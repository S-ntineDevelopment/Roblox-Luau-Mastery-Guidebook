# Stage 5: Typed Luau and Static Contracts

Luau is gradually and structurally typed. Its type checker can improve editor feedback and refactor safety, but annotations do not validate runtime values, make tables immutable, or create nominal types automatically.

Read [Curriculum Accuracy Standard](CURRICULUM_ACCURACY_STANDARD.md) before this stage.

## Type modes and `--!strict`

Use `--!strict` where its benefit exceeds the migration cost, especially for shared APIs, network schemas, persistence records, and reusable libraries. A mixed legacy project can adopt strictness at boundaries first.

Strict mode is not proof of correctness. `any`, unchecked casts, dynamic requires, engine behavior, and unvalidated external data can bypass assumptions.

## Structural typing

A value satisfies a structural table type when it has the required shape. This works well for small service views, callbacks, and strategy contracts without inheritance.

Width subtyping can let an implementation contain more fields than its public interface. It does not make those fields runtime-private.

Use exact runtime validators when extra fields are a security or forward-compatibility concern; the static structural type alone does not reject a hostile table.

## Functions before objects

Polymorphic contracts do not need `self`:

```lua
export type HitResolver = (origin: Vector3, direction: Vector3) -> RaycastResult?
```

Use a method contract when the implementation owns state or identity. Function contracts are often easier to type and compose for stateless behavior.

## Generics

Generics preserve relationships between input and output types in reusable containers and functions. They do not guarantee that a runtime registry value is valid; dynamic registration still needs an admission check when inputs are untrusted or constructed outside checked code.

Avoid making a generic abstraction only to remove two lines of duplicate code. Prefer generics when the same semantic contract genuinely operates over multiple types.

## ID types: correction to primitive branding

This pattern from the earlier curriculum was wrong:

```lua
-- Do not use this as a primitive brand.
type EntityId = number & { __brand: "EntityId" }
```

An intersection requires a value to be both a number and a table shape; ordinary Luau values cannot satisfy that nominal-brand intent.

Choose one of two honest approaches.

Zero-allocation alias (documents intent but does not prevent mixing):

```lua
export type EntityId = number
export type PlayerId = number
```

Wrapper record (structurally distinguishes domains but allocates and changes representation):

```lua
export type EntityId = { kind: "EntityId", value: number }
export type PlayerId = { kind: "PlayerId", value: number }
```

Use wrapper records only where compile-time domain separation is worth the conversion/storage cost. Runtime validation is still required at network and persistence boundaries.

## Tagged unions

String/boolean singleton types can discriminate table unions:

```lua
type ReloadState =
	{ kind: "Idle" }
	| { kind: "Reloading", endsAt: number }
	| { kind: "Cancelled", reason: string }
```

Tagged unions help model legal alternatives, but Luau does not turn every `if` chain into a guaranteed exhaustive match automatically. Use a final `else`/assertion and let the checker reveal `never` where practical.

## Results and errors

Result types are useful for expected failure:

```lua
export type Result<T, E> =
	{ ok: true, value: T }
	| { ok: false, error: E }
```

They are not mandatory for every function. Returning `nil` can be clear for a simple lookup; throwing is appropriate for programmer misuse; multiple returns may be idiomatic for a small local API. Choose one convention per boundary and document it.

## Public APIs and privacy

An exported type communicates the supported surface. It does not prevent a caller from reaching extra fields on a concrete table if the caller obtains that table with a broader type or uses casts/dynamic code.

Real encapsulation in Luau is primarily achieved through module scope and which values/functions are returned. Types reinforce that design.

## Static and runtime contracts

Pair types with runtime validation when values cross a trust or persistence boundary:

```text
checked producer -> serialized/dynamic boundary -> runtime validator -> typed internal value
```

Network type annotations describe honest checked code. The server must still validate client payload type, size, range, permission, rate, and state context.

DataStore records require version/shape validation because saved data outlives the code version that wrote it.

## Casts and `any`

A cast (`::`) tells the checker to treat a value as another type subject to its cast rules; it does not convert or validate the runtime value. Use casts at proven boundaries and explain the proof.

Prefer `unknown` over `any` for dynamic input because `unknown` must be refined before use. Track `any` at architecture boundaries and remove it when practical.

## Metatable object typing

Metatable-based objects often need explicit data and method types because `self` inference and metatable typing have specific rules. Follow current Luau object-typing documentation rather than copying an old `typeof(setmetatable(...))` pattern blindly; the type solver evolves.

## Practice project

Create a small interaction API with:

- one strict public module;
- a tagged request/result union;
- a stateless callback contract and a stateful method contract;
- an `unknown` payload validator;
- both primitive-alias and wrapper-record ID experiments;
- a deliberate unsafe cast documented and then removed.

Run the current type checker. A code example is not verified merely because it looks like Luau.

## Completion evidence

You understand this stage when you can:

- explain gradual and structural typing;
- distinguish static checking from runtime validation and immutability;
- avoid impossible primitive-intersection brands;
- choose aliases versus wrapper IDs honestly;
- model variants with singleton-tagged unions;
- account for casts, `any`, yields, and mutation that weaken refinements;
- demonstrate checker output for examples against the active toolchain.

## Primary references

- [Introduction to Luau types](https://luau.org/types/)
- [Luau primitive and singleton types](https://luau.org/types/basic-types/)
- [Luau union and intersection types](https://luau.org/types/unions-and-intersections/)
- [Luau object-oriented typing](https://luau.org/types/object-oriented-programs/)
- [Luau type refinements](https://luau.org/types/type-refinements/)
