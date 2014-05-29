--
--Copyright Daniel Shumway, 2014
--Licensed under GNU affero general public license
--http://www.gnu.org/licenses/agpl-3.0.html
--

dofile('interfaces/List.lua')

--Load in the modules
myDecider = dofile('deciders/default.lua')
--myObserver = dofile('observers/default.lua')
myObserver = dofile('observers/current.lua')
myMemory = dofile('memory/default.lua')


keys = {}
joypad.set(1, keys)
states = {"experiment","normal"}

--Some more setup
myObserver.Setup(myObserver)
--Main loop.
while(true) do

	--Always call this first.
	myObserver.Observe(myObserver)
	--Store what we've got.
	myMemory.Store(myMemory, myDecider.currentKeysPressed, myObserver.currentFrame, myObserver.bytesChanged)
	
	--decide what keys to press.  With the new method, we'll start to pass in a step as well.
	keys = myDecider.ChooseInput(myDecider, myMemory.pastInputs, myMemory.pastResults, 200, 40, 220)


	--Move forward as necessary.
	joypad.set(1, keys)
	vba.frameadvance()

end