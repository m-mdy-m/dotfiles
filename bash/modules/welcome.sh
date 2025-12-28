#!/usr/bin/env bash

_show_banner() {
    local quotes=(
        "Ship fast, break things, fix faster"
        "Code is poetry written in logic"
        "Simplicity is the ultimate sophistication"
        "Make it work, make it right, make it fast"
        "The best code is no code at all"
        "Debugging: the art of removing bugs you added while debugging"
        "There are only two hard things: cache invalidation and naming things"
        "Talk is cheap. Show me the code"
        "Any fool can write code that a computer can understand"
        "First, solve the problem. Then, write the code"
        "Code never lies, comments sometimes do"
        "Premature optimization is the root of all evil"
        "Good code is its own best documentation"
        "Programs must be written for people to read"
        "The only way to go fast is to go well"
    )
    
    local mem_used mem_total mem_percent disk_usage uptime_str time_str
    local git_info docker_info load_avg
    
    # System info
    read mem_used mem_total <<< $(LC_ALL=C free -m | awk 'NR==2 {print int($3), int($2)}')
    mem_percent=$((mem_used * 100 / mem_total))
    disk_usage=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')
    uptime_str=$(uptime -p 2>/dev/null | sed 's/up //' | sed 's/ hours\?/h/g' | sed 's/ minutes\?/m/g' | sed 's/ days\?/d/g' | sed 's/,//g')
    time_str=$(date '+%H:%M')
    load_avg=$(uptime | grep -oP 'load average: \K[0-9.]+' | head -1)
    
    # Git info
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
        local status=""
        git diff-index --quiet HEAD -- 2>/dev/null || status="*"
        git_info="  $branch$status"
    fi
    
    # Docker info
    if command -v docker &>/dev/null && docker ps &>/dev/null 2>&1; then
        local containers=$(docker ps -q 2>/dev/null | wc -l)
        [[ $containers -gt 0 ]] && docker_info=" 󰡨 $containers"
    fi
    
    # Random quote
    local quote="${quotes[$RANDOM % ${#quotes[@]}]}"
    
    # Color definitions
    local c_reset='\033[0m'
    local c_dim='\033[2m'
    local c_gray='\033[38;5;240m'
    local c_blue='\033[38;5;75m'
    local c_cyan='\033[38;5;87m'
    local c_green='\033[38;5;108m'
    local c_yellow='\033[38;5;222m'
    local c_red='\033[38;5;204m'
    
    # Status colors based on usage
    local mem_color="$c_green"
    [[ $mem_percent -gt 70 ]] && mem_color="$c_yellow"
    [[ $mem_percent -gt 85 ]] && mem_color="$c_red"
    
    local disk_color="$c_green"
    [[ $disk_usage -gt 70 ]] && disk_color="$c_yellow"
    [[ $disk_usage -gt 85 ]] && disk_color="$c_red"
    
    # Build info line
    local info_parts=(
        "${c_gray}${time_str}${c_reset}"
        "${c_dim}${uptime_str}${c_reset}"
        "${mem_color}${mem_used}M${c_reset}${c_gray}/${c_reset}${c_dim}${mem_total}M${c_reset}"
        "${disk_color}${disk_usage}%${c_reset}"
    )
    
    [[ -n "$load_avg" ]] && info_parts+=("${c_cyan}${load_avg}${c_reset}")
    [[ -n "$git_info" ]] && info_parts+=("${c_green}${git_info}${c_reset}")
    [[ -n "$docker_info" ]] && info_parts+=("${c_blue}${docker_info}${c_reset}")
    
    clear
    echo
    echo -e "  ${c_blue}$USER${c_reset}${c_gray}@${c_reset}${c_dim}$(hostname)${c_reset}"
    echo
    
    # Print info parts separated by dots
    local first=true
    for part in "${info_parts[@]}"; do
        if [[ "$first" == true ]]; then
            echo -en "  $part"
            first=false
        else
            echo -en " ${c_gray}·${c_reset} $part"
        fi
    done
    echo
    echo
    echo -e "  ${c_dim}${quote}${c_reset}"
    echo
}

_show_banner