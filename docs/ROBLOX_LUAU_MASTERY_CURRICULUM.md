# Roblox Luau Engineering Curriculum

This curriculum teaches how to choose and verify Roblox/Luau engineering techniques. It does not prescribe ECS, OOP, dependency injection, rollback, code generation, or a domain platform for every feature.

Read [Curriculum Accuracy Standard](CURRICULUM_ACCURACY_STANDARD.md) first. It defines which statements are platform facts, security requirements, recommendations, optional patterns, or experimental features.

## Baseline principles

1. The server validates client requests that affect shared, competitive, privileged, or durable state. Client code still legitimately owns input, camera, UI, and local presentation.
2. Prefer the simplest design that satisfies the feature’s correctness, scale, testability, and team needs.
3. Keep ownership and cleanup explicit when code creates resources that can outlive the current operation.
4. Separate concerns where their authority, rate of change, runtime environment, or verification method differs. Do not split code merely to satisfy a diagram.
5. Treat Roblox Instances as valid engine objects. Introduce adapters or stable IDs only where lifetime, streaming, serialization, testing, or cross-system identity makes that useful.
6. Measure performance and networking changes with comparable workloads. Architecture vocabulary is not performance evidence.

The earlier blanket statement that feature code only declares identity/domain behavior while shared architecture owns everything else was too broad. That split is useful for a genuinely reused platform, but a cohesive feature package may correctly own its orchestration, validation, networking adapter, and lifecycle. Responsibility follows authority, cohesion, volatility, and reuse—not the label “feature” or “shared.”

## Stage 1: ECS and Data-Oriented Design

Learn entities, components, systems, indexed stores, queries, update phases, and batch processing. Then decide whether the feature’s entity count and cross-cutting operations justify ECS.

Important correction: Luau tables do not give scripts direct control over CPU cache layout. Organizing data by component can improve iteration, querying, allocation behavior, and snapshots, but “data locality” is not a guaranteed low-level optimization in Luau. Profile the real workload.

See [Stage 1](STAGE_01_ECS_DATA_ORIENTED_ARCHITECTURE.md).

## Stage 2: Objects, Composition, and Polymorphism

Learn table/metatable object patterns, module APIs, resource ownership, composition, and multiple forms of polymorphic dispatch.

Important corrections:

- Composition and polymorphism are compatible. Inheritance is an `is-a` reuse relationship; composition is a `has-a` relationship; polymorphism is the ability to use different implementations through a common operation.
- Dependency injection can be as small as passing a clock or callback into a function. It works in closed-source gameplay code and does not require a container or external provider.
- Lifecycle operations are domain-specific. `destroy` is useful for an owner of disposable resources; `pause` and `resume` only belong where those states have defined semantics.
- Pooling is a measured optimization, not a default object feature.

See [Stage 2](STAGE_02_OOP_COMPOSITION_POLYMORPHIC_DISPATCH.md).

## Stage 3: Coroutines, Scheduling, and Async Control Flow

Learn yielding, task scheduling, cancellation, timeouts, event-driven work, queues, and ownership. Use custom schedulers or Promise libraries only when their semantics solve a real coordination problem.

See [Stage 3](STAGE_03_COROUTINES_SCHEDULING_ASYNC_CONTROL_FLOW.md).

## Stage 4: Metatables, Proxies, and Runtime Validation

Learn method lookup, proxies, table freezing, validators, capability-shaped APIs, and the limits of same-VM “sandboxing.” Runtime validation is essential at untrusted boundaries; proxies and metatables are optional implementation tools.

See [Stage 4](STAGE_04_METATABLES_PROXIES_RUNTIME_CONTRACTS.md).

## Stage 5: Typed Luau and Static Contracts

Learn gradual typing, strict mode, structural types, generics, tagged unions, result types, refinements, and runtime-validator pairing. Types improve tooling; they do not make remote input trusted or runtime tables immutable.

See [Stage 5](STAGE_05_TYPED_LUAU_ARCHITECTURE_STATIC_CONTRACTS.md).

## Stage 6: Prediction, Reconciliation, Lag Compensation, and Rollback

These are separate latency-management techniques with different costs. Most games need only some of them. Fixed-step code is not automatically deterministic, and Roblox physics should not be assumed replay-deterministic.

See [Stage 6](STAGE_06_ROLLBACK_NETCODE_PREDICTION_RECONCILIATION.md).

## Stage 7: Simulation Time, History, and Replay

Learn clocks, fixed steps, event records, snapshots, seeded randomness, and replay boundaries. Distinguish repeatable application logic from engine physics and cross-device numerical determinism.

See [Stage 7](STAGE_07_DETERMINISTIC_SIMULATION_TEMPORAL_ARCHITECTURE.md).

## Stage 8: Networking, Replication, and Security

Learn Roblox’s built-in replication, RemoteEvents, RemoteFunctions, UnreliableRemoteEvents, validation, rate limiting, network ownership, relevance filtering, and protocol evolution. Do not add custom replication merely because it appears more advanced.

See [Stage 8](STAGE_08_NETWORK_ARCHITECTURE_REPLICATION_SECURITY.md) and the [Networking Ladder](NETWORKING_MASTERY_LADDER.md).

## Stage 9: Runtime Tooling and Observability

Learn focused logging, metrics, profiling, tracing, failure injection, and lifecycle inspection. Instrumentation must have bounded cost, privacy rules, and a decision it supports.

See [Stage 9](STAGE_09_RUNTIME_SYSTEMS_TOOLING_OBSERVABILITY.md).

## Stage 10: Scaling Architecture and Domain Platforms

Learn when repeated, stable domain rules justify a shared platform. Duplication alone does not prove the right abstraction; extract after understanding meaningful variation.

See [Stage 10](STAGE_10_LARGE_SCALE_GAME_ARCHITECTURE_DOMAIN_PLATFORMS.md).

## Stage 11: Persistence and Economy Integrity

Learn DataStore constraints, single-key `UpdateAsync`, session ownership, schema migration, idempotent receipt handling, write budgets, recovery, and audit evidence. Do not describe application-level transaction coordinators as database-level atomicity.

See [Stage 11](STAGE_11_PERSISTENCE_ECONOMY_TRANSACTION_INTEGRITY.md).

## Stage 12: Utilities and Engine Foundations

Learn how to identify genuinely reusable primitives without building wrapper layers for their own sake. A direct Roblox API call behind a well-owned module can be better than an abstract interface that has one implementation and no testing seam.

See [Stage 12](STAGE_12_UTILITY_ARCHITECTURE_ENGINE_FOUNDATION.md).

## Stage 13: AI and NPC Systems

Learn perception, state, decisions, actions, movement, scheduling, and debugging. Behavior trees, utility scoring, planners, and state machines are alternatives that can also be combined; no NPC needs all of them. Competitive outcomes need server validation, while cosmetic NPC presentation can be client-side.

See [Stage 13](STAGE_13_AI_BEHAVIOR_NPC_SYSTEMS.md).

## Stage 14: Contract-First Feature Design

Learn stable module boundaries and extension points. A registry is useful for an open set of plugins or data-defined behaviors; a direct conditional can be clearer and safer for a small closed set.

See [Stage 14](STAGE_14_CONTRACT_FIRST_FEATURE_ARCHITECTURE.md).

## Stage 15: Rules Engines and Declarative Gameplay

Learn when gameplay data benefits from a validated evaluator. Avoid turning straightforward domain code into an untyped general-purpose interpreter.

See [Stage 15](STAGE_15_RULES_ENGINES_AND_DECLARATIVE_GAMEPLAY.md).

## Stage 16: Templates, Code Generation, and Static Analysis

Learn what tooling can prove and what remains a runtime or Studio concern. Linters can enforce syntax and detectable project rules; they cannot generally prove authority, cleanup, security, or semantic correctness.

See [Stage 16](STAGE_16_SOURCE_GENERATION_TEMPLATES_AND_STATIC_ANALYSIS.md).

## Stage 17: Parallel Luau and Scalability

Learn Actors, serial/parallel phases, thread-safety tags, VM isolation, SharedTables, messages, batching, and profiling. Parallelism is optional and may be slower for small or synchronization-heavy work.

See [Stage 17](STAGE_17_PARALLELISM_ACTOR_MODEL_AND_SCALABILITY.md).

## Stage 18: Release Engineering and LiveOps

Learn place versions, feature/config rollout, schema and protocol compatibility, rollback plans, migrations, telemetry, and cleanup. The amount of machinery should be proportional to release risk.

See [Stage 18](STAGE_18_RELEASE_ENGINEERING_VERSIONING_AND_LIVEOPS.md).

## Specialty: Combat Security

Learn authoritative validation, information limits, lag-tolerant hit checks, network-ownership risk, evidence quality, and conservative enforcement. Client-side anti-cheat cannot be trusted, ESP cannot be eliminated for already replicated information, and statistical anomalies are not proof by themselves.

See [Gunkit Anti-Cheat Specialty](SPECIALTY_GUNKIT_ANTI_CHEAT_AIMLOCK_AIMBOT_ESP_PREVENTION.md).

## Design review questions

For a new system, ask:

1. What outcome must be correct, and who can attack or invalidate it?
2. Which state is authoritative, predicted, cached, presented, or durable?
3. What is the smallest API and data model that fits the feature?
4. Which resources outlive a call, and who releases or invalidates them?
5. Which inputs are dynamic or untrusted and therefore need runtime validation?
6. What scale and latency does the feature actually need to support?
7. Which engine behavior is documented, and which behavior still needs a Studio/runtime test?
8. What evidence would falsify the design assumption?
9. Is the proposed abstraction cheaper than direct code over the expected lifetime?
10. Which checks can run statically, and which require live, visual, networked, or long-duration proof?

Use the [Scripter Ranking Rubric](SCRIPTER_RANKING_RUBRIC.md) as an evidence rubric, not a line-count target.
