# Type-Checked Curriculum Lessons

The directory contains one standalone program for every numbered stage plus networking and combat specialties. Each exact program is embedded in its curriculum page.

**Verification snapshot:** all 22 numbered stages were present and all 24 programs passed `luau-analyze` and the Luau CLI runtime from the official Luau `0.733` Windows release on 2026-08-14.

Every program uses `--!strict`, demonstrates one small behavior, marks three steps, checks results with `assert()`, and avoids framework or Roblox-global dependencies.

## Run all checks

```powershell
.\tools\verify_curriculum_lessons.ps1 -LuauAnalyzePath C:\path\to\luau-analyze.exe
```

```powershell
.\tools\run_curriculum_lessons.ps1 -LuauPath C:\path\to\luau.exe
```

## Numbered lesson index

| Stage | Program | Tiny use case |
| ---: | --- | --- |
| 1 | [STAGE_01_TABLES_RECORDS.luau](STAGE_01_TABLES_RECORDS.luau) | arrays, dictionaries, records, references, and mutation |
| 2 | [STAGE_02_FUNCTIONS_MODULES.luau](STAGE_02_FUNCTIONS_MODULES.luau) | functions, module APIs, caching, and explicit state owners |
| 3 | [STAGE_03_DATA_STRUCTURES.luau](STAGE_03_DATA_STRUCTURES.luau) | sets, stacks, queues, registries, and legal transitions |
| 4 | [STAGE_04_TYPED_LUAU.luau](STAGE_04_TYPED_LUAU.luau) | strict mode, annotations, unions, narrowing, and checker limits |
| 5 | [STAGE_05_METATABLE_COUNTER.luau](STAGE_05_METATABLE_COUNTER.luau) | method lookup, constructors, self, and metamethod limits |
| 6 | [STAGE_06_COMPOSITION.luau](STAGE_06_COMPOSITION.luau) | composed capabilities, replaceable behavior, and supplied dependencies |
| 7 | [STAGE_07_RUNTIME_PROXY_CONTRACT.luau](STAGE_07_RUNTIME_PROXY_CONTRACT.luau) | dynamic admission, write guards, capabilities, and serialization |
| 8 | [STAGE_08_ASYNC_OWNERSHIP.luau](STAGE_08_ASYNC_OWNERSHIP.luau) | cancellation, task ownership, timing policies, and cleanup |
| 9 | [STAGE_09_SMALL_UTILITY.luau](STAGE_09_SMALL_UTILITY.luau) | small reusable semantics, wrappers, caches, and test seams |
| 10 | [STAGE_10_ACTION_CONTRACT.luau](STAGE_10_ACTION_CONTRACT.luau) | feature identity, behavior contracts, registries, and shared rules |
| 11 | [STAGE_11_DIAGNOSTICS.luau](STAGE_11_DIAGNOSTICS.luau) | tests, bounded diagnostics, profiling, fuzzing, and failure evidence |
| 12 | [STAGE_12_NETWORK_VALIDATION.luau](STAGE_12_NETWORK_VALIDATION.luau) | remote protocols, runtime admission, authority, and replication |
| 13 | [STAGE_13_IDEMPOTENT_REWARD.luau](STAGE_13_IDEMPOTENT_REWARD.luau) | schema versions, idempotency, budgets, receipts, and recovery |
| 14 | [STAGE_14_TINY_ECS.luau](STAGE_14_TINY_ECS.luau) | entity identity, component stores, systems, queries, and staged mutation |
| 15 | [STAGE_15_SMALL_RULES.luau](STAGE_15_SMALL_RULES.luau) | conditions, effects, ordering, validation, and explainable evaluation |
| 16 | [STAGE_16_FIXED_STEP.luau](STAGE_16_FIXED_STEP.luau) | fixed steps, clocks, snapshots, controlled randomness, and replay limits |
| 17 | [STAGE_17_NPC_DECISION.luau](STAGE_17_NPC_DECISION.luau) | perception, decisions, actions, movement ownership, and debugging |
| 18 | [STAGE_18_RECONCILIATION.luau](STAGE_18_RECONCILIATION.luau) | client prediction, server correction, history, replay, and fairness |
| 19 | [STAGE_19_DOMAIN_PLATFORM.luau](STAGE_19_DOMAIN_PLATFORM.luau) | shared domain rules, extension points, compatibility, and ownership |
| 20 | [STAGE_20_GENERATION.luau](STAGE_20_GENERATION.luau) | validated descriptors, deterministic output, audits, and generated ownership |
| 21 | [STAGE_21_PARTITION_AND_MERGE.luau](STAGE_21_PARTITION_AND_MERGE.luau) | partitioning, Actors, thread safety, communication, and merge phases |
| 22 | [STAGE_22_MIGRATION_AND_FLAG.luau](STAGE_22_MIGRATION_AND_FLAG.luau) | migrations, flags, rollout, rollback, compatibility, and operations |

## Specialty lessons

- [NETWORKING_LADDER_ADMISSION.luau](NETWORKING_LADDER_ADMISSION.luau)
- [COMBAT_SERVER_VALIDATION.luau](COMBAT_SERVER_VALIDATION.luau)

No analyzer diagnostics prove parsing and static type consistency for that exact compiler. Passing assertions prove only the modeled standalone behavior.
