--
--Copyright Daniel Shumway
--Licensed under GNU affero general public license
--http://www.gnu.org/licenses/agpl-3.0.html
--

---------------------------------------------------------------
--Data strcture for strategies.
---------------------------------------------------------------
-- how it works:
-- We have a set dictionary of nodes.  Each node has a way of getting a next
-- That next returns an numerical index of a node (in the dictionary).
-- When you call getKeys, it will return both the keys that should be pressed,
-- and the node to call next time you're pressing a node
---------------------------------------------------------------
local strategies = {}

function strategies.init(node_count)
	strategies.curStrategy = {strategy=strategies.strategy(10), score=0}
	strategies.prevStrategy = {strategy=strategies.strategy(10), score=0}
	strategies.refresh = false
	strategies.currentNode = strategies.curStrategy.strategy.nodes[1]
end

function strategies.getNode(number)
	return strategies.curStrategy.strategy.nodes[number]
end

function strategies.strategy(node_count)
	local strategy = {count=node_count}
	strategy.nodes = {}

	--Create the nodes
	for i=1, strategy.count do

		--Make a random selection of keys
		local random_keys = {}
		local available = Piglet.Hardware.Hand.getAvailableKeys()
		for k, v in pairs(available) do
			if math.random() < .2 then
				random_keys[v] = 1
			end
		end

		--Build node.
		strategy.nodes[i] = strategies.keyNode(random_keys, math.floor(math.random()*strategy.count)+1 )
	end

	return strategy
end

function strategies.trace(strategy)
	toPrint = " "

	local c = 1
	for i=1, strategy.strategy.count do
		toPrint = toPrint.."{"
		for k,v in pairs(strategy.strategy.nodes[c].getKeys().toPress) do
			toPrint = toPrint.." "..k
		end

		if(strategy.strategy.nodes[c].getKeys().nextNode == nil) then
			toPrint = toPrint..":nil}"
			c = 1
		else
			toPrint = toPrint..":"..strategy.strategy.nodes[c].getKeys().nextNode.."}"
			c = strategy.strategy.nodes[c].getKeys().nextNode
		end
	end

	return toPrint
end

--Returns a completely new strategy based off of the old one passed in.
function strategies.iterate(base_strategy)

	--Duplicate all the existing nodes.
	local toReturn = {count=base_strategy.count}
	toReturn.nodes = {}

	for i=1, toReturn.count do
		toReturn.nodes[i] = strategies.keyNode({}, nil)
		toReturn.nodes[i].loadData(base_strategy.nodes[i].getData())
	end


	--Pick a random node.
	local randomNode = math.floor(math.random()*toReturn.count)+1

	--Make a random selection of keys
	local random_keys = {}
	local available = Piglet.Hardware.Hand.getAvailableKeys()
	for k, v in pairs(available) do
		if math.random() < .2 then
			random_keys[v] = 1
		end
	end

	--Build the node and replace the old one.
	toReturn.nodes[randomNode] = strategies.keyNode(random_keys, math.floor(math.random()*toReturn.count)+1)
	--Return new data structure.
	return {strategy=toReturn, score=0}
end

--Allows Piglet to press keys.
function strategies.keyNode(step_keys, node_next)
	local node = {type="keyNode"}

	function node.getKeys()
		return {toPress=step_keys, nextNode=node_next}
	end

	--Saving and loading.
	function node.getData()
		return {toPress=step_keys, nextNode=node_next, type="keyNode"}
	end

	function node.loadData(node_data)
		step_keys = node_data.toPress
		node_next = node_data.nextNode
		node.type="keyNode"
	end

	return node
end

--Allows Piglet to execute some basic logic.
--mem_address (number), the address for the if statement.
--comparison (number 0-255), the value to run comparison on
--true_next (number), what node to go to if 
function strategies.choiceNode(mem_address, comparison, true_next, false_next)
	local node = {type="choiceNode"}

	return node
end

--Send stuff back out.
strategies.init()
return strategies