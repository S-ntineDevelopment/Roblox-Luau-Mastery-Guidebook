--!strict

-- Use case: build a tiny weapon from replaceable ammo and sound behavior.

-- Step 1: define only the operations the weapon needs.
type AmmoStore = {
	takeOne: (self: AmmoStore) -> boolean,
}

type PlaySound = (soundId: string) -> ()

-- Step 2: create a simple ammo implementation.
local function newAmmoStore(startingAmmo: number): AmmoStore
	local store: AmmoStore
	store = {
		takeOne = function(_self: AmmoStore): boolean
			if startingAmmo <= 0 then
				return false
			end

			startingAmmo -= 1
			return true
		end,
	}
	return store
end

-- Step 3: inject the collaborators instead of finding globals inside fire().
local function fire(ammo: AmmoStore, playSound: PlaySound): boolean
	if not ammo:takeOne() then
		return false
	end

	playSound("Fire")
	return true
end

local played: { string } = {}
local ammo = newAmmoStore(1)

assert(fire(ammo, function(soundId: string)
	table.insert(played, soundId)
end))
assert(not fire(ammo, function(_soundId: string) end))
assert(played[1] == "Fire")

print("Stage 6 lesson passed")
