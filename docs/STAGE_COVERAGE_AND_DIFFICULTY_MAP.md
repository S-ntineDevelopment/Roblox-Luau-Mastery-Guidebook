# Stage Coverage and Difficulty Map

This map prevents silent omissions and difficulty regressions. Numbered files must remain contiguous from Stage 1 through Stage 22.

## Final low-to-high order

| Rank | Stage | Coverage |
| ---: | --- | --- |
| 01/22 | [Tables, Records, and Mutation](STAGE_01_TABLES_RECORDS_MUTATION.md) | arrays, dictionaries, records, references, and mutation |
| 02/22 | [Functions, ModuleScripts, and State Ownership](STAGE_02_FUNCTIONS_MODULES_STATE_OWNERSHIP.md) | functions, module APIs, caching, and explicit state owners |
| 03/22 | [Common Data Structures and State Machines](STAGE_03_COMMON_DATA_STRUCTURES.md) | sets, stacks, queues, registries, and legal transitions |
| 04/22 | [Typed Luau and Static Contracts](STAGE_04_TYPED_LUAU_STATIC_CONTRACTS.md) | strict mode, annotations, unions, narrowing, and checker limits |
| 05/22 | [Metatables and Object Methods](STAGE_05_METATABLES_OBJECT_METHODS.md) | method lookup, constructors, self, and metamethod limits |
| 06/22 | [Composition, Polymorphic Dispatch, and Dependency Injection](STAGE_06_COMPOSITION_POLYMORPHIC_DISPATCH_DEPENDENCY_INJECTION.md) | composed capabilities, replaceable behavior, and supplied dependencies |
| 07/22 | [Runtime Validation, Proxies, and Contracts](STAGE_07_RUNTIME_VALIDATION_PROXIES_CONTRACTS.md) | dynamic admission, write guards, capabilities, and serialization |
| 08/22 | [Async Ownership, Lifecycle, and Scheduling](STAGE_08_ASYNC_LIFECYCLE_SCHEDULING.md) | cancellation, task ownership, timing policies, and cleanup |
| 09/22 | [Utilities, Adapters, and Engine Foundations](STAGE_09_UTILITY_ARCHITECTURE_ENGINE_FOUNDATIONS.md) | small reusable semantics, wrappers, caches, and test seams |
| 10/22 | [Contract-First Feature Architecture](STAGE_10_CONTRACT_FIRST_FEATURE_ARCHITECTURE.md) | feature identity, behavior contracts, registries, and shared rules |
| 11/22 | [Testing, Tooling, and Observability](STAGE_11_TESTING_TOOLING_OBSERVABILITY.md) | tests, bounded diagnostics, profiling, fuzzing, and failure evidence |
| 12/22 | [Networking, Replication, and Security](STAGE_12_NETWORKING_REPLICATION_SECURITY.md) | remote protocols, runtime admission, authority, and replication |
| 13/22 | [Persistence, Economy, and Transaction Integrity](STAGE_13_PERSISTENCE_ECONOMY_TRANSACTION_INTEGRITY.md) | schema versions, idempotency, budgets, receipts, and recovery |
| 14/22 | [ECS and Data-Oriented Architecture](STAGE_14_ECS_DATA_ORIENTED_ARCHITECTURE.md) | entity identity, component stores, systems, queries, and staged mutation |
| 15/22 | [Rules Engines and Declarative Gameplay](STAGE_15_RULES_ENGINES_DECLARATIVE_GAMEPLAY.md) | conditions, effects, ordering, validation, and explainable evaluation |
| 16/22 | [Deterministic Simulation, Time, and Replay](STAGE_16_DETERMINISTIC_SIMULATION_TEMPORAL_ARCHITECTURE.md) | fixed steps, clocks, snapshots, controlled randomness, and replay limits |
| 17/22 | [AI Behavior and NPC Systems](STAGE_17_AI_BEHAVIOR_NPC_SYSTEMS.md) | perception, decisions, actions, movement ownership, and debugging |
| 18/22 | [Prediction, Reconciliation, Lag Compensation, and Rollback](STAGE_18_PREDICTION_RECONCILIATION_ROLLBACK.md) | client prediction, server correction, history, replay, and fairness |
| 19/22 | [Domain Platforms and Large-Scale Architecture](STAGE_19_DOMAIN_PLATFORMS_LARGE_SCALE_ARCHITECTURE.md) | shared domain rules, extension points, compatibility, and ownership |
| 20/22 | [Source Generation, Templates, and Static Analysis](STAGE_20_SOURCE_GENERATION_TEMPLATES_STATIC_ANALYSIS.md) | validated descriptors, deterministic output, audits, and generated ownership |
| 21/22 | [Parallel Luau, Actors, and Scalability](STAGE_21_PARALLEL_LUAU_ACTORS_SCALABILITY.md) | partitioning, Actors, thread safety, communication, and merge phases |
| 22/22 | [Release Engineering, Versioning, and LiveOps](STAGE_22_RELEASE_ENGINEERING_VERSIONING_LIVEOPS.md) | migrations, flags, rollout, rollback, compatibility, and operations |

## Original curriculum coverage

| Original topic | Final stage(s) |
| --- | --- |
| ECS and data-oriented architecture | 14 |
| OOP, composition, and polymorphic dispatch | 5-6 |
| Coroutines, scheduling, and async control flow | 8 |
| Metatables, proxies, and runtime contracts | 5 and 7 |
| Typed Luau and static contracts | 4 |
| Rollback, prediction, and reconciliation | 18 |
| Deterministic simulation and temporal architecture | 16 |
| Network architecture, replication, and security | 12 |
| Runtime systems, tooling, and observability | 11 |
| Large-scale architecture and domain platforms | 19 |
| Persistence, economy integrity, and transactions | 13 |
| Utility architecture and engine foundations | 9 |
| AI behavior and NPC systems | 17 |
| Contract-first feature architecture | 10 |
| Rules engines and declarative gameplay | 15 |
| Source generation, templates, and static analysis | 20 |
| Parallel Luau, Actors, and scalability | 21 |
| Release engineering, versioning, and LiveOps | 22 |

## Added missing foundations

- Stage 1: tables, records, references, and mutation;
- Stage 2: functions, ModuleScripts, caching, and state ownership;
- Stage 3: sets, stacks, queues, registries, and state machines.

`tools/verify_curriculum_lessons.ps1` enforces stage count, numbering, filenames, title/rank agreement, embedded programs, and code/source equality.
