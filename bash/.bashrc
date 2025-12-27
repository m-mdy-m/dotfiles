#!/usr/bin/env bash

[[ $- != *i* ]] && return

BASH_MODULES_DIR="${HOME}/.bash"

load_module() {
    local module="$1"
    local module_path="${BASH_MODULES_DIR}/${module}.sh"
    
    if [[ -f "$module_path" ]]; then
        source "$module_path"
    else
        echo "Warning: Module '$module' not found at $module_path" >&2
    fi
}

load_module "core"
load_module "colors"
load_module "prompt"
load_module "aliases"
load_module "functions"

if [[ -n "$PS1" ]] && [[ -f "${BASH_MODULES_DIR}/welcome.sh" ]]; then
    source "${BASH_MODULES_DIR}/welcome.sh"
fi