# Stage 1: Luau Tables, ModuleScripts, Metatables, and Data Structures

**Difficulty:** Foundation
**Suggested prerequisite:** [Bare Minimum Prerequisites](prerequisites/BARE_MINIMUM.md)

This is the first implementation stage. It starts with the structures used by almost every Roblox system before introducing objects, ECS, networking, rollback, or framework architecture.

Read [Bare Minimum Prerequisites](prerequisites/BARE_MINIMUM.md) and [Curriculum Accuracy Standard](CURRICULUM_ACCURACY_STANDARD.md) first.

## Learning order

Work through this stage in order:

1. tables as arrays and dictionaries;
2. functions, closures, and ModuleScripts;
3. basic metatable lookup and metamethods;
4. small reusable data structures;
5. simple system shapes built from those pieces.

Do not begin by building a class framework. First learn what tables and functions actually do.

## Tables: one type, several shapes

Luau uses tables for arrays, dictionaries, records, sets, objects, registries, queues, and many other structures. The intended shape matters even though the runtime value is always a table.

### Array-like table

Use consecutive integer keys starting at `1` when order matters:

```lua
local players = { "Ari", "Bo", "Cy" }

for index, name in ipairs(players) do
	print(index, name)
end
```

`table.insert()` appends or inserts. `table.remove()` removes and shifts later elements. Removing index `1` repeatedly is therefore a poor queue implementation for large queues.

An array with holes is no longer a reliable sequence. Do not depend on `#values` or `ipairs()` to describe every numeric key after setting an interior element to `nil`.

### Dictionary or map

Use meaningful keys for direct lookup:

```lua
local coinsByUserId: { [number]: number } = {}

coinsByUserId[1234] = 50
local coins = coinsByUserId[1234]
coinsByUserId[1234] = nil -- removes the entry
```

Dictionary lookup is normally clearer than scanning an array when the key is already known. Iteration order is not a sorting guarantee; sort explicit keys when output order matters.

### Record

A record groups named fields that describe one value:

```lua
type WeaponConfig = {
	damage: number,
	magazineSize: number,
	reloadSeconds: number,
}

local rifle: WeaponConfig = {
	damage = 24,
	magazineSize = 30,
	reloadSeconds = 1.8,
}
```

Do not mix unrelated array and dictionary responsibilities in one table merely because Luau permits both key types.

## References, copies, and mutation

Tables are reference values:

```lua
local first = { coins = 10 }
local second = first
second.coins = 20

print(first.coins) -- 20
```

Know whether an API returns:

- the live mutable table;
- a shallow copy;
- a recursively copied snapshot;
- a frozen table;
- a proxy or query API.

`table.clone()` is shallow: nested tables remain shared. `table.freeze()` prevents writes to that table but does not recursively freeze nested tables. Copy only as deeply as the contract requires, because deep copying has cost and identity consequences.

## Functions and closures

Functions are values. A closure can retain local state without a metatable:

```lua
local function makeCounter()
	local value = 0

	return function(): number
		value += 1
		return value
	end
end

local nextCount = makeCounter()
print(nextCount()) -- 1
print(nextCount()) -- 2
```

This is often enough for a small stateful tool. Use a table/object when several operations need the same state or callers need an inspectable handle.

## ModuleScripts

A ModuleScript returns one value, commonly a function or table:

```lua
-- DamageMath.luau
local DamageMath = {}

function DamageMath.afterArmor(rawDamage: number, armor: number): number
	return math.max(0, rawDamage - armor)
end

return DamageMath
```

```lua
local DamageMath = require(script.Parent.DamageMath)
print(DamageMath.afterArmor(20, 6)) -- 14
```

Important runtime facts:

- the first `require()` executes the module in that Luau environment;
- later requires in the same environment receive the same returned reference;
- server and client environments do not share one returned table;
- mutable state in a returned table can therefore act like environment-local shared state;
- a yielding module makes its first caller wait;
- circular requires are a design/load failure, not a dependency-management technique.

Use module-local variables for implementation details. Return only the operations or values callers need.

## Basic metatables

A metatable changes selected operations on a table. It is a mechanism, not automatically a class, interface, security boundary, or performance optimization.

```lua
local fallback = {
	walkSpeed = 16,
}

local playerSettings = setmetatable({
	walkSpeed = 22,
}, {
	__index = fallback,
})

print(playerSettings.walkSpeed) -- 22
print(playerSettings.jumpPower) -- nil
```

When a key is missing, `__index` can be:

- another table used for fallback lookup; or
- a function that computes or retrieves the result.

### Method lookup

The common Luau object pattern uses `__index` to find methods:

```lua
local Counter = {}
Counter.__index = Counter

function Counter.new(startValue: number?)
	return setmetatable({
		value = startValue or 0,
	}, Counter)
end

function Counter.increment(self): number
	self.value += 1
	return self.value
end

local counter = Counter.new(5)
print(counter:increment()) -- 6
```

The colon call `counter:increment()` passes `counter` as `self`. The same call can be written `counter.increment(counter)`. Stage 3 develops this into typed objects, composition, and polymorphic APIs.

### Useful metamethods

Learn these before reaching for more elaborate proxy behavior:

| Metamethod | Used for | Caution |
| --- | --- | --- |
| `__index` | fallback values or method lookup | runs only when the raw key is absent |
| `__newindex` | handling writes to absent raw keys | does not intercept replacement of an existing raw key |
| `__tostring` | debug-friendly string conversion | keep it cheap and free of important side effects |
| `__eq` | custom equality in supported cases | identity and value equality must remain clear |
| `__add`, `__sub`, etc. | operator behavior | use only when the operation is natural and unsurprising |
| `__iter` | generalized iteration | document yielded keys/values and order semantics |

`rawget()` and `rawset()` bypass normal metatable lookup for the specified table. They are low-level tools, not general encapsulation APIs.

### Write guards and proxies

This does **not** fully protect existing fields:

```lua
local value = setmetatable({ score = 10 }, {
	__newindex = function()
		error("read only")
	end,
})

value.score = 20 -- replaces an existing raw key; __newindex is not called
```

A write-guard proxy normally keeps protected storage in a separate table and leaves the proxy itself empty. Even then, test iteration, length, equality, serialization, and library behavior. Prefer a copied snapshot, frozen table, or narrow query function when those have simpler semantics.

## Core data structures

Choose a structure by the operations it needs to make clear and efficient.

### Set

A set records membership with dictionary keys:

```lua
local activeUserIds: { [number]: boolean } = {}

activeUserIds[1234] = true
if activeUserIds[1234] then
	print("active")
end
activeUserIds[1234] = nil
```

Use `true` for membership and `nil` for absence. If false is meaningful data, use a different record shape.

### Stack (last in, first out)

```lua
local stack: { string } = {}

table.insert(stack, "first")
table.insert(stack, "second")

local top = table.remove(stack) -- "second"
```

Stacks suit undo history, parser work, depth-first traversal, and nested state. Bound histories that can grow over time.

### Queue (first in, first out)

Use a moving head rather than shifting every element on every dequeue:

```lua
type Queue<T> = {
	items: { [number]: T },
	head: number,
	tail: number,
}

local function newQueue<T>(): Queue<T>
	return { items = {}, head = 1, tail = 0 }
end

local function enqueue<T>(queue: Queue<T>, value: T)
	queue.tail += 1
	queue.items[queue.tail] = value
end

local function dequeue<T>(queue: Queue<T>): T?
	if queue.head > queue.tail then
		return nil
	end

	local value = queue.items[queue.head]
	queue.items[queue.head] = nil
	queue.head += 1
	return value
end
```

Production queues also need a maximum size, overflow/backpressure policy, and occasional index compaction if they are long-lived.

### Registry

A registry maps an ID to a definition or runtime handle:

```lua
local actionsById: { [string]: (Player) -> () } = {}

local function registerAction(id: string, action: (Player) -> ())
	assert(actionsById[id] == nil, `duplicate action: {id}`)
	actionsById[id] = action
end
```

For a small closed set, a direct table literal or conditional may be simpler. A reusable registry needs duplicate, admission, ordering, replacement/removal, ownership, and inspection rules.

### State machine

A finite state machine makes legal transitions explicit:

```lua
type DoorState = "Closed" | "Opening" | "Open" | "Closing"

local allowed: { [DoorState]: { [DoorState]: boolean } } = {
	Closed = { Opening = true },
	Opening = { Open = true, Closing = true },
	Open = { Closing = true },
	Closing = { Closed = true, Opening = true },
}
```

The transition table is only the rule data. The owner still decides who may request a transition, performs side effects, and handles cancellation or destruction.

### Priority queue and graph

- A **priority queue** retrieves the highest- or lowest-priority item. A binary heap is a common implementation when repeated sorted insertion becomes expensive.
- A **graph** represents nodes and relationships, such as quests, roads, dialogue, dependencies, or navigation. Define whether edges are directed, weighted, and removable.

Do not implement a complex structure merely to name it. Start from required operations and expected size.

## Small system shapes built from these pieces

Most Roblox systems begin as combinations of ordinary modules, tables, and functions:

| Shape | Structure | Good fit |
| --- | --- | --- |
| Pure library | Module returning functions | calculations and conversions |
| Configuration | validated record/table | design-time values |
| Stateful module/service | module-local dictionary plus API | one environment-local owner |
| Runtime handle | factory returning table/closure/object | several independent owned instances |
| Registry | ID-to-definition dictionary | lookup and open extension points |
| State machine | state value plus transition rules | legal lifecycle or gameplay transitions |
| Processor/system | collection plus update function | repeated operations over many records |

These are building blocks, not competing religions. A service can own a queue. An object can contain a state machine. An ECS system can use dictionaries and arrays internally. A registry can store functions rather than objects.

## Common beginner mistakes

- using one global table for unrelated systems;
- exposing a module's live mutable state when callers only need queries;
- treating a required ModuleScript as one shared server/client singleton;
- using `table.find()` for a dictionary key instead of direct lookup;
- depending on dictionary iteration order;
- using `#` on a sparse array as if it were a precise count;
- calling `table.remove(queue, 1)` for every item in a large queue;
- adding a metatable where a plain table or closure is clearer;
- assuming `__newindex` protects existing fields;
- building a registry, service container, or class hierarchy before having a real variation/ownership problem.

## Practice project

Build a small round tracker in four passes:

1. Store players in a dictionary keyed by `UserId` and round order in an array.
2. Put the operations in a ModuleScript with module-local state and query functions.
3. Add a state machine for `Waiting -> Starting -> Running -> Ending -> Waiting`.
4. Return a separate runtime handle for two independent test rounds, with cleanup for any owned connection or task.

Then add:

- a set of ready players;
- a queue of join/leave commands with a maximum size;
- a registry of optional round modifiers;
- a metatable-based handle only if the method API is clearer than closures/plain functions.

Test empty collections, duplicate registration, removal during a round, two independent round handles, and repeated create/destroy cycles.

## Completion evidence

You understand this stage when you can:

- explain arrays, dictionaries, records, and sets without calling them different runtime types;
- predict reference sharing and shallow-copy behavior;
- explain ModuleScript caching and the server/client environment boundary;
- implement and explain `__index` method lookup;
- demonstrate why `__newindex` does not guard existing raw keys;
- choose a stack, queue, set, registry, or state machine from the operations required;
- build a small system without needing a framework;
- state which value owns mutable state and which code may change it.

## Primary references

- [Luau syntax](https://luau.org/syntax/)
- [Luau table types](https://luau.org/types/tables/)
- [Luau standard library](https://luau.org/library/)
- [Luau object-oriented type patterns](https://luau.org/types/object-oriented-programs/)
- [Lua 5.1 metatables and metamethods](https://www.lua.org/manual/5.1/manual.html#2.8)
- [Roblox ModuleScript API](https://create.roblox.com/docs/reference/engine/classes/ModuleScript)
- [Roblox module reuse guide](https://create.roblox.com/docs/scripting/module)

Check current Luau and Roblox documentation before relying on newer metamethods, type syntax, require-path behavior, or library functions.
