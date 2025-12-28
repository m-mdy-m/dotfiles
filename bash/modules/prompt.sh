#!/usr/bin/env bash

__git_status() {
    git rev-parse --is-inside-work-tree &>/dev/null || return
    
    local branch symbols="" ahead=0 behind=0
    branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "detached")
    
    # Check for uncommitted changes
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
    if git rev-parse --verify refs/stash &>/dev/null 2>&1; then
        symbols="${symbols}$"
    fi
    
    # Check ahead/behind
    if [[ "$branch" != "detached" ]]; then
        local upstream=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)
        if [[ -n "$upstream" ]]; then
            local counts=$(git rev-list --left-right --count HEAD...$upstream 2>/dev/null)
            ahead=$(echo "$counts" | cut -f1)
            behind=$(echo "$counts" | cut -f2)
            
            [[ $ahead -gt 0 ]] && symbols="${symbols}↑${ahead}"
            [[ $behind -gt 0 ]] && symbols="${symbols}↓${behind}"
        fi
    fi
    
    # Choose color based on status
    local color='\[\033[38;5;108m\]'  # green
    [[ -n "$symbols" ]] && color='\[\033[38;5;180m\]'  # yellow
    [[ "$branch" == "detached" ]] && color='\[\033[38;5;204m\]'  # red
    
    echo -e " \[\033[38;5;240m\](\[\033[0m\]${color}${branch}${symbols}\[\033[38;5;240m\])\[\033[0m\]"
}

__jobs_count() {
    local count=$(jobs -r | wc -l)
    [[ $count -gt 0 ]] && echo -e " \[\033[38;5;240m\][${count}]\[\033[0m\]"
}

__build_prompt() {
    local exit_code=$?
    
    # Determine directory to show
    local display_dir
    if [[ "$PWD" == "$HOME" ]]; then
        display_dir="~"
    elif git rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
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
    
    # Symbol based on exit code
    local symbol
    if [[ $exit_code -eq 0 ]]; then
        symbol='\[\033[38;5;108m\]›\[\033[0m\]'
    else
        symbol='\[\033[38;5;204m\]›\[\033[0m\]'
    fi
    
    # Build PS1 with proper non-printing character wrapping
    PS1="\[\033[38;5;75m\]${display_dir}\[\033[0m\]"
    PS1+="$(__git_status)"
    PS1+="$(__jobs_count)"
    PS1+=" ${symbol} "
}

PROMPT_COMMAND='__build_prompt'