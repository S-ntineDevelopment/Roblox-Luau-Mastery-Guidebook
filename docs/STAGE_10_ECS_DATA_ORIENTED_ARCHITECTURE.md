# Stage 10: ECS and Data-Oriented Design

**Difficulty:** Advanced
**Suggested prerequisites:** Stages 1-4; Stage 7 is strongly recommended

## Guided lesson: the smallest ECS-shaped update

**Use case:** Regenerate every entity that currently has a health component.

**Complete code:** [STAGE_10_TINY_ECS.luau](lessons/STAGE_10_TINY_ECS.luau)

1. `healthByEntity` maps entity IDs to plain health records.
2. `regenerate()` is a system-like function that processes every matching record.
3. `math.min()` keeps current health under its maximum.

- **Expected result:** entity `1` reaches `8`; entity `2` clamps at `10`.
- **Try it:** add an entity with no health by storing it in a separate position table; regeneration should not know about it.
- **Common mistake:** assuming this small dictionary is a full ECS or that ECS automatically improves performance.

Entity Component System (ECS) is one architecture for representing many entities and applying shared operations to their data. It is not the definition of good Roblox architecture and it is not required for service/controller, feature-package, object-oriented, or functional codebases.

Read [Curriculum Accuracy Standard](CURRICULUM_ACCURACY_STANDARD.md) before this stage.

## Accurate model

- **Entity**: identity within an ECS world, often an integer or opaque handle.
- **Component**: data associated with an entity according to that ECS library’s rules.
- **System**: code that selects entities/components and performs work.
- **Query**: a way to select entities by component presence or other indexed criteria.

“Components contain no behavior” is a common data-oriented convention, not a universal ECS law. Follow the selected library’s contract. Plain data is especially helpful for inspection, replication, and snapshots.

## When ECS is a good candidate

Consider ECS when several of these are true:

- many entities share the same operations;
- behavior is determined by combinations of capabilities;
- systems need cross-cutting queries;
- bulk iteration or staged mutation is useful;
- state needs snapshot, replay, or replication tooling;
- adding combinations is harder than adding named classes or modules.

Examples include dense projectile simulation, status effects across many combatants, large NPC crowds, or a replicated simulation with explicit snapshots.

## When not to use it

Start with a ModuleScript, service/controller, or small object when:

- the feature has few instances;
- most behavior is unique rather than batch-oriented;
- Roblox Instances already provide the needed identity and lifecycle;
- the team would spend more time maintaining the ECS boundary than the feature;
- the main work is UI flow, orchestration, or external service calls rather than entity processing.

A game can use ECS for one subsystem and ordinary modules elsewhere.

## Identity and Roblox Instances

A stable application ID is useful when identity must survive Instance replacement, cross a network/storage boundary, or refer to a logical object that has no Instance. It is not mandatory for every Part, GUI, or short-lived adapter.

Choose among:

- the Instance itself for local engine-bound work;
- a string/number ID validated at a boundary;
- an ECS entity handle for world-local identity;
- a wrapper record when the type checker must distinguish ID domains.

Do not promise that an ID is globally stable unless generation, reuse, lifetime, and serialization rules actually make it so.

## Component storage and “data locality”

Tables keyed by entity can make ownership and batch iteration explicit:

```lua
type EntityId = number
type Health = { current: number, maximum: number }

local healthByEntity: { [EntityId]: Health } = {}
```

This can reduce object indirection and make queries or snapshots easier. However, Luau manages table layout and memory internally. A script cannot assume that separate tables are contiguous arrays or that a structure-of-arrays design produces a particular CPU-cache result.

The useful claim is narrower:

> Data-oriented organization can reduce work and allocations when it enables tighter iteration, smaller records, better indexing, or batching. Verify the effect with the MicroProfiler and representative cardinality.

Algorithm choice usually matters before table-layout theory. Avoiding repeated scans, temporary allocation, serialization, or per-frame work often produces a clearer win.

## Systems, phases, and determinism

Declared phases can make ordering reviewable:

```text
collect commands -> validate -> simulate -> commit -> replicate/present
```

An ordered scheduler does not by itself make a simulation deterministic. Results can still vary because of physics, floating-point behavior, unordered traversal, task timing, external APIs, or random input.

Use a fixed step only when the mechanic benefits from stable simulation intervals, prediction, replay, or bounded numerical behavior. UI, ordinary interactions, and most event-driven services do not need a fixed-tick ECS loop.

## Mutation

Direct component mutation can be adequate when one system clearly owns the write. Staged commands or deferred mutation are useful when:

- query iteration would be invalidated;
- several producers submit changes to one authority;
- validation must precede commit;
- rollback or audit history needs an explicit command;
- operation ordering must be testable.

Do not build a command pipeline for every field assignment.

## Queries and discovery

An ECS query selects world data. Roblox discovery selects Instances. They are related but not identical.

- `CollectionService:GetTagged()` plus added/removed signals is useful for dynamic tagged discovery.
- A bounded `GetChildren()` or even `GetDescendants()` during a controlled bootstrap can be reasonable for a known container.
- Repeated whole-Workspace scans in gameplay hot paths are usually expensive and streaming-fragile.

After discovery, either keep an owned Instance registry or map the Instance to an entity when the ECS use case justifies it. Handle removal, destruction, and streaming explicitly.

## Update connections

One RunService connection per object can be wasteful at scale, but one giant loop can also become a god scheduler. The relevant questions are work, cardinality, ownership, and cancellation.

Reasonable options include:

- event-driven logic with no frame loop;
- a domain scheduler that batches similar work;
- a small number of phase connections;
- per-object connections for a small, independently owned set.

Measure before converting architecture solely to reduce connection count.

## Roblox integration

Instances are not merely presentation: they can be physics objects, characters, prompts, containers, and replicated engine state. An adapter is useful when it isolates streaming/lifetime behavior, engine calls, test doubles, or authoritative validation. It is unnecessary ceremony when a small module can safely own the Instance directly.

Attributes can be useful replicated scalar data. In Roblox’s current server-authority prediction model, documented attributes on predicted instances can participate in core synchronized simulation. Outside that model, decide who writes each attribute and do not assume a client-written value is trusted.

## Practice project

Implement the same bounded scenario twice:

1. a service/controller or functional version;
2. a small ECS version.

Use 1,000 synthetic moving records and a smaller realistic set of Models. Compare:

- code needed to add a new capability combination;
- allocations and frame time under identical work;
- cleanup after repeated spawn/despawn;
- ease of inspecting one entity;
- cost of mapping Instances to records;
- test complexity.

The goal is to explain which version fits, not to make ECS win.

## Completion evidence

You understand this stage when you can:

- describe ECS without claiming it is universally superior;
- identify a workload where queries/batching help and one where they do not;
- distinguish data organization from proven hardware-level locality;
- define entity and Instance lifetimes;
- show a comparable measurement or explain why performance is not the deciding factor;
- choose mutation and scheduling rules proportional to the feature.

## Primary references

- [Luau performance](https://luau.org/performance/)
- [Roblox performance optimization](https://create.roblox.com/docs/performance-optimization)
- [CollectionService API](https://create.roblox.com/docs/reference/engine/classes/CollectionService)
- [Roblox client-server runtime](https://create.roblox.com/docs/projects/client-server)
- [Roblox server-authority model](https://create.roblox.com/docs/projects/server-authority)

ECS terminology varies by library. Consult the chosen library’s documentation before assuming archetype, query-cache, mutation, or entity-reuse semantics.
