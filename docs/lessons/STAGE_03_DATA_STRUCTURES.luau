--!strict

-- Use case: queue round messages and track a small round state.

type Queue = {
	items: { [number]: string },
	head: number,
	tail: number,
}

-- Step 1: the queue owns its array and read/write positions.
local function newQueue(): Queue
	return { items = {}, head = 1, tail = 0 }
end

local function enqueue(queue: Queue, message: string)
	queue.tail += 1
	queue.items[queue.tail] = message
end

local function dequeue(queue: Queue): string?
	if queue.head > queue.tail then
		return nil
	end

	local message = queue.items[queue.head]
	queue.items[queue.head] = nil
	queue.head += 1
	return message
end

-- Step 2: messages leave in the same order they entered.
local messages = newQueue()
enqueue(messages, "first")
enqueue(messages, "second")
assert(dequeue(messages) == "first")
assert(dequeue(messages) == "second")
assert(dequeue(messages) == nil)

-- Step 3: a small state machine rejects an invalid transition.
type RoundState = "Waiting" | "Playing" | "Finished"

local function nextState(state: RoundState): RoundState?
	if state == "Waiting" then
		return "Playing"
	elseif state == "Playing" then
		return "Finished"
	end
	return nil
end

assert(nextState("Waiting") == "Playing")
assert(nextState("Finished") == nil)

print("Stage 3 lesson passed")
