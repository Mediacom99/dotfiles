if status is-interactive
    # Commands to run in interactive sessions can go here
end

bind \cg zx-hook
set -U fish_history_max_size 100000
set fish_greeting

function f
    /usr/bin/nvim $argv
end

function lg
    /usr/bin/lazygit $argv
end

function grep
    command grep --color=auto $argv
end

function ls
    eza -l --icons --time-style=long-iso --group-directories-first --sort=size $argv
end

function la
    eza -lah --icons --time-style=long-iso --group-directories-first --sort=size $argv
end

function lt
    eza -la --tree -L 2 --icons --time-style=long-iso --group-directories-first --sort=size $argv
end

function ltn
    eza -lah --tree --icons --time-style=long-iso --group-directories-first --sort=size $argv
end

function update
    yay -Syu $argv
end

# Export variables
set -gx SHELL /usr/bin/fish
set -gx XDG_CONFIG_HOME /home/mediacom/.config
set -gx XDG_CACHE_HOME /home/mediacom/.cache
set -gx EDITOR nvim

# Append to PATH
fish_add_path --path /home/mediacom/zig-x86_64-linux-0.14.1 || true
