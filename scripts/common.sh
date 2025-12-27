#!/usr/bin/env bash

set -e

# Colors for output
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    DIM='\033[2m'
    RESET='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    CYAN=''
    BOLD=''
    DIM=''
    RESET=''
fi

print_header() {
    echo -e "${BLUE}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BLUE}  Dotfiles Installation${RESET}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════${RESET}"
    echo
}

print_success() {
    echo -e "${GREEN}✓${RESET} $1"
}

print_error() {
    echo -e "${RED}✗${RESET} $1"
}

print_info() {
    echo -e "${BLUE}→${RESET} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${RESET} $1"
}