#!/usr/bin/env bash

set -e

# ── Color Definitions ────────────────────────────────────────────────
if [[ -t 1 ]]; then
    readonly RED='\033[0;31m'
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[1;33m'
    readonly BLUE='\033[0;34m'
    readonly MAGENTA='\033[0;35m'
    readonly CYAN='\033[0;36m'
    readonly WHITE='\033[1;37m'
    readonly GRAY='\033[0;90m'
    readonly BOLD='\033[1m'
    readonly DIM='\033[2m'
    readonly RESET='\033[0m'
else
    readonly RED=''
    readonly GREEN=''
    readonly YELLOW=''
    readonly BLUE=''
    readonly MAGENTA=''
    readonly CYAN=''
    readonly WHITE=''
    readonly GRAY=''
    readonly BOLD=''
    readonly DIM=''
    readonly RESET=''
fi

# ── Print Functions ──────────────────────────────────────────────────
print_success() {
    echo -e "${GREEN}✓${RESET} $1"
}

print_error() {
    echo -e "${RED}✗${RESET} $1" >&2
}

print_warning() {
    echo -e "${YELLOW}⚠${RESET} $1"
}

print_info() {
    echo -e "${BLUE}→${RESET} $1"
}

print_step() {
    echo -e "${CYAN}▸${RESET} $1"
}

print_header() {
    local title="$1"
    local width=60
    local padding=$(( (width - ${#title} - 2) / 2 ))
    
    echo
    echo -e "${BLUE}$(printf '═%.0s' $(seq 1 $width))${RESET}"
    printf "${BLUE}═${RESET}%*s${BOLD}%s${RESET}%*s${BLUE}═${RESET}\n" \
        $padding "" "$title" $padding ""
    echo -e "${BLUE}$(printf '═%.0s' $(seq 1 $width))${RESET}"
    echo
}

print_separator() {
    echo -e "${GRAY}────────────────────────────────────────────────────────${RESET}"
}

# ── Spinner Functions ────────────────────────────────────────────────
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    
    while ps -p $pid > /dev/null 2>&1; do
        local temp=${spinstr#?}
        printf " ${BLUE}%c${RESET} " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# ── Prompt Functions ─────────────────────────────────────────────────
confirm() {
    local prompt="$1"
    local default="${2:-n}"
    local response
    
    if [[ "$default" == "y" ]]; then
        prompt="$prompt ${GRAY}[Y/n]${RESET}: "
    else
        prompt="$prompt ${GRAY}[y/N]${RESET}: "
    fi
    
    read -rp "$(echo -e "$prompt")" response
    response="${response:-$default}"
    
    [[ "$response" =~ ^[Yy]$ ]]
}

select_option() {
    local prompt="$1"
    shift
    local options=("$@")
    local selected=0
    local key
    
    # Hide cursor
    tput civis
    
    while true; do
        # Clear and redraw
        clear
        echo -e "${BOLD}$prompt${RESET}"
        echo
        
        for i in "${!options[@]}"; do
            if [[ $i -eq $selected ]]; then
                echo -e "  ${GREEN}▸${RESET} ${BOLD}${options[$i]}${RESET}"
            else
                echo -e "    ${DIM}${options[$i]}${RESET}"
            fi
        done
        
        # Read key
        read -rsn1 key
        
        case "$key" in
            $'\x1b')  # ESC sequence
                read -rsn2 key
                case "$key" in
                    '[A') ((selected > 0)) && ((selected--)) ;;  # Up
                    '[B') ((selected < ${#options[@]} - 1)) && ((selected++)) ;;  # Down
                esac
                ;;
            '') # Enter
                tput cnorm
                echo
                return $selected
                ;;
        esac
    done
}

# ── Utility Functions ────────────────────────────────────────────────
command_exists() {
    command -v "$1" &>/dev/null
}

require_command() {
    if ! command_exists "$1"; then
        print_error "Required command not found: $1"
        return 1
    fi
}

is_git_repo() {
    git rev-parse --git-dir &>/dev/null
}

get_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "$ID"
    else
        uname -s | tr '[:upper:]' '[:lower:]'
    fi
}

get_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "$PRETTY_NAME"
    else
        uname -s
    fi
}

# ── Progress Functions ───────────────────────────────────────────────
progress_bar() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((width * current / total))
    local remaining=$((width - completed))
    
    printf "\r${BLUE}["
    printf "%${completed}s" | tr ' ' '='
    printf "%${remaining}s" | tr ' ' ' '
    printf "]${RESET} %3d%%" $percentage
    
    [[ $current -eq $total ]] && echo
}

# ── File Functions ───────────────────────────────────────────────────
file_exists() {
    [[ -f "$1" ]]
}

dir_exists() {
    [[ -d "$1" ]]
}

link_exists() {
    [[ -L "$1" ]]
}

create_dir() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        print_success "Created directory: $dir"
    fi
}

# ── Backup Functions ─────────────────────────────────────────────────
create_backup() {
    local file="$1"
    local backup_dir="${2:-$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)}"
    
    if [[ -e "$file" ]]; then
        create_dir "$backup_dir"
        cp -r "$file" "$backup_dir/$(basename "$file")"
        print_info "Backed up: $(basename "$file")"
    fi
}

# ── Error Handling ───────────────────────────────────────────────────
error_exit() {
    print_error "$1"
    exit "${2:-1}"
}

trap_error() {
    print_error "An error occurred on line $1"
    exit 1
}

trap 'trap_error $LINENO' ERR

# ── Export Functions ─────────────────────────────────────────────────
export -f print_success
export -f print_error
export -f print_warning
export -f print_info
export -f print_step
export -f print_header
export -f print_separator
export -f confirm
export -f command_exists
export -f require_command
export -f is_git_repo
export -f get_os
export -f get_distro
export -f file_exists
export -f dir_exists
export -f create_dir
export -f create_backup
export -f error_exit