# Stage 14: AI and NPC Systems

**Difficulty:** Advanced
**Suggested prerequisites:** Stages 3, 4, 7, and 8

## Guided lesson: choose one NPC action

**Use case:** An NPC chooses patrol, heal, or attack from current context.

**Downloadable code:** [STAGE_14_NPC_DECISION.luau](lessons/STAGE_14_NPC_DECISION.luau)

### Run this before reading the theory

- **Luau CLI:** `luau docs/lessons/STAGE_14_NPC_DECISION.luau`
- **Roblox Studio:** paste the code into a temporary `Script` and run the experience. These examples avoid Roblox services so the first behavior is easy to see.
- Read the `Step 1`, `Step 2`, and `Step 3` comments in order.

### Complete working example

The `type` declarations are checker notes. They describe the allowed shape of a value, but they do not perform the behavior. The working behavior is in the functions, table operations, calls, and assertions below.

<!-- BEGIN VERIFIED LESSON: STAGE_14_NPC_DECISION.luau -->
```luau
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
```
<!-- END VERIFIED LESSON: STAGE_14_NPC_DECISION.luau -->

### Walk through the behavior

Read the three points, run the code, and complete **Try it**. Once you can explain the assertions, this stage's beginner pass is done. Everything after this guided lesson is optional reference material for later.

1. Each `Action` has a name and one scoring function.
2. `chooseAction()` compares scores without executing any action.
3. Low health makes `Heal` win; healthy visibility makes `Attack` win.

- **Expected result:** the two test contexts select `Heal` and `Attack` respectively.
- **Try it:** add a `Flee` action with a score higher than heal below `10%` health.
- **Common mistake:** mixing perception, decision, movement, damage, animation, and replication into one update function.

NPC architecture depends on what the NPC can affect. A cosmetic crowd can be mostly client-side; a competitive combatant’s damage, rewards, and target eligibility need server authority. No single behavior formalism fits every NPC.

Read [Curriculum Accuracy Standard](CURRICULUM_ACCURACY_STANDARD.md) before this stage.

## Decide authority first

Server-validated state is important when an NPC can:

- damage or block players;
- grant rewards or progression;
- reveal hidden information;
- affect competitive objectives;
- own scarce world resources.

Client-side simulation/presentation can be appropriate for ambient crowds, cosmetic animals, local animation, distant impostors, or predicted presentation where divergence has no authoritative impact.

“NPCs are server-authoritative agents” is therefore too broad. Authoritative outcomes are server-owned; computation and presentation can be partitioned.

## Separate concerns only as needed

Useful conceptual parts include:

- sensing/perception;
- remembered state;
- decision policy;
- action execution;
- movement/pathfinding adapter;
- presentation/replication;
- lifecycle and diagnostics.

They can be functions/modules in one package. Do not create seven services for a simple guard NPC.

## Decision techniques

- **Finite state machine**: clear modes/transitions; good for small predictable behavior.
- **Behavior tree**: hierarchical control flow and reusable nodes.
- **Utility scoring**: choose among options based on scored context.
- **Planner**: search action sequences toward goals.
- **Direct rule code**: often clearest for a tiny closed behavior.

These are alternatives and can be combined. A behavior tree is not automatically more scalable than a state machine; a planner can be expensive or unpredictable without bounded search.

## Perception

Perception is a gameplay model, not omniscient access to Workspace. Define sensor frequency, range, occlusion, team rules, memory duration, and uncertainty.

Use spatial queries/raycasts deliberately and budget them. Do not rescan all descendants or recompute every line of sight every frame. Cache only with a freshness/invalidation policy.

Keep hidden goals/threat data server-side when replication would enable cheating. But do not duplicate state secrecy work for cosmetic NPCs with no competitive information.

## Memory/blackboards

A blackboard is one way to make working state inspectable. It can become an untyped dumping ground. Prefer named typed fields or domain records and define who writes each value and when it expires.

Local variables are not inherently wrong. Promote state to a blackboard/store when multiple decisions/actions need it or diagnostics must inspect it.

## Actions

Route authoritative effects through the same domain rules players use where semantics overlap: damage, inventory, interactions, cooldowns, and rewards. An NPC should not bypass validation merely because its command originates on the server.

It may still use a trusted internal command path rather than pretending to be a networked player. Reuse rules, not unnecessary transport.

## Pathfinding and movement

Pathfinding is asynchronous and can fail. Define:

- request budget/coalescing;
- stale path rejection;
- blocked/stuck handling;
- target movement threshold for recompute;
- streaming/world-change behavior;
- cancellation on NPC destroy;
- fallback behavior.

Do not quote an invented universal pathfinding rate. Profile and observe the experience’s actual workload.

Network ownership affects unanchored NPC physics. Choose ownership and validate gameplay consequences. Client ownership may improve responsiveness/performance but cannot be treated as trusted competitive movement.

## Scheduling and scale

One Heartbeat connection per NPC can be wasteful, but a single loop that updates every NPC every frame can also be wasteful. Use relevance, staggered updates, event-driven transitions, distance/interest bands, and batching according to behavior sensitivity.

Parallel Luau may help pure perception/scoring batches after profiling. It introduces Actor/VM state and synchronization costs; do not make it a prerequisite for “advanced” AI.

## Debugging

Useful decision evidence includes:

- current mode/goal/action;
- inputs considered and freshness;
- utility scores or tree path;
- path request/result age;
- last rejection/failure;
- time spent per stage.

Sample and bound histories. Debug tooling should not reveal hidden state to ordinary clients.

## Practice project

Implement one guard using a direct finite state machine. Then implement a utility-scored alternative for the same behavior. Test:

- target appears/disappears;
- path fails or becomes stale;
- NPC destroys during a request;
- 1, 50, and representative maximum NPC counts;
- server-authoritative damage with client-side animation;
- diagnostic explanation for each decision.

Keep the more complex model only if it improves the desired behavior or authoring workflow.

## Completion evidence

You understand this stage when you can:

- choose authority per outcome instead of per “NPC” label;
- select among direct rules, FSMs, trees, utility, and planning;
- bound perception/pathfinding/scheduling work;
- prevent stale async results after destroy or target change;
- reuse authoritative domain rules without unnecessary network simulation;
- explain an NPC decision from bounded runtime evidence.

## Primary references

- [Roblox PathfindingService](https://create.roblox.com/docs/reference/engine/classes/PathfindingService)
- [Roblox character pathfinding](https://create.roblox.com/docs/characters/pathfinding)
- [Roblox network ownership and physics](https://create.roblox.com/docs/scripting/security/network-ownership)
- [Roblox Parallel Luau](https://create.roblox.com/docs/scripting/multithreading)
- [Roblox performance guidance](https://create.roblox.com/docs/performance-optimization/improve)
