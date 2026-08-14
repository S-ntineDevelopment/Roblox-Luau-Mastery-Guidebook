# Stage 18: Release Engineering, Versioning, and LiveOps

**Difficulty:** Production mastery
**Suggested prerequisites:** Stages 7-9 and the advanced stages used by the project

## Guided lesson: migrate data and gate rollout

**Use case:** Convert a V1 save to V2 and enable a feature for one test user.

**Downloadable code:** [STAGE_18_MIGRATION_AND_FLAG.luau](lessons/STAGE_18_MIGRATION_AND_FLAG.luau)

### Run this before reading the theory

- **Luau CLI:** `luau docs/lessons/STAGE_18_MIGRATION_AND_FLAG.luau`
- **Roblox Studio:** paste the code into a temporary `Script` and run the experience. These examples avoid Roblox services so the first behavior is easy to see.
- Read the `Step 1`, `Step 2`, and `Step 3` comments in order.

### Complete working example

The `type` declarations are checker notes. They describe the allowed shape of a value, but they do not perform the behavior. The working behavior is in the functions, table operations, calls, and assertions below.

<!-- BEGIN VERIFIED LESSON: STAGE_18_MIGRATION_AND_FLAG.luau -->
```luau
--!strict

-- Use case: migrate an old save and enable a feature for a controlled group.

type SaveV1 = { version: "V1", coins: number }
type SaveV2 = { version: "V2", coins: number, level: number }

-- Step 1: migration returns a new current-version record.
local function migrate(save: SaveV1 | SaveV2): SaveV2
	if save.version == "V2" then
		return {
			version = "V2",
			coins = save.coins,
			level = save.level,
		}
	end

	return {
		version = "V2",
		coins = save.coins,
		level = 1,
	}
end

-- Step 2: a flag has an explicit default and allow-list override.
type FeatureFlag = {
	defaultEnabled: boolean,
	enabledUserIds: { [number]: boolean },
}

local function isEnabled(flag: FeatureFlag, userId: number): boolean
	if flag.enabledUserIds[userId] then
		return true
	end
	return flag.defaultEnabled
end

-- Step 3: verify migration and rollout behavior.
local current = migrate({ version = "V1", coins = 25 })
assert(current.version == "V2" and current.level == 1)

local flag: FeatureFlag = {
	defaultEnabled = false,
	enabledUserIds = { [101] = true },
}
assert(isEnabled(flag, 101))
assert(not isEnabled(flag, 202))

print("Stage 18 lesson passed")
```
<!-- END VERIFIED LESSON: STAGE_18_MIGRATION_AND_FLAG.luau -->

### Walk through the behavior

Read the three points, run the code, and complete **Try it**. Once you can explain the assertions, this stage's beginner pass is done. Everything after this guided lesson is optional reference material for later.

1. `migrate()` accepts either supported version and always returns a copied V2 record.
2. `FeatureFlag` declares a default plus an explicit user allow-list.
3. Assertions verify both migration and the enabled/disabled users.

- **Expected result:** V1 gains `level = 1`; user `101` is enabled while `202` is not.
- **Try it:** add a V2 input with level `4` and prove migration preserves it.
- **Common mistake:** deleting migration or compatibility code before old live data/protocols can no longer reach it.

Release engineering manages change while servers, players, saved data, and external systems may still reflect older versions. The amount of process should be proportional to the blast radius.

Read [Curriculum Accuracy Standard](CURRICULUM_ACCURACY_STANDARD.md) before this stage.

## What can coexist

Account for the versions that can actually overlap:

- old live servers after a new publish;
- players teleporting between server/place versions;
- saved records from older schemas;
- MemoryStore/MessagingService work created by older code;
- separately released packages/tools;
- external Open Cloud workers.

Do not build a general protocol migration framework for clients that cannot coexist in the same server unless another real compatibility path requires it.

## Place versions and rollback

Roblox place Version History provides published checkpoints and restoration tools. Restoring code/place content does not automatically roll back:

- DataStore migrations;
- purchases or economy mutations;
- MemoryStore messages;
- analytics/external side effects;
- incompatible content already created.

Every high-risk release needs a data-aware rollback/forward-fix decision, not only a previous place version.

## Feature flags and live configuration

Use flags/config for staged rollout, emergency disablement, or controlled experiments. Define owner, default, scope, fallback, observation, and removal date.

Roblox Configs can provide read-only live values with their documented rollout behavior. Local modules, DataStores, MemoryStores, or third-party systems have different consistency and availability. Choose based on actual requirements.

Do not leave permanent dead flags or test all possible flag combinations by assumption; combinations are product states that need coverage.

## Schema migration

Prefer migrations that are:

- versioned and idempotent;
- tested from every supported version;
- safe to retry;
- observable and bounded;
- compatible with old servers when overlap is possible;
- reversible only when data semantics truly permit it.

Sometimes a forward-fix migration is safer than down-migration. Preserve backups/evidence and avoid destructive cleanup until the rollout is proven.

## Protocol evolution

Use the smallest compatibility technique that fits:

- optional fields with safe defaults;
- versioned message variants;
- dual read/write during a bounded transition;
- reject-and-refresh for incompatible sessions;
- server/place routing that prevents incompatible peers.

Remove compatibility code after the coexistence window closes.

## Release gates

Choose checks according to risk:

- format/lint/type/build;
- deterministic fixtures and unit tests;
- Studio server/client smoke;
- migration dry run on representative copies;
- hostile-input and lifecycle repetition;
- target-device/scale profiling;
- canary percentage or private test universe;
- live dashboards and stop criteria.

A green static build cannot prove live DataStore, physics, networking, streaming, or visual behavior.

## Kill switches and degraded modes

A kill switch should prevent new risky work and define what happens to in-flight sessions. Turning a feature off may require cancelling jobs, preserving pending transactions, removing UI entry points, or leaving existing matches to finish.

Test the switch under load and dependency failure. An untested emergency path is not a reliable rollback.

## Observability and decision rules

Before release, specify:

- success and guardrail metrics;
- comparison baseline;
- sample/segment;
- alert/rollback thresholds;
- observation duration;
- person/system authorized to stop rollout.

Avoid high-cardinality or private payload logging. Monitor correctness as well as performance/business metrics.

## Practice project

Release a fake schema/protocol change through:

1. old-reader/new-writer compatibility fixture;
2. migration dry run;
3. canary flag;
4. simulated old server and teleport payload;
5. kill switch while operations are in flight;
6. place rollback showing why data still needs a forward/recovery plan;
7. removal of the temporary compatibility and flag code.

## Completion evidence

You understand this stage when you can:

- enumerate versions/data that can coexist;
- distinguish place rollback from data/effect rollback;
- migrate idempotently under old-server overlap;
- define and test in-flight kill-switch behavior;
- separate static gates from Studio/live proof;
- remove temporary rollout machinery.

## Primary references

- [Roblox Version History](https://create.roblox.com/docs/projects/version-history)
- [Roblox data stores](https://create.roblox.com/docs/cloud-services/data-stores)
- [DataStore errors and limits](https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits)
- [Choosing Roblox cloud services and Configs](https://create.roblox.com/docs/cloud-services/data-stores-vs-memory-stores)
- [Roblox memory stores](https://create.roblox.com/docs/cloud-services/memory-stores)
