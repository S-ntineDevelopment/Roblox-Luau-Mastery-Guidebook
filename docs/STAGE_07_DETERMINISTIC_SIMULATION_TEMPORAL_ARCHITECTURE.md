# Stage 7: Simulation Time, History, and Replay

Time-sensitive code needs explicit clocks and state history only to the degree required by the mechanic. “Deterministic” must name the environment, inputs, and tolerance being claimed.

Read [Curriculum Accuracy Standard](CURRICULUM_ACCURACY_STANDARD.md) before this stage.

## Time domains

Distinguish at least:

- render/frame time;
- simulation step/tick;
- server-observed wall/network time;
- client-local time;
- duration/deadline time;
- persisted calendar time;
- test-controlled time.

Do not compare timestamps from different clocks without a documented mapping. Do not use a client clock as authoritative proof of when an action occurred.

Injecting a clock is useful when timing behavior needs repeatable tests. Stable leaf code that simply needs current time may call the platform directly; not every function needs a clock interface.

## Fixed timestep

A fixed timestep helps with stable application update intervals, bounded history indices, and replayable pure-data logic. It does not guarantee:

- identical floating-point results on every environment;
- deterministic Roblox physics;
- identical event ordering;
- enough CPU to process every missed step.

Specify overload behavior: cap catch-up, slow simulation, drop time, degrade features, or reject the workload. Each has gameplay consequences.

## Levels of repeatability

Avoid one vague “deterministic” label. State the actual target:

1. repeatable within one test runtime;
2. repeatable client/server for a supported engine build;
3. repeatable across devices;
4. repeatable across engine versions or saved replays.

The stronger claims require stronger evidence. Engine physics and undocumented random implementation details should not be assumed stable across versions.

## Randomness

Use explicit random streams when outcome reproduction matters. Separate domains only when cross-domain consumption would otherwise change meaningful results.

Record seeds and, when necessary, decisions/outputs. A seed alone may be insufficient for long-lived replay compatibility if the algorithm or call order changes.

Never use predictable gameplay RNG for security tokens, purchase identity, or secrets.

## State machines and time

Represent meaningful temporal states directly instead of scattering booleans and loose waits:

```lua
type ChargeState =
	{ kind: "Idle" }
	| { kind: "Charging", startedTick: number }
	| { kind: "Released", releasedTick: number }
```

Use ticks for simulation-relative ordering and an appropriate clock for real deadlines. Pausing a state machine needs explicit rules for whether deadlines shift or continue.

## Events, audit logs, and event sourcing

An audit log records facts for explanation. Event sourcing reconstructs state from an authoritative event sequence. These are not synonyms.

Event sourcing adds ordering, schema evolution, replay, idempotency, storage, and correction complexity. Use it only when reconstructing state from events is an actual system requirement. Many games need periodic snapshots plus a bounded audit log instead.

## Snapshots and deltas

For each snapshot stream define:

- schema/version;
- base frame;
- full-state interval;
- delta application order;
- retention and eviction;
- checksum meaning;
- recovery from missing/corrupt history.

A checksum mismatch detects disagreement; it does not identify which side is correct or what caused it.

## Side effects during replay

Replay must not duplicate external side effects. Separate pure state transition from:

- RemoteEvents;
- purchases/rewards;
- DataStore writes;
- analytics;
- sounds/effects/UI;
- Instance creation that is not part of the restored state.

Commit or emit those effects once, after the authoritative outcome is known, using idempotency where necessary.

## Physics boundary

For each mechanic decide whether Roblox physics is:

- authoritative engine state accepted with server validation;
- predicted and corrected through the current server-authority model;
- an approximation driven by simpler authoritative data;
- presentation only.

Do not promise deterministic replay of arbitrary assemblies, Humanoids, contacts, or network-owned physics without direct platform evidence and tests.

## Practice project

Create a pure-data cooldown/projectile simulation with:

- a fake clock and fixed step;
- recorded inputs;
- seeded randomness;
- full and delta snapshots;
- a replay hash;
- a side-effect collector that emits only after replay.

Run the same fixture repeatedly and then deliberately introduce unordered table iteration or an unrecorded random call to show how the claim fails.

## Completion evidence

You understand this stage when you can:

- name the clock and units for every timestamp;
- state the exact repeatability level proven;
- separate audit logging from event sourcing;
- prevent side-effect duplication during replay;
- recover from missing delta bases;
- identify which engine behavior remains outside the deterministic boundary.

## Primary references

- [Roblox RunService API](https://create.roblox.com/docs/reference/engine/classes/RunService)
- [Roblox server-authority model](https://create.roblox.com/docs/projects/server-authority)
- [Luau standard library](https://luau.org/library/)
- [Luau performance](https://luau.org/performance/)
