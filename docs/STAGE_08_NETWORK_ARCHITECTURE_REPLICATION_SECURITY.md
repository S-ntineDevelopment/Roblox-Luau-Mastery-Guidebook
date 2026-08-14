# Stage 8: Networking, Replication, and Security

**Difficulty:** Intermediate
**Suggested prerequisites:** Stages 2, 4, 6, and 7

## Guided lesson: admit one remote payload

**Use case:** Convert an untrusted fire-request table into a small trusted record before gameplay code uses it.

**Downloadable code:** [STAGE_08_NETWORK_VALIDATION.luau](lessons/STAGE_08_NETWORK_VALIDATION.luau)

### Run this before reading the theory

- **Luau CLI:** `luau docs/lessons/STAGE_08_NETWORK_VALIDATION.luau`
- **Roblox Studio:** paste the code into a temporary `Script` and run the experience. These examples avoid Roblox services so the first behavior is easy to see.
- Read the `Step 1`, `Step 2`, and `Step 3` comments in order.

### Complete working example

The `type` declarations are checker notes. They describe the allowed shape of a value, but they do not perform the behavior. The working behavior is in the functions, table operations, calls, and assertions below.

<!-- BEGIN VERIFIED LESSON: STAGE_08_NETWORK_VALIDATION.luau -->
```luau
--!strict

-- Use case: turn an untrusted fire payload into a small trusted record.

type FireRequest = {
	sequence: number,
	directionX: number,
}

-- Step 1: accept unknown at the trust boundary.
local function decodeFireRequest(value: unknown): FireRequest?
	if type(value) ~= "table" then
		return nil
	end

	local record = value :: { [string]: unknown }
	local sequence = record.sequence
	local directionX = record.directionX

	-- Step 2: validate type, integer/range, and finite numeric values.
	if type(sequence) ~= "number" or sequence % 1 ~= 0 or sequence < 1 then
		return nil
	end
	if type(directionX) ~= "number" or not math.isfinite(directionX) then
		return nil
	end
	if directionX < -1 or directionX > 1 then
		return nil
	end

	-- Return a fresh trusted record, not the caller's table.
	return { sequence = sequence, directionX = directionX }
end

-- Step 3: exercise a valid and malformed payload.
local accepted = decodeFireRequest({ sequence = 1, directionX = 0.5 })
assert(accepted ~= nil and accepted.sequence == 1)
assert(decodeFireRequest({ sequence = 0, directionX = 4 }) == nil)
assert(decodeFireRequest("not a table") == nil)

print("Stage 8 lesson passed")
```
<!-- END VERIFIED LESSON: STAGE_08_NETWORK_VALIDATION.luau -->

### Walk through the behavior

Read the three points, run the code, and complete **Try it**. Once you can explain the assertions, this stage's beginner pass is done. Everything after this guided lesson is optional reference material for later.

1. `decodeFireRequest()` accepts `unknown`, because the boundary has not trusted the payload yet.
2. It validates the sequence and direction type, integer/range, and finite-number requirements.
3. It returns a fresh `FireRequest` rather than passing the caller's mutable table inward.

- **Expected result:** `{ sequence = 1, directionX = 0.5 }` is admitted; malformed values return `nil`.
- **Try it:** add a bounded `weaponId` string.
- **Common mistake:** checking only the static type or table shape while ignoring permissions, rate, ownership, and current server state.

Roblox already replicates the DataModel, physics, and supported properties. Custom remotes supplement that system; they are not automatically the primary representation of all state.

Read [Curriculum Accuracy Standard](CURRICULUM_ACCURACY_STANDARD.md) before this stage.

## Start with the engine model

Before adding a custom message, ask:

- does Roblox already replicate the Instance/property?
- can the receiver derive the value locally?
- is an Attribute or Value object appropriate for low-rate replicated state?
- does streaming affect whether the Instance exists on this client?
- is this intent, authoritative state, or presentation-only effect?

Custom replication is justified when engine replication is too broad, lacks the application schema, needs owner-only data, requires different rate/reliability semantics, or a measured hot path benefits from packing.

## Remote semantics

- `RemoteEvent` is asynchronous, one-way, and does not yield the sender for a reply.
- `RemoteFunction` is synchronous request/response and yields the invoker.
- `UnreliableRemoteEvent` is asynchronous, unordered, and unreliable; messages may be dropped.

RemoteFunctions are not forbidden for gameplay or by frequency alone. They are appropriate when a bounded request truly needs an immediate response and the caller can tolerate yielding/failure. Avoid server-to-client `InvokeClient()` in critical paths because the client can error, disconnect, or never return.

UnreliableRemoteEvents currently drop payloads over 1,000 bytes and are suitable only when loss/reordering is acceptable. Recheck current limits before shipping.

## Message contracts

For each custom message document what is relevant:

- direction and sender identity;
- payload type and runtime validator;
- semantic authority;
- size/range/depth limits;
- rate/burst policy;
- ordering/duplicate policy;
- reliability choice;
- recipients/relevance;
- version/migration behavior;
- diagnostics and privacy.

Not every message needs a complex version header. A small experience deployed atomically may only need a simple schema revision and safe rejection. Persistent queues, teleports, old servers, and long-lived data increase compatibility needs.

## Server validation

The server-injected `Player` argument identifies which client fired a server remote. It does not make the remaining arguments trustworthy.

Validate in bounded layers:

1. type/shape/size, including NaN and infinity;
2. rate and amplification cost;
3. session/sequence freshness where relevant;
4. permission, ownership, team, and current state;
5. distance/line of sight/target validity where relevant;
6. resource/cooldown/economy rules;
7. authoritative commit.

Reject before expensive pathfinding, raycasts, cloning, or cloud calls where possible.

## Network ownership

Client network ownership gives the client substantial control over simulation of the owned unanchored assembly. Treat positions, velocities, touches, and movement consequences as untrusted for competitive/gameplay-critical outcomes. Validation must be mechanic-specific; a universal speed check produces false positives in vehicles, teleports, and unstable networks.

Roblox’s current server-authority model changes some physics/prediction options. Treat it as an explicit engine mode with documented setup and tests.

## Buffers and quantization

A `buffer` is a fixed-size mutable byte block with zero-based offsets and bounded read/write operations. Buffers are useful when measurement shows that binary packing, batching, or allocation reduction matters.

Every codec needs:

- version/layout documentation;
- length checks before reads;
- integer/range/NaN handling;
- quantization error bounds;
- maximum record count;
- decode failure behavior;
- round-trip and malformed-input tests.

Binary is not automatically smaller. Roblox encodes/compresses certain remote values, including buffers, and payload shape affects the result. Compare representative messages in the real transport.

## Delta replication

Deltas require a known base. Without acknowledgement or a recoverable full snapshot, loss/reordering/version mismatch can make a small delta useless.

Full snapshots can be cheaper for small or heavily changing records. Choose by measured encoded size, CPU, frequency, recipient count, and recovery complexity.

## Interest and privacy

Send only recipients who need application-level information, but do not claim perfect secrecy for objects/data already replicated to a client. Streaming and server-selected remotes can reduce exposure; replicated LocalScripts and ModuleScripts should be assumed inspectable.

## Attributes

Attributes can be appropriate for small Instance-associated replicated values. The writer and authority still matter. The current server-authority prediction model explicitly uses attributes for synchronized custom simulation state on predicted Instances within documented limits, so blanket bans on authoritative health/ammo attributes are outdated in that mode.

Outside that mode, avoid using hundreds of high-frequency attributes as an unmeasured custom replication database. Compare against Instances, remotes, and local data stores for the actual use case.

## Practice project

Implement one interaction request three ways where applicable:

1. RemoteEvent intent plus result event;
2. client-to-server RemoteFunction;
3. no custom remote because engine replication/Attribute is sufficient.

Add hostile payload, spam, disconnect, missing Instance, streaming, and oversized data tests. Measure recipient count × frequency × encoded payload plus validation/serialization CPU.

## Completion evidence

You understand this stage when you can:

- state actual RemoteEvent/RemoteFunction/UnreliableRemoteEvent semantics;
- justify engine versus custom replication;
- trace each client request through semantic validation and commit;
- explain network-ownership risk without a universal movement formula;
- prove buffer/delta value with transport measurements;
- identify what information is already visible to a client.

## Primary references

- [Roblox client-server runtime](https://create.roblox.com/docs/projects/client-server)
- [Remote events and callbacks](https://create.roblox.com/docs/scripting/events/remote)
- [RemoteEvent API](https://create.roblox.com/docs/reference/engine/classes/RemoteEvent)
- [UnreliableRemoteEvent API](https://create.roblox.com/docs/reference/engine/classes/UnreliableRemoteEvent)
- [Securing the client-server boundary](https://create.roblox.com/docs/scripting/security/client-server-boundary)
- [Network ownership and movement validation](https://create.roblox.com/docs/scripting/security/network-ownership)
- [Luau buffer library](https://luau.org/library/#buffer-library)
- [Roblox server-authority model](https://create.roblox.com/docs/projects/server-authority)
