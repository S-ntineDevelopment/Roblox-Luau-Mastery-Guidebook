# Bare Minimum Prerequisites

This is the entry point for the curriculum and a menu for projects using S_ngine, not a universal architecture minimum. Complete the language foundations below before Stage 1, then add only the tooling and boundaries the project actually uses.

## Language foundations

Before [Stage 1](../STAGE_01_LUAU_TABLES_MODULES_METATABLES_DATA_STRUCTURES.md), be comfortable with:

- local variables, scope, functions, parameters, return values, and closures;
- `if`/`elseif`/`else`, `for`, `while`, and early returns;
- strings, booleans, numbers, `nil`, Instances, and basic type annotations;
- table literals, indexing, assignment, `ipairs`, `pairs`, and generalized iteration;
- dot calls versus colon calls;
- Scripts, LocalScripts, ModuleScripts, and the client/server execution split;
- reading an error message and following its file/line traceback.

If any item is unfamiliar, build two or three tiny scripts with it before continuing. Stage 1 then turns those language pieces into reusable data structures and small systems.

Each stage has a standalone lesson under [`docs/lessons`](../lessons/README.md). Run the lesson exactly as written first, predict the assertions, and only then make the suggested change. The lesson files deliberately avoid framework and Roblox-global dependencies so ordinary Luau type checking can explain mistakes clearly.

## Tooling

- Rojo project mapping through `default.project.json`.
- Luau source in `src/Shared`, `src/Server`, and `src/Client`.
- `--!strict` for shared contracts and security-sensitive modules.
- Selene and StyLua configs at the repo root.
- Root `AGENTS.md` copied or inherited from this repo.

## Architecture

- Server authority for gameplay outcomes.
- Typed config per feature domain.
- Owned state in ModuleScripts, services, ECS, or Roblox Instances according to the feature. Attributes are valid when authority/rate/engine semantics fit, including documented server-authority prediction use.
- Roblox Instances used directly unless an adapter provides a meaningful lifecycle, test, streaming, authority, or compatibility boundary.
- Runtime-validated RemoteEvents/RemoteFunctions; a typed adapter is optional when it centralizes useful protocol policy.
- Runtime validators for untrusted boundaries.
- Lifecycle ownership for tasks, connections, Instances, and sessions.
- Diagnostics for authoritative systems.

## Optional Foundation Services

Add only services a project actually needs. Possible examples:

- `World`
- `EntityRegistry`
- `ComponentRegistry`
- `SystemScheduler`
- `NetworkSchemaRegistry`
- `RemoteAdapter`
- `DiagnosticsService`
- `FeatureFlagService`
- `TransactionService`
- `PersistenceService`
- `CombatValidationService`
- `VisibilityService`
- `ReplayCaptureService`

## Upload Rule

When this repo is pushed to GitHub, keep it private unless explicitly approved otherwise.
