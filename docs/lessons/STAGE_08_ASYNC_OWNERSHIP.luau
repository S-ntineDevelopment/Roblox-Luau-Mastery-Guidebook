--!strict

-- Use case: prevent a cancelled countdown from applying later work.

-- Step 1: the owner keeps a cancellation state.
type Operation = {
	cancelled: boolean,
}

local function cancel(operation: Operation)
	operation.cancelled = true
end

-- Step 2: every delayed callback checks the owner's current state.
local function runCountdown(operation: Operation, steps: number, onStep: (number) -> ())
	for remaining = steps, 1, -1 do
		if operation.cancelled then
			return
		end
		onStep(remaining)
	end
end

-- Step 3: prove cancellation blocks later mutation.
local operation: Operation = { cancelled = false }
local visited: { number } = {}

runCountdown(operation, 3, function(remaining: number)
	table.insert(visited, remaining)
	if remaining == 2 then
		cancel(operation)
	end
end)

assert(#visited == 2)
assert(visited[1] == 3 and visited[2] == 2)

print("Stage 8 lesson passed")
