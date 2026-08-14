# Roblox Luau Engineering Curriculum

This curriculum has 22 contiguous stages. The order is based on reasoning difficulty and dependency depth: local values first, then module/object boundaries, then lifecycle and trust boundaries, then historical/distributed state, and finally toolchain, concurrency, and live operations.

Read [Bare Minimum Prerequisites](prerequisites/BARE_MINIMUM.md), [Curriculum Accuracy Standard](CURRICULUM_ACCURACY_STANDARD.md), and the [Stage Coverage and Difficulty Map](STAGE_COVERAGE_AND_DIFFICULTY_MAP.md) first.

Every stage embeds its complete checked program. Run that guided lesson before the longer reference sections.

## Difficulty rule

Ranks increase with independently owned state, module/lifecycle count, hostile or durable boundaries, history/replay, cross-system compatibility, concurrency, and deployment consequences. The order is a teaching path, not a requirement to adopt every technique.

## Tier 1 — Beginner language and state

### Stage 1: Tables, Records, and Mutation

Learn arrays, dictionaries, records, references, and mutation.

See [Stage 1](STAGE_01_TABLES_RECORDS_MUTATION.md).

### Stage 2: Functions, ModuleScripts, and State Ownership

Learn functions, module APIs, caching, and explicit state owners.

See [Stage 2](STAGE_02_FUNCTIONS_MODULES_STATE_OWNERSHIP.md).

### Stage 3: Common Data Structures and State Machines

Learn sets, stacks, queues, registries, and legal transitions.

See [Stage 3](STAGE_03_COMMON_DATA_STRUCTURES.md).

## Tier 2 — Foundation contracts and objects

### Stage 4: Typed Luau and Static Contracts

Learn strict mode, annotations, unions, narrowing, and checker limits.

See [Stage 4](STAGE_04_TYPED_LUAU_STATIC_CONTRACTS.md).

### Stage 5: Metatables and Object Methods

Learn method lookup, constructors, self, and metamethod limits.

See [Stage 5](STAGE_05_METATABLES_OBJECT_METHODS.md).

### Stage 6: Composition, Polymorphic Dispatch, and Dependency Injection

Learn composed capabilities, replaceable behavior, and supplied dependencies.

See [Stage 6](STAGE_06_COMPOSITION_POLYMORPHIC_DISPATCH_DEPENDENCY_INJECTION.md).

## Tier 3 — Applied ownership and reuse

### Stage 7: Runtime Validation, Proxies, and Contracts

Learn dynamic admission, write guards, capabilities, and serialization.

See [Stage 7](STAGE_07_RUNTIME_VALIDATION_PROXIES_CONTRACTS.md).

### Stage 8: Async Ownership, Lifecycle, and Scheduling

Learn cancellation, task ownership, timing policies, and cleanup.

See [Stage 8](STAGE_08_ASYNC_LIFECYCLE_SCHEDULING.md).

### Stage 9: Utilities, Adapters, and Engine Foundations

Learn small reusable semantics, wrappers, caches, and test seams.

See [Stage 9](STAGE_09_UTILITY_ARCHITECTURE_ENGINE_FOUNDATIONS.md).

## Tier 4 — Reliable feature systems

### Stage 10: Contract-First Feature Architecture

Learn feature identity, behavior contracts, registries, and shared rules.

See [Stage 10](STAGE_10_CONTRACT_FIRST_FEATURE_ARCHITECTURE.md).

### Stage 11: Testing, Tooling, and Observability

Learn tests, bounded diagnostics, profiling, fuzzing, and failure evidence.

See [Stage 11](STAGE_11_TESTING_TOOLING_OBSERVABILITY.md).

### Stage 12: Networking, Replication, and Security

Learn remote protocols, runtime admission, authority, and replication.

See [Stage 12](STAGE_12_NETWORKING_REPLICATION_SECURITY.md).

## Tier 5 — Advanced state architectures

### Stage 13: Persistence, Economy, and Transaction Integrity

Learn schema versions, idempotency, budgets, receipts, and recovery.

See [Stage 13](STAGE_13_PERSISTENCE_ECONOMY_TRANSACTION_INTEGRITY.md).

### Stage 14: ECS and Data-Oriented Architecture

Learn entity identity, component stores, systems, queries, and staged mutation.

See [Stage 14](STAGE_14_ECS_DATA_ORIENTED_ARCHITECTURE.md).

### Stage 15: Rules Engines and Declarative Gameplay

Learn conditions, effects, ordering, validation, and explainable evaluation.

See [Stage 15](STAGE_15_RULES_ENGINES_DECLARATIVE_GAMEPLAY.md).

### Stage 16: Deterministic Simulation, Time, and Replay

Learn fixed steps, clocks, snapshots, controlled randomness, and replay limits.

See [Stage 16](STAGE_16_DETERMINISTIC_SIMULATION_TEMPORAL_ARCHITECTURE.md).

## Tier 6 — Expert distributed and domain systems

### Stage 17: AI Behavior and NPC Systems

Learn perception, decisions, actions, movement ownership, and debugging.

See [Stage 17](STAGE_17_AI_BEHAVIOR_NPC_SYSTEMS.md).

### Stage 18: Prediction, Reconciliation, Lag Compensation, and Rollback

Learn client prediction, server correction, history, replay, and fairness.

See [Stage 18](STAGE_18_PREDICTION_RECONCILIATION_ROLLBACK.md).

### Stage 19: Domain Platforms and Large-Scale Architecture

Learn shared domain rules, extension points, compatibility, and ownership.

See [Stage 19](STAGE_19_DOMAIN_PLATFORMS_LARGE_SCALE_ARCHITECTURE.md).

## Tier 7 — Production engineering

### Stage 20: Source Generation, Templates, and Static Analysis

Learn validated descriptors, deterministic output, audits, and generated ownership.

See [Stage 20](STAGE_20_SOURCE_GENERATION_TEMPLATES_STATIC_ANALYSIS.md).

### Stage 21: Parallel Luau, Actors, and Scalability

Learn partitioning, Actors, thread safety, communication, and merge phases.

See [Stage 21](STAGE_21_PARALLEL_LUAU_ACTORS_SCALABILITY.md).

### Stage 22: Release Engineering, Versioning, and LiveOps

Learn migrations, flags, rollout, rollback, compatibility, and operations.

See [Stage 22](STAGE_22_RELEASE_ENGINEERING_VERSIONING_LIVEOPS.md).

## Specialty paths

- [Networking Mastery Ladder](NETWORKING_MASTERY_LADDER.md): extend Stage 12 from basic admission through protocol design and measurement.
- [Combat Security and Information Limits](SPECIALTY_GUNKIT_ANTI_CHEAT_AIMLOCK_AIMBOT_ESP_PREVENTION.md): apply Stages 12, 16, and 18 to server-authoritative combat.

## Continuous practice project

Build one small round-based experience through the ladder: store local state, extract module APIs, add structures and types, learn metatable/composition/runtime contracts, own async work, add only proven utilities, then introduce feature contracts, tests, networking, persistence, advanced architectures, and production techniques in that order.

At every step, name authoritative state, owner, cleanup condition, failure behavior, and verification environment.
