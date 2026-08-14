# Stage 11: Rules Engines and Declarative Gameplay

**Difficulty:** Advanced
**Suggested prerequisites:** Stages 1-7

A rules engine interprets data or composable rule objects to decide gameplay outcomes. It is useful when many features share stable evaluation semantics. It can also turn simple code into a difficult custom language.

Read [Curriculum Accuracy Standard](CURRICULUM_ACCURACY_STANDARD.md) before this stage.

## When it helps

Consider a rules engine when:

- designers author many data-driven variants;
- validation/effect ordering must be consistent;
- the same conditions/costs/effects combine repeatedly;
- preview/explanation tooling needs a common representation;
- rule definitions need versioning or audit.

Use direct domain code when behavior is unique, highly procedural, timing-sensitive, or easier to understand in ordinary Luau.

## Define semantics before syntax

Specify:

- evaluation order and short-circuiting;
- pure checks versus mutations;
- cost reservation and commit;
- failure/rejection vocabulary;
- randomness and time source;
- idempotency/retry behavior;
- partial failure and compensation;
- recursion/depth/work limits.

Do not start by inventing a DSL. Typed tables/functions may be enough.

## Suggested bounded flow

```text
parse/admit definition
build request context
run cheap structural/state checks
run bounded expensive checks
reserve required resources
apply one authoritative domain mutation
emit presentation/audit effects
```

This is a possible transaction-shaped flow, not database atomicity. If effects span DataStore keys or external services, define idempotency and recovery explicitly.

## Conditions and effects

Keep pure conditions free of side effects when possible; that allows preview and explanation. Effects should return explicit outcomes and avoid arbitrary full-world access.

Ordering matters. Two individually valid effects may conflict. Test commutativity assumptions rather than assuming a list order is harmless.

## Security

Client messages may request a rule/action ID and intent. The server resolves the authoritative definition and checks player/world state. Never accept client-supplied price, reward, cooldown completion, effect list, or target eligibility as truth.

Bound definition size and evaluator work even for server-authored content so a bad config cannot freeze a server.

## Performance

Interpretation and generality cost CPU/allocations. Resolve IDs and validate static definitions at admission, cache only safe compiled forms, and profile representative rule counts. Do not remove dynamic state/security checks from requests.

## Practice project

Build a purchase/interaction evaluator with:

- three pure conditions;
- two resource costs;
- three effects;
- typed rejection reasons;
- preview that cannot mutate;
- an idempotent authoritative commit;
- depth/count limits;
- tests for effect-order conflicts and partial failure.

Then implement one unusual feature directly. If forcing it into the engine obscures the behavior, keep a domain-specific escape boundary or do not include it.

## Completion evidence

You understand this stage when you can:

- justify declarative evaluation from content needs;
- distinguish pure checks, reservation, commit, and presentation;
- state ordering and partial-failure semantics;
- prevent clients from authoring rules/outcomes;
- bound interpreter work;
- choose direct code when it is clearer.

## Primary references

- [Roblox client-server security](https://create.roblox.com/docs/scripting/security/client-server-boundary)
- [Roblox data stores](https://create.roblox.com/docs/cloud-services/data-stores)
- [Luau type system](https://luau.org/types/)
