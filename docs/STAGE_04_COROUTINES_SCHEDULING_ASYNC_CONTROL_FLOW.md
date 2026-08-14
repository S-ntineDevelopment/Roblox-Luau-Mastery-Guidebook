# Stage 4: Coroutines, Scheduling, and Async Control Flow

**Difficulty:** Foundation
**Suggested prerequisites:** Stages 1-3

## Guided lesson: cancel a countdown

**Use case:** A countdown must stop changing state after its round is cancelled.

**Complete code:** [STAGE_04_ASYNC_OWNERSHIP.luau](lessons/STAGE_04_ASYNC_OWNERSHIP.luau)

1. Read the `Operation` record; it is the owner-visible cancellation state.
2. Notice that `runCountdown()` checks cancellation before each callback.
3. The callback cancels at `2`, so the loop never visits `1`.

- **Expected result:** the visited values are exactly `3, 2`.
- **Try it:** cancel before starting and prove no callback runs.
- **Common mistake:** cancelling a task handle but allowing an already-started callback to mutate replacement state.

Roblox code frequently waits for events, frames, network replies, and cloud services. The goal of this stage is to make those waits understandable and bounded—not to replace the engine scheduler with a custom framework.

Read [Curriculum Accuracy Standard](CURRICULUM_ACCURACY_STANDARD.md) before this stage.

## Execution model

Luau coroutines are cooperatively scheduled: running code continues until it returns, yields, errors, or enters a parallel scheduling boundary. Roblox’s `task` library schedules threads through the engine.

Know the semantic differences before choosing an API:

- `coroutine.create` creates a suspended thread.
- `coroutine.resume` returns a success boolean followed by yielded/returned values or an error value.
- `coroutine.close` closes a suspended or dead coroutine; it is not a universal structured-cancellation mechanism.
- `task.spawn` schedules work promptly.
- `task.defer` schedules work for a later resumption point.
- `task.delay` schedules work after an approximate delay.
- `task.wait` yields for at least approximately the requested duration and returns elapsed time; it is not a precise timer.

Scheduling details can change. Do not depend on undocumented ordering between unrelated callbacks.

## Ownership and cancellation

An async operation needs explicit ownership when its completion could outlive the player, character, UI route, match, or object that started it.

Cancellation may be:

- **cooperative**: a token/flag is checked before each effect;
- **subscription-based**: disconnect the event or remove the queued job;
- **thread cancellation**: cancel/close a known scheduled thread where the API permits it;
- **stale-result rejection**: compare an operation/session generation before committing.

Stopping a thread is not enough if it already created Instances, subscribed to events, or partially mutated state. Define cleanup and commit rules separately.

## Events versus polling

Use an event when the producer already knows when state changes. Polling can still be reasonable when:

- no event exists;
- observations are intentionally sampled;
- the polling rate is low and bounded;
- several values need one periodic reconciliation pass.

Never assume `RBXScriptSignal:Wait()` will resume. If abandonment matters, race the event against a timeout or cancellation signal. Also note that destroying an Instance disconnects its non-deferred connections, but a waiter or other captured state may still need an explicit owner strategy.

## Debounce, throttle, cooldown, timeout, and backpressure

These solve different problems:

- **debounce**: combine or delay repeated triggers until activity settles;
- **throttle/rate limit**: bound how often work is admitted;
- **cooldown**: represent game/action readiness;
- **timeout**: stop waiting or reject a result after a deadline;
- **backpressure**: reject, merge, drop, or slow producers when a consumer is saturated.

A boolean “debounce” is not a replacement for server rate limiting. A timeout also does not necessarily cancel the underlying operation; document whether it does.

## RunService and simulation time

Choose a RunService phase based on what the work affects. Rendering and camera presentation belong on the client’s render path. Physics-facing work should respect documented pre/post simulation phases. Ordinary event-driven logic may need no frame callback.

A fixed-step accumulator can make application update intervals stable:

```lua
local accumulator = 0
local step = 1 / 30
local maxSteps = 4

local function update(deltaTime: number)
	accumulator = math.min(accumulator + deltaTime, step * maxSteps)
	local count = 0
	while accumulator >= step and count < maxSteps do
		simulate(step)
		accumulator -= step
		count += 1
	end
end
```

The cap avoids an unbounded catch-up spiral but means the simulation may discard time or slow under overload. Choose and document that policy. Fixed steps do not guarantee deterministic physics or cross-device equality.

## Custom schedulers

A custom scheduler is justified when the project needs one or more of:

- named phase ordering;
- bounded queues and per-frame budgets;
- centralized cancellation/inspection;
- fake-clock execution in tests;
- fair scheduling across many similar jobs;
- deterministic stepping for a bounded pure-data simulation.

It is not justified merely to wrap `task.spawn`. Scheduler bugs affect every consumer, so keep semantics small and test reentrancy, overload, cancellation, and destroy-during-callback behavior.

## Promise-style libraries

Promises are not built into Luau. A Promise library can clarify multi-step async composition, but only if the team understands that library’s handling of cancellation, unhandled rejection, scheduling, and cleanup. Do not assume JavaScript Promise semantics or that cancelling a Promise reverses already-started Roblox work.

Plain callbacks, events, coroutines, or typed operation handles may be simpler for short flows.

## Concurrency hazards

Review async code for:

- state read before a yield and used after it without revalidation;
- two overlapping requests committing twice;
- callbacks firing after destroy or player removal;
- unbounded retries or `task.spawn` fan-out;
- errors lost because return values from `coroutine.resume` were ignored;
- locks or mutation-critical state held across a yield;
- one slow handler blocking unrelated serial work;
- time measured with the wrong clock.

## Practice project

Build a cancellable interaction session with a fake clock:

- start, complete, cancel, timeout, and destroy paths;
- one event-driven completion condition;
- a bounded request queue;
- stale completion rejection after a new session starts;
- tests for simultaneous completion/cancel and destroy during a callback.

Then implement a direct version without a custom scheduler. Keep the scheduler only if its extra behavior is actually used.

## Completion evidence

You understand this stage when you can explain:

- which operations yield and what can change while suspended;
- what cancellation does and does not undo;
- why a fixed step is not a determinism guarantee;
- how overload is bounded;
- when an event, polling loop, queue, or custom scheduler is the simplest fit;
- how every long-lived operation becomes unable to commit after its owner ends.

## Primary references

- [Luau coroutine library](https://luau.org/library/#coroutine-library)
- [Roblox task library](https://create.roblox.com/docs/reference/engine/libraries/task)
- [Roblox events](https://create.roblox.com/docs/scripting/events)
- [RunService API](https://create.roblox.com/docs/reference/engine/classes/RunService)
- [Roblox performance guidance](https://create.roblox.com/docs/performance-optimization/improve)
