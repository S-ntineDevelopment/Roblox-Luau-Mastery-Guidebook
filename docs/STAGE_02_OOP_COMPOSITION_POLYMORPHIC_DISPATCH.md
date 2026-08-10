# Stage 2: OOP, Composition, and Polymorphic Dispatch

OOP in Luau is not about copying Java or pretending every table is a class. In Roblox architecture, OOP is most useful when you need clear ownership, lifecycle, reusable behavior, and stable APIs around services, adapters, controllers, tools, runtime objects, and framework internals.

ECS is best for simulation state and mass behavior. OOP is best for boundaries, orchestration, services, adapters, and objects that own resources.

Core policy:

> Use ECS for shared simulation data. Use OOP for explicit ownership, lifecycle, adapters, services, and polymorphic behavior. Use composition to add capability. Avoid giant inheritance trees.

## 1. Metatable Class Patterns

Metatable classes are the standard way to create object-like structures in Luau.

Apply it by creating modules that return a table with a constructor and methods:

```lua
--!strict

local WeaponController = {}
WeaponController.__index = WeaponController

export type WeaponController = typeof(setmetatable({} :: {
	owner: Player,
	weaponId: string,
}, WeaponController))

function WeaponController.new(owner: Player, weaponId: string): WeaponController
	local self = setmetatable({
		owner = owner,
		weaponId = weaponId,
	}, WeaponController)

	return self
end

function WeaponController:destroy()
	-- cleanup here
end

return WeaponController
```

Used for:

- Controllers.
- Services.
- Runtime handles.
- Roblox Instance adapters.
- Debug tools.
- Network clients.
- Object pools.

Practice:

Create a `PromptController` object that owns one prompt's UI state and connection cleanup. Then create and destroy it 100 times without leaking connections.

Mastery rule:

Every object that creates connections, tasks, Instances, or subscriptions needs a `destroy` method.

## 2. Interface-by-Contract Design

Luau does not require formal interfaces, but you can define explicit type contracts.

Apply it by defining the shape an object must satisfy:

```lua
export type Activatable = {
	canActivate: (self: Activatable, player: Player) -> boolean,
	activate: (self: Activatable, player: Player) -> (),
	destroy: (self: Activatable) -> (),
}
```

Used for:

- Abilities.
- Prompt actions.
- Weapon firing modes.
- Inventory item effects.
- AI behaviors.
- Quest objectives.

Practice:

Create three prompt actions that share the same `InteractAction` contract:

- OpenDoorAction.
- BuyItemAction.
- StartDialogueAction.

The prompt system should call them through the contract, not through feature-name conditionals.

Mastery rule:

If a shared system needs to call feature behavior, define the required behavior as a contract.

## 3. Composition Over Inheritance

Composition means building objects from smaller capabilities instead of deep class trees.

Bad direction:

```text
BaseWeapon
  Gun
    Rifle
      BurstRifle
        FireBurstRifleWithScope
```

Better direction:

```text
Weapon = FireMode + AmmoStore + SpreadModel + RecoilModel + HitResolver
```

Used for:

- Gunkits.
- Abilities.
- Vehicles.
- NPCs.
- Prompt actions.
- UI controllers.
- Tools.

Practice:

Build a weapon runtime object from injected parts:

- `AmmoStore`
- `FireMode`
- `CooldownGate`
- `HitResolver`
- `RecoilPresenter`

Then swap only the `FireMode` to turn a semi-auto gun into a burst weapon.

Mastery rule:

Prefer small replaceable collaborators over inheritance depth.

## 4. Polymorphic Dispatch

Polymorphic dispatch means calling the same method on different objects and letting each object decide its behavior.

Apply it when you are tempted to write:

```lua
if actionType == "Door" then
	openDoor()
elseif actionType == "Shop" then
	openShop()
elseif actionType == "Dialogue" then
	startDialogue()
end
```

Instead:

```lua
action:execute(context)
```

Used for:

- Prompt actions.
- Ability effects.
- Item effects.
- Weapon fire modes.
- AI decisions.
- Quest rewards.
- Status effects.

Practice:

Create a shared `Effect` contract with `apply(context)`. Implement:

- DamageEffect.
- HealEffect.
- KnockbackEffect.
- GiveItemEffect.
- StartQuestEffect.

Then make an ability run a list of effects without checking their names.

Mastery rule:

If code keeps checking feature names, it probably wants polymorphism.

## 5. Dependency Injection

Dependency injection means objects receive their dependencies instead of requiring globals directly everywhere.

Apply it by passing services into constructors:

```lua
local controller = WeaponController.new({
	world = world,
	network = network,
	clock = clock,
	raycast = raycast,
})
```

Used for:

- Testing.
- Cleaner boundaries.
- Replacing implementations.
- Avoiding hidden dependencies.
- Server/client variants.

Practice:

Build a `DamageService` that receives a `Clock`, `World`, and `Logger`. In tests, inject a fake clock and fake logger.

Mastery rule:

Constructors should reveal what an object depends on.

## 6. Lifecycle Methods

Lifecycle methods define how an object enters, runs, pauses, resumes, and exits.

Apply it by standardizing names:

- `init`
- `start`
- `stop`
- `destroy`
- `pause`
- `resume`

Used for:

- Services.
- Match sessions.
- Controllers.
- UI screens.
- ECS worlds.
- Prompt runtime.
- Weapon runtime.
- NPC brains.

Practice:

Create a `MatchSession` object with:

- `init`
- `start`
- `endMatch`
- `destroy`

Make `destroy` safe to call twice.

Mastery rule:

Every lifecycle must be explicit, idempotent where practical, and cleanup-owned.

## 7. Object Pooling

Object pooling reuses objects instead of constantly creating and destroying them.

Apply it for high-frequency temporary things:

- Projectiles.
- Bullet tracers.
- Hit markers.
- Floating damage numbers.
- Prompt UI rows.
- Particles.
- Sound emitters.

Used for:

- Reducing garbage.
- Avoiding frame spikes.
- Smoother combat.
- Predictable memory usage.

Practice:

Create a tracer pool with `acquire` and `release`. Fire 500 fake shots and prove only a small fixed number of tracer objects were created.

Mastery rule:

Pool visual and transient runtime objects. Do not pool complex authoritative state unless ownership and reset rules are strict.

## 8. Error Boundaries

Error boundaries make object APIs fail early and clearly when used incorrectly.

Apply it by validating constructor inputs, lifecycle state, and public method arguments.

Used for:

- Framework internals.
- Network handlers.
- Prompt actions.
- Weapon configs.
- Service APIs.
- Plugin APIs.

Practice:

Make `WeaponController.new(config)` reject missing `fireMode`, `ammoStore`, or `hitResolver`. Include the weapon id in the error message.

Mastery rule:

Invalid construction should fail immediately. Invalid runtime requests should return structured failure when recovery is expected.

## 9. Service Object Design

Service objects own one domain and expose a narrow public API.

Apply it by building services like:

- `EntityService`
- `DamageService`
- `PromptService`
- `InventoryService`
- `AbilityService`
- `NetworkService`
- `ReplicationService`

Used for:

- Stable architecture boundaries.
- Shared game systems.
- Testing.
- Cross-feature coordination.
- Server authority.

Practice:

Design a `PromptService` with only these public methods:

- `registerPrompt`
- `unregisterPrompt`
- `requestInteraction`
- `getPromptState`

Everything else should be private implementation.

Mastery rule:

A service is not a dumping ground. If it has too many reasons to change, split the domain.

## 10. Roblox Object Adapters

Roblox object adapters wrap Instances so the rest of your architecture does not become dependent on raw engine details.

Apply it by wrapping Models, Tools, ProximityPrompts, UI objects, Remotes, and CollectionService tags behind stable APIs.

Used for:

- Character adapters.
- Weapon Tool adapters.
- Prompt adapters.
- UI adapters.
- Remote adapters.
- Workspace entity adapters.

Practice:

Create a `ProximityPromptAdapter` that:

- Creates or receives a `ProximityPrompt`.
- Connects to `Triggered`.
- Converts the trigger into a typed interaction request.
- Cleans up connections in `destroy`.

The gameplay system should not directly know about the `Triggered` event.

Mastery rule:

Roblox Instances are engine integration details. Keep them near the boundary.

## Genius-Level Application

The advanced move is combining ECS and OOP correctly:

- ECS stores `Weapon`, `Ammo`, `Cooldown`, `Owner`, and `DamageSource` data.
- OOP owns `WeaponController`, `RaycastService`, `NetworkChannel`, and `ToolAdapter`.
- Polymorphism powers `FireMode`, `HitResolver`, `Effect`, and `PromptAction`.
- Dependency injection keeps server/client/test versions swappable.
- Lifecycle rules make cleanup predictable.

Example gunkit architecture:

```text
ECS:
  Weapon
  Ammo
  Cooldown
  Owner
  Spread
  DamageSource

OOP:
  WeaponRuntime
  ToolAdapter
  RaycastService
  RecoilPresenter
  NetworkChannel

Polymorphic contracts:
  FireMode
  HitResolver
  ReloadPolicy
  RecoilModel
  Effect
```

Example prompt architecture:

```text
ECS:
  Prompt
  Interactable
  InteractionRange
  PermissionRule
  Cooldown

OOP:
  PromptService
  PromptAdapter
  PromptPresenter
  InteractionContext

Polymorphic contracts:
  PromptAction
  PermissionCheck
  InteractionEffect
```

## Stage 2 Master Practice Project

Build a reusable interaction framework.

Requirements:

1. `PromptService` owns prompt registration and interaction requests.
2. `ProximityPromptAdapter` converts Roblox prompt events into service calls.
3. Prompt actions use a shared `execute(context)` contract.
4. Permission checks are composable objects.
5. Cooldowns are handled by a shared cooldown object or service.
6. The prompt system does not contain door/shop/dialogue conditionals.
7. Every object that creates connections has `destroy`.
8. Constructors receive dependencies explicitly.
9. Invalid configs fail during registration.
10. The same framework supports doors, shops, dialogue, loot crates, and vehicle seats.

Completion standard:

You understand Stage 2 when you can add a new gameplay behavior by implementing a small contract object, not by editing a central conditional chain or copying a manager.

## Mastery Summary

To use OOP at a serious level in Roblox, do not think of it as "make everything a class." Think of it as the architecture tool for ownership, boundaries, lifecycles, adapters, and replaceable behavior.

The main benefit is this:

> OOP gives your systems stable APIs and explicit ownership. Composition and polymorphism let features vary without central systems needing to know every feature name.

ECS answers:

```text
What data exists?
Which entities have it?
Which systems process it?
```

OOP answers:

```text
Who owns this resource?
Who cleans it up?
What API is exposed?
What behavior can be swapped?
What boundary hides Roblox engine details?
```

## How To Use OOP At A High Level

Use OOP for:

- Services.
- Controllers.
- Runtime handles.
- Adapters around Roblox Instances.
- Object pools.
- Network channels.
- Debug inspectors.
- Feature actions.
- Strategy objects.
- Lifecycle-owned resources.

Avoid using OOP for:

- Mass simulation state that should be plain ECS data.
- Huge inheritance trees.
- Objects that are only passive data.
- Feature managers that become dumping grounds.
- Classes that exist only to hold one function.

The best policy is:

> OOP owns boundaries and behavior variation. ECS owns simulation state.

## For Gunkits

A weak gunkit design creates separate scripts for each weapon and grows conditional logic:

```text
if weaponType == "Rifle" then
elseif weaponType == "Shotgun" then
elseif weaponType == "Burst" then
```

A stronger design uses contracts:

```text
WeaponRuntime
  FireMode
  AmmoStore
  ReloadPolicy
  SpreadModel
  RecoilModel
  HitResolver
  EffectPipeline
```

The weapon runtime owns the lifecycle. The collaborators define the behavior.

Examples:

- Semi-auto rifle: `SingleShotFireMode`, `MagazineAmmoStore`, `RaycastHitResolver`.
- Shotgun: `PelletFireMode`, `MagazineAmmoStore`, `MultiRaycastHitResolver`.
- Grenade launcher: `ProjectileFireMode`, `SingleRoundAmmoStore`, `ExplosionHitResolver`.
- Beam weapon: `HeldFireMode`, `EnergyAmmoStore`, `ContinuousTraceResolver`.

The benefit:

You add a new weapon by composing behavior objects and config, not by rewriting the core weapon controller.

## For Prompt Systems

A weak prompt system puts all behavior into one script:

```text
if promptKind == "Door" then
elseif promptKind == "Shop" then
elseif promptKind == "Vehicle" then
elseif promptKind == "Dialogue" then
```

A stronger design uses action objects:

```text
PromptService
PromptAdapter
InteractionContext
PromptAction
PermissionCheck
InteractionEffect
```

Different prompts implement the same contract:

```text
OpenDoorAction:execute(context)
OpenShopAction:execute(context)
EnterVehicleAction:execute(context)
StartDialogueAction:execute(context)
LootCrateAction:execute(context)
```

The benefit:

The prompt framework stays stable while gameplay expands indefinitely.

## For Every Roblox System

Use this decision map:

```text
Is it shared simulation data?
  Use ECS component data.

Does it own connections, Instances, tasks, or cleanup?
  Use an object with lifecycle.

Does behavior vary by feature?
  Use a polymorphic contract.

Does it touch Roblox APIs directly?
  Use an adapter object.

Does it coordinate one domain?
  Use a narrow service object.

Does it need to be tested independently?
  Inject dependencies.
```

## The Indefinite Framework

Your long-term Roblox framework should include these OOP-backed architecture pieces:

```text
ServiceContainer
LifecycleRunner
ResourceCleaner
NetworkChannel
RemoteAdapter
InstanceAdapter
ControllerFactory
ObjectPool
ActionRegistry
EffectRegistry
PermissionRegistry
DebugInspector
```

Each piece has a permanent role:

- `ServiceContainer` wires dependencies.
- `LifecycleRunner` starts and stops services in order.
- `ResourceCleaner` owns cleanup.
- `NetworkChannel` wraps remotes behind typed APIs.
- `RemoteAdapter` hides RemoteEvent and RemoteFunction details.
- `InstanceAdapter` hides Roblox Instance details.
- `ControllerFactory` creates runtime controllers.
- `ObjectPool` reuses transient objects.
- `ActionRegistry` stores prompt, item, and ability actions.
- `EffectRegistry` stores reusable effects.
- `PermissionRegistry` stores reusable validation policies.
- `DebugInspector` exposes runtime state safely.

The deeper benefit is consistency. Once these pieces exist, every new system has the same shape.

## How To Master It

Practice in this order:

1. Build a metatable object with `new` and `destroy`.
2. Add strict Luau types to the object.
3. Make `destroy` idempotent.
4. Add a small cleanup container for connections and Instances.
5. Define one interface-by-contract type.
6. Implement three different objects that satisfy the same contract.
7. Replace a conditional chain with polymorphic dispatch.
8. Inject dependencies instead of requiring globals inside the object.
9. Build a narrow service object with a public API.
10. Build an adapter around a Roblox Instance.
11. Compose a weapon from smaller behavior objects.
12. Compose a prompt from action and permission objects.
13. Add runtime config validation.
14. Add fake dependencies for tests.
15. Convert one real project system away from feature-name conditionals.

The best first real project is a reusable prompt framework. It is simpler than a full gunkit, but it teaches contracts, adapters, services, permissions, cleanup, and composition.

Then build the gunkit using the same principles.

## Permanent Policy

Use this rule for every future Roblox system:

> If a feature owns resources, exposes an API, adapts Roblox Instances, varies behavior by type, or needs controlled lifecycle, model it with OOP plus composition. If it represents shared simulation state, keep the data in ECS.

The true mastery is knowing how ECS and OOP support each other:

- ECS gives you scalable state and system processing.
- OOP gives you clean ownership and replaceable behavior.
- Composition keeps systems open for extension.
- Polymorphism removes feature-name conditionals.
- Dependency injection makes systems testable.
- Lifecycle discipline prevents leaks.

When these are combined, your framework stops being a collection of managers and becomes a reusable architecture platform.
