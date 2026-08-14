# Stage 3: Common Data Structures and State Machines

**Difficulty rank:** 03/22 — Beginner
**Suggested prerequisites:** Stages 1-2

## Guided lesson

**Use case:** Process round messages in first-in-first-out order and allow only named round-state transitions.

**Downloadable code:** [STAGE_03_DATA_STRUCTURES.luau](lessons/STAGE_03_DATA_STRUCTURES.luau)

### Run this before reading the reference

- **Luau CLI:** `luau docs/lessons/STAGE_03_DATA_STRUCTURES.luau`
- **Roblox Studio:** paste the program into a temporary `Script` and run it.
- Follow the `Step 1`, `Step 2`, and `Step 3` comments.

The `type` lines describe values for the checker. The functions, assignments, calls, and assertions are the behavior.

<!-- BEGIN VERIFIED LESSON: STAGE_03_DATA_STRUCTURES.luau -->
```luau
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
```
<!-- END VERIFIED LESSON: STAGE_03_DATA_STRUCTURES.luau -->

### Walk through the behavior

Finish this example and **Try it** before reading further. Everything after the guided lesson is reference material.

1. The queue stores values plus `head` and `tail` positions.
2. `dequeue()` returns `nil` when no item remains.
3. `nextState()` represents a tiny closed state machine.

- **Expected result:** the program prints `Stage 3 lesson passed`.
- **Try it:** add a `Cancelled` state and decide which state may transition to it.
- **Common mistake:** choosing a complex structure because its name sounds faster without measuring the actual operation.

## Select by operation

| Operation | Small structure |
| --- | --- |
| membership | set |
| last item added | stack |
| first item added | queue |
| lookup by stable ID | registry/dictionary |
| legal transitions | state machine |
| smallest priority first | priority queue/heap |
| connections and paths | graph |

## Set

```lua
local active: { [number]: boolean } = {}
active[101] = true
active[101] = nil
```

## Stack

```lua
local stack = {}
table.insert(stack, "menu")
local newest = table.remove(stack)
```

## Queue

Removing index `1` from an array shifts later values. A queue with a moving head index avoids that repeated shift. Long-lived queues should compact or reset storage after consumed items become large.

## Registry

A registry maps an ID to a value or behavior. Define duplicate policy, missing-ID behavior, iteration order, removal, and ownership.

```lua
local actions: { [string]: (number) -> number } = {}
actions.Double = function(value: number): number
	return value * 2
end
```

## State machine

A state machine names states and legal transitions. It does not require a class framework.

```lua
local allowed = {
	Waiting = { Playing = true },
	Playing = { Finished = true },
}
```

State transitions should own their mutation and rejection behavior. Side effects such as creating Instances or connections still need separate lifecycle ownership.

## When to stop

Use direct tables until the demonstrated operations justify a custom structure. A priority queue, graph, cache, or pool adds invariants and failure modes. Profile before adopting one for performance.

## Practice

Build a matchmaking queue, active-player set, action registry, and three-state round machine. Test empty queue reads, duplicate registration, missing actions, and invalid transitions.

## Completion evidence

- implement set, stack, queue, registry, and small state machine behavior;
- name the invariant each structure owns;
- explain why a head-index queue differs from repeated `table.remove(queue, 1)`;
- avoid claiming performance without representative measurement.

## Primary references

- [Luau table library](https://luau.org/library/#table-library)
- [Luau iteration](https://luau.org/syntax#generalized-iteration)
