# Stage 17: Parallel Luau and Scalability

**Difficulty:** Production mastery
**Suggested prerequisites:** Stages 4, 7, and 10

## Guided lesson: partition and merge pure work

**Use case:** Split six numbers into three independent jobs and combine their sums.

**Complete code:** [STAGE_17_PARTITION_AND_MERGE.luau](lessons/STAGE_17_PARTITION_AND_MERGE.luau)

1. `makeJobs()` describes disjoint index ranges; it does not create threads.
2. `sumJob()` performs pure work over one range.
3. The serial owner merges results in a defined order.

- **Expected result:** three two-item jobs merge to total `21`.
- **Try it:** use a chunk size of `4` and prove the total remains `21`.
- **Common mistake:** adding Actors before measuring whether isolated work is large enough to repay communication and synchronization cost.

Parallel execution can reduce elapsed CPU time for suitable workloads. It also adds Actor/VM boundaries, safe-API restrictions, communication cost, and harder debugging. Profile first.

Read [Curriculum Accuracy Standard](CURRICULUM_ACCURACY_STANDARD.md) before this stage.

## Platform model

- Scripts under different Actors can run in parallel.
- Scripts in the same Actor execute sequentially relative to each other.
- Code enters parallel execution with documented mechanisms such as `task.desynchronize()`, parallel signal connections, or parallel Actor message bindings.
- Many Instance/API operations are not safe in parallel; current API thread-safety tags are authoritative.
- `require()` cannot be called after entering a desynchronized parallel phase; load required modules in serial first.
- Each Actor runs its own Luau VM, and ModuleScript state is not shared/cached across Actors like ordinary same-VM requires.
- Actor messages are asynchronous. SharedTables support shared data with specific semantics; individual safe operations do not make an arbitrary multi-step algorithm atomic.

Recheck current documentation because supported APIs and features evolve.

## Suitable work

Candidates often include large independent batches of:

- raycasts or perception calculations using parallel-safe APIs;
- procedural generation computations;
- pure scoring/math;
- data transforms over partitioned input.

Poor candidates include tiny jobs, highly shared mutable state, frequent serial Instance mutation, or workloads dominated by network/cloud yielding.

## Partitioning

Partition by meaningful independent work. Too few Actors may underuse cores; too many can increase scheduling, memory, and maintenance cost. The best count depends on workload and devices, not simply CPU core count.

Do not require ECS for Parallel Luau. Arrays, jobs, service-owned batches, or ECS queries can all provide work units.

## Communication and merge

A serial merge phase is one useful design when workers compute proposals and one owner commits authoritative state. It is not mandatory for every parallel feature; Actor-local ownership or safe isolated updates may fit better.

Whichever model is chosen, define:

- input snapshot/ownership;
- message/shareability constraints;
- stale result rejection;
- failure/timeout behavior;
- output validation;
- authoritative mutation point.

## SharedTables

SharedTables can avoid copies for shared state but introduce shared-memory reasoning. Define who writes each key, whether compound updates need another coordination protocol, and how snapshots/readers observe change. Do not treat them as ordinary tables with free cross-thread mutation.

## Bulk and batched engine work

Batching can help even without parallelism. APIs such as `Workspace:BulkMoveTo()` may reduce overhead for moving many Parts in supported cases, but API behavior, event semantics, and physics requirements must be checked. It is not a replacement for ownership/security validation or a universal way to move characters.

## Amdahl’s law and measurement

Total speedup is limited by serial work plus scheduling/synchronization overhead. Measure:

- serial baseline;
- worker computation;
- message/copy/share cost;
- synchronization/merge;
- memory per Actor/VM;
- worst frame/server-step time on target devices.

Parallel code that moves work off one timeline can still exceed total frame budgets.

## Practice project

Create a representative raycast/scoring batch with:

1. serial implementation;
2. batched serial implementation;
3. Actor-parallel implementation.

Test multiple batch and Actor counts, stale cancellation, one worker failure, and serial commit cost. Keep parallelism only if end-to-end measurements improve without violating semantics.

## Completion evidence

You understand this stage when you can:

- state Actor VM/module isolation accurately;
- use current thread-safety tags;
- explain where `require()` is allowed;
- choose message, snapshot, SharedTable, or Actor-local ownership intentionally;
- include communication/merge/memory in speedup claims;
- reject parallelism for workloads where it loses.

## Primary references

- [Roblox Parallel Luau](https://create.roblox.com/docs/scripting/multithreading)
- [Actor API](https://create.roblox.com/docs/reference/engine/classes/Actor)
- [SharedTable API](https://create.roblox.com/docs/reference/engine/datatypes/SharedTable)
- [Workspace BulkMoveTo API](https://create.roblox.com/docs/reference/engine/classes/WorldRoot#BulkMoveTo)
- [Roblox performance optimization](https://create.roblox.com/docs/performance-optimization)
