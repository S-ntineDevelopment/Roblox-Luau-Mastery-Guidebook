# Roblox Luau Engineering Guidebook

A fact-checked Roblox/Luau curriculum arranged from the smallest local language concepts at Stage 1 to project-wide release operations at Stage 22.

This repository contains learning material only. Patterns are tools, not maturity requirements.

## Start here

1. [Bare Minimum Prerequisites](docs/prerequisites/BARE_MINIMUM.md)
2. [Accuracy and Applicability Standard](docs/CURRICULUM_ACCURACY_STANDARD.md)
3. [Stage Coverage and Difficulty Map](docs/STAGE_COVERAGE_AND_DIFFICULTY_MAP.md)
4. [Master Curriculum](docs/ROBLOX_LUAU_MASTERY_CURRICULUM.md)
5. [Type-Checked Lesson Index](docs/lessons/README.md)

## Difficulty-ordered stages

| Stage | Level | Focus |
| ---: | --- | --- |
| [1. Tables, Records, and Mutation](docs/STAGE_01_TABLES_RECORDS_MUTATION.md) | Beginner | arrays, dictionaries, records, references, and mutation |
| [2. Functions, ModuleScripts, and State Ownership](docs/STAGE_02_FUNCTIONS_MODULES_STATE_OWNERSHIP.md) | Beginner | functions, module APIs, caching, and explicit state owners |
| [3. Common Data Structures and State Machines](docs/STAGE_03_COMMON_DATA_STRUCTURES.md) | Beginner | sets, stacks, queues, registries, and legal transitions |
| [4. Typed Luau and Static Contracts](docs/STAGE_04_TYPED_LUAU_STATIC_CONTRACTS.md) | Foundation | strict mode, annotations, unions, narrowing, and checker limits |
| [5. Metatables and Object Methods](docs/STAGE_05_METATABLES_OBJECT_METHODS.md) | Foundation | method lookup, constructors, self, and metamethod limits |
| [6. Composition, Polymorphic Dispatch, and Dependency Injection](docs/STAGE_06_COMPOSITION_POLYMORPHIC_DISPATCH_DEPENDENCY_INJECTION.md) | Foundation | composed capabilities, replaceable behavior, and supplied dependencies |
| [7. Runtime Validation, Proxies, and Contracts](docs/STAGE_07_RUNTIME_VALIDATION_PROXIES_CONTRACTS.md) | Applied | dynamic admission, write guards, capabilities, and serialization |
| [8. Async Ownership, Lifecycle, and Scheduling](docs/STAGE_08_ASYNC_LIFECYCLE_SCHEDULING.md) | Applied | cancellation, task ownership, timing policies, and cleanup |
| [9. Utilities, Adapters, and Engine Foundations](docs/STAGE_09_UTILITY_ARCHITECTURE_ENGINE_FOUNDATIONS.md) | Applied | small reusable semantics, wrappers, caches, and test seams |
| [10. Contract-First Feature Architecture](docs/STAGE_10_CONTRACT_FIRST_FEATURE_ARCHITECTURE.md) | Intermediate | feature identity, behavior contracts, registries, and shared rules |
| [11. Testing, Tooling, and Observability](docs/STAGE_11_TESTING_TOOLING_OBSERVABILITY.md) | Intermediate | tests, bounded diagnostics, profiling, fuzzing, and failure evidence |
| [12. Networking, Replication, and Security](docs/STAGE_12_NETWORKING_REPLICATION_SECURITY.md) | Intermediate | remote protocols, runtime admission, authority, and replication |
| [13. Persistence, Economy, and Transaction Integrity](docs/STAGE_13_PERSISTENCE_ECONOMY_TRANSACTION_INTEGRITY.md) | Advanced | schema versions, idempotency, budgets, receipts, and recovery |
| [14. ECS and Data-Oriented Architecture](docs/STAGE_14_ECS_DATA_ORIENTED_ARCHITECTURE.md) | Advanced | entity identity, component stores, systems, queries, and staged mutation |
| [15. Rules Engines and Declarative Gameplay](docs/STAGE_15_RULES_ENGINES_DECLARATIVE_GAMEPLAY.md) | Advanced | conditions, effects, ordering, validation, and explainable evaluation |
| [16. Deterministic Simulation, Time, and Replay](docs/STAGE_16_DETERMINISTIC_SIMULATION_TEMPORAL_ARCHITECTURE.md) | Advanced | fixed steps, clocks, snapshots, controlled randomness, and replay limits |
| [17. AI Behavior and NPC Systems](docs/STAGE_17_AI_BEHAVIOR_NPC_SYSTEMS.md) | Expert | perception, decisions, actions, movement ownership, and debugging |
| [18. Prediction, Reconciliation, Lag Compensation, and Rollback](docs/STAGE_18_PREDICTION_RECONCILIATION_ROLLBACK.md) | Expert | client prediction, server correction, history, replay, and fairness |
| [19. Domain Platforms and Large-Scale Architecture](docs/STAGE_19_DOMAIN_PLATFORMS_LARGE_SCALE_ARCHITECTURE.md) | Expert | shared domain rules, extension points, compatibility, and ownership |
| [20. Source Generation, Templates, and Static Analysis](docs/STAGE_20_SOURCE_GENERATION_TEMPLATES_STATIC_ANALYSIS.md) | Production | validated descriptors, deterministic output, audits, and generated ownership |
| [21. Parallel Luau, Actors, and Scalability](docs/STAGE_21_PARALLEL_LUAU_ACTORS_SCALABILITY.md) | Production | partitioning, Actors, thread safety, communication, and merge phases |
| [22. Release Engineering, Versioning, and LiveOps](docs/STAGE_22_RELEASE_ENGINEERING_VERSIONING_LIVEOPS.md) | Production | migrations, flags, rollout, rollback, compatibility, and operations |

## Specialty paths

- [Networking Mastery Ladder](docs/NETWORKING_MASTERY_LADDER.md) — continue after Stage 12.
- [Combat Security, Aim Automation, and ESP Limits](docs/SPECIALTY_GUNKIT_ANTI_CHEAT_AIMLOCK_AIMBOT_ESP_PREVENTION.md) — begin after Stage 12; Stage 18 is recommended for lag compensation.
- [Engineering Evidence Rubric](docs/SCRIPTER_RANKING_RUBRIC.md) — assess demonstrated engineering evidence rather than technology count.

## Verification

Every numbered stage shows a complete `--!strict` program before its reference material. The verification tools enforce contiguous stages `1..22`, exact code-block/source equality, static analysis, and runtime assertions.

Static and standalone runtime checks do not prove Roblox Studio lifecycle, live-provider, network-condition, security, visual, performance, or scale behavior.
