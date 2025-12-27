#!/usr/bin/env bash

[[ $- != *i* ]] && return

BASH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$BASH_DIR/core.sh"
source "$BASH_DIR/colors.sh"
source "$BASH_DIR/prompt.sh"
source "$BASH_DIR/aliases.sh"
source "$BASH_DIR/functions.sh"

if [ -n "$PS1" ]; then
    mem=$(free -h 2>/dev/null | awk 'NR==2 {print $3"/"$2}')
    load=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | tr -d ',')
    
    clear
    echo -e "\033[38;5;111m  Welcome back, \033[1m$(whoami)\033[0m"
    echo -e "\033[38;5;246m  RAM $mem • Load $load\033[0m"
    echo
fi