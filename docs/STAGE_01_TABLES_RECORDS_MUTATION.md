# Stage 1: Tables, Records, and Mutation

**Difficulty rank:** 01/22 — Beginner
**Suggested prerequisite:** [Bare Minimum Prerequisites](prerequisites/BARE_MINIMUM.md)

## Guided lesson

**Use case:** Store scores in order, look up ready players by user ID, and update one player record.

**Downloadable code:** [STAGE_01_TABLES_RECORDS.luau](lessons/STAGE_01_TABLES_RECORDS.luau)

### Run this before reading the reference

- **Luau CLI:** `luau docs/lessons/STAGE_01_TABLES_RECORDS.luau`
- **Roblox Studio:** paste the program into a temporary `Script` and run it.
- Follow the `Step 1`, `Step 2`, and `Step 3` comments.

The `type` lines describe values for the checker. The functions, assignments, calls, and assertions are the behavior.

<!-- BEGIN VERIFIED LESSON: STAGE_01_TABLES_RECORDS.luau -->
```luau
--!strict

-- Use case: store an ordered score list, ready-player lookup, and player record.

-- Step 1: an array stores values in order.
local scores: { number } = { 10, 25, 15 }
table.insert(scores, 30)
assert(scores[1] == 10)
assert(scores[4] == 30)

-- Step 2: a dictionary looks up a value by key.
local readyByUserId: { [number]: boolean } = {}
readyByUserId[101] = true
readyByUserId[202] = true
readyByUserId[101] = nil
assert(readyByUserId[101] == nil)
assert(readyByUserId[202] == true)

-- Step 3: a record groups named fields that belong together.
type PlayerState = {
	name: string,
	coins: number,
}

local player: PlayerState = {
	name = "Ari",
	coins = 5,
}
player.coins += 2
assert(player.name == "Ari")
assert(player.coins == 7)

print("Stage 1 lesson passed")
```
<!-- END VERIFIED LESSON: STAGE_01_TABLES_RECORDS.luau -->

### Walk through the behavior

Finish this example and **Try it** before reading further. Everything after the guided lesson is reference material.

1. The `scores` array uses consecutive numeric positions, so insertion order is visible.
2. The `readyByUserId` dictionary uses IDs as keys; assigning `nil` removes a key.
3. The `PlayerState` record groups named fields that describe one player.

- **Expected result:** the program prints `Stage 1 lesson passed`.
- **Try it:** add user ID `303`, mark it ready, then remove user ID `202`.
- **Common mistake:** using an array when the real operation is lookup by ID.

## What a table is

A Luau table stores key-value pairs. Arrays, dictionaries, records, sets, queues, module APIs, and many objects are all table shapes. Start by choosing the shape that matches the operation.

### Array

Use consecutive integer keys beginning at `1` when order matters:

```lua
local names = { "Ari", "Bo", "Cy" }
print(names[1])
table.insert(names, "Dee")
```

The length operator `#` is reliable for a dense sequence. Do not assume useful length semantics after leaving holes.

### Dictionary

Use meaningful keys for direct lookup:

```lua
local coinsByUserId = {
	[101] = 20,
	[202] = 35,
}
coinsByUserId[101] += 5
```

### Record

Use named fields when values describe one thing:

```lua
local item = {
	id = "HealthPotion",
	price = 25,
	consumable = true,
}
```

## Mutation and references

Tables are reference values. Two variables can point to the same table:

```lua
local first = { coins = 5 }
local second = first
second.coins = 9
assert(first.coins == 9)
```

`table.clone()` makes a shallow copy. Nested tables remain shared. `table.freeze()` prevents writes to that table only; it is not recursive.

## Choosing a shape

| Need | Start with |
| --- | --- |
| ordered list | dense array |
| lookup by ID/name | dictionary |
| named fields for one value | record |
| membership only | dictionary-as-set |

Do not begin with a framework. Most small Roblox state starts as one clearly owned table.

## Practice

Build an inventory with a dense display order and a dictionary keyed by item ID. Add, update, and remove one item. Explain which table owns truth and which view is derived.

## Completion evidence

- choose arrays, dictionaries, and records intentionally;
- explain shared table references;
- remove dictionary entries with `nil`;
- avoid using `#` as a dictionary count.

## Primary references

- [Luau tables](https://luau.org/library/#table-library)
- [Luau type checking](https://luau.org/typecheck)
