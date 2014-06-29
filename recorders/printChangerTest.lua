--We make a recorder object.
--This allows us to keep track of everything that the script does.
local recorder = {}

--We assume that you're passing in a honking large array of data.
function recorder.Memory(self, memory, currentSession, fileName, values)
	--local toReturn = "["
	self.file = io.open("../memory/"..currentSession.."/"..fileName..".json", "w")
	self.file:write("var ", fileName," = {")
	for a=1, (256*16*16) do
		--toReturn = toReturn..memory[a]..","
		--if(memory[a]["key_left"] ~= nil) then
		--	if(memory[a]["key_left"] >= -300) then
				self.file:write('"',a,'": { ')
				for k, v in pairs(values) do
					self.file:write('"', v.string,'":', Value(memory[a][v.string]), ', ')
				end
				-- self.file:write('default":',Value(memory[a]["default"])
				-- 	,', "left": ', Value(memory[a]["key_left"])
				--  	, ',"right": '
				--  	, Value(memory[a]["key_right"]),', "A": ', Value(memory[a]["key_A"]))
				 self.file:write(" },\n")
		--	end
		--end
	end
	self.file:write("};")
	self.file:close()
	print("saved")
end

function Value(value)
	if(value ~= nil) then return value end
	return 0
end


--
--Creates a session (folder) that we can use to save all of our current data
--This is done within the current session.
--




return recorder