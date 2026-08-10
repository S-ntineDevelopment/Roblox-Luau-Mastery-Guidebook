# Stage 1: ECS and Data-Oriented Architecture

ECS means Entity Component System. It is a way to build game systems where identity, data, and behavior are separated:

- Entity: an id that represents a thing in the game.
- Component: typed data attached to an entity.
- System: logic that reads and writes components.

In Roblox, ECS is useful because most projects become tangled around Instances, RemoteEvents, ModuleScripts, and feature-specific managers. ECS gives you a shared architecture where combat, movement, inventory, effects, NPCs, and interactables can reuse the same rules for identity, lifecycle, querying, mutation, debugging, and replication.

## 1. Entity Identity

Entity identity means every simulated thing has a stable id that is not just a Roblox Instance reference. A character, projectile, enemy, dropped item, ability zone, vehicle, or temporary effect can all be represented by an entity id.

Apply it by creating an `EntityId` type and an entity registry. The registry should create ids, mark entities alive/dead, and own despawn cleanup.

Use it for:

- Combat targets.
- NPCs.
- Projectiles.
- Inventory items.
- Temporary status effects.
- Interactables.
- World objects that need simulation state.

Practice:

Build a tiny entity registry with `create`, `exists`, and `destroy`. Spawn 10 dummy entities for enemies, attach a display name separately, then destroy half of them and verify no system can act on destroyed ids.

Roblox rule:

Do not let random systems pass raw `Model` or `Part` references everywhere as identity. Use an entity id as the stable simulation identity, and only map to Instances at the Roblox boundary.

## 2. Component Schema Design

Component schema design means each component is a small typed data record. Components should not contain behavior. They describe what an entity has, not what it does.

Apply it by defining components like `Health`, `Position`, `Velocity`, `Team`, `Cooldowns`, `StatusEffects`, `Inventory`, or `Renderable`.

Use it for:

- Keeping feature data inspectable.
- Making behavior reusable.
- Avoiding huge object classes.
- Making rollback snapshots easier.
- Making network payloads easier to validate.

Practice:

Create these typed components:

```lua
export type Health = {
	current: number,
	max: number,
}

export type Team = {
	id: string,
}

export type Movement = {
	speed: number,
	direction: Vector3,
}
```

Then create three entities that combine them differently: a player, a turret, and a pickup.

Roblox rule:

If a table has methods, event connections, or Instance references, think carefully before calling it a component. Components should usually be serializable data.

## 3. System Execution Order

System execution order means the game updates in clear phases instead of depending on which Script happened to run first.

Apply it by creating a scheduler with ordered phases such as:

1. Input.
2. Command validation.
3. Simulation.
4. Collision/hit resolution.
5. State commit.
6. Replication.
7. Presentation.

Use it for:

- Combat.
- Movement.
- Rollback.
- Cooldowns.
- AI.
- Projectiles.
- Status effects.

Practice:

Make three systems: `MovementSystem`, `DamageSystem`, and `DeathSystem`. Run them in a fixed order. Prove that death is only processed after damage, and movement does not run for dead entities on the next tick.

Roblox rule:

Do not spread core simulation behavior across unrelated `Heartbeat` connections. Route important game logic through one deliberate execution pipeline.

## 4. Query Design

Query design means systems need a clean way to find entities with specific components. For example, a movement system wants every entity with `Position` and `Velocity`.

Apply it by building query helpers such as `world:query("Position", "Velocity")`. Start simple, then later optimize with cached views or archetypes.

Use it for:

- Finding damageable targets.
- Updating moving entities.
- Rendering health bars.
- Applying status effects.
- Finding interactables near a player.

Practice:

Create 100 entities with different component combinations. Write queries for:

- Entities with `Health`.
- Entities with `Health` and `Team`.
- Entities with `Position` and `Interactable`.

Print the counts and verify they match what you spawned.

Roblox rule:

Avoid using `workspace:GetDescendants()` as a gameplay query mechanism. Roblox tree search is useful at boundaries, not as your core simulation query model.

## 5. Component Mutation Rules

Component mutation rules define when and how component data can change. Without rules, systems overwrite each other and bugs become order-dependent.

Apply it by deciding which systems can write each component. For risky flows, stage changes as commands or patches, then commit them after validation.

Use it for:

- Damage application.
- Inventory transactions.
- Currency changes.
- Status effect changes.
- Rollback replay.
- Network reconciliation.

Practice:

Create a `DamageRequest` queue. Instead of directly changing `Health.current`, combat code submits damage requests. A single `DamageSystem` validates and applies them.

Roblox rule:

Never let both client UI code and server gameplay code mutate authoritative state directly. Presentation can request; authority validates and commits.

## 6. Feature Composition

Feature composition means behavior comes from component combinations rather than a giant class hierarchy.

Apply it by building entities from capabilities:

- `Health` makes something damageable.
- `Team` makes it faction-aware.
- `Inventory` makes it able to hold items.
- `Interactable` makes it usable.
- `AIController` makes it autonomous.

Use it for:

- Weapons.
- Abilities.
- NPC variants.
- Items.
- Vehicles.
- Traps.
- Doors.
- Pickups.

Practice:

Build four entities from component combinations:

- Damageable door: `Health`, `Interactable`.
- Enemy NPC: `Health`, `Team`, `Movement`, `AIController`.
- Healing pickup: `Position`, `Pickup`, `HealAmount`.
- Turret: `Health`, `Team`, `Targeting`, `Weapon`.

Then write systems that operate on components, not specific entity names.

Roblox rule:

Do not create a separate manager for every small variant. Prefer shared systems that react to component combinations.

## 7. Data Locality

Data locality means storing data in a way that is easy to iterate and process in batches. In Lua/Luau, this often means simple arrays or dictionaries organized by component type.

Apply it by storing components in tables like:

```lua
local healthByEntity: {[EntityId]: Health} = {}
local movementByEntity: {[EntityId]: Movement} = {}
```

Use it for:

- Performance.
- Easier snapshots.
- Efficient queries.
- Clear ownership.
- Batch updates.

Practice:

Make 1,000 movement entities and update them in one loop. Compare that to putting movement logic inside 1,000 separate objects with separate update connections.

Roblox rule:

Do not create one `Heartbeat` connection per entity for core simulation. Prefer one system loop that updates many records.

## 8. Runtime Registration

Runtime registration means components and systems are declared through one authoritative registry.

Apply it by requiring each component type to register its name, schema, defaults, and optional replication policy. Systems should register their phase and update function.

Use it for:

- Debugging.
- Tooling.
- Feature discovery.
- Validation.
- Replication rules.
- System order control.

Practice:

Create a component registry that can register:

- `Health`
- `Position`
- `Velocity`
- `Team`

Then reject duplicate component names and reject adding unregistered component types to entities.

Roblox rule:

Avoid scattered sibling config files for the same feature. Prefer one typed registration surface per component or feature.

## 9. ECS Debugging

ECS debugging means you can inspect entities, components, queries, and system timing without guessing through random scripts.

Apply it by building debug functions:

- `world:dumpEntity(entityId)`
- `world:listComponents(entityId)`
- `world:count("Health")`
- `world:traceSystemTimings()`

Use it for:

- Finding leaks.
- Understanding combat bugs.
- Debugging despawn issues.
- Explaining state to yourself.
- Building future Studio tooling.

Practice:

Create a command-line style debug module that prints one entity's full component state. Then add a system timing report that measures how long each system takes per update.

Roblox rule:

If a system cannot explain its current state, it will become painful at scale. Debug visibility is part of architecture, not a luxury.

## 10. Roblox Integration

Roblox integration means deciding where ECS meets Roblox Instances, Attributes, CollectionService tags, Remotes, physics, UI, and replication.

Apply it by keeping engine objects at the boundary:

- Instances are presentation or engine-backed adapters.
- Components are simulation data.
- Systems bridge between simulation and Roblox APIs.

Use it for:

- Character models.
- NPC models.
- Tools.
- Projectiles.
- UI.
- Effects.
- Replication.
- Studio-authored world objects.

Practice:

Tag several Parts with CollectionService as `Damageable`. On server start, scan those tagged Parts once, create ECS entities for them, attach `Health` and `RenderableModel` components, and store the Instance reference only in the Roblox adapter component.

Roblox rule:

Do not let every gameplay system directly crawl Workspace, mutate Attributes, fire Remotes, and manage effects. Keep Roblox API contact in adapter systems with clear authority boundaries.

## Stage 1 Master Practice Project

Build a small Roblox arena simulation with:

- Players.
- NPC enemies.
- Damageable crates.
- Pickups.
- Projectiles.
- Health.
- Teams.
- Movement.
- Interactions.
- Death/despawn.

The goal is not visual polish. The goal is architecture.

Required constraints:

1. Every simulated object has an entity id.
2. Gameplay data lives in components.
3. Behavior lives in systems.
4. Systems run in a declared order.
5. Queries find entities by component sets.
6. Damage is staged through requests.
7. No entity owns its own Heartbeat connection.
8. Components and systems are registered.
9. You can dump any entity's state for debugging.
10. Roblox Instances are integrated through boundary components or adapter systems.

Completion standard:

You understand Stage 1 when you can add a new entity type without creating a new manager, rewriting existing systems, or passing raw Instances through the whole game.
