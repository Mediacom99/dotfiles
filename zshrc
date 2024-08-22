
# The following lines were added by compinstall
zstyle :compinstall filename '/home/edoardo/.zshrc'

autoload -Uz compinit
fpath+=~/.zfunc
compinit
# End of lines added by compinstall
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt extendedglob
unsetopt beep nomatch
bindkey -e
# End of lines configured by zsh-newuser-install

# Personal configuration

alias grep='grep --color=auto'
alias ls='ls --color=auto'
alias ll='ls -lah --color=auto'
alias la='ls -ah --color=auto'
alias poweroff='sudo systemctl poweroff'
alias reboot='sudo systemctl reboot'

export XDG_CONFIG_HOME="${HOME}/.config"
export TERM=alacritty
export PATH=${PATH}:/home/edoardo/.config/emacs/bin
