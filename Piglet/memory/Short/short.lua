local short = {}

--Causes are used here with percentage values.
local causes = {}
local states = {}
short.watching = {key_left=1, key_right=1, key_up=1, key_down=1, key_A=1, key_B=1, key_select=1, default=1}
short.currentGoal = {}
short.currentGoal.address = 0
short.currentGoal.rating = 0
short.currentGoal.goal = "mem_0"


------------------------------------------------------------------------------------------------------
-------------------------SIGNIFICANT CHANGES----------------------------------------------------------
--Keeps track of all of the states that have been seen, and the number of times they have been seen.
--
------------------------------------------------------------------------------------------------------

local seen = {}

----------------------------------------------------------------------
--Data structure for short.strategies.
----------------------------------------------------------------------
short.strategies = {}

--Generates a new node for use in a strategy
--Add what keys you want pressed, and the nodes that you want to be inserted in.
function short.strategies.keyNode(step_keys, node_prev, node_next)
	local node = {}
	local keys = step_keys

	--For attaching and internal use.
	local prev = node_prev
	local next = node_next
	--Updating position.
	function node.updateNext(new_node)
		next = new_node
	end
	function node.updatePrev(new_node)
		prev = new_node
	end

	--Returns both the keys that you're supposed to press
	--And a link to the next node to check (or nil if you're at the end of the )
	function node.getKeys()
		return {toPress=keys, nextNode=next}
	end

	--Handle mutation.
	function node.mutate()

		if math.random() < .07 then
			--Get some random keys.
			local random_keys = {}
			local available = Piglet.Hardware.Hand.getAvailableKeys()
			for k, v in pairs(available) do
				if math.random() < .2 then
					random_keys[v] = 1
				end
			end

			--Choose where to attach them.
			local r = math.random()
			if r < .333 then --Adjust current node.
				keys = random_keys
				--print('mutated new combo')
			elseif r < .499 then --Insert a previous node.
				local new_node = short.strategies.keyNode(random_keys, prev, node)
				if prev ~= nil then prev.updateNext(new_node) end
				--print('mutated new step')
				prev = new_node
			elseif r < .666 then --Insert a next node.
				--print('mutated new step')
				local new_node = short.strategies.keyNode(random_keys, node, next)
				if next ~= nil then next.updatePrev(new_node) end
				next = new_node
			elseif r < .832 then --Delete a previous node.
				if prev ~= nil then 
					--Finish this soon.
				end
			else --Delete a next node.
				if next ~= nil then
					--Finish this soon.
				end
			end
		end
	end

	--Returns a new strategy, optionally do mutations as well.
	function node.duplicate(do_mutation)
		--If you're not at the end of the sequence.
		local duplicated_next = nil
		if next ~= nil then
			duplicated_next = next.duplicate(do_mutation)
		end

		local toReturn = short.strategies.keyNode(keys, nil, duplicated_next) --Replace current node.

		--Having a second if here is inneficient, todo: take a look at fixing it.
		if next ~= nil then
			duplicated_next.updatePrev(duplicated_next) --Fix current node.
		end

		--If you're meant to mutate.
		if do_mutation then
			toReturn.mutate()
		end

		--Give back the head (or if recursive the currently generated node).
		return toReturn
	end

	function node.toString(i)
		local toReturn = i..":"
		for k,v in pairs(keys) do
			toReturn = toReturn..k
		end
		if(next ~= nil) then toReturn = toReturn..", "..next.toString(i+1) end
		return toReturn
	end

	return node
end

--Not filled out right now, but will be.
function short.strategies.choiceNode()

end

--Length: how many short.strategies.  **Must** be at least 1.
function short.strategies.init(length, chances)
	short.strategies.count = length --
	short.strategies.baseChances = chances
	for i=1, length, 1 do
		short.strategies[i] = {score=0, chancesLeft=short.strategies.baseChances, strategy=short.strategies.keyNode({}, nil, nil) }
	end


	--Used to figure out where we are in the short.strategies.
	short.strategies.currentIndex = 1
	short.strategies.currentNode = short.strategies[1].strategy
end

function short.strategies.iterate(strategy)
	for i=1, short.strategies.count, 1 do
		short.strategies[i] = {score=0, chancesLeft=short.strategies.baseChances, strategy=strategy.duplicate(true) }
	end

	--Used to figure out where we are in the short.strategies.
	short.strategies.currentIndex = 1
	short.strategies.currentNode = short.strategies[1].strategy
end

----------------------------------------------------------------------
--end data structure for short.strategies.
----------------------------------------------------------------------


--Returns the number of times I've seen this state.
function short.haveSeen(state, value)
	--If I've seen this state change.
	if(seen[state]) then
		if(seen[state][value]) then
			return seen[state][value]
		end
	end

	return 0
end

--Adds a new state to the list of things you've seen.
--Also returns the number of time's I've seen this state.
function short.updateSeen(state, value)
	--Set up state if it doesn't yet exist.
	if(seen[state] == nil) then
		seen[state] = {}
	end
	--Set up seen state if it doesn't exist yet.
	if(seen[state][value] == nil) then
		seen[state][value] = 1 --I've seen it once.
		return 0
	else
		seen[state][value] = seen[state][value] + 1 --I've seen it again.
		return seen[state][value] - 1
	end
end




-------------------------------------------------------------------------------------------------------
--------------------------CAUSE AND EFFECT-------------------------------------------------------------
-------------------------------------------------------------------------------------------------------

--Send a state/result to the causes array.  Effect isn't really talked about here.
function short.updateCause(state, cause, direction)
	--If we don't have existing data for the state.
	if(causes[state] == nil) then
		--Create the state
		causes[state] = {}
	end

	--If we haven't created or observed this cause yet.
	if(causes[state][cause] == nil) then
		--Create the cause
		causes[state][cause] = {}
		--There are a couple of fields we care about making.
		causes[state][cause].trials = 1
		causes[state][cause].effect = 1

		--Start it at the proper chance.
		causes[state][cause].chance = direction
	else 
		--We keep things simple for right now.
		--Just update it.  Don't worry about bayesian stuff.

		--Extract out the actual number of successes.
		causes[state][cause].chance = causes[state][cause].chance*causes[state][cause].trials;
		
		--Adjust likelyhood.
		causes[state][cause].chance = causes[state][cause].chance + direction


		--Increase number of trials
		causes[state][cause].trials = causes[state][cause].trials + 1
		--Reset to a decimal chance.
		causes[state][cause].chance = causes[state][cause].chance/causes[state][cause].trials
	end
end


--Needs some refinement.
function short.getCauses(state)
	--Return all the causes related to that state.
	if(causes[state] == nil) then
		return {}
	end
	--Else
	return causes[state]
end

function short.allCauses()
	return causes
end

function short.rememberCauses(_c)
	causes = _c
end

--Returns whether or not a state is true.
--Returns 1 (true), 0(false), or -1, unknown.
function short.getState(state)
	if(states[state] ~= nil) then
		return states[state]
	else
		return -1
	end
end

--The value of the state to set, and the int value to set it as (1, 0, -1)
function short.setState(state, value)
	states[state] = value
end

function short.forgetStates()
	states = {}
end

return short