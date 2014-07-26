local short = {}

--Causes are used here with percentage values.
local causes = {}
local states = {}
short.watching = {key_left=1, key_right=1, key_up=1, key_down=1, key_A=1, key_B=1, key_select=1, default=1}
short.currentGoal = {}
short.currentGoal.address = 0
short.currentGoal.rating = 0
short.currentGoal.goal = "mem_0"

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

		--If we really wanted to be mathematically accurate, we'd set this to 1.
		--But I think that's not what we want to do right now.
		causes[state][cause].chance = .5
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