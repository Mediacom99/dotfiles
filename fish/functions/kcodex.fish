function kcodex --description 'Launch Codex with the work technical or business permission profile'
    # Generic per-invocation launcher, mirroring kclaude. Machine-specific values
    # (root path, subdirectory names, Codex profile names) come from
    # ~/.config/fish/work-profile.local.fish — see work-profile.local.fish.example.
    #
    #   kcodex               profile picked from the current directory
    #   kcodex --technical   force the technical profile
    #   kcodex --business    force the business profile

    test -f "$HOME/.config/fish/work-profile.local.fish"
    and source "$HOME/.config/fish/work-profile.local.fish"

    if not set -q WORKPROF_ROOT; or not set -q WORKPROF_CODEX_TECH_PROFILE
        echo "kcodex: no work profile configured — create ~/.config/fish/work-profile.local.fish (see the .example)" >&2
        return 1
    end

    set -l profile
    set -l rest
    for arg in $argv
        switch $arg
            case --technical -t
                set profile "$WORKPROF_CODEX_TECH_PROFILE"
            case --business -b
                set profile "$WORKPROF_CODEX_BIZ_PROFILE"
            case -h --help
                echo "kcodex [--technical | --business] [codex args...]"
                echo "Without a flag, the profile is selected from the current directory."
                return 0
            case '*'
                set -a rest $arg
        end
    end

    if test -z "$profile"
        switch "$PWD"
            case "$WORKPROF_ROOT/$WORKPROF_TECH_SUBDIR" "$WORKPROF_ROOT/$WORKPROF_TECH_SUBDIR/"\*
                set profile "$WORKPROF_CODEX_TECH_PROFILE"
            case "$WORKPROF_ROOT/$WORKPROF_BIZ_SUBDIR" "$WORKPROF_ROOT/$WORKPROF_BIZ_SUBDIR/"\*
                set profile "$WORKPROF_CODEX_BIZ_PROFILE"
            case '*'
                echo "kcodex: open $WORKPROF_TECH_SUBDIR or $WORKPROF_BIZ_SUBDIR, or pass --technical/--business" >&2
                return 2
        end
    end

    if status is-interactive
        set_color 8b5cf6 2>/dev/null; or set_color magenta
        echo "⬢ kcodex: $profile — cwd=$PWD" >&2
        set_color normal
    end

    command codex --profile $profile $rest
end
