# Stage 9: Runtime Systems, Tooling, and Observability

Runtime mastery is what separates a clever system from a system you can operate, debug, scale, and trust. Roblox projects often fail not because the core idea is wrong, but because nobody can explain leaks, timing spikes, network abuse, validation failures, desyncs, or state corruption after the fact.

Core policy:

> Every serious system must be inspectable, measurable, and debuggable under live-like conditions.

## 1. Diagnostics Architecture

Diagnostics architecture means logs, traces, counters, timings, and errors have structure.

Apply it by defining standard diagnostic records:

- timestamp/tick
- system name
- entity id
- player id
- action
- result
- duration
- rejection reason
- metadata

Used for:

- combat validation
- prompt sessions
- vehicles
- networking
- inventory
- economy
- rollback
- anti-cheat

Practice:

Create a `DiagnosticsService` that records structured events for fire requests, rejected shots, prompt interactions, and vehicle authority changes.

Mastery rule:

If a system cannot explain what happened, it is not production-ready.

## 2. Feature Flags

Feature flags control rollout, kill switches, and experiments.

Apply flags with:

- owner
- default state
- rollout scope
- risk level
- expiry/removal plan
- audit record

Used for:

- new gunkit logic
- anti-cheat strictness
- vehicle rewrites
- prompt framework changes
- networking protocol upgrades
- economy changes

Practice:

Add a flag for `ServerAuthoritativeHitscanV2`. Make the server choose old/new validation through the flag, and record which path handled each shot.

Mastery rule:

A feature flag without an owner or removal plan becomes permanent uncertainty.

## 3. Hot Reload Boundaries

Hot reload boundaries define what can be reloaded safely while the game is running.

Apply by separating:

- pure config
- stateless behavior modules
- stateful services
- live sessions
- runtime stores
- network protocols

Used for:

- weapon tuning
- prompt configs
- UI presentation
- debug tools
- local development
- Studio workflows

Practice:

Allow weapon config reload in Studio, but require full service restart for weapon runtime state. Document why.

Mastery rule:

Reload config freely. Reload stateful authority cautiously.

## 4. Memory Profiling

Memory profiling finds leaks, churn, and unbounded growth.

Apply it by tracking:

- Instances created
- connections owned
- active tasks
- object pool size
- entity count
- component count
- queue size
- snapshot history size
- replay log size

Used for:

- weapons
- tracers
- prompts
- vehicles
- UI
- networking
- rollback history
- anti-cheat logs

Practice:

Build a runtime report that lists active weapon runtimes, projectiles, prompt sessions, connections, and pending tasks.

Mastery rule:

Anything created repeatedly must have an owner, a count, and a cleanup story.

## 5. Performance Budgets

Performance budgets define acceptable cost before optimization work starts.

Apply budgets for:

- frame time
- server step time
- client render time
- network bytes/sec
- RemoteEvent calls/sec
- DataStore writes
- scheduler queue length
- snapshot memory
- validation CPU

Used for:

- gunkits
- vehicles
- NPCs
- replication
- UI
- economy
- rollback

Practice:

Set budgets for a combat system: max fire validation time, max network messages/sec per player, max active projectiles, and max audit log memory.

Mastery rule:

You cannot know whether a system is fast enough until "enough" has a number.

## 6. System Health Dashboards

Health dashboards expose live system state.

Apply them as Studio/debug panels or command dumps:

- active players
- active entities
- active sessions
- weapon state
- vehicle state
- network rates
- validation rejects
- trust scores
- queue sizes
- recent errors

Used for:

- debugging live servers
- QA
- playtests
- anti-cheat review
- performance tuning

Practice:

Create a text dashboard command that prints combat health: active weapons, shots/sec, rejected shots, avg validation time, and top rejection reasons.

Mastery rule:

The fastest bug fix starts with the system telling you where to look.

## 7. Automated Contract Tests

Contract tests prove APIs obey their promises.

Apply to:

- service APIs
- network schemas
- config validators
- ECS component registration
- scheduler phases
- prompt actions
- weapon fire modes
- vehicle strategies

Used for:

- refactor safety
- package extension
- protocol changes
- regression prevention

Practice:

Write tests that every registered `PromptAction`, `FireMode`, and `HitResolver` satisfies its contract.

Mastery rule:

Every extension point needs a contract test.

## 8. Fuzz Testing

Fuzz testing sends random or malformed inputs to prove failure is safe.

Apply fuzzing to:

- remotes
- buffer decoders
- config loaders
- transaction requests
- command replay
- prompt actions
- inventory operations

Used for:

- anti-cheat
- exploit resistance
- protocol hardening
- datastore migration safety

Practice:

Fuzz `FireRequested` with wrong types, huge vectors, stale sequences, future ticks, fake weapon ids, duplicate commands, and impossible aim directions.

Mastery rule:

A hostile input should become a typed rejection, not a crash or mutation.

## 9. Editor Tooling

Editor tooling turns architecture into daily workflow.

Apply with Studio plugins, command modules, generators, and validators:

- config validator
- entity inspector
- prompt map scanner
- weapon config auditor
- network schema browser
- component registry browser
- leak checker
- deployment checker

Used for:

- faster development
- fewer manual mistakes
- onboarding
- audits
- content pipeline quality

Practice:

Create a command that scans weapon configs and reports missing ids, duplicate names, invalid fire modes, impossible damage, and missing server validators.

Mastery rule:

If humans repeat the same architecture check, build a tool for it.

## 10. Failure Injection

Failure injection simulates bad conditions before production does.

Apply by simulating:

- latency
- packet loss
- duplicate messages
- malformed payloads
- DataStore failure
- player removal
- streamed object removal
- service timeout
- rollback correction
- physics ownership loss

Used for:

- networking
- prompts
- weapons
- vehicles
- persistence
- matchmaking
- economy

Practice:

Build a debug mode that randomly delays or drops non-critical client messages and proves server authority still holds.

Mastery rule:

If a failure can happen in production, rehearse it in development.

## Compatibility With ECS

Observability should expose ECS state.

Use tooling for:

- entity counts
- component counts
- query sizes
- mutation logs
- system timings
- snapshot size
- lifecycle cleanup

Policy:

> ECS is not mastered until you can inspect the world it owns.

## Compatibility With OOP

Observability should expose object lifecycles.

Use tooling for:

- active services
- controllers
- adapters
- object pools
- cleaner contents
- destroyed state
- dependency graphs

Policy:

> Any object that owns resources should be inspectable.

## Compatibility With Scheduling

Observability should expose time and work.

Use tooling for:

- phase timings
- queue lengths
- active operations
- cancelled tasks
- timeouts
- cooldown states
- backpressure drops

Policy:

> Scheduler bugs are invisible without timing instrumentation.

## Compatibility With Runtime Contracts

Observability should expose contract failures.

Track:

- validator rejects
- assertion failures
- config admission errors
- payload decode failures
- lifecycle transition violations
- capability misuse

Policy:

> A rejected action should name the contract it failed.

## Compatibility With Typed Luau

Typed systems should generate and enforce toolable contracts.

Use types for:

- diagnostic records
- health reports
- feature flag records
- test cases
- fuzz inputs
- rejection reasons
- dashboard summaries

Policy:

> If a debug record matters, type it.

## Compatibility With Networking

Network observability is mandatory for serious multiplayer.

Track:

- message rate
- payload size
- direction
- player
- schema id
- validation result
- processing time
- sequence gaps
- desync reports

Policy:

> Network protocols are not owned until they are measured.

## Compatibility With Rollback and Temporal Architecture

Replay and time-travel debugging are observability tools.

Track:

- command history
- snapshots
- random seeds
- correction events
- rollback count
- desync checksums
- frame timings

Policy:

> Rollback without replay tooling is guesswork.

## Compatibility With Anti-Cheat

Anti-cheat needs evidence.

Track:

- shot decisions
- visibility results
- possibility reports
- likelihood scores
- rejection reasons
- trust score changes
- counterfactual replay outputs
- marker visibility decisions

Policy:

> Suspicion without evidence is noise.

## For Gunkits

Required runtime tooling:

```text
CombatDashboard
ShotAuditLog
FireCommandFuzzer
WeaponConfigAuditor
HitValidationProfiler
AntiCheatEvidenceViewer
NetworkTrafficSummary
ReplayCapture
```

Policy:

Every shot should be explainable by server state, weapon state, geometry, timing, validation, and audit records.

## For Prompt Systems

Required runtime tooling:

```text
PromptSessionInspector
InteractionAuditLog
PermissionFailureReport
CooldownDebugger
RewardTransactionLog
StreamingRemovalTest
```

Policy:

Every interaction completion or rejection should be explainable.

## For Vehicles

Required runtime tooling:

```text
VehicleStateDashboard
SuspensionTimingProfiler
AuthorityHandoffLog
PhysicsOwnershipInspector
CorrectionReplay
InputCommandAudit
```

Policy:

Vehicle bugs need timing, ownership, and correction evidence.

## The Indefinite Framework

Your long-term Roblox framework should include:

```text
DiagnosticsService
FeatureFlagService
HealthDashboard
LifecycleInspector
MemoryTracker
PerformanceBudget
NetworkProfiler
ContractTestHarness
FuzzHarness
FailureInjector
ReplayCaptureService
DebugCommandRegistry
```

## How To Master It

Practice in this order:

1. Add structured logs to one service.
2. Add typed rejection reasons.
3. Add a health dump command.
4. Add lifecycle inspection.
5. Add connection/task tracking.
6. Add system timing reports.
7. Add network payload summaries.
8. Add feature flags with ownership.
9. Add config audit tooling.
10. Add contract tests.
11. Add remote fuzz tests.
12. Add buffer decode fuzz tests.
13. Add failure injection for player removal and latency.
14. Add replay capture for one combat interaction.
15. Build a dashboard for the riskiest live system.

## Permanent Policy

Use this rule for every future Roblox system:

> If the system can fail, leak, desync, be abused, overload, or affect authority, build the tool that proves what happened.
