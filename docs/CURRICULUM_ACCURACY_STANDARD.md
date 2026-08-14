# Curriculum Accuracy Standard

This curriculum is a toolbox, not a mandatory architecture. A pattern belongs in a project when it solves a demonstrated problem with less total cost than the alternatives.

## How to read normative language

- **Required** means a correctness, security, platform, or task constraint demands it.
- **Recommended** means it is a useful default whose cost and fit still need review.
- **Optional** means it is one valid technique among alternatives.
- **Experimental** means the Roblox or Luau feature may change and must be checked against current documentation before production use.

Security rules are intentionally stronger than style rules. For example, a server must validate a client request that changes shared or durable state. By contrast, a service does not have to be a metatable object, every game does not need ECS, and every dependency does not need an interface or container.

## Architecture selection

Choose the simplest model that fits the actual workload:

| Situation | Reasonable starting point |
| --- | --- |
| Small, local feature with little shared state | Functions and a ModuleScript |
| Domain orchestration with owned connections or resources | Service/controller or lifecycle handle |
| Many entities processed by the same operations | Tables, indexed stores, or ECS after measurement |
| Closed set of variants | A direct conditional or tagged union |
| Open or frequently extended behavior set | Callback table, strategy object, or registry |
| Untrusted/dynamic input | Static type plus runtime validation |
| High-frequency network data with a measured cost | Quantization/batching and possibly buffers |
| Latency-sensitive local feel | Prediction plus authoritative correction |
| Replay-sensitive bounded simulation | Fixed-step state, snapshots, and controlled randomness |

These approaches compose. A service/controller project may use ECS for one simulation-heavy subsystem. A functional codebase may use explicit dependency parameters. Composition can provide polymorphic behavior. A direct `if` over three stable variants can be clearer than a registry.

## Evidence standard

Each stage must distinguish:

1. a language or engine fact;
2. a common engineering heuristic;
3. a project-specific policy;
4. a technique that requires profiling or runtime proof.

Do not convert a heuristic into an engine fact. Do not claim that a type annotation enforces runtime security, a fixed timestep guarantees deterministic results, a buffer is automatically cheaper, or an abstraction improves performance without measurement.

## Lesson verification labels

The complete `.luau` programs under [`docs/lessons`](lessons/README.md) are the curriculum's type-checked examples. Every curriculum page embeds the exact matching program between `BEGIN VERIFIED LESSON` and `END VERIFIED LESSON` markers. The verification script fails if visible code differs from the analyzed source. A lesson may be called **type checked** only when the recorded `luau-analyze` command completes with no diagnostics for that exact file and compiler version. A lesson may be called **runtime checked** only when its assertions also run successfully.

Markdown fragments elsewhere may be partial illustrations. Do not describe them as independently type checked unless they are identical to a checked lesson file. Neither label proves Roblox API behavior, Studio lifecycle, live-provider behavior, networking conditions, security, or performance.

## Current platform corrections

- Luau is gradually typed. Static types do not exist as runtime validators and casts can suppress useful checking.
- Luau primitive-intersection “brands” such as `number & { __brand: ... }` are not valid nominal primitive types. Use a wrapper record when compile-time separation is worth an allocation, or use a primitive alias plus boundary validation when it is not.
- Metatable `__newindex` does not observe writes to keys already present on the table. A write-guard normally needs a separate proxy whose storage lives elsewhere.
- RemoteEvents are asynchronous one-way messages. RemoteFunctions yield for a reply; server-to-client `InvokeClient()` can error or yield indefinitely. UnreliableRemoteEvents may drop and reorder messages and currently impose a 1,000-byte payload limit.
- `buffer` is a fixed-size byte container. Bounds, versions, ranges, and decode costs remain the application’s responsibility. Binary representation is not automatically smaller once compression and message shape are considered.
- `UpdateAsync()` coordinates changes to one DataStore key; it is not a general multi-key ACID transaction. Its callback cannot yield and the operation consumes read and write budget.
- Parallel Luau uses Actors and parallel-safe APIs. Actor ModuleScript state is isolated per VM; `require()` cannot be called after desynchronizing. Parallelism has overhead and should follow profiling.
- Roblox’s current server-authority model has special prediction and attribute rules. In that mode, attributes on predicted instances can be core synchronized simulation data. That is an engine-specific exception to older blanket advice against gameplay attributes and must be implemented within the documented limits.

## Primary references

- [Luau type system](https://luau.org/types/)
- [Luau unions and intersections](https://luau.org/types/unions-and-intersections/)
- [Luau object-oriented typing patterns](https://luau.org/types/object-oriented-programs/)
- [Luau performance](https://luau.org/performance/)
- [Luau standard library and buffers](https://luau.org/library/)
- [Roblox client-server runtime](https://create.roblox.com/docs/projects/client-server)
- [Roblox remote events and callbacks](https://create.roblox.com/docs/scripting/events/remote)
- [Roblox client-server security](https://create.roblox.com/docs/scripting/security/client-server-boundary)
- [Roblox network ownership and movement validation](https://create.roblox.com/docs/scripting/security/network-ownership)
- [Roblox server-authority model](https://create.roblox.com/docs/projects/server-authority)
- [Roblox Parallel Luau](https://create.roblox.com/docs/scripting/multithreading)
- [Roblox data stores](https://create.roblox.com/docs/cloud-services/data-stores)
- [Roblox memory stores](https://create.roblox.com/docs/cloud-services/memory-stores)
- [Roblox performance optimization](https://create.roblox.com/docs/performance-optimization)

Platform behavior changes. Recheck current Creator Hub and Luau documentation before relying on limits, beta features, thread-safety tags, replication behavior, or API availability.
