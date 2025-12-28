#!/usr/bin/env bash

# ── Shell Options ────────────────────────────────────────────────────
shopt -s histappend
shopt -s checkwinsize
shopt -s autocd     
shopt -s cdspell    
shopt -s dirspell   
shopt -s nocaseglob 
shopt -s cmdhist    
shopt -s histreedit 
shopt -s histverify 
shopt -s dotglob    
shopt -s extglob    
shopt -s globstar   

# ── History Configuration ────────────────────────────────────────────
export HISTCONTROL=ignoreboth:erasedups
export HISTSIZE=50000
export HISTFILESIZE=100000
export HISTTIMEFORMAT='%F %T  '
export HISTIGNORE='ls:ll:la:cd:pwd:bg:fg:history:clear:exit:q'
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

# ── Editor Configuration ─────────────────────────────────────────────
if command -v vim &>/dev/null; then
    export EDITOR=vim
    export VISUAL=vim
else
    export EDITOR=vi
    export VISUAL=vi
fi

# ── Pager Configuration ──────────────────────────────────────────────
export PAGER=less
export LESS='-R -F -X -i -M -g'
export LESS_TERMCAP_mb=$'\E[1;31m'  
export LESS_TERMCAP_md=$'\E[1;36m'    
export LESS_TERMCAP_me=$'\E[0m'       
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_se=$'\E[0m'       
export LESS_TERMCAP_us=$'\E[1;32m'    
export LESS_TERMCAP_ue=$'\E[0m'       

# ── Terminal Configuration ───────────────────────────────────────────
export TERM=xterm-256color
export COLORTERM=truecolor
export CLICOLOR=1
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'

# ── Language Configuration ───────────────────────────────────────────
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

# ── Path Configuration ───────────────────────────────────────────────
add_to_path() {
    if [[ -d "$1" ]] && [[ ":$PATH:" != *":$1:"* ]]; then
        export PATH="$1:$PATH"
    fi
}

# Essential paths
add_to_path "$HOME/.local/bin"
add_to_path "$HOME/bin"

export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh" --no-use

# Rust
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# ── GPG Configuration ────────────────────────────────────────────────
export GPG_TTY=$(tty)

# ── Key Bindings ─────────────────────────────────────────────────────
set -o vi                     # Vi mode in shell
stty -ixon                    # Disable Ctrl-S and Ctrl-Q

# ── Completion ───────────────────────────────────────────────────────
[[ -f /etc/bash_completion ]] && source /etc/bash_completion
[[ -f /usr/share/bash-completion/bash_completion ]] && source /usr/share/bash-completion/bash_completion

# Git completion
if [[ -f /usr/share/bash-completion/completions/git ]]; then
    source /usr/share/bash-completion/completions/git
fi

# ── FZF Configuration ────────────────────────────────────────────────
if command -v fzf &>/dev/null; then
    export FZF_DEFAULT_OPTS="
        --color=bg+:#1a1a1a,bg:#0a0a0a,border:#1a1a1a,spinner:#6c6c6c
        --color=hl:#a8a8a8,fg:#808080,header:#6c6c6c,info:#6c6c6c
        --color=marker:#a8a8a8,fg+:#a8a8a8,prompt:#6c6c6c,pointer:#a8a8a8
        --color=hl+:#ffffff
        --layout=reverse
        --border=rounded
        --height=40%
    "
    
    # Use fd or find
    if command -v fd &>/dev/null; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
    else
        export FZF_DEFAULT_COMMAND='find . -type f ! -path "*/\\.git/*"'
    fi
    
    # Load fzf keybindings
    [[ -f ~/.fzf.bash ]] && source ~/.fzf.bash
    [[ -f /usr/share/doc/fzf/examples/key-bindings.bash ]] && source /usr/share/doc/fzf/examples/key-bindings.bash
fi

# ── Docker ───────────────────────────────────────────────────────────
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# ── Development Tools ────────────────────────────────────────────────
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/config"
export BAT_THEME="base16"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"