--
--Copyright Daniel Shumway, 2014
--Licensed under GNU affero general public license
--http://www.gnu.org/licenses/agpl-3.0.html
--

local observer = {}

--The only data we'll actually store.
observer.lastFrame = false
observer.lastInput = false

observer.currentInput = {}
observer.currentFrame = {}

--int levels of certainty for what bytes are effected by the action continuing (2), starting (1), being false (0), and ending (-1)
observer.results = {}
observer.results[-1] = {}
observer.results[0] = {}
observer.results[1] = {}
observer.results[2] = {}
observer.finalConclude = {}

observer.keys = {"left", "right", "up", "down", "A", "B"}
--You have a list of states.  Right now this is built for keypresses.
--I should also build it out for variables, probably.  Anyway.. more stuff to come.
observer.currentTest = "left"--{{"left", 1, 1}, {"right", 1, -1}}

observer.postulates = {}

observer.lastState = -3
observer.currentState = -3


--
function observer.checkState(self)


end

function observer.Setup(self)
	for a=1, 256*16*16 do
		for b=-1, 2 do
			self.results[b][a] = 0
			self.currentFrame[a] = 0
		end
		self.finalConclude[a] = 0
	end
	self.lastInput = {}
	self.currentInput = {}
end

function observer.Keydown(self)
	--currentInput.A
	if(self.currentInput.A) then
		return 1
	end
	return 0
end


observer.watcherObj = dofile('../observers/tests/ChangerTest.lua')
function observer.Observe(self)
	self.lastFrame = self.currentFrame
	self.currentFrame = memory.readbyterange(0, 256*16*16)

	self.lastInput = self.currentInput
	self.currentInput = joypad.get(1)

	if(self.lastFrame ~= false) then
		--Loop through memory and see what you can see.
		self.watcherObj.resetNextFrame(self.watcherObj, self.currentFrame, self.lastFrame, self.currentInput)
		--print(self.currentFrame[65521])
		--vba.message("s: "..self.currentFrame[42275]..", c: "..self.currentFrame[65466])
		--vba.message(self.watcherObj.currentlyWatching)
		if(self.watcherObj.mostRecentAddedValue ~= nil) then
			local toSend = self.watcherObj.checkState(self.watcherObj, self.watcherObj.mostRecentAddedValue, self.currentInput);
			if(toSend == true) then
				vba.message("happy")
			else
				vba.message("sad")
			end
		end
		if(self.watcherObj.shouldCheck) then


			local start = math.random(1, (256*16*16) - 10000)

			--for a=start, start+10000 do
			--	self.watcherObj.tallyScore(self.watcherObj, self.watcherObj.currentlyWatching, a, self.lastFrame[a] - self.currentFrame[a], self.currentInput)


			for a=1, 256*16*16 do
				self.watcherObj.tallyScore(self.watcherObj, self.watcherObj.currentlyWatching, a, self.lastFrame[a] - self.currentFrame[a], self.currentInput)

				--[[
				if(self.lastFrame[a] ~= self.currentFrame[a]) then
					--We've changed.
					self.results[self.currentState][a] = self.results[self.currentState][a] + 1
				else
					--We've stayed the same.
					self.results[self.currentState][a] = self.results[self.currentState][a] - 1
				end
				--]]
			end
		end
	end
end

function observer.GetByte(address)
	return memory.readbyterange(address - 1, 1)[1]
end

function observer.Conclude(self)
	local count = 0
	local best = { 0, 0 }
	for a=1, 256*16*16 do

		--CONTINUOUS--

		--First we add together the values from starting and stopping.
		--If something changes when you start and stop, consistently, that probably means that it's effected by what's going on.
		-- self.finalConclude[a] = self.results[1][a] + self.results[-1][a]
		-- --Now we subtract things that change when the keys aren't pressed.  If it's changing when nothing is happening, how are you effecting it?
		-- if(self.results[0][a] > 0) then
		-- 	self.finalConclude[a] = self.finalConclude[a] - self.results[0][a]
		-- end

		--WE JUST WANT START/END, THEN WE FILTER OUR OTHER CHANGES.
		-- self.finalConclude[a] = self.results[-1][a]
		-- if(self.results[0][a] > 0) then
		-- 	self.finalConclude[a] = self.finalConclude[a] - self.results[0][a]
		-- end

		--So lets say we want continual change.
		--Let's only record changes that are happening while the key is down.
		self.finalConclude[a] = self.results[2][a]


		--Some internal things I'll deal with now.
		if(self.finalConclude[a] > 0) then
			count = count + 1
		end

		--If you've got a new best.
		if(self.finalConclude[a] > best[2]) then
			best = {a, self.finalConclude[a]}
		end
	end

	--Form a postulate.
	--This action effects this byte.

	vba.print(count)
end


--Whether or not the cause is happening.
--Returns 2 (is true), 1 (just started), 0 (is false), -1 (just ended)
function observer.ActionTrue(self, truthFunction)

	--Get the current truth state, yes (1), no (0), or disregard (-1)
	local state = truthFunction(self)

	if(truthFunction == -1) then 
		return -3 --If you're meant to disregard, do it already.
	else
		--We only do this if we're not ignoring the current frame.
		self.lastState = self.currentState --Get the past working correctly.
	end

	--Otherwise, *let's get creative!*
	--Was the action true last frame?
	if(self.lastState == 1 or self.lastState == 2) then
		--Is the action currently true?
		if(state == 1) then 
			return 2 --Continue
		else
			return -1 --Just ended
		end
	else
		--Is the action currently true?
		if(state == 1) then
			return 1 --Just started
		else
			return 0 --Continue false
		end
	end
end

return observer;