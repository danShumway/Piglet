local decider = {}


function decider.pickKeys()
	local keys = {}
	local available = Piglet.Hardware.Hand.getAvailableKeys()

	--For right now, I'll just choose input at random.
	for k, v in pairs(available) do
		if math.random() < .05 then
			keys[v] = 1
		end
	end

	--Decide which keys to press.
	local checked = {} 
	checked["mem_"..Piglet.Memory.Short.currentGoal.address] = 1
	--if(input.get().tab == true) then
		decider.maximizeGoal("mem_"..Piglet.Memory.Short.currentGoal.address, 1, keys, checked, 1)
	--end
	Piglet.Hardware.Hand.setKeys(keys)
end

function decider.maximizeGoal(goal, direction, keys, checked, tick)
	--Translate a goal into an array.
	if(tick < 5) then
		tick = tick + 1
		local translate = {}
		local i = 1
		for item in string.gmatch(goal, "([^_]+)_?") do
	      translate[i] = item;
	      i = i +1
	    end

	    --If direction is positive.
	    if(direction > 0) then
	    	--If goal is a key
	    	if(translate[1] == "key") then
	    		keys[translate[2]] = 1
	    	elseif(translate[1] == "mem") then
	    		for k, v in pairs(Piglet.Memory.Short.getCauses(goal)) do
	    			--If we haven't checked that cause yet.
		    		if(checked[k] == nil) then
		    			--If the cause is worth maximizing.
		    			if(v.chance > .7) then
			    			--We have now.
			    			checked[k] = 1
			    			--Recurse down.
			    			decider.maximizeGoal(k, 1, keys, checked, tick)
			    			--Uncheck.
			    			checked[k] = nil
			    		end
		    		end
		   		end
	    	end
	    end
    end
    --

	--Start at our goal and loop through all of the states.

	--Are any negative states true?
			--If so, how do we change them?
	--Otherwise, ignore them.

	--Any positive states not true?
			--If so, how do we change them?
	--Otherwise, ignore them. (?)


end

return decider