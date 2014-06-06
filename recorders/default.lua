--We make a recorder object.
--This allows us to keep track of everything that the script does.
local recorder = {}

--I want to be able to save to a file.
--I want the recorder to record multiple things at the same time.
--I want the recorder to be able to deal with possibly being cut off at any time.


--Some variables it will need

--An array of all of the currently open files  Files use a file object.
recorder.Files = { count = 0 }

--Sessions are the context in which you are saving and pulling data out.
--I probably want to abstract sessions out into yet another file.
recorder.session = ""


--Appends a string passed in to a directory and file.
function recorder.AppendString(self, currentSession, fileName, string)
	self.file = io.open("../memory/"..currentSession.."/"..fileName..".json", "a")
	io.output(self.file)
	io.write(string)
	--io.close()
end


--Recursively builds a json object out of a block of data, and returns it as a string.
function recorder.ToJSON(self, data, json)

	if(type(data) ~= "table") then
		return data
	else
		local toReturn = "{"
		for k, v in pairs(data) do
			toReturn = toReturn.."\""..k.."\":"..self.ToJSON(self, v, json)..","
		end
		json = json..toReturn.."}"
		return json
	end
end

--We assume that you're passing in a honking large array of data.
function recorder.Memory(self, memory, currentSession, fileName)
	--local toReturn = "["
	self.file = io.open("../memory/"..currentSession.."/"..fileName..".json", "a")
	io.write("[")
	for a=1, (256*16*16)-1 do
		--toReturn = toReturn..memory[a]..","
		io.write(memory[a], ",")
	end
	--toReturn = toReturn..memory[256*16*16].."]"
	io.write("], ")
	--io.close()
	return toReturn;
end


--
--Creates a session (folder) that we can use to save all of our current data
--This is done within the current session.
--




return recorder