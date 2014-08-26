local guessTestRevise = {}


--
function guessTestRevise.iterate()

	--For each step.
	local strategy = Piglet.Memory.Short.strategies[Piglet.Memory.Short.strategies.currentIndex];
	for k, v in pairs(Piglet.Memory.Instant.currentChanges) do
		if(Piglet.Memory.Short.updateSeen(k, v) == 0) then
			--You get a huge bonus.
			strategy.score = strategy.score + 1
		else
			--Repetitive changes either shouldn't count towards you, or should count as nothing.
			--Since we'll be able to see how many times you've seen that, we could possibly bias stuff(?)
			--Not really useful, I think we thought through a couple of reasons that doesn't work.
		end
	end

	--If we've reached the end, iterate on the winning formula.
	if(Piglet.Memory.Short.strategies.refresh == true) then

		Piglet.Memory.Short.strategies.refresh = false --We're doing it.
		
		local bestStrategy = 1
		local bestScore = 0
		--Find winner
		for i=1, Piglet.Memory.Short.strategies.count, 1 do
			if(Piglet.Memory.Short.strategies[i].score > bestScore) then
				bestScore = Piglet.Memory.Short.strategies[i].score
				bestStrategy = i
			end
		end
		Piglet.Memory.Short.strategies.iterate(Piglet.Memory.Short.strategies[bestStrategy].strategy)
		print("trial finished: "..bestScore..", "..Piglet.Memory.Short.strategies.currentNode.toString(0))
	end
end

return guessTestRevise