# Stage 7: Deterministic Simulation and Temporal Architecture

Deterministic simulation is the discipline of making important game outcomes reproducible from the same starting state and the same inputs. Temporal architecture is the discipline of making time explicit: real time, server time, client time, render time, simulation ticks, cooldown time, replay time, and network time are not the same thing.

Core policy:

> Important gameplay should not depend on accidental timing. If a system affects authority, rollback, replay, validation, economy, combat, or fairness, its time model must be explicit.

## 1. Deterministic Math Policy

Deterministic math means using calculations that produce predictable enough results for the mechanic.

Apply it by avoiding hidden randomness, uncontrolled physics dependence, unordered iteration, and frame-dependent accumulation in replay-sensitive systems.

Used for:

- rollback
- projectiles
- melee hitboxes
- combat validation
- cooldowns
- procedural encounters
- replay tests
- economy transactions

Practice:

Build a small projectile simulation that receives position, velocity, and fixed `dt`. Run it twice with the same input and verify the final state is identical.

Mastery rule:

If you need to replay it, the same input must produce the same result.

## 2. Seeded Random Streams

Seeded random streams make random outcomes reproducible.

Apply it by giving each domain its own random stream:

- combat spread
- loot rolls
- NPC decisions
- procedural placement
- minigame generation
- cosmetic variance

Used for:

- rollback
- audit logs
- replay
- fairness checks
- procedural generation
- anti-cheat review

Practice:

Create a combat RNG stream and a loot RNG stream. Prove that changing loot rolls does not change combat spread.

Mastery rule:

Randomness should be isolated by domain. One system's random calls should not change another system's outcomes.

## 3. Fixed-Point and Quantized Approximations

Sometimes stable approximations are better than uncontrolled precision.

Apply it by quantizing positions, angles, velocities, recoil, spread, and input values where exact floating-point precision is unnecessary.

Used for:

- buffer networking
- rollback
- hit validation
- vehicle telemetry
- combat input
- replay compression

Practice:

Quantize an aim yaw angle into `0-65535`, send it through a typed record, decode it, and measure the maximum angular error.

Mastery rule:

Precision is a budget. Spend only what the mechanic needs.

## 4. Simulation Clocks

Different clocks serve different jobs.

Apply separate clocks for:

- server wall time
- simulation tick time
- client render time
- cooldown time
- network timestamp time
- replay time
- test fake time

Used for:

- cooldowns
- prediction
- rollback
- replay
- networking
- UI timers
- minigames
- vehicle simulation

Practice:

Create a `Clock` contract with real and fake implementations. Use fake time to test cooldowns without waiting.

Mastery rule:

Never let important gameplay logic depend on an unnamed clock.

## 5. Temporal State Machines

Temporal state machines model states that change over time.

Apply them with discriminated unions:

```lua
export type ReloadState =
	{kind: "Idle"}
	| {kind: "Reloading", startedTick: number, endsTick: number}
	| {kind: "Cancelled", reason: string}
```

Used for:

- reloads
- prompts
- minigames
- vehicle occupancy
- match flow
- ability casts
- cooldowns
- status effects

Practice:

Replace a reload `task.wait` flow with a tick-based `ReloadState` processed by a system.

Mastery rule:

If time changes the legal state, model the state explicitly.

## 6. Event Sourcing

Event sourcing records what happened as commands or domain events.

Apply it by recording authoritative events:

- weapon fired
- damage applied
- item purchased
- prompt completed
- vehicle entered
- match started
- reward granted

Used for:

- audit logs
- replay
- rollback
- economy integrity
- debugging
- desync investigation

Practice:

For a purchase transaction, record `PurchaseRequested`, `PurchaseValidated`, `CurrencyDebited`, `ItemGranted`, and `PurchaseCompleted`.

Mastery rule:

For important outcomes, the system should be able to explain the path, not just the final value.

## 7. Snapshot Delta Encoding

Snapshot delta encoding stores only meaningful changes between states.

Apply it by comparing current and previous snapshots and recording changed components or fields.

Used for:

- replication
- rollback history
- replay storage
- desync debugging
- bandwidth reduction
- save diffing

Practice:

Create snapshots for 100 entities with Health and Position. Store only entities whose components changed since the previous tick.

Mastery rule:

Full snapshots are for recovery. Deltas are for regular flow.

## 8. Deterministic Physics Boundaries

Roblox physics is powerful, but not always deterministic enough for replay-sensitive authority.

Apply a boundary decision:

- physics as authority
- physics as approximation
- physics as presentation
- simplified simulation as authority

Used for:

- vehicles
- projectiles
- ragdolls
- thrown objects
- collisions
- suspension
- sports mechanics

Practice:

For one projectile type, compare Roblox physics movement against a simple server-authored kinematic simulation. Decide which one owns authority and which one presents.

Mastery rule:

Do not assume engine physics is rollback-safe. Assign its authority role explicitly.

## 9. Replay Tooling

Replay tooling lets you reproduce bugs from inputs and state.

Apply it by capturing:

- starting snapshot
- input commands
- authoritative events
- random seeds
- tick range
- config version
- rejection reasons

Used for:

- combat bugs
- anti-cheat review
- rollback debugging
- vehicle desync
- economy audits
- minigame fairness

Practice:

Record a 10-second combat replay with commands, snapshots, and RNG seed. Re-run it in a test harness and verify the same final state.

Mastery rule:

If you cannot reproduce a bug, you do not fully own the system.

## 10. Time-Travel Debugging

Time-travel debugging lets you inspect historical state and transitions.

Apply it with bounded history buffers and debug views:

- entity state by tick
- component diffs
- event log
- command log
- network messages
- validation results
- RNG outputs

Used for:

- desyncs
- suspicious shots
- state corruption
- failed transactions
- cooldown bugs
- rollback corrections

Practice:

Build a debug dump for one entity showing its last 30 ticks of Health, Position, active states, and events.

Mastery rule:

The system should explain not only what is true now, but how it became true.

## Compatibility With ECS

ECS is the ideal shape for deterministic simulation.

ECS provides:

```text
Plain component state
Stable entity ids
System phases
Mutation pipelines
Snapshots
Queries
```

Temporal architecture provides:

```text
Ticks
State history
Events
Replay
Clock boundaries
Delta snapshots
```

Policy:

> ECS defines the state. Temporal architecture defines its history.

## Compatibility With OOP

OOP owns the tools and services around deterministic systems.

Use OOP for:

- `ClockService`
- `ReplayService`
- `SnapshotStore`
- `EventLog`
- `RandomStream`
- `TimeTravelDebugger`
- `PhysicsAuthorityAdapter`

Policy:

> OOP owns temporal machinery. ECS owns temporal data.

## Compatibility With Scheduling

Scheduling is the execution form of temporal architecture.

Use scheduling for:

- fixed tick loops
- event ordering
- snapshot timing
- replay stepping
- network flush timing
- cleanup windows

Policy:

> Temporal architecture without scheduler discipline is just timestamps.

## Compatibility With Runtime Contracts

Runtime contracts protect temporal boundaries.

Validate:

- tick ids
- event shapes
- command order
- replay admission
- snapshot shape
- random stream identity
- historical window bounds

Policy:

> A replayed event must be at least as valid as a live event.

## Compatibility With Typed Luau

Typed Luau makes time explicit.

Use types for:

- `Tick`
- `FrameId`
- `Command`
- `DomainEvent`
- `Snapshot`
- `SnapshotDelta`
- `ReplayRecord`
- `RandomStreamId`
- `Clock`

Policy:

> If time matters, type the time value.

## Compatibility With Rollback

Rollback depends directly on deterministic temporal design.

Use:

- fixed ticks
- command history
- snapshots
- replay runner
- deterministic RNG
- presentation separation
- debug frame history

Policy:

> Rollback is temporal architecture under latency pressure.

## For Gunkits

Apply deterministic temporal design to:

- fire cadence
- reload timing
- burst timing
- recoil recovery
- spread recovery
- projectile simulation
- hitscan lag compensation
- damage events
- anti-cheat audit logs
- replayable shot decisions

Strong design:

```text
FireCommand at tick N
Server validates weapon state at tick N
Lag compensation reads historical hitbox state
DamageTransaction emits domain event
Replay log records command, result, and rejection reason
```

## For Prompt Systems

Apply to:

- hold duration
- cooldowns
- session timeout
- minigame timer
- reward transaction
- cancellation
- player leaving
- streamed object removal

Policy:

Prompt outcomes should be modeled as timed server transactions, not loose waits.

## For Vehicles

Apply to:

- input sampling
- fixed-step vehicle state
- suspension telemetry
- authority handoff
- correction windows
- replayable collision decisions
- physics boundary choices

Policy:

Vehicle systems must explicitly decide which state is physics-authored, server-authored, predicted, or presentation-only.

## The Indefinite Framework

Your long-term Roblox framework should include:

```text
Clock
FakeClock
Tick
FixedStepLoop
RandomStream
DomainEventLog
SnapshotStore
SnapshotDelta
ReplayRunner
HistoryBuffer
TimeTravelDebugger
PhysicsAuthorityPolicy
```

## How To Master It

Practice in this order:

1. Build a fixed-step simulation.
2. Add typed ticks.
3. Add a fake clock.
4. Add seeded random streams.
5. Add temporal state machines.
6. Add event logs.
7. Add snapshots.
8. Add snapshot deltas.
9. Add replay from command history.
10. Add time-travel debug dumps.
11. Add deterministic projectile tests.
12. Add lag-compensated shot replay.
13. Add physics authority decisions.
14. Add vehicle/prompt/gun temporal reviews.
15. Convert one real feature from waits to explicit tick/state logic.

## Permanent Policy

Use this rule for every future Roblox system:

> If a bug, exploit, rollback, transaction, or replay depends on when something happened, the system must store time explicitly and make that time inspectable.

The true mastery is combining temporal architecture with the earlier stages:

- ECS stores replayable state.
- OOP owns temporal services.
- Scheduling runs fixed phases.
- Runtime contracts validate commands and events.
- Typed Luau names time and state.
- Rollback replays history.
- Anti-cheat compares actual events against possible histories.
