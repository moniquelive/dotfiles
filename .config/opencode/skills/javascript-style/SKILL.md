---
name: javascript-style
description: Use when editing JavaScript, TypeScript, React, browser UI code, service workers, or Node tests to apply the user's JS style preferences.
---

# JavaScript Style

- Keep JavaScript direct and behavior-oriented; avoid clever abstractions for one-off UI logic.
- Prefer small pure helpers only when they clarify behavior or create useful test seams.
- Prefer vanilla DOM APIs for browser scripts unless the project already uses a framework or dependency.
- Preserve progressive enhancement: load expensive UI, embeds, network requests, and media only after they are needed.
- Use modern JavaScript syntax and 2-space indentation unless the repository clearly uses another style.
- Prefer `const` by default, `let` for reassignment, and avoid `var`.
- Prefer early returns over deeply nested branches.
- Avoid optional dependencies for simple browser or Node tasks; use built-in APIs first.
- Prefer `node:test` and `node:assert/strict` for small Node test suites before adding heavier runners.
- Write behavior tests over snapshots; test inputs, outputs, DOM state, network/cache decisions, and persisted state.
- For service workers, test request routing, cache strategies, offline fallback, and activation cleanup with mocked events.
- For browser UI code, prefer `jsdom` tests for meaningful DOM behavior when pure helpers are not enough.
- For React, follow the repository's existing patterns; do not add `useMemo` or `useCallback` by default.
- Keep service-worker caching conservative: never cache live/session/player routes unless the requirement is explicit.
- Follow repo-local tasks first, especially `mise run test`, `mise run build`, and `mise run ci` when available.
