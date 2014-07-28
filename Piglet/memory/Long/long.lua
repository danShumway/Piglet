long = {}



--Private internal function
local function recurseSave(file, object)
	--Recurse through all the objects and write them out.
	for k, v in pairs(object) do
		--If it's a table, we need to recurse down into that and write it.
		if(type(v) == "table") then
			file:write(":", k, ":[") --Mark that we're entering an object
			recurseSave(file, v) --Recurse down.
			file:write(":]") --End the function.
		else
			file:write(":", k, ":", v)
		end
	end
end

function long.save(directory, filename, object)
	--Open up the file.
	file = io.open("Databases/"..directory.."/"..filename, "w")
	file:write("object:[")
	recurseSave(file, object)
	file:write(":]")
	
	file:close()
	print("saved")
end

return long









