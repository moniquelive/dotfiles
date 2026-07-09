---
name: elixir-style
description: Use when writing, editing, reviewing, or testing Elixir source and project files (`.ex`, `.exs`, `mix.exs`) in Mix, Phoenix, LiveView, Ecto, Broadway, or umbrella projects to apply pragmatic coding and verification conventions.
---

# Elixir Style

## Workflow

- Read repository instructions and inspect `mix.exs` aliases, `.formatter.exs`, `mise.toml`, and CI configuration before choosing commands.
- Prefer minimal, surgical changes over large refactors.
- Keep existing architecture and naming intact unless explicitly asked to change them.
- Preserve established public contracts, error shapes, and supervision boundaries.
- Run project-wide checks from the repository or umbrella root. In umbrella projects, run focused tests from the affected app when appropriate.
- Use `mise x -- mix ...` when the project uses `mise`; otherwise use `mix ...` directly.
- Prefer project-defined `check`, `ci`, Credo, Dialyzer, or equivalent tasks when available.
- Never commit `.env` files or secrets.

## Common Commands

- Install dependencies: `mise x -- mix deps.get`
- Compile: `mise x -- mix compile`
- Compile strictly when a fresh strict compile is needed: `mise x -- mix compile --force --warnings-as-errors`
- Format: `mise x -- mix format`
- Check formatting: `mise x -- mix format --check-formatted`
- Test: `mise x -- mix test`
- Coverage: `mise x -- mix test --cover`
- Failed tests: `mise x -- mix test --failed`
- Single test file: `mise x -- mix test path/to/file_test.exs`
- Single test line: `mise x -- mix test path/to/file_test.exs:123`
- Tagged tests: `mise x -- mix test --only focus`

Use the equivalent `mix ...` command when the project does not use `mise`. Do not run database setup, coverage, static analysis, or dependency-mutating commands unless they are relevant to the change or required by the project workflow.

## Formatting And Structure

- Follow `mix format`; do not hand-format against it.
- Keep modules and functions focused and cohesive.
- Prefer explicit public APIs plus private helpers using `defp`.
- Test through public behavior. If logic genuinely needs direct testing, extract it into a cohesive module rather than expanding the original module's public API solely for tests.

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
- Prefer tagged tuples for expected failures when they fit the existing contract:

```elixir
{:ok, value}
{:error, reason}
```

## Error Handling

- Use `with` when it makes sequential fallible steps clearer than nested branching or pipelines.
- Return tagged tuples for expected failures where appropriate; preserve framework callback and established API contracts.
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

## Ecto

- Keep changesets responsible for casting and validation; keep business workflow orchestration outside schemas.
- Make migration changes reversible when practical and safe for existing data.
- Test constraint handling, invalid changesets, and query behavior affected by schema, migration, or preload changes.

## Broadway And Pipelines

- Respect the callbacks used by the pipeline, including optional `prepare_messages/2`, `handle_message/3`, `handle_batch/4`, and `handle_failed/2` phases.
- Keep ack/requeue behavior explicit and tested.
- Queue, exchange, routing-key, and dead-letter topology changes require regression tests.
- Be careful with message processing semantics; small changes can affect retries, acknowledgements, and duplicate processing.

## Testing

- Follow idiomatic ExUnit style: `describe`, explicit assertions, and clear test names.
- Place tests in the same app boundary as the code in umbrella projects.
- Cover relevant success and failure behavior, especially at external or fallible boundaries.
- For parsers and transformers, test valid and malformed inputs.
- For HTTP boundaries, use existing project patterns such as Bypass or local test plugs.
- Keep tests line-targetable so failures can be rerun quickly.
- Prefer `test/support` compiled in `:test` via `elixirc_paths` over ad hoc broad exports when sharing test helpers.

## Before Finishing

- Run `mise x -- mix format` or the project equivalent.
- Run targeted tests first, then affected-app or full-suite tests for cross-app or non-trivial behavior changes.
- Run configured compile, lint, type, or CI checks relevant to the touched code.
- If behavior changed, include or adjust tests for success and failure paths.
- Summarize changed files, commands run, and remaining risks.
