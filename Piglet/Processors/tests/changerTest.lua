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

	--Loop through all of the frames.
	for k, v in pairs(Piglet.Memory.Instant.currentFrame) do
		--Observable states.
		for k_2, v_2 in pairs(Piglet.Memory.Short.watching) do
			--Update depending on whether or not what that state is true.
			if(Piglet.Processor.checkPastState(k_2) == 1) then
				--if it was a change.
				if(Piglet.Memory.Instant.currentChanges[k] ~= nil) then
					Piglet.Memory.Short.updateCause("mem_"..k, k_2, 1)
				else
					Piglet.Memory.Short.updateCause("mem_"..k, k_2, -1)
				end
			end

			if(k_2 ~= 'default') then --Hard check
				--If the cause is above 95% and it's not a member of watching, add it.
				if(Piglet.Memory.Short.getCauses("mem_"..k_2)[k] ~= nil and Piglet.Memory.Short.getCauses("mem_"..k_2)[k].chance > .85 and Piglet.Memory.Short.watching["mem_"..k_2] == nil) then
					Piglet.Memory.Short.watching["mem_"..k_2] = 1
					Piglet.Memory.Short.currentGoal = {goal="mem_"..k_2}
					print('added state: '.."mem_"..k_2)
				end
			end
		end
	end
end



function changerTest.reverse()

	--Loop through every action we know we can do.
	for k, v in pairs(Piglet.Memory.Short.watching) do
	--Keys/States we've observed
		--Are any of them currently true?  --Skip for now.
			--What is being effected?
			for k_2, v_2 in pairs(Piglet.Memory.Instant.currentFrame) do
				--Update depending on whether or not what we're watching is actually true.
				if(Piglet.Processor.checkPastState(k) == 1) then
					--if it was a change.
					if(Piglet.Memory.Instant.currentChanges[k_2] ~= nil) then
						Piglet.Memory.Short.updateCause("mem_"..k_2, k, 1)
					else
						Piglet.Memory.Short.updateCause("mem_"..k_2, k, -1)
					end
				end

				if(k ~= 'default') then --Hard check
					--If the cause is above 95% and it's not a member of watching, add it.
					if(Piglet.Memory.Short.getCauses("mem_"..k_2)[k] ~= nil and Piglet.Memory.Short.getCauses("mem_"..k_2)[k].chance > .85 and Piglet.Memory.Short.watching["mem_"..k_2] == nil) then
						Piglet.Memory.Short.watching["mem_"..k_2] = 1
						Piglet.Memory.Short.currentGoal = {goal="mem_"..k_2}
						print('added state: '.."mem_"..k_2)
					end
				end
			end
	end
end


return changerTest