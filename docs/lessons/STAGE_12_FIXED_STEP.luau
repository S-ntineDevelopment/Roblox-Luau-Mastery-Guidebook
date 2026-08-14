--!strict

-- Use case: step a simple position simulation and copy a snapshot.

type State = {
	position: number,
	velocity: number,
}

-- Step 1: keep one simulation step free of external side effects.
local function step(state: State, deltaTime: number)
	state.position += state.velocity * deltaTime
end

-- Step 2: copy serializable state instead of returning the live table.
local function snapshot(state: State): State
	return {
		position = state.position,
		velocity = state.velocity,
	}
end

-- Step 3: run the same fixed interval and inspect history.
local state: State = { position = 0, velocity = 4 }
local history: { State } = {}

for _ = 1, 3 do
	step(state, 0.25)
	table.insert(history, snapshot(state))
end

assert(state.position == 3)
assert(history[1].position == 1)
state.position = 99
assert(history[3].position == 3)

print("Stage 12 lesson passed")
