local observer = {}

function observer.observe()

	--Grab what keys are being pressed.
	Piglet.Memory.Instant.currentKeys = Piglet.Hardware.Hand.getKeys()
	--Grab the eye data and set it.
	Piglet.Memory.Instant.lastFrame = Piglet.Memory.Instant.currentFrame
	Piglet.Memory.Instant.currentFrame = Piglet.Hardware.Eye.getFrame()

	--Count what frame we're on/how many frames have elapsed during this current session.
	if(Piglet.Memory.Instant.frameNumber == nil ) then 
		Piglet.Memory.Instant.frameNumber = 1
	else
		Piglet.Memory.Instant.frameNumber = Piglet.Memory.Instant.frameNumber + 1
	end

	--Move back changes.
	Piglet.Memory.Instant.lastChanges = Piglet.Memory.Instant.currentChanges
	Piglet.Memory.Instant.currentChanges = {}



	--If we were scanning the entire rom.
	--for a=1, 256*16*16 do
	--However, only 4000 to 7FFF actually holds game variables.  I think.
	--If I'm right, we go from an N loop of 65536 to an N loop of 16383
	areasOfInterest = {
		{65408, 65422}, --FF80-end
		{65280, 65408}, --FF00-FF80-IO
		{40960, 49152} --A000-C000-System RAM
	}

	areasOfInterest = {
		{0, 65536}
	}

	function loop(first, last)
		for a=first, last do
			if(Piglet.Memory.Instant.lastFrame[a] ~= Piglet.Memory.Instant.currentFrame[a]) then
				--Record changes that are relevant.
				Piglet.Memory.Instant.currentChanges[a] = Piglet.Memory.Instant.currentFrame[a] --- Piglet.Memory.Instant.lastFrame[a]
			else
				--Set as nil.  This will make other loops more efficient if we use for... in.
				Piglet.Memory.Instant.currentChanges[a] = nil
			end
		end
	end

	for k, v in pairs(areasOfInterest) do
		loop(v[1], v[2])
	end
end




return observer