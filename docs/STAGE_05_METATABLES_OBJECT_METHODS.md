# Stage 5: Metatables and Object Methods

**Difficulty rank:** 05/22 — Foundation
**Suggested prerequisites:** Stages 1-4

## Guided lesson

**Use case:** Create two counters that share one method table while keeping separate values.

**Downloadable code:** [STAGE_05_METATABLE_COUNTER.luau](lessons/STAGE_05_METATABLE_COUNTER.luau)

### Run this before reading the reference

- **Luau CLI:** `luau docs/lessons/STAGE_05_METATABLE_COUNTER.luau`
- **Roblox Studio:** paste the program into a temporary `Script` and run it.
- Follow the `Step 1`, `Step 2`, and `Step 3` comments.

The `type` lines describe values for the checker. The functions, assignments, calls, and assertions are the behavior.

<!-- BEGIN VERIFIED LESSON: STAGE_05_METATABLE_COUNTER.luau -->
```luau
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
```
<!-- END VERIFIED LESSON: STAGE_05_METATABLE_COUNTER.luau -->

### Walk through the behavior

Finish this example and **Try it** before reading further. Everything after the guided lesson is reference material.

1. `Counter.__index = Counter` makes the method table the fallback for missing object keys.
2. `Counter.new()` creates a new data table and attaches the method table as its metatable.
3. Colon calls pass the object as `self`; the two counters mutate independently.

- **Expected result:** the program prints `Stage 5 lesson passed`.
- **Try it:** add `Counter.add(self, amount)` and test both positive and negative amounts.
- **Common mistake:** believing a metatable automatically creates privacy, inheritance, or validation.

## Metatables are fallback behavior

A metatable changes selected operations on a table. It does not create a separate class runtime.

```lua
local methods = {}
methods.__index = methods

local object = setmetatable({ value = 1 }, methods)
```

When `object.increment` is missing as a raw key, `__index` can provide it from `methods`.

## Colon and dot

```lua
object:increment()
-- is equivalent to:
object.increment(object)
```

A colon definition also declares the first `self` parameter. Mixing dot and colon calls is a common source of incorrect arguments.

## Useful metamethods

- `__index`: fallback reads or method lookup;
- `__newindex`: fallback writes to keys not already present;
- `__tostring`: string representation;
- arithmetic/comparison metamethods: custom operator behavior when justified.

`__newindex` does not intercept writes to existing raw keys. Use a separate empty proxy when every write must be observed or rejected.

## Metatable typing

The verified lesson uses `typeof(setmetatable(...))` so the checker knows the data and method lookup belong together. That type line is checker bookkeeping; `setmetatable()` and `__index` are the runtime behavior.

## When not to use metatables

Plain functions and records are often clearer for small stateless logic. Use metatable objects when identity, methods, or lifecycle ownership make the representation easier to understand.

## Practice

Build a timer object with `new`, `start`, `stop`, and `elapsed`. Define whether repeated `start` and `stop` calls are accepted. Do not add `pause`, `resume`, or `destroy` unless the object has real semantics for them.

## Completion evidence

- explain raw keys versus `__index` fallback;
- use colon and dot calls correctly;
- create two independent objects sharing methods;
- explain the existing-key limitation of `__newindex`;
- choose plain functions when objects add no value.

## Primary references

- [Luau object-oriented typing](https://luau.org/types/object-oriented-programs/)
- [Luau table library](https://luau.org/library/#table-library)
