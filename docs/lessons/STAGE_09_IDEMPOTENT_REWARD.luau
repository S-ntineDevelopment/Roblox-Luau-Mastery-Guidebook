--!strict

-- Use case: a retried reward request must not grant coins twice.

type Profile = {
	coins: number,
	appliedTransactions: { [string]: boolean },
}

-- Step 1: require a stable transaction ID and a valid amount.
local function grantCoins(profile: Profile, transactionId: string, amount: number): boolean
	if transactionId == "" or amount <= 0 then
		return false
	end

	-- Step 2: return success for a known retry without applying it again.
	if profile.appliedTransactions[transactionId] then
		return true
	end

	profile.coins += amount
	profile.appliedTransactions[transactionId] = true
	return true
end

-- Step 3: call the same transaction twice and inspect the durable model.
local profile: Profile = {
	coins = 10,
	appliedTransactions = {},
}

assert(grantCoins(profile, "daily-2026-08-14", 5))
assert(grantCoins(profile, "daily-2026-08-14", 5))
assert(profile.coins == 15)
assert(not grantCoins(profile, "", 5))

print("Stage 9 lesson passed")
