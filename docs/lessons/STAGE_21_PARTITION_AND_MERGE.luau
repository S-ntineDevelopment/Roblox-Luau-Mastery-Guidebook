--!strict

-- Use case: prepare pure numeric work for chunks and merge them serially.

type Job = {
	firstIndex: number,
	lastIndex: number,
}

-- Step 1: partitioning describes isolated work without starting threads.
local function makeJobs(itemCount: number, chunkSize: number): { Job }
	assert(chunkSize > 0, "chunkSize must be positive")
	local jobs: { Job } = {}
	local firstIndex = 1

	while firstIndex <= itemCount do
		local lastIndex = math.min(itemCount, firstIndex + chunkSize - 1)
		table.insert(jobs, { firstIndex = firstIndex, lastIndex = lastIndex })
		firstIndex = lastIndex + 1
	end
	return jobs
end

-- Step 2: a worker performs pure work for one job.
local function sumJob(values: { number }, job: Job): number
	local total = 0
	for index = job.firstIndex, job.lastIndex do
		total += values[index]
	end
	return total
end

-- Step 3: the serial owner merges worker results deterministically.
local values = { 1, 2, 3, 4, 5, 6 }
local total = 0
for _, job in makeJobs(#values, 2) do
	total += sumJob(values, job)
end

assert(total == 21)

print("Stage 21 lesson passed")
