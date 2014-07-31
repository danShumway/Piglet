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
	local curFrame = Piglet.Memory.Instant.currentFrame
	local curChanges = Piglet.Memory.Instant.currentChanges
	local watching = Piglet.Memory.Short.watching
	--local rand = math.random(55536)
	--Pick a random 10,000 coord block.
	--for k=rand, rand+10000--[[65536]] do --Not sure how much these help, but some optimizations.
	for k=1, 65536 do
		local v = curFrame[k]
		--Observable states.

		--First we loop through and see which states are true/false.
		local causes = Piglet.Memory.Short.getCauses("mem_"..k)
		local frameChanged = false
		if(Piglet.Memory.Instant.currentChanges[k] ~= nil) then --Did the frame we're on change?
			frameChanged = true
		else
			frameChanged = false
		end
		local changeLikelyhood = 0 --The likelyhood that this effect will happen.
		local i = 0 --How many causes we've run.
		for k_2, v_2 in pairs(causes) do
			--Is it true?
			if(Piglet.Processor.checkPastState(k_2) == 1) then
				i = i+1 --Look, a possible cause.
				changeLikelyhood = changeLikelyhood + v_2.chance --Add likelyhood.
			end
		end

		--We don't get final likelyhood of change here, because it varies depending on what we're testing.

		--Loop through and update the states we're wathing.
		--print("c: "..)
		for k_2, v_2 in pairs(watching) do
			local myLikelyhood = changeLikelyhood
			local j = i
			--Is it currently true?
			if(Piglet.Processor.checkPastState(k_2) == 1) then
				--Does it exist?
				if(causes[k_2] ~= nil) then
					--Don't count your own probability against you.
					myLikelyhood = myLikelyhood - causes[k_2].chance
					j = j - 1
				end

				--Now, get final likelyhood and subtract.
				if(j ~= 0) then
					--myLikelyhood = myLikelyhood / j
				end

				--Depending on if the frame changed, we move in one of two directions.
				if(frameChanged == true) then
					-- We adjust by 1 - changeLikelyhood
					Piglet.Memory.Short.updateCause("mem_"..k, k_2, math.max(1 - myLikelyhood, 0))

				else
					--We adjust by -1 - changeLikelyhood
					Piglet.Memory.Short.updateCause("mem_"..k, k_2, math.min(0 - myLikelyhood, 0))
					
				end
			end
		end
	end
end


return changerTest