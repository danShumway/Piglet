--
--Copyright Daniel Shumway, 2014
--Licensed under GNU affero general public license
--http://www.gnu.org/licenses/agpl-3.0.html
--

dofile('interfaces/List.lua')

--Load in the modules
myDecider = dofile('deciders/default.lua')
myObserver = dofile('observers/default.lua')
myMemory = dofile('memory/default.lua')


keys = {}
joypad.set(1, keys)
while(true) do

	myObserver.Observe(myObserver)
	myMemory.Store(myMemory, myDecider.currentKeysPressed, myObserver.currentFrame, myObserver.bytesChanged)
	keys = myDecider.ChooseInput(myDecider, myMemory.pastInputs, myMemory.pastResults, 200, 40, 220)
	print(keys)
	joypad.set(1, keys)
	vba.frameadvance()

end