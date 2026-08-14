--!strict

-- Use case: store an ordered score list, ready-player lookup, and player record.

-- Step 1: an array stores values in order.
local scores: { number } = { 10, 25, 15 }
table.insert(scores, 30)
assert(scores[1] == 10)
assert(scores[4] == 30)

-- Step 2: a dictionary looks up a value by key.
local readyByUserId: { [number]: boolean } = {}
readyByUserId[101] = true
readyByUserId[202] = true
readyByUserId[101] = nil
assert(readyByUserId[101] == nil)
assert(readyByUserId[202] == true)

-- Step 3: a record groups named fields that belong together.
type PlayerState = {
	name: string,
	coins: number,
}

local player: PlayerState = {
	name = "Ari",
	coins = 5,
}
player.coins += 2
assert(player.name == "Ari")
assert(player.coins == 7)

print("Stage 1 lesson passed")
