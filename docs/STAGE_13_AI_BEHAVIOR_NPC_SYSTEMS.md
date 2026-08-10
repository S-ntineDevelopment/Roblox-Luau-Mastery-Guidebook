# Stage 13: AI Behavior Architecture and NPC Systems

AI systems become weak when every NPC is a pile of local scripts, random waits, direct Humanoid calls, and special-case combat logic. A serious Roblox engine needs AI as a domain platform: perception, memory, decision-making, actions, authority, scheduling, networking, debugging, and tooling all need explicit boundaries.

Core policy:

> NPCs are not special scripts. They are server-authoritative agents that perceive the world, choose actions through typed behavior contracts, execute through the same domain platforms as players where practical, and expose enough diagnostics to explain every decision.

## 1. AI Agent Identity

AI agents need stable identity separate from their Roblox Model.

Apply it with:

- `AgentId`
- linked `EntityId`
- model adapter
- lifecycle owner
- blackboard state
- team/faction data
- behavior profile id

Used for:

- NPC enemies
- guards
- civilians
- vendors
- bosses
- police/criminal AI
- vehicles
- mission actors

Practice:

Spawn five NPCs from configs. Each gets an `EntityId`, `AgentId`, `Team`, `Health`, `Transform`, `BehaviorProfile`, and `ModelAdapter`.

Mastery rule:

The Roblox Model presents the agent. It is not the agent's identity.

## 2. Perception Systems

Perception decides what an NPC can sense.

Apply perception channels:

- sight
- hearing
- damage source
- proximity
- threat
- objective
- team signals
- memory recall

Used for:

- target detection
- patrol interruption
- combat response
- stealth
- alarms
- squad behavior

Practice:

Build a `PerceptionSystem` that writes `VisibleTargets` and `HeardEvents` components without directly choosing actions.

Mastery rule:

Perception collects evidence. Decision systems choose behavior.

## 3. Blackboard Memory

A blackboard stores agent memory and working state.

Apply blackboards for:

- last seen target
- last heard noise
- current objective
- squad alert state
- path target
- cover point
- threat score
- cooldowns

Used for:

- combat AI
- patrols
- investigation
- squad coordination
- boss phases

Practice:

Create a blackboard component with `lastKnownTargetPosition`, `alertLevel`, `currentGoal`, and `memoryExpiresAt`.

Mastery rule:

AI memory should be explicit state, not hidden local variables inside behavior scripts.

## 4. Behavior Trees

Behavior trees organize decisions as selectors, sequences, conditions, and actions.

Apply them when behavior needs readable priority flow:

```text
Selector
  Sequence: If low health -> find cover -> retreat
  Sequence: If target visible -> aim -> fire
  Sequence: If heard noise -> investigate
  Action: patrol
```

Used for:

- guards
- enemies
- bosses
- mission NPCs
- civilian routines

Practice:

Build a small behavior tree runner with `Selector`, `Sequence`, `Condition`, and `Action` nodes.

Mastery rule:

Behavior trees describe decision flow. Actions still execute through domain services.

## 5. Utility AI

Utility AI scores possible actions and chooses the best one.

Apply utility scoring for:

- attack
- retreat
- reload
- seek cover
- chase
- flank
- call backup
- investigate
- idle

Used for:

- dynamic combat
- vehicle NPCs
- bosses
- squad tactics
- adaptive difficulty

Practice:

Score `Attack`, `Reload`, `Retreat`, and `TakeCover` from health, ammo, target distance, and visibility.

Mastery rule:

Utility AI is useful when the best action depends on changing context, not a fixed priority list.

## 6. Planners and Goals

Planners choose steps to satisfy a goal.

Apply planning for:

- fetch item
- reach objective
- breach building
- arrest suspect
- escape area
- repair vehicle
- defend point

Used for:

- mission NPCs
- cops/criminals
- workers
- squad AI
- open-world behaviors

Practice:

Design a simple goal planner where an NPC with goal `ReloadWeapon` can choose `FindCover -> Reload -> Reengage`.

Mastery rule:

Use planners when the path to a goal can vary. Use behavior trees when the decision hierarchy is stable.

## 7. Action Contracts

AI actions should use typed contracts and shared services.

Apply actions:

- `MoveTo`
- `AimAt`
- `FireWeapon`
- `Reload`
- `Interact`
- `TakeCover`
- `CallBackup`
- `UseAbility`

Used for:

- player/NPC parity
- testing
- reuse
- anti-cheat consistency
- debugging

Practice:

Make NPC firing use the same server `WeaponPlatform` and `DamageTransactionService` as player weapons.

Mastery rule:

AI should not bypass the same authority rules players obey.

## 8. Pathfinding and Movement Authority

Movement AI must separate path planning, movement commands, and Roblox execution.

Apply:

- path request queue
- movement intent component
- path cache
- stuck detection
- steering/avoidance
- humanoid adapter
- server authority

Used for:

- patrols
- chase
- cover seeking
- vehicles
- civilians
- enemy waves

Practice:

Create a `PathRequestService` with backpressure and a `HumanoidMovementAdapter` that executes movement without owning decision logic.

Mastery rule:

Pathfinding is expensive and failure-prone. Queue it, cache it, and inspect it.

## 9. Squad and Group AI

Group AI coordinates multiple agents.

Apply group state:

- squad id
- shared target
- alert level
- formation
- role
- suppression target
- flank assignment
- retreat command

Used for:

- tactical combat
- police squads
- raids
- boss minions
- convoy systems

Practice:

Create a `SquadBlackboard` where one NPC spotting a player raises alert for nearby squad members.

Mastery rule:

Group coordination belongs in shared group state, not duplicated in every NPC brain.

## 10. AI Debugging and Observability

AI must explain decisions.

Track:

- current goal
- selected action
- score values
- perception result
- blackboard values
- path status
- failed conditions
- action duration
- target choice
- last rejection reason

Used for:

- debugging NPC behavior
- balancing
- performance
- anti-cheat parity
- playtest tooling

Practice:

Build an AI debug dump for one NPC showing perception, blackboard, selected action, and reason.

Mastery rule:

If an NPC acts "stupid," the system should explain which input or score made it choose that action.

## Compatibility With ECS

AI state is ideal ECS data.

Use components for:

- `AIController`
- `Perception`
- `Blackboard`
- `Goal`
- `PathRequest`
- `SquadMember`
- `Targeting`
- `Threat`

Policy:

> ECS stores AI state. AI systems process that state in declared phases.

## Compatibility With OOP

OOP owns AI services, adapters, and behavior runners.

Use:

- `BehaviorTreeRunner`
- `UtilityScorer`
- `PathRequestService`
- `HumanoidAdapter`
- `SquadService`
- `AIDebugger`

Policy:

> OOP owns AI machinery. ECS owns AI state.

## Compatibility With Scheduling

AI needs budgeted execution.

Policy:

> AI perception, scoring, pathfinding, and actions must run through scheduler phases and budgets, not one Heartbeat per NPC.

## Compatibility With Runtime Contracts

AI extension points need validation.

Policy:

> Behavior nodes, utility actions, planners, and AI configs must be registered through typed contracts and runtime validators.

## Compatibility With Typed Luau

AI behavior must be typed.

Use types for:

- behavior nodes
- action results
- blackboard records
- perception records
- utility scores
- path requests
- squad commands

Policy:

> AI that cannot type its state cannot explain its behavior.

## Compatibility With Networking

AI is server-authoritative, but clients need presentation.

Policy:

> Replicate only client-needed AI presentation state. Keep decision state, hidden targets, threat scores, and future goals server-only unless explicitly allowed.

## Compatibility With Anti-Cheat

AI must not weaken combat authority.

Policy:

> NPC weapons and abilities use the same server validation, damage transactions, visibility rules, and audit logs as player systems where practical.

## Compatibility With Persistence

Most AI state is runtime-only, but some AI outcomes persist.

Policy:

> Persist outcomes such as rewards, quest progress, arrests, ownership, and economy changes through transactions. Do not persist volatile blackboard state unless the feature explicitly needs recovery.

## For Gunkits

AI gunkit integration requires:

```text
AIWeaponController
TargetingComponent
AimPolicy
FireDecision
ReloadDecision
CombatValidationService
DamageTransactionService
ShotAuditLog
```

Policy:

NPCs may choose to fire, but the weapon platform still validates cadence, ammo, target eligibility, line of sight, and damage.

## For Prompt Systems

AI prompt integration requires:

```text
AIInteractionIntent
PermissionCheck
PromptAction
InteractionSession
RewardTransaction
```

Policy:

NPCs and players should use the same interaction contracts where the mechanic overlaps.

## For Vehicles

AI vehicle integration requires:

```text
VehicleGoal
PathPlan
DrivingPolicy
VehicleInputCommand
AuthorityHandoff
CorrectionPolicy
```

Policy:

AI drivers should emit vehicle input commands through the same vehicle platform instead of directly controlling physics internals.

## The Indefinite Framework

Your long-term Roblox framework should include:

```text
AIAgentRegistry
PerceptionSystem
BlackboardStore
BehaviorTreeRunner
UtilityScorer
GoalPlanner
ActionRegistry
PathRequestService
SquadService
AIDebugger
HumanoidAdapter
AIConfigAuditor
```

## How To Master It

Practice in this order:

1. Give NPCs stable `AgentId` and `EntityId`.
2. Add perception components.
3. Add blackboard memory.
4. Add behavior tree runner.
5. Add utility scorer.
6. Add typed action contracts.
7. Make NPC firing use the weapon platform.
8. Add path request queue and backpressure.
9. Add humanoid adapter.
10. Add squad blackboard.
11. Add AI debug dumps.
12. Add config validators.
13. Add scheduler budgets.
14. Add network interest filtering for AI presentation.
15. Convert one scripted NPC into the AI platform.

## Permanent Policy

Use this rule for every future Roblox system:

> AI is not exempt from architecture. NPCs must use the same identity, authority, lifecycle, validation, networking, and observability standards as the rest of the engine.
