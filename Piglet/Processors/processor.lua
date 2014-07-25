local processor = {}


--Do some processing on the info.
function processor.process()
	--We'll potentially deal with this differently in the future.
	Piglet.Memory.Short.forgetStates()

	--Loop through the changes and see what's going on.
	local i = 0
	local j = 0
	for k, v in pairs(Piglet.Memory.Instant.currentChanges) do
		--For each change, look changes from the previous frame.
		i = i+1
		j = 0

		--hard break fix
		if(i > 200) then
			break
		end

		for k_2, v_2 in pairs(Piglet.Memory.Instant.lastChanges) do
			--Add it as a possible cause.
			Piglet.Memory.Short.updateCause("mem_"..k, "mem_"..k_2, 1)
			Piglet.Memory.Short.setState("mem_"..k, 1)
			j = j+1
			--Hard break fix.
			if(j > 200) then
				break
			end
		end

		for k_2, v_2 in pairs(Piglet.Hardware.Hand.getKeys()) do
			Piglet.Memory.Short.updateCause("mem_"..k, "key_"..k_2, 1)
		end

		--Also add in currently held keys as a possible cause.
		--And pick a goal I guess.
	end
	processor.pickGoal()
	--print(i.." : "..j)
	print(Piglet.Memory.Short.currentGoal.address)

end

function processor.pickGoal()

	local bestGoal = {}
	bestGoal.address = 0
	bestGoal.rating = 0

	for k, v in pairs(Piglet.Memory.Instant.currentChanges) do
		local currentRating = 0
		--Figure out what the rating is for that byte and deal with it.
		local causes = Piglet.Memory.Short.getCauses("mem_"..k)
		if(causes ~= nil) then
			for k_2, v_2 in pairs(causes) do
				-- + (1 minus the difference between it and .5)
				--currentRating = currentRating + (1 - math.abs(v_2.chance - .5))
				-- + (the difference between it and .5)
				currentRating = currentRating + (math.abs(v_2.chance - .5) - .1)
			end
			--Check to see if it's a good goal.
			if(currentRating > bestGoal.rating) then
				bestGoal.address = k
				bestGoal.rating = currentRating
			end
		end
	end

	Piglet.Memory.Short.currentGoal = bestGoal
end




--Look up a state and see if it's currently true or not.
function processor.checkState(state)
	local translate = {}
	local i = 1
	for item in string.gmatch(state, "([^_]+)_?") do
      translate[i] = item;
      i = i +1
    end
	--local translate = string.gmatch(state, "([^_]+)_?")
	if(state == "default") then 
		return 1
	end --This is always true.  It's something that changes kind of regardless of what's pressed, or at least by default.

	--All our states start with what to check.
	if(translate[1] == "mem") then
		--print(translate[2])
		translate[2] = tonumber(translate[2])
		if(self.curFrame[translate[2]] - self.prevFrame[translate[2]] ~= 0) then
			return 1
		end
		return 0 --Hasn't changed.
	elseif(translate[1] == "key") then
		if(keys[translate[2]]) then
			return 1
		end
		return 0 --Isn't down.
	end
end























return processor