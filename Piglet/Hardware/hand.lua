--Some setup.
local hand = {}

--[[
--------------------------------
Data, keys are a table
(A, B, select, start, right, left, up, down, R, L)
nil means not pressed, 1 means pressed.
---------------------------------
--]]

--Closures work, so we're using them.  This also invalidates the need for self, which I quite like.
local currentlyHolding = {}

--Sets which keys the hand will hold down next frame.
function hand.setKeys(keys) 
	currentlyHolding = keys
	--Also update the vba emulator.
	joypad.set(1, keys)
end

--Gets the keys the hand is currently holding down.
function hand.getKeys()
	return currentlyHolding
end

function hand.getAvailableKeys()
	return {"A", "B", "left", "right", "up", "down"}--, "start"}
end


return hand;