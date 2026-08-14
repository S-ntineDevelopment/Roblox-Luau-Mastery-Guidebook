--!strict

-- Use case: track ready players, process messages in order, and create counters.

-- Step 1: a dictionary can act as a set.
local readyByUserId: { [number]: boolean } = {}
readyByUserId[101] = true
readyByUserId[202] = true
readyByUserId[101] = nil

assert(readyByUserId[101] == nil)
assert(readyByUserId[202] == true)

-- Step 2: a queue uses a head index so dequeue does not shift every item.
type Queue = {
	items: { [number]: string },
	head: number,
	tail: number,
}

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

local messages = newQueue()
enqueue(messages, "first")
enqueue(messages, "second")
assert(dequeue(messages) == "first")

-- Step 3: __index can provide method lookup for a small object.
type CounterData = { value: number }

local Counter = {}
Counter.__index = Counter

type Counter = typeof(setmetatable({} :: CounterData, Counter))

function Counter.new(startValue: number): Counter
	return setmetatable({ value = startValue }, Counter)
end

function Counter.increment(self: Counter): number
	self.value += 1
	return self.value
end

local counter = Counter.new(4)
assert(counter:increment() == 5)

print("Stage 1 lesson passed")
