# Roblox Networking Mastery Ladder

Networking mastery is the ability to choose the smallest correct communication model, validate hostile input, and prove behavior under real latency/scale. It is not measured by how many custom codecs, buffers, remotes, or rollback systems a project contains.

Read [Curriculum Accuracy Standard](CURRICULUM_ACCURACY_STANDARD.md) and [Stage 12](STAGE_12_NETWORKING_REPLICATION_SECURITY.md) first.

## Guided lesson: sequence and rate admission

**Use case:** Admit small ordered client messages while rejecting replay and excess requests.

**Downloadable code:** [NETWORKING_LADDER_ADMISSION.luau](lessons/NETWORKING_LADDER_ADMISSION.luau)

### Run this before reading the theory

- **Luau CLI:** `luau docs/lessons/NETWORKING_LADDER_ADMISSION.luau`
- **Roblox Studio:** paste the code into a temporary `Script` and run the experience. These examples avoid Roblox services so the first behavior is easy to see.
- Read the `Step 1`, `Step 2`, and `Step 3` comments in order.

### Complete working example

The `type` declarations are checker notes. They describe the allowed shape of a value, but they do not perform the behavior. The working behavior is in the functions, table operations, calls, and assertions below.

<!-- BEGIN VERIFIED LESSON: NETWORKING_LADDER_ADMISSION.luau -->
```luau
--!strict

-- Use case: admit ordered client messages under a simple per-player limit.

type Packet = {
	sequence: number,
	payload: string,
}

type PeerState = {
	lastSequence: number,
	requestsThisWindow: number,
}

-- Step 1: check bounded payload and strictly newer sequence.
local function admit(state: PeerState, packet: Packet, maximumRequests: number): boolean
	if #packet.payload > 32 then
		return false
	end
	if packet.sequence <= state.lastSequence then
		return false
	end

	-- Step 2: apply a workload limit before committing sequence state.
	if state.requestsThisWindow >= maximumRequests then
		return false
	end

	state.requestsThisWindow += 1
	state.lastSequence = packet.sequence
	return true
end

-- Step 3: exercise success, replay rejection, and rate rejection.
local state: PeerState = { lastSequence = 0, requestsThisWindow = 0 }
assert(admit(state, { sequence = 1, payload = "jump" }, 2))
assert(not admit(state, { sequence = 1, payload = "replay" }, 2))
assert(admit(state, { sequence = 2, payload = "move" }, 2))
assert(not admit(state, { sequence = 3, payload = "extra" }, 2))

print("Networking lesson passed")
```
<!-- END VERIFIED LESSON: NETWORKING_LADDER_ADMISSION.luau -->

### Walk through the behavior

Read the three points, run the code, and complete **Try it**. Once you can explain the assertions, this stage's beginner pass is done. Everything after this guided lesson is optional reference material for later.

1. `Packet` contains only a sequence and small payload for this lesson.
2. `admit()` checks payload size, newer sequence, and per-window request count before committing state.
3. Assertions show one replay and one over-limit packet being rejected.

- **Expected result:** sequences `1` and `2` pass once; replayed `1` and extra `3` fail.
- **Try it:** reset `requestsThisWindow` to model the next time window.
- **Common mistake:** treating sequence and rate checks as semantic permission to perform the requested gameplay action.

## Level 0: Client-server and replication model

Learn:

- which scripts run on server/client;
- what ReplicatedStorage, ServerStorage, ServerScriptService, PlayerScripts, and PlayerGui imply;
- DataModel/property/physics replication;
- StreamingEnabled and missing/streamed Instances;
- that replicated client code/data can be inspected and changed locally.

Practice: in a multi-client Studio session, change a property on server and client and record exactly where it appears. Repeat with an Attribute and a streamed Workspace object.

Completion evidence: explain why “the client changed it” does not imply the server accepted it, and why a replicated ModuleScript is not secret.

## Level 1: Remote primitives

Know the documented semantics:

| Primitive | Direction | Yield | Delivery/order |
| --- | --- | --- | --- |
| RemoteEvent | either direction, one-way | sender does not wait for reply | standard reliable event semantics; engine buffering/throttling still applies |
| RemoteFunction | either direction, request/reply | invoker yields | failure/disconnect/never-return risks matter |
| UnreliableRemoteEvent | either direction, one-way | no reply wait | may drop and reorder |

Use RemoteFunctions when a bounded synchronous answer is genuinely useful and the caller can tolerate yielding/failure. Frequency alone is not the deciding rule. Avoid critical server-to-client `InvokeClient()` because the client can error, disconnect, or never return.

Current documented UnreliableRemoteEvent payloads over 1,000 bytes are dropped, and client-to-server remote calls have platform throttling. Treat numbers as current platform limits to recheck, not architecture constants.

Practice: implement one request as an event/result pair and a client-to-server RemoteFunction. Test missing handlers, server error, client disconnect, timeout at the application layer, and duplicate requests.

## Level 2: Intent and authority

Classify every value:

- client input/intent;
- server-authoritative shared/durable outcome;
- client-local presentation;
- predicted state awaiting correction;
- cached or replicated view.

The server should validate requests that affect shared, competitive, privileged, or durable outcomes. It need not author camera motion, local menu state, or every cosmetic effect.

Practice: replace a client-reported purchase result or hit result with a client request and server-owned calculation.

## Level 3: Runtime validation and abuse resistance

For each client-triggered path validate the relevant layers:

1. type, shape, depth, count, string/buffer length;
2. finite numeric values and domain ranges;
3. rate and amplification cost;
4. sequence/session freshness if ordering matters;
5. permission, ownership, state, distance, target, and resources;
6. authoritative commit and bounded diagnostics.

Validate ProximityPrompts, ClickDetectors, touches, and network-owned physics consequences too; client-triggerable engine events are not automatically trustworthy.

Practice: fuzz missing/wrong/huge/deep/NaN/infinite/duplicate/stale values and prove that rejection happens before expensive work.

## Level 4: Message contracts

Document only the fields the message needs:

```text
name/direction
payload and validator
authority
rate/burst
ordering/duplicate behavior
reliability
recipients
version if coexistence requires it
diagnostics/privacy
```

Static Luau types describe checked producers. Runtime validators admit dynamic/hostile values.

Practice: create a small message catalog and a test that every registered client-to-server message has a server validator and rate policy.

## Level 5: Engine versus custom replication

Before sending a custom update, ask:

- is the Instance/property already replicated?
- can the receiver derive it?
- does an Attribute fit a small Instance-associated value?
- does streaming already provide spatial relevance?
- is custom owner/team/private filtering required?

Do not stamp Attributes every frame without measurement. Also do not repeat the outdated rule that attributes can never hold authoritative gameplay data: in the current server-authority prediction model, documented attributes on predicted Instances can be synchronized simulation state.

Practice: compare a low-rate value via Attribute, RemoteEvent, and existing property replication. Record semantics and encoded/network cost rather than declaring a winner.

## Level 6: Interest, fan-out, and budgets

Estimate custom message cost as:

```text
recipients x frequency x encoded payload
```

Then include serialization/compression, validation, history, allocation, and fan-out CPU. `FireAllClients()` is correct when all clients need the event; `FireClient()`/selected recipients are better when they do not.

Interest management reduces application disclosure and traffic but cannot hide information already replicated to the client.

Practice: produce per-message counts/bytes/recipients in a representative multi-client session.

## Level 7: Tables, buffers, batching, and quantization

Buffers are fixed-size byte blocks. They are a representation choice, not a mastery requirement.

Use them when measured frequency/volume/CPU/allocation justifies:

- known layout/version;
- zero-based offsets and bounds checks;
- maximum record count;
- numeric range/NaN/infinity policy;
- quantization error budget;
- malformed decode behavior;
- round-trip fixtures.

Roblox encodes and compresses certain remote values, including buffers, so a hand-counted byte layout does not by itself prove on-wire savings. Measure representative transport behavior.

Batching can reduce per-message overhead but increases latency and worst-case payload/processing. Bound batch age and size.

Practice: encode the same representative records as tables and buffers, then compare correctness, encoded/network measurements, CPU, allocations, and debugging cost.

## Level 8: Deltas and snapshots

Deltas need a known base. Define acknowledgement or recovery with periodic full snapshots. A full record may be smaller/safer when most fields change or the record is tiny.

Practice: deliberately drop/reorder an unreliable delta and demonstrate recovery rather than assuming delivery.

## Level 9: Latency presentation

Choose separately among interpolation, extrapolation, prediction, reconciliation, lag compensation, and rollback. See [Stage 18](STAGE_18_PREDICTION_RECONCILIATION_ROLLBACK.md).

ECS is not a prerequisite. Plain records, services, or objects can provide snapshot state. Fixed ticks are not a determinism guarantee.

Practice: compare interpolation-only and prediction/reconciliation for one pure-data movement mechanic under injected delay/jitter/loss.

## Level 10: Physics and server authority

Understand client network ownership of unanchored assemblies and its security impact. Movement validation is mechanic-specific; universal speed thresholds fail around vehicles, teleports, latency, and physics impulses.

Evaluate the current Roblox server-authority model separately. It has documented setup, prediction, simulation callback, and Attribute constraints that older custom-netcode advice does not cover.

Practice: test a network-owned assembly, server-owned alternative, and current server-authority experiment. Measure responsiveness and validate outcomes.

## Level 11: Compatibility and operations

Versioning is needed when incompatible producers/consumers/data can coexist: old live servers, teleport payloads, saved records, queues, external workers, or separately deployed packages.

Use optional fields, explicit versions, dual-read transitions, or session rejection as appropriate. Do not add elaborate migration machinery where deployment makes coexistence impossible.

Track rejection rates, payload sizes, recipient counts, queue/history sizes, and protocol version with bounded cardinality/privacy.

## Common corrections

| Incorrect shortcut | Accurate replacement |
| --- | --- |
| “Use RemoteEvents for gameplay; RemoteFunctions are bad.” | Choose one-way versus bounded request/reply semantics; avoid critical server-to-client invocation. |
| “Buffers are faster/smaller.” | They may be; prove end-to-end cost for representative payloads. |
| “Send only deltas.” | Deltas require a base/recovery and can cost more than small full records. |
| “Advanced networking requires ECS.” | ECS is one state organization; it is not a network prerequisite. |
| “Fixed tick means deterministic.” | It fixes step interval, not all inputs/numerics/physics/order. |
| “The server owns everything.” | The server owns admitted shared/competitive/durable outcomes; clients own local presentation/input and may predict. |
| “Never use Attributes for gameplay.” | Choose by authority/rate/model; current server-authority predicted simulation explicitly supports documented Attribute state. |
| “Sequence numbers make input safe.” | They help order/dedup; semantic validation is still required. |

## Mastery project

Build a small secure interaction plus one latency-sensitive pure-data mechanic. Provide:

- message/authority table;
- runtime validators and rate limits;
- table versus buffer measurement where volume justifies it;
- recipient/frequency/payload budget;
- hostile-input fixtures;
- delay/jitter/loss tests appropriate to transport;
- lifecycle cleanup on leave/respawn/destroy;
- explicit limitations and Studio/live checks not run.

Mastery is demonstrated by rejecting unnecessary complexity as confidently as implementing necessary complexity.

## Primary references

- [Roblox client-server runtime](https://create.roblox.com/docs/projects/client-server)
- [Remote events and callbacks](https://create.roblox.com/docs/scripting/events/remote)
- [RemoteEvent API](https://create.roblox.com/docs/reference/engine/classes/RemoteEvent)
- [UnreliableRemoteEvent API](https://create.roblox.com/docs/reference/engine/classes/UnreliableRemoteEvent)
- [Securing the client-server boundary](https://create.roblox.com/docs/scripting/security/client-server-boundary)
- [Network ownership and movement validation](https://create.roblox.com/docs/scripting/security/network-ownership)
- [Roblox server-authority model](https://create.roblox.com/docs/projects/server-authority)
- [Luau buffer library](https://luau.org/library/#buffer-library)
