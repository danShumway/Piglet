--
--Copyright Daniel Shumway, 2014
--Licensed under GNU affero general public license
--http://www.gnu.org/licenses/agpl-3.0.html
--

local observer = {}

--The only data we'll actually store.
observer.lastFrame = false
observer.lastInput = false

observer.currentInput = false
observer.currentFrame = false

--int levels of certainty for what bytes are effected by the action continuing (2), starting (1), being false (0), and ending (-1)
observer.results = {}
observer.results[-1] = {}
observer.results[0] = {}
observer.results[1] = {}
observer.results[2] = {}
observer.cause = false


observer.finalConclude = {}

function observer.Setup(self)
	for a=1, 256*16*16 do
		for b=-1, 2 do
			self.results[b][a] = 0
		end
		self.finalConclude[a] = 0
	end
	self.lastInput = {}--0--
	self.currentInput = {}--0--
end


function observer.Observe(self)
	self.lastFrame = self.currentFrame
	self.currentFrame = memory.readbyterange(0, 256*16*16)
	self.lastInput = self.currentInput
	self.currentInput = joypad.get(1)--memory.readbyte(65409)--

	if(self.lastFrame ~= false) then
		--Loop through memory and see what you can see.
		for a=1, 256*16*16 do
			if(self.cause ~= false) then
				if(self.lastFrame[a] ~= self.currentFrame[a]) then
					self.results[self.cause][a] = self.results[self.cause][a] + 1
				else
					self.results[self.cause][a] = self.results[self.cause][a] - 1
				end
			end
		end

	end

	self.cause = self.ActionTrue(self)
end



function observer.Conclude(self)
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
		if(self.results[0][a] > 0) then
			self.finalConclude[a] = self.finalConclude[a] - self.results[0][a]
		end
	end
end

function observer.MakePrediction(self)
	for a=1, 256*16*16 do
		--Make a list of 4 bytes.
		--Check them to see if they always work.

	end
end


--Whether or not the cause is happening.
--Returns 2 (is true), 1 (just started), 0 (is false), -1 (just ended)
function observer.ActionTrue(self)
	--Were you pressing the key?
	if(self.lastInput.right == true) then
		--Are you pressing it now.
		if(self.currentInput.right == true) then 
			return 2 --Continue
		else
			return -1 --Just ended
		end
	else
		if(self.currentInput.right == true) then
			return 1 --Just started
		else
			return 0 --Continue false
		end
	end
end

-- function observer.ActionTrue(self)
-- 	--Were you pressing the key?
-- 	if(self.lastInput == 16) then
-- 		print('was')
-- 		--Are you pressing it now.
-- 		if(self.currentInput == 16) then 
-- 			print('continue')
-- 			return 2 --Continue
-- 		else
-- 			print('end')
-- 			return -1 --Just ended

-- 		end
-- 	else
-- 		if(self.currentInput == 16) then
-- 			print('start')
-- 			return 1 --Just started
-- 		else
-- 			return 0 --Continue false
-- 		end
-- 	end
-- end

return observer;