--
--Copyright Daniel Shumway, 2014
--Licensed under GNU affero general public license
--http://www.gnu.org/licenses/agpl-3.0.html
--

--make our decider object
decider = {}

--++++++++++++++++++++PUBLIC+++++++++++++++++++++++++++++++

---VARIABLES
decider.Memory = false;
decider.Experimenting = false; --Are we trying something new or utilizing the past?

---FUNCTIONS

--decides what input to press for the current frame.
function decider.ChooseInput(self)

	--If you have any RAM to work with.
	if(self.Memory ~= false) then
		--Are we trying something new?
		if(self.Experimenting == false) then
			local start = self.Memory.PastInputs.firstIndex; --Needs some fleshing out.
			--TODO: Finish this.  And the rest of the method.
		end
	end
end

--This isn't exactly modular, but I want a method so that I can basically check to see what info I have.
--Not being used at the moment, so it will be hard to see the use until I start expanding things later.
function decider.GiveInfo(self, memory)

end

--++++++++++++++++++++e/PUBLIC+++++++++++++++++++++++++++++