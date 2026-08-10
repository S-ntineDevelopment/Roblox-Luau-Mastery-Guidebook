# Stage 12: Utility Architecture and Engine Foundation

Utilities are dangerous when they become a junk drawer. They are powerful when they become the shared foundation that enforces architecture policy across every system. A mature Roblox/Luau engine needs utilities for ids, results, cleanup, clocks, registries, validation, networking, transactions, diagnostics, and testing, but each utility must have a clear contract and domain.

Core policy:

> Utilities are not shortcuts. They are reusable primitives that encode the engine's rules, reduce repeated mistakes, and make every system easier to validate, test, inspect, and compose.

Engine identity policy:

> S_ngine must be built in the image of the agent policy. The engine exists to enforce architecture behavior: modularity, contracts, authority, lifecycle, validation, observability, and cross-project reuse. A utility or service that does not strengthen those rules does not belong in the engine foundation.

## 0. Agent-Shaped Engine Design

The engine must mirror the agent's decision process.

Apply this by making every module answer:

- What boundary does this protect?
- What contract does this expose?
- What dependency direction does this enforce?
- What system policy does this encode?
- What lifecycle does this own?
- What can inspect or test it?
- What project can reuse it without bringing unrelated systems?

Used for:

- preventing utility sprawl
- preventing circular dependencies
- keeping modules reusable
- making the engine teach correct behavior
- avoiding "framework soup"

Practice:

Before accepting any utility into the engine, write a one-paragraph admission note:

```text
This module belongs in S_ngine because it enforces <policy>, exposes <contract>, depends only on <allowed layer>, and is reusable by <domains>.
```

Mastery rule:

If a module cannot justify its place in the engine, it stays in the feature until the pattern is proven.

## 1. Utility Ownership and Taxonomy

Utilities need categories so unrelated helpers do not pile into one folder.

Apply a taxonomy:

- core primitives
- lifecycle utilities
- data utilities
- validation utilities
- networking utilities
- scheduler utilities
- diagnostics utilities
- testing utilities
- Roblox adapters
- domain-specific utilities

Used for:

- engine structure
- source navigation
- reuse
- audits
- preventing helper sprawl

Practice:

Take 20 existing utility ideas and place each into one taxonomy category. If one utility fits everywhere, split it.

Mastery rule:

A utility with no owner or category becomes technical debt.

## Dependency Direction

The engine must have one-way dependency flow.

Default direction:

```text
Core
  -> Contracts
  -> Validation
  -> Lifecycle
  -> Scheduling
  -> Diagnostics
  -> Networking/Persistence/RobloxAdapters
  -> Domain Platforms
  -> Feature Packages
```

Rules:

- Core cannot depend on Roblox services.
- Types cannot depend on runtime services.
- Validators cannot mutate state.
- Diagnostics can observe but should not own gameplay decisions.
- Domain platforms can depend on core engine utilities.
- Utilities cannot depend on domain platforms.
- Feature packages depend on platform contracts, not concrete internals.
- Compatibility layers hide volatile providers behind stable contracts.

Mastery rule:

If two modules need each other, the boundary is wrong. Extract a smaller contract or move behavior to the correct layer.

## 2. Core Primitives

Core primitives are tiny, stable modules used everywhere.

Apply them for:

- branded ids
- result types
- option/maybe values
- readonly views
- array/dictionary helpers
- enum helpers
- assertions
- string/path helpers

Used for:

- ECS
- networking
- transactions
- configs
- registries
- diagnostics

Practice:

Create `Result`, `Ids`, and `Readonly` modules. Use them in one gunkit transaction and one prompt action.

Mastery rule:

Core primitives must stay small, typed, and boring.

## 3. Lifecycle Utilities

Lifecycle utilities own cleanup and destruction.

Apply them with:

- cleaner/maid/janitor
- task owner
- operation handle
- disposable interface
- object pool
- lifecycle state guard

Used for:

- weapons
- prompts
- vehicles
- UI
- NPCs
- sessions
- effects

Practice:

Build a `Cleaner` utility that accepts connections, Instances, functions, and nested cleaners. Use it in a weapon runtime and prompt adapter.

Mastery rule:

If a system creates something, a lifecycle utility should be able to prove who cleans it.

## 4. Registry Utilities

Registries make extension points controlled.

Apply generic registries for:

- components
- systems
- fire modes
- hit resolvers
- prompt actions
- permission checks
- vehicle strategies
- effect handlers
- network schemas

Used for:

- domain platforms
- plugin-grade extensibility
- validation
- tooling

Practice:

Create a generic typed registry with duplicate rejection, required lookup, optional lookup, and debug listing.

Mastery rule:

Extension should happen through registries, not by editing central conditionals.

Foundational manager rule:

Agnostic managers and services must execute cataloged behavior through typed registries. They own lifecycle, validation, scheduling, dispatch, cleanup, diagnostics, and compatibility boundaries; feature packages register identity, config, rules, strategies, adapters, permissions, and effects. If a generic service starts branching on feature names, the missing abstraction is a catalog entry, contract, rule, adapter, or domain platform.

## 5. Validation Utilities

Validation utilities admit data into the engine.

Apply validators for:

- remote payloads
- buffer decodes
- configs
- datastore records
- command records
- transactions
- extension registrations

Used for:

- security
- configs
- networking
- persistence
- anti-cheat

Practice:

Build composable validators: `numberInRange`, `stringId`, `vectorFinite`, `arrayOf`, `record`, and `literal`.

Mastery rule:

Every untrusted boundary should use shared validation vocabulary.

## 6. Scheduler and Time Utilities

Time utilities prevent timing bugs.

Apply:

- clock interface
- fake clock
- fixed tick loop
- cooldown gate
- throttle
- debounce
- timeout
- queue/backpressure

Used for:

- weapons
- rollback
- prompts
- vehicles
- networking
- persistence saves
- testing

Practice:

Build `Clock`, `FakeClock`, `Cooldown`, and `FixedTickLoop`. Test a reload without waiting for real time.

Mastery rule:

Time-dependent systems should depend on clock utilities, not raw `os.clock` or scattered waits.

## 7. Network Utility Layer

Network utilities hide raw remotes behind protocol contracts.

Apply:

- schema registry
- remote adapter
- rate limiter
- sequence tracker
- payload size estimator
- buffer codec
- rejection response helper

Used for:

- gunkits
- prompts
- vehicles
- prediction
- anti-cheat
- replication

Practice:

Wrap one RemoteEvent so callers can only send registered message schemas.

Mastery rule:

No feature code should talk to a raw RemoteEvent directly.

## 8. Diagnostics and Debug Utilities

Diagnostics utilities make behavior explainable.

Apply:

- structured logger
- counters
- timers
- rolling logs
- debug command registry
- health report builder
- rejection reason formatter
- snapshot dumper

Used for:

- combat
- persistence
- networking
- prompts
- vehicles
- rollback
- anti-cheat

Practice:

Create a `Trace` utility that records event name, tick, entity id, player id, duration, and result.

Mastery rule:

Debug output should be structured enough for tools, not just humans.

## 9. Test and Fuzz Utilities

Testing utilities make architecture enforceable.

Apply:

- fake clock
- fake player
- fake remote
- fake datastore
- test world
- command replay harness
- fuzz input generator
- golden fixture loader

Used for:

- transactions
- remotes
- validators
- gunkits
- prompts
- vehicles
- rollback

Practice:

Build a fuzz utility that generates invalid fire commands and proves the validator rejects all of them without mutation.

Mastery rule:

Every risky boundary deserves a reusable test utility.

## 10. Roblox Adapter Utilities

Adapter utilities isolate engine APIs.

Apply adapters for:

- Instance lookup
- CollectionService tags
- Attributes
- ProximityPrompts
- Tools
- character models
- Remotes
- RunService phases
- physics ownership

Used for:

- streaming safety
- testing
- portability
- engine boundary control

Practice:

Build a `ToolAdapter` that exposes equip/unequip signals and cleanup without letting weapon services depend on raw Tool events.

Mastery rule:

Roblox APIs belong at boundaries, not scattered through domain logic.

## 11. Compatibility Layers

Compatibility layers are adapters that let domain systems depend on stable engine contracts instead of unstable implementation details.

Apply compatibility layers around anything likely to change, vary by environment, require testing, or expose platform-specific behavior:

- networking
- caching
- persistence
- Roblox Instances
- CollectionService
- Attributes
- RunService
- physics ownership
- DataStore/ProfileService
- MemoryStore
- analytics
- logging
- feature flags
- platform services

Used for:

- swapping implementations
- testing without Roblox services
- isolating engine APIs
- versioning protocols
- local development
- migration
- mocking failure cases
- preventing vendor/tool lock-in

Practice:

Create a `CacheStore` compatibility contract with `get`, `set`, `remove`, and `flush`. Implement one in-memory version for tests and one Roblox-backed version for runtime.

Mastery rule:

If a system depends directly on a volatile platform API, it inherits that API's limitations everywhere.

Compatibility layers are not cross-dependency excuses.

Bad design:

```text
CombatService depends on NetworkService internals
NetworkService depends on CombatService result shapes
Cache depends on ProfileService concrete tables
ProfileService depends on UI state
```

Good design:

```text
CombatService emits typed CombatResult
CombatNetworkAdapter translates CombatResult into protocol messages
CacheStore implements a generic cache contract
ProfileRepository owns durable records behind a repository contract
UI consumes client mirror views
```

Mastery rule:

Compatibility layers should reduce coupling. If they increase coupling, they are just wrappers around a bad boundary.

## 12. Networking Compatibility Layers

Networking compatibility layers prevent raw remotes from leaking through gameplay code.

Apply:

- `NetworkChannel`
- `RemoteAdapter`
- `SchemaRegistry`
- `RateLimiter`
- `BufferCodec`
- `ProtocolVersionAdapter`
- `ReplicationAdapter`

Used for:

- changing RemoteEvent layout
- moving from table payloads to buffers
- supporting protocol versions
- fuzz testing remotes
- recording network telemetry
- rate limiting uniformly
- mocking networking in tests

Practice:

Write gameplay code against `CombatNetwork.sendFireResult(player, result)` instead of `RemoteEvent:FireClient`. Then implement that method with schema validation and logging.

Mastery rule:

Raw RemoteEvents are transport. Gameplay should depend on protocol contracts.

## 13. Caching Compatibility Layers

Caching compatibility layers hide how short-lived data is stored and invalidated.

Apply:

- in-memory cache
- TTL cache
- per-player cache
- entity cache
- replicated client cache
- MemoryStore-backed cache
- read-through cache
- write-through cache

Used for:

- config lookup
- profile views
- inventory summaries
- visibility results
- expensive queries
- network interest sets
- anti-cheat baselines
- matchmaking/session data

Practice:

Create a `VisibilityCache` that caches line-of-sight results for a short tick window. The combat validator should depend on the cache contract, not its storage table.

Mastery rule:

Caching is a correctness boundary, not only a speed trick. Every cache needs invalidation, ownership, and freshness rules.

## 14. Persistence Compatibility Layers

Persistence compatibility layers isolate durable storage providers.

Apply:

- profile adapter
- datastore adapter
- memory/fake persistence for tests
- migration runner
- transaction store
- ledger writer
- save scheduler

Used for:

- testing transactions
- switching persistence libraries
- dry-run migrations
- recovery tooling
- write-budget handling
- failure injection

Practice:

Make `ProfileRepository` expose `load`, `save`, `release`, and `withTransaction`. Back it with a fake repository in tests and a real implementation in production.

Mastery rule:

Domain systems should not know which persistence provider stores their durable records.

## 15. Runtime Environment Compatibility Layers

Runtime environment layers keep server, client, Studio, test, and command-line behavior separate.

Apply:

- environment detector
- service locator/context
- fake RunService
- fake Players
- fake Remotes
- fake clock
- server/client boundary adapters

Used for:

- unit tests
- Studio plugins
- local tools
- server-only services
- client-only presentation
- shared modules

Practice:

Build an `EngineContext` that supplies `clock`, `scheduler`, `network`, `diagnostics`, and `isServer`. Use a fake context for tests.

Mastery rule:

Environment checks should be centralized. Do not scatter `RunService:IsServer()` through domain logic.

## Compatibility With ECS

Utilities should make ECS smaller, not blurrier.

Policy:

> ECS utilities provide ids, component registries, queries, mutation helpers, snapshots, and debug dumps. They must not hide behavior inside components.

## Compatibility With OOP

Utilities support OOP lifecycles and contracts.

Policy:

> OOP utilities provide cleaners, constructors, dependency contexts, registries, adapters, and capability views. They must not become giant base classes.

## Compatibility With Scheduling

Utilities standardize time.

Policy:

> Scheduling utilities own clocks, ticks, queues, cooldowns, and operation handles. Raw waits are not architecture.

## Compatibility With Runtime Contracts

Utilities provide validation vocabulary.

Policy:

> Validators, assertions, proxies, and capability factories are shared utilities so every boundary fails consistently.

## Compatibility With Typed Luau

Utilities must be typed first.

Policy:

> If a utility is reused across systems, its public API must be exported and strict.

## Compatibility With Networking

Networking utilities enforce protocol safety.

Policy:

> Remote adapters, schema registries, rate limiters, and codecs are engine utilities, not per-feature inventions.

Compatibility-layer rule:

> Gameplay depends on `NetworkChannel` contracts. Transport details, RemoteEvent names, buffer layouts, telemetry, rate limiting, and protocol migration stay behind the network layer.

## Compatibility With Persistence

Persistence utilities protect durable state.

Policy:

> Transaction ids, ledgers, schema versions, migrations, and save queues should be reusable primitives.

Compatibility-layer rule:

> Domain systems submit typed transactions. Persistence providers, save queues, retry policy, and ledger storage stay behind repository/transaction layers.

## Compatibility With Caching

Caching utilities protect performance without leaking storage details.

Policy:

> Caches must have ownership, invalidation, TTL/freshness rules, debug visibility, and test doubles.

Compatibility-layer rule:

> Domain systems depend on cache contracts. Cache storage, invalidation strategy, and backing provider stay behind the cache layer.

## For Gunkits

Required utility foundation:

```text
WeaponId
Result
Cleaner
Clock
Cooldown
Registry
Validator
RemoteAdapter
RateLimiter
Trace
Fuzz
ToolAdapter
```

Policy:

Gunkit code should compose engine utilities. It should not invent a new cleaner, validator, cooldown, remote wrapper, or registry per weapon system.

## For Prompt Systems

Required utility foundation:

```text
PromptId
InteractionContext
Cleaner
Cooldown
PermissionRegistry
ActionRegistry
Validator
PromptAdapter
Trace
TransactionResult
```

Policy:

Prompt systems should use the same lifecycle, validation, registry, diagnostics, and transaction utilities as gunkits.

## For Vehicles

Required utility foundation:

```text
VehicleId
Clock
FixedTickLoop
Cleaner
InputCommand
StrategyRegistry
RemoteAdapter
PhysicsOwnershipAdapter
TelemetryTrace
CorrectionResult
```

Policy:

Vehicle systems should reuse timing, networking, validation, lifecycle, and diagnostics utilities rather than becoming isolated controllers.

## The Indefinite Framework

Your long-term Roblox framework should include utility packages for:

```text
Core
Ids
Result
Readonly
Cleaner
Clock
Scheduler
Registry
Validator
Network
Diagnostics
Testing
RobloxAdapters
Persistence
Compatibility
Caching
```

Preferred source shape:

```text
src/Shared/Engine/Core
src/Shared/Engine/Contracts
src/Shared/Engine/Validation
src/Shared/Engine/Lifecycle
src/Shared/Engine/Scheduling
src/Shared/Engine/Diagnostics
src/Shared/Engine/Networking
src/Shared/Engine/Persistence
src/Shared/Engine/Caching
src/Shared/Engine/RobloxAdapters
src/Shared/Engine/Platforms
```

Admission rule:

Do not create a new top-level utility namespace until the category has at least two reusable modules or one module that clearly protects a critical boundary.

## How To Master It

Practice in this order:

1. Inventory every current utility.
2. Categorize each utility by ownership.
3. Delete or quarantine vague helpers.
4. Type all public utility APIs.
5. Build `Result`, `Ids`, and `Cleaner`.
6. Build `Clock`, `Cooldown`, and `FixedTickLoop`.
7. Build generic `Registry`.
8. Build composable validators.
9. Build `RemoteAdapter`.
10. Build structured `Trace`.
11. Build a cache compatibility contract.
12. Build a persistence compatibility contract.
13. Build fake utilities for tests.
14. Convert one gunkit path to shared utilities.
15. Convert one prompt path to shared utilities.
16. Convert one vehicle path to shared utilities.
17. Promote stable utilities into the engine template.

## Permanent Policy

Use this rule for every future Roblox system:

> If a helper is useful twice, type it, categorize it, test it, document its contract, and promote it into the engine foundation.

Engine-shape rule:

> S_ngine is not a dependency bucket. It is the executable form of the agent policy. Every module must make systems more modular, more testable, more inspectable, more authoritative, or easier to reuse across projects.
