---
name: javascript-style
description: Use when writing, editing, reviewing, or testing JavaScript, TypeScript, React, Node.js, browser UI code, or service workers to apply the user's pragmatic implementation and verification preferences.
---

# JavaScript Style

## Workflow

- Read repository instructions and inspect `package.json`, the lockfile, runtime targets, TypeScript configuration, and existing tooling before choosing APIs or commands.
- Preserve the configured package manager, module system, framework, formatter, linter, test runner, and architectural patterns.
- Prefer the smallest change that preserves behavior. Do not add a dependency when a platform API or existing dependency already solves the problem clearly.
- Follow repository tasks first, especially `mise run test`, `mise run build`, and `mise run ci` when available; otherwise use the matching package-manager scripts.

## Implementation

- Keep JavaScript direct and behavior-oriented; avoid clever abstractions for one-off UI logic.
- Prefer small pure helpers only when they clarify behavior or create useful test seams.
- Prefer vanilla DOM APIs for browser scripts unless the project already uses a framework or dependency.
- Use syntax and APIs supported by the repository's configured runtime and browser targets. Follow its formatter and indentation.
- Prefer `const` by default, `let` for reassignment, and avoid `var`.
- Prefer early returns over deeply nested branches.
- Preserve type safety in TypeScript. Avoid introducing `any`, unchecked assertions, or duplicate runtime and type models when narrowing or inference is sufficient.

## Browser And React

- Preserve progressive enhancement where applicable: keep essential content and actions usable without client-side JavaScript.
- Defer expensive UI, embeds, media, and network work until needed.
- For React, follow the repository's existing patterns and installed version. Do not add `useMemo` or `useCallback` by default; use transitions, deferred values, and effect events only when their semantics solve a concrete problem.
- Keep service-worker caching conservative. Do not cache authenticated, personalized, streaming, mutation, or explicitly non-cacheable responses unless requirements define a safe strategy.

## Testing

- Use the repository's existing runner and DOM environment.
- For small dependency-free Node projects without a runner, prefer `node:test` and `node:assert/strict`.
- Add `jsdom` only when meaningful DOM behavior requires it and no existing browser-test setup is suitable.
- Prefer behavior tests over snapshots. Test inputs, outputs, DOM state, network and cache decisions, and persisted state.
- For service workers, test request routing, cache strategies, offline fallback, and activation cleanup with mocked events.

## Before Finishing

- Run the narrowest relevant test first, then applicable lint, type-check, build, and broader tests.
- Report commands not run and any remaining browser or runtime compatibility risks.
