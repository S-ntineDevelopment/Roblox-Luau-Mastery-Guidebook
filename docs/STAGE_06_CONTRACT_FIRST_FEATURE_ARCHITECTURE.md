# Stage 6: Contract-First Feature Design

**Difficulty:** Intermediate
**Suggested prerequisites:** Stages 2-5

## Guided lesson: register one named action

**Use case:** Separately owned features can register actions under stable IDs.

**Complete code:** [STAGE_06_ACTION_CONTRACT.luau](lessons/STAGE_06_ACTION_CONTRACT.luau)

1. Read `Action`; every implementation accepts a player name and returns text.
2. Follow `register()` to see empty and duplicate IDs rejected at admission.
3. Follow `run()` to see a missing action return `nil` instead of crashing.

- **Expected result:** `Greet` returns `Hello, Ari!`; duplicate and missing registrations are controlled.
- **Try it:** register a `Farewell` action without changing `run()`.
- **Common mistake:** using a registry for three permanent variants that would be clearer in one direct table or conditional.

A contract describes what callers and implementations may rely on. Designing that boundary early is useful when multiple owners, implementations, or trust domains must coordinate. It is not a reason to create an interface and registry for every feature.

Read [Curriculum Accuracy Standard](CURRICULUM_ACCURACY_STANDARD.md) before this stage.

## Start from use cases

Before defining a contract, identify:

- concrete callers and operations;
- authoritative state and validation;
- expected failures;
- ownership/lifecycle;
- which variation is known now;
- which compatibility promises are real.

A speculative “generic” interface often encodes the wrong variation and pushes special cases into configuration.

## Closed and open sets

For a small closed set of variants, a tagged union and direct conditional can provide:

- visible exhaustive handling;
- easy navigation;
- no registration-order failures;
- simple refactoring.

For an open set owned by separate packages or content, a registry/strategy contract can provide:

- ID-based lookup;
- independent extension;
- admission validation;
- tooling/discovery.

The earlier rule “if adding a feature edits shared code, the contract is incomplete” was false. Editing a clear closed dispatcher can be the safest design.

## Contract forms

A contract may be:

- a plain function signature;
- a ModuleScript return type;
- a table/method shape;
- a tagged command/result union;
- a runtime schema;
- a lifecycle protocol;
- a documented sequence of operations.

Prefer the smallest form that captures the real guarantee.

## Registration

When a registry is justified, define:

- ID namespace and duplicate behavior;
- registration/bootstrap order;
- static type and runtime admission;
- lookup failure;
- replacement/removal/version policy;
- iteration order if observable;
- debug listing and ownership.

Dictionary lookup is commonly efficient but not a strict timing guarantee. Registration validation cannot replace runtime permission/state/security checks.

## Capability and dependency boundaries

Give extension code the operations it needs when that reduces coupling or privilege. A capability-shaped table is an architecture technique, not necessarily a security boundary in unrestricted same-environment code.

Dependency injection can be simple explicit parameters. A direct import is acceptable for stable dependencies. Avoid a service locator/container that makes dependencies less visible.

## Roblox placement

ReplicatedStorage contents are available to clients and replicated ModuleScript source should be assumed inspectable. Keep server secrets and authority-only implementations in server containers. Shared schemas/types may live in replicated code, but do not mistake hiding implementation for server validation.

Raw RemoteEvents are valid Roblox primitives. A protocol adapter is useful when it centralizes schemas, validation, rates, diagnostics, or versioning; wrapping every remote with no additional policy is optional indirection.

## Performance

Contract-first design is not automatically faster. Indirection, allocation, generic validators, registry lookup, and callback dispatch all have costs. The performance benefit comes only if the design removes repeated work, admits config once, improves batching, or enables a measured optimization.

Keep hostile-input validation on every request even when static config was validated at registration.

## Practice project

Implement five fixed prompt actions first with a tagged union and exhaustive dispatcher. Then build a registry version that supports third-party feature modules.

Compare:

- adding/removing an action;
- invalid/missing registration;
- discoverability and stack traces;
- static checking;
- runtime overhead;
- compatibility burden.

Choose based on the actual extension model, not “open/closed” slogans.

## Completion evidence

You understand this stage when you can:

- derive a boundary from callers and failures;
- choose a conditional for a closed set without treating it as a defect;
- justify a registry for an open set;
- separate admission validation from per-request validation;
- state what a capability/API does and does not secure;
- delete speculative extension points.

## Primary references

- [Luau structural types](https://luau.org/types/)
- [Luau union and intersection types](https://luau.org/types/unions-and-intersections/)
- [Roblox ModuleScripts](https://create.roblox.com/docs/scripting/module)
- [Roblox security tactics](https://create.roblox.com/docs/scripting/security/security-tactics)
- [Roblox remote events and callbacks](https://create.roblox.com/docs/scripting/events/remote)
