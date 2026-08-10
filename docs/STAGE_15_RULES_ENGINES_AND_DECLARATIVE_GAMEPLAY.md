# Stage 15: Rules Engines and Declarative Gameplay

Rules engines let gameplay be assembled from validated conditions, costs, effects, cooldowns, targeting, permissions, rewards, and rejection reasons. This is the natural next step after contract-first design: once contracts exist, features should declare what they want to do while the shared rules engine owns the order, validation, transactions, networking, and diagnostics.

Core policy:

> Feature packages declare rules. Shared engines validate, order, execute, audit, and replicate them.

## Computer Science Fundamentals

- Interpreter pattern: the rules engine interprets declarative rule records.
- Command pattern: a requested action becomes a command admitted into the rule pipeline.
- Strategy pattern: conditions, effects, target selectors, and cost handlers are replaceable strategies.
- Chain of responsibility: validation flows through ordered checks with typed rejection reasons.
- Algebraic data modeling: effects and conditions become discriminated unions.
- Transaction processing: rule execution commits or rejects as a unit.
- Referential transparency where possible: pure condition/effect calculations are easier to test and cache.

## Roblox API Grounding

- Use ModuleScripts for rule definitions, registries, validators, and feature configs.
- Use RemoteEvents only as transport for typed commands; the rules engine admits and executes them server-side.
- Use DataStoreService only through transaction/persistence services when rules affect durable state.
- Use MemoryStoreService for ephemeral cross-server queues, matchmaking, auctions, or caches, not durable truth.
- Use CollectionService tags only for discovery; convert tagged Instances into typed rule targets or ECS entities before gameplay logic.

## Performance Impact

- Declarative rules reduce duplicated feature scripts and branch-heavy shared services.
- Prevalidate rule configs at load time, then cache resolved handlers for hot paths.
- Keep condition checks cheap and ordered: reject impossible/cheap cases before expensive geometry, pathfinding, or datastore work.
- Avoid allocating new rule context tables in tight loops where a pooled/context builder can be used safely.
- Use batching for repeated target queries, effects, and replication deltas.
- Do not run economy/persistence effects inside high-frequency simulation loops.

## Mastery Topics

1. Condition contracts.
2. Cost contracts.
3. Effect contracts.
4. Target selector contracts.
5. Cooldown and timing policies.
6. Permission policies.
7. Rule pipeline ordering.
8. Transaction-backed rewards.
9. Rule explainability and rejection reasons.
10. Rule authoring tools and validators.
11. Prevalidated hot-path rule handles.
12. Rule context capability limits.
13. Pure rule simulation for previews/tests.
14. Rule diffs and migration support.
15. Rule execution traces.

## Extreme Usage Cases

- A gun attachment declares modifiers, not custom weapon scripts.
- A quest objective declares conditions and rewards, not bespoke completion code.
- An ability declares targeting, costs, effects, and cooldowns.
- A shop declares purchase rules and transaction outputs.
- NPC actions use the same rule pipeline as player abilities.
- Prompt interactions produce typed rule commands with server-owned rewards.

## Best Case Scenario

Most features are data plus small registered handlers:

```lua
{
	id = "ArmorPiercingRounds",
	conditions = {"WeaponEquipped", "AmmoAvailable"},
	costs = {{kind = "Ammo", amount = 1}},
	effects = {
		{kind = "Damage", amount = 18},
		{kind = "ArmorPierce", percent = 0.35},
	},
}
```

The rules engine validates, executes, logs, and rejects consistently.

## Practice Project

Build a rule engine for weapon abilities:

- `ConditionRegistry`
- `CostRegistry`
- `TargetSelectorRegistry`
- `EffectRegistry`
- `RuleValidator`
- `RuleExecutor`
- `RuleTrace`

Acceptance standard:

You can add `ArmorPiercingRounds`, `StunShot`, and `HealPulse` by config plus registered effects without editing the shared executor by name.

## Permanent Rule

Repeated `validate -> cost -> mutate -> reward` flows belong in a rules engine.

## References

- Roblox Creator Hub: ModuleScript and reusable code.
- Roblox Creator Hub: Remote events and callbacks.
- Roblox Creator Hub: Data stores.
- Roblox Creator Hub: Memory stores.
