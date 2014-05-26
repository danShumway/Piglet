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
--Requires a list of past inputs (using the List class), and some other stuff probably.
function decider.ChooseInput(self, pastInputs)

	--If I'm in the middle of trying something.
	if(self.framesToTry > 0) then return {} end

	--If you have any information to work with
	if(pastInputs ~= nil and pastInputs.Count ~= 0) then
		--Are we trying something new?
		if(self.Experimenting == false) then
			local start = pastInputs.FirstIndex; --Needs some fleshing out.
			--TODO: Finish this.  And the rest of the method.
			return {}
		end
	end

	return {} --How did you get here?
end


--++++++++++++++++++++e/PUBLIC+++++++++++++++++++++++++++++


return decider --Return the object so that index can actually use it.