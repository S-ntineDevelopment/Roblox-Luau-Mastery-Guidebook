--!strict

-- Use case: apply the same regeneration rule to entities with health data.

type EntityId = number
type Health = {
	current: number,
	maximum: number,
}

-- Step 1: store one component type by entity ID.
local healthByEntity: { [EntityId]: Health } = {
	[1] = { current = 5, maximum = 10 },
	[2] = { current = 9, maximum = 10 },
}

-- Step 2: a system applies one operation to every matching record.
local function regenerate(store: { [EntityId]: Health }, amount: number)
	for _, health in store do
		health.current = math.min(health.maximum, health.current + amount)
	end
end

-- Step 3: run the system and check both entities.
regenerate(healthByEntity, 3)
assert(healthByEntity[1].current == 8)
assert(healthByEntity[2].current == 10)

print("Stage 10 lesson passed")
