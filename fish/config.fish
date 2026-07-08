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
fish_add_path /Users/edoardo/.local/bin
fish_add_path /Users/edoardo/go/bin
fish_add_path /opt/homebrew/opt/libpq/bin
fish_add_path /Users/edoardo/.local/state/fnm_multishells/5942_1767797492604/bin

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
alias read-once "/Users/edoardo/.claude/read-once/read-once"
# alias ls='eza -l --icons --time-style=long-iso --group-directories-first --sort=size'
# alias la='eza -lah --icons --time-style=long-iso --group-directories-first --sort=size'
# alias lt='eza -la --tree -L 2 --icons --time-style=long-iso --group-directories-first --sort=size'
# alias ltn='eza -lah --tree --icons --time-style=long-iso --group-directories-first --sort=size'

# Export variables
set -gx SHELL fish
set -gx EDITOR nvim
set -gx XDG_CONFIG_HOME $HOME/.config

# FNM node version manager
set -gx PATH "/Users/edoardo/.local/state/fnm_multishells/86196_1774862958801/bin" $PATH;
set -gx FNM_MULTISHELL_PATH "/Users/edoardo/.local/state/fnm_multishells/86196_1774862958801";
set -gx FNM_VERSION_FILE_STRATEGY "local";
set -gx FNM_DIR "/Users/edoardo/.local/share/fnm";
set -gx FNM_LOGLEVEL "info";
set -gx FNM_NODE_DIST_MIRROR "https://nodejs.org/dist";
set -gx FNM_COREPACK_ENABLED "false";
set -gx FNM_RESOLVE_ENGINES "true";
set -gx FNM_ARCH "arm64";

# set -gx LDFLAGS "-L/opt/homebrew/opt/binutils/lib"
# set -gx CPPFLAGS "-I/opt/homebrew/opt/binutils/include"


# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :
