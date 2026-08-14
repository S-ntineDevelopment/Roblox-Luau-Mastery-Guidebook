# Stage 2: Functions, ModuleScripts, and State Ownership

**Difficulty rank:** 02/22 — Beginner
**Suggested prerequisite:** Stage 1

## Guided lesson

**Use case:** Put reusable score operations behind a small module-shaped API while the caller owns player state.

**Downloadable code:** [STAGE_02_FUNCTIONS_MODULES.luau](lessons/STAGE_02_FUNCTIONS_MODULES.luau)

### Run this before reading the reference

- **Luau CLI:** `luau docs/lessons/STAGE_02_FUNCTIONS_MODULES.luau`
- **Roblox Studio:** paste the program into a temporary `Script` and run it.
- Follow the `Step 1`, `Step 2`, and `Step 3` comments.

The `type` lines describe values for the checker. The functions, assignments, calls, and assertions are the behavior.

<!-- BEGIN VERIFIED LESSON: STAGE_02_FUNCTIONS_MODULES.luau -->
```luau
--!strict

-- Use case: put reusable score behavior in a ModuleScript-shaped table.

type ScoreState = {
	pointsByUserId: { [number]: number },
}

-- Step 1: a function receives inputs and returns one result.
local function add(left: number, right: number): number
	return left + right
end
assert(add(2, 3) == 5)

-- Step 2: a table groups functions like a small ModuleScript API.
local ScoreModule = {}

function ScoreModule.award(state: ScoreState, userId: number, amount: number)
	assert(amount > 0, "amount must be positive")
	state.pointsByUserId[userId] = (state.pointsByUserId[userId] or 0) + amount
end

function ScoreModule.get(state: ScoreState, userId: number): number
	return state.pointsByUserId[userId] or 0
end

-- Step 3: the caller owns the mutable state and passes it to the module API.
local scoreState: ScoreState = { pointsByUserId = {} }
ScoreModule.award(scoreState, 101, 5)
ScoreModule.award(scoreState, 101, 3)
assert(ScoreModule.get(scoreState, 101) == 8)
assert(ScoreModule.get(scoreState, 202) == 0)

print("Stage 2 lesson passed")
```
<!-- END VERIFIED LESSON: STAGE_02_FUNCTIONS_MODULES.luau -->

### Walk through the behavior

Finish this example and **Try it** before reading further. Everything after the guided lesson is reference material.

1. `add()` demonstrates inputs, a return value, and no hidden state.
2. `ScoreModule` groups related operations in one public table.
3. The caller creates `scoreState`, so ownership and cleanup stay visible.

- **Expected result:** the program prints `Stage 2 lesson passed`.
- **Try it:** add a `reset(state, userId)` function and assert that the score becomes zero.
- **Common mistake:** putting all player state in a ModuleScript singleton without defining join/leave cleanup.

## Functions first

A function should have a clear input, output, side effect, and failure behavior. Pure functions are easiest to test because the result depends only on arguments.

```lua
local function clampHealth(value: number, maximum: number): number
	return math.clamp(value, 0, maximum)
end
```

Mutation is valid when ownership is explicit:

```lua
local function damage(state: { health: number }, amount: number)
	state.health = math.max(0, state.health - amount)
end
```

## What a ModuleScript does

A ModuleScript returns exactly one value. It runs once per Luau environment when first required, then later `require()` calls in that environment receive the cached return value. Server and client environments do not share one module execution.

### ModuleScript

```lua
-- ReplicatedStorage/MathUtil
local MathUtil = {}

function MathUtil.double(value: number): number
	return value * 2
end

return MathUtil
```

### Script using it

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MathUtil = require(ReplicatedStorage.MathUtil)
print(MathUtil.double(4))
```

The placement decides who can require it. Code in `ServerScriptService` is server-only; code in `ReplicatedStorage` is visible to both server and clients.

## State ownership

A module may own bounded singleton state, but player, character, match, connection, and task state needs an owner and cleanup condition. Passing state into functions often makes that ownership clearer than hiding it in module globals.

Use closures for genuinely private local state:

```lua
local function makeCounter()
	local value = 0
	return function()
		value += 1
		return value
	end
end
```

## Practice

Create `ScoreUtil` as a ModuleScript and a server Script that owns `pointsByUserId`. Add a player, award points, remove the player record, and prove a rejoining player does not inherit stale state.

## Completion evidence

- write functions with clear inputs and returns;
- create and require one ModuleScript;
- explain per-environment module caching;
- identify the owner and cleanup condition for mutable state.

## Primary references

- [Roblox ModuleScripts](https://create.roblox.com/docs/scripting/module)
- [ModuleScript API](https://create.roblox.com/docs/reference/engine/classes/ModuleScript)
- [Luau functions](https://luau.org/syntax#functions)
