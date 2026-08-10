# Stage 4: Metatables, Proxies, and Runtime Contracts

Metatables and runtime contracts are where Lua becomes much more than "tables and functions." Used carefully, they let you build controlled APIs, immutable views, guarded state, reactive data, service boundaries, debug instrumentation, sandboxed capabilities, and safe extension points.

Used carelessly, they create invisible behavior that is hard to debug.

Core policy:

> Metatables are for boundaries, contracts, instrumentation, and controlled behavior. They must not hide authoritative state mutation or make system behavior mysterious.

## 1. `__index` and `__newindex`

`__index` controls fallback reads. `__newindex` controls writes to missing keys.

Apply it by using `__index` for class-style methods, read-through proxies, lazy lookup, and API surfaces. Use `__newindex` for write guards or controlled mutation.

Used for:

- metatable classes
- read-only config views
- state write guards
- adapter APIs
- lazy-loaded services
- debug tracing

Practice:

Create a read-only config proxy. Reads work normally, but writes throw a clear error with the config name and key.

Mastery rule:

Use metatables to make invalid access obvious, not to make valid behavior invisible.

## 2. Proxy Tables

A proxy table stands between callers and real data.

Apply it by exposing a safe view over internal state instead of returning the real table.

Used for:

- read-only state inspection
- restricted service APIs
- debug views
- immutable config
- controlled component access
- client-safe mirrors

Practice:

Create `world:getReadonlyComponent(entityId, "Health")` that returns a proxy. Reading works. Writing fails. The real component can only be changed through `world:patchComponent`.

Mastery rule:

If callers should inspect but not mutate, return a proxy or copied snapshot, not the live table.

## 3. Runtime Type Guards

Runtime type guards validate data at trust boundaries.

Apply it by checking untrusted payloads, configs, plugin inputs, datastore records, and dynamic module results.

Used for:

- RemoteEvent payloads
- config loading
- datastore migration
- command validation
- rollback input decode
- buffer decode
- plugin/module extension points

Practice:

Write a validator for:

```lua
export type FireCommand = {
	weaponEntityId: number,
	sequence: number,
	clientTick: number,
	origin: Vector3,
	direction: Vector3,
}
```

Reject missing fields, invalid numbers, wrong Vector3 values, negative sequences, and impossible direction magnitudes.

Mastery rule:

Static types help the author. Runtime guards protect boundaries.

## 4. Contract Assertions

Contract assertions enforce preconditions, postconditions, and invariants.

Apply it to framework internals where misuse means the architecture boundary was violated.

Used for:

- system registration
- component registration
- lifecycle state transitions
- service construction
- transaction boundaries
- scheduler phase ordering

Practice:

Make `SystemRegistry:register(system)` assert that every system has:

- unique name
- phase
- priority
- update function
- declared read/write component sets

Mastery rule:

Framework misuse should fail early with precise errors.

## 5. API Capability Tokens

Capability tokens restrict what a caller is allowed to do.

Apply it by giving systems limited access instead of the entire world/service.

Used for:

- ECS mutation authority
- admin tooling
- plugin APIs
- client-safe service views
- test harnesses
- debug tools

Practice:

Give read systems a `WorldRead` capability and mutation systems a `WorldWrite` capability. A presentation system should not be able to call mutation methods.

Mastery rule:

Do not pass a powerful object where a limited capability would do.

## 6. Sandboxed Environments

Sandboxing means running extension logic with limited access.

Apply it when accepting feature-authored callbacks, plugin-like modules, generated behavior, or user-authored logic.

Used for:

- ability scripts
- item effects
- admin/plugin tooling
- generated minigame behavior
- content pipeline validation
- safe extension points

Practice:

Create an effect runner that receives only:

- context
- math helpers
- read-only config
- allowed effect API

It should not receive direct access to DataStore, Remotes, Players, or the full ECS world.

Mastery rule:

Extension code should receive capabilities, not the whole game.

## 7. Reactive Tables

Reactive tables detect changes and notify listeners.

Apply them cautiously for presentation, debug tools, and client mirrors. Avoid reactive magic in authoritative hot paths unless the behavior is explicit and measurable.

Used for:

- UI state
- debug inspectors
- settings panels
- replicated client mirrors
- tool state
- editor panels

Practice:

Build a reactive client-side ammo view. When `Ammo.current` changes in the client mirror, update the UI. Keep server authority separate.

Mastery rule:

Reactivity is excellent for presentation. Authoritative simulation should prefer explicit mutations and system phases.

## 8. Debug Instrumentation

Metatables can trace reads, writes, slow paths, and contract violations.

Apply it by wrapping selected state during development or debug builds.

Used for:

- finding unauthorized mutations
- tracking component writes
- debugging config access
- detecting stale entity usage
- measuring slow service calls
- network payload tracing

Practice:

Create a debug proxy that logs any write to a component outside the mutation pipeline. Include entity id, component name, key, old value, new value, and callsite if available.

Mastery rule:

Debug instrumentation should explain behavior without changing production semantics.

## 9. Serialization-Safe Objects

Runtime objects with methods, metatables, Instances, and connections are not serialization-safe.

Apply it by separating:

- serializable state
- runtime handles
- adapters
- presentation
- services

Used for:

- datastore saves
- rollback snapshots
- network replication
- replay logs
- debugging exports
- migration tools

Practice:

Create a weapon runtime object and a separate `WeaponState` component. Prove that only `WeaponState` can be serialized, replicated, or snapshotted.

Mastery rule:

Never snapshot behavior. Snapshot data.

## 10. Contract Performance

Runtime contracts have a cost. The skill is knowing where they belong.

Apply strong validation at boundaries and registration time. Use lighter checks in hot paths after data has been admitted.

Used for:

- high-frequency combat
- movement input
- buffer decode
- projectile simulation
- vehicle stepping
- replication
- ECS queries

Practice:

Build two validators for a movement input:

- full validator for RemoteEvent admission
- hot-path validator that assumes decoded field types but checks ranges and sequence order

Measure the difference.

Mastery rule:

Validate heavily at trust boundaries. Keep hot paths predictable and measured.

## Compatibility With ECS

Metatables and runtime contracts protect ECS boundaries.

ECS provides:

```text
World state
Component data
Systems
Queries
Mutation pipeline
Snapshots
```

Contracts provide:

```text
Registered component schemas
Write guards
Read-only views
Mutation authority
Debug tracing
Serialization boundaries
```

The correct relationship:

- Components remain plain typed data.
- The world controls mutation.
- Proxies expose safe read views.
- Runtime guards validate external component data before admission.
- Debug proxies detect illegal writes.
- Snapshots store data, not metatable objects.

Policy:

> ECS state should be simple. ECS access should be controlled.

## Compatibility With OOP

OOP and metatables are naturally connected in Luau, but the boundary matters.

OOP provides:

```text
Services
Adapters
Controllers
Runtime objects
Lifecycle
Methods
```

Runtime contracts provide:

```text
Constructor validation
Interface assertions
Read-only config
Capability-limited APIs
Debug wrappers
Sandboxed extension surfaces
```

The correct relationship:

- Objects validate dependencies at construction.
- Public APIs guard invalid usage.
- Services expose narrow capabilities.
- Adapters prevent raw Roblox APIs from leaking everywhere.
- Runtime objects do not become serialized state.

Policy:

> OOP objects can use metatables. Authoritative data should not depend on hidden metatable behavior.

## Compatibility With Scheduling

Runtime contracts make async safer.

Scheduling provides:

```text
Tasks
Operations
Ticks
Timeouts
Queues
Lifecycle cleanup
```

Contracts provide:

```text
State transition assertions
Cancelled-operation guards
Timeout result contracts
Queue admission checks
Debug traces
```

The correct relationship:

- Async operations expose explicit states.
- Cancelled operations cannot mutate authoritative state.
- Queues validate items before admission.
- Scheduler systems declare reads/writes.
- Debug tools can inspect active operations.

Policy:

> Every delayed mutation must still pass through the same contract as an immediate mutation.

## For Gunkits

Apply runtime contracts to:

- weapon config validation
- ammo mutation guards
- fire command validation
- buffer decode validation
- attachment compatibility
- recoil/spread model interfaces
- hit resolver contracts
- damage transaction invariants
- read-only client weapon views
- illegal state transition detection

Strong design:

```text
FireCommand admitted through runtime guard
WeaponRuntime receives limited weapon capability
Ammo changes through mutation pipeline
HitResolver satisfies a typed contract
Damage transaction asserts server authority
Client receives read-only replicated state
```

## For Prompt Systems

Apply runtime contracts to:

- prompt action registration
- permission check interfaces
- interaction context shape
- prompt config validation
- cooldown guards
- session state assertions
- read-only prompt views
- untrusted client request validation

Strong design:

```text
Client sends InteractionRequested
Server validates schema and authority
PromptService checks registered action contract
PermissionCheck receives limited context
PromptAction executes through capability API
Session state transitions are asserted
```

## For Vehicles

Apply runtime contracts to:

- vehicle config validation
- seat/occupant authority
- input command validation
- suspension strategy interfaces
- physics ownership guards
- replication snapshot schemas
- client presentation views
- server correction payloads

Policy:

Vehicles must not let physics ownership, client input, or presentation objects bypass authoritative contracts.

## The Indefinite Framework

Your long-term Roblox framework should include:

```text
ReadonlyProxy
WriteGuard
SchemaValidator
ContractAssert
CapabilityFactory
DebugProxy
SafeConfig
SerializedSnapshot
InterfaceRegistry
SandboxRunner
```

Each piece has a permanent role:

- `ReadonlyProxy` exposes state safely.
- `WriteGuard` catches illegal mutation.
- `SchemaValidator` admits external data.
- `ContractAssert` catches framework misuse.
- `CapabilityFactory` creates limited APIs.
- `DebugProxy` instruments risky state.
- `SafeConfig` prevents accidental config mutation.
- `SerializedSnapshot` strips behavior from data.
- `InterfaceRegistry` validates polymorphic plugins.
- `SandboxRunner` restricts extension code.

## How To Master It

Practice in this order:

1. Build a metatable class.
2. Build a read-only proxy.
3. Build a write guard.
4. Build a runtime schema validator.
5. Validate a RemoteEvent payload.
6. Validate a feature config.
7. Create a capability-limited service view.
8. Replace full-world access with read/write capabilities.
9. Add debug proxies around ECS components.
10. Create a serialization-safe snapshot.
11. Build an interface registry for prompt actions or weapon fire modes.
12. Build a sandboxed effect runner.
13. Measure validation overhead in a hot path.
14. Split boundary validation from hot-path validation.
15. Convert one real system to use safe config, schemas, read-only views, and capability APIs.

The best first real project is a contract-validated prompt action registry. Then apply the same pattern to weapon fire modes, attachment effects, vehicle strategies, and network payloads.

## Permanent Policy

Use this rule for every future Roblox system:

> If data crosses a boundary, gets configured dynamically, exposes a shared API, or can be mutated by more than one caller, protect it with a runtime contract.

The true mastery is combining the first four stages:

- ECS defines simple authoritative data.
- OOP owns objects, services, and adapters.
- Scheduling controls when work happens.
- Runtime contracts control who may read, write, configure, or execute behavior.

When these four agree, systems become much harder to misuse, easier to inspect, safer to extend, and better prepared for networking, rollback, and large-scale reuse.
