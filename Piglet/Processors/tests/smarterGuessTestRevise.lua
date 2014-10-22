local guessTestRevise = {}

--
function guessTestRevise.iterate()

	--Increase scores of the strategy based on what you've seen.
	local changes = 0
	for k, v in pairs(Piglet.Memory.Instant.currentChanges) do
		if(Piglet.Memory.Short.updateSeen(k, v) == 0) then
			--You get a huge bonus.
			changes = changes + 1
		else
			--Repetitive changes either shouldn't count towards you, or should count as nothing.
			--Since we'll be able to see how many times you've seen that, we could possibly bias stuff(?)
			--Not really useful, I think we thought through a couple of reasons that doesn't work.
		end
	end

	--Increase the score of the current strategy.
	Piglet.Memory.Short.strategies.curStrategy.score = Piglet.Memory.Short.strategies.curStrategy.score + changes

	--If we're bored, then we need to stop the strategy and reset.
	if changes == 0 then
		Piglet.Memory.Short.interest = Piglet.Memory.Short.interest - 1

		if Piglet.Memory.Short.interest <= 0 then
			print(Piglet.Memory.Short.strategies.curStrategy.score.."vs "..Piglet.Memory.Short.strategies.prevStrategy.score)
			Piglet.Memory.Short.interest = Piglet.Memory.Short.baseInterest
			Piglet.Memory.Short.forgetSeen()
			Piglet.Memory.Short.resetInitialState()
			Piglet.Memory.Instant.lastFrame = {}
			Piglet.Memory.Instant.currentFrame = {}


			--If this strategy did better, keep it.  Otherwise, trash it.
			if Piglet.Memory.Short.strategies.curStrategy.score >= Piglet.Memory.Short.strategies.prevStrategy.score then
				Piglet.Memory.Short.strategies.prevStrategy = Piglet.Memory.Short.strategies.curStrategy
				Piglet.Memory.Short.strategies.curStrategy = Piglet.Memory.Short.strategies.iterate(Piglet.Memory.Short.strategies.curStrategy.strategy)
			else
				Piglet.Memory.Short.strategies.curStrategy = Piglet.Memory.Short.strategies.iterate(Piglet.Memory.Short.strategies.prevStrategy.strategy)
			end

			print(Piglet.Memory.Short.strategies.trace(Piglet.Memory.Short.strategies.curStrategy))
		end
	end
end

return guessTestRevise