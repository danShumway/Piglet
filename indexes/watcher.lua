--
--Copyright Daniel Shumway, 2014
--Licensed under GNU affero general public license
--http://www.gnu.org/licenses/agpl-3.0.html
--

--
-- Watcher isn't designed to press buttons or play games.
-- The idea is that is watches you play and tries to learn by cycling through inputs.
-- The more it watches you play, the better mental map it should get of the game.
--

dofile('../interfaces/List.lua')

--Load in the modules
myObserver = dofile('../observers/watcher.lua')
myRecorder = dofile('../recorders/causalResults.lua')
saved = false


keys = {}

-- --Some more setup
-- myObserver.Setup(myObserver)
-- myRecorder.AppendString(myRecorder, "testingSession", "memory", "{ frames=[")

-- function memorySave(i, data)
-- 	myRecorder.Memory(myRecorder, data, "testingSession", "memory")
-- 	--print("converted to JSON")
-- 	--myRecorder.AppendString(myRecorder, "testingSession", string)
-- end

--Main loop.

myObserver.Setup(myObserver)
while(true) do

	myObserver.Observe(myObserver)
	vba.message(memory.readbyte(43254))
	if(input.get().shift == true) then
		--memory.writebyte(41473, 80)
		--memory.writebyte(65409, 16)
		--vba.message(memory.readbyte(65409).." - "..memory.readbyte(65410))
		--vba.message(memory.readbyte(65070))

		myObserver.Conclude(myObserver)
		--myRecorder.Memory(myRecorder, myObserver.finalConclude, "testingSession", "rightHeldDown")
		saved = true
	else
		saved = false
	end
	vba.frameadvance()
end