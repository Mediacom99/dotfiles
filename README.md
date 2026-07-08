# dotfiles

Personal macOS dotfiles. Branch `macos` (there's also `arch-linux`). Each tool
lives in its own top-level directory; copy or symlink the pieces you want into
`~/.config` (there's no install script — it's a reference layout).

```
emacs/     Emacs config
fish/      fish shell: config.fish, functions/, conf.d/
ghostty/   Ghostty terminal config
nvim/      Neovim config
tmux/      tmux config
```

## fish

| Path | What it is |
|------|------------|
| `fish/config.fish` | main shell config |
| `fish/conf.d/fnm.fish` | fnm (Node version manager) init |
| `fish/conf.d/rustup.fish` | sources `~/.cargo/env.fish` |
| `fish/conf.d/work-profile.fish` | per-directory work/personal profile switcher (see below) |
| `fish/functions/kclaude.fish` | launch Claude Code on the work account in any folder (see below) |
| `fish/functions/zx-hook.fish` | commandline hook for the `zx` helper |

Files in `conf.d/` are auto-sourced by fish on startup; files in `functions/`
are autoloaded on first call.

### Work / personal profile switching

`conf.d/work-profile.fish` switches shell identity based on the current
directory, so work and personal stay cleanly separated:

- Inside a configured **work root**, it exports the work profile:
  - `CLAUDE_CONFIG_DIR` — Claude Code config dir (separate settings, memory, login)
  - `GH_CONFIG_DIR` — `gh` CLI config dir (separate GitHub account)
  - `GIT_AUTHOR_*` / `GIT_COMMITTER_*` — commit identity
  - a git credential-helper override routing `git push` auth through `gh`, so a
    bare `git push` uses the work account instead of the default keychain
- **Everywhere else**, it restores the personal profile.

Personal is always the default. All machine-specific values (paths, work email,
client name) live in a **gitignored** local file, so this repo stays free of
private details:

```fish
cp ~/.config/fish/work-profile.local.fish.example ~/.config/fish/work-profile.local.fish
# then edit it with your real values
```

With no local file present, the switcher is a no-op — nothing changes, and the
public config works as plain personal-only dotfiles.

- Disable for a session: `set -gx WORKPROF_DISABLE 1`
- Inspect current profile: `echo $WORKPROF_ACTIVE`

### `kclaude` — work Claude in any folder

`functions/kclaude.fish` launches one Claude Code session on the **work
account** from any directory (including outside the work root), without touching
your shell or other terminals (it's child-scoped via `env`). It reads the same
`work-profile.local.fish` values.

| Command | Effect |
|---------|--------|
| `kclaude` | **lite**: work account, minimal config (no work memory/skills/hooks). Session auto-memory is written into the project's own folder (`<project-root>/.claude/memory`), so side-project memory never mixes across projects. GitHub stays personal. |
| `kclaude --full` | full work Claude config dir (memory, skills, hooks) |
| `kclaude --gh` | also switch gh config + git identity + push auth to the work account |

Flags combine, e.g. `kclaude --full --gh`. The lite config dir has its own
login — run `kclaude` once and `/login`. Add `.claude/memory/` to a project's
gitignore so lite memory isn't committed.
