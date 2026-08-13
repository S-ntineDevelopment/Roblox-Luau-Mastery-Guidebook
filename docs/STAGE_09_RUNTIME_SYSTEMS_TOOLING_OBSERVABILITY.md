# Stage 9: Runtime Tooling and Observability

Observability is evidence collected to answer operational questions. More logs and dashboards do not automatically make a system observable.

Read [Curriculum Accuracy Standard](CURRICULUM_ACCURACY_STANDARD.md) before this stage.

## Start with a question

Useful instrumentation answers a decision such as:

- why was this request rejected?
- which operation owns this connection or task?
- where is frame/server-step time spent?
- is a queue growing faster than it drains?
- did a purchase grant exactly once?
- which protocol/schema version produced this failure?

If a metric has no owner, threshold, or action, it may be noise.

## Logs, metrics, traces, and profiles

- **Logs** describe discrete events with context.
- **Metrics** aggregate counts, gauges, rates, or distributions.
- **Traces** correlate steps of one operation across boundaries.
- **Profiles** sample or instrument where time/memory is spent.

They are complementary. A log timestamp is not a precise profiler, and an average metric can hide spikes.

## Roblox tools

Use current platform tools for the question:

- Developer Console for logs and runtime summaries;
- Script Performance for broad script activity;
- MicroProfiler for frame/task timing;
- `debug.profilebegin()`/`debug.profileend()` for balanced named regions;
- memory categories and Instance counts where available;
- DataStore/MemoryStore observability and request budgets;
- server/client test sessions and device/network emulation where applicable.

Keep profiler labels bounded. Never leave a profile region open across a yield or error path; use a structure that guarantees balanced end calls.

## Performance method

1. Define the workload and target device/server conditions.
2. Predict the likely cost center.
3. Capture a baseline.
4. Change one meaningful factor.
5. repeat the identical workload;
6. compare frame time distributions, memory, network, and correctness.

Classify evidence as sustained, burst, scaling, retention/leak, or network-related. “It felt smoother in Studio” is not enough.

## Lifecycle inspection

Track resources whose sources outlive their consumers. Do not call every undisconnected connection a leak: Roblox disconnects non-deferred connections when the event Instance is destroyed. A leak claim needs a retention chain, unbounded growth, or a missing lifecycle path.

Useful debug views include:

- active sessions/jobs by owner;
- player/character generation records;
- connection/task counts for long-lived services;
- bounded queue/cache/history sizes;
- repeated create/destroy baseline comparisons.

Instrumentation itself must not retain the objects it is meant to observe.

## Structured diagnostics

Prefer stable fields over interpolated prose when analysis needs grouping:

```text
event=interaction_rejected
reason=out_of_range
playerId=...
promptId=...
operationId=...
schemaVersion=...
```

Do not log secrets, full persistent records, chat/private content, or high-cardinality payloads without a retention/privacy plan. Sample high-frequency success paths; retain stronger evidence for errors and security decisions.

## Feature flags and kill switches

Flags are useful for risky rollout, experiments, or emergency disablement. They are not mandatory for every module.

Each flag should define:

- owner and purpose;
- default and scope;
- evaluation location and fallback;
- telemetry needed for a decision;
- expiry/removal condition.

Avoid nested flag combinations that create untested product states.

## Failure injection and testing

Inject failures only in controlled environments or safely scoped production experiments. Test:

- timeout/throttle/error responses from cloud dependencies;
- duplicate, malformed, reordered, or stale messages;
- owner destruction during every async phase;
- full queues and bounded drop/reject policies;
- repeated respawn/stream/remove cycles;
- old schema versions and corrupt records.

Do not claim to simulate engine packet behavior exactly unless the harness actually uses that transport behavior.

## Health reports

A health endpoint/report should summarize actionable state, not dump every internal table. Include freshness, degraded dependencies, bounded queue depth, last successful operation, and version where relevant. A “green” report cannot replace end-to-end behavior checks.

## Practice project

Instrument one interaction or transaction flow with:

- an operation ID;
- bounded structured rejection logs;
- queue depth and latency distributions;
- one balanced MicroProfiler label;
- repeated lifecycle count checks;
- one injected timeout and one malformed request.

Write down which question each signal answers and its production cost.

## Completion evidence

You understand this stage when you can:

- choose the right evidence type for a question;
- produce comparable before/after profiles;
- identify a real retention chain instead of guessing “leak”;
- bound labels, logs, histories, and metric cardinality;
- test failure without changing production semantics;
- remove instrumentation or flags when their decision is complete.

## Primary references

- [Roblox performance issue identification](https://create.roblox.com/docs/performance-optimization/identify)
- [Roblox MicroProfiler](https://create.roblox.com/docs/performance-optimization/microprofiler)
- [Roblox performance optimization](https://create.roblox.com/docs/performance-optimization)
- [Roblox DataStore limits](https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits)
- [Roblox MemoryStore observability and limits](https://create.roblox.com/docs/cloud-services/memory-stores)
