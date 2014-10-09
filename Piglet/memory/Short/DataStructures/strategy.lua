--
--Licensed under GNU affero general public license
--http://www.gnu.org/licenses/agpl-3.0.html
--

----------------------------------------------------------------------
--Data structure for strategies.
----------------------------------------------------------------------
local strategies = {}

--Generates a new node for use in a strategy
--Add what keys you want pressed, and the nodes that you want to be inserted in.
function strategies.keyNode(step_keys, node_prev, node_next)
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

	function node.delete()
		if prev ~= nil then
			prev.updateNext(next)
		end
		if next ~= nil then
			next.updatePrev(prev)
		end
	end

	--Handle mutation.
	--Recursively via first node.
	function node.mutate()

		if math.random() < .05 then
			--Get some random keys.
			local random_keys = {}
			local available = Piglet.Hardware.Hand.getAvailableKeys()
			for k, v in pairs(available) do
				if math.random() < .2 then
					random_keys[v] = 1
				end
			end

			--Choose where to attach them.
			local r = math.random(1, 6)



			if r == 1 then --Adjust current node.
				keys = random_keys

			elseif r == 2 then --Insert a previous node.
				local new_node = strategies.keyNode(random_keys, prev, node)
				if prev ~= nil then prev.updateNext(new_node) end
				prev = new_node

			elseif r == 3 then --Insert a next node.
				local new_node = strategies.keyNode(random_keys, node, next)
				if next ~= nil then next.updatePrev(new_node) end
				next = new_node

			elseif r == 4 then --Delete a previous node.
				if prev ~= nil then 
					prev.delete()
				end

			elseif r == 5 then --Delete next node.
				if(next ~= nil) then
					next.delete()
				end
			end
		end


		--Move on to the next node.
		if(next ~= nil) then
			next.mutate()
		end
	end

	--Returns a new strategy, optionally do mutations as well.
	function node.duplicate()
		--If you're not at the end of the sequence.
		local duplicated_next = nil
		local count = 1
		if next ~= nil then
			duplicated_next = next.duplicate(do_mutation)
		end

		local toReturn = strategies.keyNode(keys, nil, duplicated_next) --Replace current node.

		--Having a second if here is inneficient, todo: take a look at fixing it.
		if duplicated_next ~= nil then
			duplicated_next.updatePrev(toReturn) --Fix current node.
		end

		--Give back the head (or if recursive the currently generated node).
		return toReturn
	end

	function node.toString(i)
		local toReturn = i.."{"
		for k,v in pairs(keys) do
			toReturn = toReturn..k
		end
		toReturn = toReturn.."}"
		if(next ~= nil) then toReturn = toReturn..", "..next.toString(i+1) end
		return toReturn
	end

	return node
end

--Not filled out right now, but will be.
function strategies.choiceNode()

end

--Length: how many strategies.  **Must** be at least 1.
function strategies.init(length, chances)
	strategies.count = length --
	strategies.baseChances = chances
	for i=1, length, 1 do
		strategies[i] = {score=0, chancesLeft=strategies.baseChances, size=1, cost=0, strategy=strategies.keyNode({}, nil, nil) }
	end


	--Used to figure out where we are in the strategies.
	strategies.currentIndex = 1
	strategies.currentNode = strategies[1].strategy
end

function strategies.iterate(strategy)
	for i=1, strategies.count, 1 do
		local _strategy = nil local _size = nil
		_strategy = strategy.duplicate()
		strategies[i] = {score=0, chancesLeft=strategies.baseChances, cost=0, strategy=_strategy }
		_strategy.mutate()
	end

	--Used to figure out where we are in the strategies.
	strategies.currentIndex = 1
	strategies.currentNode = strategies[1].strategy
end

----------------------------------------------------------------------
--end data structure for strategies.
----------------------------------------------------------------------

return strategies