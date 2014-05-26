--
--Copyright Daniel Shumway, 2014
--Licensed under GNU affero general public license
--http://www.gnu.org/licenses/agpl-3.0.html
--

--make our decider object
local decider = {}

--++++++++++++++++++++PUBLIC+++++++++++++++++++++++++++++++

---VARIABLES
decider.Experimenting = false; --Are we trying something new or utilizing the past?
decider.framesToTry = 0;


---FUNCTIONS

--decides what input to press for the current frame, and returns it as an object.
--Requires:
--a list of past inputs (using the List class), 
--a list of past results (ints of how bytes were different in that frame), 
--how long to remember back when choosing moves
--hom many frames to average when choosing future inputs.
function decider.ChooseInput(self, pastInputs, pastResults, memoryLength, framesToAverage)

	--If I'm in the middle of trying something.
	if(self.framesToTry > 0) then return {} end

	--If you have any information to work with
	if(pastInputs ~= nil and pastInputs.Count ~= 0) then
		--Are we trying something new?
		if(self.Experimenting == false) then

			--A sorted list of what frames had the best inputs in the past.
			local bestFrame = List.CreateList()
			local bestInput = List.CreateList()

			--We loop through our past inputs based on how many we're allowed to remember
			--Then we sort them into an ordered list of which ones had the best results.
				--(see bestFrame and bestInput above).
			--After we're done, we'll use those lists to choose our future input.
			for i=pastResults.LastIndex, pastResults.LastIndex - memoryLength, -1 do
				if(pastResults[i] ~= nil) then --if there's anything to remember or iterate on.
					--loop through the list and see if it can be added.
					for j=bestFrame.FirstIndex, bestFrame.FirstIndex + framesToAverage - 1 do
						--If the list isn't full and you're at the end, just add it.
						if(bestFrame[j] == nil) then 
							List.Push(bestFrame, {frame=i, novelty=pastResults[i]}) 
							break
						end
						--Otherwise, check to see if it should be added.
						if(pastResults[i] > bestFrame[j].novelty) then
							List.Insert(bestFrame, j, {frame=i, novelty=pastResults[i]})
							if(bestFrame.Count > framesToAverage) then
								List.Pop(bestFrame)
							end
							break
						end
					end --/for
				end
			end --/for
			vba.print(bestFrame)
		end
	end

	return {} --How did you get here?
end


--++++++++++++++++++++e/PUBLIC+++++++++++++++++++++++++++++


return decider --Return the object so that index can actually use it.