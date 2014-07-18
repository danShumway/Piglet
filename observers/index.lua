dofile('..interfaces/List.lua')
local hrt=require "..interfaces/HiResTimer"

--Load in any necessary modules.
observer = dofile('undefined')
recorder = dofile('undefined')
decider = dofile('undefined')



--Structure
--Have a main tick loop.

--dx(time since last frame.)
function tick(dx)


end


--dx(time since last frame)
--Draw any messages required to the screen.  
--Do memory display or whatever the heck you want here as well.
function draw(dx)


end


--main
dx = 0;
while(true) do
	t0 = hrt.clock();
	tick(dx); --Call the main loop, passing in the elapsed time since the last frame.
	draw(dx); --Draw anything required to the screen.
	dx = hrt.clock() - t0
	vba.frameadvance()
end