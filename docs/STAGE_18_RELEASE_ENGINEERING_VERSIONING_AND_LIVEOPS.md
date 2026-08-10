# Stage 18: Release Engineering, Versioning, and LiveOps

Mastery includes shipping safely. Systems must evolve while players, data, protocols, and servers are live.

Core policy:

> Every platform needs versioning, rollout, rollback, observability, migration, and removal plans.

## Computer Science Fundamentals

- Semantic versioning: communicate compatibility expectations.
- Backward compatibility: old clients/data can still operate during migration windows.
- Feature flags: runtime behavior switches with ownership and cleanup.
- Canary releases: expose risky changes to a small population first.
- Rollback engineering: return to a known-safe state quickly.
- Incident response: identify, mitigate, repair, and learn.
- Change management: every risky change has scope, owner, and verification.

## Roblox API Grounding

- DataStoreService supports persistent state and exposes request budgets; writes can fail and must be handled with `pcall`.
- DataStore `UpdateAsync` callbacks must not yield, so transaction design must prepare data before callback execution.
- MemoryStoreService is ephemeral, high-throughput, and TTL-based; use it for cross-server queues/caches, not durable truth.
- Remote protocol versioning matters because live servers/clients may not transition simultaneously.
- Creator Hub Data Stores Manager and observability tools should be part of release/debug workflow where available.

## Performance Impact

- Feature flags add branches; resolve them outside hot loops where possible.
- Protocol compatibility can increase handler complexity; remove old versions after the compatibility window.
- Migrations can be expensive; dry-run, batch, budget, and observe them.
- Rollout telemetry must be lightweight and sampled where high-frequency systems are involved.
- Rollback switches must avoid expensive cleanup work in critical paths.

## Mastery Topics

1. Semantic versioning for engine packages.
2. Protocol versioning.
3. Data migration rollout.
4. Feature flags and kill switches.
5. Canary releases.
6. Compatibility windows.
7. Rollback plans.
8. Deprecation policy.
9. Live incident playbooks.
10. Post-release audits.
11. DataStore budget-aware migration.
12. MemoryStore-backed rollout coordination.
13. Protocol dual-read/dual-write phases.
14. Automated health gates.
15. Removal audits for stale flags and adapters.

## Extreme Usage Cases

- Roll out a new gunkit hit validator to 5% of servers.
- Support old and new network schema versions during migration.
- Disable a broken vehicle system without taking down the whole game.
- Run a dry-run profile migration before enabling writes.
- Keep old weapon configs readable while new configs write to a ledger-backed model.
- Canary an anti-cheat strictness increase and compare rejection/false-positive metrics.

## Best Case Scenario

Every serious platform has:

```text
version
feature flag
migration path
health metrics
rollback switch
compatibility policy
deprecation date
```

## Practice Project

Design a release plan for `ServerAuthoritativeHitscanV2`:

- feature flag
- protocol version
- old/new validator adapter
- canary rollout
- metrics
- rejection reason comparison
- rollback switch
- deprecation date for v1

Acceptance standard:

The feature can be enabled, observed, compared, rolled back, and later cleaned up.

## Permanent Rule

If a system cannot be rolled out, observed, and rolled back, it is not production-ready.

## References

- Roblox Creator Hub: Data stores and DataStoreService.
- Roblox Creator Hub: Memory stores.
- Roblox Creator Hub: Remote events and callbacks.
- Roblox Creator Hub: Services.
