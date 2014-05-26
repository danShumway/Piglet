--
--Copyright Daniel Shumway, 2014
--Licensed under GNU affero general public license
--http://www.gnu.org/licenses/agpl-3.0.html
--


--Although Lists can be accessed via [], they are not meant to be.  They are more like queues/stacks.
--Deleting a value from a List does not change the other indexes.  So it is possible to have a list that starts at value [2].

--Make our list library.
List = {}

--++++++++++++++++++++PUBLIC+++++++++++++++++++++++++++++++

--Returns a new list object.
function List.CreateList()

	--Make a list.
	local toReturn = {}

	--Set variables.
	--Lists are 1 based because most of Lua is 1 based, not because I like it.
	toReturn.FirstIndex = 1
	toReturn.LastIndex = 1
	toReturn.Count = 0

	--Used for internal error checking, maybe, sometime.
	toReturn.Type = "List"

	return toReturn;
end

--Lists can have some operations done to them.

--Pop and Pull will delete a value from the front or the back of a list.
--Push and Budge will insert a value at the front or back of a list.
--Pass in the list you want to run the operation on.
function List.Pull(self) --front

	--If it is a list.
	if(self.Type == "List") then
		--If you can remove.
		if(self.Count ~= 0) then
			local toReturn = self[self.FirstIndex] --Grab value to return.
			self[self.FirstIndex] = nil
			self.FirstIndex	= self.FirstIndex + 1 --We don't start there anymore.
			self.Count = self.Count - 1 --Update count.

			return toReturn; --Send Data.
		end

	end

	return nil;
end

function List.Pop(self) --back

	--If it is a list.
	if(self.Type == "List") then
		--If you can remove.
		if(self.Count ~= 0) then
			local toReturn = self[self.LastIndex] --Grab value to return.
			self[self.FirstIndex] = nil
			self.FirstIndex	= self.LastIndex - 1 --We don't end there anymore.
			self.Count = self.Count - 1 --Update count.

			return toReturn; --Send Data.
		end

	end

	return nil;
end

function List.Push(self, data) --back
	if(self.Type == 'List') then
		self[self.LastIndex + 1] = data
		self.Count = self.Count + 1
	end
end

function List.Budge(self, data) --front
	if(self.Type == 'List') then
		self[self.FirstIndex - 1] = data --yes, we can actually have a list where -1 is the starting index.
		self.Count = self.Count + 1
	end
end

--An iterator that takes a function as a parameter.
function List.ForEach(self, func, context)
	for a=self.FirstIndex, self.LastIndex do
		if(context ~= nil) then
			func(context, a) --When you're using an object.
		else
			func(a) --For global context
		end
	end
end

--Runs an interator until something other than nil is returned, then returns that value.
function List.CheckAll(self, func, context)

	local toReturn;
	for a=self.FirstIndex, self.LastIndex do
		if(context ~= nil) then
			--When you're using an object.
			toReturn = func(context, a)
			if(toReturn ~= nil) then
				return toReturn
			end
		else
			--When you're using an object.
			toReturn = func(a)
			if(toReturn ~= nil) then
				return toReturn
			end
		end
	end

	return nil --We didn't meet whatever condition you wanted to meet.
end


--I'll add some more stuff later, as needed.

--+++++++++++++++++++e/PUBLIC+++++++++++++++++++++++++++++++


