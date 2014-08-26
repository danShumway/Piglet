local guessTestRevise = {}


--
function guessTestRevise.iterate(sequence)

	--For each step.
	for k, v in pairs(Piglet.Memory.Instant.currentChanges) do
		if(Piglet.Memory.Short.updateSeen(k, v)) then
			--You get a huge bonus.
		else
			--Repetitive changes either shouldn't count towards you, or should count as nothing.
			--Since we'll be able to see how many times you've seen that, we could possibly bias stuff(?)
			--Not really useful, I think we thought through a couple of reasons that doesn't work.
		end
	end
end

return guessTestRevise