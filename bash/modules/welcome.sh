#!/usr/bin/env bash

_get_system_info() {
    local mem_info disk_usage uptime_info distro current_time git_branch docker_info
    
    mem_info=$(free -h 2>/dev/null | awk 'NR==2 {printf "%s/%s", $3, $2}')
    disk_usage=$(df -h / 2>/dev/null | awk 'NR==2 {print $5}')
    uptime_info=$(uptime -p 2>/dev/null | sed 's/up //' | sed 's/ day/d/g' | sed 's/ hour/h/g' | sed 's/ minute/m/g' | awk '{print $1$2$3$4}')
    distro=$(cat /etc/os-release 2>/dev/null | grep "^NAME=" | cut -d'"' -f2 | awk '{print $1}')
    current_time=$(date '+%H:%M')
    
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        git_branch="⎇ $(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
    fi
    
    if command -v docker &> /dev/null && docker ps &> /dev/null; then
        local docker_count=$(docker ps -q 2>/dev/null | wc -l)
        docker_info="󰡨 $docker_count"
    fi
    
    echo "$mem_info|$disk_usage|$uptime_info|$distro|$current_time|$git_branch|$docker_info"
}

_show_banner() {
    local quotes=(
        "Write code nobody will read. Commit anyway."
        "Your bugs are features in an alternate universe."
        "The best code is the one you delete."
        "Debugging: Being a detective in a crime you committed."
        "Code like nobody's watching. Because they're not."
        "Your prod is someone's nightmare. Ship it."
        "Perfect code doesn't exist. Ship the chaos."
        "Every error is a feature in disguise."
        "The only winning move is not to deploy on Friday."
        "git push --force and hope for the best."
        "In production, everything is legacy code."
        "There are no bugs, only undocumented features."
        "Code review is where dreams go to die."
        "Tests are for the weak. Real devs debug in production."
        "Tabs vs Spaces: The eternal struggle."
    )
    
    local random_quote="${quotes[$RANDOM % ${#quotes[@]}]}"
    local info=$(_get_system_info)
    
    IFS='|' read -r mem disk uptime distro time git docker <<< "$info"
    
    clear
    echo
    echo -e "${colors[blue]}  ╭────────────────────────────────────────────╮${colors[reset]}"
    echo -e "${colors[blue]}  │${colors[reset]}  ${colors[green]}Welcome back, ${colors[bold]}$USER${colors[reset]} ${colors[yellow]}⚡${colors[reset]}              ${colors[blue]}│${colors[reset]}"
    echo -e "${colors[blue]}  ╰────────────────────────────────────────────╯${colors[reset]}"
    echo
    echo -e "  ${colors[cyan]}●${colors[reset]} ${colors[white]}$distro${colors[reset]} ${colors[gray]}•${colors[reset]} ${colors[white]}$time${colors[reset]} ${colors[gray]}•${colors[reset]} ${colors[dim]}RAM $mem${colors[reset]}"
    echo -e "  ${colors[yellow]}●${colors[reset]} ${colors[dim]}Disk $disk${colors[reset]} ${colors[gray]}•${colors[reset]} ${colors[dim]}Uptime $uptime${colors[reset]}"
    
    [ -n "$git" ] && echo -e "  ${colors[green]}●${colors[reset]} ${colors[white]}$git${colors[reset]}"
    [ -n "$docker" ] && echo -e "  ${colors[blue]}●${colors[reset]} ${colors[white]}$docker${colors[reset]}"
    
    echo
    echo -e "  ${colors[gray]}\"${colors[reset]}${colors[dim]}$random_quote${colors[reset]}${colors[gray]}\"${colors[reset]}"
    echo
}

_show_banner