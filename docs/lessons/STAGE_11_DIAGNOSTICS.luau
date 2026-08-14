--!strict

-- Use case: retain only the three most recent diagnostic messages.

-- Step 1: use a small record with an explicit capacity.
type Diagnostics = {
	capacity: number,
	messages: { string },
}

local function newDiagnostics(capacity: number): Diagnostics
	assert(capacity > 0, "capacity must be positive")
	return { capacity = capacity, messages = {} }
end

-- Step 2: enforce the retention bound when recording.
local function record(diagnostics: Diagnostics, message: string)
	table.insert(diagnostics.messages, message)
	while #diagnostics.messages > diagnostics.capacity do
		table.remove(diagnostics.messages, 1)
	end
end

-- Step 3: record enough events to prove old history is removed.
local diagnostics = newDiagnostics(3)
record(diagnostics, "joined")
record(diagnostics, "spawned")
record(diagnostics, "died")
record(diagnostics, "respawned")

assert(#diagnostics.messages == 3)
assert(diagnostics.messages[1] == "spawned")
assert(diagnostics.messages[3] == "respawned")

print("Stage 11 lesson passed")
