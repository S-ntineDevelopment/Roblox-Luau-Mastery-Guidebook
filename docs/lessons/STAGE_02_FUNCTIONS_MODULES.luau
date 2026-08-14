--!strict

-- Use case: put reusable score behavior in a ModuleScript-shaped table.

type ScoreState = {
	pointsByUserId: { [number]: number },
}

-- Step 1: a function receives inputs and returns one result.
local function add(left: number, right: number): number
	return left + right
end
assert(add(2, 3) == 5)

-- Step 2: a table groups functions like a small ModuleScript API.
local ScoreModule = {}

function ScoreModule.award(state: ScoreState, userId: number, amount: number)
	assert(amount > 0, "amount must be positive")
	state.pointsByUserId[userId] = (state.pointsByUserId[userId] or 0) + amount
end

function ScoreModule.get(state: ScoreState, userId: number): number
	return state.pointsByUserId[userId] or 0
end

-- Step 3: the caller owns the mutable state and passes it to the module API.
local scoreState: ScoreState = { pointsByUserId = {} }
ScoreModule.award(scoreState, 101, 5)
ScoreModule.award(scoreState, 101, 3)
assert(ScoreModule.get(scoreState, 101) == 8)
assert(ScoreModule.get(scoreState, 202) == 0)

print("Stage 2 lesson passed")
