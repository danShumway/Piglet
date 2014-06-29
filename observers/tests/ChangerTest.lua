--
--Copyright Daniel Shumway, 2014
--Licensed under GNU affero general public license
--http://www.gnu.org/licenses/agpl-3.0.html
--

--ToDo:  Remember how to check strings in lua.  It's something like string.at or something stupid.
--In the meantime, we're going to reference this stuff with STRING(string, index)
--That way, we can change it easily later.
--In fact, all uppercase stuff will be rewritten later.  Just assume it.

print('hello there from ChangerTest')

local watching = {}

--
watching.statesChecked = {}
watching.effects = {}
watching.currentlyWatching = "default"
watching.shouldCheck = false
watching.decayRate = 10
watching.decay = 10

--Set up a list of states that you can check.  This will by dynamically updated as we go.
watching.canCheck = {}
watching.canCheck[1] = "key_left"
watching.canCheck[2] = "key_right"
watching.canCheck[3] = "key_up"
watching.canCheck[4] = "key_down"
watching.canCheck[5] = "key_A"
watching.canCheck[6] = "key_B"
watching.canCheck[7] = "default"
--watching.cancheck[3] = 

function watching.resetNextFrame(self, memory, keys)
	self.statesChecked = {}
	self.currentlyWatching = self.canCheck[math.random(1,7)]
	self.shouldCheck = self.checkState(self, self.currentlyWatching, memory, keys)
	--Reset whatever else need to be reset here.

	self.decay = self.decay - 1
	if(self.decay < 0) then self.decay = self.decayRate end
end


function watching.tallyScore(self, state, currentByte, currentByteChange, keys)
	local changeLikelyhood = 0 --0 means we have no idea what's going to happen.
	--If this is a frame we've checked before.
	if(self.effects[currentByte] ~= nil) then
		--Loop through and see if any of the other states are true.
		for k, v in pairs(self.effects[currentByte]) do
			if (k ~= state) then --I don't want to include what I'm currently checking into the whole expected, unexpected
				if(self.statesChecked[k] == nil) then --If we haven't checked it yet, check it.
					self.statesChecked[k] = self.checkState(self, k, changes, keys)
				end
				--Now we do the actual check
				if(self.statesChecked[k] == true) then
					--Keep it simple for the time being.  Add the associated likelyhood that it changes.
					--Remember, associated likelyhood is an int.  Positive makes it more likely to change, negative, more likely to be constant.
					--0 means we have literally no idea what will happen.  You shouldn't ever run into 0s, there's no point in storing them.
						-- Well, really, I suppose a 0 would mean that we know something self.effects a value, but it seems to make it change and stay constant at random.
					changeLikelyhood = changeLikelyhood + v --Remember, v is the value stored at self.effects[a]
				end
			end
		end --end for loop checking existing states we remember having an effect.
		-- did it do something unexpected?
		if(currentByteChange == 0 and changeLikelyhood >= 0) then --If it didn't change and we would, based on the currently true states, expect to change.
			-- Update the current checked state as a possible cause.
			if(self.effects[currentByte][state] ~= nil) then --If it exists.
				self.effects[currentByte][state] = self.effects[currentByte][state] - 1 --This is slightly more likely to make the byte not change.
			else
				self.effects[currentByte][state] = -1 --Add it as a new possible cause.
			end
		elseif(currentByteChange ~= 0 and changeLikelyhood <= 0) then --If it did change, and based on the currently true states, we expected it not to.
			-- Update the current checked state as a possible cause.
			if(self.effects[currentByte][state] ~= nil) then --If it exists.
				self.effects[currentByte][state] = self.effects[currentByte][state] + 1 --This is slightly more likely to make the byte change.
			else
				self.effects[currentByte][state] = 1 --Add it as a new possible cause.
			end
		else
			--Decay here if nothing interesting happened.  Like you're forgetting almost.
			if(self.decay == 0 and self.effects[currentByte][state] ~= nil) then --We gravitate towards 0 if behaviors aren't reinforced.
				if(self.effects[currentByte][state] > 0) then 
					self.effects[currentByte][state] = self.effects[currentByte][state] - 1
				elseif(self.effects[currentByte][state] < 0) then
					self.effects[currentByte][state] = self.effects[currentByte][state] + 1
				end
			end
		end
	else
		--Add it.
		self.effects[currentByte] = {}
	end
end

function watching.checkState(self, state, changes, keys)
	local translate = {}
	local i = 1
	for item in string.gmatch(state, "([^_]+)_?") do
      translate[i] = item;
      i = i +1
    end
	--local translate = string.gmatch(state, "([^_]+)_?")

	if(state == "default") then 

		return true 
	end --This is always true.  It's something that changes kind of regardless of what's pressed, or at least by default.

	--All our states start with what to check.
	if(translate[1] == "mem") then
		if(changes[translate[2]] ~= 0) then
			return true
		end
		return false --Hasn't changed.
	elseif(translate[1] == "key") then
		if(keys[translate[2]]) then
			return true
		end
		return false --Isn't down.
	end
end



function watching.chooseToWatch(self)
	--Write out a syntactically correct postulate based on something you've watched.

end


return watching