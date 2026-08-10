# Stage 11: Persistence, Economy Integrity, and Transaction Ledgers

Persistence is not just saving tables. Economy integrity is not just checking prices. In Roblox, persistent state is long-lived, player-facing, exploitable, failure-prone, and expensive to repair after corruption. Treat inventory, currency, ownership, unlocks, rewards, attachments, vehicles, progression, and purchases as authoritative ledgers.

Core policy:

> Persistent gameplay state must change through validated, idempotent, auditable server transactions. Never mutate durable economy or inventory state casually.

## 1. Profile Ownership

Profile ownership means one server session owns the right to read/write a player's durable state.

Apply it with:

- profile session locks
- load states
- release on leave
- timeout recovery
- reconnect handling
- save shutdown handling

Used for:

- inventory
- money
- weapon ownership
- attachments
- vehicles
- progression
- job rewards

Practice:

Design a `PlayerProfileSession` state machine: `Unloaded`, `Loading`, `Loaded`, `Saving`, `Released`, `Failed`.

Mastery rule:

No system may mutate durable player state before the profile is loaded and owned.

## 2. Data Schemas

Persistent data needs explicit schemas and versions.

Apply schemas for:

- profile metadata
- wallet balances
- inventory items
- weapon ownership
- attachments
- vehicles
- progression
- settings
- audit records

Used for:

- migrations
- validation
- debugging
- rollback recovery
- safe feature rollout

Practice:

Create a typed profile schema with a `schemaVersion`, `wallet`, `inventory`, `weapons`, `vehicles`, and `transactionLedger`.

Mastery rule:

If it is saved, it has a versioned schema.

## 3. Migrations

Migrations transform old data into current shape.

Apply migrations as ordered, idempotent functions:

```text
v1 -> v2
v2 -> v3
v3 -> v4
```

Used for:

- adding currencies
- renaming weapon ids
- changing attachment formats
- splitting inventory records
- adding audit ledgers

Practice:

Write a migration that converts `OwnedGuns = {"Rifle"}` into `Weapons = {Rifle = {owned = true, attachments = {}}}`.

Mastery rule:

Migrations must be repeat-safe and tested against real old shapes.

## 4. Transaction Boundaries

Transactions define a complete state change.

Apply this flow:

```text
validate request -> validate profile -> validate cost -> reserve/debit -> mutate -> emit ledger event -> commit -> replicate result
```

Used for:

- purchases
- rewards
- trading
- crafting
- ammo purchases
- weapon unlocks
- attachment installs
- vehicle ownership

Practice:

Build a `PurchaseWeaponTransaction` that debits currency and grants ownership atomically.

Mastery rule:

Currency and items change together or not at all.

## 5. Idempotency

Idempotency means repeated requests do not duplicate outcomes.

Apply transaction ids:

- purchase id
- reward id
- trade id
- grant id
- migration id
- receipt id

Used for:

- duplicate remotes
- retries
- DataStore uncertainty
- server crashes
- purchase receipts
- reward claims

Practice:

Send the same purchase request three times with the same transaction id. The player should be charged once and receive one weapon.

Mastery rule:

Every durable grant or debit needs a duplicate policy.

## 6. Ledgers and Audit Events

Ledgers record why durable state changed.

Apply ledger records:

- transaction id
- player id
- action
- before/after summary
- amount
- item id
- source system
- timestamp/tick
- result
- reason

Used for:

- economy debugging
- exploit investigation
- refund tooling
- rollback recovery
- analytics
- support review

Practice:

Record a ledger entry for every currency change, item grant, weapon purchase, and reward claim.

Mastery rule:

If value changed, there should be evidence explaining why.

## 7. Write Budgets and Queues

DataStore writes are limited and can fail.

Apply:

- coalesced saves
- save queues
- dirty flags
- retry policy
- shutdown flush
- budget-aware scheduling
- critical save priority

Used for:

- profiles
- inventories
- settings
- match rewards
- economy state
- long sessions

Practice:

Create a save scheduler that coalesces profile writes and exposes queue length, last save time, retry count, and failure reason.

Mastery rule:

Persistence must be scheduled, not spammed.

## 8. Conflict Handling

Conflicts happen when data is stale, duplicated, or concurrently modified.

Apply conflict policies:

- reject stale transaction
- replay ledger
- merge safe fields
- prefer server-owned session
- require manual review
- restore from backup

Used for:

- reconnects
- server crashes
- trades
- cross-server grants
- receipt processing
- inventory corrections

Practice:

Simulate a stale purchase against an old profile version. Reject it or replay it through the ledger safely.

Mastery rule:

Never guess on durable conflicts. Use a named policy.

## 9. Secure Reward Claims

Rewards are high-value exploit targets.

Validate:

- profile loaded
- source system
- completion proof
- reward eligibility
- duplicate claim
- cooldown/window
- amount bounds
- inventory capacity
- transaction id

Used for:

- job rewards
- heist payouts
- mission rewards
- combat rewards
- daily rewards
- quest completion

Practice:

Make a `RewardClaimed` transaction that can only be called by the authoritative session service, not directly by a client remote.

Mastery rule:

Clients request actions. Server systems grant rewards.

## 10. Recovery and Repair Tooling

Persistence systems need recovery tools.

Apply tooling for:

- profile dump
- ledger lookup
- transaction replay
- rollback to checkpoint
- manual grant/revoke
- corruption detector
- migration dry-run
- economy audit

Used for:

- support
- exploit cleanup
- production incidents
- migration safety
- QA

Practice:

Build a dry-run migration command that reports what would change without writing.

Mastery rule:

If you cannot repair durable state, you are not ready to mutate it at scale.

## Compatibility With ECS

ECS runtime state and persistent state are not the same.

Policy:

> ECS owns live simulation. Persistence owns durable records. Synchronize through typed transactions, not table copying.

## Compatibility With OOP

OOP owns profile services, transaction services, save queues, and repair tools.

Policy:

> Durable mutation happens through narrow service APIs, never direct table edits from feature code.

## Compatibility With Scheduling

Persistence depends on time, retries, queues, and shutdown windows.

Policy:

> Save work must be scheduled, budget-aware, observable, and cancellable only where safe.

## Compatibility With Runtime Contracts

Persistence boundaries require runtime admission.

Validate:

- loaded profile state
- transaction shape
- schema version
- migration input
- reward eligibility
- item ids
- amount bounds

Policy:

> No unvalidated dynamic data enters durable state.

## Compatibility With Typed Luau

Typed Luau defines durable data and transactions.

Use types for:

- profile schema
- inventory records
- wallet records
- transaction requests
- transaction results
- ledger entries
- migration functions
- save states

Policy:

> If it is saved or affects saved state, type it.

## Compatibility With Networking

Clients should not send durable mutations directly.

Policy:

> Network messages request intent. Server transaction services mutate persistence.

## Compatibility With Rollback and Temporal Architecture

Economy rollback is not combat rollback. Durable state needs ledger-based recovery.

Policy:

> Use ledgers and compensating transactions for durable recovery, not blind snapshot rewinds.

## Compatibility With Anti-Cheat

Economy anti-cheat is transaction validation.

Policy:

> Every currency, inventory, reward, weapon, attachment, and vehicle mutation must prove its source and eligibility.

## Compatibility With Observability

Persistence must be auditable.

Policy:

> Every durable mutation should be explainable by transaction id, source system, validation result, and ledger record.

## Compatibility With Domain Platforms

Domain platforms should call shared transaction services.

Policy:

> Weapons, prompts, jobs, vehicles, shops, and missions do not each invent persistence. They submit typed transactions to the durable-state platform.

## For Gunkits

Apply to:

- weapon ownership
- attachment ownership
- ammo purchases
- skin unlocks
- rank unlocks
- combat rewards
- loadout saves

Required platform pieces:

```text
WeaponOwnershipRecord
AttachmentRecord
LoadoutRecord
PurchaseWeaponTransaction
InstallAttachmentTransaction
CombatRewardTransaction
WeaponLedger
LoadoutMigration
```

Policy:

Gunkit runtime state may change quickly. Gunkit ownership state changes through durable transactions only.

## For Prompt Systems

Apply to:

- shop purchases
- job completion rewards
- mission rewards
- crafting results
- loot crates
- vehicle purchase prompts

Policy:

Prompt completion may trigger a transaction. The prompt itself does not directly mutate durable state.

## For Vehicles

Apply to:

- vehicle ownership
- upgrades
- repair costs
- impound fees
- fuel purchases
- garage loadouts

Policy:

Vehicle ownership and upgrades are durable economy records, not vehicle controller state.

## The Indefinite Framework

Your long-term Roblox framework should include:

```text
ProfileServiceAdapter
ProfileSession
SchemaVersion
MigrationRunner
TransactionService
LedgerService
WalletService
InventoryService
OwnershipService
SaveScheduler
ConflictPolicy
RecoveryTooling
EconomyAuditService
```

## How To Master It

Practice in this order:

1. Define a typed profile schema.
2. Add schema versioning.
3. Add profile session states.
4. Add a transaction result type.
5. Build one idempotent purchase transaction.
6. Add ledger records.
7. Add duplicate request handling.
8. Add save queue scheduling.
9. Add migration dry-run tests.
10. Add conflict policy tests.
11. Add reward eligibility validation.
12. Add audit dump tooling.
13. Add repair/replay tooling.
14. Convert one prompt reward into a transaction.
15. Convert one gunkit ownership change into a ledger-backed transaction.

## Permanent Policy

Use this rule for every future Roblox system:

> If a state change survives server shutdown, it must be typed, validated, transactional, idempotent, and auditable.
