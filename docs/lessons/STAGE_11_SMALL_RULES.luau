--!strict

-- Use case: grant a reward only when a player has enough wins.

type PlayerState = {
	wins: number,
	coins: number,
}

type Condition = {
	kind: "MinimumWins",
	amount: number,
}

type Effect = {
	kind: "GrantCoins",
	amount: number,
}

type Rule = {
	condition: Condition,
	effect: Effect,
}

-- Step 1: keep condition evaluation separate from mutation.
local function passes(state: PlayerState, condition: Condition): boolean
	return state.wins >= condition.amount
end

-- Step 2: apply only known, validated effects.
local function applyEffect(state: PlayerState, effect: Effect)
	assert(effect.amount > 0, "reward must be positive")
	state.coins += effect.amount
end

local function runRule(state: PlayerState, rule: Rule): boolean
	if not passes(state, rule.condition) then
		return false
	end
	applyEffect(state, rule.effect)
	return true
end

-- Step 3: test a passing and failing player.
local rule: Rule = {
	condition = { kind = "MinimumWins", amount = 3 },
	effect = { kind = "GrantCoins", amount = 10 },
}

local ready: PlayerState = { wins = 3, coins = 0 }
local notReady: PlayerState = { wins = 2, coins = 0 }
assert(runRule(ready, rule) and ready.coins == 10)
assert(not runRule(notReady, rule) and notReady.coins == 0)

print("Stage 11 lesson passed")
