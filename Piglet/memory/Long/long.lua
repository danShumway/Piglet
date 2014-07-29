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


--Iterative, suck it.
function long.load(directory, filename)

	--Pull in the file and split it.
	local file = io.open("Databases/"..directory.."/"..filename, "r")
	local text = file:read("*a")

	--Yes, this will probably take a while.
	local translate = {}
	local i = 0


	local currentKey = nil --Do we have a key?
	local currentObject = {object={}, parent=nil} --What object are we on?
	for item in string.gmatch(text, "([^:]+):?") do
		i = i+1
	    --If you're closing an object, then do that.
	    if(item == "]") then
	     	currentObject = currentObject.parent
	    --If we don't have a key, you're on that.
	    elseif(currentKey == nil) then
	      	currentKey = item;
		--If we do have a key, then you're looking for a value.
		--Of course, that value might be an object.
		elseif(item == "[") then
			if(currentObject.object == nil) then print("currentText "..i..", "..item) end
			currentObject.object[currentKey] = {}
			currentObject = {object=currentObject.object[currentKey], parent = currentObject}
			--print(currentObject.parent)
			currentKey = nil --Reset key.
		--Nvm, it's got to be a value.
		else
			currentObject.object[currentKey] = item
			currentKey = nil --Reset key.
		end
    end

    print('loaded causes from last session')
	return currentObject.object
end

return long









