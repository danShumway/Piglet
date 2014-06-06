--
--Copyright Daniel Shumway, 2014
--Licensed under GNU affero general public license
--http://www.gnu.org/licenses/agpl-3.0.html
--
dofile('../interfaces/List.lua')

--Load in the modules
myDecider = dofile('../deciders/current.lua')
--myObserver = dofile('observers/default.lua')
myObserver = dofile('../observers/current.lua')
myMemory = dofile('../memory/default.lua')
myRecorder = dofile('../recorders/default.lua')


keys = {}
joypad.set(1, keys)
keysAvailable = {"left", "right", "up", "down", "A", "B"}
keyDown = false
curKey = 0
curstate = 1
timer = 120;

--Some more setup
myObserver.Setup(myObserver)
myRecorder.AppendString(myRecorder, "testingSession", "memory", "{ frames=[")

function memorySave(i, data)
	myRecorder.Memory(myRecorder, data, "testingSession", "memory")
	--print("converted to JSON")
	--myRecorder.AppendString(myRecorder, "testingSession", string)
end

--Main loop.
while(true) do
	--Always call this first.
	myObserver.Observe(myObserver)
	--Store what we've got.
	myMemory.Store(myMemory, myDecider.currentKeysPressed, myObserver.currentFrame, myObserver.bytesChanged)
	myMemory.CheckStore(myMemory, memorySave)



	if (curstate == 1) then
		myObserver.removeNoise(myObserver)
		timer = timer - 1
		if(timer == 0) then
			print("Stage 1 complete: filtered out "..myObserver._removeNoise_totalChanged.."bytes.")
			curstate = curstate + 1
		end
	elseif (curstate < 4) then
		if(timer == 0) then
			--Take a snapshot.  Starting next keypress.
			myObserver.removeLoops(myObserver, 1)
			curKey = curKey + 1
			if(curKey == 7) then 
				curstate = curstate + 1
				curKey = 1
				print("finished filtering input")
			end
			print("about to test:"..keysAvailable[curKey].."\n")
			keys = {}
			timer = 121
		elseif(timer == 1) then
			keys = {}
			myObserver.removeLoops(myObserver, 3)
		elseif(timer < 60) then
			myObserver.removeLoops(myObserver, 2)
			keys = {} --Don't press anything.
		elseif(timer >= 60) then
			myObserver.removeLoops(myObserver, 2)
			keys = {}
			keys[keysAvailable[curKey]] = 1
		end
		timer = timer - 1;
	else
		keys = myDecider.ChooseInput(myDecider, myMemory.pastInputs, myMemory.pastResults, 200, 40, 40)
	end


	--Move forward as necessary.
	joypad.set(1, keys)
	vba.frameadvance()

end