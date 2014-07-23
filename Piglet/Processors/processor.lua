local processor = {}


--Do some processing on the info.
function processor.process()
	--We'll potentially deal with this differently in the future.
	Piglet.Memory.Short.forgetStates()

	--Loop through the changes and see what's going on.
	--for local k, v in pairs(instant)


end




--Look up a state and see if it's currently true or not.
function processor.checkState(state)
	local translate = {}
	local i = 1
	for item in string.gmatch(state, "([^_]+)_?") do
      translate[i] = item;
      i = i +1
    end
	--local translate = string.gmatch(state, "([^_]+)_?")
	if(state == "default") then 
		return 1
	end --This is always true.  It's something that changes kind of regardless of what's pressed, or at least by default.

	--All our states start with what to check.
	if(translate[1] == "mem") then
		--print(translate[2])
		translate[2] = tonumber(translate[2])
		if(self.curFrame[translate[2]] - self.prevFrame[translate[2]] ~= 0) then
			return 1
		end
		return 0 --Hasn't changed.
	elseif(translate[1] == "key") then
		if(keys[translate[2]]) then
			return 1
		end
		return 0 --Isn't down.
	end
end























return processor