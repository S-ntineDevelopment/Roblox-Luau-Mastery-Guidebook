# Stage 20: Source Generation, Templates, and Static Analysis

**Difficulty rank:** 20/22 — Production
**Suggested prerequisites:** Stages 4, 9-11, and 19

## Guided lesson: validate before generating

**Use case:** Generate a tiny Luau record type from a component descriptor.

**Downloadable code:** [STAGE_20_GENERATION.luau](lessons/STAGE_20_GENERATION.luau)

### Run this before reading the theory

- **Luau CLI:** `luau docs/lessons/STAGE_20_GENERATION.luau`
- **Roblox Studio:** paste the code into a temporary `Script` and run the experience. These examples avoid Roblox services so the first behavior is easy to see.
- Read the `Step 1`, `Step 2`, and `Step 3` comments in order.

### Complete working example

The `type` declarations are checker notes. They describe the allowed shape of a value, but they do not perform the behavior. The working behavior is in the functions, table operations, calls, and assertions below.

<!-- BEGIN VERIFIED LESSON: STAGE_20_GENERATION.luau -->
```luau
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

print("Stage 20 lesson passed")
```
<!-- END VERIFIED LESSON: STAGE_20_GENERATION.luau -->

### Walk through the behavior

Read the three points, run the code, and complete **Try it**. Once you can explain the assertions, this stage's beginner pass is done. Everything after this guided lesson is optional reference material for later.

1. `validate()` rejects empty descriptors and duplicate field names.
2. `generate()` runs only after validation and emits fields in declared order.
3. Assertions check that both expected fields appear in the output.

- **Expected result:** generated text contains `current: number` and `maximum: number`.
- **Try it:** reject a descriptor containing two `current` fields.
- **Common mistake:** trusting generated code merely because the generator completed; generated output still needs parsing/type checks.

Tooling can automate repeatable syntax and detectable repository policy. It cannot generally prove runtime authority, lifecycle correctness, network security, visual quality, or live-provider behavior.

Read [Curriculum Accuracy Standard](CURRICULUM_ACCURACY_STANDARD.md) before this stage.

## Choose the tool for the claim

- **Template**: copy a reviewed starting structure that developers then own.
- **Generator**: produce files/data from an authoritative input.
- **Formatter**: normalize syntax/layout.
- **Linter/static checker**: detect patterns or type errors without executing gameplay.
- **Build step**: transform or validate a source tree.
- **Runtime test**: execute behavior in a controlled environment.

“If a policy matters, automate it” is aspirational, not always cost-effective. Automate rules that are stable, machine-detectable, and frequent enough to justify maintenance.

## Static-analysis limits

A checker can reliably find an AST pattern such as a raw `RemoteEvent.OnServerEvent` outside an allowed directory. It usually cannot prove that every semantic input is validated, the server owns the outcome, or cleanup occurs on every runtime path without deeper whole-program analysis.

Report what the rule detects, likely false positives/negatives, and suppression policy. Do not label architectural heuristics as compiler proof.

## Generated code

Define:

- source of truth;
- deterministic output;
- generator/tool version;
- whether output is checked in;
- how manual edits are prevented or reconciled;
- stale-output detection;
- formatting/type-checking of output;
- upgrade/rollback path.

Generated code can be bloated or slower than hand-written code. Measure hot generated paths and keep diagnostics mapped back to source inputs.

## Templates

A template should contain the minimum proven structure. Optional subsystems should remain optional; generating lifecycle, networking, persistence, registry, and diagnostics layers for every tiny feature teaches ceremony rather than architecture.

Include ownership and deletion instructions for placeholder files so unused scaffolding does not survive indefinitely.

## Roblox/Rojo checks

Static checks may validate source paths, project files, require conventions, forbidden client/server placements, or known service boundaries. Those are repository policies, not Roblox platform requirements.

Rojo sourcemaps and build checks can prove mapping/structure, not that the place behaves correctly in Studio. Keep build, type, unit, Studio runtime, live-provider, and visual proof separate.

## Source transformations and migrations

Prefer AST-aware edits for code. Regex is acceptable for narrowly specified text with fixtures, but can corrupt comments, strings, types, or formatting when treated as a parser.

Make generators/migrations fail safely and provide dry-run/diff output before large rewrites.

## Practice project

Build one feature template and one static check:

- template produces only config, public API, server entry, client entry, and test placeholder when requested;
- checker detects raw client-to-server handlers outside an approved network boundary;
- fixtures include true positives, allowed cases, comments/strings, and false-positive cases;
- CI distinguishes checker success from runtime security proof.

## Completion evidence

You understand this stage when you can:

- name the exact property a tool proves;
- avoid claiming semantic correctness from text matching;
- regenerate deterministically and detect drift;
- keep templates minimal and optional;
- distinguish source/build proof from Studio/runtime/live proof;
- maintain fixtures and suppressions as the project evolves.

## Primary references

- [Luau type system](https://luau.org/types/)
- [Luau linting](https://luau.org/lint/)
- [Luau syntax](https://luau.org/syntax/)
- [Roblox client-server runtime](https://create.roblox.com/docs/projects/client-server)
