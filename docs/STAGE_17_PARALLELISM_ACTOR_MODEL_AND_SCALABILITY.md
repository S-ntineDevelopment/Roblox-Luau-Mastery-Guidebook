# Stage 17: Parallelism, Actor Model, Bulk Movement, and Scalability

Large Roblox systems need scalable execution. Parallelism, batching, BulkMoveTo, query batching, and workload partitioning are powerful only when state ownership is clear.

Core policy:

> Parallel work must not share mutable gameplay state casually. Use ownership boundaries, messages, snapshots, batches, and deterministic merge points.

## Computer Science Fundamentals

- Actor model: isolated workers communicate through messages.
- Data parallelism: the same operation runs across many independent inputs.
- Task batching: combine many small operations into one larger operation.
- Immutability: workers consume snapshots instead of live mutable state.
- Synchronization: results merge at explicit safe points.
- Amdahl's law: parallelism only helps the portion that can actually run in parallel.
- Spatial partitioning: divide large worlds by region/cell/interest.

## Roblox API Grounding

- Actors are containers that can run scripts in parallel when paired with `task.desynchronize()`.
- Actor messaging supports asynchronous communication between actors.
- ModuleScripts required by Actors are not shared/cached with the main thread in the same way; design shared state accordingly.
- `WorldRoot:BulkMoveTo(partList, cframeList, eventMode)` moves many parts in one call and is useful for batched visual/presentation movement.
- PathfindingService should be queued and budgeted; `CreatePath()` plus path computation should not be spammed per NPC per frame.
- RunService phases should be wrapped by scheduler utilities instead of scattered frame callbacks.

## Performance Impact

- BulkMoveTo can reduce overhead when many anchored or presentation parts need coordinated movement.
- Bulk movement is not a replacement for server-authoritative simulation; it is a batch application mechanism.
- Parallel workers have serialization/message costs; do not parallelize tiny tasks.
- Pathfinding overload can dominate server time; queue, cache, throttle, and prioritize.
- Immutable snapshots reduce race risk but cost memory; store only needed fields.
- Merge phases should validate worker outputs before mutating authoritative state.

## Mastery Topics

1. Roblox Actor boundaries.
2. Parallel Luau constraints.
3. Message-passing architecture.
4. Immutable snapshot inputs.
5. Worker-safe computation.
6. Deterministic merge phases.
7. AI/pathfinding workload partitioning.
8. Combat query batching.
9. Serialization cost awareness.
10. Parallel debug and profiling tools.
11. BulkMoveTo visual batching.
12. Spatial partitioning and cell ownership.
13. Interest-set computation off the hot path.
14. Worker result validation.
15. Budgeted pathfinding queues.

## Extreme Usage Cases

- Batch NPC perception queries across workers.
- Precompute visibility candidates from immutable snapshots.
- Use BulkMoveTo to move hundreds of client-side/presentation parts in one batched call.
- Partition large NPC worlds by region.
- Run procedural placement scoring in worker-safe batches.
- Batch raycast candidate generation, then validate authoritative hits in serial.

## BulkMoveTo Policy

Use BulkMoveTo for batched movement where the engine boundary cost matters:

- minimap markers
- client-only projectile/tracer visuals
- debug ghosts
- large groups of anchored props
- procedural preview pieces
- NPC presentation rigs where simulation state is elsewhere

Do not use BulkMoveTo to bypass authoritative movement, collision, damage, ownership, or validation rules.

## Practice Project

Build an NPC perception batcher:

```text
Server ECS snapshot
  -> partition targets by region
  -> worker computes visible candidates
  -> serial merge validates results
  -> AI blackboards update
  -> client presentation uses BulkMoveTo for debug markers
```

Acceptance standard:

The authoritative state mutates only during the merge phase, and debug/performance reports show batch size, worker time, merge time, and rejected outputs.

## Permanent Rule

Parallelism is for isolated computation, not escaping architecture.

## References

- Roblox Creator Hub: Actor.
- Roblox Creator Hub: Parallel Luau.
- Roblox Creator Hub: task.desynchronize/task.synchronize.
- Roblox Creator Hub: WorldRoot and BulkMoveTo.
- Roblox Creator Hub: PathfindingService and Pathfinding.
