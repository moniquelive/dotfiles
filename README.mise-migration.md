# mise tracking inventory

## Provisioning and Homebrew completion

The core provisioning workflow is implemented and shared through `mise-setup`.
Both Macs now use mise 2026.9.3, independent pinned Oh My Zsh and TPM repositories,
missing-only Fish/Yazi restoration, native dependency declarations, and a stable
Fish launcher. Twelve essential home dotfiles were materialized and enrolled.
The FZF Git helper and Kitty scrollback helper now live in tracked `~/.local/bin`
instead of depending on Dropbox. Stow's old update entrypoint delegates to mise;
the archive remains required by deliberately unreviewed account/state and backup
links and must not be deleted wholesale.

The global config is split into `config.toml` (settings), `conf.d/10-tools.toml`,
`conf.d/20-dotfiles.toml`, `conf.d/30-bootstrap.toml`, and separate Linux/macOS
package files. `config.macos.toml` provides Bison's keg-only PATH; the FreeBSD
profile disables unsupported mise backends and uses the guarded native pkg/cron
adapter. `config.armrama.toml` and `config.studiorama.toml` preserve distinct app
inventories. Machine selection lives in untracked `~/.miserc.toml` on each Mac.
There is no unsupported hostname command in the early shared miserc template.

The reviewed Homebrew inventory added 169 declarations: 101 common entries,
26 Armrama-only, and 42 Studiorama-only. Together with the baseline, effective
macOS sets are 83 formulae/61 casks on Armrama and 80 formulae/80 casks on Studiorama.
Dependency-only packages, deprecated entries, uncertain installer artifacts,
unverified taps, and service/data-sensitive overlaps were held out; explanations
are in `~/.config/mise/HOMEBREW.md`. Inventory additions did not reinstall apps.

Full core bootstrap and repeat checks passed on both working Macs before the
inventory expansion. The offline suite passed 46 tests (one opt-in test skipped),
and the fresh Fish/Yazi network restore was separately tested in an isolated home.
Linux/FreeBSD native package application and whole blank-machine installation were
not integration-tested; the enrollment guide states those limits and Intel Mac's
manual package path. Editors retain explicit first-run package installation.

Final `mise doctor` in fresh Fish shells reports no warnings or problems on both
Macs, all selected Homebrew packages installed, all mise tools installed, and both
watchers running. This required installing the missing JDK/native dependencies,
upgrading mise to 2026.9.3, exposing Bison 3.8.2, and fixing PATH activation order.
The guide is at `~/.config/mise/NEW-MACHINE.md` and `/tmp/mise-new-machine.md` locally.

## Current consolidated manifest

On 2026-09-08, the shared live `~/.config/mise/config.toml` was simplified on both
Macs: 81 tracking entries became 39, 105 exclusion patterns became 66, and the
file shrank from 294 to 228 lines. Tools, unrelated settings, credentials and sync
policy were not changed. Both watchers were paused for validation and restarted
successfully in automatic `sync` mode afterward.

The current model is 22 reviewed app-directory entries plus 17 standalone files.
The standalone entries are shell/Git files, Starship, four decks, and the existing
SSH allowlist. Keep SSH explicit because the directory also contains private deploy
keys. Keep `nnn/plugins` narrower than the app root to avoid its runtime state.
No whole-home or whole-`.config` tracking was introduced.

The capture set is unchanged: exactly the same 222 Git snapshot paths and no source
content changes except mise's own configuration. The two older `id_*.pub` omissions
remain. Both hosts passed actual mise capture-count checks for every consolidated
root; after saving/restoring, Git snapshot path and content comparisons passed too.
Studiorama's untracked `git/allowed-signers.before-setup` remains excluded by the
shared backup pattern. Directory tracking also synchronized Fish's root permission
to owner-only `0700` on Studiorama; its existing `0700` htop directory stayed private.

Common exclusions now cover local overrides (`*.local` and `*.local.*`), migration
backups (`*.before-*`), editor debris, environment files and Python bytecode.
App-specific exclusions retain Fisher/Yazi installation boundaries, Emacs packages
and caches, and other runtime state. Ghostty's `appearance.local` and mise's local
origin/credential config remain outside history. Adding Fisher plugins may require
new exclusion entries for their installed files; existing exclusions cover the
currently reviewed plugin set.

New files inside an enrolled app directory now sync automatically unless excluded.
Treat this as a deliberate policy change for future files: exclusions are not a
secret scanner. Entirely new app roots and SSH public keys still need enrollment.
Older per-batch exact-file instructions below describe migration history, not the
current tracking policy. Active configuration is the live home copy, not this
checkout's former `.config/mise/config.toml`.

## Current deferred-config batch

skhd, yabai and htop settings were migrated on Armrama and Studiorama on 2026-09-08.
The manifest now has 81 entries capturing 222 files; the two older `id_*.pub`
omissions remain. Both watchers continue automatic two-way sync.

Only `~/.config/skhd/skhdrc`, `~/.config/yabai/yabairc`, and `~/.config/htop/htoprc`
are tracked. Each root is now a real directory, with its original `.before-mise`
link and an independent owner-only `.before-tracking` directory backup on each
host. Source contents and file permissions match their backups; yabairc remains
executable. The htop parent directory remains `0755` locally and `0700` on
Studiorama, preserving the original host-specific permissions.

All three files were identical. Studiorama's enrollment decisions were accepted
only after checking incoming bytes and executable bits. Both hosts pass yabai
shell grammar and htop assignment-structure checks; the earlier audit also parsed
the 22 skhd shell payloads without executing them. Final histories report matching
source hashes, no unsaved differences, and no unresolved sharing conflicts.

No skhd, yabai or htop process was running at the preflight check, and none was
started, reloaded or installed. This is configuration preservation, not validation
of native command schemas or macOS security compatibility. skhd still references
missing Kitty/yabai executables. yabairc still invokes privileged scripting-addition
loading and uses `find ... -delete` on its temporary monocle-lock pattern when
executed; those commands were not run. Review activation separately.

htop can rewrite its own settings and upgrade its older config format. Those
future settings changes now synchronize, including the hardware-dependent meter
layout; no process list or other runtime state is enrolled. Edit these live paths
rather than their former checkout copies.

## Current Emacs and decks batch

Emacs sources and four Deckmaster layouts were migrated on Armrama and Studiorama
on 2026-09-08. There are now 78 entries capturing 219 files, with the existing two
`id_*.pub` omissions. Both watchers continue automatic two-way sync.

Emacs enrollment is limited to `early-init.el`, `init.el`, and `test/init-test.el`
under `~/.config/emacs`. Its entire directory was materialized independently on
each host, preserving local legacy packages, compiled cache files and the local
vterm package symlink. Complete private copies are at `emacs.before-tracking`;
original Stow links remain at `emacs.before-mise`. Each live tree still matches its
own backup, while package/runtime differences between hosts remain intentionally
local. XDG data/cache/state, credentials and Studiorama's private `custom.el` were
not enrolled, copied between machines, or evaluated.

The exact sibling files `~/.config/conf.deck`, `main.deck`, `obs.deck`, and
`spotify.deck` are also materialized and enrolled. Each has an independent
owner-only `.before-tracking` file backup and its original `.before-mise` link.
All seven sources were identical before migration; no configuration settings were
changed. New source files require explicit enrollment.

These are legacy Linux Deckmaster layouts, not Spotify account data. They require
missing `/home/cyber/Pictures/icons/` assets, a Pop launcher script, Linux/X11 tools
and D-Bus services. The main deck includes reboot/suspend button actions and a
command-output widget. No deck loader, command or action was executed or enabled;
activation and dependency migration require separate review.

Emacs 31.1 on both hosts passed reader and `check-parens` checks in `-Q --batch`
without evaluating the three source files, local customizations or package code.
The four deck files parse as TOML, source hashes match, and both histories report
no unsaved differences or sharing conflicts. Full Emacs startup and ERT were not
run because this config/test entrypoint can install or upgrade packages. Studiorama's
watcher was briefly stopped to release the sync lock, then restarted and verified.
Existing-file enrollment was accepted only after byte/mode comparison with the
incoming snapshot. Edit the live files, not the former checkout copies.

## Current small-config batch

Cabal, IPSW and AeroSpace were migrated on Armrama and Studiorama on 2026-09-08.
The manifest now has 71 entries capturing 212 files; the same two `id_*.pub`
omissions remain. Both watchers continue automatic two-way sync.

Only `~/.config/cabal/config`, `~/.config/ipsw/config.yml`, and
`~/.config/aerospace/aerospace.toml` are enrolled. Their parent directories are now
real directories, with original links at `<app>.before-mise` and independent
owner-only backups at `<app>.before-tracking` on each host. Cache, build, download
and runtime files are not enrolled. The three files matched before migration;
contents and permissions remain unchanged, and the old repo sources are intact.

Studiorama's enrollment decisions were accepted only after comparing each live
file and executable bit to the incoming snapshot. TOML/YAML syntax checks passed,
all three file hashes match, and both histories report no unsaved differences or
unresolved conflicts. No native Cabal config-schema test was run. No package index
updates, downloads, software installation, service startup or window operations
were performed.

Cabal is 3.14.2.0 on both Macs, but installed GHC versions differ; this migration
does not align toolchains. The IPSW binary and its configured `/SHARE/IPSWs` output
directory were not found and were not created. AeroSpace was not running or found
in the inspected installation locations. Its config disables login autostart, but
contains window-management hotkeys including close-other-windows; review activation
separately. skhd/yabai were deferred because of their coupled bindings, privileged
startup actions and missing dependencies. htop remains deferred as app-written state.

Edit these three live files, not the former copies in the dotfiles checkout.

## Current legacy-tools batch

Alacritty, Kitty, Fontconfig and nnn's plugin snapshot were migrated on Armrama and
Studiorama on 2026-09-08. There are now 68 entries capturing 209 files; the existing
two `id_*.pub` omissions remain. Both watchers run in automatic two-way sync mode.

All four app roots under `~/.config` are real directories. Each has its original
Stow link retained as `<app>.before-mise` and an independent owner-only full-tree
backup at `<app>.before-tracking` on each Mac. All 68 files were already identical,
including modes, and no settings or plugin implementations changed.

The shared scope is Alacritty's `alacritty.yml` (one exact entry), Fontconfig's
`fonts.conf` (one exact entry), Kitty's eight-file configuration/assets directory,
and nnn's 58-file `plugins/` snapshot. nnn's 57 executable files retain their bits.
Selections, sessions, history, mount directories, sockets, caches, updater archives,
local overrides and Python bytecode remain outside tracking. No plugin updater,
font-cache rebuild, terminal application or GUI was executed.

Studiorama's new-file enrollment was accepted only after comparison with the
incoming snapshot, including executable bits. Its watcher was briefly stopped to
release the sync lock and restarted after restore. Final checks on both hosts show
matching content/mode hashes, no unsaved differences and no unresolved conflicts.
Alacritty YAML, Fontconfig XML, Kitty Python ASTs and all 58 nnn shell scripts parse;
Kitty's four included files exist. These are static checks, not app/runtime tests.

These are preserved legacy configs. Alacritty's YAML was not converted to current
TOML format; application installations were not found in the inspected paths, and
compatibility with current releases is unverified. Font-family availability and
macOS native font alias handling were not tested. Kitty's existing remote-control
settings and bundled `icat/` implementation were retained rather than modernized.

Kitty's scrollback pager still references `~/bin/nvim-scrollback.sh`, which resolves
through Dropbox on both hosts. That executable is identical but remains an external
dependency; `~/bin` was not materialized or enrolled. Some nnn plugins require Linux
facilities or optional tools. Its `getplugs` updater can replace the shared plugin
snapshot; run it only as a deliberate reviewed update, not routine provisioning.

Edit these live config paths instead of the former copies in this checkout.

## Current shell-tools batch

Bat, Vivid, Carapace and Television were migrated together on Armrama and Studiorama
on 2026-09-08. The manifest now has 64 entries capturing 141 files; the two existing
`id_*.pub` omissions remain. Both watchers continue automatic two-way sync.

All four `~/.config/<app>` roots are real directories. Each host retains the original
link at `<app>.before-mise` and an independent owner-only directory backup at
`<app>.before-tracking`. All 35 shared files were already identical, and no settings
were changed. Studiorama's enrollment checks were accepted only after byte-for-byte
comparison against the incoming snapshot.

Exact-file entries cover Bat's `themes/Ef Cherie.tmTheme`, Vivid's
`themes/ef-cherie.yml`, and Carapace's `styles.json`. Television's whole directory
is tracked: its main config, theme, and 30 channel definitions. Future Television
config files are captured unless excluded; the other three apps require explicit
enrollment for additional shared files. Television's history/environment/cloud
channels contain command definitions, not captured history or credential values.
No channel commands or integrations were executed during migration.

Generated Bat syntax/theme caches and Carapace bridge caches remain local. Bat's
cache was rebuilt on both Macs and the custom theme is available. After later
theme-source edits arrive, run `bat cache --build` on the affected Mac; no automatic
cache-rebuild hook was added. Vivid color generation passed on both hosts.

All tracked TOML, JSON, XML and YAML files parse. Shared-file hashes match, and
histories report no unsaved differences or sharing conflicts. This is not a test
of every Television channel or application-specific schema. Edit the live config
paths rather than their old copies in this checkout.

htop was audited but deliberately left unchanged: its config is app-rewritten and
should be handled separately if shared mutable settings are desired.

## Current Yazi migration

Yazi migration completed on Armrama and Studiorama on 2026-09-08. The manifest now
has 60 entries capturing 106 files; the existing two `id_*.pub` omissions remain.
Both watchers continue automatic two-way synchronization.

`~/.config/yazi` is materialized on each host, with its full 47-file tree preserved.
Original Stow links remain at `~/.config/yazi.before-mise`; independent owner-only
full-tree backups are at `~/.config/yazi.before-tracking`. The repository sources
were not changed, and both live trees were identical before migration.

The 13 exact tracking entries cover `init.lua`, the four top-level TOML files
(including pinned `package.toml`), the two Ef Cherie flavor files, and all six
files in the retained Rose Pine Moon flavor. Flavors are preserved explicitly
because the current package manifest does not declare either as a dependency.
New shared Yazi files require explicit enrollment.

All 34 files belonging to six installed plugins remain machine-local and excluded
from history. Their hashes still match their pre-migration backups. Package caches,
runtime state, logs, local overrides and backups remain untracked. Both hosts have
Yazi/Ya 26.9.1; no plugin installation, upgrade or preview command was run. Syncing
`package.toml` does not install plugins: fresh hosts need a separate package restore
using the actual Ya executable. Zsh aliases `ya` to `yazi`, so use `command ya pkg
install` rather than invoking the alias, and do not use `--discard` casually.

All tracked TOML/XML files parse and `init.lua` compiles without execution. The 13
shared-file hashes match, histories show no unsaved differences or conflicts, and
the watchers remain active. Studiorama's new-file enrollment checks were accepted
only after byte-for-byte comparison with the incoming snapshot. These are static
and synchronization checks, not TUI/preview or complete application-schema tests.

Separate existing-plugin follow-up: the pinned DuckDB preview plugin interpolates
filenames into SQL without escaping single quotes, and Excel previewing can
install the spatial extension. Its optional opener also uses shell interpolation.
These existing execution boundaries were not exercised or modified during the
migration; audit/update them separately before previewing untrusted filenames.

Edit the live `~/.config/yazi` files, not their former copies in this checkout.

## Current Starship migration

Starship migration completed on Armrama and Studiorama on 2026-09-08. The manifest
now has 47 entries capturing 93 files, with the existing two `id_*.pub` omissions.
Both watchers continue automatic two-way synchronization.

The single `~/.config/starship.toml` file is materialized and tracked on each host.
Original links remain at `~/.config/starship.toml.before-mise`, and independent
owner-only file backups are at `~/.config/starship.toml.before-tracking`.
The old repository copies were left unchanged.

Both configs were already identical, including hostname aliases for both Macs;
no prompt settings changed. The enrollment conflict on Studiorama was accepted
after comparing its file byte-for-byte against the incoming snapshot. Both hosts
use Starship 1.26.0. TOML parsing, matching hashes, and effective Fish/Zsh config
selection checks passed. No custom prompt commands exist in the audited config,
and no prompt-rendering test was run. Final histories report no unsaved differences
or unresolved sharing conflicts. Edit the live `~/.config/starship.toml` from now on.

## Current LazyGit migration

LazyGit migration completed on Armrama and Studiorama on 2026-09-08. The manifest
now has 46 entries capturing 92 files, with the existing two `id_*.pub` omissions.
Automatic two-way sync remains enabled on both hosts.

Only `~/.config/lazygit/config.yml` is tracked. The directory was materialized on
both hosts, preserving `.before-mise` link backups and independent owner-only
`.before-tracking` directory copies beside it. The YAML was already identical;
no settings were changed. Studiorama's enrollment conflict was accepted only after
comparing the live file against the incoming Git snapshot byte-for-byte.

Recent-repository state, pull-request caches, local configuration and other runtime
files are not enrolled. Existing files under the macOS Library application-support
directory were left untouched. Fish and Zsh both select the shared file using
`LG_CONFIG_FILE` and the `lg` alias; both shell selections were verified.

YAML parsing, matching file hashes, watcher status and clean history diffs passed
on both hosts. No LazyGit TUI was launched and no Git operation was performed through
it; YAML parsing is not a complete application-schema or UI test. Edit the live
`~/.config/lazygit/config.yml`, not this checkout's old copy.

## Current Ghostty migration

Ghostty migration completed on Armrama and Studiorama on 2026-09-08. There are now
45 tracking entries capturing 91 files; the two older `id_*.pub` omissions remain.
Both watchers continue automatic two-way synchronization at one-minute intervals.

`~/.config/ghostty` is a real directory on both Macs. Each retains the original
Stow link as `~/.config/ghostty.before-mise` and an independent owner-only backup
as `~/.config/ghostty.before-tracking`. The old repo sources remain unchanged.

All 11 shared files are enrolled, including the default/FreeBSD entrypoints,
behavior, keyboard and appearance settings, theme, shader and both icon assets.
The directory entry includes future shared additions automatically. The optional
`appearance.local` is explicitly excluded so machine-specific appearance remains
local; it was absent on both Macs. Editor debris, environment files and backups
are also excluded. No alternate macOS Library configuration directory exists on
either host, and none was created.

Both hosts run Ghostty 1.3.1. Default and FreeBSD config entrypoints pass its CLI
validation on each Mac, the configured `/usr/local/bin/fish` exists and is
executable, and all 11 file hashes match. Incoming enrollment conflicts were
accepted only after byte-for-byte verification. Histories show no unsaved changes
or unresolved conflicts. No terminal windows were opened or closed; GUI rendering,
shader rendering, fonts and actual FreeBSD execution were not tested.

Edit `~/.config/ghostty`, not this checkout's former copy. Synchronization writes
files; it does not guarantee every setting is reapplied to already-open windows.
Use Ghostty's Reload Configuration action when needed. The `config.freebsd` file
still requires explicit selection and is not automatically selected by its name.

## Current Neovim migration

Neovim migration completed on Armrama and Studiorama on 2026-09-08. The active
manifest now has 44 entries capturing 80 files, with the same two `id_*.pub`
omissions. Both watchers remain in automatic two-way sync mode.

On each Mac, `~/.config/nvim` is a real directory. Its old Stow link is retained at
`~/.config/nvim.before-mise`, and an independent owner-only pre-migration copy is
at `~/.config/nvim.before-tracking`. The old repository sources were not changed.

The one configuration difference was Studiorama's LSP document-highlighting block.
With user approval, that block was preserved on both Macs. All 39 current files
now match, including the 20-plugin `lazy-lock.json`.

Neovim is tracked as a directory, so new configuration files are included
automatically. History exclusions cover swap/backup files, sessions, caches, local
overrides, environment files, and installation directories. These are defensive
filters, not secret detection: never place credentials in shared configuration.
Plugin checkouts, Mason tools, parser installations, logs, undo and other runtime
state under the normal data/state/cache directories remain machine-local.

Validation on both Macs passed: all 36 Lua files parse, lockfile JSON is valid,
headless startup and `VeryLazy` work, and the complete configuration hashes match.
The adopted LSP file passes StyLua. A temporary test harness disabled Lazy missing
plugin installation, update checking, project-local specs, Mason startup installs,
and Tree-sitter parser installs. No dependency upgrade was requested. The harness
is not part of the shared config; normal Neovim retains its existing installation
behavior. This was a startup smoke test, not a test of every language server or UI.

Studiorama's newly enrolled files triggered mise's existing-file safety checks.
All 39 live files were compared byte-for-byte to the incoming snapshot before
accepting enrollment. Final history checks show no unsaved differences or sharing
conflicts. Edit `~/.config/nvim`, not this checkout's former Neovim sources.

## Current Fish migration

Fish migration completed on Armrama and Studiorama on 2026-09-08. Both watchers
run in `sync` mode with one-minute push and fetch intervals. The current manifest
has 43 exact entries and captures 41 files; the two previously documented
`id_*.pub` omissions remain. Earlier sections below record the pilot stages.

Both Fish trees were identical before enrollment. Independent, owner-only backups
of each complete tree are at `~/.config/fish.before-tracking` on the respective
Macs. Existing `.before-mise` rollback links were preserved.

The live global mise configuration now tracks 27 Fish files:

- `config.fish` and `fish_plugins`.
- Seven custom startup snippets in `conf.d`, including the existing 1Password setup.
- Twelve non-Fisher functions, including shell wrappers and maintenance helpers.
- Six completions: `bdcli`, `fj`, `mise`, `mole`, `tailscale`, and `tv`.

The four generated/vendor-style completion snapshots are intentionally retained
for fidelity. They can be replaced with tool-generated completions later; no
completion generators or maintenance functions were executed during migration.

Fisher and puffer-fish's seven installed files remain excluded, along with
`fish_variables`, Fish history, local snippets, and backups. Existing installation
ownership metadata stays machine-local. Both Macs already have matching plugin
installations; no plugin update was needed. On a fresh machine, restore the manifest
and install Fisher/plugins separately rather than copying universal variables.
Syncing `fish_plugins` alone does not install or update plugins. Pinning reviewed
plugin versions and adding their bootstrap installation remain future work.

Validation passed on both Macs: all 27 file hashes match, every tracked Fish script
passes syntax checking, interactive and noninteractive startup succeed, Fisher is
available, and 1Password's socket is selected without a regular agent PID. Both
histories report no unsaved differences or sharing conflicts. Studiorama initially
reported 26 new-file enrollment conflicts; each live file was verified byte-for-byte
against the incoming Git snapshot before accepting it. No distinct local settings
were overwritten, and Fish file contents were not changed by this migration.

Edit the live files under `~/.config/fish`, not the old copies in this checkout.
New custom files need explicit entries in the global mise tracking manifest.
External credentials such as `~/.awskeys.sh` remain outside tracking. The shared
`speed` function is macOS-specific and potentially disruptive when invoked; it was
preserved, not executed or made portable.

Inventory date: 2026-09-08. The local pilot is active in the live
`~/.config/mise/config.toml`, not the former source in this checkout.
Pilot paths have been materialized and 17 tracking entries declared (15 files
captured; see the public-key limitation below). No watcher or remote is configured,
and no history has been published. Synchronization is explicitly `manual`.
The `README.*` naming keeps this document out of Stow deployment under the existing
ignore rules. Keep this draft outside mise's active global configuration.

## Current deployment update

As of 2026-09-08, the private origin is
`git@github-mise:moniquelive/mise-setup.git` (the SSH alias resolves to GitHub).
Both this Mac and Studiorama have the
local history watcher installed. Studiorama restored all 15 captured files and
reports no working-tree history differences; remote sync remains manual in the
shared configuration. Earlier no-origin/no-watcher statements below describe the
initial pilot rather than the current deployment.

Studiorama's original Stow links were retained as `.before-mise` siblings. Its
SSH config and allowed-signers also have `.before-setup` file backups. The user's
existing mise configuration was previously moved to `~/.config/mise.before-setup`.
Conflicts were resolved using the first Mac's versions with explicit approval.

The shared `miserc.toml` now prefixes its Tera control lines with `# `, making the
raw file valid TOML for incoming validation while preserving runtime FreeBSD-only
environment selection. No full tool/package bootstrap was run on Studiorama.

### Dedicated sync credentials

Armrama and Studiorama each have a distinct local `~/.ssh/mise-setup` Ed25519
private key (`0600`, no passphrase). Their public keys are registered as separate
write-enabled deploy keys scoped only to `moniquelive/mise-setup`. Neither key pair
is in the tracking manifest, and private keys were not transferred between hosts.

The shared `github-mise` SSH alias disables agent use, identity fallback, key
loading, and connection sharing. Both mise origins use that alias. Read and write
access succeeded with `SSH_AUTH_SOCK=/nonexistent`; personal SSH/Git identities and
commit signing remain under 1Password. Remote sync remains manual until explicitly
enabled. Revoke a lost machine's deploy key independently in repository settings.

## Tracking manifest

Use exact file entries, never directory-wide tracking of `~/.ssh`. mise tracking
entries do not support glob paths, so every currently discovered `.pub` file is
listed explicitly. The user removed `old-keys` during SSH cleanup; its two former
entries are intentionally omitted. New public keys require a
new entry. Public keys and certificates are not private keys, but may disclose
identities and infrastructure metadata; the destination repository should be private.

The following TOML records the tracking portion now merged into global config.
It is not a replacement for the existing tools/settings configuration.

```toml
[dotfiles]
"~/.ssh/config" = { mode = "track" }
"~/.ssh/ed25519-2026.pub" = { mode = "track" }
"~/.ssh/github_rsa.pub" = { mode = "track" }
"~/.ssh/id_ed25519.pub" = { mode = "track" }
"~/.ssh/id_rsa.pub" = { mode = "track" }
"~/.ssh/leo_labs.pub" = { mode = "track" }
"~/.ssh/vdl.pub" = { mode = "track" }
"~/.ssh/vitor_labs.pub" = { mode = "track" }
"~/.ssh/z_github_rsa.pub" = { mode = "track" }
"~/.config/git/allowed-signers" = { mode = "track" }

# Supporting configuration needed to reproduce signing, agent selection, and mise.
"~/.gitconfig" = { mode = "track" }
"~/.zshenv" = { mode = "track" }
"~/.zshrc" = { mode = "track" }
"~/.config/fish/conf.d/1password-ssh-agent.fish" = { mode = "track" }
"~/.config/mise/config.toml" = { mode = "track" }
"~/.config/mise/config.freebsd.toml" = { mode = "track" }
"~/.config/mise/miserc.toml" = { mode = "track" }

[settings]
history.sync = "manual"

[history]
exclude = [
  "~/.ssh/known_hosts*",
  "~/.ssh/authorized_keys*",
  "~/.ssh/environment",
  "~/.ssh/master-socket/**",
  "~/.ssh/config.local",
  "~/.ssh/config.local.d/**",
  "~/.ssh/*.pem",
  "~/.ssh/**/*.pem",
  "~/.ssh/*.key",
  "~/.ssh/**/*.key",
  "~/.config/mise/config.local.toml",
  "~/.config/mise/*.local.toml",
  "~/.config/fish/fish_variables",
]
```

The exact-file allowlist is the main protection for private keys, which often have
no extension. These exclusions are defense in depth, not a complete secret detector.
Keep mise's built-in credential/local-file exclusions. Inspect `dotfiles paths`
after enrollment to confirm every intended file is active and nothing unexpected
is captured. Do not bypass protected-path exclusions broadly.

## Materialization completed

The user materialized `~/.ssh` and retained `~/.ssh.before-mise` as a link into
Dropbox. The live directory is owner-only (`0700`); Dropbox contents were not
restored or modified by this migration.

The following six Stow links were replaced with verified copies, preserving their
owner/group and permissions, with the original symlink retained at each path plus
`.before-mise`:

- `~/.config/git`
- `~/.config/mise`
- `~/.config/fish` (including untracked neighbors; not authorization to track them)
- `~/.gitconfig`
- `~/.zshenv`
- `~/.zshrc`

The original repo sources remain unchanged. These live copies are now independent:
edits in the checkout no longer update them. Do not run `stow .` or the existing
Stow update script during this transition. The rest of the repository has not been
migrated. Backup links are rollback references, not immutable snapshots; keep the
source contents intact. To roll back, first preserve any edits in the new live
copy, move it aside, then rename its `.before-mise` link to the original path.

## Readiness and remaining work

1. **Confirm SSH sanitation.** The user cleaned the file; the earlier password-like
   comments and PEM reference were not reproduced in the follow-up inspection.
   This is not a comprehensive secret audit. Rotate any still-valid credentials
   formerly exposed in Dropbox. Removing a value does not erase historical copies.
2. **Keep rollback paths untracked.** Never enroll `.before-mise` links or the
   Dropbox target. Review remaining local private-key permissions separately.
3. **Verify materialized paths on each machine.** This machine's selected paths
   are now real files/directories, but other machines still require their own
   inventory and safe materialization before capture.
4. **SSH portability cleanup verified.** The user removed the hardcoded
   `IdentityAgent`, global forwarding, and old identity references. SSH now uses the
   inherited agent socket; `ssh -G hass` confirms `forwardagent no`. GUI clients
   without that environment still need a deliberate agent policy. Put future
   specific/local overrides before wildcard defaults.
5. **Optional SSH cleanup remains.** `AddKeysToAgent`/`UseKeychain` remain, as does
   automatic identity selection. Prefer host-specific `.pub` selection with
   `IdentitiesOnly yes` when many agent keys cause authentication failures. Do not
   blindly replace every service's identity with the new key. `master-socket` now
   exists locally; recreate it on restores and never sync its sockets.
6. **Review supporting files as a complete dependency set.** Audit shell and Git
   config for secrets and machine-only paths before capture. Zsh depends on Oh My
   Zsh and other local sources; this batch is not a complete shell restore. Keep
   external credential files such as `~/.awskeys.sh` untracked. Confirm Git's
   `op-ssh-sign` configuration has an explicit FreeBSD policy rather than assuming
   the desktop agent is available in labs.
7. **Local history signing verified.** The first mise checkpoint completed without
   a prompt and its internal Git commit is unsigned (`%G? = N`). Normal repository
   signing settings were not changed, and both existing signed commits still verify
   as `G`. This tests local capture, not unattended remote authentication or service
   startup on other platforms.

## Local pilot results

- Initial checkpoint 1 captured 15 files. No obvious secret literals were found in
  the bounded review of the allowlist; this is not a guarantee of secret absence.
- A temporary comment in `allowed-signers` was saved, rolled back, restored with
  `undo`, and rolled back again. The file was verified byte-for-byte against its
  original; no test comment remains in the live file.
- Eight checkpoints record the baseline and recovery test. The final working-tree
  history diff reports no differences. Harmless intermediate test saves remain in
  local history and would be included in a later publication.
- The history repository has no remote. No full bootstrap, package installation,
  watcher installation, or synchronization was run.

### Public-key limitation in mise 2026.9.2

The built-in credential filter matches `id_*` even for public-key files. Consequently
`~/.ssh/id_ed25519.pub` and `~/.ssh/id_rsa.pub` are declared but NOT captured.
`dotfiles paths` reports the omissions; status alone may call these entries tracked.
The filter cannot be overridden with a narrow user include in this release.

Do not rely on this pilot to restore those two files. Their live files and existing
backups are untouched. Before a complete restore, choose a supported fix: verify an
upstream version with a public-key exception, deliberately rename the public files
and update references, or configure encrypted tracking for those exact files with
independently recoverable decryption identities. No protection was bypassed and no
encryption or renaming was introduced during this pilot.

### Current manual workflow

Run from home to avoid loading this checkout's former mise configuration:

```sh
mise -C "$HOME" bootstrap dotfiles paths
mise -C "$HOME" bootstrap dotfiles save
mise -C "$HOME" bootstrap dotfiles history
mise -C "$HOME" bootstrap dotfiles status
```

Edits are NOT saved automatically yet. Keep the origin unset until the captured
history is reviewed and a private destination plus background credentials are ready.

## Deliberately not tracked

- Private SSH keys, PEM credentials, Dropbox SSH directories, and recovery secrets.
- `known_hosts`: host trust is verified per machine; do not blindly distribute trust.
- `authorized_keys`: inbound access policy belongs to each server, not every desktop.
- Agent sockets, multiplexing sockets, PID/environment caches, and keychain data.
- mise `config.local.toml`, origin credentials, deploy keys, and encryption identities.
- Fish universal variables, editor databases, conversations, caches, and sessions.
- The entire 1Password config directory, which is not a public configuration bundle.

## Suggested next batches

- A reviewed `~/.config/1Password/ssh/agent.toml` if custom vault/key selection is
  needed. None was found in the current standard configuration directory. Track
  only that file, not the surrounding application data.
- Selected Fish config/functions and its plugin manifest, after auditing mutable
  state and deciding how Fisher-installed code is restored.
- Neovim configuration and lockfile, with generated state excluded.
- Oh My Zsh and urxvt Perl extensions as independent `[bootstrap.repos]` clones,
  not tracked copies or submodule worktrees dependent on this checkout.
- A local SSH include convention, created only when there is an actual override
  to preserve; its contents stay untracked. Public host aliases can remain shared.

## Pilot acceptance checks

1. Back up and materialize the selected live paths; verify none depend on Dropbox
   or the old checkout, including symlinked ancestors.
2. Merge the reviewed tracking declarations into global mise configuration. A
   `track` command saves immediately; do not use it as an inventory command.
3. Keep synchronization manual and leave the origin unset during the local pilot.
   Explicitly save, inspect paths/history, and test rollback/undo on a harmless file.
4. Enable the watcher only after the first captures and signing behavior pass.
   Manual sync still accumulates commits; a later push publishes intermediate saves.
5. Validate SSH and Git signing again. Test platform-specific SSH settings on actual
   Linux desktops; FreeBSD labs need no persistent personal private keys.
6. Review all saved history before connecting a new private setup repository. Test
   a second-machine restore and unattended credentials before retiring Stow.

Installed mise at inventory time: 2026.9.2 (`--from-git` bootstrap syntax). Current
online documentation uses `--adopt`; verify the selected version on each machine
before writing the final installation instructions.
