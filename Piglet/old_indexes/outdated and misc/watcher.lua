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
myObserver = dofile('../observers/current.lua')
myRecorder = dofile('../recorders/printChangerTest.lua')
myDecider = dofile('../deciders/changerTest.lua')
saved = false


keys = {}
selfInput = false

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

	if(input.get().control == true) then
		--memory.writebyte(44849, 10)
	end


	--vba.message(myObserver.GetByte(65475).." "..myObserver.GetByte(44849).." "..myObserver.GetByte(65466))

	--Save what you currently have.
	if(input.get().shift == true and saved == false) then
		--myObserver.Conclude(myObserver)
		myRecorder.Memory(myRecorder, myObserver.watcherObj.effects, "testingSession", "total", myObserver.watcherObj.inactiveChecks)
		saved = true
	end
	if(input.get().shift ~= true) then
		saved = false
	end

	if(input.get().tab == true) then
		print("switching to self input")
		selfInput = true
		myDecider.effects = myObserver.watcherObj.effects
		----myObserver.watcherObj.currentlyWatching = "key_left"
	end

	if(selfInput) then
		--This will get updated over time.
		myDecider.goal = myObserver.watcherObj.mostRecentAddedValue
		myDecider.decide(myDecider)
	end

	--Advance frame.
	vba.frameadvance()

end