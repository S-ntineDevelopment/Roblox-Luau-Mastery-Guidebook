--!strict

-- Use case: register named actions and reject duplicate IDs.

-- Step 1: define the smallest behavior contract.
type Action = (playerName: string) -> string

type ActionRegistry = {
	actions: { [string]: Action },
}

-- Step 2: validate registration once.
local function register(registry: ActionRegistry, id: string, action: Action): boolean
	if id == "" or registry.actions[id] ~= nil then
		return false
	end

	registry.actions[id] = action
	return true
end

local function run(registry: ActionRegistry, id: string, playerName: string): string?
	local action = registry.actions[id]
	if action == nil then
		return nil
	end
	return action(playerName)
end

-- Step 3: register one feature and exercise success and failure.
local registry: ActionRegistry = { actions = {} }
assert(register(registry, "Greet", function(playerName: string): string
	return `Hello, {playerName}!`
end))
assert(not register(registry, "Greet", function(): string
	return "duplicate"
end))
assert(run(registry, "Greet", "Ari") == "Hello, Ari!")
assert(run(registry, "Missing", "Ari") == nil)

print("Stage 6 lesson passed")
