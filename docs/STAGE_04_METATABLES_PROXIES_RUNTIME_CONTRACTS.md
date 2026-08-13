# Stage 4: Metatables, Proxies, and Runtime Validation

Metatables change table operations. Proxies and validators can protect or observe an API boundary, but they are not prerequisites for clean architecture and do not create a security sandbox by themselves.

Read [Curriculum Accuracy Standard](CURRICULUM_ACCURACY_STANDARD.md) before this stage.

## Metatable facts

Common metamethods include `__index`, `__newindex`, `__call`, `__tostring`, arithmetic/comparison methods, and iteration-related behavior supported by Luau.

Critical correction:

> `__newindex` runs when an assignment does not resolve to an existing raw key. It does not reliably guard writes to keys already stored on the same table.

Therefore a write-guard generally uses an empty proxy and separate backing storage:

```lua
local backing = { damage = 25 }
local proxy = setmetatable({}, {
	__index = backing,
	__newindex = function(_, key, _value)
		error(`cannot modify config key {tostring(key)}`, 2)
	end,
	__iter = function()
		return next, backing
	end,
})
```

The exact iteration and length behavior of a proxy must be tested. A proxy is not automatically transparent to every table operation or library function.

## Freeze, copy, or proxy

Choose according to the contract:

- `table.freeze` prevents direct mutation of that table but is shallow; referenced nested tables remain independently mutable unless also frozen.
- a copied snapshot prevents the caller from mutating the original but can be stale and allocates;
- a proxy can present a live view and instrument access but adds indirection and semantic edge cases;
- a narrow query function can expose only the values callers need.

Static “readonly” types improve checking but do not freeze runtime data.

## Runtime validation

Runtime validation is required where static types cannot establish trust, including:

- RemoteEvent/RemoteFunction input;
- decoded buffers and compressed input;
- DataStore records and migrations;
- plugin or data-authored configuration;
- external HTTP/Open Cloud data;
- dynamically registered callbacks or behavior objects.

Validation should cover shape and semantics. For a vector, `typeof(value) == "Vector3"` is not enough if NaN, infinity, magnitude, range, or world context matters.

Validate expensive/deep inputs with explicit size and depth limits before recursive work. Do not expose internal error details to hostile callers.

## Preconditions, invariants, and expected failure

- Assert a precondition when a programmer violated an API contract.
- Return a structured result when a gameplay or service rejection is expected.
- Log an invariant failure with context and stop unsafe commit work.
- Avoid postconditions in every hot call unless the evidence justifies their cost.

Runtime assertions detect failures; they do not prove the design correct.

## Capability-shaped APIs

Passing a smaller table of functions can reduce accidental coupling:

```lua
type HealthWriter = {
	applyDamage: (entityId: number, amount: number) -> boolean,
}
```

This is useful as an architecture and testing boundary. It is not a security boundary against code running with the same unrestricted environment: a module may still access globals or other reachable objects. Roblox Script Capabilities and sandboxed containers are separate engine mechanisms with their own current restrictions.

## Sandboxing correction

Do not claim that a metatable proxy, removed global, or limited argument table safely executes hostile user-authored Luau. Same-VM code sandboxing is difficult and depends on what the host exposes. If actual untrusted-code execution is in scope, use documented Roblox sandbox/capability features where available, keep the execution surface minimal, and threat-model escape paths. Otherwise, describe the design as dependency restriction—not a sandbox.

## Serialization and remotes

Metatables and functions are behavior, not portable state. Remote arguments and persisted records have serialization restrictions and do not preserve arbitrary table identity/metatable behavior. Define explicit data records for messages and snapshots.

Avoid using a runtime object as both:

- an owning handle with methods/connections; and
- a payload expected to serialize, replicate, or replay.

## Performance

Metamethod dispatch, proxy allocation, deep validation, and traceback construction have costs. Validate strongly at admission/trust boundaries, then pass a known internal representation through measured hot paths. Do not remove a required hostile-input check for speed; redesign validation to be bounded.

## Practice project

Build and test:

1. a shallow frozen config;
2. a deep-freeze helper with cycle handling;
3. an empty proxy with separate storage;
4. a RemoteEvent payload validator with size/range/NaN checks;
5. a narrow capability API for one feature action.

Demonstrate the existing-key `__newindex` trap and document which operations your proxy does not emulate.

## Completion evidence

You understand this stage when you can:

- explain exactly when `__index` and `__newindex` run;
- choose freeze, copy, proxy, or query functions intentionally;
- distinguish architecture capabilities from security sandboxing;
- pair dynamic input with bounded semantic validation;
- serialize data rather than runtime behavior;
- measure or remove proxy/validation overhead without weakening trust boundaries.

## Primary references

- [Lua 5.1 metatables and metamethods](https://www.lua.org/manual/5.1/manual.html#2.8)
- [Luau standard library](https://luau.org/library/)
- [Roblox remote argument limitations](https://create.roblox.com/docs/scripting/events/remote#argument-limitations)
- [Roblox client-server security](https://create.roblox.com/docs/scripting/security/client-server-boundary)
- [Roblox Script Capabilities](https://create.roblox.com/docs/scripting/capabilities)
