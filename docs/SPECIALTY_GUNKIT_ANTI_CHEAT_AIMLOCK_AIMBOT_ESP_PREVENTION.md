# Specialty Curriculum: Aimlock, Aimbot, and ESP Prevention

This curriculum is for Roblox gun systems, combat systems, vehicle weapons, tactical tools, and any competitive feature where client-side cheating can distort aim, visibility, timing, target selection, or damage.

Core reality:

> You cannot fully prevent hostile client-side aimlock, aimbot, or ESP in Roblox. You can reduce useful information, remove client authority, validate claims, detect impossible patterns, slow abuse, and design systems where cheating produces less value.

Core policy:

> The client may render, predict, and request. The server validates visibility, timing, geometry, weapon state, ammunition, cooldown, target eligibility, and damage. The client never decides hits, damage, rewards, or authoritative target state.

## 1. Threat Model Discipline

Threat modeling means naming exactly what the attacker can do.

Assume an exploiter can:

- read client-visible Instances
- inspect replicated values
- call remotes
- alter local scripts
- spoof input payloads
- automate aim
- track visible targets
- spam requests
- tamper with UI
- lie about timing

Used for:

- gun systems
- melee systems
- NPC targeting
- arrest/taser systems
- vehicle weapons
- tactical prompts
- competitive scoring

Practice:

Write a threat model for one weapon. List what the client currently knows, what it can request, what the server validates, and what would happen if the client lies about every field.

Mastery rule:

Anti-cheat starts by assuming the client is already compromised.

## 2. Server-Authoritative Hit Validation

The server must decide whether a shot hit.

Apply it by making the client send intent:

- weapon id
- input sequence
- client tick
- aim direction
- fire origin candidate

The server validates:

- owner
- equipped weapon
- ammo
- cooldown
- allowed fire mode
- origin sanity
- direction sanity
- line of sight
- target eligibility
- damage rules

Used for:

- hitscan
- projectiles
- shotguns
- tasers
- explosives
- melee cones

Practice:

Build a `FireRequested` handler that rejects any client-reported target or damage. The server recomputes the raycast and damage transaction.

Mastery rule:

Never trust client-reported hit, damage, headshot, wallbang, kill, or target id as authoritative.

## 3. Information Minimization

ESP becomes stronger when the client receives unnecessary information.

Apply it by limiting replicated combat-relevant state to what a client needs.

Reduce exposure of:

- hidden players
- exact health of enemies
- team/private role metadata
- objective secrets
- invisible markers
- server-only hitboxes
- unspawned loot
- hidden NPC paths
- through-wall interactables

Used for:

- competitive combat
- stealth
- police/criminal systems
- heists
- hidden objectives
- tactical UI

Practice:

Audit one combat system and divide state into:

- must replicate
- may replicate approximately
- owner-only
- team-only
- server-only

Mastery rule:

The best ESP prevention is not replicating information the client does not need.

## 4. Visibility and Line-of-Sight Authority

The server should validate whether a target could be seen or hit.

Apply it with server-side raycasts, occlusion checks, range checks, and historical hitbox validation.

Used for:

- hitscan guns
- tasers
- lock-on weapons
- detection tools
- nameplate visibility
- spotting mechanics
- NPC aggro

Practice:

Create a server `CanSeeTarget` function that checks distance, team rules, alive state, and raycast occlusion. Use it before confirming damage or target lock.

Mastery rule:

Client camera visibility is useful for presentation. Server geometry decides authority.

## 5. Aim Sanity and Human-Limit Heuristics

Aimlock and aimbots often produce abnormal aim patterns.

Apply detection heuristics carefully. Do not instantly ban from one suspicious event. Accumulate evidence.

Signals:

- repeated perfect angular snaps
- impossible turn speed
- low reaction time after target appears
- high headshot rate across contexts
- tracking through occlusion
- target switching with machine-like timing
- no overshoot or correction noise
- firing on the first valid frame repeatedly

Used for:

- flagging suspicious accounts
- shadow review
- matchmaking trust
- server-side aim assist limits
- competitive analytics

Practice:

Record aim delta, target visibility time, shot timing, hit location, and occlusion state for each shot. Build a suspicion score but do not punish automatically yet.

Mastery rule:

Heuristics are evidence, not proof. Use them to investigate, limit, or escalate.

## 6. Input and Fire Cadence Validation

Exploiters often bypass local cooldowns and fire faster than intended.

Apply server validation for:

- fire interval
- burst timing
- reload duration
- equip delay
- chamber state
- ammo count
- magazine state
- rate limits
- sequence order

Used for:

- all guns
- charge weapons
- burst weapons
- shotguns
- explosives
- melee cooldowns

Practice:

Move every fire cadence rule to server validation. Delete or ignore any client-side-only cooldown that affects authority.

Mastery rule:

Client cooldowns are UX. Server cooldowns are law.

## 7. Remote Protocol Hardening

Gun remotes are high-value attack surfaces.

Apply strict schemas, rate limits, sequence numbers, idempotency, and payload bounds.

Validate:

- payload type
- field count
- vector magnitude
- numeric ranges
- sequence order
- request frequency
- weapon ownership
- target existence
- message version

Used for:

- firing
- reloading
- equipping
- aiming
- attachment changes
- hit confirmations
- projectile updates

Practice:

Fuzz the fire remote with malformed payloads: missing fields, wrong types, huge vectors, old sequence numbers, future ticks, fake weapon ids, and duplicate requests. Every case must fail safely.

Mastery rule:

Every combat remote is hostile input until admitted by a validator.

## 8. Lag Compensation Without Trusting the Client

Lag compensation helps honest latency, but it can be abused if client time is trusted too much.

Apply bounded historical validation:

- keep server-side hitbox history
- clamp accepted client tick age
- reject future ticks
- reject excessive rewind
- validate origin and direction
- require target eligibility at historical time
- apply weapon-specific penetration/range rules

Used for:

- hitscan guns
- fast projectiles
- melee validation
- tasers
- sports collisions

Practice:

Store 200 ms of server target history. Validate a shot against historical position only if the reported tick is inside the allowed latency window.

Mastery rule:

Lag compensation is server-controlled mercy for latency, not a license for client-authored hits.

## 9. Server-Side Target Eligibility

Aimbots exploit weak target rules.

Apply server target eligibility before damage:

- alive
- in match/session
- not protected
- not same team unless friendly fire allowed
- not spawn-protected
- not behind hard cover unless penetration allows it
- within weapon range
- within valid angle/cone
- not immune due to state

Used for:

- guns
- melee
- tasers
- lock-on tools
- NPC attacks
- abilities

Practice:

Create `CanDamage(attacker, target, weapon, context)`. Every damage path must use it, including projectiles and explosives.

Mastery rule:

Damage is a transaction. Target eligibility is part of that transaction.

## 10. Deception-Resistant Client Presentation

Some client effects should be predicted, but not trusted.

Apply it by separating:

- local muzzle flash
- local recoil
- local hitmarker prediction
- server-confirmed hitmarker
- server damage indicator
- kill confirmation

Used for:

- responsive shooting
- recoil/camera
- hitmarkers
- damage numbers
- tracers
- impact effects

Practice:

Show a predicted hitmarker in a different internal state from a confirmed hitmarker. If the server rejects the hit, correct the presentation without granting damage.

Mastery rule:

Presentation may be optimistic. Rewards and damage must be confirmed.

## 11. ESP-Resistant UI and Marker Design

UI can accidentally reveal hidden information.

Apply server-filtered visibility for:

- nameplates
- health bars
- objective markers
- minimap blips
- team icons
- wanted markers
- interactable outlines
- target highlights

Used for:

- police/criminal games
- tactical shooters
- heists
- stealth
- objective games
- NPC tracking

Practice:

Build a marker replication service that sends markers only after server-side visibility, team, distance, and gameplay rules allow them.

Mastery rule:

Never let client UI decide who should be visible in competitive contexts.

## 12. Honeypots, Canaries, and Detection Traps

Detection traps can reveal exploit tools, but they must be used carefully.

Apply only defensive canaries:

- server-only fake targets not replicated to normal clients
- impossible target ids in analytics
- invalid remote routes
- decoy message names that should never be called
- hidden state fields that honest clients never send

Used for:

- exploit detection
- telemetry
- review queues
- rate limiting
- trust scoring

Practice:

Add analytics for clients that send unknown weapon ids, impossible target ids, or fields the official client never sends.

Mastery rule:

Detection traps should inform server-side response. Do not depend on them as the main defense.

## 13. Trust Scoring and Response Policy

Anti-cheat needs graduated responses.

Apply a trust score based on evidence:

- invalid payloads
- impossible fire cadence
- impossible aim deltas
- repeated occluded hits
- excessive remote rate
- duplicate/replayed commands
- impossible movement
- suspicious target acquisition timing

Response options:

- ignore request
- reject action
- reduce client trust window
- increase server strictness
- flag for review
- remove from competitive queues
- kick only on high-confidence abuse

Practice:

Create a server trust score module that records reasons and decay over time. Use it to harden validation for suspicious players.

Mastery rule:

Punishment policy must be more conservative than detection policy.

## 14. Buffer Networking Security

Buffers reduce bandwidth but can hide malformed data if decode is weak.

Apply strict buffer layout validation:

- version byte
- message id
- expected byte length
- bounded arrays
- numeric range checks
- sequence checks
- decode failure handling
- round-trip tests

Used for:

- input commands
- aim frames
- projectile batches
- rollback inputs
- snapshots
- combat telemetry

Practice:

Create a packed aim input buffer. Decode it, validate length and ranges, and reject any malformed or out-of-window command before simulation.

Mastery rule:

Buffer-packed input is still hostile input.

## 15. Audit, Replay, and Evidence

You need evidence to understand cheating and false positives.

Apply combat audit records:

- player id
- weapon id
- sequence
- server tick
- client tick
- origin
- aim direction
- target candidate
- visibility result
- hit result
- rejection reason
- suspicion flags

Used for:

- debugging false positives
- tuning heuristics
- reviewing reports
- replay tools
- desync investigation
- balancing

Practice:

Record the last 100 combat decisions per player. Add a debug command to dump rejected shots with reasons.

Mastery rule:

If the server rejects or flags a shot, it should be able to explain why.

## 16. Prediction-Based Detection and Possibility Bounds

Accurate detection comes from comparing what a player did against what was physically, mechanically, and statistically possible.

Apply it by building server-side models of expected behavior:

- maximum turn speed
- weapon handling limits
- recoil recovery limits
- spread and accuracy limits
- target visibility windows
- reaction-time windows
- mouse/controller input plausibility
- line-of-sight history
- target movement history
- player movement history
- shot timing history

Used for:

- aimlock detection
- silent aim detection
- recoil bypass detection
- triggerbot detection
- tracking-through-wall detection
- impossible flick detection
- suspicious headshot clustering

Practice:

For every shot, compute a `PossibilityReport`:

- Was the target visible long enough?
- Was the aim angle change physically plausible?
- Was the shot fired inside the weapon's legal cadence?
- Was the target inside the weapon's allowed cone?
- Did recoil/spread allow the claimed hit?
- Did the player track a target before line of sight existed?
- How far was the result from normal human input distribution?

Mastery rule:

Do not ask "is this cheating?" first. Ask "how possible was this outcome under the server's rules and observed history?"

## 17. Likelihood Scoring

Likelihood scoring accumulates evidence across many events.

Apply it with a scoring model that tracks:

- impossible events
- barely-possible events
- repeated low-probability events
- context-adjusted skill allowances
- weapon-specific expectations
- distance-adjusted accuracy
- target-speed-adjusted accuracy
- visibility-window-adjusted reaction time
- recoil-adjusted follow-up accuracy

Used for:

- trust scores
- review queues
- stricter validation modes
- competitive matchmaking trust
- automated session flags

Practice:

Build a score where one suspicious shot is weak evidence, but repeated shots with low visibility time, perfect snap angles, and high headshot precision become strong evidence.

Mastery rule:

One incredible shot can be legitimate. Repeated impossible or near-impossible patterns are the signal.

## 18. Counterfactual Replay

Counterfactual replay compares the actual shot against what the server believes should have happened.

Apply it by replaying recent state with:

- server-known positions
- historical hitboxes
- weapon spread
- recoil state
- movement state
- aim direction
- latency window
- allowed correction tolerance

Used for:

- silent aim detection
- lag compensation review
- disputed hit validation
- desync debugging
- false-positive analysis

Practice:

When a hit is suspicious, replay the shot three ways:

- strict current server state
- allowed lag-compensated historical state
- maximum tolerance state

If the hit only works outside all three, reject or flag it.

Mastery rule:

The server should know not only whether it accepted a shot, but how close that shot was to being rejected.

## 19. Behavioral Baselines

Detection becomes stronger when compared against a player's own history and the broader population.

Apply it by tracking:

- average aim delta
- reaction time
- hit rate by distance
- headshot rate by weapon
- tracking smoothness
- target acquisition timing
- correction/overshoot patterns
- accuracy while moving
- accuracy under recoil

Used for:

- identifying sudden impossible improvement
- distinguishing skilled players from automation
- reducing false positives
- tuning thresholds

Practice:

Create a per-player combat profile for the current session. Compare the last 20 shots to the previous 200 shots and flag sudden extreme changes.

Mastery rule:

Great players are consistent in human ways. Automation is often consistent in machine ways.

## 20. Detection Response Ladder

Prediction-based detection needs measured responses.

Apply graduated responses:

- silently reject impossible commands
- log near-impossible events
- increase server strictness
- reduce lag compensation tolerance
- disable client-predicted confirmations
- require more server-confirmed data
- flag for review
- remove from ranked/competitive contexts
- kick only on high-confidence repeated abuse

Used for:

- avoiding false punishments
- protecting competitive integrity
- limiting exploit value
- gathering better evidence

Practice:

Create response thresholds:

- `Clean`
- `Watch`
- `StrictValidation`
- `CompetitiveRestricted`
- `Actionable`

Each threshold should name exactly what changes in server behavior.

Mastery rule:

Detection should first protect the game state. Punishment comes only when confidence is high enough.

## Compatibility With ECS

ECS helps anti-cheat because authoritative state is explicit.

Use ECS for:

- weapon state
- ammo
- cooldowns
- health
- teams
- hitboxes
- visibility state
- player combat state
- projectiles
- status effects

Anti-cheat systems can query ECS state instead of scraping Instances.

Policy:

> Anti-cheat validates ECS simulation state, not client UI or raw replicated presentation.

## Compatibility With OOP

OOP owns anti-cheat services and validators.

Use:

- `CombatValidationService`
- `VisibilityService`
- `AimAuditService`
- `TrustScoreService`
- `RemoteGuard`
- `LagCompensationService`
- `DamageTransactionService`

Policy:

> Feature weapons compose behavior, but shared anti-cheat services own validation invariants.

## Compatibility With Scheduling

Anti-cheat depends on time.

Use scheduling for:

- fixed tick history
- rate-limit windows
- input sequence ordering
- aim delta sampling
- trust score decay
- replay capture
- delayed review export

Policy:

> Every anti-cheat claim involving time must name the server tick, client tick, sequence, and accepted tolerance.

## Compatibility With Runtime Contracts

Anti-cheat starts at admission.

Use runtime contracts for:

- fire command validation
- buffer decode validation
- target eligibility
- damage transaction invariants
- config admission
- attachment compatibility
- lag compensation windows

Policy:

> No combat command enters simulation until it passes runtime admission.

## Compatibility With Typed Luau

Types make anti-cheat explainable.

Use types for:

- `FireCommand`
- `AimFrame`
- `CombatDecision`
- `VisibilityResult`
- `HitValidationResult`
- `TrustSignal`
- `SuspicionScore`
- `DamageTransaction`
- `ShotRejectionReason`

Policy:

> Expected rejections should be typed, logged, and reviewable.

## Compatibility With Rollback and Prediction

Prediction and rollback must not create cheat authority.

Use:

- client prediction for local effects only
- server rollback or lag compensation for fair validation
- sequence numbers for replay order
- historical server state for hit checks
- server correction for rejected prediction

Policy:

> A predicted hit is presentation. A confirmed hit is a server transaction.

## For Gunkits

Required anti-cheat boundaries:

```text
Client:
  input sampling
  local recoil/camera
  predicted muzzle flash
  predicted tracer
  optional predicted hitmarker

Server:
  fire cadence
  ammo
  reload state
  weapon ownership
  raycast/hit validation
  damage
  lag compensation
  trust scoring
  audit logs
```

The gunkit should expose:

- typed fire command schema
- weapon config validator
- server fire transaction
- server hit resolver
- visibility service
- damage transaction service
- aim audit stream
- possibility report generator
- likelihood score model
- counterfactual replay path
- behavioral baseline tracker
- rejection reason enum
- client correction message

## For Prompt Systems

Prompt anti-cheat is less about aim and more about visibility and interaction abuse.

Apply:

- server distance validation
- line-of-sight checks where relevant
- permission checks
- cooldowns
- rate limits
- server-owned rewards
- UI marker filtering

Policy:

Prompt UI can be local. Prompt outcomes are server transactions.

## For Vehicles

Vehicle weapon and movement anti-cheat must validate:

- seat ownership
- input rate
- steering/throttle sanity
- weapon mount angle
- line of sight
- projectile origin
- physics ownership changes
- collision/damage authority

Policy:

Vehicle clients may provide input. They do not author final combat or collision outcomes.

## The Indefinite Framework

Your long-term Roblox framework should include:

```text
CombatValidationService
RemoteGuard
VisibilityService
LagCompensationService
AimAuditService
TrustScoreService
PossibilityModel
LikelihoodScorer
CounterfactualReplayService
BehaviorBaselineService
DamageTransactionService
MarkerReplicationService
HitboxHistoryBuffer
CombatReplayLog
ShotRejectionReasons
AntiCheatTelemetry
```

Each piece has a permanent role:

- `CombatValidationService` admits or rejects combat intent.
- `RemoteGuard` validates payloads, rates, and sequence.
- `VisibilityService` checks target visibility and line of sight.
- `LagCompensationService` validates bounded historical hits.
- `AimAuditService` records aim and timing signals.
- `TrustScoreService` accumulates suspicion carefully.
- `PossibilityModel` defines what could legally happen.
- `LikelihoodScorer` scores repeated low-probability outcomes.
- `CounterfactualReplayService` compares actual shots against possible worlds.
- `BehaviorBaselineService` compares current play against historical patterns.
- `DamageTransactionService` commits server-authoritative damage.
- `MarkerReplicationService` limits ESP-prone UI data.
- `HitboxHistoryBuffer` stores server-side historical target state.
- `CombatReplayLog` explains decisions after the fact.
- `ShotRejectionReasons` makes failures typed and reviewable.
- `AntiCheatTelemetry` supports tuning and review.

## How To Master It

Practice in this order:

1. Write a threat model for one weapon.
2. Move hit and damage authority to the server.
3. Add typed fire command validation.
4. Add server fire cadence and ammo validation.
5. Add server line-of-sight validation.
6. Add target eligibility validation.
7. Add shot rejection reasons.
8. Add audit logging for every rejected shot.
9. Add marker visibility filtering.
10. Add bounded lag compensation.
11. Add aim timing telemetry.
12. Add trust scoring without automatic punishment.
13. Add malformed remote fuzz tests.
14. Add buffer decode security tests.
15. Add a combat replay/debug dump.
16. Add possibility reports for each shot.
17. Add likelihood scoring over many shots.
18. Add counterfactual replay for suspicious hits.
19. Add behavior baselines.
20. Add a response ladder that protects state before punishing players.

The best first real project is a server-authoritative hitscan validation service. Then add marker filtering, lag compensation, audit logs, and trust scoring.

## Permanent Policy

Use this rule for every future combat system:

> If a client reports something that affects combat outcome, assume it is false until the server proves it is legal.

The true mastery is combining security with the full curriculum:

- ECS makes combat state explicit.
- OOP owns validation services.
- Scheduling gives tick and rate context.
- Runtime contracts admit or reject payloads.
- Typed Luau makes decisions reviewable.
- Rollback and lag compensation support fairness without trusting the client.
- Information minimization weakens ESP value.

When these agree, aimlock, aimbot, and ESP still exist as threats, but they stop being system-authoritative.
