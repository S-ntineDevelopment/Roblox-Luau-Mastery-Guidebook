# Stage 16: Source Generation, Templates, and Static Analysis

Mastery means the engine can generate correct structure and reject bad structure before runtime. If a policy is important, the project should eventually have a template, generator, static check, audit, or CI gate for it.

Core policy:

> If humans repeat a framework pattern manually, turn it into a template, generator, validator, or static audit.

## Computer Science Fundamentals

- Metaprogramming: code writes consistent code or config.
- Static analysis: inspect source without running it.
- Linting: enforce style and policy automatically.
- Abstract syntax thinking: find imports, calls, globals, and dependency direction.
- Code generation: produce boilerplate from a higher-level schema.
- Build pipelines: make validation part of project workflow.
- Regression prevention: once a bug becomes a rule, automate the rule.

## Roblox API Grounding

- ModuleScripts make feature packages generator-friendly because they return typed tables/contracts.
- Luau type checking supports generated type surfaces and contract stubs.
- Rojo project maps make source trees auditable outside Studio.
- Creator Hub service boundaries guide audits: raw RemoteEvents, DataStoreService, RunService, CollectionService, and Attributes should appear only in allowed adapter layers.
- ProceduralModel generator modules show Roblox's own pattern for parameter-driven generation; generation code should write into its target container rather than mutate arbitrary hierarchy.

## Performance Impact

- Generated feature skeletons reduce manual mistakes but should not generate bloated runtime layers.
- Static audits are build-time cost, not gameplay cost.
- Precomputed registries can reduce runtime discovery overhead.
- Generated validators must avoid excessive allocation in hot paths.
- Dependency checks prevent performance regressions caused by hidden service imports and cross-layer coupling.

## Mastery Topics

1. Feature package generators.
2. Config schema generators.
3. Network schema generators.
4. Contract test generators.
5. Registry audit tools.
6. Dependency-direction static checks.
7. Feature-name conditional detection.
8. Attribute misuse detection.
9. Raw RemoteEvent access detection.
10. CI/preflight architecture gates.
11. DataStore access boundary audits.
12. RunService/Heartbeat ownership audits.
13. Generated rejection reason enums.
14. Generated docs from schemas.
15. Architecture score reports.

## Extreme Usage Cases

- Generate a new weapon package with config, fire mode stub, tests, and network schema.
- Audit the repo for shared code branching on feature names.
- Reject modules that import Roblox services from core utility layers.
- Detect direct durable-state mutation outside transaction services.
- Detect raw `RemoteEvent:FireServer` usage outside network adapters.
- Detect Attributes used as authoritative ammo/health/currency state.

## Best Case Scenario

The engine ships with tooling:

```text
create-feature weapon Rifle
audit-contracts
audit-dependencies
audit-network
audit-persistence
audit-attributes
audit-runservice
```

Bad architecture fails before it reaches Studio.

## Practice Project

Build an architecture audit tool that scans source for:

- raw RemoteEvent calls outside network adapters
- `game:GetService("DataStoreService")` outside persistence adapters
- `RunService.Heartbeat` outside scheduler/adapters
- feature-name conditionals inside shared services
- Attribute writes to banned authoritative keys

Acceptance standard:

The tool reports file path, line, rule id, severity, and suggested boundary.

## Permanent Rule

A policy that cannot be checked will eventually be violated.

## References

- Roblox Creator Hub: Luau and type checking.
- Roblox Creator Hub: ModuleScript.
- Roblox Creator Hub: Remote events and callbacks.
- Roblox Creator Hub: Procedural models.
