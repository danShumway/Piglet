local changerTest = {}

function changerTest.doFull()
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
	end
end



function changerTest.reverse()

	--Loop through every action we know we can do.
	--Keys/States we've observed
		--Are any of them currently true?
			--What is being effected?
			for k, v in pairs(Piglet.Memory.Instant.currentChanges) do
				--Update.
			end
end


return changerTest