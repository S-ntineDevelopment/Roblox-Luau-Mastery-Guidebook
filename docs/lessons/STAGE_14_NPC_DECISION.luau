--!strict

-- Use case: choose whether an NPC should patrol, heal, or attack.

type Context = {
	healthRatio: number,
	canSeeTarget: boolean,
}

type Action = {
	name: string,
	score: (Context) -> number,
}

-- Step 1: each action owns one small scoring rule.
local actions: { Action } = {
	{ name = "Patrol", score = function(): number return 1 end },
	{ name = "Heal", score = function(context: Context): number
		return if context.healthRatio < 0.3 then 10 else 0
	end },
	{ name = "Attack", score = function(context: Context): number
		return if context.canSeeTarget then 5 else 0
	end },
}

-- Step 2: selection compares scores; execution remains a separate concern.
local function chooseAction(context: Context): Action
	local best = actions[1]
	local bestScore = best.score(context)

	for index = 2, #actions do
		local candidate = actions[index]
		local candidateScore = candidate.score(context)
		if candidateScore > bestScore then
			best = candidate
			bestScore = candidateScore
		end
	end

	return best
end

-- Step 3: test two easy-to-explain decisions.
assert(chooseAction({ healthRatio = 0.2, canSeeTarget = true }).name == "Heal")
assert(chooseAction({ healthRatio = 1, canSeeTarget = true }).name == "Attack")

print("Stage 14 lesson passed")
