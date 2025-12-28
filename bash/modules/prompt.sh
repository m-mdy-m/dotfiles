#!/usr/bin/env bash

__git_status() {
    git rev-parse --is-inside-work-tree &>/dev/null || return
    
    local branch status symbols=""
    branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "detached")
    
    # Check for changes
    if ! git diff --quiet 2>/dev/null; then
        symbols="${symbols}*"
    fi
    
    # Check for staged changes
    if ! git diff --cached --quiet 2>/dev/null; then
        symbols="${symbols}+"
    fi
    
    # Check for untracked files
    if [[ -n $(git ls-files --others --exclude-standard 2>/dev/null) ]]; then
        symbols="${symbols}?"
    fi
    
    # Check for stashed changes
    if git rev-parse --verify refs/stash &>/dev/null; then
        symbols="${symbols}$"
    fi
    
    # Choose color based on status
    local color='\033[38;5;108m'  # green
    [[ -n "$symbols" ]] && color='\033[38;5;180m'  # yellow
    [[ "$branch" == "detached" ]] && color='\033[38;5;204m'  # red
    
    echo -e " \033[38;5;240m(\033[0m${color}${branch}${symbols}\033[38;5;240m)\033[0m"
}

__jobs_count() {
    local count=$(jobs -r | wc -l)
    [[ $count -gt 0 ]] && echo -e " \033[38;5;240m[${count}]\033[0m"
}

__prompt_symbol() {
    local exit_code=$?
    if [[ $exit_code -eq 0 ]]; then
        echo -e '\033[38;5;108m›\033[0m'
    else
        echo -e '\033[38;5;204m›\033[0m'
    fi
}

__build_prompt() {
    local exit_code=$?
    
    # Determine directory to show
    local display_dir
    if [[ "$PWD" == "$HOME" ]]; then
        display_dir="~"
    elif git rev-parse --is-inside-work-tree &>/dev/null; then
        local git_root=$(git rev-parse --show-toplevel 2>/dev/null)
        if [[ "$PWD" == "$git_root" ]]; then
            display_dir="$(basename "$git_root")"
        else
            local rel_path="${PWD#$git_root/}"
            display_dir="$(basename "$git_root")/$rel_path"
        fi
    else
        display_dir="$(basename "$PWD")"
    fi
    
    # Build PS1
    PS1=""
    PS1+="\[\033[38;5;75m\]${display_dir}\[\033[0m\]"
    PS1+="$(__git_status)"
    PS1+="$(__jobs_count)"
    PS1+=" \$(if [[ \$? -eq 0 ]]; then echo -e '\033[38;5;108m›\033[0m'; else echo -e '\033[38;5;204m›\033[0m'; fi) "
}

PROMPT_COMMAND='__build_prompt'