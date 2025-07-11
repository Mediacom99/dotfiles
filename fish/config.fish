if status is-interactive
    # Commands to run in interactive sessions can go here
end

bind \cg zx-hook
set -U fish_history_max_size 100000
set fish_greeting

# # Append to PATH
fish_add_path --path /home/mediacom/zig-x86_64-linux-0.14.1 || true
fish_add_path --path /opt/homebrew/bin || true

# Aliases
alias f="nvim"
alias lg="lazygit"
alias grep='grep --color=auto'
alias ls='eza -l --icons --time-style=long-iso --group-directories-first --sort=size'
alias la='eza -lah --icons --time-style=long-iso --group-directories-first --sort=size'
alias lt='eza -la --tree -L 2 --icons --time-style=long-iso --group-directories-first --sort=size'
alias ltn='eza -lah --tree --icons --time-style=long-iso --group-directories-first --sort=size'

# Export variables
set -gx SHELL fish
set -gx EDITOR nvim

