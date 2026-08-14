# Type-Checked Curriculum Lessons

Every lesson is a small, standalone Luau program, and the exact program is embedded directly in its curriculum page. The files use `--!strict`, avoid hidden framework dependencies, and progress through three ideas:

1. define the smallest useful data or contract;
2. perform one real operation;
3. check the expected result with `assert()`.

**Verification snapshot:** all 20 lessons passed `luau-analyze` and the Luau CLI runtime from the official Luau `0.733` Windows release on 2026-08-14. Re-run the checks when the compiler version changes.

The examples model Roblox use cases without requiring Roblox globals, so the official Luau command-line analyzer can check them. The verification script also proves that each visible Markdown code block is identical to its checked `.luau` source. Engine-specific behavior still needs Studio/runtime verification.

Run every lesson with:

```powershell
.\tools\verify_curriculum_lessons.ps1 -LuauAnalyzePath C:\path\to\luau-analyze.exe
```

Run every lesson's assertions with:

```powershell
.\tools\run_curriculum_lessons.ps1 -LuauPath C:\path\to\luau.exe
```

Run one lesson with:

```powershell
luau-analyze docs\lessons\STAGE_01_TABLES_AND_METATABLES.luau
```

No diagnostic output and exit code `0` means the analyzer accepted the file. That proves parsing and static type consistency only; it does not prove Roblox API behavior, networking, persistence, performance, or lifecycle behavior in Studio.

## Lesson index

| Lesson | Tiny use case |
| --- | --- |
| Stage 1 | Track players, queue messages, and create a counter |
| Stage 2 | Type and validate a coin reward |
| Stage 3 | Compose a weapon from ammo and sound functions |
| Stage 4 | Cancel a countdown before stale work runs |
| Stage 5 | Reuse one small clamp utility |
| Stage 6 | Register and run a small set of actions |
| Stage 7 | Record a bounded diagnostic history |
| Stage 8 | Admit an untrusted fire request |
| Stage 9 | Apply an idempotent coin reward |
| Stage 10 | Update health records with a tiny ECS-style system |
| Stage 11 | Evaluate a small declarative reward rule |
| Stage 12 | Step and snapshot a simple simulation |
| Stage 13 | Correct prediction and replay unacknowledged input |
| Stage 14 | Select one NPC action by score |
| Stage 15 | Share one prompt rule across two features |
| Stage 16 | Validate a descriptor before generating source text |
| Stage 17 | Partition pure work and merge results |
| Stage 18 | Migrate a saved record and evaluate a feature flag |
| Networking | Check direction, sequence, and rate admission |
| Combat security | Validate cadence, ammo, and range on the server |
