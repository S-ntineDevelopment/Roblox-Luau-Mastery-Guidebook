--!strict

-- Use case: validate dynamic settings, then expose a read-only view.

type Settings = {
	volume: number,
}

-- Step 1: runtime validation converts unknown input into trusted data.
local function decodeSettings(value: unknown): Settings?
	if type(value) ~= "table" then
		return nil
	end

	local record = value :: { [string]: unknown }
	local volume = record.volume
	if type(volume) ~= "number" or not math.isfinite(volume) then
		return nil
	end
	if volume < 0 or volume > 1 then
		return nil
	end
	return { volume = volume }
end

local settings = decodeSettings({ volume = 0.5 })
assert(settings ~= nil)
assert(decodeSettings({ volume = 5 }) == nil)

-- Step 2: the proxy has no raw fields, so writes reach __newindex.
local view = setmetatable({} :: Settings, {
	__index = settings,
	__newindex = function()
		error("settings view is read-only")
	end,
})
assert(view.volume == 0.5)

-- Step 3: a rejected write does not mutate the backing settings table.
local writeSucceeded = pcall(function()
	view.volume = 1
end)
assert(not writeSucceeded)
assert(settings.volume == 0.5)

print("Stage 7 lesson passed")
