--
--Licensed under GNU affero general public license
--http://www.gnu.org/licenses/agpl-3.0.html
--

local short = {}

--Causes are used here with percentage values.
local causes = {}
local states = {}
short.watching = {key_left=1, key_right=1, key_up=1, key_down=1, key_A=1, key_B=1, key_select=1, default=1}
short.currentGoal = {}
short.currentGoal.address = 0
short.currentGoal.rating = 0
short.currentGoal.goal = "mem_0"
short.interest = 2
short.baseInterest = 2

------------------------------------------------------------------------------------------------------
---------------------------RESETS---------------------------------------------------------------------
--
--
------------------------------------------------------------------------------------------------------


local initialState = savestate.create()

function short.recordInitialState()
	savestate.save(initialState)
end

function short.resetInitialState()
	savestate.load(initialState)
end

------------------------------------------------------------------------------------------------------
--End data structure for resets.
------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------
-------------------------SIGNIFICANT CHANGES----------------------------------------------------------
--Keeps track of all of the states that have been seen, and the number of times they have been seen.
--
------------------------------------------------------------------------------------------------------

local seen = {}


short.strategies = dofile("Memory/Short/DataStructures/strategy.lua")

--Returns the number of times I've seen this state.
function short.haveSeen(state, value)
	--If I've seen this state change.
	if(seen[state]) then
		if(seen[state][value]) then
			return seen[state][value]
		end
	end

	return 0
end

function short.forgetSeen()
	seen = {}
end

--Adds a new state to the list of things you've seen.
--Also returns the number of time's I've seen this state.
function short.updateSeen(state, value)
	--Set up state if it doesn't yet exist.
	if(seen[state] == nil) then
		seen[state] = {}
	end
	--Set up seen state if it doesn't exist yet.
	if(seen[state][value] == nil) then
		seen[state][value] = 1 --I've seen it once.
		return 0
	else
		seen[state][value] = seen[state][value] + 1 --I've seen it again.
		return seen[state][value] - 1
	end
end




-------------------------------------------------------------------------------------------------------
--------------------------CAUSE AND EFFECT-------------------------------------------------------------
-------------------------------------------------------------------------------------------------------

--Send a state/result to the causes array.  Effect isn't really talked about here.
function short.updateCause(state, cause, direction)
	--If we don't have existing data for the state.
	if(causes[state] == nil) then
		--Create the state
		causes[state] = {}
	end

	--If we haven't created or observed this cause yet.
	if(causes[state][cause] == nil) then
		--Create the cause
		causes[state][cause] = {}
		--There are a couple of fields we care about making.
		causes[state][cause].trials = 1
		causes[state][cause].effect = 1

		--Start it at the proper chance.
		causes[state][cause].chance = direction
	else 
		--We keep things simple for right now.
		--Just update it.  Don't worry about bayesian stuff.

		--Extract out the actual number of successes.
		causes[state][cause].chance = causes[state][cause].chance*causes[state][cause].trials;
		
		--Adjust likelyhood.
		causes[state][cause].chance = causes[state][cause].chance + direction


		--Increase number of trials
		causes[state][cause].trials = causes[state][cause].trials + 1
		--Reset to a decimal chance.
		causes[state][cause].chance = causes[state][cause].chance/causes[state][cause].trials
	end
end


--Needs some refinement.
function short.getCauses(state)
	--Return all the causes related to that state.
	if(causes[state] == nil) then
		return {}
	end
	--Else
	return causes[state]
end

function short.allCauses()
	return causes
end

function short.rememberCauses(_c)
	causes = _c
end

--Returns whether or not a state is true.
--Returns 1 (true), 0(false), or -1, unknown.
function short.getState(state)
	if(states[state] ~= nil) then
		return states[state]
	else
		return -1
	end
end

--The value of the state to set, and the int value to set it as (1, 0, -1)
function short.setState(state, value)
	states[state] = value
end

function short.forgetStates()
	states = {}
end

return short