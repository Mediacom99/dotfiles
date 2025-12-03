if status is-interactive
    # Commands to run in interactive sessions can go here
end

bind \cg zx-hook
set -U fish_history_max_size 100000
set fish_greeting

function f
    command /usr/bin/nvim $argv
end

function lg
    command /usr/bin/lazygit $argv
end

function grep
    command grep --color=auto $argv
end

function ls
    # eza -l --icons --time-style=long-iso --group-directories-first --sort=size $argv
    command ls -lh --color=auto $argv
end

function la
    # eza -lah --icons --time-style=long-iso --group-directories-first --sort=size $argv
    command ls -lah --color=auto $argv
end

function lt
    command eza -la --tree -L 2 --icons --time-style=long-iso --group-directories-first --sort=size $argv
end

function ltn
    command eza -lah --tree --icons --time-style=long-iso --group-directories-first --sort=size $argv
end

function update
    command yay -Syu $argv
end

function download
    command yay -Sy $argv
end

# Export variables
set -gx SHELL /usr/bin/fish
set -gx XDG_CONFIG_HOME /home/mediacom/.config
set -gx XDG_CACHE_HOME /home/mediacom/.cache
set -gx EDITOR nvim

# Append to PATH
fish_add_path --path /home/mediacom/zig-x86_64-linux-0.14.1 || true
fish_add_path --path /home/mediacom/.yarn/bin || true

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
