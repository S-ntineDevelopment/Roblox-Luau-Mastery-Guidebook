# Stage 19: Domain Platforms and Large-Scale Architecture

**Difficulty rank:** 19/22 — Expert
**Suggested prerequisites:** Stages 6 and 9-15, plus several concrete features to compare

## Guided lesson: share one proven prompt rule

**Use case:** A shop prompt and bell prompt share distance admission but retain different behavior.

**Downloadable code:** [STAGE_19_DOMAIN_PLATFORM.luau](lessons/STAGE_19_DOMAIN_PLATFORM.luau)

### Run this before reading the theory

- **Luau CLI:** `luau docs/lessons/STAGE_19_DOMAIN_PLATFORM.luau`
- **Roblox Studio:** paste the code into a temporary `Script` and run the experience. These examples avoid Roblox services so the first behavior is easy to see.
- Read the `Step 1`, `Step 2`, and `Step 3` comments in order.

### Complete working example

The `type` declarations are checker notes. They describe the allowed shape of a value, but they do not perform the behavior. The working behavior is in the functions, table operations, calls, and assertions below.

<!-- BEGIN VERIFIED LESSON: STAGE_19_DOMAIN_PLATFORM.luau -->
```luau
--!strict

-- Use case: two prompts share the same distance rule but keep their own behavior.

type PromptDefinition = {
	maximumDistance: number,
	run: (playerName: string) -> string,
}

type PromptPlatform = {
	definitions: { [string]: PromptDefinition },
}

-- Step 1: the platform owns the shared admission rule.
local function tryRun(
	platform: PromptPlatform,
	id: string,
	playerName: string,
	distance: number
): string?
	local definition = platform.definitions[id]
	if definition == nil
		or not math.isfinite(distance)
		or distance < 0
		or distance > definition.maximumDistance
	then
		return nil
	end
	return definition.run(playerName)
end

-- Step 2: features provide identity, data, and domain behavior.
local platform: PromptPlatform = {
	definitions = {
		OpenShop = {
			maximumDistance = 10,
			run = function(playerName: string): string
				return `{playerName} opened the shop`
			end,
		},
		RingBell = {
			maximumDistance = 6,
			run = function(playerName: string): string
				return `{playerName} rang the bell`
			end,
		},
	},
}

-- Step 3: both features pass through the same distance check.
assert(tryRun(platform, "OpenShop", "Ari", 4) == "Ari opened the shop")
assert(tryRun(platform, "RingBell", "Ari", 9) == nil)

print("Stage 19 lesson passed")
```
<!-- END VERIFIED LESSON: STAGE_19_DOMAIN_PLATFORM.luau -->

### Walk through the behavior

Read the three points, run the code, and complete **Try it**. Once you can explain the assertions, this stage's beginner pass is done. Everything after this guided lesson is optional reference material for later.

1. `PromptDefinition` contains feature distance and behavior.
2. `tryRun()` owns the genuinely shared lookup and distance rule.
3. The two definitions provide their own results without feature-name branches in `tryRun()`.

- **Expected result:** the nearby shop opens; the distant bell request is rejected.
- **Try it:** add a nearby `SitDown` prompt without editing `tryRun()`.
- **Common mistake:** extracting a platform before multiple real features reveal the same rule.

A domain platform is shared infrastructure for a family of related features, such as weapons, quests, vehicles, or purchases. It is valuable after the domain’s stable rules and meaningful variations are understood. It is not a maturity badge that every codebase must build.

Read [Curriculum Accuracy Standard](CURRICULUM_ACCURACY_STANDARD.md) before this stage.

## When to extract a platform

Evidence for extraction includes:

- several features repeat the same correctness/security rules;
- bugs recur because each feature implements validation/lifecycle differently;
- a stable extension model is visible from real examples;
- shared tooling or migration would reduce total work;
- the team can own compatibility and documentation.

“Used twice” or “before the third time” is only a heuristic. Two similar features may diverge; three duplicated lines may be cheaper than a generic abstraction.

## What belongs together

Group by cohesion and ownership, not by a universal feature/shared split.

A weapon feature package may reasonably own its configuration, runtime orchestration, and client presentation. A shared combat service may own damage rules used by weapons, NPCs, hazards, and abilities. If a rule is not shared, moving it into a central platform can make the system harder to change.

Ask:

- who owns the authoritative decision?
- what changes together?
- which rules are genuinely shared?
- which extension points are open versus closed?
- what can be tested independently?
- what must remain private to the server?

## Contracts and extension points

Use the lightest extension mechanism that fits:

- direct functions for a fixed implementation;
- a tagged union/conditional for a small closed set;
- callback tables for simple configurable behavior;
- strategy objects when behavior owns state/lifecycle;
- a registry when independently owned extensions are loaded by ID.

Registries add admission, duplicate-ID, ordering, versioning, removal, and discoverability responsibilities. They are not automatically superior to code imports.

## Data and configuration

Static configuration is helpful when content designers vary data more often than code. Validate dynamic configuration at load/admission time, but continue runtime validation for player state and hostile input.

Avoid a custom DSL when typed Luau functions/tables are clearer. A DSL becomes a language product: it needs grammar/semantics, errors, tooling, versioning, testing, and security boundaries.

## Domain boundaries

A mature platform may separate:

- content/configuration;
- authoritative runtime state;
- rules/behavior;
- engine adapters;
- network transport;
- persistence;
- presentation;
- diagnostics.

These may be modules inside one package rather than independent services. Split only where the boundary improves authority, ownership, change isolation, or verification.

## Cross-domain transactions

Do not claim that a platform makes multi-system changes automatically atomic. Roblox DataStore `UpdateAsync()` coordinates a single key, while in-memory services can still partially fail. For purchases/rewards, design one authoritative commit record where practical, use idempotency, and define compensation/recovery for external steps.

## Compatibility and deprecation

Compatibility work is proportional to how long old producers/consumers/data can coexist. Consider:

- old live servers and teleport payloads;
- saved records from older code;
- queued MemoryStore messages;
- separately versioned packages;
- content using removed registry IDs.

A small single-place prototype may not need a general migration framework.

## Observability

Platform diagnostics should answer domain questions: admitted config count, rejected command reasons, active sessions, queue depth, transaction outcome, network volume, and version. Do not require every platform to ship a dashboard, replay system, fuzz suite, and health server regardless of risk.

Match proof to risk:

- economy/combat/persistence: strong audit and hostile-input testing;
- cosmetic UI platform: lifecycle and visual checks may dominate;
- editor-only generator: deterministic output and undo/change-history behavior matter.

## Practice project

Take three real interaction features. First implement them directly. Extract only the demonstrated common rules into a small interaction package.

Document:

- common rule versus coincidental similarity;
- closed variants versus open registry entries;
- server/client boundaries;
- migration/removal behavior;
- total code/navigation cost before and after.

Then add a deliberately unusual fourth feature. If it requires escape hatches everywhere, revise the abstraction instead of forcing it in.

## Completion evidence

You understand this stage when you can:

- justify extraction from real variation rather than a slogan;
- keep feature-specific rules cohesive;
- select conditionals, callbacks, objects, or registries intentionally;
- describe failure/compatibility limits honestly;
- avoid calling an application workflow a database transaction;
- delete or simplify a platform whose maintenance cost exceeds reuse.

## Primary references

- [Roblox ModuleScripts](https://create.roblox.com/docs/scripting/module)
- [Roblox client-server runtime](https://create.roblox.com/docs/projects/client-server)
- [Roblox data stores](https://create.roblox.com/docs/cloud-services/data-stores)
- [Roblox memory stores](https://create.roblox.com/docs/cloud-services/memory-stores)
- [Luau structural types](https://luau.org/types/)
