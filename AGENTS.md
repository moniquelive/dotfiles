# AGENTS.md

## Repo Shape (GNU Stow dotfiles)
- This is a GNU Stow-managed dotfiles repo, not a single app/package.
- `.stowrc` enables `--dotfiles`: `dot-*` files map to hidden files in `$HOME` (for example `dot-zshrc` -> `~/.zshrc`).
- Apply/sync changes from repo root with `stow .`.
- Keep `.stow-local-ignore` patterns intact unless you explicitly want different stow behavior.

## Submodules
- `.oh-my-zsh` and `.urxvt/perls` are git submodules (`.gitmodules`).
- Treat submodule content as upstream-owned; avoid editing inside them unless explicitly requested.
- Preferred update flow is `./update-submodules.sh` (pull root, update/init submodules, pull each submodule, then `stow .`).

## Neovim Entrypoints
- Main config entry: `.config/nvim/init.lua`.
- Plugin specs: `.config/nvim/lua/plugins/*.lua` via `config.lazy`.
- Mini setup is intentionally split:
  - `.config/nvim/lua/plugins/mini.lua` (plugin spec)
  - `.config/nvim/lua/config/mini.lua` (orchestrator)
  - `.config/nvim/lua/config/mini_modules.lua`
  - `.config/nvim/lua/config/mini_mappings.lua`
  - `.config/nvim/lua/config/mini_starter.lua`

## Neovim Couplings Easy to Miss
- LSP/tooling changes often require edits in both places:
  - `.config/nvim/lua/plugins/lspconfig.lua` (server config/enable)
  - `.config/nvim/lua/plugins/mason.lua` (`ensure_installed` tools)
- TOML `run` language injection for mise depends on both:
  - `.config/nvim/after/queries/toml/injections.scm`
  - custom `is-mise?` predicate in `.config/nvim/lua/plugins/treesitter.lua`

## Validation Commands (focused, repo has no root CI)
- Neovim runtime sanity:
  - `nvim --headless '+doautocmd User VeryLazy' '+qa'`
- Validate plugin lockfile JSON after manual edits:
  - `python3 -m json.tool .config/nvim/lazy-lock.json >/dev/null`
- If plugins are removed, clean installed leftovers:
  - `nvim --headless '+Lazy! clean' '+qa'`

## Formatting
- Neovim Lua formatting uses `.config/nvim/stylua.toml` (`sort_requires.enabled = true`).
- Prefer formatting only touched files.
