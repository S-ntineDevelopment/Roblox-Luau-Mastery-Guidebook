# Stage 10: Large-Scale Game Architecture and Domain Platforms

Large-scale architecture is what turns individual systems into a reusable game platform. At this level, the goal is not to build one gunkit, one prompt framework, one vehicle controller, or one economy module. The goal is to build domain platforms that can generate, validate, run, inspect, and evolve many systems across projects.

Core policy:

> A mature Roblox codebase should not repeatedly rebuild the same kind of system. It should provide platforms where features declare identity, config, rules, and domain behavior while shared architecture owns validation, lifecycle, networking, persistence, observability, and tooling.

## 1. Modular Feature Platforms

Feature platforms are reusable systems that many features plug into.

Apply them to:

- weapons
- prompts
- vehicles
- jobs
- crimes/heists
- shops
- abilities
- NPCs
- quests
- minigames

Used for:

- faster feature delivery
- consistent rules
- reusable validation
- shared tooling
- reduced regressions

Practice:

Design a `WeaponPlatform` where a new weapon supplies config, fire mode, hit resolver, recoil model, and optional effects without editing the shared fire service.

Mastery rule:

The platform owns rules. Features supply identity and domain behavior.

## 2. Domain-Specific Languages

A domain-specific language is a constrained way to describe gameplay behavior.

Apply DSLs through typed configs or declarative tables:

- ability definitions
- weapon effects
- quest objectives
- dialogue nodes
- shop inventories
- NPC behaviors
- prompt actions

Used for:

- content authoring
- safer extension
- tooling
- validation
- generation
- balancing

Practice:

Create a small ability DSL:

```lua
{
	id = "ConcussiveShot",
	cost = {ammo = 1},
	cooldown = 8,
	effects = {
		{kind = "Damage", amount = 20},
		{kind = "Stun", duration = 1.25},
	},
}
```

Then validate and execute it through registered effect handlers.

Mastery rule:

Good DSLs are constrained enough to validate and expressive enough to reduce custom scripts.

## 3. Rules Engines

Rules engines compose conditions, costs, effects, cooldowns, targeting, and validation.

Apply them by creating reusable rule pieces:

- condition
- cost
- target selector
- validator
- effect
- cooldown
- reward
- rejection reason

Used for:

- weapons
- abilities
- prompts
- shops
- quests
- economy
- NPC attacks
- law/crime systems

Practice:

Build a rule pipeline for an interaction:

```text
validate actor -> validate target -> validate distance -> validate cost -> apply effect -> emit result
```

Mastery rule:

When many systems repeat validate/apply/reward logic, extract the rule model.

## 4. Data Pipelines

Data pipelines import, validate, version, and deploy gameplay data.

Apply them to:

- weapon configs
- vehicle configs
- item databases
- economy prices
- mission definitions
- NPC archetypes
- prompt maps
- animation/sound references

Used for:

- fewer broken configs
- automated audits
- versioned content
- safe rollout
- build-time validation

Practice:

Create a config audit command that checks every weapon for valid id, damage range, fire mode, ammo type, animations, sounds, and server validator registration.

Mastery rule:

Content data should fail before runtime when possible.

## 5. Persistence Architecture

Persistence architecture controls save/load, profile ownership, migrations, and write budgets.

Apply it with:

- profile sessions
- data schemas
- migrations
- write queues
- idempotent transactions
- conflict handling
- audit logs
- rollback-safe records

Used for:

- inventory
- economy
- progression
- weapon ownership
- attachments
- vehicles
- jobs
- achievements

Practice:

Design an inventory persistence schema with versioned migrations and idempotent purchase records.

Mastery rule:

Persistent data is server-owned financial-grade state. Treat it like a ledger, not a table dump.

## 6. Economy Integrity

Economy integrity prevents duplication, fraud, partial writes, and inconsistent rewards.

Apply transaction principles:

- validate
- reserve
- debit
- mutate
- credit
- emit audit event
- commit
- recover safely

Used for:

- shops
- purchases
- rewards
- trading
- jobs
- robbery payouts
- weapon unlocks
- vehicle ownership

Practice:

Create a `PurchaseTransaction` result that is idempotent by transaction id and cannot grant the same weapon twice.

Mastery rule:

Currency and items must change through transactions, not loose mutation.

## 7. Match and Session Orchestration

Match/session orchestration owns lifecycle across players, servers, objectives, and cleanup.

Apply it with:

- lobby/session creation
- participant admission
- server reservation
- reconnect handling
- objective lifecycle
- timeout
- completion
- cancellation
- cleanup

Used for:

- heists
- minigames
- combat rounds
- races
- jobs
- raids
- arenas

Practice:

Design a `CombatRoundSession` with explicit states: `Waiting`, `Starting`, `Active`, `Ending`, `Completed`, `Cancelled`, `Destroyed`.

Mastery rule:

Sessions are state machines with authority, not folders full of scripts.

## 8. AI Behavior Architecture

AI architecture controls perception, decision, action, memory, and coordination.

Apply patterns:

- behavior trees
- utility AI
- finite state machines
- planners
- blackboards
- perception systems
- squad coordination

Used for:

- NPC enemies
- police/criminal AI
- bosses
- civilians
- vehicles
- vendors
- guards
- mission actors

Practice:

Build an NPC combat agent with perception, target memory, utility scoring, and action execution through the same weapon/action contracts as players.

Mastery rule:

AI should use the same authoritative game contracts as players where possible.

## 9. Plugin-Grade Extensibility

Plugin-grade extensibility means other features can extend the platform safely.

Apply with:

- registries
- capability APIs
- sandboxed extension surfaces
- typed contracts
- versioned interfaces
- compatibility tests
- deprecation policy

Used for:

- weapon modules
- attachment effects
- prompt actions
- quest objectives
- minigames
- vehicle strategies
- AI behaviors

Practice:

Create an `EffectRegistry` that admits only effects satisfying a typed contract and runtime validator.

Mastery rule:

Extension points must be easier to use correctly than incorrectly.

## 10. Cross-Project Policy Extraction

Cross-project policy extraction turns proven patterns into templates and instructions.

Apply it by extracting:

- agent policies
- templates
- checklists
- config schemas
- starter modules
- test harnesses
- audit commands
- debug tools

Used for:

- RK Robanger
- v2 Revamp Guns
- future gunkits
- vehicle projects
- prompt systems
- economy systems
- combat frameworks

Practice:

After building a feature twice, extract the shared policy, typed contract, skeleton modules, and validation checklist into a reusable template.

Mastery rule:

A pattern is not mastered until it can be reused without copying mistakes.

## Compatibility With ECS

Large-scale platforms use ECS as the shared state substrate where systems need queryable runtime state.

Policy:

> Domain platforms should declare which state is ECS data, which state is config, which state is persistence, and which state is presentation.

## Compatibility With OOP

OOP owns platform services, adapters, controllers, registries, and lifecycle.

Policy:

> Domain platforms expose narrow service APIs and polymorphic extension contracts.

## Compatibility With Scheduling

Large systems need explicit execution and lifecycle phases.

Policy:

> Platform orchestration must name when validation, simulation, mutation, replication, persistence, cleanup, and diagnostics run.

## Compatibility With Runtime Contracts

Platforms admit third-party or feature-authored behavior through contracts.

Policy:

> Every extension point must validate its registered config, behavior object, permissions, and lifecycle.

## Compatibility With Typed Luau

Typed Luau makes platform boundaries visible.

Policy:

> Every platform needs public service types, config types, result types, state unions, and extension contract types.

## Compatibility With Networking

Domain platforms need protocol surfaces.

Policy:

> Every platform that crosses client/server boundaries owns a message catalog, rate policy, authority policy, and migration strategy.

## Compatibility With Rollback and Temporal Architecture

Replay-sensitive platforms need command/event/snapshot design.

Policy:

> If platform outcomes must be replayed, audited, or corrected, they need typed commands, events, snapshots, ticks, and history buffers.

## Compatibility With Anti-Cheat

Combat platforms must design against hostile clients from the start.

Policy:

> Anti-cheat is not a bolt-on module. It is a platform requirement for combat authority, visibility, networking, and evidence.

## Compatibility With Observability

Large platforms must prove what they are doing.

Policy:

> Every platform needs diagnostics, health reports, audit logs, fuzz tests, and failure-injection paths proportional to risk.

## For Gunkits

A mature gunkit platform includes:

```text
WeaponConfig
WeaponState
FireModeRegistry
ReloadPolicyRegistry
HitResolverRegistry
EffectPipeline
DamageTransactionService
CombatValidationService
LagCompensationService
AntiCheatEvidenceService
NetworkSchemaRegistry
ReplayCaptureService
WeaponConfigAuditor
```

Policy:

New weapons should be config plus registered behavior. Shared services own authority, validation, networking, damage, audit, and observability.

## For Prompt Systems

A mature prompt platform includes:

```text
PromptConfig
PromptState
PromptActionRegistry
PermissionRegistry
InteractionSessionService
RewardTransactionService
PromptAdapter
PromptReplicationService
PromptAuditLog
```

Policy:

New interactions should be registered actions and permissions, not new one-off scripts.

## For Vehicles

A mature vehicle platform includes:

```text
VehicleConfig
VehicleState
InputCommandSchema
SuspensionStrategyRegistry
AuthorityHandoffService
VehicleCorrectionService
PhysicsAuthorityPolicy
VehicleTelemetryService
VehicleAuditLog
```

Policy:

New vehicles should be config plus registered strategies. Shared services own authority, correction, telemetry, and cleanup.

## The Indefinite Framework

Your long-term Roblox framework should include:

```text
DomainPlatform
RulesEngine
ConfigPipeline
SchemaRegistry
EffectRegistry
PermissionRegistry
TransactionService
PersistenceService
SessionOrchestrator
AIBehaviorPlatform
PluginExtensionHost
TemplateLibrary
PolicyExtractor
```

## How To Master It

Practice in this order:

1. Pick one domain: weapons, prompts, vehicles, economy, jobs, or AI.
2. Identify shared rules versus feature identity.
3. Define the platform service API.
4. Define typed config.
5. Define extension contracts.
6. Define runtime validators.
7. Define transaction boundaries.
8. Define network schemas.
9. Define persistence needs.
10. Define observability and audit logs.
11. Build two features on the platform.
12. Remove feature-name conditionals from shared code.
13. Add tooling to validate configs and registrations.
14. Add failure injection and contract tests.
15. Extract the pattern into reusable project policy and templates.

## Permanent Policy

Use this rule for every future Roblox system:

> If you build the same kind of feature twice, stop and extract the platform before building it a third time.
