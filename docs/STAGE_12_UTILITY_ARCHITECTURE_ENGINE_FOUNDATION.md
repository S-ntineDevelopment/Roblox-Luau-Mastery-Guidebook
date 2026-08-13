# Stage 12: Utilities and Engine Foundations

Utilities should reduce repeated semantic work. They should not become a second standard library, a mandatory wrapper around every Roblox API, or a dependency maze called an “engine.”

Read [Curriculum Accuracy Standard](CURRICULUM_ACCURACY_STANDARD.md) before this stage.

## Promotion criteria

Promote a helper when evidence shows:

- the same semantic contract recurs;
- callers benefit from one bug fix or policy;
- the API can be named and tested clearly;
- dependency direction remains understandable;
- the abstraction costs less than direct code.

“Useful twice” is not a rule. Two uses may be coincidental, and a good utility may be justified by one high-risk cross-cutting boundary.

## Categories that often earn reuse

- result/error vocabulary;
- runtime validators;
- cleanup/resource ownership;
- clocks and test fakes;
- bounded queues/rate limiters;
- IDs and sequence helpers;
- network codecs after measurement;
- profile repositories and test providers;
- structured diagnostics;
- Roblox boundary adapters with actual substitution/lifecycle value.

No project needs every category.

## Dependency direction

A layered dependency graph can prevent cycles, but there is no universal ordering such as `Core -> Contracts -> Validation -> ...` that fits every repository. Define and enforce the project’s actual layers.

Useful constraints often include:

- pure utilities do not require Roblox services;
- server-only persistence does not leak into shared/client code;
- feature packages depend on public domain APIs rather than private tables;
- test fakes satisfy the same relevant semantics as production providers.

Do not split a tiny cohesive module simply to satisfy a layer count.

## Wrappers and adapters

Wrap a platform API when the wrapper owns a meaningful policy:

- validation/security;
- retry/budget behavior;
- lifecycle/cleanup;
- version translation;
- environment substitution;
- batching/measurement;
- testability that a direct call prevents.

A wrapper that forwards every method unchanged is a maintenance surface with little value. Platform APIs and their documented behavior should remain visible when callers need them.

## Cleaners

A cleaner can aggregate heterogeneous cleanup, but it does not decide ownership for you. Document:

- what values it accepts;
- cleanup order;
- idempotency;
- behavior when one cleanup errors;
- whether adding after cleanup runs immediately or errors;
- whether it holds strong references.

Do not add already-destroyed or externally owned resources without a clear ownership transfer.

## Registries

Registries are useful for ID-based dynamic lookup. They require duplicate policy, admission validation, removal/versioning, iteration order, and debug visibility.

Dictionary lookup is typically efficient, but do not promise strict O(1) timing or claim that registration-time validation removes all runtime validation. Player context and hostile commands still change at runtime.

## Caches

Caching changes correctness. Define source of truth, key, value, invalidation, TTL/freshness, negative-cache behavior, capacity, eviction, and failure fallback.

Do not add a cache before identifying the expensive/repeated operation and measuring hit rate. A stale or unbounded cache can be worse than the original cost.

## Pools

Pooling belongs with performance evidence and strict reset/lifecycle rules. It is not a default lifecycle utility. Cap retained Instances and compare memory/CPU under a representative workload.

## Types and IDs

Avoid impossible primitive-intersection brands. Use primitive aliases when representation cost matters and wrapper records when checker-enforced domain separation is worth it. A central `Types` module can also become a coupling hotspot; keep types near their owning domain unless truly shared.

## Test doubles

A fake provider must model the semantics the test relies on. An in-memory DataStore fake that never throttles, retries callbacks, returns stale reads, or conflicts cannot prove live provider behavior. Label deterministic unit proof separately from integration/runtime proof.

## Practice project

Audit ten existing helpers. For each, record:

- semantic purpose;
- callers;
- owner;
- test evidence;
- dependencies;
- whether direct code is clearer;
- promote, keep local, merge, or delete.

Then build one bounded queue or validator used by two real consumers and measure whether the shared API reduces duplicated policy without hiding necessary details.

## Completion evidence

You understand this stage when you can:

- reject a generic helper that has no stable semantic contract;
- justify each wrapper with owned policy;
- define cleaner/cache/registry failure and lifecycle behavior;
- preserve project-specific dependency direction without universal dogma;
- distinguish fake-provider proof from live-provider proof;
- remove a utility when direct code is cheaper.

## Primary references

- [Roblox ModuleScripts](https://create.roblox.com/docs/scripting/module)
- [Luau type system](https://luau.org/types/)
- [Luau performance](https://luau.org/performance/)
- [Roblox performance optimization](https://create.roblox.com/docs/performance-optimization)
- [Roblox data stores](https://create.roblox.com/docs/cloud-services/data-stores)
