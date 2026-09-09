# AGENTS.md

## Active Setup (mise)
- The active configuration is in `$HOME`, primarily `~/.config/mise/config.toml`,
  and is shared through the private `moniquelive/mise-setup` history repository.
- Migrated home/config paths are real files and directories. Edit those live paths,
  not their old copies in this checkout. In particular, Neovim now lives at
  `$HOME/.config/nvim`; the relative Neovim paths below describe the archived layout.
- Do not run `stow .`: it conflicts with materialized paths. `update-submodules.sh`
  is now a compatibility entrypoint for `mise -C "$HOME" bootstrap`.
- Keep the old checkout and backups until remaining account/state links have been
  reviewed. Do not automatically track credentials, app databases, or conversations.

## Archived Repo Shape
- This was a GNU Stow-managed dotfiles repo, not a single app/package.
- `.stowrc` enables `--dotfiles`: `dot-*` files map to hidden files in `$HOME` (for example `dot-zshrc` -> `~/.zshrc`).
- Keep `.stow-local-ignore` patterns intact unless you explicitly want different stow behavior.

## Submodules
- `.oh-my-zsh` and `.urxvt/perls` are git submodules (`.gitmodules`).
- Treat submodule content as upstream-owned; avoid editing inside them unless explicitly requested.
- Active Oh My Zsh is now an independent pinned repository declared in mise;
  archived submodules remain untouched as rollback sources.

## Neovim Entrypoints
- Main config entry: `.config/nvim/init.lua`.
- Plugin specs: `.config/nvim/lua/plugins/*.lua` via `config.lazy`.
- Mini setup is intentionally split:
  - `.config/nvim/lua/plugins/mini.lua` (plugin spec)
  - `.config/nvim/lua/config/mini.lua` (orchestrator)
  - `.config/nvim/lua/config/mini_modules.lua`
  - `.config/nvim/lua/config/mappings.lua`

## Neovim Couplings Easy to Miss
- LSP/tooling changes often require edits in both places:
  - `.config/nvim/lua/plugins/lspconfig.lua` (server config/enable)
  - `.config/nvim/lua/plugins/mason.lua` (`ensure_installed` tools)
- TOML `run` language injection for mise depends on both:
  - `.config/nvim/after/queries/toml/injections.scm`
  - custom `is-mise?` predicate in `.config/nvim/lua/plugins/treesitter.lua`
- Tailwind class sorting is provided by project-local Prettier configuration:
  - `.config/nvim/lua/plugins/lazy.lua` maps supported web filetypes to Prettier
  - projects must install and configure `prettier-plugin-tailwindcss`
- Mason tool reconciliation runs three seconds after startup, at most once per day; use `:MasonToolsUpdateSync` to force it.

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
- Check all Neovim Lua with `$HOME/.local/share/nvim/mason/bin/stylua --check .config/nvim`.
