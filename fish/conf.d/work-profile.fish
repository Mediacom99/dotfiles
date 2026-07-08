# ─────────────────────────────────────────────────────────────────────────────
# work-profile.fish — per-directory work/personal profile switcher for fish.
#
# When cwd is under a configured work root, exports a "work" profile:
#   CLAUDE_CONFIG_DIR   Claude Code config dir
#   GH_CONFIG_DIR       gh CLI config dir
#   GIT_AUTHOR/COMMITTER_NAME/EMAIL   commit identity
#   GIT_CONFIG_* (work only)          route git push/fetch auth through gh, so a
#                                     bare `git push` uses the work token rather
#                                     than the default keychain (personal) one
# Personal everywhere else.
#
# All machine-specific values live in a LOCAL, gitignored file so this snippet
# is safe in a public repo. Copy work-profile.local.fish.example to
# ~/.config/fish/work-profile.local.fish and fill it in. With no local file
# present, this is a NO-OP and nothing switches.
#
# Disable for a session:   set -gx WORKPROF_DISABLE 1
# Inspect current profile: echo $WORKPROF_ACTIVE
# ─────────────────────────────────────────────────────────────────────────────

if set -q WORKPROF_DISABLE
    exit 0
end

# Load machine-local specifics (paths, identities). Not in the repo.
test -f "$HOME/.config/fish/work-profile.local.fish"
and source "$HOME/.config/fish/work-profile.local.fish"

# No local config -> no-op: leave the environment exactly as it is.
if not set -q WORKPROF_ROOT
    exit 0
end

function __workprof_for_dir --argument-names dir
    switch "$dir"
        case "$WORKPROF_ROOT" "$WORKPROF_ROOT/"\*
            echo work
        case '*'
            echo personal
    end
end

function __workprof_apply --argument-names profile
    test "$WORKPROF_ACTIVE" = "$profile"; and return

    switch "$profile"
        case work
            set -gx CLAUDE_CONFIG_DIR "$WORKPROF_CLAUDE_DIR"
            set -gx GH_CONFIG_DIR "$WORKPROF_GH_DIR"
            set -gx GIT_AUTHOR_NAME "$WORKPROF_GIT_NAME"
            set -gx GIT_COMMITTER_NAME "$WORKPROF_GIT_NAME"
            set -gx GIT_AUTHOR_EMAIL "$WORKPROF_GIT_EMAIL"
            set -gx GIT_COMMITTER_EMAIL "$WORKPROF_GIT_EMAIL"
            # Reset the git credential-helper list, then point it at gh, so a
            # bare `git push` authenticates as the work account (via GH_CONFIG_DIR)
            # instead of falling through to the default keychain (personal).
            set -gx GIT_CONFIG_COUNT 2
            set -gx GIT_CONFIG_KEY_0 credential.helper
            set -gx GIT_CONFIG_VALUE_0 ""
            set -gx GIT_CONFIG_KEY_1 credential.helper
            set -gx GIT_CONFIG_VALUE_1 "!gh auth git-credential"
        case '*' # personal
            set -gx CLAUDE_CONFIG_DIR "$WORKPROF_PERSONAL_CLAUDE_DIR"
            set -gx GH_CONFIG_DIR "$WORKPROF_PERSONAL_GH_DIR"
            set -gx GIT_AUTHOR_NAME "$WORKPROF_PERSONAL_GIT_NAME"
            set -gx GIT_COMMITTER_NAME "$WORKPROF_PERSONAL_GIT_NAME"
            set -gx GIT_AUTHOR_EMAIL "$WORKPROF_PERSONAL_GIT_EMAIL"
            set -gx GIT_COMMITTER_EMAIL "$WORKPROF_PERSONAL_GIT_EMAIL"
            set -e GIT_CONFIG_COUNT
            set -e GIT_CONFIG_KEY_0
            set -e GIT_CONFIG_VALUE_0
            set -e GIT_CONFIG_KEY_1
            set -e GIT_CONFIG_VALUE_1
    end

    set -gx WORKPROF_ACTIVE "$profile"

    if status is-interactive
        set -l shown personal
        test "$profile" = work; and set shown (set -q WORKPROF_LABEL; and echo "$WORKPROF_LABEL"; or echo work)
        switch "$profile"
            case work
                set_color 8b5cf6 2>/dev/null; or set_color magenta
            case '*'
                set_color 10b981 2>/dev/null; or set_color green
        end
        echo "⬢ profile: $shown" >&2
        set_color normal
    end
end

function __workprof_hook --on-variable PWD
    __workprof_apply (__workprof_for_dir "$PWD")
end

__workprof_apply (__workprof_for_dir "$PWD")
