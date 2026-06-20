---
name: elixir-style
description: Use when editing Elixir, Phoenix, LiveView, Broadway, Mix, ExUnit, Ecto-style modules, or umbrella apps to apply pragmatic Elixir coding, testing, and verification conventions.
---

# Elixir Style

Use this skill when working on Elixir code, including Phoenix, LiveView, Broadway pipelines, Mix projects, and umbrella apps.

## Workflow
- Prefer minimal, surgical changes over large refactors.
- Keep existing architecture and naming intact unless explicitly asked to change them.
- Run commands from the repository root unless the project clearly documents otherwise.
- If the project uses `mise`, run Mix commands through `mise x -- mix ...`.
- Never commit `.env` files or secrets.

## Common Commands
- Install dependencies: `mise x -- mix deps.get`
- Compile: `mise x -- mix compile`
- Compile strictly: `mise x -- mix compile --warnings-as-errors`
- Format: `mise x -- mix format`
- Check formatting: `mise x -- mix format --check-formatted`
- Test: `mise x -- mix test`
- Coverage: `mise x -- mix test --cover`
- Failed tests: `mise x -- mix test --failed`
- Single test file: `mise x -- mix test path/to/file_test.exs`
- Single test line: `mise x -- mix test path/to/file_test.exs:123`
- Tagged tests: `mise x -- mix test --only focus`

If the project does not use `mise`, use the equivalent `mix ...` command directly.

## Formatting And Structure
- Follow `mix format`; do not hand-format against it.
- Use 2-space indentation.
- Keep modules and functions focused and cohesive.
- Prefer explicit public APIs plus private helpers using `defp`.
- Avoid exposing private functions only for tests; prefer testing through public behavior. If direct access is intentionally needed, make a narrow `@doc false` public function instead of using broad `@compile :export_all`.

Typical module order:
- `use` / `@moduledoc` / module attributes
- `alias`, `import`, and `require`
- Public functions
- Private helpers

## Imports, Aliases, And Requires
- Prefer `alias` for repeated long module names.
- Keep aliases and imports near the top of the module.
- Use `import` sparingly, mainly for framework helpers and sigils.
- Keep `require Logger` near other module-level imports/aliases.

## Naming
- Modules use `PascalCase` under the app namespace.
- Functions and variables use `snake_case`.
- Predicate functions should end in `?`.
- Use descriptive names for payloads and external data, such as `raw_payload`, `producer_config`, `raw_quotation`, or `http_response`.

## Types, Specs, And Contracts
- Add `@spec` to reusable public functions, especially utility modules and application-facing APIs.
- Keep specs truthful to current behavior, not aspirational.
- Use broad return types when the function genuinely passes through arbitrary client/library errors.
- Prefer tagged tuples for fallible operations:

```elixir
{:ok, value}
{:error, reason}
```

## Error Handling
- Use `with` for sequential fallible steps.
- Return tagged tuples for expected failures.
- Avoid raises for normal flow.
- Preserve existing error shapes and messages in established APIs.
- Add context to errors when crossing service or integration boundaries.

## Logging And Observability
- Use `Logger` with actionable context.
- Do not log credentials, tokens, or sensitive payload data.
- Keep telemetry, New Relic, PromEx, and similar instrumentation intact unless explicitly asked to change it.

## Phoenix And LiveView
- Keep authentication flow consistent with existing auth modules and plugs.
- Validate and normalize event payloads before acting.
- For controls that affect processes or pipelines, verify the broadcast/update flow in LiveView modules.
- Prefer testing LiveView behavior through rendered output, events, broadcasts, and assigns rather than internal helper details.

## Broadway And Pipelines
- Respect Broadway callback phases: `prepare_messages`, `handle_message`, and `handle_failed`.
- Keep ack/requeue behavior explicit and tested.
- Queue, exchange, routing-key, and dead-letter topology changes require regression tests.
- Be careful with message processing semantics; small changes can affect retries, acknowledgements, and duplicate processing.

## Testing
- Follow idiomatic ExUnit style: `describe`, explicit assertions, and clear test names.
- Place tests in the same app boundary as the code in umbrella projects.
- Cover both happy path and at least one failure path for behavior changes.
- For parsers and transformers, test valid and malformed inputs.
- For HTTP boundaries, use existing project patterns such as Bypass or local test plugs.
- Keep tests line-targetable so failures can be rerun quickly.
- Prefer `test/support` compiled in `:test` via `elixirc_paths` over ad hoc broad exports when sharing test helpers.

## Before Finishing
- Run `mise x -- mix format` or the project equivalent.
- Run relevant tests; prefer the full suite for cross-app or non-trivial behavior changes.
- For larger changes, prefer `mise x -- mix test --cover` when feasible.
- If behavior changed, include or adjust tests for success and failure paths.
- Summarize changed files, commands run, and remaining risks.
