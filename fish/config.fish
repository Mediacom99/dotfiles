if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -U fish_history_max_size 100000
set fish_greeting
bind \cg zx-hook

# Append to PATH
fish_add_path --path /home/mediacom/zig-x86_64-linux-0.14.1 || true
fish_add_path --path /opt/homebrew/bin || true
fish_add_path --path /opt/homebrew/sbin || true

fish_add_path /opt/homebrew/opt/postgresql@17/bin
fish_add_path /opt/homebrew/opt/curl/bin
fish_add_path /opt/homebrew/opt/binutils/bin
fish_add_path /opt/homebrew/opt/ccache/libexec

# Bun setup
set -gx BUN_INSTALL "$HOME/.bun"
fish_add_path $BUN_INSTALL/bin

# Aliases
alias f="nvim"
alias lg="lazygit"
alias grep='grep --color=auto'
alias ls='eza -l --icons --time-style=long-iso --group-directories-first --sort=size'
alias la='eza -lah --icons --time-style=long-iso --group-directories-first --sort=size'
alias lt='eza -la --tree -L 2 --icons --time-style=long-iso --group-directories-first --sort=size'
alias ltn='eza -lah --tree --icons --time-style=long-iso --group-directories-first --sort=size'
alias brave='/Applications/Brave\ Browser.app/Contents/MacOS/Brave\ Browser'

# Export variables
set -gx SHELL fish
set -gx EDITOR nvim

