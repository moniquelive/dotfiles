---
name: lua-style
description: Use when editing Lua or Neovim Lua code to apply the user's Lua style preferences and idioms.
---

# Lua Style

- Keep Lua code terse but readable; prefer direct data flow over extra helpers.
- Prefer `("string"):method()` when calling string methods on literals.
- Prefer `setmetatable({}, { __index = table })` for all tables, use table methods like `:insert()` or `:concat()`.
- For Neovim Lua only, prefer `vim.iter` for mapping, filtering, folding, and table construction when it improves clarity.
- Do not use `vim.*` in plain Lua modules that may run outside Neovim.
- Prefer StyLua-compatible formatting and do not fight the formatter.
- When working on Neovim Lua files, always check Mason-installed tool locations before deciding a formatter/linter is unavailable: first `~/.local/share/nvim/mason/bin/<tool>`, then `~/.local/share/nvim/mason/packages/<tool>/<tool>`.
