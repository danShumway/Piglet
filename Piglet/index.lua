print("Hai, I'm Piglet")


--[[
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
              PIGLET
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

Copyright Daniel Shumway, 2014

--
--Licensed under GNU affero general public license
--http://www.gnu.org/licenses/agpl-3.0.html
--

-----------------------------------------------------------------------------------
--]]

Piglet = {} --Hai, I'm Piglet!


--[[
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
              STORAGE AND APPENDEGES
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Piglet has specific locations to store memory in.

Instant memory serves as a holding tank for what is actually happening at the moment.
Think of it as her perception of the world around her.
Short term memory is the stuff that Piglet is actively remembering and thinking about.
Long term memory is an external database that is only loaded into short term memory.

Piglet also has virtual 'appendeges' that serve as her link to the VBA emulator.
An 'eye' allows her to read in byte data from memory, and 'hand' allows her to send
keypresses to the emulator.  Piglet observes what these appendeges are doing/sending
and stores that in instant memory as well.
-----------------------------------------------------------------------------------
--]]

--ToDo: replace these with classes that wrap around the data structures.
Piglet.Memory = {}
Piglet.Memory.Instant = dofile('memory/Instant/instant.lua')
Piglet.Memory.Short = dofile('memory/Short/short.lua')
--We don't have an accessible long.  What long should be is a class that pulls data and puts it into short.
Piglet.Memory.Long = dofile('memory/Long/long.lua')

Piglet.Hardware = {}
Piglet.Hardware.Eye = dofile('Hardware/eye.lua')
Piglet.Hardware.Hand = dofile('Hardware/hand.lua')


--[[
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
              MENTAL PROCESSES
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

Piglet's brain is divided into three separate parts that work together.

An Observer looks at the world and gathers information - it's designed to replicate the part 
of your brain that would work in conjunction with an eye, filling in gaps where it needs to, logging
changes that it sees in the world, etc...

The processor, suitably enough, processes information that is passed in from the observer and forms conclusions
about the world.

The decider, using infomration that is stored in short term memory passes inputs to hardware like the hand about
what should be done in the future.  So the decider would look at instant/short memory and make a decision:
"I should press left", then it will pass 'left' to the hand, which will in the next frame, hold down left.
It works kind of a nervous system.
-----------------------------------------------------------------------------------
--]]

--ToDo: Should probably be a brain ({}) object here.  Maybe add one in the future?
Piglet.Observer = dofile('Observers/observer.lua')
Piglet.Processor = dofile('Processors/processor.lua')
Piglet.Decider = dofile('Deciders/decider.lua')


--[[
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
              MAIN LOOP
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

-----------------------------------------------------------------------------------
--]]

--Piglet has a mental tick
function Piglet.tick()
	--Observe Information
	Piglet.Observer.observe()
	--Process Relevant Information
		Piglet.Processor.process()
	--Decide Input
	Piglet.Decider.pickKeys()
end


--Draw any messages required to the screen.  
--Do memory display or whatever the heck you want here as well.
--Note that this is not attached to Piglet.  Piglet is not actively drawing to the screen.
--We are, after pulling information from piglet.
function draw()

	local toPrint = ' '
	local keys = joypad.get(1)
	for key, value in pairs(keys) do
		if(value == true) then
			toPrint = toPrint..key..' '
		end
	end
	vba.message(toPrint)
end


--main
--Remember some stuff.  Legacy code from when Piglet was storing and remembering stuff.
--Piglet.Memory.Short.rememberCauses(Piglet.Memory.Long.load("Mario_6Golden_Coins", "test_01"))

Piglet.Memory.Short.strategies.init(8, 6) --When piglet boots up, we start up her memory.  In the future, we would have some type of recall function
--That would be tied into long in the future.

Piglet.Memory.Short.recordInitialState() --Check out what's going on in the game.

--And here we go.
while(true) do
	--Piglet sees.
	--Eye

	Piglet.tick(dx); --Call the main loop, passing in the elapsed time since the last frame.
	draw(dx); --Draw anything required to the screen.

	vba.frameadvance() --Advance the emulator one frame.
end