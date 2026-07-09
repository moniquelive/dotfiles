---
name: lua-style
description: Use when writing, editing, reviewing, or testing Lua (`.lua`) code, including Neovim configuration and plugins, to apply the user's style, formatting, and verification preferences.
---

# Lua Style

## Implementation

- Keep Lua code terse but readable; prefer direct data flow over extra helpers.
- Prefer `("string"):method()` when calling string methods on literals.
- For private, list-like tables that need no other metatable, `setmetatable({}, { __index = table })` is acceptable when method syntax such as `items:insert(value)` or `items:concat(",")` materially improves readability.
- Otherwise prefer `table.insert(items, value)` and `table.concat(items, ",")`. Never add the `table` metatable to map-like, configuration, public API, or externally supplied tables.
- Respect the project's target Lua version. Neovim code must remain compatible with the project's minimum Neovim version and LuaJIT runtime.

## Neovim

- Use `vim.*` only in modules intentionally tied to Neovim; keep reusable plain-Lua modules free of Neovim globals.
- Prefer `vim.iter` for mapping, filtering, folding, and table construction only when the minimum Neovim version supports it and it is clearer than a direct loop.
- Preserve lazy-loading, event, keymap, and plugin-spec conventions already established by the configuration.

## Formatting And Verification

- Use the repository's StyLua configuration when present, format only touched Lua files, and do not manually reshape code against StyLua's output.
- Run the narrowest existing tests after changes. Parse-check plain Lua with the project's interpreter or compiler when available, and use the project's headless Neovim check for runtime configuration.
- Before declaring a formatter or linter unavailable, check project-local tooling and `PATH`, then Mason's `bin` directory under `vim.fn.stdpath("data")`; inspect the package directory only when necessary.
- Report unavailable tools and any verification not run.
