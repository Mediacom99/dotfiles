if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -U fish_history_max_size 100000
set fish_greeting
bind \cg zx-hook

# Append to PATH
# fish_add_path --path /home/mediacom/zig-x86_64-linux-0.14.1 || true
fish_add_path /opt/homebrew/bin
fish_add_path --path /opt/homebrew/bin || true
fish_add_path --path /opt/homebrew/sbin || true
fish_add_path --path /opt/homebrew/opt/binutils/bin || true

# fish_add_path /opt/homebrew/opt/curl/bin
# fish_add_path /opt/homebrew/opt/binutils/bin
# fish_add_path /opt/homebrew/opt/ccache/libexec
fish_add_path $HOME/.local/bin
fish_add_path $HOME/go/bin
fish_add_path /opt/homebrew/opt/libpq/bin

# ESP_IDF
fish_add_path /opt/homebrew/opt/ccache/libexec

# Bun setup
# set -gx BUN_INSTALL "$HOME/.bun"
# fish_add_path $BUN_INSTALL/bin

# Aliases
alias f="nvim"
alias lg="lazygit"
alias grep='grep --color=auto'
alias ls='ls -lh --color=auto'
alias la='ls -falh --color=auto'
alias code "open -a 'Visual Studio Code'"
alias read-once "$HOME/.claude/read-once/read-once"
# alias ls='eza -l --icons --time-style=long-iso --group-directories-first --sort=size'
# alias la='eza -lah --icons --time-style=long-iso --group-directories-first --sort=size'
# alias lt='eza -la --tree -L 2 --icons --time-style=long-iso --group-directories-first --sort=size'
# alias ltn='eza -lah --tree --icons --time-style=long-iso --group-directories-first --sort=size'

# Export variables
set -gx SHELL fish
set -gx EDITOR nvim
set -gx XDG_CONFIG_HOME $HOME/.config


# set -gx LDFLAGS "-L/opt/homebrew/opt/binutils/lib"
# set -gx CPPFLAGS "-I/opt/homebrew/opt/binutils/include"


# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :

# kimi-code
fish_add_path -g "$HOME/.kimi-code/bin"

# App Store Connect credentials for fastlane (splitto-app). The values live
# outside this repo — it is public — next to the .p8 key they authenticate with.
test -f ~/.appstoreconnect/env.fish; and source ~/.appstoreconnect/env.fish

# Scaleway CLI autocomplete initialization.
command -q scw; and eval (scw autocomplete script shell=fish)
