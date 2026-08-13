# Roblox/Luau Engineering Evidence Rubric

This rubric evaluates engineering evidence, not line count, architecture vocabulary, or the number of advanced techniques used. A small correct system can demonstrate stronger judgment than a large overengineered one.

Use it with the [curriculum](ROBLOX_LUAU_MASTERY_CURRICULUM.md), [accuracy standard](CURRICULUM_ACCURACY_STANDARD.md), and project audit standard.

## Rating levels

| Level | Evidence |
| --- | --- |
| Developing | Can implement the happy path but needs help identifying boundaries, failures, or verification. Claims may rely on intuition or a small Studio run. |
| Competent | Implements a bounded feature correctly, follows its authority/lifecycle contracts, handles expected failures, and runs relevant repeatable checks. |
| Advanced | Designs or improves multi-module/domain systems, makes explicit tradeoffs, handles hostile/failure/scale cases proportionally, and produces strong static plus runtime evidence. |
| Expert | Repeatedly makes high-quality simplification and architecture decisions across different systems, discovers non-obvious failure modes, builds maintainable proof/tooling, and ships/revises safely under real constraints. |

## Dimensions

### 1. Correctness and contracts

- Developing: happy-path behavior; implicit types/contracts.
- Competent: clear inputs/outputs/state, expected failure handling, relevant types and runtime checks.
- Advanced: traces producer-to-consumer contracts, concurrency, compatibility, and recovery.
- Expert: identifies incorrect premises, narrows guarantees precisely, and creates proof that catches regressions without overclaiming.

### 2. Authority and security

- Developing: trusts client or engine-triggered input too readily.
- Competent: server validates shared/competitive/durable outcomes and bounds abuse.
- Advanced: designs protocol/physics/information boundaries and separates hard invalidity from heuristics.
- Expert: balances exploit resistance, latency, accessibility, false positives, privacy, and operational response with evidence.

### 3. Ownership and lifecycle

- Developing: cleanup is incidental.
- Competent: long-lived resources have owners and normal/error cleanup.
- Advanced: handles cancellation, stale completion, respawn/stream/leave/shutdown, repeated cycles, and bounded retention.
- Expert: simplifies ownership models, proves return-to-baseline behavior, and diagnoses real retention chains.

### 4. Design judgment

- Developing: copies patterns because they appear advanced.
- Competent: uses straightforward modules/services/objects appropriate to a feature.
- Advanced: chooses among direct code, objects, ECS, registries, rules, custom networking, and parallelism based on actual variation/workload.
- Expert: removes unnecessary abstraction, evolves boundaries from evidence, and can explain why a fashionable technique is the wrong choice.

### 5. Performance and scale

- Developing: optimizes by intuition or microbenchmarks unrelated to production.
- Competent: avoids obvious unbounded work and measures representative paths.
- Advanced: defines budgets, profiles end-to-end workload, and includes allocations/network/retention/fan-out.
- Expert: predicts and isolates bottlenecks, designs comparable experiments, and ships the simplest measured correction.

### 6. Verification and operations

- Developing: “works in Studio” is the conclusion.
- Competent: runs type/build/unit/runtime checks relevant to the change and states limitations.
- Advanced: adds hostile/failure/lifecycle/scale fixtures and separates fake-provider from live proof.
- Expert: designs release/migration/observability/rollback evidence, monitors real outcomes, and corrects mistaken assumptions transparently.

### 7. Workload and impact

Workload is evaluated by independently verifiable complexity and responsibility, not non-blank lines.

- Developing: small local task with limited integration responsibility.
- Competent: owns a complete bounded feature or difficult correction.
- Advanced: owns cross-module/domain behavior with security, lifecycle, migration, or scale consequences.
- Expert: repeatedly delivers or repairs high-impact systems, improves team capability, and leaves durable evidence/tooling/documentation.

Generated code, copied modules, comments, and boilerplate do not increase a rating. Deleting thousands of unnecessary lines may be expert evidence.

## Portfolio assessment

Do not assign “expert” from one code sample or one large repository. Require multiple artifacts showing:

- at least two different problem domains;
- one production or production-like lifecycle;
- one diagnosis/correction where the initial premise was wrong;
- security/authority evidence where relevant;
- failure/recovery and repeated lifecycle checks;
- measured performance/scale work where relevant;
- clear limitations and checks not run.

No artifact must use ECS, OOP, DI, rollback, buffers, Actors, a rules engine, or code generation. The expert signal is correct selection and execution.

## Review output

For each dimension report:

```text
Rating:
Evidence:
Counter-evidence or missing proof:
Highest-risk gap:
Smallest next exercise:
```

Separate static/source evidence from Studio runtime, multi-client, live-provider, visual, performance, and production evidence.

## Anti-gaming rules

- No line-count thresholds.
- No score for naming patterns without using them correctly.
- No score for framework size without consumers and verification.
- No automatic penalty for direct code or conditionals when the set is small/closed.
- No expert claim from unverified generated output.
- No security claim from client code alone.
- No performance claim without a representative measurement.
