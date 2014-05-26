
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

--We also have a small amount of state management (are we experimenting or not?)
experimenting = false --are we experimenting?
experimenting_count = 0 -- how long have we been experimenting?
experimenting_reset = 20 -- how many inputs do we take when we experiment?

--What does a frame look like and how do we make one?
function addInput(justPressed, currentNovelty)
	local index = pastInputs.firstIndex + pastInputs.count --table.getn(pastInputs) + 1
	pastInputs[index] = justPressed
	pastInputs[index].novely = currentNovelty
	pastInputs.count = pastInputs.count + 1

	--And get rid of the old inputs.
	if(pastInputs.count > 1000) then

		pastInputs[pastInputs.firstIndex] = nil
		pastInputs.firstIndex = pastInputs.firstIndex + 1
		pastInputs.count = pastInputs.count - 1
	end


end
--Saving the past so we can go back to it when necessary.
function makeSaveState()
	local num = saveStates.count + saveStates.firstIndex
	if(vba.framecount() % framesPerSaveState == 0) then
		--Add the savestate.
		saveStates[num] = savestate.create()
		saveStates.count = saveStates.count + 1
		--And save.
		savestate.save(saveStates[num])

		--Also, remove old savestates if necessary.
		if(saveStates.count > 25) then
			saveStates[saveStates.firstIndex] = nil
			saveStates.firstIndex = saveStates.firstIndex + 1
			saveStates.count = saveStates.count - 1
		end
	end
end
--And adding a way to go back to that past.
function loadSaveState()
	local num = table.getn(saveStates)
	savestate.load(saveStates[num - 1])
	--Jump back two savestates, I guess.
	saveStates[num] = nil
	saveStates[num - 1] = nil
	saveStates.count = saveStates.count - 2

	local num2 = pastInputs.count + pastInputs.firstIndex
	for i=num2 - framesPerSaveState, num2 do
		pastInputs[i] = nil
		pastInputs.count = pastInputs.count - 1
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
frameTry = 3
currentTry = {} --What input are you trying right now?
reflectionCount = 30 --How often do you check if you're feeling bored.


--Baselines for tolerance and bias - what does he find boring?
tolerance = 40
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

	bestFrame = {0, 0, 0, 0, 0, 0, 0, 0}
	bestInput = {0, 0, 0, 0, 0, 0, 0, 0}

	--Are you in the middle of trying something?
	if(vba.framecount() % frameTry == 0) then



	--Otherwise it's time to pick some new input.

	--First off, are we trying something new or are we learning from the old?
		if(experimenting == false) then
			local start = pastInputs.firstIndex
			local endIndex = pastInputs.count + pastInputs.firstIndex
			for i=endIndex, endIndex - shortTermMemory, -1 do
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
				if(bestFrame[j].A == 1 and bestFrame[j].novely > tolerance) then aCount = aCount + 1 end
				if(bestFrame[j].B == 1 and bestFrame[j].novely > tolerance) then bCount = bCount + 1 end
				if(bestFrame[j].left == 1 and bestFrame[j].novely > tolerance) then leftCount = leftCount + 1 end
				if(bestFrame[j].right == 1 and bestFrame[j].novely > tolerance) then rightCount = rightCount + 1 end
				if(bestFrame[j].up == 1 and bestFrame[j].novely > tolerance) then upCount = upCount + 1 end
				if(bestFrame[j].down == 1 and bestFrame[j].novely > tolerance) then downCount = downCount + 1 end

				if(bestFrame[j].novely > averageNovelty) then
					averageNovelty = bestFrame[j].novely
					--averageNovelty = averageNovelty + (bestFrame[j].novely/length)
					vba.print(averageNovelty)
				end
			end



			--Build based on the input.
			keys = bestFrame[1] -- Allows keys to compete with each other.
			--if(aCount >= 1) then keys.A = 1 end
			--if(bCount >= 1) then keys.B = 1 end
			if(leftCount > rightCount) then
				keys.left = 1
				keys.right = nil
			elseif(leftCount < rightCount) then
				keys.right = 1
				keys.left = nil
			else
				keys.right = nil
				keys.left = nil
			end
			if(upCount > downCount) then
				keys.up = 1
				keys.down = nil
			elseif (upCount < downCount) then
				keys.down = 1
				keys.up = nil
			else
				keys.down = nil
				keys.up = nil
			end
			--averageNovelty = averageNovelty/table.getn(bestInput)


			--If the best frame was interesting enough, repeat that action.
			if(averageNovelty > tolerance) then
				--Oh, we found something interesting.
				timeBored = 0
				joypad.set(1, keys)
				--vba.print("using memory")
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
				if (rand < .4) then
					keys.left = 1
				elseif(rand < .8) then
					keys.right = 1
				end --or press neither

				rand = math.random()
				if (rand< .4) then
					keys.up = 1
				elseif(rand < .8) then
					keys.down = 1
				end

				--Line that up with what the user is holding.  If the user is holding a key, it can't be pressed.
				userKeys = input.get()
				if(userKeys.Z == true) then
					keys.A = nil
					--vba.print("suppressing A")
				end
				if(userKeys.X == true) then keys.B = nil end
				if(userKeys.left == true) then
					keys.left = nil
				end
				if(userKeys.right == true) then keys.right = nil end
				if(userKeys.up == true) then keys.up = nil end
				if(userKeys.down == true) then keys.down = nil end

				joypad.set(1, keys)
				--vba.print("trying something brand new!")
				currentTry = keys
				return keys

			end
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
	if(timeBored > framesPerSaveState*1/3) then
		loadSaveState()
		currentExcitement = 0
		timeBored = 0
	end

	prevKeys = currentKeys

	--fileWrite()
	makeSaveState()

	vba.frameadvance()

end
