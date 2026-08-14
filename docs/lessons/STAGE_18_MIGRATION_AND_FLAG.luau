--!strict

-- Use case: migrate an old save and enable a feature for a controlled group.

type SaveV1 = { version: "V1", coins: number }
type SaveV2 = { version: "V2", coins: number, level: number }

-- Step 1: migration returns a new current-version record.
local function migrate(save: SaveV1 | SaveV2): SaveV2
	if save.version == "V2" then
		return {
			version = "V2",
			coins = save.coins,
			level = save.level,
		}
	end

	return {
		version = "V2",
		coins = save.coins,
		level = 1,
	}
end

-- Step 2: a flag has an explicit default and allow-list override.
type FeatureFlag = {
	defaultEnabled: boolean,
	enabledUserIds: { [number]: boolean },
}

local function isEnabled(flag: FeatureFlag, userId: number): boolean
	if flag.enabledUserIds[userId] then
		return true
	end
	return flag.defaultEnabled
end

-- Step 3: verify migration and rollout behavior.
local current = migrate({ version = "V1", coins = 25 })
assert(current.version == "V2" and current.level == 1)

local flag: FeatureFlag = {
	defaultEnabled = false,
	enabledUserIds = { [101] = true },
}
assert(isEnabled(flag, 101))
assert(not isEnabled(flag, 202))

print("Stage 18 lesson passed")
