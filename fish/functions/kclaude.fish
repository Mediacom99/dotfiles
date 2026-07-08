function kclaude --description 'Launch Claude Code on the work account in ANY folder (default: lite, project-local memory; personal stays the shell default)'
    # Generic per-invocation launcher. Machine-specific values come from
    # ~/.config/fish/work-profile.local.fish (see work-profile.local.fish.example).
    # Child-scoped via env(1): your shell and other terminals are untouched, so
    # bare `claude` / `gh` stay personal.
    #
    #   kclaude            LITE work config dir; no work memory/skills/hooks;
    #                      session memory -> <project-root>/.claude/memory; GitHub personal
    #   kclaude --full     full work config dir
    #   kclaude --gh       add work GitHub (gh config + git identity + push auth)
    #   flags combine, e.g.  kclaude --full --gh

    test -f "$HOME/.config/fish/work-profile.local.fish"
    and source "$HOME/.config/fish/work-profile.local.fish"
    if not set -q WORKPROF_CLAUDE_LITE_DIR
        echo "kclaude: no work profile configured — create ~/.config/fish/work-profile.local.fish (see the .example)" >&2
        return 1
    end

    set -l use_gh 0
    set -l use_full 0
    set -l rest
    for a in $argv
        switch $a
            case --gh -g
                set use_gh 1
            case --full -f
                set use_full 1
            case -h --help
                echo "kclaude [--full] [--gh] [claude args...]"
                echo "  (default)   LITE work account; memory -> <project-root>/.claude/memory; GitHub personal"
                echo "  --full, -f  full work Claude config dir"
                echo "  --gh, -g    also use work gh config + git identity + push auth"
                return 0
            case '*'
                set -a rest $a
        end
    end

    set -l note ""
    set -l pairs
    set -l unsets
    set -l preargs

    # --- Claude config dir: lite (default) or full ---
    if test $use_full -eq 1
        set -a pairs CLAUDE_CONFIG_DIR="$WORKPROF_CLAUDE_DIR"
        set note "full work config"
    else
        set -a pairs CLAUDE_CONFIG_DIR="$WORKPROF_CLAUDE_LITE_DIR"
        # Route auto-memory into the launch project's own folder (absolute path,
        # computed now). Prefer the git root so worktrees/subdirs of one repo
        # share a memory dir; fall back to cwd for non-repo folders.
        set -l projroot (command git -C "$PWD" rev-parse --show-toplevel 2>/dev/null)
        test -n "$projroot"; or set projroot "$PWD"
        set -a preargs --settings "{\"autoMemoryDirectory\": \"$projroot/.claude/memory\"}"
        set note "lite (work account; memory -> $projroot/.claude/memory)"
    end

    # --- GitHub side: personal (default) or work (--gh) ---
    if test $use_gh -eq 1
        set -a pairs GH_CONFIG_DIR="$WORKPROF_GH_DIR"
        set -a pairs GIT_AUTHOR_NAME="$WORKPROF_GIT_NAME" GIT_COMMITTER_NAME="$WORKPROF_GIT_NAME"
        set -a pairs GIT_AUTHOR_EMAIL="$WORKPROF_GIT_EMAIL" GIT_COMMITTER_EMAIL="$WORKPROF_GIT_EMAIL"
        set -a pairs GIT_CONFIG_COUNT=2
        set -a pairs GIT_CONFIG_KEY_0=credential.helper GIT_CONFIG_VALUE_0=""
        set -a pairs GIT_CONFIG_KEY_1=credential.helper GIT_CONFIG_VALUE_1="!gh auth git-credential"
        set note "$note + work GitHub"
    else
        set -a pairs GH_CONFIG_DIR="$WORKPROF_PERSONAL_GH_DIR"
        set -a pairs GIT_AUTHOR_NAME="$WORKPROF_PERSONAL_GIT_NAME" GIT_COMMITTER_NAME="$WORKPROF_PERSONAL_GIT_NAME"
        set -a pairs GIT_AUTHOR_EMAIL="$WORKPROF_PERSONAL_GIT_EMAIL" GIT_COMMITTER_EMAIL="$WORKPROF_PERSONAL_GIT_EMAIL"
        set -a unsets GIT_CONFIG_COUNT GIT_CONFIG_KEY_0 GIT_CONFIG_VALUE_0 GIT_CONFIG_KEY_1 GIT_CONFIG_VALUE_1
        set note "$note + GitHub personal"
    end

    set -l unsetflags
    for v in $unsets
        set -a unsetflags -u $v
    end

    if status is-interactive
        set_color 8b5cf6 2>/dev/null; or set_color magenta
        echo "⬢ kclaude: $note — this launch only, cwd=$PWD" >&2
        set_color normal
    end

    env $unsetflags $pairs claude $preargs $rest
end
