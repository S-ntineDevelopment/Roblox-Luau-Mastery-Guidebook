# Stage 14: Contract-First Feature Architecture

Contract-first architecture means the shared system defines the rules before features exist. Features plug in by satisfying typed contracts.

Core policy:

> Shared systems own the protocol, lifecycle, validation, networking, persistence, and observability. Features supply identity, config, and domain behavior.

Foundational catalog policy:

> Managers stay agnostic. Catalogs define dynamic behavior. Features register contracts. Shared systems execute the rules.

A reusable manager must not know concrete feature names unless it is that feature package or a clearly bounded domain platform. Dynamic behavior belongs in typed catalogs and registries: strategies, rules, schemas, effects, handlers, adapters, permissions, and policies are admitted once, inspected through tooling, and executed through shared services.

Official Roblox grounding:

- ModuleScripts are the correct Roblox mechanism for shared reusable code because they return one value from `require()` and are cached per Luau environment.
- Luau `--!strict`, exported types, and gradual typing make feature contracts visible before runtime.
- RemoteEvents, UnreliableRemoteEvents, and RemoteFunctions are transport tools; contract-first architecture wraps them in typed protocol APIs.
- Actors and Parallel Luau matter later for scale, but contract boundaries must exist before parallel work is safe.

Computer science grounding:

- Interface segregation: callers receive only the methods/capabilities they need.
- Dependency inversion: feature code depends on contracts, not concrete platform internals.
- Open/closed principle: new features extend registries instead of modifying shared services.
- Command pattern: client/user/NPC intent becomes typed commands admitted by shared systems.
- Strategy pattern: fire modes, hit resolvers, prompt actions, AI actions, and vehicle policies are replaceable behavior contracts.
- State machines: lifecycle and session modes are explicit instead of implicit booleans.
- Data abstraction: feature config and runtime state are hidden behind typed APIs.
- Information hiding: Roblox Instances, remotes, persistence providers, and caches stay behind compatibility layers.

Performance grounding:

- Contract-first design reduces duplicated logic and branch-heavy shared services.
- Registries are usually O(1) lookup by id; validation cost moves to admission time instead of every hot-path branch.
- Typed configs and prevalidated registrations allow runtime paths to use smaller, predictable checks.
- Stable contracts make it easier to cache resolved behavior safely.
- Too many dynamic contract layers in hot loops can add overhead; validate at boundaries, then run direct resolved functions in performance-critical paths.
- ModuleScript caching is helpful, but do not assume it crosses Actor VM boundaries in Parallel Luau.

## Mastery Topics

1. Public service contracts before implementation.
2. Feature config schemas before feature behavior.
3. Extension registries instead of feature-name branches.
4. Capability-limited context objects.
5. Domain result/rejection types.
6. Versioned contracts for long-lived systems.
7. Contract tests for every extension point.
8. Runtime admission for registered behavior.
9. Compatibility adapters for old feature packages.
10. Tooling that proves a feature satisfies the platform contract.
11. Contract admission phases: load, validate, register, freeze, run.
12. Dependency-direction checks: features depend inward on contracts; shared systems do not import feature internals.
13. Hot-path contract resolution: resolve behavior once, then call the resolved strategy directly.
14. Failure contracts: every rejection has a typed reason and debug surface.
15. Contract evolution: old packages remain compatible through adapters or versioned schemas.
16. Dynamic behavior catalogs: feature behavior is registered, validated, inspected, versioned, and executed without feature-name branches.

## Extreme Usage Cases

- A weapon platform where adding a new gun never edits the fire service.
- A prompt platform where doors, shops, NPC dialogue, and vehicles are all registered actions.
- A vehicle platform where cars differ by config and strategy modules, not copied controllers.
- A mission platform where jobs, crimes, and objectives share session contracts.
- An NPC platform where behavior trees, utility scorers, and weapon actions satisfy the same action contracts as player systems.
- A persistence platform where shops, prompts, rewards, and gunkit unlocks submit typed transactions instead of mutating player data directly.
- A networking platform where feature packages register message schemas but never touch raw RemoteEvents.
- A UI/platform service where panels, routes, notification types, and debug inspectors register presentation adapters instead of editing one central UI router by feature name.

## Best Case Scenario

The engine exposes a small number of stable contracts. Features become lightweight packages:

```text
Feature/
  Config.luau
  ServerBehavior.luau
  ClientPresenter.luau
  Tests.luau
```

The platform validates the feature, registers it, runs it, observes it, and rejects it if it violates the contract.

Best-case runtime flow:

```text
Feature package loaded
  -> Config schema validated
  -> Behavior contracts checked
  -> Dependencies injected through limited context
  -> Feature registered by identity
  -> Hot-path handlers resolved
  -> Runtime execution uses shared validation/lifecycle/network/persistence/diagnostics
```

Best-case performance flow:

```text
Slow path:
  load config -> validate schema -> resolve contracts -> cache runtime handles

Hot path:
  command admitted -> resolved handler called -> typed result emitted
```

This prevents repeated string branching and repeated config validation during gameplay.

## Roblox API Usage

Use ModuleScripts for contracts, registries, config, service APIs, and feature packages.

Use ReplicatedStorage only for shared code and schemas that both client and server may safely know. Keep server authority implementations in ServerScriptService or server-only containers.

Use RemoteEvents for one-way gameplay messages and wrap them behind typed network channels. Use RemoteFunctions sparingly because they yield for a response and are a poor fit for high-frequency gameplay.

Use UnreliableRemoteEvents only for non-critical, continuously changing data where dropped/out-of-order updates are acceptable.

Use Actors and Parallel Luau later for isolated compute work, but do not design contracts that rely on shared mutable ModuleScript state across Actor VMs.

## Common Failure Modes

- Shared service imports feature packages by name.
- Feature configs are validated only after gameplay starts.
- Raw RemoteEvents are fired directly from feature code.
- A base class grows dozens of optional methods and flags.
- Package identity is copied into several sibling config files.
- Hot paths repeatedly validate config that should have been admitted once.
- Compatibility layers hide bad dependencies instead of reducing them.
- Feature code receives full service/world access when it only needs a narrow capability.

## Practice Project

Build a contract-first weapon feature platform.

Required contracts:

- `WeaponConfig`
- `FireMode`
- `HitResolver`
- `ReloadPolicy`
- `RecoilModel`
- `DamageEffect`
- `FireCommand`
- `FireResult`

Required platform services:

- `WeaponRegistry`
- `WeaponConfigValidator`
- `WeaponRuntimeFactory`
- `CombatValidationService`
- `NetworkSchemaRegistry`
- `DiagnosticsService`

Acceptance standard:

You can add `Pistol`, `Shotgun`, and `BurstRifle` without editing shared fire service code by feature name.

## Permanent Rule

If adding a feature requires editing shared code by name, the shared contract is incomplete.

## References

- Roblox Creator Hub: ModuleScript.
- Roblox Creator Hub: Reuse code with ModuleScripts.
- Roblox Creator Hub: Luau and type checking.
- Roblox Creator Hub: Remote events and callbacks.
- Roblox Creator Hub: Actor and Parallel Luau.
