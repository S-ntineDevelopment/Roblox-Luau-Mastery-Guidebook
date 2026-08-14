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

print("Stage 15 lesson passed")
