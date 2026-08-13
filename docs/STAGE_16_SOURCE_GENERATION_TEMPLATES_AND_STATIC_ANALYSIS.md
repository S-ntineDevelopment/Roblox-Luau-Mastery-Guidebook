# Stage 16: Templates, Code Generation, and Static Analysis

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
