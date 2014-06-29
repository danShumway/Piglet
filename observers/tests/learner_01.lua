--
--Copyright Daniel Shumway, 2014
--Licensed under GNU affero general public license
--http://www.gnu.org/licenses/agpl-3.0.html
--

--ToDo:  Remember how to check strings in lua.  It's something like string.at or something stupid.
--In the meantime, we're going to reference this stuff with STRING(string, index)
--That way, we can change it easily later.
--In fact, all uppercase stuff will be rewritten later.  Just assume it.


local watching = {}

watching.cause_effect = {}
watching.currentlyWatching = "left_"


function watching.to(self, left, right)
	
end



function watching.checkState(self, state){
	local stateChecks = string.gmatch(state, "([^_]+)_?")

	--Loop through each index in the stateChecks.
		--Different logic applies depending where we are.

	local params = {} --We need to keep track of the stuff to check.

	--Params is a list of table values.
	--[[{
		
		1: {value:key_left, optional: how does it change.}

	}--]]

	--Start true.
	local stateTrue = true
	local notModifier = false
	local currentModifier = ""
	local value_1 = ""
	local value_2 = ""
	local currentCheck = "key"
	for i in stateChecks do
		----Check if the first is an n.
		if (i=="n") then
			--First things first, we're at the start
			notModifier = true
		----Check for some of the other stuff.
		else if (i=="key") then
			currentCheck = "key"
		else if (i=="memC") then
			currentCheck = "mem"
		--One level deep.
		else
			--If it's none of those, it's probably a number or a label for a key.
			if(currentCheck == "key") then
				--Grab the current value and set it for the current check.
			else if (currentCheck == "mem") then
				--Check to see if you have a value1.
				if(value_1 == "") then
					--Grab the address.
					value_1 = MEMORY.GET(i)
					--But really we want the value to be how much it's changed by.
					--Or do we?  That won't let us use the to modifier.
				--I have a value1 and now I want to get value2.
				else
					--Check to see if you have a modifier.
					if(i == "a") then
						currentModifier = "a"
					else
						if(currentModifier == "a") then

						end
						--Reset now that you've grabbed the value.
						currentModifier = ""
					end
				end
			end
		end
	end
end



function watching.chooseToWatch(self){
	--Write out a syntactically correct postulate based on something you've watched.

	--Loop through the changes and grab
end


return watching