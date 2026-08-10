# Roblox Luau Mastery Curriculum

This project exists to turn advanced Luau and Roblox engineering practice into repeatable policy. The goal is not only to understand these concepts, but to implement them across every system: combat, inventory, UI, economy, world simulation, tools, NPCs, matchmaking, persistence, networking, and editor workflows.

Core policy:

> Every system must separate data, behavior, lifecycle, authority, presentation, contracts, and cleanup. Feature code declares identity and domain behavior; shared architecture owns orchestration, validation, networking, scheduling, rollback, and enforcement.

## Stage 1: ECS and Data-Oriented Architecture

1. Entity identity: stable ids, lifecycle ownership, despawn semantics, and cross-system references.
2. Component schema design: small typed data records with no hidden behavior.
3. System execution order: deterministic update phases instead of incidental script ordering.
4. Query design: efficient filtering, tags, archetypes, and cached views.
5. Component mutation rules: controlled writes, staged changes, and event-safe updates.
6. Feature composition: behavior emerges from components rather than inheritance chains.
7. Data locality: designing state for batch processing and predictable iteration.
8. Runtime registration: typed component and system registries.
9. ECS debugging: entity inspectors, component diffs, and system timing traces.
10. Roblox integration: mapping Instances, Attributes, CollectionService tags, and replicated state into ECS boundaries.

## Stage 2: OOP, Composition, and Polymorphic Dispatch

1. Metatable class patterns: constructors, methods, private state, and object identity.
2. Interface-by-contract design: documenting and enforcing expected method surfaces.
3. Composition over inheritance: capabilities, delegates, traits, and injected collaborators.
4. Polymorphic dispatch: replacing feature-name conditionals with object behavior.
5. Dependency injection: explicit services, test doubles, and dependency boundaries.
6. Lifecycle methods: init, start, pause, resume, destroy, and ownership transfer.
7. Object pooling: reuse policies for projectiles, effects, UI rows, and transient objects.
8. Error boundaries: defensive object APIs that fail early with useful diagnostics.
9. Service object design: single-purpose services instead of omniscient managers.
10. Roblox object adapters: wrapping Instances without leaking engine details through the whole codebase.

## Stage 3: Coroutines, Scheduling, and Async Control Flow

1. Coroutine fundamentals: yield/resume semantics, error propagation, and cancellation gaps.
2. Task ownership: every async task has an owner and a cleanup path.
3. Custom schedulers: frame queues, priority queues, delayed jobs, and budgeted execution.
4. Promise-style flows: success, failure, timeout, cancellation, and composition.
5. Deterministic stepping: simulation ticks separated from render frames.
6. Backpressure: preventing unbounded task.spawn, event fanout, and retry storms.
7. Debounce vs throttle vs cooldown: explicit timing policies per feature.
8. Cleanup containers: Janitor/Maid/Trove-style resource ownership.
9. Async testing: fake clocks, controlled yields, and deterministic task flushing.
10. Roblox scheduler integration: RunService phases, task library behavior, and network/event timing.

## Stage 4: Metatables, Proxies, and Runtime Contracts

1. __index and __newindex: controlled reads, writes, and method lookup.
2. Proxy tables: read-only views, write guards, lazy access, and instrumentation.
3. Runtime type guards: validating data at trust boundaries.
4. Contract assertions: preconditions, postconditions, and invariant checks.
5. API capability tokens: exposing only the operations a caller is allowed to perform.
6. Sandboxed environments: limiting access for plugin-style modules or user-authored behavior.
7. Reactive tables: change observation without uncontrolled mutation.
8. Debug instrumentation: tracing access, mutation, and slow-path behavior.
9. Serialization-safe objects: separating runtime behavior from transferable data.
10. Contract performance: removing or reducing runtime guards in hot paths safely.

## Stage 5: Typed Luau Architecture and Static Contracts

1. Strict mode discipline: making `--!strict` the default for shared code.
2. Structural typing: using shape-based contracts intentionally.
3. Generic modules: typed containers, registries, resources, and event buses.
4. Branded ids: distinguishing PlayerId, EntityId, ItemId, MatchId, and similar values.
5. Network schemas: typed RemoteEvent and RemoteFunction payload definitions.
6. Service contracts: explicit public APIs separated from private implementation.
7. Type-safe configuration: one authoritative typed config surface per feature.
8. Result types: success/failure returns instead of ambiguous nil/error patterns.
9. Type narrowing: discriminated unions for feature modes and state machines.
10. Type-driven refactors: using the checker to move behavior without losing correctness.

## Stage 6: Rollback Netcode, Prediction, and Reconciliation

1. Server authority: the server owns truth while clients predict responsiveness.
2. Input commands: compact, timestamped, sequence-numbered input records.
3. Fixed tick simulation: deterministic state progression independent from render frames.
4. State snapshots: compact capture, restore, diff, and compression strategies.
5. Client prediction: local simulation before server confirmation.
6. Server reconciliation: correcting client state with minimal visual disruption.
7. Rollback and replay: rewinding to a trusted frame and replaying pending inputs.
8. Lag compensation: server-side historical hit validation for latency-sensitive actions.
9. Presentation smoothing: interpolation, extrapolation, and correction blending.
10. Anti-cheat constraints: validating inputs, rate limits, impossible movement, and authority violations.

## Chapter 7: Deterministic Simulation and Temporal Architecture

1. Deterministic math policy: avoiding nondeterministic floating-point and random behavior where rollback depends on repeatability.
2. Seeded random streams: domain-specific RNG streams for combat, loot, AI, and procedural systems.
3. Fixed-point approximations: when stable numeric behavior matters more than convenience.
4. Simulation clocks: separating real time, server time, client time, render time, and tick time.
5. Temporal state machines: state transitions driven by ticks and events instead of loose waits.
6. Event sourcing: recording commands and domain events as the basis for replay and auditing.
7. Snapshot delta encoding: storing only meaningful state changes between frames.
8. Deterministic physics boundaries: deciding when Roblox physics is presentation, authority, or approximation.
9. Replay tooling: deterministic test replays for combat, movement, economy, and NPC behavior.
10. Time-travel debugging: inspecting historical states and reproducing desyncs.

See [Stage 7: Deterministic Simulation and Temporal Architecture](STAGE_07_DETERMINISTIC_SIMULATION_TEMPORAL_ARCHITECTURE.md) for the full practice guide.

## Chapter 8: Network Architecture, Replication, and Security

1. Trust boundaries: defining which data can originate from clients and which never can.
2. Remote protocol design: versioned message names, schemas, ids, and rate policies.
3. Replication layers: separating engine replication, custom replication, and presentation replication.
4. Interest management: sending only relevant world state to each client.
5. Bandwidth budgeting: per-feature network budgets and compression strategies.
6. Authority handoff: controlled ownership transitions for vehicles, physics objects, and temporary simulations.
7. Secure command validation: proving an action is legal before applying it.
8. Abuse-resistant cooldowns: server-side cooldowns, input windows, and spam mitigation.
9. Desync detection: checksums, divergence reports, and reconciliation diagnostics.
10. Protocol migration: keeping old and new clients compatible during staged rollout.

See [Stage 8: Network Architecture, Replication, and Security](STAGE_08_NETWORK_ARCHITECTURE_REPLICATION_SECURITY.md) for the full practice guide.

## Chapter 9: Runtime Systems, Tooling, and Observability

1. Diagnostics architecture: logs, traces, counters, timings, and structured error reports.
2. Feature flags: controlled rollout, kill switches, and experiment boundaries.
3. Hot reload boundaries: safe reloadable modules versus stateful runtime services.
4. Memory profiling: leak detection, object lifetime reports, and connection tracking.
5. Performance budgets: frame time, memory, network, DataStore, and replication targets.
6. System health dashboards: live views for services, queues, entities, and remote traffic.
7. Automated contract tests: validating service APIs, schemas, and lifecycle guarantees.
8. Fuzz testing: randomized command sequences for inventories, combat, trading, and rollback.
9. Editor tooling: Roblox Studio plugins, inspectors, generators, and validation panels.
10. Failure injection: simulating latency, packet loss, datastore failure, and partial service outages.

See [Stage 9: Runtime Systems, Tooling, and Observability](STAGE_09_RUNTIME_SYSTEMS_TOOLING_OBSERVABILITY.md) for the full practice guide.

## Chapter 10: Large-Scale Game Architecture and Domain Platforms

1. Modular feature platforms: shared rules engines that features configure instead of rewriting.
2. Domain-specific languages: declarative ability, item, quest, dialogue, and enemy behavior definitions.
3. Rules engines: composing conditions, effects, costs, cooldowns, targeting, and validation.
4. Data pipelines: importing, validating, versioning, and deploying gameplay data.
5. Persistence architecture: profile ownership, migrations, conflict handling, and write budgets.
6. Economy integrity: transaction ledgers, idempotency, rollback, fraud resistance, and audit trails.
7. Match/session orchestration: lifecycle, matchmaking, server reservation, reconnect, and cleanup.
8. AI behavior architecture: behavior trees, utility AI, planners, blackboards, and perception systems.
9. Plugin-grade extensibility: capabilities, sandboxing, extension points, and backwards-compatible APIs.
10. Cross-project policy extraction: turning proven patterns into templates, checklists, and reusable system contracts.

See [Stage 10: Large-Scale Game Architecture and Domain Platforms](STAGE_10_LARGE_SCALE_GAME_ARCHITECTURE_DOMAIN_PLATFORMS.md) for the full practice guide.

## Specialty Chapter: Gunkit Anti-Cheat, Aimlock, Aimbot, and ESP Prevention

1. Threat model discipline: assume the client can inspect, spoof, automate, and spam.
2. Server-authoritative hit validation: clients send intent, servers decide hits and damage.
3. Information minimization: do not replicate combat data the client does not need.
4. Visibility and line-of-sight authority: server geometry and rules decide valid targeting.
5. Aim sanity and human-limit heuristics: detect abnormal patterns without overclaiming proof.
6. Input and fire cadence validation: server owns fire rate, reload, ammo, and sequence.
7. Remote protocol hardening: schemas, rate limits, sequence numbers, payload bounds, and fuzz tests.
8. Lag compensation without trust: bounded historical validation using server-owned state.
9. ESP-resistant UI and marker design: server-filtered nameplates, markers, health bars, and outlines.
10. Audit, replay, and evidence: every rejection or suspicious shot should be explainable.
11. Possibility bounds: compare shots against server-known physical, weapon, visibility, recoil, and timing limits.
12. Likelihood scoring: accumulate repeated low-probability events instead of overreacting to one suspicious shot.
13. Counterfactual replay: test suspicious hits against strict, lag-compensated, and maximum-tolerance histories.
14. Behavioral baselines: compare current aim behavior against session history and population expectations.
15. Detection response ladder: protect state first, escalate punishment only with high-confidence repeated evidence.

## Stage 11: Persistence, Economy Integrity, and Transaction Ledgers

1. Profile ownership: one server session owns durable player state at a time.
2. Data schemas: saved state has typed, versioned records.
3. Migrations: old data upgrades through ordered, idempotent transforms.
4. Transaction boundaries: durable changes validate, mutate, audit, and commit as one unit.
5. Idempotency: retries and duplicate requests do not duplicate rewards or charges.
6. Ledgers and audit events: every value change records why it happened.
7. Write budgets and queues: DataStore work is scheduled, coalesced, retried, and observable.
8. Conflict handling: stale or concurrent durable changes use named policies.
9. Secure reward claims: clients never directly grant durable rewards.
10. Recovery and repair tooling: durable state can be audited, replayed, migrated, and repaired.

See [Stage 11: Persistence, Economy Integrity, and Transaction Ledgers](STAGE_11_PERSISTENCE_ECONOMY_TRANSACTION_INTEGRITY.md) for the full practice guide.

## Stage 12: Utility Architecture and Engine Foundation

1. Utility ownership and taxonomy: utilities are categorized by purpose and owner.
2. Core primitives: ids, results, readonly views, assertions, and small typed helpers.
3. Lifecycle utilities: cleaners, task owners, operation handles, pools, and disposable contracts.
4. Registry utilities: typed extension registries for components, systems, actions, effects, and schemas.
5. Validation utilities: shared runtime admission vocabulary for remotes, configs, buffers, and persistence.
6. Scheduler and time utilities: clocks, fake clocks, ticks, cooldowns, throttles, queues, and backpressure.
7. Network utility layer: schema registries, remote adapters, rate limiters, sequence trackers, and codecs.
8. Diagnostics and debug utilities: structured traces, counters, health reports, and debug commands.
9. Test and fuzz utilities: fake services, replay harnesses, fuzz generators, and fixtures.
10. Roblox adapter utilities: Tools, prompts, tags, remotes, RunService, Attributes, and physics ownership boundaries.
11. Compatibility layers: stable contracts around volatile services and implementation details.
12. Networking compatibility layers: gameplay depends on protocol APIs, not raw remotes or transport details.
13. Caching compatibility layers: cache ownership, invalidation, TTL, freshness, and backing provider stay isolated.
14. Persistence compatibility layers: domain systems submit transactions while repositories hide storage providers.
15. Runtime environment compatibility layers: server/client/Studio/test differences stay behind context adapters.

See [Stage 12: Utility Architecture and Engine Foundation](STAGE_12_UTILITY_ARCHITECTURE_ENGINE_FOUNDATION.md) for the full practice guide.

## Stage 13: AI Behavior Architecture and NPC Systems

1. AI agent identity: stable ids, model adapters, lifecycle, team, and behavior profile.
2. Perception systems: sight, hearing, damage, proximity, threat, objective, and memory signals.
3. Blackboard memory: explicit agent memory and working state.
4. Behavior trees: priority flow through selectors, sequences, conditions, and actions.
5. Utility AI: scoring actions from context.
6. Planners and goals: variable paths to goal completion.
7. Action contracts: NPC behavior executes through typed shared services.
8. Pathfinding and movement authority: queues, adapters, backpressure, and stuck handling.
9. Squad and group AI: shared group state and coordination.
10. AI debugging and observability: decision traces, perception dumps, scores, and path status.

See [Stage 13: AI Behavior Architecture and NPC Systems](STAGE_13_AI_BEHAVIOR_NPC_SYSTEMS.md) for the full practice guide.

## Stage 14: Contract-First Feature Architecture

Shared systems define contracts first; feature packages only supply identity, config, and domain behavior.

See [Stage 14: Contract-First Feature Architecture](STAGE_14_CONTRACT_FIRST_FEATURE_ARCHITECTURE.md).

## Stage 15: Rules Engines and Declarative Gameplay

Gameplay is composed from validated conditions, costs, effects, targeting, cooldowns, permissions, and rewards.

See [Stage 15: Rules Engines and Declarative Gameplay](STAGE_15_RULES_ENGINES_AND_DECLARATIVE_GAMEPLAY.md).

## Stage 16: Source Generation, Templates, and Static Analysis

Repeated architecture patterns become generators, templates, audits, and static checks.

See [Stage 16: Source Generation, Templates, and Static Analysis](STAGE_16_SOURCE_GENERATION_TEMPLATES_AND_STATIC_ANALYSIS.md).

## Stage 17: Parallelism, Actor Model, Bulk Movement, and Scalability

Parallel work uses ownership boundaries, immutable snapshots, message passing, and deterministic merge phases.

See [Stage 17: Parallelism, Actor Model, and Scalability](STAGE_17_PARALLELISM_ACTOR_MODEL_AND_SCALABILITY.md).

## Stage 18: Release Engineering, Versioning, and LiveOps

Production systems need versioning, rollout, rollback, observability, migration, and deprecation policy.

See [Stage 18: Release Engineering, Versioning, and LiveOps](STAGE_18_RELEASE_ENGINEERING_VERSIONING_AND_LIVEOPS.md).

## Implementation Rule

For every future Roblox system, ask:

1. What is the authoritative state?
2. Which side owns it: server, client, or shared simulation?
3. What are the typed contracts?
4. What is the lifecycle and cleanup path?
5. What is predicted, replicated, reconciled, or rolled back?
6. What is data, what is behavior, and what is presentation?
7. What can be tested deterministically?
8. What can fail, be abused, desync, leak, or overload?
9. What tooling proves the system is healthy?
10. What reusable policy should this system contribute back to the curriculum?
