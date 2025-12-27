#!/usr/bin/env bash

__git_prompt() {
    git rev-parse --is-inside-work-tree &>/dev/null || return
    
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "detached")
    
    local status=""
    git diff --quiet --ignore-submodules -- 2>/dev/null || status="${status}*"
    git diff --cached --quiet --ignore-submodules -- 2>/dev/null || status="${status}+"
    [ -n "$(git ls-files --others --exclude-standard 2>/dev/null)" ] && status="${status}?"
    
    local color='\033[38;5;108m'
    [ -n "$status" ] && color='\033[38;5;180m'
    [ "$branch" = "detached" ] && color='\033[38;5;183m'
    
    echo -e " \033[38;5;246m(\033[0m${color}${branch}${status}\033[38;5;246m)\033[0m"
}

__prompt_command() {
    local exit=$?
    local display_cwd

    if [[ "$PWD" == "$HOME" ]]; then
        display_cwd="~"
    else
        if git rev-parse --is-inside-work-tree &>/dev/null; then
            local git_root
            git_root=$(git rev-parse --show-toplevel 2>/dev/null || true)
            if [[ -n "$git_root" ]]; then
                display_cwd="$(basename "$git_root")"
            else
                display_cwd="$(basename "$PWD")"
            fi
        else
            display_cwd="$(basename "$PWD")"
        fi
    fi

    local status_char='\033[38;5;108m▶\033[0m'
    [ $exit -ne 0 ] && status_char='\033[38;5;204m▶\033[0m'

    PS1="\[\033[38;5;111m\]${display_cwd}\[\033[0m\]$(__git_prompt) ${status_char} "
}

PROMPT_COMMAND='__prompt_command'