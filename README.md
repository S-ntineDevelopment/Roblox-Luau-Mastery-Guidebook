# Roblox Luau Engineering Guidebook

A fact-checked Roblox/Luau curriculum ordered from basic language structures to advanced production architecture.

This repository intentionally contains learning material only. It excludes project agent instructions, private project policy, engine implementation documents, and operational checklists.

## Start here

1. [Bare Minimum Prerequisites](docs/prerequisites/BARE_MINIMUM.md)
2. [Accuracy and Applicability Standard](docs/CURRICULUM_ACCURACY_STANDARD.md)
3. [Master Curriculum and Practice Path](docs/ROBLOX_LUAU_MASTERY_CURRICULUM.md)
4. [Type-Checked Beginner Lessons](docs/lessons/README.md)

## Tier 1 — Luau foundations

1. [Tables, ModuleScripts, Metatables, and Data Structures](docs/STAGE_01_LUAU_TABLES_MODULES_METATABLES_DATA_STRUCTURES.md)
2. [Typed Luau and Static Contracts](docs/STAGE_02_TYPED_LUAU_STATIC_CONTRACTS.md)
3. [Objects, Composition, and Polymorphic Dispatch](docs/STAGE_03_OOP_COMPOSITION_POLYMORPHIC_DISPATCH.md)
4. [Coroutines, Scheduling, and Async Control Flow](docs/STAGE_04_COROUTINES_SCHEDULING_ASYNC_CONTROL_FLOW.md)

## Tier 2 — Reliable feature systems

5. [Utilities and Engine Foundations](docs/STAGE_05_UTILITY_ARCHITECTURE_ENGINE_FOUNDATION.md)
6. [Contract-First Feature Design](docs/STAGE_06_CONTRACT_FIRST_FEATURE_ARCHITECTURE.md)
7. [Runtime Tooling, Testing, and Observability](docs/STAGE_07_RUNTIME_SYSTEMS_TOOLING_OBSERVABILITY.md)
8. [Networking, Replication, and Security](docs/STAGE_08_NETWORK_ARCHITECTURE_REPLICATION_SECURITY.md)
9. [Persistence and Economy Integrity](docs/STAGE_09_PERSISTENCE_ECONOMY_TRANSACTION_INTEGRITY.md)

## Tier 3 — Advanced gameplay architecture

10. [ECS and Data-Oriented Design](docs/STAGE_10_ECS_DATA_ORIENTED_ARCHITECTURE.md)
11. [Rules Engines and Declarative Gameplay](docs/STAGE_11_RULES_ENGINES_DECLARATIVE_GAMEPLAY.md)
12. [Simulation Time, History, and Replay](docs/STAGE_12_DETERMINISTIC_SIMULATION_TEMPORAL_ARCHITECTURE.md)
13. [Prediction, Reconciliation, Lag Compensation, and Rollback](docs/STAGE_13_ROLLBACK_NETCODE_PREDICTION_RECONCILIATION.md)
14. [AI and NPC Systems](docs/STAGE_14_AI_BEHAVIOR_NPC_SYSTEMS.md)
15. [Scaling Architecture and Domain Platforms](docs/STAGE_15_LARGE_SCALE_GAME_ARCHITECTURE_DOMAIN_PLATFORMS.md)

## Tier 4 — Production mastery

16. [Templates, Code Generation, and Static Analysis](docs/STAGE_16_SOURCE_GENERATION_TEMPLATES_AND_STATIC_ANALYSIS.md)
17. [Parallel Luau and Scalability](docs/STAGE_17_PARALLELISM_ACTOR_MODEL_AND_SCALABILITY.md)
18. [Release Engineering and LiveOps](docs/STAGE_18_RELEASE_ENGINEERING_VERSIONING_AND_LIVEOPS.md)

## Specialty and extended paths

- [Networking Mastery Ladder](docs/NETWORKING_MASTERY_LADDER.md) — continue after Stage 8.
- [Combat Security, Aim Automation, and ESP Limits](docs/SPECIALTY_GUNKIT_ANTI_CHEAT_AIMLOCK_AIMBOT_ESP_PREVENTION.md) — begin after Stage 8; Stages 12-13 are recommended for lag compensation.
- [Engineering Evidence Rubric](docs/SCRIPTER_RANKING_RUBRIC.md) — assess demonstrated engineering evidence, not technology count.

## Scope

The guidebook treats patterns as options, not maturity requirements. It distinguishes platform facts, security requirements, engineering heuristics, project policy, and claims that need profiling or runtime proof. Each stage includes primary references, suggested prerequisites, a three-step beginner lesson, practice work, and completion evidence.

Every stage page shows its complete working lesson before the optional theory. The 20 standalone lesson programs use `--!strict` and assertions, and the verification script checks that the visible Markdown code exactly matches the analyzed source. Use the included scripts under `tools/` to repeat the type and runtime checks with a current Luau release.
