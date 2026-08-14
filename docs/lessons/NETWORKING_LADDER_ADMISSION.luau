--!strict

-- Use case: admit ordered client messages under a simple per-player limit.

type Packet = {
	sequence: number,
	payload: string,
}

type PeerState = {
	lastSequence: number,
	requestsThisWindow: number,
}

-- Step 1: check bounded payload and strictly newer sequence.
local function admit(state: PeerState, packet: Packet, maximumRequests: number): boolean
	if #packet.payload > 32 then
		return false
	end
	if packet.sequence <= state.lastSequence then
		return false
	end

	-- Step 2: apply a workload limit before committing sequence state.
	if state.requestsThisWindow >= maximumRequests then
		return false
	end

	state.requestsThisWindow += 1
	state.lastSequence = packet.sequence
	return true
end

-- Step 3: exercise success, replay rejection, and rate rejection.
local state: PeerState = { lastSequence = 0, requestsThisWindow = 0 }
assert(admit(state, { sequence = 1, payload = "jump" }, 2))
assert(not admit(state, { sequence = 1, payload = "replay" }, 2))
assert(admit(state, { sequence = 2, payload = "move" }, 2))
assert(not admit(state, { sequence = 3, payload = "extra" }, 2))

print("Networking lesson passed")
