# Specialty: Roblox Combat Security, Aim Automation, and ESP Limits

Combat security protects authoritative outcomes and limits unnecessary information. It cannot make a hostile client trustworthy, prevent decompilation of replicated code, or make already replicated enemy information invisible to an exploiter.

Read [Curriculum Accuracy Standard](CURRICULUM_ACCURACY_STANDARD.md), [Stage 12](STAGE_12_NETWORKING_REPLICATION_SECURITY.md), and the [Networking Ladder](NETWORKING_MASTERY_LADDER.md) first. Stage 18 is recommended for lag compensation and reconciliation.

## Guided lesson: validate one fire intent

**Use case:** The client asks to fire; the server checks cadence, ammo, and range before changing state.

**Downloadable code:** [COMBAT_SERVER_VALIDATION.luau](lessons/COMBAT_SERVER_VALIDATION.luau)

### Run this before reading the theory

- **Luau CLI:** `luau docs/lessons/COMBAT_SERVER_VALIDATION.luau`
- **Roblox Studio:** paste the code into a temporary `Script` and run the experience. These examples avoid Roblox services so the first behavior is easy to see.
- Read the `Step 1`, `Step 2`, and `Step 3` comments in order.

### Complete working example

The `type` declarations are checker notes. They describe the allowed shape of a value, but they do not perform the behavior. The working behavior is in the functions, table operations, calls, and assertions below.

<!-- BEGIN VERIFIED LESSON: COMBAT_SERVER_VALIDATION.luau -->
```luau
--!strict

-- Use case: the server validates a fire intent before changing ammo.

type WeaponState = {
	ammo: number,
	lastShotTime: number,
	secondsPerShot: number,
	maximumRange: number,
}

type FireIntent = {
	clientSequence: number,
	targetDistance: number,
}

type FireResult =
	{ accepted: true, remainingAmmo: number }
	| { accepted: false, reason: string }

-- Step 1: the client sends intent, not damage or a reward.
local function validateFire(state: WeaponState, intent: FireIntent, serverTime: number): FireResult
	-- Step 2: validate server-owned cadence, ammo, and range.
	if intent.clientSequence < 1 or intent.clientSequence % 1 ~= 0 then
		return { accepted = false, reason = "bad sequence" }
	end
	if state.ammo <= 0 then
		return { accepted = false, reason = "empty" }
	end
	if serverTime - state.lastShotTime < state.secondsPerShot then
		return { accepted = false, reason = "too fast" }
	end
	if not math.isfinite(intent.targetDistance)
		or intent.targetDistance < 0
		or intent.targetDistance > state.maximumRange
	then
		return { accepted = false, reason = "out of range" }
	end

	-- Step 3: commit only after every check passes.
	state.ammo -= 1
	state.lastShotTime = serverTime
	return { accepted = true, remainingAmmo = state.ammo }
end

local weapon: WeaponState = {
	ammo = 2,
	lastShotTime = 0,
	secondsPerShot = 0.2,
	maximumRange = 100,
}

local accepted = validateFire(weapon, { clientSequence = 1, targetDistance = 30 }, 1)
assert(accepted.accepted and accepted.remainingAmmo == 1)

local rejected = validateFire(weapon, { clientSequence = 2, targetDistance = 30 }, 1.1)
assert(not rejected.accepted and rejected.reason == "too fast")
assert(weapon.ammo == 1)

print("Combat security lesson passed")
```
<!-- END VERIFIED LESSON: COMBAT_SERVER_VALIDATION.luau -->

### Walk through the behavior

Read the three points, run the code, and complete **Try it**. Once you can explain the assertions, this stage's beginner pass is done. Everything after this guided lesson is optional reference material for later.

1. `FireIntent` contains sequence and target distance—not damage, ammo, or rewards.
2. `validateFire()` reads server-owned `WeaponState` and returns a specific rejection reason.
3. Ammo and last-shot time change only after every check passes.

- **Expected result:** the first shot succeeds; a shot `0.1` seconds later fails as too fast and spends no ammo.
- **Try it:** submit a target beyond `maximumRange` and check the reason.
- **Common mistake:** treating one valid shot or one suspicious shot as proof about the player's overall legitimacy.

## Threat model

Assume a hostile client can:

- inspect and alter local code/state;
- invoke client-triggerable remotes/events with arbitrary arguments and frequency subject to engine behavior;
- automate input/aim;
- read information already replicated to it;
- manipulate network-owned assemblies and local character behavior;
- suppress or forge client telemetry.

Therefore client anti-tamper, hidden remote names, obfuscated modules, and client-reported detections are weak signals—not authority.

## What the server should decide

For competitive combat, the server should authoritatively admit:

- equipped weapon and ownership;
- fire cadence and reload/ammo/resource state;
- legal origin/direction tolerances;
- target eligibility/team/alive state;
- hit/damage/reward/kill-credit outcomes;
- accepted lag-compensation window;
- sequence/rate policy.

The client may collect input, present recoil/camera/crosshair, play predicted effects, and send an aim/input candidate. “Server decides” does not require hiding all responsiveness behind round-trip latency.

## Fire command design

A request commonly includes a weapon/session ID, sequence/tick, and aim/input candidate. Avoid client-authored final hit, target damage, reward, or ammo truth.

Validate in a cheap-to-expensive order:

1. payload size/type/finite numbers;
2. rate/burst and session freshness;
3. weapon ownership/equipped state;
4. cadence/ammo/reload/state;
5. origin/direction plausibility;
6. historical/geometry/target rules;
7. authoritative mutation and effect replication.

Record internal rejection reasons. A client-facing reason may be generic to avoid leaking sensitive validation details.

## Hitscan and origin

The server can raycast using server geometry, but the correct origin policy depends on the game:

- muzzle origin is authoritative but can disagree with camera peeking;
- camera-origin candidates improve feel but require bounds and obstruction rules;
- third-person/VR/mobile/control schemes change legitimate aim behavior;
- streaming/prediction/history affect what each side observed.

Define a tolerance model and test corner peeks, close walls, moving platforms, respawn, and high latency. Do not call every client/server mismatch cheating.

## Lag compensation

Maintain bounded server-owned history only for state needed by validation. Map client tick/time to server history with a documented tolerance; a client timestamp is not proof.

The history window is a game fairness decision, not a universal 200 ms value. Longer rewind helps high-latency attackers and can hurt targets who moved behind cover.

Handle discontinuities explicitly:

- spawn/death/respawn;
- teleport/dash;
- invulnerability;
- changing hitboxes;
- vehicle entry/exit;
- missing history.

If Roblox physics cannot be replayed exactly, store simplified hit volumes or validate an approximation and document its limits.

## Projectiles and explosives

Choose an authority model:

- server-simulated projectile;
- client-predicted/server-simulated projectile;
- server-admitted analytic trajectory;
- engine physics with explicit network ownership and plausibility validation.

Do not trust client `Touched`, explosion victims, or final impact position for damage. Validate lifecycle, maximum lifetime/range, collision policy, and duplicate impact handling.

## ESP and information exposure

You cannot prevent an exploiter from reading information already replicated to their client. Reduce exposure by:

- keeping secret objectives/hidden targets/server hit volumes in server-only containers/data;
- sending owner/team/relevance-filtered marker data;
- avoiding ReplicatedStorage for server-only modules/assets/data;
- using streaming where it fits world delivery, while not treating streaming as a security guarantee;
- deriving UI markers from server-approved information when the marker itself is privileged.

World geometry/characters that legitimate clients must render may still be available to ESP. State this limitation honestly.

## Aim automation evidence

Aimlock/aimbot behavior is statistical and contextual. One fast flick, headshot, or low reaction time is not proof. Legitimate behavior varies with mouse/controller/touch, sensitivity, aim assist, accessibility tools, skill, latency, frame rate, weapon, and replay error.

Separate:

- **hard invalidity**: violates authoritative cadence, ammo, range, sequence, or geometry rules and can be rejected;
- **soft anomaly**: unusual aim delta, visibility timing, target switching, tracking, or hit distribution and should contribute limited evidence;
- **client telemetry**: forgeable and useful only as supplemental context.

Never define a universal “human maximum turn speed” as an automatic ban threshold.

## Possibility and confidence

A bounded validation report may include:

- accepted server frame/history sample;
- origin/direction tolerance;
- visibility/occlusion result and uncertainty;
- weapon spread/recoil state owned by the server;
- cadence/ammo/sequence result;
- target motion and discontinuities;
- latency/history quality;
- hard rejection versus soft anomaly.

Do not multiply invented probabilities and call the result scientifically calibrated. Validate scoring against labeled/reviewed data where possible, monitor false positives, and keep enforcement more conservative than detection.

## Decoys and honeypots: correction

The old curriculum recommended server-only fake targets and decoy remotes too casually.

- A server-only target that is never replicated cannot reveal ESP reading client data because the client cannot see it.
- A decoy remote name is security through obscurity; exploit scripts can call it accidentally, malicious users can frame noisy telemetry, and official/test code can drift.
- Hidden fields or canaries may be useful research signals but are not safe sole punishment evidence.

Prefer authoritative rejection and evidence from real protected mechanics. Any canary must be reviewed for false positives, privacy, maintenance, and attacker adaptation.

## Network ownership and movement

Client-owned physics can be manipulated. Validate gameplay consequences rather than trying to infer every local action. Vehicle/character movement needs mechanic-specific tolerances, server-known impulses/teleports, and degraded handling for unstable latency.

Evaluate Roblox’s current server-authority model as a distinct engine option. Its prediction/rollback/Attribute rules must be tested; feature status and limitations can change.

## Data minimization versus gameplay

Do not harm legitimate awareness solely to chase “ESP prevention.” Team markers, accessibility cues, kill cams, replays, spectators, and audio all have game-design value. Decide what each player is allowed to know and enforce that policy server-side where possible.

## Response ladder

Protect state before punishing:

1. reject invalid commands;
2. rate-limit or reduce expensive processing;
3. correct authoritative state;
4. narrow lag/prediction tolerance for a session if policy supports it;
5. log bounded evidence and raise review signals;
6. kick/ban only under a separately defined high-confidence policy with appeal/support considerations.

Do not silently reject every anomaly: unexplained desync can damage legitimate players. Distinguish security-sensitive response detail from enough feedback/telemetry to debug false positives.

## Evidence and privacy

Log enough to reproduce important rejected/suspicious events, not every successful shot forever. Bound retention and cardinality. Prefer IDs, ticks, compact reason codes, and sampled context over full player histories or private data.

An audit log can be wrong if its inputs, clocks, or geometry snapshot are wrong. Include evidence quality and missing-data flags.

## Testing matrix

Test at minimum:

- wrong/missing/oversized/deep/NaN/infinite payloads;
- spam, duplicates, old/future/wrapped sequences;
- fire during reload/death/unequip/respawn;
- leave/destroy during validation;
- high latency, jitter, loss, and server hitch;
- corner peeks and moving/teleporting targets;
- network-owned physics manipulation;
- controller/touch/mouse/accessibility and aim-assist cases;
- false-positive fixtures from skilled legitimate play;
- long-session history/log bounds;
- current server-authority mode separately if used.

Studio fixtures prove only the tested model. Live exploit resistance and engine network behavior require monitored live-like validation.

## Practice project

Build a server-authoritative hitscan validator with:

- bounded fire command schema/rate/sequence;
- server-owned weapon state;
- configurable origin/occlusion policy;
- bounded historical target volumes;
- hard rejection codes separated from soft anomaly evidence;
- predicted client effects corrected by server result;
- representative device/latency fixtures;
- evidence retention/privacy limits.

Do not add automatic bans. Review false positives and model error first.

## Completion evidence

You understand this specialty when you can:

- state what cannot be hidden or trusted on a client;
- reject authoritative impossibilities independently of statistical detection;
- explain lag-compensation fairness and uncertainty;
- avoid honeypot and “human limit” certainty;
- validate network-owned physics outcomes;
- produce bounded, reviewable evidence with known limitations;
- preserve responsive client presentation without granting authority.

## Primary references

- [Roblox security tactics](https://create.roblox.com/docs/scripting/security/security-tactics)
- [Securing the client-server boundary](https://create.roblox.com/docs/scripting/security/client-server-boundary)
- [Network ownership and movement validation](https://create.roblox.com/docs/scripting/security/network-ownership)
- [Roblox client-server runtime](https://create.roblox.com/docs/projects/client-server)
- [Remote events and callbacks](https://create.roblox.com/docs/scripting/events/remote)
- [Roblox server-authority model](https://create.roblox.com/docs/projects/server-authority)
