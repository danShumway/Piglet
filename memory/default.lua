--
--Copyright Daniel Shumway, 2014
--Licensed under GNU affero general public license
--http://www.gnu.org/licenses/agpl-3.0.html
--

--make our memory object
local memory = {}

--++++++++++++++++++++PUBLIC+++++++++++++++++++++++++++++++

memory.pastInputs = List.CreateList()
memory.pastFrames = List.CreateList()
memory.pastResults = List.CreateList()
memory.stores = 0

---FUNCTIONS

function memory.Store(self, input, frameData, result)
	List.Push(self.pastInputs, input)
	List.Push(self.pastFrames, frameData)
	List.Push(self.pastResults, result)
end

function memory.CheckStore(self, func)
	if(self.pastFrames.Count == 1) then
		func(1, List.Pop(self.pastFrames))
	end
end

--++++++++++++++++++e/PUBLIC+++++++++++++++++++++++++++++++

return memory