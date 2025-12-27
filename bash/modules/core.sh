#!/usr/bin/env bash
shopt -s histappend checkwinsize autocd cdspell dirspell nocaseglob cmdhist histreedit histverify
export HISTCONTROL=ignoreboth:erasedups
export HISTSIZE=50000
export HISTFILESIZE=100000
export HISTTIMEFORMAT='%F %T '
export HISTIGNORE='ls:ll:cd:pwd:bg:fg:history:clear'

# Editor
export EDITOR=vim
export VISUAL=vim
export PAGER=less

export LESS='-R -F -X -i -M'
export LESS_TERMCAP_mb=$'\E[1;31m'
export LESS_TERMCAP_md=$'\E[1;36m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_us=$'\E[1;32m'
export LESS_TERMCAP_ue=$'\E[0m'

# GPG configuration
export GPG_TTY=$(tty)

export TERM=xterm-256color
export COLORTERM=truecolor

if [[ -d "$HOME/.local/bin" ]] && [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

if [[ -d "$HOME/bin" ]] && [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
    export PATH="$HOME/bin:$PATH"
fi

set -o vi

stty -ixon