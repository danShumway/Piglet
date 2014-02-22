
--Declerations here.
toDisplay = "WideEyes"

--What does a frame look like?
--We store both past inputs (what keys were pressed &&
significantFrames = {} --Will be used in the future (what states should we remember and possibly avoid?)
significantFrames.firstIndex = 1
significantFrames.count = 0
saveStates = {} --We can jump back a number of frames to prevent us from getting too stuck.
framesPerSaveState = 100 --How often do we save the state?
saveStates.firstIndex = 1
saveStates.count = 0
pastInputs = {}
pastInputs.firstIndex = 1
pastInputs.count = 0
differencesToTrack = {}
differencesToTrack.count = 0
--What does a frame look like and how do we make one?
function addInput(justPressed, currentNovelty)
	local index = table.getn(pastInputs) + 1
	pastInputs[index] = justPressed
	pastInputs[index].novely = currentNovelty
end
--Saving the past so we can go back to it when necessary.
function makeSaveState()
	local num = table.getn(saveStates) + 1
	if(vba.framecount() % framesPerSaveState == 0) then
		saveStates[num] = savestate.create()
		--And save.
		savestate.save(saveStates[num])
	end
end
--And adding a way to go back to that past.
function loadSaveState()
	local num = table.getn(saveStates)
	savestate.load(saveStates[num - 1])
	saveStates[num] = nil
	saveStates[num - 1] = nil
	local num2 = table.getn(pastInputs)
	for i=num2 - framesPerSaveState, num2 do
		pastInputs[i] = nil
	end
end


--memoryCheck
currentFrame = false
previousFrame = false
shortTermMemory = 200
--
prevKeys = false
currentKeys = false

differenceCheck = 0
highestDifference = 1
currentExcitement = 0
totalExcitement = .5 --Influenced by the newer novelty system, this tells it when it needs to get really creative.

--Anticipation (get it to try things for longer than one frame)
frameTry = 2
currentTry = {} --What input are you trying right now?
reflectionCount = 30 --How often do you check if you're feeling bored.


--Baselines for tolerance and bias - what does he find boring?
tolerance = 45
timeBored = 0 --A sense of self awareness?  Is something significant enough to check for?
baseActivity = 0 --What normally goes on in the world?


--Puts the message on the screen.
function interface()
	vba.message(toDisplay)
end
--Register the functions
gui.register(interface)


--Open a file, if you need one.
function fileWrite()
	file = io.open("result", "a")
	io.output(file)
	io.write("hello", 42, "hello")
	io.close()
end


--[[
Checks the amount of difference between two passed in states.
Also updates memory.readbyterange.
]]
function comparative(check1, check2)

	local differences = 0
	local existingElements = differencesToTrack.count
	for k, v in pairs(differencesToTrack) do

		if(check1[k] ~= check2[k]) then
			differences = differences + 1
		end

		--If it's been 500 frames since you last saw any change there,
		--then for heaven's sake stop tracking
		if(v > 500 and k ~= "count") then
			differencesToTrack[k] = nil
			differencesToTrack.count = differencesToTrack.count - 1
		end
	end

	--Return the number of differences from the previous file, number of elements removed.
	return differences, existingElements - differencesToTrack.count
end


--[[
Checks the differences between this and the previous
frame.  Returns the number of bytes that are different.
]]
function memoryCheck()

	--Read in data (array of characters).
	currentFrame = memory.readbyterange(0, 256*16*16)


	--Loop through all of your memories and see how different the current situation is.
	--If you have data to compare.
	if(previousFrame ~= false) then

		--Reset previous data
		differenceCheck = 0

		--Run a comparison
		for a=0, 256*16*16 do
			--If you have data that's different.
			if(previousFrame[a] ~= currentFrame[a]) then
				differenceCheck = differenceCheck + 1

				--Also, I want you to log that this is data that can change and is worth monitoring.
				if(differencesToTrack[a] == nil) then
					differencesToTrack.count = differencesToTrack.count + 1
				end
				differencesToTrack[a] = vba.framecount()
			end

		end

	end

	--pop onto memory.

	previousFrame = currentFrame

	--Every once and a while, we take a snapshot of a previous place.
	--If we end up back at this place, we can be bored again.
	if vba.framecount()%60 == 0 then --fix this line.
		local memory = significantFrames.count
		significantFrames[memory + significantFrames.firstIndex] = currentFrame
		significantFrames.count = significantFrames.count + 1
		--The cheap way to keep our data consumption under control.
		if(memory > 5) then
			significantFrames[significantFrames.firstIndex] = nil
			significantFrames.firstIndex = significantFrames.firstIndex + 1
			significantFrames.count = significantFrames.count - 1
		end
	end

	return differenceCheck

end

function getFrustrated()
	if(totalExcitement < .4) then
		frameTry = frameTry + 1
	else
		frameTry = math.max(frameTry - 1, 1)
	end
end


function chooseInput()
	--Try and loop through the previous inputs you've tried.
	--Which keys yielded the best results?

	--Before you do anything else, check to see if you need a savestate.  If you do, wait.
	if table.getn(saveStates) <= 1 then
		--setTolerance()
		return {}
	end

	bestFrame = {0}
	bestInput = {0}

	--Are you in the middle of trying something?
	if(vba.framecount() % frameTry == 0) then
	--Otherwise it's time to pick some new input.
		for i=table.getn(pastInputs), table.getn(pastInputs) - shortTermMemory, -1 do
			if(pastInputs[i] ~= nil) then

				--Loop through and see if you need to be added to the list of good inputs.
				local added=false
				for j=1, table.getn(bestInput) do
					if(pastInputs[i].novely > bestInput[j] and added == false) then
						bestInput[j] = pastInputs[i].novely
						bestFrame[j] = pastInputs[i]
						added = true
					end
				end

			end
		end


		local aCount, bCount, upCount, downCount, leftCount, rightCount, averageNovelty = 0, 0, 0, 0, 0, 0, 0
		local keys = {}
		local length = table.getn(bestInput)
		for j=1, length do
			--Average them together and get the most pressed keys.
			if(bestFrame[j].A == 1) then aCount = aCount + 1 end
			if(bestFrame[j].B == 1) then bCount = bCount + 1 end
			if(bestFrame[j].left == 1) then leftCount = leftCount + 1 end
			if(bestFrame[j].right == 1) then rightCount = rightCount + 1 end
			if(bestFrame[j].up == 1) then upCount = upCount + 1 end
			if(bestFrame[j].down == 1) then downCount = downCount + 1 end

			averageNovelty = averageNovelty + bestFrame[j].novely
		end
		--Build based on the input.  You need a 2/3 vote to get into the repeat.
		--[[if(aCount >= 1) then keys.A = 1 end
		if(bCount >= 1) then keys.B = 1 end
		if(leftCount >= 1) then keys.left = 1 end
		if(rightCount >= 1) then keys.right = 1 end
		if(upCount >= 1) then keys.up = 1 end
		if(downCount >= 1) then keys.down = 1 end]]
		averageNovelty = averageNovelty/table.getn(bestInput)
		keys = bestFrame[1]


		--If the best frame was interesting enough, repeat that action.
		if(averageNovelty > tolerance) then
			--Oh, we found something interesting.
			timeBored = 0
			joypad.set(1, keys)
			vba.print("using memory")
			currentTry = keys --Set what you're currently doing.
			return keys
		--Otherwise, mess around with random input.  This could be done better.
		else
			keys = {}

			timeBored = timeBored + 1 --Also, I'm bored.
			local rand = 0

			rand = math.random()
			if (rand < .45) then
				keys.A = 1
			end

			rand = math.random()
			if (rand < .45) then
				keys.B = 1
			end

			rand = math.random()
			if (rand < .333) then
				keys.left = 1
			elseif(rand < .666) then
				keys.right = 1
			end --or press neither

			rand = math.random()
			if (rand< .333) then
				keys.up = 1
			elseif(rand < .666) then
				keys.down = 1
			end

			--Line that up with what the user is holding.  If the user is holding a key, it can't be pressed.
			userKeys = input.get()
			if(userKeys.Z == true) then
				keys.A = nil
				vba.print("suppressing A")
			end
			if(userKeys.X == true) then keys.B = nil end
			if(userKeys.left == true) then
				keys.left = nil
			end
			if(userKeys.right == true) then keys.right = nil end
			if(userKeys.up == true) then keys.up = nil end
			if(userKeys.down == true) then keys.down = nil end

			joypad.set(1, keys)
			vba.print("trying something brand new!")
			currentTry = keys
			return keys

		end

	else
		joypad.set(1, currentTry)
		return currentTry
	end


end

function setTolerance()
	--Don't press anything.
	--Get the highest change during that time.
	if(currentExcitement > baseActivity) then
		baseActivity = currentExcitement
	end

	tolerance = baseActivity + 4

end




--Main loop
while (true) do

	currentExcitement = memoryCheck()
	--Before you do anything else, lets get a reflection on our current situation.
	if(vba.framecount() % reflectionCount == 0) then
		getFrustrated()
	end


	--Something something something
	--Check previous states.
	if(significantFrames.count > 1) then
		local checkPrevious = math.random(significantFrames.firstIndex, significantFrames.firstIndex + significantFrames.count - 1)
		local result = comparative(currentFrame, significantFrames[significantFrames.firstIndex])
		if(result < tolerance) then
			toDisplay = result
			currentExcitement = result
			--totalExcitement = math.max(totalExcitement - .001, 0)
		else
			toDisplay = "NOVELTY"
			--totalExcitement = math.min(totalExcitement + .0011, 1)
		end

	end
	--Stuff
	currentKeys = chooseInput()

	if(prevKeys) then
		addInput(prevKeys, currentExcitement)
	end

	--If you've been bored for a while, jump back to a previous state and do some other stuff.
	if(timeBored > framesPerSaveState*1/2 - 5) then
		loadSaveState()
		timeBored = 0
	end

	prevKeys = currentKeys

	--fileWrite()
	makeSaveState()


	vba.frameadvance()

end
