# Stage 11: Persistence and Economy Integrity

Persistent state outlives a server process, so failures, retries, old schemas, and concurrent writers are normal design inputs. Roblox DataStores are key-value storage, not a general relational database or multi-key ACID transaction system.

Read [Curriculum Accuracy Standard](CURRICULUM_ACCURACY_STANDARD.md) before this stage.

## Platform facts

- DataStore calls are asynchronous network operations that can fail and should be handled with `pcall` and an explicit policy.
- `SetAsync()` can overwrite another server’s change.
- `UpdateAsync()` reads and conditionally writes one key, may rerun its callback, consumes read and write budget, and its callback cannot yield.
- `GetAsync()` may return cached/stale data in documented circumstances.
- Standard DataStores retain version history for a limited period; OrderedDataStores have different data/feature constraints.
- MemoryStore is cross-server but ephemeral and TTL-limited; it is not durable transaction evidence.

Recheck current limits and budgets before shipping.

## Record ownership

If one live server should mutate a player record, implement a session lease/lock protocol or use a reviewed profile library. This is application behavior, not an automatic DataStore guarantee.

Define:

- lease identity and expiry;
- renewal and loss behavior;
- stale-owner recovery;
- teleport/rejoin overlap;
- what gameplay does when ownership cannot be acquired;
- shutdown and crash expectations.

Never keep accepting durable mutations after the session knows it lost ownership.

## Schema and migration

Each saved record should identify a schema version when shape can evolve. Migrations should be ordered, bounded, and tested from every supported version.

Do not silently replace a corrupt/unknown record with defaults and save over it. Quarantine, alert, or preserve recoverable evidence according to product policy.

Migration code should avoid yielding inside `UpdateAsync()` callbacks. Prepare external information before the callback or redesign the record transition.

## Application transactions

For a change contained in one profile key, an application transaction can validate and return a new record inside one `UpdateAsync()` flow. For changes spanning multiple keys/services, atomic all-or-nothing commit is not provided automatically.

Use one or more of:

- co-locate data that must commit together;
- an idempotent transaction record/state machine;
- reservations and finalization;
- compensating actions;
- reconciliation/repair jobs;
- manual review for high-value exceptions.

Call these application protocols, not guaranteed database atomicity.

## Idempotency

An idempotency key prevents a repeated logical request from applying twice only if the duplicate record and mutation are checked/committed within a sufficiently durable authoritative boundary.

Define:

- key source and uniqueness scope;
- retention length;
- response for duplicate success, duplicate pending, and conflicting reuse;
- storage growth/compaction;
- behavior after partial failure.

An in-memory “seen IDs” table does not protect across server crash or retry.

## Developer products

Use `MarketplaceService.ProcessReceipt` for granting Developer Products. Do not grant from `PromptProductPurchaseFinished`; that event does not prove a successful purchase.

Receipt handling must tolerate repeated delivery. Validate the player/product context, durably record/grant according to an idempotent policy, and return `PurchaseGranted` only when the grant is safely accounted for. Follow the current official receipt documentation rather than copying an old sample blindly.

## Write scheduling and budgets

Queue/coalesce writes when that preserves semantics, but define:

- maximum pending work;
- priority (purchases versus cosmetic settings);
- retryable versus permanent failure;
- exponential backoff/jitter where appropriate;
- shutdown deadline behavior;
- last-known durable version;
- player-facing degraded behavior.

Do not retry every error forever. A retry queue is another bounded persistent-state machine.

## Caches

A cache needs an owner, freshness rule, invalidation strategy, and authoritative backing source. Caching persistent records can introduce stale overwrites if two writers or old snapshots are allowed to save.

MemoryStore may support cross-server coordination/cache use, but values expire and calls can fail/throttle. Never treat it as the only record of a permanent purchase.

## Security and audit

Clients request purchases, rewards, crafting, or inventory changes; the server validates and commits. Audit evidence should be proportional to value and include transaction/receipt ID, source, player, outcome, and rejection/failure reason without exposing private full profiles.

An append-only “ledger” in a mutable profile is not automatically tamper-proof or unboundedly scalable. Define retention, reconciliation, and external support tooling.

## Practice project

Build a fake profile repository and purchase service that simulates:

- duplicate requests and duplicate receipts;
- two writers for one key;
- `UpdateAsync` callback reruns;
- throttle/timeouts;
- server crash between reservation and finalization;
- migration from each old schema;
- loss of session ownership;
- bounded retry queue overflow.

Then run a limited Studio/provider test. Keep fake-provider proof separate from live DataStore proof.

## Completion evidence

You understand this stage when you can:

- state the single-key scope of `UpdateAsync`;
- distinguish durable DataStore state from ephemeral MemoryStore coordination;
- design and lose a session lease safely;
- prove idempotency across retries/crashes for the chosen boundary;
- process Developer Products through `ProcessReceipt`;
- recover or escalate partial multi-service workflows without claiming ACID semantics.

## Primary references

- [Roblox data stores](https://create.roblox.com/docs/cloud-services/data-stores)
- [DataStore errors and limits](https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits)
- [DataStore best practices](https://create.roblox.com/docs/cloud-services/data-stores/best-practices)
- [Roblox memory stores](https://create.roblox.com/docs/cloud-services/memory-stores)
- [Choosing Roblox cloud storage](https://create.roblox.com/docs/cloud-services/data-stores-vs-memory-stores)
- [Roblox Developer Products](https://create.roblox.com/docs/production/monetization/developer-products)
