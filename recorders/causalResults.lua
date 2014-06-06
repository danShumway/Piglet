--We make a recorder object.
--This allows us to keep track of everything that the script does.
local recorder = {}

--We assume that you're passing in a honking large array of data.
function recorder.Memory(self, memory, currentSession, fileName)
	--local toReturn = "["
	self.file = io.open("../memory/"..currentSession.."/"..fileName..".json", "w")
	self.file:write("var ", fileName," = {")
	for a=1, (256*16*16) do
		--toReturn = toReturn..memory[a]..","
		if(memory[a] > 4) then
			self.file:write('"',a,'":',memory[a], ",")
		end
	end
	self.file:write("};")
	self.file:close()
	print("saved")
end


--
--Creates a session (folder) that we can use to save all of our current data
--This is done within the current session.
--




return recorder