# Stage 3: Coroutines, Scheduling, and Async Control Flow

Async control flow is one of the biggest hidden sources of Roblox bugs. A project can have good ECS data and good OOP boundaries, but still fail because tasks, events, waits, retries, animations, cooldowns, and network responses are uncontrolled.

This stage is about making time, execution, cancellation, ownership, and cleanup explicit.

Core policy:

> No async work should exist without an owner, a lifecycle, a cancellation path, and a reason to run in its chosen scheduler phase.

## 1. Coroutine Fundamentals

Coroutines let Luau pause and resume execution. Roblox's `task.spawn`, `task.defer`, `task.delay`, and many engine yields sit on top of async scheduling ideas, but they do not automatically give you ownership or cancellation.

Apply it by understanding:

- `coroutine.create`
- `coroutine.resume`
- `coroutine.yield`
- `coroutine.status`
- error propagation
- yielded call stacks
- scheduler timing

Used for:

- controlled background work
- animation sequences
- ability flows
- NPC behavior
- minigames
- prompt sessions
- network waits

Practice:

Create a coroutine that performs a three-step interaction flow:

1. validate
2. wait for a simulated duration
3. complete

Then intentionally error inside step 2 and make sure the owner receives the failure.

Mastery rule:

If an async flow can fail, timeout, or be cancelled, treat it as a managed operation, not a loose spawned thread.

## 2. Task Ownership

Task ownership means every async operation belongs to something: a service, controller, session, entity, player, prompt, weapon, match, or UI screen.

Apply it by giving owners a cleanup container and registering every connection, delayed callback, spawned task, tween, and subscription.

Used for:

- player sessions
- weapon equip state
- reloads
- prompt interactions
- NPC brains
- vehicle controllers
- UI screens
- temporary effects

Practice:

Build a `TaskOwner` object with:

- `spawn`
- `delay`
- `cancelAll`
- `destroy`

Start three tasks, destroy the owner, and prove none of the tasks can mutate state afterward.

Mastery rule:

No fire-and-forget task is allowed to mutate important state.

## 3. Custom Schedulers

A custom scheduler runs jobs in controlled queues instead of scattering logic across unrelated events.

Apply it by building scheduler phases:

```text
PreSimulation
Input
CommandValidation
Simulation
PostSimulation
Replication
Presentation
Cleanup
```

Used for:

- ECS systems
- rollback simulation
- combat ticks
- projectile updates
- vehicle simulation
- prompt/session timeouts
- AI updates
- network flushes

Practice:

Create a scheduler that registers systems by phase and priority. Add three systems with logs and prove they always run in the same order.

Mastery rule:

Important gameplay order must be declared, not accidentally produced by Script startup order.

## 4. Promise-Style Flows

Promise-style flows represent async operations with success, failure, cancellation, and chaining.

Apply it for operations that have a result:

- asset loading
- profile loading
- matchmaking
- server reservation
- confirmation flows
- minigame completion
- remote request/response pairs

Used for:

- avoiding nested callbacks
- timeouts
- cancellation
- combining async operations
- testable async logic

Practice:

Create a simple promise-like wrapper for a prompt interaction:

- resolves on completion
- rejects on validation failure
- cancels on player leaving
- times out after 10 seconds

Mastery rule:

If an async operation has a result, model the result explicitly instead of hiding it in a callback chain.

## 5. Deterministic Stepping

Deterministic stepping means simulation advances in fixed ticks instead of arbitrary wait durations or frame-dependent deltas.

Apply it by running simulation at a fixed rate, such as 30 or 60 ticks per second, while presentation can render separately.

Used for:

- rollback
- prediction
- combat validation
- projectile simulation
- cooldown processing
- vehicle state
- replay testing

Practice:

Build a fixed-tick loop that accumulates `dt` from `RunService.Heartbeat` and runs `simulateTick()` at 30 Hz. Then make rendering interpolate separately.

Mastery rule:

Simulation time and render time are different responsibilities.

## 6. Backpressure

Backpressure prevents systems from creating more work than the server or client can process.

Apply it by limiting queues, coalescing duplicate jobs, dropping obsolete updates, and rate-limiting producers.

Used for:

- RemoteEvent spam
- UI updates
- projectile batches
- pathfinding requests
- datastore saves
- effect spawning
- prompt discovery
- network replication

Practice:

Create a queue that accepts at most 100 pending damage requests. When full, reject low-priority requests and report the overflow.

Mastery rule:

A system that accepts infinite work will eventually fail under load or abuse.

## 7. Debounce, Throttle, and Cooldown

These are different timing policies:

- Debounce: ignore repeated triggers until quiet or complete.
- Throttle: allow at most one operation per interval.
- Cooldown: allow the next operation after a ready time.

Apply the correct policy instead of using a vague `debounce = true` everywhere.

Used for:

- prompt interactions
- gun fire cadence
- reloads
- ability activation
- UI buttons
- datastore saves
- remote messages

Practice:

Implement all three policies and use each correctly:

- debounce a UI confirm button
- throttle debug log spam
- cooldown a weapon fire action

Mastery rule:

Name the timing rule you mean. Do not use one boolean debounce to represent every time-based constraint.

## 8. Cleanup Containers

Cleanup containers own disposable resources.

Apply it with a Maid/Janitor/Trove-style object that can clean:

- RBXScriptConnections
- Instances
- functions
- tasks
- tweens
- nested cleaners

Used for:

- OOP lifecycles
- ECS entity despawn
- player sessions
- UI screens
- weapons
- prompts
- vehicles
- effects

Practice:

Build a `Cleaner` module. Connect three events, create one temporary Part, add one cleanup function, then call `clean` and verify all resources are released.

Mastery rule:

Cleanup is architecture. It is not something to remember manually at the end.

## 9. Async Testing

Async testing means you can prove timing behavior without waiting for real time or hoping the scheduler behaves.

Apply it with fake clocks, controlled ticks, fake signals, and deterministic task flushing.

Used for:

- cooldowns
- timeouts
- reloads
- prompt sessions
- matchmaking
- rollback replay
- retry logic
- delayed cleanup

Practice:

Write a fake clock. Test that a weapon cannot fire before cooldown expires and can fire immediately after advancing the fake clock.

Mastery rule:

If timing matters, test it with controlled time.

## 10. Roblox Scheduler Integration

Roblox has several execution surfaces:

- `RunService.Heartbeat`
- `RunService.Stepped`
- `RunService.PreSimulation`
- `RunService.PostSimulation`
- `RunService.PreRender`
- `task.spawn`
- `task.defer`
- `task.delay`
- yielding APIs
- events

Apply it by assigning each system to the correct phase.

Used for:

- physics-adjacent logic
- visual interpolation
- client input
- server simulation
- network flushing
- UI updates
- cleanup

Practice:

Build a tiny client loop:

- collect input before simulation
- apply prediction on simulation tick
- render camera/recoil on render step
- clean expired effects after presentation

Mastery rule:

Do not put all timing-sensitive work into arbitrary `Heartbeat` callbacks. Choose phases intentionally.

## Compatibility With ECS

Async scheduling is the execution layer for ECS.

ECS provides:

```text
Entities
Components
Systems
Queries
Mutations
Snapshots
```

Scheduling provides:

```text
When systems run
In what order they run
How much work they may do
How ticks are advanced
How cleanup is processed
How rollback replay is controlled
```

The correct relationship:

- ECS systems register into scheduler phases.
- ECS mutations are staged and committed at declared points.
- ECS snapshots happen at fixed tick boundaries.
- ECS cleanup runs through lifecycle-owned cleanup containers.
- ECS queries should not be mutated unpredictably by loose async tasks.

Policy:

> ECS owns the world. The scheduler owns when the world changes.

## Compatibility With OOP

Async control flow depends on OOP lifecycle ownership.

OOP provides:

```text
Services
Controllers
Adapters
Runtime objects
Cleanup containers
Injected dependencies
```

Scheduling provides:

```text
Task ownership
Cancellation
Timeouts
Ordered execution
Backpressure
Fake clocks for tests
```

The correct relationship:

- Services register systems and jobs.
- Controllers own client-side tasks and presentation loops.
- Adapters own Roblox event connections.
- Runtime objects cancel tasks in `destroy`.
- Dependencies include clocks, schedulers, loggers, and network channels.

Policy:

> OOP owns async resources. The scheduler executes them. Cleanup containers retire them.

## For Gunkits

Async mastery is critical for weapons.

Apply it to:

- fire cadence
- reload timing
- burst fire
- charge weapons
- recoil recovery
- spread recovery
- projectile lifetime
- hitmarker display
- equip/unequip cancellation
- server validation windows
- client prediction

Bad design:

```text
task.spawn reload
task.delay cooldown
Heartbeat recoil
RemoteEvent fire
no owner
no cancellation
```

Strong design:

```text
WeaponRuntime owns tasks
CooldownPolicy gates fire
ReloadOperation can cancel on unequip
FireMode schedules shots through weapon scheduler
Server validates sequence and cadence
Client presentation runs separately from authority
```

## For Prompt Systems

Prompt systems need controlled async flow.

Apply it to:

- interaction hold duration
- server validation
- permission checks
- cooldowns
- minigame launch
- timeout
- cancellation on movement/player leaving/object removal
- UI presentation

Strong design:

```text
PromptAdapter captures Roblox trigger
PromptService validates request
InteractionSession owns lifecycle
PromptAction executes through a managed async operation
Cleaner cancels on destroy
Result is replicated through typed message
```

## For Vehicles

Vehicles are timing-sensitive and benefit from scheduler discipline.

Apply it to:

- input sampling
- server authority
- physics ownership checks
- suspension stepping
- replication cadence
- client interpolation
- occupancy cleanup
- despawn
- handoff

Policy:

Vehicle simulation and visual smoothing must not be tangled into one uncontrolled Heartbeat loop.

## The Indefinite Framework

Your long-term Roblox framework should include:

```text
Scheduler
Clock
FixedTickLoop
TaskOwner
Cleaner
Operation
CooldownPolicy
ThrottlePolicy
DebouncePolicy
Queue
BackpressurePolicy
AsyncTestHarness
RunServiceAdapter
```

Each piece has a permanent role:

- `Scheduler` orders systems and jobs.
- `Clock` provides testable time.
- `FixedTickLoop` drives deterministic simulation.
- `TaskOwner` binds async work to lifecycle.
- `Cleaner` releases resources.
- `Operation` represents cancellable async work.
- `CooldownPolicy` gates gameplay actions.
- `ThrottlePolicy` limits repeated work.
- `DebouncePolicy` suppresses duplicate triggers.
- `Queue` stores bounded pending work.
- `BackpressurePolicy` decides reject/drop/coalesce behavior.
- `AsyncTestHarness` proves timing behavior.
- `RunServiceAdapter` isolates Roblox scheduler APIs.

## How To Master It

Practice in this order:

1. Write raw coroutine examples until yield/resume/error behavior is clear.
2. Wrap spawned tasks with an owner.
3. Build a cleanup container.
4. Build cooldown, debounce, and throttle as separate modules.
5. Build a fixed-tick loop.
6. Register ECS systems into scheduler phases.
7. Add staged mutation commit points.
8. Add cancellable operations.
9. Add timeouts.
10. Add backpressure queues.
11. Inject a fake clock.
12. Test cooldowns and timeouts with fake time.
13. Convert a prompt interaction into a managed session.
14. Convert weapon reload/fire cadence into managed operations.
15. Add debug reporting for active tasks, queues, and scheduler timings.

The best first real project is a managed prompt interaction session. Then apply the same model to reloads, burst fire, vehicle occupancy, and minigame timers.

## Permanent Policy

Use this rule for every future Roblox system:

> If behavior happens later, repeats over time, waits for something, can be cancelled, or depends on frame order, it must be scheduler-owned and lifecycle-owned.

The true mastery is combining all three early stages:

- ECS defines what state exists.
- OOP defines who owns behavior and cleanup.
- Scheduling defines when behavior runs and how it stops.

When these three agree, systems become predictable, testable, rollback-ready, and much harder to break through timing bugs.
