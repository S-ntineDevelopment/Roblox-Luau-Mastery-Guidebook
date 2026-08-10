# Stage 8: Network Architecture, Replication, and Security

Roblox networking mastery is not knowing how to fire a RemoteEvent. It is designing a typed protocol where authority, validation, replication, bandwidth, reliability, compatibility, observability, and abuse resistance are all explicit.

Core policy:

> The network is a protocol, not a shortcut between scripts. Every message needs direction, schema, authority, validation, rate policy, reliability expectation, observability, and a migration path when it evolves.

## 1. Trust Boundaries

Trust boundaries define which side may originate, validate, mutate, and observe data.

Apply it by classifying every field:

- client intent
- server-authoritative state
- client presentation state
- owner-only state
- team-visible state
- public replicated state
- server-only state

Used for:

- guns
- vehicles
- prompts
- inventory
- economy
- missions
- NPCs
- match state

Practice:

Audit one RemoteEvent. Mark every payload field as trusted, untrusted, derived, server-owned, or presentation-only.

Mastery rule:

If a field crosses from client to server, it is hostile until validated.

## 2. Remote Protocol Design

Remote protocol design means messages are named contracts, not ad-hoc tables.

Apply it with a message catalog:

```text
FireRequested
ReloadRequested
InteractionRequested
EntityDelta
CorrectionApplied
InventoryDelta
```

Each message defines direction, type, validator, version, rate limit, and handler.

Used for:

- secure feature APIs
- refactors
- debug logs
- migrations
- generated wrappers

Practice:

Create a `NetworkSchemas` module with five messages and reject any send/receive that is not registered.

Mastery rule:

No anonymous network messages.

## 3. Replication Layers

Replication has layers:

- Roblox engine replication
- custom authoritative replication
- client prediction state
- presentation-only effects
- debug/telemetry replication

Apply it by deciding which layer owns each data type.

Used for:

- characters
- vehicles
- projectiles
- UI
- prompts
- markers
- hit effects
- state deltas

Practice:

For a weapon, split muzzle flash, ammo, damage, recoil, tracer, hitmarker, and kill confirmation into replication layers.

Mastery rule:

Do not custom-replicate what Roblox already handles well. Do not rely on Roblox replication for state that needs server validation or protocol control.

## 4. Interest Management

Interest management sends only relevant state to each client.

Apply it by filtering replication by:

- distance
- team
- line of sight
- ownership
- streaming area
- match/session
- permission
- gameplay visibility

Used for:

- ESP reduction
- bandwidth savings
- large maps
- NPCs
- markers
- interactables
- vehicles

Practice:

Build a marker replication rule that sends objective markers only to players whose team, distance, and mission state allow them to see it.

Mastery rule:

A client should not receive combat-relevant information just because it exists on the server.

## 5. Bandwidth Budgeting

Bandwidth budgeting means knowing how much each feature sends.

Apply per-feature budgets:

- bytes per second
- messages per second
- max payload size
- burst allowance
- per-player budget
- server aggregate budget

Used for:

- guns
- vehicles
- projectiles
- entity deltas
- minimaps
- NPC updates
- combat telemetry

Practice:

Add logging for message name, payload size estimate, direction, player, and send rate. Create a report for the top 10 network users.

Mastery rule:

Networking decisions without measurement are guesses.

## 6. Authority Handoff

Authority handoff controls when ownership changes.

Apply it for:

- vehicle seats
- physics network ownership
- mounted weapons
- temporary projectiles
- carried objects
- minigame sessions
- party/match ownership

Used for:

- vehicles
- physics tools
- sports mechanics
- interactions
- server reservations

Practice:

Design a vehicle authority handoff record with occupant id, vehicle id, start tick, end tick, reason, and cleanup path.

Mastery rule:

Ownership transfer must be explicit, revocable, and auditable.

## 7. Secure Command Validation

Command validation proves an action is legal before mutation.

Validate:

- player identity
- entity existence
- ownership
- permission
- distance
- cooldown
- resource cost
- state transition
- target eligibility
- sequence
- rate

Used for:

- firing
- reloading
- interaction
- purchases
- arrests/tasers
- trading
- vehicle entry
- rewards

Practice:

Create a validation pipeline that returns typed rejection reasons before any mutation occurs.

Mastery rule:

Validation comes before mutation. Always.

## 8. Abuse-Resistant Cooldowns

Cooldowns are security boundaries, not just UX.

Apply server-side timing for:

- fire rate
- reload
- prompt use
- purchases
- ability activation
- vehicle entry/exit
- reward claiming
- RemoteEvent rate

Used for:

- exploit resistance
- fairness
- server load control
- economy integrity

Practice:

Implement cooldowns with server time or simulation ticks. Prove client clock changes cannot bypass them.

Mastery rule:

Client cooldowns communicate readiness. Server cooldowns enforce readiness.

## 9. Desync Detection

Desync detection finds divergence between server truth and client mirrors.

Apply it with:

- sequence numbers
- state hashes
- component checksums
- correction counts
- rejected prediction reports
- replay records
- snapshot comparison

Used for:

- rollback
- prediction
- vehicles
- weapons
- inventory
- client mirrors

Practice:

Send a compact server state checksum every second for a predicted system. Log when the client mirror disagrees.

Mastery rule:

If clients mirror state, build a way to prove when the mirror is wrong.

## 10. Protocol Migration

Protocols evolve while players may be on different versions.

Apply:

- message version fields
- optional fields
- feature flags
- deprecation windows
- compatibility validators
- staged rollout
- old-client rejection paths

Used for:

- live updates
- gunkit changes
- vehicle rewrites
- prompt framework upgrades
- economy migrations
- buffer layout changes

Practice:

Add a version byte to one buffer message and support version 1 and version 2 decode paths.

Mastery rule:

If a protocol can change, it needs a compatibility story before production.

## Compatibility With ECS

Networking should replicate ECS state deliberately.

Use ECS for:

- authoritative server state
- client mirror state
- component deltas
- snapshots
- correction records
- interest queries

Policy:

> Replicate selected ECS state through typed protocol messages, not by leaking the whole world.

## Compatibility With OOP

OOP owns network services and adapters.

Use:

- `NetworkService`
- `RemoteAdapter`
- `SchemaRegistry`
- `ReplicationService`
- `InterestService`
- `RateLimiter`
- `ProtocolLogger`

Policy:

> Feature code should call typed network APIs, not raw RemoteEvents.

## Compatibility With Scheduling

Networking depends on timing.

Use scheduling for:

- input collection
- validation
- simulation commit
- replication flush
- rate windows
- retry windows
- correction timing

Policy:

> Network messages should be admitted and flushed in declared phases.

## Compatibility With Runtime Contracts

Runtime contracts admit network data.

Use validators for:

- RemoteEvent payloads
- buffer decode records
- sequence numbers
- entity ids
- permission
- payload length
- numeric ranges
- message versions

Policy:

> No network payload enters gameplay until it passes runtime admission.

## Compatibility With Typed Luau

Typed Luau defines the protocol.

Use types for:

- message payloads
- rejection reasons
- replication deltas
- correction records
- buffer layouts
- rate policies
- protocol versions

Policy:

> Every network schema has a static type and a runtime validator.

## Compatibility With Rollback and Temporal Architecture

Rollback uses networking as its command stream.

Use:

- sequence numbers
- ticks
- input buffers
- snapshots
- corrections
- replay records
- bounded history windows

Policy:

> Network time must map cleanly to simulation time.

## Compatibility With Anti-Cheat

Network security is the first anti-cheat layer.

Use:

- information minimization
- command validation
- rate limits
- target eligibility
- visibility filters
- marker filtering
- audit logs
- possibility reports

Policy:

> Anti-cheat starts by refusing to receive or reveal unnecessary information.

## For Gunkits

Required network design:

```text
Client -> Server:
  FireRequested
  ReloadRequested
  EquipRequested
  AimInputBatch

Server -> Client:
  FireAccepted
  FireRejected
  AmmoDelta
  HitConfirmed
  Correction
  ReplicatedCombatEvent
```

Policy:

Client messages are intent. Server messages are admitted truth or presentation permission.

## For Prompt Systems

Required network design:

```text
Client -> Server:
  InteractionRequested
  InteractionCancelled

Server -> Client:
  InteractionAccepted
  InteractionRejected
  PromptStateDelta
  RewardConfirmed
```

Policy:

Prompt rewards and completion are server transactions.

## For Vehicles

Required network design:

```text
Client -> Server:
  VehicleInputCommand
  SeatRequest

Server -> Client:
  VehicleStateDelta
  AuthorityGranted
  AuthorityRevoked
  Correction
```

Policy:

Vehicle input may be client-authored. Vehicle authority and combat/collision outcomes remain server-controlled.

## The Indefinite Framework

Your long-term Roblox framework should include:

```text
NetworkSchemaRegistry
RemoteAdapter
NetworkChannel
RateLimiter
InterestService
ReplicationService
DeltaEncoder
BufferCodec
ProtocolLogger
DesyncDetector
CompatibilityRegistry
```

## How To Master It

Practice in this order:

1. Wrap one RemoteEvent behind a typed API.
2. Add runtime schema validation.
3. Add rate limiting.
4. Add sequence numbers.
5. Add typed rejection reasons.
6. Add replication deltas.
7. Add per-player interest filtering.
8. Add payload size logging.
9. Add buffer encoding for one measured hot path.
10. Add decode tests.
11. Add state checksums.
12. Add protocol versioning.
13. Add migration tests.
14. Add fuzz tests for malformed messages.
15. Convert one real system away from raw RemoteEvent access.

## Permanent Policy

Use this rule for every future Roblox system:

> If a value crosses the network, it becomes part of a protocol. Protocols must be typed, validated, measured, observable, and secure.
