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
observer.bytesChanged = 0
--Observed content from the previous frame.
observer.previousFrame = false --Default to false, will become an array soon.
--Observed content from the current frame.
observer.currentFrame = false --Default to false, will become an array soon.


----DATA CULLING
observer.bytesToCheck = {} --We don't use a list for this because our list stinks at doing removal.
observer.bytesToTrack = {} --The goal with this is to have a list of bytes that we pay more attention to.
observer.changing = {} --What bytes have changed recently, and by how much?
observer.snapshots = List.CreateList(); --A list of snapshots of memory.  Unused at the moment.


----FUNCTIONS

function observer.Setup(self)
	for a=0, 256*16*16 do
		--Bytes to check starts out with a value greater than 0, meaning, how much trust we're putting in it.
		--If it drops to 0, it changes to nil, meaning we're no longer watching it.
		self.bytesToCheck[a] = 100
	end
end

--Checks for changes and updates all the current variables.
--Always call this first.
function observer.Observe(self)	

	self.changing = {}
	self.previousFrame = self.currentFrame --Switch back to make room for currentFrame's new data.
	self.bytesChanged = 0 --reset bytesChanged.
	--Hard coded for the visual boy advance.  Future modules might (should) be different.
	self.currentFrame = memory.readbyterange(0, 256*16*16) --size of the gameboy color memory.


	--Loop through previous frame and count differences, if you can.
	if(self.previousFrame ~= false) then
		for k, v in pairs(self.bytesToCheck) do
			--If you have data that's different.
			if(self.previousFrame[k] ~= self.currentFrame[k]) then
				self.bytesChanged = self.bytesChanged + 1
				self.changing[k] = true;
			end
		end
	end

	vba.message(self.bytesChanged)
end

--Basically, cull is looking for different types of information
--That it can exclude from bytesToCheck.  This reduces processor time,
--but more importantly, it keeps us from fixating on senseless noise.

--remove loops is called before, during, and after a single keypress.
--It checks to see if reactions to a keypress are irrelevant and stops tracking them if they are.
observer._removeLoops_changing = {}
observer._removeLoops_snapshot = {}
function observer.removeLoops(self, stage)
	if(stage == 1) then --Before keypress.
		--Take a snapshot.
		self._removeLoops_snapshot = memory.readbyterange(0, 256*16*16)

	elseif(stage == 2) then --During keypress.
		--Record data that's changing.  Add it to the list of all data that's changing.
		for k, v in pairs(self.changing) do
			self._removeLoops_changing[k] = true
		end
	elseif(stage == 3) then -- After keypress.
		--Compare to the snapshot and address.
		local countThing, countThing2 = 0, 0
		for k, v in pairs(self._removeLoops_changing) do
			if(self._removeLoops_snapshot[k] == self.currentFrame[k]) then--If it changed, and then just changed back.
				--Don't track it.
				if(self.bytesToCheck[k] ~= nil) then countThing = countThing + 1 end
				self.bytesToCheck[k] = nil
			else
				if(self.bytesToTrack[k] == nil) then 
					countThing2 = countThing2 + 1 
					self.bytesToTrack[k] = 0
				end
				self.bytesToTrack[k] = self.bytesToTrack[k] + 1
			end
		end
		vba.print("Ignoring "..countThing.." bytes.  Watching "..countThing2.." bytes.")

	end
end


observer._removeNoise_totalChanged = 0
function observer.removeNoise(self)
	--Reaaal simple.
	--Hey, what's changing?
	--I mean, I'm not pressing any buttons right now.
	--So, it can't be that important.
	--Ignore it.
	for k, v in pairs(self.changing) do
		if(self.bytesToCheck[k] ~= nil) then 
			self._removeNoise_totalChanged = self._removeNoise_totalChanged + 1 
		end
		self.bytesToTrack[k] = nil
	end
end

--++++++++++++++++++++e/PUBLIC+++++++++++++++++++++++++++++



--+++++++++++++++++++PRIVATE++++++++++++++++++++++++++++++++
--By name only.

--+++++++++++++++++++e/PRIVATE++++++++++++++++++++++++++++++


--End of the file.
return observer
