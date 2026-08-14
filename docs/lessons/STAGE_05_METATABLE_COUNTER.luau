--!strict

-- Use case: create two counters that share methods but own separate values.

type CounterData = {
	value: number,
}

-- Step 1: __index tells an object where to find missing methods.
local Counter = {}
Counter.__index = Counter

type Counter = typeof(setmetatable({} :: CounterData, Counter))

-- Step 2: the constructor returns a new table with Counter as its metatable.
function Counter.new(startValue: number): Counter
	return setmetatable({ value = startValue }, Counter)
end

function Counter.increment(self: Counter): number
	self.value += 1
	return self.value
end

-- Step 3: both objects share increment() but not their value field.
local first = Counter.new(0)
local second = Counter.new(10)
assert(first:increment() == 1)
assert(first:increment() == 2)
assert(second:increment() == 11)
assert(first.value == 2)

print("Stage 5 lesson passed")
