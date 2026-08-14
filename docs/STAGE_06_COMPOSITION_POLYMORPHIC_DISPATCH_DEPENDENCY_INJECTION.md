# Stage 6: Composition, Polymorphic Dispatch, and Dependency Injection

**Difficulty rank:** 06/22 — Foundation
**Suggested prerequisites:** Stages 1-5

## Guided lesson: compose a tiny weapon

**Use case:** Firing needs an ammo source and a sound function, but it does not need a base weapon class.

**Downloadable code:** [STAGE_06_COMPOSITION.luau](lessons/STAGE_06_COMPOSITION.luau)

### Run this before reading the theory

- **Luau CLI:** `luau docs/lessons/STAGE_06_COMPOSITION.luau`
- **Roblox Studio:** paste the code into a temporary `Script` and run the experience. These examples avoid Roblox services so the first behavior is easy to see.
- Read the `Step 1`, `Step 2`, and `Step 3` comments in order.

### Complete working example

The `type` declarations are checker notes. They describe the allowed shape of a value, but they do not perform the behavior. The working behavior is in the functions, table operations, calls, and assertions below.

<!-- BEGIN VERIFIED LESSON: STAGE_06_COMPOSITION.luau -->
```luau
--!strict

-- Use case: build a tiny weapon from replaceable ammo and sound behavior.

-- Step 1: define only the operations the weapon needs.
type AmmoStore = {
	takeOne: (self: AmmoStore) -> boolean,
}

type PlaySound = (soundId: string) -> ()

-- Step 2: create a simple ammo implementation.
local function newAmmoStore(startingAmmo: number): AmmoStore
	local store: AmmoStore
	store = {
		takeOne = function(_self: AmmoStore): boolean
			if startingAmmo <= 0 then
				return false
			end

			startingAmmo -= 1
			return true
		end,
	}
	return store
end

-- Step 3: inject the collaborators instead of finding globals inside fire().
local function fire(ammo: AmmoStore, playSound: PlaySound): boolean
	if not ammo:takeOne() then
		return false
	end

	playSound("Fire")
	return true
end

local played: { string } = {}
local ammo = newAmmoStore(1)

assert(fire(ammo, function(soundId: string)
	table.insert(played, soundId)
end))
assert(not fire(ammo, function(_soundId: string) end))
assert(played[1] == "Fire")

print("Stage 6 lesson passed")
```
<!-- END VERIFIED LESSON: STAGE_06_COMPOSITION.luau -->

### Walk through the behavior

Read the three points, run the code, and complete **Try it**. Once you can explain the assertions, this stage's beginner pass is done. Everything after this guided lesson is optional reference material for later.

1. Read the `AmmoStore` and `PlaySound` contracts; each exposes one operation.
2. Follow `newAmmoStore(1)` to see state captured by a closure.
3. Follow `fire()` to see both dependencies supplied directly by the caller.

- **Expected result:** the first shot succeeds and records `Fire`; the second fails because ammo is empty.
- **Try it:** provide a silent `PlaySound` function for a test.
- **Common mistake:** creating inheritance, interfaces, or a dependency container when two function parameters are enough.

Luau supports functions, closures, tables, modules, and metatables. “OOP” is one way to organize those tools; it is not required for a service/controller architecture and does not imply inheritance.

Read [Curriculum Accuracy Standard](CURRICULUM_ACCURACY_STANDARD.md) before this stage.

## Objects in Luau

A common object pattern uses a table plus a metatable for method lookup. It can provide identity and a convenient method API:

```lua
--!strict

type PromptHandleData = {
	connection: RBXScriptConnection?,
	destroyed: boolean,
}

local PromptHandle = {}
PromptHandle.__index = PromptHandle

export type PromptHandle = typeof(setmetatable({} :: PromptHandleData, PromptHandle))

function PromptHandle.new(): PromptHandle
	return setmetatable({
		connection = nil,
		destroyed = false,
	}, PromptHandle)
end

function PromptHandle:destroy()
	if self.destroyed then
		return
	end
	self.destroyed = true
	if self.connection then
		self.connection:Disconnect()
		self.connection = nil
	end
end
```

This does not create language-enforced private fields. Callers holding the table may be able to inspect or mutate it. Module-local closures, limited returned APIs, copies, frozen tables, or proxies offer different tradeoffs.

A service can also be a plain module of functions. Use an object when per-instance identity, state, or ownership makes the method form useful.

## Composition, inheritance, and polymorphism

These terms are not mutually exclusive:

- **Inheritance** reuses or specializes through an `is-a` hierarchy.
- **Composition** builds a value from collaborators or capabilities it `has`.
- **Polymorphism** lets different implementations be used through a shared operation or contract.

Composition often supplies polymorphism:

```lua
type HitResolver = (origin: Vector3, direction: Vector3) -> RaycastResult?

local function fire(resolveHit: HitResolver, origin: Vector3, direction: Vector3)
	return resolveHit(origin, direction)
end
```

The implementation can be a function, a table with methods, a tagged-union branch, or an inherited object. Luau’s structural typing does not require a base class.

Use a direct conditional when variants are few, closed, and clearer together. Use polymorphic callbacks/objects or a registry when the set is open, separately owned, or frequently extended. Feature-name conditionals are not inherently defects.

## Composition

Composition helps when collaborators change independently:

```text
WeaponRuntime
  has AmmoStore
  has FirePolicy
  has HitResolver
  has RecoilPresenter
```

Do not split every function into a “strategy.” Each seam adds naming, wiring, indirect calls, and more states to reason about. Extract a collaborator when it has meaningful variation, a separate owner, a testing seam, or a distinct dependency.

## Dependency injection

Dependency injection means a caller supplies a dependency. It does not require an IoC container, framework, interface for every module, or data from outside Roblox.

```lua
type Clock = () -> number

local function makeCooldown(clock: Clock, duration: number)
	local readyAt = 0
	return function(): boolean
		local now = clock()
		if now < readyAt then
			return false
		end
		readyAt = now + duration
		return true
	end
end
```

This is useful in a closed-source game because a fake clock makes timing tests repeatable. Explicitly passing a server service, callback, configuration, or adapter is also injection.

Direct `require()` and `game:GetService()` are reasonable for stable leaf dependencies when substitution or isolated testing has no value. Avoid injecting every standard-library call or building a container that hides dependency order.

## Lifecycle

Lifecycle methods describe real domain transitions; there is no universal list.

- `destroy` or `close`: release owned resources or make the handle unusable.
- `start`/`stop`: useful when construction and running are intentionally separate.
- `pause`/`resume`: useful only if pausing has specified effects on timers, input, queues, and state.
- `init`: often unnecessary if construction already establishes invariants.

An object that owns no disposable resource may need no `destroy`. When cleanup exists, define whether it is idempotent and what methods do afterward.

Roblox automatically disconnects non-deferred event connections when the event’s Instance is destroyed, but explicit cleanup is still necessary when the event source outlives the subscriber or other resources remain.

## Services and controllers

A service/controller architecture is compatible with functional modules, objects, ECS, or none of them.

A useful service boundary usually has:

- a cohesive domain responsibility;
- a small public API;
- a clear server/client location;
- explicit long-lived state and resource ownership;
- known startup/shutdown ordering if it matters.

Avoid both extremes: a god service with every feature and dozens of one-method “services” that only forward calls.

## Adapters

An adapter is useful when it translates between contracts—for example, a `ProximityPrompt` event into a validated interaction request, or Roblox time into a testable clock.

Do not wrap every Instance automatically. A wrapper that merely renames properties adds indirection without isolating a meaningful boundary.

## Errors and expected failure

- Use assertions/errors for programmer misuse or broken construction invariants.
- Return a typed result for expected outcomes such as cooldown, permission denial, or missing inventory.
- Use `pcall` around operations that can throw and need recovery, especially cloud APIs; do not use it to silently discard bugs.

“Error boundary” is a design responsibility, not necessarily a class or a `pcall` around every method.

## Object pooling

Pooling trades allocation/destruction for reset complexity, retained memory, and lifecycle risk. It can help with measured churn in expensive Instances or large NPC models, but can hurt when pooled objects are cheap, rarely reused, or difficult to reset correctly.

Before pooling:

1. profile the creation/destruction path;
2. test Roblox-provided alternatives such as particles or client-only visuals;
3. cap the pool;
4. define reset, ownership, release, and shutdown behavior;
5. compare the same workload before and after.

Do not make an `ObjectPool` a required engine primitive.

## Practice project

Build a small interaction feature three ways:

1. direct functions with a closed conditional;
2. a table of action callbacks;
3. action objects satisfying a structural contract.

Add a fake clock to test cooldowns and one `ProximityPrompt` adapter that owns its connection. Compare extension cost, error messages, runtime allocation, and navigation complexity. Keep the simplest design that satisfies the stated extension model.

## Completion evidence

You understand this stage when you can:

- explain why composition and polymorphism work together;
- distinguish polymorphism from inheritance;
- use injection without a container and explain when direct imports are better;
- give lifecycle methods domain semantics instead of copying a fixed list;
- identify which values truly need object identity;
- justify an adapter or pool with a boundary or measurement;
- use a service/controller architecture without assuming ECS.

## Primary references

- [Luau object-oriented typing patterns](https://luau.org/types/object-oriented-programs/)
- [Luau structural type system](https://luau.org/types/)
- [Roblox ModuleScripts](https://create.roblox.com/docs/scripting/module)
- [Roblox events and connection cleanup](https://create.roblox.com/docs/scripting/events)
- [Roblox performance guidance](https://create.roblox.com/docs/performance-optimization/improve)
