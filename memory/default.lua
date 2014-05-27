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

---FUNCTIONS

function memory.Store(self, input, frameData, result)
	List.Push(self.pastInputs, input)
	--List.Push(self.pastFrames, frameData)
	List.Push(self.pastResults, result)
end


--++++++++++++++++++e/PUBLIC+++++++++++++++++++++++++++++++

return memory