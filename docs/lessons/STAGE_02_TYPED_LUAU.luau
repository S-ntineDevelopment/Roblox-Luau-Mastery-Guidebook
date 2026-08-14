--!strict

-- Use case: accept or reject a coin reward without an ambiguous nil result.

-- Step 1: describe the record and the two possible outcomes.
type PlayerData = {
	coins: number,
}

type RewardResult =
	{ ok: true, newBalance: number }
	| { ok: false, reason: string }

-- Step 2: make the function contract explicit.
local function addCoins(data: PlayerData, amount: number): RewardResult
	if amount <= 0 then
		return { ok = false, reason = "amount must be positive" }
	end

	data.coins += amount
	return { ok = true, newBalance = data.coins }
end

-- Step 3: narrow the tagged union before reading variant-specific fields.
local data: PlayerData = { coins = 10 }
local result = addCoins(data, 5)

if result.ok then
	assert(result.newBalance == 15)
else
	error(result.reason)
end

local rejected = addCoins(data, -1)
assert(not rejected.ok)

print("Stage 2 lesson passed")
