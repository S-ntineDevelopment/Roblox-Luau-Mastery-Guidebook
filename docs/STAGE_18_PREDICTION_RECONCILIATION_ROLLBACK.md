# Stage 18: Prediction, Reconciliation, Lag Compensation, and Rollback

**Difficulty rank:** 18/22 — Expert
**Suggested prerequisites:** Stages 12 and 16; Stage 14 is optional

## Guided lesson: correct and replay prediction

**Use case:** A client predicts two movements, then receives server truth acknowledging only the first.

**Downloadable code:** [STAGE_18_RECONCILIATION.luau](lessons/STAGE_18_RECONCILIATION.luau)

### Run this before reading the theory

- **Luau CLI:** `luau docs/lessons/STAGE_18_RECONCILIATION.luau`
- **Roblox Studio:** paste the code into a temporary `Script` and run the experience. These examples avoid Roblox services so the first behavior is easy to see.
- Read the `Step 1`, `Step 2`, and `Step 3` comments in order.

### Complete working example

The `type` declarations are checker notes. They describe the allowed shape of a value, but they do not perform the behavior. The working behavior is in the functions, table operations, calls, and assertions below.

<!-- BEGIN VERIFIED LESSON: STAGE_18_RECONCILIATION.luau -->
```luau
--!strict

-- Use case: accept server position, then replay inputs the server has not acknowledged.

type InputCommand = {
	sequence: number,
	delta: number,
}

type ClientState = {
	position: number,
	pending: { InputCommand },
}

local function apply(state: ClientState, command: InputCommand)
	state.position += command.delta
end

-- Step 1: local input predicts immediately and enters pending history.
local function predict(state: ClientState, command: InputCommand)
	apply(state, command)
	table.insert(state.pending, command)
end

-- Step 2: server acknowledgement becomes the new base truth.
local function reconcile(state: ClientState, serverPosition: number, acknowledgedSequence: number)
	state.position = serverPosition

	local remaining: { InputCommand } = {}
	for _, command in state.pending do
		if command.sequence > acknowledgedSequence then
			table.insert(remaining, command)
			apply(state, command)
		end
	end
	state.pending = remaining
end

-- Step 3: replay only commands newer than the acknowledgement.
local state: ClientState = { position = 0, pending = {} }
predict(state, { sequence = 1, delta = 2 })
predict(state, { sequence = 2, delta = 2 })
assert(state.position == 4)

reconcile(state, 1.5, 1)
assert(state.position == 3.5)
assert(#state.pending == 1 and state.pending[1].sequence == 2)

print("Stage 18 lesson passed")
```
<!-- END VERIFIED LESSON: STAGE_18_RECONCILIATION.luau -->

### Walk through the behavior

Read the three points, run the code, and complete **Try it**. Once you can explain the assertions, this stage's beginner pass is done. Everything after this guided lesson is optional reference material for later.

1. `predict()` applies input immediately and records it by sequence.
2. `reconcile()` replaces predicted position with admitted server position.
3. Only commands newer than the acknowledgement are replayed and retained.

- **Expected result:** prediction reaches `4`; server correction plus command `2` produces `3.5`.
- **Try it:** acknowledge sequence `2` and prove pending history becomes empty.
- **Common mistake:** calling interpolation, reconciliation, lag compensation, and rollback the same process.

Latency techniques solve different problems. A Roblox game should use only the techniques its mechanics need and its simulation can support.

Read [Curriculum Accuracy Standard](CURRICULUM_ACCURACY_STANDARD.md) before this stage.

## Separate the terms

- **Interpolation** renders between known samples, usually adding delay for smoothness.
- **Extrapolation** estimates beyond the newest sample and may need correction.
- **Client prediction** immediately applies local input before authoritative confirmation.
- **Reconciliation** compares predicted and authoritative outcomes and corrects disagreement.
- **Lag compensation** evaluates an action against bounded historical server-known state.
- **Rollback/resimulation** restores earlier state and replays later inputs/events.

You can use interpolation without prediction, prediction without full rollback, or lag-compensated hit checks without rewinding the whole world.

## Authority

For competitive/shared outcomes, the server should decide what is accepted. The client legitimately owns local input collection and presentation and may predict responsiveness. “Server authoritative” does not mean every calculation must run only on the server; it means the server’s admitted result wins.

The server must not trust a client timestamp, position, hit, or sequence merely because it is well typed. Map client data into bounded server history and validate it against server-known context.

## Inputs and acknowledgement

A prediction protocol commonly needs:

- a per-session sequence or tick identifier;
- the minimal input/intent;
- server acknowledgement of processed input;
- bounded pending-input history;
- duplicate/old/future handling;
- a reset policy for wrap, respawn, teleport, or protocol change.

Sequence numbers do not prove honesty; they help ordering and deduplication. Avoid sending client-authored outcomes such as final damage or currency.

## Fixed steps and determinism

A fixed step makes the application update interval explicit. It does not guarantee identical results across client/server, devices, engine versions, or Roblox physics.

Full deterministic replay requires control over all state inputs, iteration order, random sources, numerical behavior, and side effects. When that boundary cannot be made repeatable, reconcile authoritative snapshots instead of claiming deterministic rollback.

## Snapshot design

Snapshot only the state needed to restore the chosen simulation boundary. Define:

- frame/tick identity;
- included/excluded fields;
- full versus delta encoding;
- base snapshot for each delta;
- retention limit and memory budget;
- restore validation;
- behavior when a base or frame is missing.

Do not snapshot Instances, connections, coroutines, metatables, UI, or service objects as if they were portable simulation data.

## Correction policies

Different state needs different correction:

- invisible/internal state may snap immediately;
- camera and render transforms may blend;
- collision-critical state may need an immediate authoritative correction;
- small error may be tolerated until a threshold;
- repeated disagreement may disable prediction for that session.

Smoothing presentation must not leave authoritative collision or rewards in a fake intermediate state.

## Lag compensation

Historical validation trades attacker fairness against target fairness. The history window must be based on the game’s latency policy and measured conditions—not a copied “200 ms” constant.

Validate:

- whether the requested historical time is inside the accepted window;
- which server snapshot it maps to;
- weapon cadence/ammo/state at that time;
- origin and direction tolerances;
- target eligibility and world geometry policy;
- discontinuities such as respawn, teleport, or invulnerability.

Roblox physics history is not automatically reconstructible. Store simplified hit volumes or other bounded server data when exact engine rewind is infeasible.

## Roblox’s server-authority model

Roblox now documents an engine server-authority/prediction model using settings such as fixed simulation, `BindToSimulation()`, predicted Instances, rollback/resimulation, and synchronized attributes. Treat it as a distinct engine feature with current setup requirements and limitations—not proof that a custom rollback architecture is obsolete or that old advice applies unchanged.

If adopting it:

- verify current feature availability and production status;
- follow its prediction and attribute limits;
- keep simulation writes in the documented simulation callbacks;
- test misprediction, streaming, physics, and unsupported APIs in Studio and live-like sessions.

## When not to use rollback

Avoid full rollback when:

- ordinary interpolation is acceptable;
- the mechanic is turn-based or low frequency;
- Roblox physics dominates the result and cannot be replayed reliably;
- snapshots/history exceed memory or complexity budgets;
- reconciliation can correct a small predicted subset;
- durable/economy effects cannot safely be replayed.

## Practice project

Build a one-dimensional pure-data movement simulation:

1. server-authoritative input processing;
2. client prediction;
3. acknowledgement and pending input replay;
4. injected delay/jitter/loss in a test transport;
5. bounded history and correction logs.

Then compare it with interpolation-only presentation. Do not involve Humanoid/physics until the pure-data protocol is correct. If testing Roblox server authority, make that a separate experiment with its documented flags.

## Completion evidence

You understand this stage when you can:

- distinguish all six latency techniques;
- justify which subset the mechanic needs;
- state the exact replay boundary and sources of nondeterminism;
- bound history, pending inputs, and lag compensation;
- separate authoritative correction from visual smoothing;
- demonstrate behavior under delay, jitter, duplication, reordering, and loss appropriate to the chosen transport.

## Primary references

- [Roblox server-authority model](https://create.roblox.com/docs/projects/server-authority)
- [Roblox client-server runtime](https://create.roblox.com/docs/projects/client-server)
- [Roblox remote events and callbacks](https://create.roblox.com/docs/scripting/events/remote)
- [Roblox network ownership and movement validation](https://create.roblox.com/docs/scripting/security/network-ownership)
