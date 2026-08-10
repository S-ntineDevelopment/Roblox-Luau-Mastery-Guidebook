# Stage 6: Rollback Netcode, Prediction, and Reconciliation

Rollback netcode is not a single trick. It is the result of disciplined state architecture, typed inputs, fixed ticks, snapshots, replay, authority, prediction, reconciliation, and presentation smoothing. In Roblox, it must be designed carefully because engine physics, replication, and client authority can easily fight the model.

Core policy:

> The server owns truth. The client may predict responsiveness. Rollback and reconciliation must operate on explicit typed simulation state, not hidden Roblox Instance behavior.

## 1. Server Authority

Server authority means the server decides the real outcome of gameplay.

Apply it by making clients send intent, not final results.

Used for:

- weapon firing
- damage
- ammo
- movement validation
- hit validation
- ability activation
- inventory
- economy
- objectives

Practice:

Build a dash request where the client sends `DashRequested`. The server checks cooldown, player state, direction, stamina, and distance before committing the dash.

Mastery rule:

The client may say "I want to do this." The server decides whether it happened.

## 2. Input Commands

Input commands are compact records of player intent at a specific time or tick.

Apply it by converting raw input into typed commands:

```lua
export type InputCommand = {
	playerId: PlayerId,
	sequence: number,
	clientTick: number,
	moveX: number,
	moveZ: number,
	buttons: number,
	aimYaw: number,
	aimPitch: number,
}
```

Used for:

- movement
- dashing
- fighting games
- weapon fmakeiring
- vehicle input
- rollback replay
- prediction

Practice:

Record 120 input commands for one player. Replay them into a simple movement simulation and prove the same final position is produced.

Mastery rule:

Rollback replays commands, not key presses scattered across scripts.

## 3. Fixed Tick Simulation

Fixed tick simulation advances gameplay in equal time steps.

Apply it by running simulation at a stable rate, such as 30 or 60 ticks per second.

Used for:

- rollback
- prediction
- replay tests
- projectile simulation
- combat validation
- vehicle correction
- deterministic cooldowns

Practice:

Create a fixed 30 Hz simulation loop. Feed it the same input commands twice and verify identical output.

Mastery rule:

Rollback needs discrete frames. Arbitrary waits and frame-dependent deltas make replay unreliable.

## 4. State Snapshots

Snapshots capture the simulation state at a tick so the system can restore it later.

Apply it by storing only serializable simulation data:

- entity positions
- velocities
- health
- ammo
- cooldowns
- status effects
- active projectiles
- sequence numbers

Used for:

- rollback
- replay
- desync debugging
- late join recovery
- correction
- test fixtures

Practice:

Store the last 60 ticks of simplified combat state. Restore tick 40, replay ticks 41-60, and compare the final state.

Mastery rule:

Snapshot data, not objects, Instances, connections, coroutines, or metatables.

## 5. Client Prediction

Client prediction simulates expected local results immediately so gameplay feels responsive.

Apply it by letting the client predict movement, dash, recoil, projectiles, or ability startup while waiting for server confirmation.

Used for:

- movement
- dashing
- shooting feel
- melee startup
- vehicle steering
- camera/recoil presentation
- sports mechanics

Practice:

Make a client-predicted dash. The client moves immediately, sends the input command, and stores pending commands until the server confirms.

Mastery rule:

Prediction improves feel. It does not grant authority.

## 6. Server Reconciliation

Reconciliation corrects the client when server truth disagrees with prediction.

Apply it by sending authoritative state plus the last processed input sequence. The client rewinds to that state and reapplies unconfirmed local inputs.

Used for:

- movement correction
- dash correction
- projectile correction
- vehicle correction
- combat state correction
- ability cancellation

Practice:

Simulate server rejection of every third dash. The client should correct to server state, replay remaining valid inputs, and smooth the visual correction.

Mastery rule:

A correction is not a failure. It is the normal cost of predicting before truth arrives.

## 7. Rollback and Replay

Rollback restores a previous state, inserts or corrects an input, and replays forward.

Apply it when late information changes the outcome of a previous frame.

Used for:

- fighting games
- melee hit validation
- projectile correction
- dash collisions
- latency-compensated shots
- competitive movement

Practice:

Build a two-player 2D hitbox simulation. Store snapshots and inputs. When a delayed punch input arrives, rollback to that tick, apply it, and replay to the present.

Mastery rule:

Rollback is only as good as the determinism of the state it replays.

## 8. Lag Compensation

Lag compensation validates actions against historical server state.

Apply it by keeping short history buffers for target positions, hitboxes, and relevant combat state.

Used for:

- hitscan weapons
- melee attacks
- tackles
- sports collisions
- ability targeting
- projectiles with rewind validation

Practice:

Store 200 ms of target hitbox history. When a player fires, validate against the target position at the shooter's reported tick, clamped by server sanity rules.

Mastery rule:

Lag compensation should help honest latency, not allow impossible client claims.

## 9. Presentation Smoothing

Presentation smoothing hides corrections without lying about server truth.

Apply it with interpolation, extrapolation, correction blending, animation masking, and camera-only smoothing.

Used for:

- movement
- vehicle correction
- projectile correction
- hit reactions
- remote player movement
- recoil/camera

Practice:

Apply an instant server position correction to simulation state, but visually blend the model over 100 ms unless the error is too large.

Mastery rule:

Correct simulation immediately. Smooth presentation separately.

## 10. Anti-Cheat Constraints

Rollback and prediction must not weaken security.

Apply strict server validation:

- input rate
- sequence order
- movement distance
- aim limits
- cooldowns
- resource costs
- line of sight
- hitbox sanity
- historical tick bounds
- replay attack protection

Used for:

- combat
- movement
- vehicles
- economy actions
- competitive systems
- trading

Practice:

Reject input commands that are too old, too far in the future, out of sequence, too frequent, or physically impossible.

Mastery rule:

Prediction is for responsiveness. Validation is for truth.

## Compatibility With ECS

Rollback is easiest when simulation state is already ECS-shaped.

ECS provides:

```text
Entity ids
Plain components
System phases
Mutation pipeline
Snapshots
Queries
Debug inspection
```

Rollback provides:

```text
Input history
State history
Replay
Correction
Desync detection
Historical validation
```

The correct relationship:

- rollback snapshots store ECS component data
- systems run in fixed deterministic phases
- replay uses the same mutation pipeline as live simulation
- entity ids remain stable across snapshot/restore
- presentation components are excluded or separated

Policy:

> Rollback should replay ECS simulation, not Roblox presentation.

## Compatibility With OOP

OOP owns the services around rollback.

OOP provides:

```text
PredictionService
RollbackService
SnapshotStore
InputBuffer
NetworkChannel
PresentationCorrector
HitValidationService
```

Rollback provides:

```text
Commands
Snapshots
Replay
Reconciliation
History windows
Correction results
```

The correct relationship:

- services own buffers and lifecycle
- adapters translate Roblox input into commands
- runtime objects do not store authoritative rollback state
- services expose narrow typed APIs
- cleanup clears per-player histories

Policy:

> OOP owns rollback machinery. ECS owns rollback data.

## Compatibility With Scheduling

Rollback depends on scheduling discipline.

Scheduling provides:

```text
Fixed ticks
System order
Input sampling
Network flush phases
Replay loops
Correction timing
Presentation phases
```

Rollback provides:

```text
Frame history
Input sequence
Deterministic replay
Server reconciliation
Lag compensation
```

The correct relationship:

- input is sampled before simulation
- commands are applied in tick order
- snapshots are captured at tick boundaries
- replication flushes after state commit
- presentation smoothing runs after correction

Policy:

> If tick order is unclear, rollback correctness is unclear.

## Compatibility With Runtime Contracts

Rollback handles untrusted timing-sensitive data, so contracts are mandatory.

Runtime contracts provide:

```text
Input validation
Snapshot admission
Buffer decode checks
Sequence checks
Historical tick bounds
Correction result validation
```

Rollback provides:

```text
Commands
History
Replay
Correction
Prediction
Lag compensation
```

Policy:

> Every replayed command must pass the same authority contract as a live command.

## Compatibility With Typed Luau

Typed Luau makes rollback records explicit.

Types provide:

```text
InputCommand
Snapshot
FrameId
SequenceId
PredictionState
Correction
RollbackResult
HitValidationResult
```

Rollback provides:

```text
The runtime behavior behind those contracts
```

Policy:

> Rollback data structures must be typed before they are optimized or buffer-packed.

## For Gunkits

Apply rollback concepts to:

- fire input sequence
- aim command records
- ammo/cooldown validation
- hitscan lag compensation
- projectile history
- damage authority
- hitmarker prediction
- recoil presentation
- server correction
- anti-cheat validation

Strong design:

```text
Client sends typed FireCommand
Server validates sequence, cooldown, ammo, owner, and aim sanity
Server checks historical hitbox state for lag compensation
Damage transaction commits on server
Client predicts presentation only
Correction updates client mirror state
```

## For Prompt Systems

Most prompt systems do not need full rollback, but they need prediction discipline.

Apply to:

- local prompt UI responsiveness
- server interaction validation
- hold-duration confirmation
- cancellation on movement/removal
- server rejection feedback
- cooldown correction

Policy:

Prompt UI may predict affordances. Prompt outcomes remain server-authoritative.

## For Vehicles

Vehicles are one of the hardest Roblox rollback-adjacent domains.

Apply to:

- input command recording
- steering/throttle prediction
- server correction
- interpolation
- authority handoff
- physics ownership sanity
- suspension telemetry
- collision validation

Policy:

If Roblox physics is too nondeterministic for full rollback, use prediction/reconciliation with simplified authoritative state and presentation smoothing.

## The Indefinite Framework

Your long-term Roblox framework should include:

```text
InputBuffer
CommandSchema
FixedTickSimulator
SnapshotStore
ReplayRunner
PredictionService
ReconciliationService
LagCompensationService
HistoryBuffer
CorrectionSmoother
DesyncDetector
RollbackDebugger
```

Each piece has a permanent role:

- `InputBuffer` stores ordered commands.
- `CommandSchema` defines typed inputs.
- `FixedTickSimulator` advances state.
- `SnapshotStore` captures history.
- `ReplayRunner` restores and reapplies inputs.
- `PredictionService` runs client-local expected state.
- `ReconciliationService` applies server truth.
- `LagCompensationService` validates historical hits.
- `HistoryBuffer` stores bounded past state.
- `CorrectionSmoother` hides visual corrections.
- `DesyncDetector` compares checksums or state signatures.
- `RollbackDebugger` reproduces frame history.

## How To Master It

Practice in this order:

1. Build a fixed-tick 2D movement simulation.
2. Record typed input commands.
3. Replay commands deterministically.
4. Add snapshots.
5. Restore a snapshot and replay forward.
6. Add client prediction.
7. Add server reconciliation.
8. Add visual correction smoothing.
9. Add sequence numbers.
10. Add input validation and rate limits.
11. Add lag-compensated hitscan validation.
12. Add rollback for a simple melee hitbox.
13. Add debug frame history.
14. Add desync checksums.
15. Buffer-pack input commands only after the typed table version is correct.

The best first real project is a simple dash or top-down movement simulation. Then apply lag compensation to a hitscan weapon. Only then attempt more complex rollback combat.

## Permanent Policy

Use this rule for every future Roblox system:

> If a mechanic needs instant feel under latency, design prediction first. If it needs fair historical validation, design lag compensation. If it needs late input to change past outcomes, design rollback.

The true mastery is combining the first six stages:

- ECS defines rollback-friendly state.
- OOP owns rollback services and adapters.
- Scheduling creates fixed ticks and replay order.
- Runtime contracts protect input and snapshot boundaries.
- Static types define command, snapshot, and correction records.
- Rollback turns those pieces into responsive, fair multiplayer.

When these six agree, Roblox systems can feel responsive without surrendering authority.
