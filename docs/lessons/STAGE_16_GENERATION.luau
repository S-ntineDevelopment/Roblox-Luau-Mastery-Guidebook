--!strict

-- Use case: validate a tiny component descriptor before generating source text.

type Field = {
	name: string,
	typeName: "number" | "string" | "boolean",
}

type Descriptor = {
	name: string,
	fields: { Field },
}

-- Step 1: reject malformed input before generation.
local function validate(descriptor: Descriptor): boolean
	if descriptor.name == "" or #descriptor.fields == 0 then
		return false
	end

	local seen: { [string]: boolean } = {}
	for _, field in descriptor.fields do
		if field.name == "" or seen[field.name] then
			return false
		end
		seen[field.name] = true
	end
	return true
end

-- Step 2: generate deterministic text from admitted data.
local function generate(descriptor: Descriptor): string
	assert(validate(descriptor), "invalid descriptor")
	local lines = { "export type " .. descriptor.name .. " = {" }
	for _, field in descriptor.fields do
		table.insert(lines, `\t{field.name}: {field.typeName},`)
	end
	table.insert(lines, "}")
	return table.concat(lines, "\n")
end

-- Step 3: compare generated output with a small expected fragment.
local source = generate({
	name = "Health",
	fields = {
		{ name = "current", typeName = "number" },
		{ name = "maximum", typeName = "number" },
	},
})

assert(string.find(source, "current: number", 1, true) ~= nil)
assert(string.find(source, "maximum: number", 1, true) ~= nil)

print("Stage 16 lesson passed")
