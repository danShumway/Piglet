--We make a recorder object.
--This allows us to keep track of everything that the script does.
recorder = {}

--I want to be able to save to a file.
--I want the recorder to record multiple things at the same time.
--I want the recorder to be able to deal with possibly being cut off at any time.


--Some variables it will need

--An array of all of the currently open files  Files use a file object.
recorder.Files = { count = 0 }

--Sessions are the context in which you are saving and pulling data out.
--I probably want to abstract sessions out into yet another file.
recorder.session = ""


--
--Creates a session (folder) that we can use to save all of our current data
--This is done within the current session.
--
function recorder.createSession(sessionName)
	
end

function recorder.recordLine()
	
end
