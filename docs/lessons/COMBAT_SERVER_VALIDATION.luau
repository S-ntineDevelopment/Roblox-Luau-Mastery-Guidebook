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
