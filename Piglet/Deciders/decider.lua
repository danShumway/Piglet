local decider = {}


function decider.pickKeys()
	local keys = {}
	local available = Piglet.Hardware.Hand.getAvailableKeys()

	--For right now, I'll just choose input at random.
	for k, v in pairs(available) do
		if math.random() < .75 then
			keys[v] = 1
		end
	end

	--
	Piglet.Hardware.Hand.setKeys(keys)
end

return decider