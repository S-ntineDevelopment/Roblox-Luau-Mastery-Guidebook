--!strict

-- Use case: keep a percentage inside the valid 0-to-1 range.

-- Step 1: write the smallest reusable operation.
local function clamp01(value: number): number
	return math.clamp(value, 0, 1)
end

-- Step 2: use it in two real callers before treating it as shared utility code.
local function healthRatio(current: number, maximum: number): number
	if maximum <= 0 then
		return 0
	end
	return clamp01(current / maximum)
end

local function progressRatio(completed: number, required: number): number
	if required <= 0 then
		return 1
	end
	return clamp01(completed / required)
end

-- Step 3: check boundaries as well as the normal case.
assert(healthRatio(50, 100) == 0.5)
assert(healthRatio(150, 100) == 1)
assert(progressRatio(-2, 10) == 0)
assert(progressRatio(0, 0) == 1)

print("Stage 5 lesson passed")
