--!strict

-- Use case: accept server position, then replay inputs the server has not acknowledged.

type InputCommand = {
	sequence: number,
	delta: number,
}

type ClientState = {
	position: number,
	pending: { InputCommand },
}

local function apply(state: ClientState, command: InputCommand)
	state.position += command.delta
end

-- Step 1: local input predicts immediately and enters pending history.
local function predict(state: ClientState, command: InputCommand)
	apply(state, command)
	table.insert(state.pending, command)
end

-- Step 2: server acknowledgement becomes the new base truth.
local function reconcile(state: ClientState, serverPosition: number, acknowledgedSequence: number)
	state.position = serverPosition

	local remaining: { InputCommand } = {}
	for _, command in state.pending do
		if command.sequence > acknowledgedSequence then
			table.insert(remaining, command)
			apply(state, command)
		end
	end
	state.pending = remaining
end

-- Step 3: replay only commands newer than the acknowledgement.
local state: ClientState = { position = 0, pending = {} }
predict(state, { sequence = 1, delta = 2 })
predict(state, { sequence = 2, delta = 2 })
assert(state.position == 4)

reconcile(state, 1.5, 1)
assert(state.position == 3.5)
assert(#state.pending == 1 and state.pending[1].sequence == 2)

print("Stage 18 lesson passed")
