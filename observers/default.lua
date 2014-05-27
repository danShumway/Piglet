--
--Copyright Daniel Shumway, 2014
--Licensed under GNU affero general public license
--http://www.gnu.org/licenses/agpl-3.0.html
--

--Make our observer object.
local observer = {}

--++++++++++++++++++++PUBLIC+++++++++++++++++++++++++++++++

---VARIABLES

--Number of bytes changed since the last frame.
observer.bytesChanged = 0;
--Observed content from the previous frame.
observer.previousFrame = false; --Default to false, will become an array soon.
--Observed content from the current frame.
observer.currentFrame = false; --Default to false, will become an array soon.

----FUNCTIONS

--Checks for changes and updates all the current variables.
function observer.Observe(self)	

	self.previousFrame = self.currentFrame --Switch back to make room for currentFrame's new data.
	self.bytesChanged = 0 --reset bytesChanged.
	--Hard coded for the visual boy advance.  Future modules might (should) be different.
	self.currentFrame = memory.readbyterange(0, 256*16*16) --size of the gameboy color memory.


	--Loop through previous frame and count differences, if you can.
	if(self.previousFrame ~= false) then
		for a=0, 256*16*16 do
			--If you have data that's different.
			if(self.previousFrame[a] ~= self.currentFrame[a]) then
				self.bytesChanged = self.bytesChanged + 1
			end
		end
	end
end

--TODO: Start doing data culling in here (only watch certain parts of memory).

--++++++++++++++++++++e/PUBLIC+++++++++++++++++++++++++++++



--+++++++++++++++++++PRIVATE++++++++++++++++++++++++++++++++
--By name only.

--+++++++++++++++++++e/PRIVATE++++++++++++++++++++++++++++++


--End of the file.
return observer
