# Roblox Luau Engineering Curriculum

This curriculum is ordered from foundational Luau structures to advanced production architecture. Later stages assume the vocabulary and small-system skills from earlier stages, but the techniques remain optional unless the feature actually needs them.

Read [Bare Minimum Prerequisites](prerequisites/BARE_MINIMUM.md) and [Curriculum Accuracy Standard](CURRICULUM_ACCURACY_STANDARD.md) first.

Every stage contains its complete beginner program directly on the page and links the same source file in [`docs/lessons`](lessons/README.md). Each lesson:

- starts with one concrete use case;
- introduces only three small steps;
- uses `--!strict` with only the types needed to check the small example;
- contains assertions for the expected result;
- is checked by the official Luau analyzer and command-line runtime;
- states the Roblox/Studio behavior that the standalone example cannot prove.

Read the three steps above the theory, predict each assertion, run the visible code, then make the suggested one-line change. Once that works, the beginner pass is complete; the remaining sections are optional reference material for later.

## How difficulty is assigned

Difficulty follows the kind of reasoning required, not how impressive a pattern sounds:

- **Foundation**: one module or small local system; direct runtime behavior.
- **Intermediate**: multiple owners, modules, lifecycles, or trust boundaries.
- **Advanced**: historical state, distributed behavior, scale, or architecture across feature families.
- **Production mastery**: tooling and operational practices that affect a whole project or release process.

The order is a learning path, not a mandate to add every technique to one game.

## Tier 1 — Luau foundations

### Stage 1: Tables, ModuleScripts, Metatables, and Data Structures

Learn arrays, dictionaries, records, sets, stacks, queues, ModuleScript caching, closures, `__index`, method lookup, `__newindex` limitations, registries, state machines, and the basic shapes of services and processors.

Outcome: build small, understandable systems from ordinary Luau before introducing frameworks.

See [Stage 1](STAGE_01_LUAU_TABLES_MODULES_METATABLES_DATA_STRUCTURES.md).

### Stage 2: Typed Luau and Static Contracts

Learn gradual typing, strict mode, table types, function types, structural typing, generics, tagged unions, expected-failure types, refinements, and the boundary between static checking and runtime validation.

Outcome: make the shape of Stage 1 structures visible to tools without pretending types secure hostile runtime input.

See [Stage 2](STAGE_02_TYPED_LUAU_STATIC_CONTRACTS.md).

### Stage 3: Objects, Composition, and Polymorphic Dispatch

Learn when a table/metatable object is useful, how colon methods work, how to compose collaborators, and how functions, structural contracts, tagged unions, or objects can provide polymorphism without deep inheritance.

Dependency injection is introduced as ordinary dependency passing. Lifecycle methods are added only for real states and owned resources.

See [Stage 3](STAGE_03_OOP_COMPOSITION_POLYMORPHIC_DISPATCH.md).

### Stage 4: Coroutines, Scheduling, and Async Control Flow

Learn yielding, tasks, signals, cancellation/stale-result guards, timeouts, cooldowns, throttles, debounces, queues, backpressure, and lifecycle ownership for asynchronous work.

Outcome: keep delayed or concurrent work from mutating a system after its owner ends.

See [Stage 4](STAGE_04_COROUTINES_SCHEDULING_ASYNC_CONTROL_FLOW.md).

## Tier 2 — Building reliable feature systems

### Stage 5: Utilities and Engine Foundations

Learn when a cleaner, clock, ID admission function, queue, cache, result helper, validator, or adapter deserves reuse. Avoid helper dumps and one-implementation abstractions that do not reduce risk.

See [Stage 5](STAGE_05_UTILITY_ARCHITECTURE_ENGINE_FOUNDATION.md).

### Stage 6: Contract-First Feature Design

Learn to define caller/implementation agreements, runtime admission, capability-shaped APIs, closed versus open behavior sets, registration policy, and failure behavior.

A direct conditional remains valid for a small closed set; registries are introduced for genuinely open extension points.

See [Stage 6](STAGE_06_CONTRACT_FIRST_FEATURE_ARCHITECTURE.md).

### Stage 7: Runtime Tooling, Testing, and Observability

Learn focused logs, counters, profiles, traces, failure injection, lifecycle inspection, and how to choose evidence that matches a claim.

Outcome: diagnose systems before networking, persistence, or simulation complexity makes failures harder to isolate.

See [Stage 7](STAGE_07_RUNTIME_SYSTEMS_TOOLING_OBSERVABILITY.md).

### Stage 8: Networking, Replication, and Security

Learn Roblox replication, RemoteEvents, RemoteFunctions, UnreliableRemoteEvents, payload validation, rate/workload limits, network ownership, interest filtering, protocol evolution, and measured buffer use.

See [Stage 8](STAGE_08_NETWORK_ARCHITECTURE_REPLICATION_SECURITY.md) and the [Networking Mastery Ladder](NETWORKING_MASTERY_LADDER.md).

### Stage 9: Persistence and Economy Integrity

Learn DataStore behavior, single-key `UpdateAsync`, session ownership, schema migration, idempotent receipts, write budgets, retries, recovery, caches, and audit evidence.

Outcome: preserve durable truth without claiming database guarantees Roblox does not provide.

See [Stage 9](STAGE_09_PERSISTENCE_ECONOMY_TRANSACTION_INTEGRITY.md).

## Tier 3 — Advanced gameplay architecture

### Stage 10: ECS and Data-Oriented Design

Learn entities, components, systems, indexed stores, queries, update phases, staged mutation, snapshots, and batch processing after ordinary Luau collections and system ownership are familiar.

ECS is optional. Luau tables do not give scripts direct control over CPU-cache layout; profile the actual improvement in work, allocation, indexing, or iteration.

See [Stage 10](STAGE_10_ECS_DATA_ORIENTED_ARCHITECTURE.md).

### Stage 11: Rules Engines and Declarative Gameplay

Learn when validated data-driven conditions/effects simplify a variable gameplay domain and when direct code remains clearer. Define evaluator semantics, authority, ordering, limits, and diagnostics before adding a rule language.

See [Stage 11](STAGE_11_RULES_ENGINES_DECLARATIVE_GAMEPLAY.md).

### Stage 12: Simulation Time, History, and Replay

Learn clock domains, fixed steps, event records, snapshots, seeded randomness, replay boundaries, and side-effect isolation. A fixed timestep or declared phase order does not automatically guarantee determinism.

See [Stage 12](STAGE_12_DETERMINISTIC_SIMULATION_TEMPORAL_ARCHITECTURE.md).

### Stage 13: Prediction, Reconciliation, Lag Compensation, and Rollback

Learn these as separate latency-management techniques with different costs. Full rollback is introduced only after networking and temporal-state foundations.

Roblox physics should not be assumed replay-deterministic, and most games need only a subset of these techniques.

See [Stage 13](STAGE_13_ROLLBACK_NETCODE_PREDICTION_RECONCILIATION.md).

### Stage 14: AI and NPC Systems

Learn perception, memory, direct logic, finite state machines, behavior trees, utility scoring, planning, actions, pathfinding, scheduling, and debug decision traces.

These are alternative/composable techniques; an NPC does not need all of them or an ECS representation.

See [Stage 14](STAGE_14_AI_BEHAVIOR_NPC_SYSTEMS.md).

### Stage 15: Scaling Architecture and Domain Platforms

Learn when several real features reveal stable shared rules worth extracting into a weapon, vehicle, quest, prompt, economy, or other domain platform.

Outcome: reuse proven semantics without reducing features to configuration-only shells or creating giant managers.

See [Stage 15](STAGE_15_LARGE_SCALE_GAME_ARCHITECTURE_DOMAIN_PLATFORMS.md).

## Tier 4 — Production mastery

### Stage 16: Templates, Code Generation, and Static Analysis

Learn what generators, templates, linters, dependency checks, and project validators can prove. Keep static/source claims separate from Studio, runtime, authority, lifecycle, and live-provider proof.

See [Stage 16](STAGE_16_SOURCE_GENERATION_TEMPLATES_AND_STATIC_ANALYSIS.md).

### Stage 17: Parallel Luau and Scalability

Learn Actors, serial/parallel phases, thread-safety, VM isolation, SharedTables, messaging, partitioning, batching, merge costs, and profiling. Parallelism is optional and can be slower for small or synchronization-heavy work.

See [Stage 17](STAGE_17_PARALLELISM_ACTOR_MODEL_AND_SCALABILITY.md).

### Stage 18: Release Engineering and LiveOps

Learn place versions, staged rollout, flags/configuration, schema and protocol compatibility, migration, rollback plans, telemetry, degraded modes, and removal of obsolete paths.

The amount of machinery should be proportional to release and data risk.

See [Stage 18](STAGE_18_RELEASE_ENGINEERING_VERSIONING_AND_LIVEOPS.md).

## Specialty path: Combat security

Take this after Stage 8. Stages 12 and 13 are strongly recommended for lag-compensated weapons.

Learn authoritative cadence/ammo/hit/damage validation, information limits, network-ownership risk, evidence quality, and conservative enforcement. Client-side anti-cheat cannot be trusted, ESP cannot be eliminated for information already replicated to the client, and statistical anomalies are not proof by themselves.

See [Combat Anti-Cheat Specialty](SPECIALTY_GUNKIT_ANTI_CHEAT_AIMLOCK_AIMBOT_ESP_PREVENTION.md).

## Suggested practice path

1. Build the Stage 1 round tracker using plain modules and structures.
2. Type its boundaries in Stage 2.
3. Give two round instances explicit ownership in Stage 3.
4. Add cancellable timers and a bounded command queue in Stage 4.
5. Extract only one utility that a second exercise genuinely reuses.
6. Define one open modifier contract and test malformed registrations.
7. Add diagnostics and repeated lifecycle tests.
8. Add a small server-validated remote protocol.
9. Persist one idempotent reward safely.
10. Rebuild only the batch-oriented portion with ECS and compare it to the original.

Later exercises should add advanced techniques only when their prerequisite problem appears.

## Design review questions

For a new system, ask:

1. What outcome must be correct, and who can attack or invalidate it?
2. Which state is authoritative, predicted, cached, presented, or durable?
3. What is the smallest API and data structure that fits the feature?
4. Which resources or asynchronous results outlive a call, and who invalidates them?
5. Which inputs are dynamic or untrusted and need runtime validation?
6. What scale and latency does the feature actually need to support?
7. Which engine behavior is documented, and which still needs a Studio/runtime test?
8. What evidence would falsify the design assumption?
9. Is the proposed abstraction cheaper than direct code over the expected lifetime?
10. Which checks can run statically, and which require live, visual, networked, or long-duration proof?

Use the [Scripter Ranking Rubric](SCRIPTER_RANKING_RUBRIC.md) as an evidence rubric, not a technology or line-count checklist.
