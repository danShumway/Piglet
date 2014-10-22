--
--Licensed under GNU affero general public license
--http://www.gnu.org/licenses/agpl-3.0.html
--

local processor = {}

local test = dofile("Processors/tests/smarterGuessTestRevise.lua")--dofile("Processors/tests/changerTest.lua")

--Do some processing on the info.
function processor.process()

	--We'll potentially deal with this differently in the future.
	--[[
	Piglet.Memory.Short.forgetStates()

	test.reverse()
	Piglet.Memory.Long.save("Mario_6Golden_Coins", "test_01", Piglet.Memory.Short.allCauses())

	]]
	--processor.pickGoal()

	--print(Piglet.Memory.Short.currentGoal.address)
	--print(Piglet.Memory.Short.currentGoa)
	test.iterate()

end



---------------------------------------------------------------------------
--Not used at this state, this is for updating goals based on the whole
--causation model, which I'm not going to be using soon.
---------------------------------------------------------------------------

function processor.pickGoal()

	local bestGoal = {}
	bestGoal.address = 0
	bestGoal.rating = 0
	bestGoal.goal = "mem_0"

	for k, v in pairs(Piglet.Memory.Instant.currentChanges) do
		local currentRating = 0
		--Figure out what the rating is for that byte and deal with it.
		local causes = Piglet.Memory.Short.getCauses("mem_"..k)
		if(causes ~= nil) then
			for k_2, v_2 in pairs(causes) do
				-- + (1 minus the difference between it and .5)
				currentRating = currentRating + (1 - math.abs(v_2.chance - .5))
				-- + (the difference between it and .5)
				--currentRating = currentRating + (math.abs(v_2.chance - .5) - .1)
			end
			--Check to see if it's a good goal.
			if(currentRating > bestGoal.rating) then
				bestGoal.address = k
				bestGoal.rating = currentRating
				bestGoal.goal = "mem_"..k
			end
		end
	end

	Piglet.Memory.Short.currentGoal = bestGoal
end

--Look up a state and see if it was true or not last frame.
--This way we can build up a causal relationship.  If something changes 1 frame,
--and something else changes on the next frame, that's a relationship.
function processor.checkPastState(state)
	if(Piglet.Memory.Short.getState(state) ~= -1) then
		--If we already know, just return it.
		return Piglet.Memory.Short.getState(state)
	else
		--Otherwise, let's parse the state.
		local translate = {}
		local i = 1
		for item in string.gmatch(state, "([^_]+)_?") do
	      translate[i] = item;
	      i = i +1
	    end
		--local translate = string.gmatch(state, "([^_]+)_?")
		if(state == "default") then 
			Piglet.Memory.Short.setState(state, 1)
			return 1
		end --This is always true.  It's something that changes kind of regardless of what's pressed, or at least by default.

		--All our states start with what to check.
		if(translate[1] == "mem") then
			translate[2] = tonumber(translate[2])
			--If the byte changed last frame, that means we're currently in a true state(ie, a cause.)
			if(Piglet.Memory.Instant.lastChanges[translate[2]] ~= nil) then
				Piglet.Memory.Short.setState(state, 1)
				return 1
			end
			--Not true.
			Piglet.Memory.Short.setState(state, 0)
			return 0 --Hasn't changed.
		elseif(translate[1] == "key") then
			if(Piglet.Hardware.Hand.getKeys()[translate[2]] ~= nil) then
				--Set state and return true.
				Piglet.Memory.Short.setState(state, 1)
				return 1
			end
			--Not true.
			Piglet.Memory.Short.setState(state, 0)
			return 0 --Isn't down.
		end
	end
end



return processor