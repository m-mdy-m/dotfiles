#!/usr/bin/env bash

[[ $- != *i* ]] && return

BASH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$BASH_DIR/core.sh"
source "$BASH_DIR/colors.sh"
source "$BASH_DIR/prompt.sh"
source "$BASH_DIR/aliases.sh"
source "$BASH_DIR/functions.sh"

if [[ -n "$PS1" ]] && [[ -f "${BASH_DIR}/welcome.sh" ]]; then
    source "${BASH_DIR}/welcome.sh"
fi