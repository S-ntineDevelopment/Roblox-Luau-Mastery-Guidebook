--!strict

-- Use case: turn an untrusted fire payload into a small trusted record.

type FireRequest = {
	sequence: number,
	directionX: number,
}

-- Step 1: accept unknown at the trust boundary.
local function decodeFireRequest(value: unknown): FireRequest?
	if type(value) ~= "table" then
		return nil
	end

	local record = value :: { [string]: unknown }
	local sequence = record.sequence
	local directionX = record.directionX

	-- Step 2: validate type, integer/range, and finite numeric values.
	if type(sequence) ~= "number" or sequence % 1 ~= 0 or sequence < 1 then
		return nil
	end
	if type(directionX) ~= "number" or not math.isfinite(directionX) then
		return nil
	end
	if directionX < -1 or directionX > 1 then
		return nil
	end

	-- Return a fresh trusted record, not the caller's table.
	return { sequence = sequence, directionX = directionX }
end

-- Step 3: exercise a valid and malformed payload.
local accepted = decodeFireRequest({ sequence = 1, directionX = 0.5 })
assert(accepted ~= nil and accepted.sequence == 1)
assert(decodeFireRequest({ sequence = 0, directionX = 4 }) == nil)
assert(decodeFireRequest("not a table") == nil)

print("Stage 8 lesson passed")
