# Stage 5: Typed Luau Architecture and Static Contracts

Typed Luau is not just a bug-catching layer. At mastery level, it becomes an architecture language. It describes what systems may know, what data may cross boundaries, what services expose, what components contain, what messages carry, and what states are legal.

Runtime contracts protect live boundaries. Static contracts shape the code before it runs.

Core policy:

> Types are architecture. Every important boundary should be visible in Luau's type system before it is enforced at runtime.

## 1. Strict Mode Discipline

`--!strict` makes Luau hold modules to a higher standard.

Apply it by making shared framework modules strict by default:

- component types
- service APIs
- network schemas
- config modules
- ECS world interfaces
- scheduler contracts
- prompt actions
- weapon contracts

Used for:

- safer refactors
- clearer APIs
- fewer nil mistakes
- stronger module contracts
- code review clarity

Practice:

Convert a small service module to `--!strict`. Add explicit parameter and return types until the checker understands the public API.

Mastery rule:

Shared architecture code should be strict first. Feature code should move toward strict as contracts stabilize.

## 2. Structural Typing

Luau uses structural typing: if a value has the right shape, it can satisfy a type.

Apply it by defining behavior contracts by method shape rather than class inheritance.

Used for:

- prompt actions
- weapon fire modes
- hit resolvers
- vehicle strategies
- permission checks
- effects
- adapters

Practice:

Define:

```lua
export type PromptAction = {
	execute: (self: PromptAction, context: InteractionContext) -> ActionResult,
}
```

Then implement three different modules that satisfy the shape without inheriting from a base class.

Mastery rule:

Use structural typing to make composition natural.

## 3. Generic Modules

Generics let one module preserve type information for many data shapes.

Apply it to reusable containers:

- registries
- stores
- signals
- result types
- object pools
- queues
- caches
- resource owners

Used for:

- ECS component stores
- typed registries
- scheduler queues
- network message catalogs
- config resolvers
- object pools

Practice:

Build a generic registry:

```lua
export type Registry<T> = {
	register: (self: Registry<T>, id: string, value: T) -> (),
	get: (self: Registry<T>, id: string) -> T?,
	require: (self: Registry<T>, id: string) -> T,
}
```

Use it for both `PromptAction` and `FireMode`.

Mastery rule:

When a pattern repeats with different value types, make the container generic before duplicating it.

## 4. Branded Ids

Plain strings and numbers are easy to mix up. Branded ids make intent explicit.

Apply it by defining separate id types:

```lua
export type EntityId = number & {__brand: "EntityId"}
export type WeaponId = string & {__brand: "WeaponId"}
export type PromptId = string & {__brand: "PromptId"}
export type MatchId = string & {__brand: "MatchId"}
```

Used for:

- entities
- players
- weapons
- attachments
- prompts
- inventory items
- matches
- transactions
- rollback frames

Practice:

Create branded `EntityId`, `WeaponId`, and `ItemId` types. Then prevent a function expecting `WeaponId` from accepting `ItemId`.

Mastery rule:

If two ids have different meanings, give them different types.

## 5. Network Schemas

Network schemas define message names, directions, payloads, and validation.

Apply it by pairing static types with runtime validators.

Used for:

- RemoteEvent payloads
- buffer layouts
- request/response ids
- replication deltas
- prediction inputs
- rollback frame commands

Practice:

Define:

```lua
export type FireRequested = {
	weaponEntityId: EntityId,
	sequence: number,
	clientTick: number,
	origin: Vector3,
	direction: Vector3,
}
```

Then create a runtime validator with the same field expectations.

Mastery rule:

Network types describe what honest code sends. Runtime validators decide what hostile code is allowed to send.

## 6. Service Contracts

Service contracts separate public API from private implementation.

Apply it by exporting a service type that callers use, while implementation details remain local.

Used for:

- damage services
- prompt services
- inventory services
- weapon services
- vehicle services
- networking
- scheduler services
- ECS worlds

Practice:

Define a `PromptService` public type with only:

- `registerPrompt`
- `unregisterPrompt`
- `requestInteraction`
- `getPromptView`

Keep internal session maps and Roblox adapters private.

Mastery rule:

Callers should depend on the smallest public service type that lets them do their job.

## 7. Type-Safe Configuration

Configs are long-lived contracts. They should be typed.

Apply it by defining one exported config type per feature domain.

Used for:

- weapons
- attachments
- prompts
- abilities
- vehicles
- enemies
- quests
- shops
- economy

Practice:

Create a typed weapon config:

```lua
export type WeaponConfig = {
	id: WeaponId,
	displayName: string,
	fireModeId: string,
	damage: number,
	fireInterval: number,
	magazineSize: number,
	reloadDuration: number,
}
```

Then validate every config record at load time.

Mastery rule:

Config is code-adjacent data. Treat it like an API.

## 8. Result Types

Result types make success and failure explicit.

Apply them instead of returning ambiguous `nil`, strings, or thrown errors for expected failures.

Used for:

- validation
- transactions
- prompt interactions
- purchases
- weapon firing
- reload attempts
- inventory changes
- matchmaking
- datastore operations

Practice:

Define:

```lua
export type Result<T, E> =
	{ok: true, value: T}
	| {ok: false, error: E}
```

Use it for `tryFireWeapon`, where failure may be `NoAmmo`, `Cooldown`, `NotEquipped`, or `InvalidOwner`.

Mastery rule:

Expected failure should be typed, not guessed.

## 9. Type Narrowing and Discriminated Unions

Discriminated unions model legal variants with a tag field.

Apply it to state machines and message variants.

Used for:

- weapon states
- reload states
- prompt sessions
- match lifecycle
- transaction states
- vehicle occupancy
- network messages
- async operations

Practice:

Define:

```lua
export type ReloadState =
	{kind: "Idle"}
	| {kind: "Reloading", startedAt: number, endsAt: number}
	| {kind: "Cancelled", reason: string}
```

Then write code that handles every variant explicitly.

Mastery rule:

If a state has modes, model the modes directly.

## 10. Type-Driven Refactors

Type-driven refactoring means moving architecture safely because the checker reveals all affected boundaries.

Apply it when splitting managers into services, extracting contracts, or converting feature-name conditionals into polymorphic modules.

Used for:

- ECS migration
- gunkit rewrites
- prompt framework extraction
- vehicle service separation
- network schema changes
- rollback additions
- config consolidation

Practice:

Take one loosely typed module and extract:

- public service type
- config type
- message type
- result type
- state union

Then refactor until all callers compile against the new surfaces.

Mastery rule:

Good types make large refactors mechanical instead of archaeological.

## Compatibility With ECS

Typed Luau makes ECS safer and more inspectable.

ECS provides:

```text
Entity ids
Components
Systems
Queries
Mutation pipelines
Snapshots
```

Types provide:

```text
Component schemas
Branded ids
System read/write declarations
Typed queries
Snapshot shapes
Mutation request/result types
```

The correct relationship:

- component data has exported types
- entity ids are branded
- queries return typed views where practical
- mutation requests and results are typed
- snapshots have serializable types
- component registries validate static and runtime shape

Policy:

> ECS state should be plain data, but never vague data.

## Compatibility With OOP

Typed Luau keeps OOP boundaries honest.

OOP provides:

```text
Services
Controllers
Adapters
Runtime objects
Polymorphic contracts
Lifecycle
```

Types provide:

```text
Public service APIs
Constructor dependency shapes
Interface contracts
Lifecycle state unions
Cleanup ownership contracts
Adapter boundaries
```

The correct relationship:

- services export narrow public types
- constructors accept typed dependency contexts
- polymorphic objects satisfy structural contracts
- private fields stay private to the module where possible
- runtime objects are not confused with serializable state

Policy:

> Objects can vary internally. Their public contracts must stay explicit.

## Compatibility With Scheduling

Typed Luau turns time-based behavior into explicit contracts.

Scheduling provides:

```text
Operations
Ticks
Queues
Tasks
Timeouts
Cooldowns
Backpressure
```

Types provide:

```text
Operation state unions
Tick ids
Queue item types
Timeout result types
Cooldown state
Scheduler phase names
Job contracts
```

The correct relationship:

- async operations return typed results
- cancellation has typed reasons
- queues only accept declared item types
- scheduler phases are typed constants/unions
- fake clocks satisfy the same clock contract as real clocks

Policy:

> If timing behavior matters, type the operation state and result.

## Compatibility With Runtime Contracts

Static and runtime contracts should pair together.

Static types provide:

```text
Author intent
Editor feedback
Refactor safety
API documentation
```

Runtime contracts provide:

```text
Boundary protection
Exploit resistance
Config admission
Datastore migration safety
Buffer decode safety
```

The correct relationship:

- every important runtime validator should have a matching exported type
- every network schema should have both a type and validator
- every dynamic config should have both type and admission check
- hot paths may use lighter runtime checks after strong admission

Policy:

> Static types are not security. Runtime contracts are not architecture documentation. Use both.

## For Gunkits

Apply typed Luau to:

- weapon config
- ammo state
- reload state
- fire command messages
- fire result types
- attachment contracts
- fire mode contracts
- hit resolver contracts
- recoil/spread model contracts
- damage transaction results
- client prediction state
- rollback input records

Strong design:

```text
WeaponConfig defines design data
WeaponState defines runtime data
FireCommand defines client intent
FireResult defines accepted/rejected output
FireMode defines polymorphic behavior
HitResolver defines impact behavior
DamageTransaction defines server authority result
```

## For Prompt Systems

Apply typed Luau to:

- prompt config
- prompt state
- interaction request messages
- interaction result types
- prompt action contracts
- permission check contracts
- cooldown state
- session state unions
- read-only prompt views

Strong design:

```text
PromptConfig defines interaction identity
PromptState defines runtime state
InteractionRequest defines client intent
InteractionResult defines outcome
PromptAction defines behavior
PermissionCheck defines authority rule
SessionState defines lifecycle mode
```

## For Vehicles

Apply typed Luau to:

- vehicle config
- occupant state
- input command records
- suspension config
- suspension strategy contracts
- replication snapshot types
- authority handoff messages
- correction result types
- debug telemetry records

Policy:

Vehicle systems should not pass untyped blobs between physics, input, networking, and presentation.

## The Indefinite Framework

Your long-term Roblox framework should include:

```text
Types
Ids
Result
Registry<T>
Readonly<T>
ServiceContract
NetworkSchema<T>
ConfigSchema<T>
ComponentSchema<T>
OperationState
SchedulerPhase
SerializableSnapshot
```

Each piece has a permanent role:

- `Types` centralizes shared primitives without becoming a dumping ground.
- `Ids` defines branded identity types.
- `Result` standardizes expected success/failure.
- `Registry<T>` stores typed extension points.
- `Readonly<T>` documents inspect-only views.
- `ServiceContract` defines public APIs.
- `NetworkSchema<T>` pairs message type and validator.
- `ConfigSchema<T>` pairs config type and admission check.
- `ComponentSchema<T>` pairs ECS component type and runtime guard.
- `OperationState` models async lifecycle.
- `SchedulerPhase` constrains execution phases.
- `SerializableSnapshot` prevents behavior from entering snapshots.

## How To Master It

Practice in this order:

1. Convert one utility module to `--!strict`.
2. Export a public type from a service.
3. Type a component.
4. Type a config.
5. Type a network message.
6. Add a runtime validator matching that network type.
7. Define branded ids.
8. Replace string failure returns with a `Result` type.
9. Replace mode booleans with a discriminated union.
10. Build a generic registry.
11. Type a prompt action contract.
12. Type a weapon fire mode contract.
13. Type a scheduler operation state.
14. Refactor one manager into typed service/config/message/result boundaries.
15. Use type errors as the guide until the architecture compiles cleanly.

The best first real project is a typed prompt action registry. Then apply the same model to weapon fire modes, network schemas, vehicle strategies, ECS component registries, and rollback input records.

## Permanent Policy

Use this rule for every future Roblox system:

> If a concept matters to architecture, authority, networking, persistence, scheduling, or extension, give it a type.

The true mastery is combining the first five stages:

- ECS defines authoritative data.
- OOP defines ownership and polymorphic behavior.
- Scheduling defines when work happens.
- Runtime contracts protect boundaries.
- Static types make those boundaries visible before runtime.

When these five agree, your systems become easier to extend, safer to refactor, harder to exploit, and much closer to framework-grade Roblox engineering.
