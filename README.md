![100% organic code](https://img.shields.io/badge/100%25%20organic%20code-brightgreen?style=for-the-badge)
[![Say Thanks!](https://img.shields.io/badge/Say%20Thanks-!-1EAEDB.svg)](https://saythanks.io/to/moniquelive)

# dotfiles

## Active setup

The live setup is managed by mise at `~/.config/mise/config.toml` and shared through
the private `moniquelive/mise-setup` repository. Do not run `stow .` against the
materialized configuration. This checkout is retained as a legacy archive and
rollback source; its old config copies are no longer authoritative.

```sh
mise -C "$HOME" bootstrap --dry-run
mise -C "$HOME" bootstrap
mise -C "$HOME" run --skip-tools bootstrap:check
```

Bootstrap declares native dependencies, pinned Oh My Zsh/TPM repositories, and
missing-only Fish/Yazi plugin restoration. It does not install private keys, sign
in to 1Password, install licensed fonts, or start privileged window managers.
Neovim and Emacs keep their explicit first-run package setup.

See [the migration record](README.mise-migration.md) for source/state boundaries.
The operational enrollment guide is also kept in the shared mise configuration as
`~/.config/mise/NEW-MACHINE.md`.

Some legacy account-app/runtime links still use this archive. Do not delete the
checkout or backups wholesale; those paths require separate privacy review.
