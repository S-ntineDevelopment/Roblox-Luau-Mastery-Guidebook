# Stage 18: Release Engineering, Versioning, and LiveOps

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
