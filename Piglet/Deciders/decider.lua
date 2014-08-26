local decider = {}


function decider.pickKeys()
	--vba.print(Piglet.Memory.Short.currentGoal.goal)
	--[[
	local keys = {}
	local available = Piglet.Hardware.Hand.getAvailableKeys()

	--For right now, I'll just choose input at random.
	for k, v in pairs(available) do
		if math.random() < .2 then
			keys[v] = 1
		end
	end
	]]

	--Get the keys for this current test.
	local currentStep = Piglet.Memory.Short.strategies.currentNode.getKeys()
	--If we'ver reached the end of this sequence.
	if(currentStep.nextNode == nil) then
		Piglet.Memory.Short.strategies.currentIndex = Piglet.Memory.Short.strategies.currentIndex + 1
		if(Piglet.Memory.Short.strategies.currentIndex > Piglet.Memory.Short.strategies.count) then
			Piglet.Memory.Short.strategies.currentIndex = 1 --Loop.
			--We've looped, which means this is a full trial.
			Piglet.Memory.Short.strategies.chancesLeft = Piglet.Memory.Short.strategies.chancesLeft - 1
			--Oh yeah, we need a new node for next turn.
			Piglet.Memory.Short.strategies.currentNode = Piglet.Memory.Short.strategies[1].strategy
		end
	else
		Piglet.Memory.Short.strategies.currentNode = currentStep.nextNode
	end

	--Decide which keys to press.
	--local checked = {} 
	--checked[Piglet.Memory.Short.currentGoal.goal] = 1
	--if(input.get().tab == true) then
		--decider.maximizeGoal(Piglet.Memory.Short.currentGoal.goal, 1, keys, checked, 1)
	--end
	Piglet.Hardware.Hand.setKeys(currentStep.toPress)
end



function decider.getCombosForGoal()

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
end

return decider