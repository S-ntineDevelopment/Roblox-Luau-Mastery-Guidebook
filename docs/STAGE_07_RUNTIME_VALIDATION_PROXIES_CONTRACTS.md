# Stage 7: Runtime Validation, Proxies, and Contracts

**Difficulty rank:** 07/22 — Applied
**Suggested prerequisites:** Stages 1-6

## Guided lesson

**Use case:** Validate dynamic settings and expose them through a proxy that rejects writes.

**Downloadable code:** [STAGE_07_RUNTIME_PROXY_CONTRACT.luau](lessons/STAGE_07_RUNTIME_PROXY_CONTRACT.luau)

### Run this before reading the reference

- **Luau CLI:** `luau docs/lessons/STAGE_07_RUNTIME_PROXY_CONTRACT.luau`
- **Roblox Studio:** paste the program into a temporary `Script` and run it.
- Follow the `Step 1`, `Step 2`, and `Step 3` comments.

The `type` lines describe values for the checker. The functions, assignments, calls, and assertions are the behavior.

<!-- BEGIN VERIFIED LESSON: STAGE_07_RUNTIME_PROXY_CONTRACT.luau -->
```luau
--!strict

-- Use case: validate dynamic settings, then expose a read-only view.

type Settings = {
	volume: number,
}

-- Step 1: runtime validation converts unknown input into trusted data.
local function decodeSettings(value: unknown): Settings?
	if type(value) ~= "table" then
		return nil
	end

	local record = value :: { [string]: unknown }
	local volume = record.volume
	if type(volume) ~= "number" or not math.isfinite(volume) then
		return nil
	end
	if volume < 0 or volume > 1 then
		return nil
	end
	return { volume = volume }
end

local settings = decodeSettings({ volume = 0.5 })
assert(settings ~= nil)
assert(decodeSettings({ volume = 5 }) == nil)

-- Step 2: the proxy has no raw fields, so writes reach __newindex.
local view = setmetatable({} :: Settings, {
	__index = settings,
	__newindex = function()
		error("settings view is read-only")
	end,
})
assert(view.volume == 0.5)

-- Step 3: a rejected write does not mutate the backing settings table.
local writeSucceeded = pcall(function()
	view.volume = 1
end)
assert(not writeSucceeded)
assert(settings.volume == 0.5)

print("Stage 7 lesson passed")
```
<!-- END VERIFIED LESSON: STAGE_07_RUNTIME_PROXY_CONTRACT.luau -->

### Walk through the behavior

Finish this example and **Try it** before reading further. Everything after the guided lesson is reference material.

1. `decodeSettings()` accepts `unknown` and returns a fresh trusted record only after runtime checks.
2. The proxy has no raw fields, so reads fall through `__index` and writes reach `__newindex`.
3. `pcall()` proves the rejected write leaves backing data unchanged.

- **Expected result:** the program prints `Stage 7 lesson passed`.
- **Try it:** add a `brightness` field limited to `0..1` and reject a missing field.
- **Common mistake:** treating a static type or cast as runtime validation.

## Static types and runtime admission

`--!strict` checks source relationships. It cannot prove that a remote payload, decoded JSON value, DataStore record, plugin input, or dynamically loaded configuration matches the annotation.

Validate dynamic values before using them:

1. container/type shape;
2. required fields;
3. number finiteness and range;
4. string length and allowed values;
5. semantic permission and current state where applicable.

Return a fresh internal record when caller-owned tables should not remain mutable aliases.

## Proxy behavior

A write guard normally uses a separate proxy whose raw table stays empty. If a raw key already exists, assignment updates it directly and bypasses `__newindex`.

Alternatives include:

- return a copy for a snapshot;
- `table.freeze()` for shallow immutability;
- closures that expose only named operations;
- a proxy when dynamic observation or recursive views justify it.

No same-VM table technique is a hostile-code security sandbox.

## Preconditions and invariants

`assert()` is useful for programmer errors and impossible internal states. Expected user/input rejection usually needs an ordinary result that callers can handle without crashing the flow.

```lua
local function divide(total: number, count: number): (number?, string?)
	if count == 0 then
		return nil, "count must be nonzero"
	end
	return total / count, nil
end
```

## Capability-shaped APIs

Giving a caller only `read()` is safer against accidental mutation than handing it the entire service table. This reduces coupling; it does not protect against fully hostile code running with the same environment capabilities.

## Serialization

Transfer plain serializable data. Functions, connections, Instances, threads, and metatable behavior do not become portable data contracts.

## Practice

Validate one settings record from `unknown`, return a fresh admitted record, expose a read-only view, and test nil, wrong type, NaN, infinity, out-of-range numbers, and a rejected write.

## Completion evidence

- distinguish static checking from runtime validation;
- explain why `__newindex` misses existing raw keys;
- choose copy, freeze, closure, or proxy by required semantics;
- represent expected rejection without pretending it is an impossible invariant;
- keep serialized state separate from runtime behavior.

## Primary references

- [Luau type checking](https://luau.org/typecheck)
- [Luau standard library](https://luau.org/library/)
- [Roblox client-server security](https://create.roblox.com/docs/scripting/security/client-server-boundary)
