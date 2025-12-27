#!/usr/bin/env bash

declare -gA colors=(
    [reset]='\033[0m'
    [bold]='\033[1m'
    [dim]='\033[2m'
    [italic]='\033[3m'
    [underline]='\033[4m'
    [blink]='\033[5m'
    [reverse]='\033[7m'
    [hidden]='\033[8m'
    
    [black]='\033[0;30m'
    [red]='\033[0;31m'
    [green]='\033[0;32m'
    [yellow]='\033[0;33m'
    [blue]='\033[0;34m'
    [magenta]='\033[0;35m'
    [cyan]='\033[0;36m'
    [white]='\033[0;37m'
    [gray]='\033[0;90m'
    
    [bred]='\033[1;31m'
    [bgreen]='\033[1;32m'
    [byellow]='\033[1;33m'
    [bblue]='\033[1;34m'
    [bmagenta]='\033[1;35m'
    [bcyan]='\033[1;36m'
    [bwhite]='\033[1;37m'
    
    [bg_black]='\033[40m'
    [bg_red]='\033[41m'
    [bg_green]='\033[42m'
    [bg_yellow]='\033[43m'
    [bg_blue]='\033[44m'
    [bg_magenta]='\033[45m'
    [bg_cyan]='\033[46m'
    [bg_white]='\033[47m'
)

colorize() {
    local color="$1"
    shift
    echo -e "${colors[$color]}$*${colors[reset]}"
}

export -f colorize