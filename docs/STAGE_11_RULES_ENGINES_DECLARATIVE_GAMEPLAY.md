# Stage 11: Rules Engines and Declarative Gameplay

**Difficulty:** Advanced
**Suggested prerequisites:** Stages 1-7

## Guided lesson: one declarative reward rule

**Use case:** Grant ten coins when a player has at least three wins.

**Downloadable code:** [STAGE_11_SMALL_RULES.luau](lessons/STAGE_11_SMALL_RULES.luau)

### Run this before reading the theory

- **Luau CLI:** `luau docs/lessons/STAGE_11_SMALL_RULES.luau`
- **Roblox Studio:** paste the code into a temporary `Script` and run the experience. These examples avoid Roblox services so the first behavior is easy to see.
- Read the `Step 1`, `Step 2`, and `Step 3` comments in order.

### Complete working example

The `type` declarations are checker notes. They describe the allowed shape of a value, but they do not perform the behavior. The working behavior is in the functions, table operations, calls, and assertions below.

<!-- BEGIN VERIFIED LESSON: STAGE_11_SMALL_RULES.luau -->
```luau
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
```
<!-- END VERIFIED LESSON: STAGE_11_SMALL_RULES.luau -->

### Walk through the behavior

Read the three points, run the code, and complete **Try it**. Once you can explain the assertions, this stage's beginner pass is done. Everything after this guided lesson is optional reference material for later.

1. The `Rule` record contains condition data and effect data.
2. `passes()` reads state without mutation; `applyEffect()` owns the mutation.
3. `runRule()` applies the effect only after the condition passes.

- **Expected result:** the three-win player receives coins; the two-win player does not.
- **Try it:** change the required wins to `5` without changing evaluator code.
- **Common mistake:** building a general scripting language when a typed record and two direct functions solve the problem.

A rules engine interprets data or composable rule objects to decide gameplay outcomes. It is useful when many features share stable evaluation semantics. It can also turn simple code into a difficult custom language.

Read [Curriculum Accuracy Standard](CURRICULUM_ACCURACY_STANDARD.md) before this stage.

## When it helps

Consider a rules engine when:

- designers author many data-driven variants;
- validation/effect ordering must be consistent;
- the same conditions/costs/effects combine repeatedly;
- preview/explanation tooling needs a common representation;
- rule definitions need versioning or audit.

Use direct domain code when behavior is unique, highly procedural, timing-sensitive, or easier to understand in ordinary Luau.

## Define semantics before syntax

Specify:

- evaluation order and short-circuiting;
- pure checks versus mutations;
- cost reservation and commit;
- failure/rejection vocabulary;
- randomness and time source;
- idempotency/retry behavior;
- partial failure and compensation;
- recursion/depth/work limits.

Do not start by inventing a DSL. Typed tables/functions may be enough.

## Suggested bounded flow

```text
parse/admit definition
build request context
run cheap structural/state checks
run bounded expensive checks
reserve required resources
apply one authoritative domain mutation
emit presentation/audit effects
```

This is a possible transaction-shaped flow, not database atomicity. If effects span DataStore keys or external services, define idempotency and recovery explicitly.

## Conditions and effects

Keep pure conditions free of side effects when possible; that allows preview and explanation. Effects should return explicit outcomes and avoid arbitrary full-world access.

Ordering matters. Two individually valid effects may conflict. Test commutativity assumptions rather than assuming a list order is harmless.

## Security

Client messages may request a rule/action ID and intent. The server resolves the authoritative definition and checks player/world state. Never accept client-supplied price, reward, cooldown completion, effect list, or target eligibility as truth.

Bound definition size and evaluator work even for server-authored content so a bad config cannot freeze a server.

## Performance

Interpretation and generality cost CPU/allocations. Resolve IDs and validate static definitions at admission, cache only safe compiled forms, and profile representative rule counts. Do not remove dynamic state/security checks from requests.

## Practice project

Build a purchase/interaction evaluator with:

- three pure conditions;
- two resource costs;
- three effects;
- typed rejection reasons;
- preview that cannot mutate;
- an idempotent authoritative commit;
- depth/count limits;
- tests for effect-order conflicts and partial failure.

Then implement one unusual feature directly. If forcing it into the engine obscures the behavior, keep a domain-specific escape boundary or do not include it.

## Completion evidence

You understand this stage when you can:

- justify declarative evaluation from content needs;
- distinguish pure checks, reservation, commit, and presentation;
- state ordering and partial-failure semantics;
- prevent clients from authoring rules/outcomes;
- bound interpreter work;
- choose direct code when it is clearer.

## Primary references

- [Roblox client-server security](https://create.roblox.com/docs/scripting/security/client-server-boundary)
- [Roblox data stores](https://create.roblox.com/docs/cloud-services/data-stores)
- [Luau type system](https://luau.org/types/)
