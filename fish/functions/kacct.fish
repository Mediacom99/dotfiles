function kacct --description 'Pick the work Claude account for this shell: kacct 1|2 (no arg: show current)'
    test -f "$HOME/.config/fish/work-profile.local.fish"
    and source "$HOME/.config/fish/work-profile.local.fish"
    switch "$argv[1]"
        case 1
            set -gx WORKPROF_ACCT ""
        case 2
            set -gx WORKPROF_ACCT "-2"
        case ''
        case '*'
            echo "kacct 1|2" >&2
            return 1
    end
    set -gx CLAUDE_CONFIG_DIR "$WORKPROF_CLAUDE_DIR$WORKPROF_ACCT"
    set -l email (python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("oauthAccount",{}).get("emailAddress","<not logged in>"))' "$CLAUDE_CONFIG_DIR/.claude.json" 2>/dev/null)
    echo "⬢ account: $email ($CLAUDE_CONFIG_DIR)" >&2
end
