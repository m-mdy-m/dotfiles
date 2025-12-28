#!/usr/bin/env bash

set -eo pipefail

readonly DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
readonly STATE_FILE="$HOME/.dotfiles_state"

source "$DOTFILES_DIR/scripts/common.sh"

ensure_directory() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        print_success "Created directory: $dir"
    fi
}

backup_if_exists() {
    local target="$1"
    if [[ -e "$target" ]] || [[ -L "$target" ]]; then
        ensure_directory "$BACKUP_DIR"
        local backup_path="$BACKUP_DIR/$(basename "$target")"
        cp -r "$target" "$backup_path" 2>/dev/null || true
        print_warning "Backed up: $(basename "$target")"
    fi
}

install_file() {
    local source="$1"
    local target="$2"
    
    if [[ ! -f "$source" ]]; then
        print_error "Source file not found: $source"
        return 1
    fi
    
    backup_if_exists "$target"
    ensure_directory "$(dirname "$target")"
    
    cp "$source" "$target"
    
    if [[ -x "$source" ]]; then
        chmod +x "$target"
    fi
    
    echo "$target:$source:$(date +%s)" >> "$STATE_FILE"
    print_success "Installed: $(basename "$target")"
}

install_bash() {
    print_header "Bash Configuration"
    
    install_file "$DOTFILES_DIR/bash/.bashrc" "$HOME/.bashrc"
    
    ensure_directory "$HOME/.bash"
    for module in "$DOTFILES_DIR"/bash/modules/*.sh; do
        [[ -f "$module" ]] || continue
        install_file "$module" "$HOME/.bash/$(basename "$module")"
    done
    
    print_info "Run 'source ~/.bashrc' to apply changes"
    echo
}

install_i3() {
    print_header "i3 Window Manager"
    
    ensure_directory "$HOME/.config/i3"
    install_file "$DOTFILES_DIR/.config/i3/config" "$HOME/.config/i3/config"
    install_file "$DOTFILES_DIR/.config/i3/random-bg.sh" "$HOME/.config/i3/random-bg.sh"
    
    print_info "Run 'i3-msg reload' to apply changes"
    echo
}

install_i3status() {
    print_header "i3status"
    
    ensure_directory "$HOME/.config/i3status"
    install_file "$DOTFILES_DIR/.config/i3status/config" "$HOME/.config/i3status/config"
    echo
}

install_kitty() {
    print_header "Kitty Terminal"
    
    ensure_directory "$HOME/.config/kitty"
    install_file "$DOTFILES_DIR/.config/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
    echo
}

install_neofetch() {
    print_header "Neofetch"
    
    ensure_directory "$HOME/.config/neofetch"
    install_file "$DOTFILES_DIR/.config/neofetch/config.conf" "$HOME/.config/neofetch/config.conf"
    echo
}

install_picom() {
    print_header "Picom Compositor"
    
    ensure_directory "$HOME/.config/picom"
    install_file "$DOTFILES_DIR/.config/picom/picom.conf" "$HOME/.config/picom/picom.conf"
    echo
}

install_rofi() {
    print_header "Rofi Launcher"
    
    ensure_directory "$HOME/.config/rofi"
    install_file "$DOTFILES_DIR/.config/rofi/config.rasi" "$HOME/.config/rofi/config.rasi"
    echo
}

install_tmux() {
    print_header "Tmux"
    
    ensure_directory "$HOME/.config/tmux"
    install_file "$DOTFILES_DIR/.config/tmux/.tmux.conf" "$HOME/.config/tmux/.tmux.conf"
    echo
}

update_config() {
    print_header "Updating Configuration"
    
    if [[ ! -f "$STATE_FILE" ]]; then
        print_error "No installation state found. Run install first."
        return 1
    fi
    
    while IFS=: read -r target source timestamp; do
        if [[ -f "$source" ]]; then
            cp "$source" "$target"
            print_success "Updated: $(basename "$target")"
        fi
    done < "$STATE_FILE"
    
    print_success "All configurations updated"
    echo
}

uninstall_config() {
    print_header "Uninstalling Dotfiles"
    
    if [[ ! -f "$STATE_FILE" ]]; then
        print_error "No installation state found"
        return 1
    fi
    
    while IFS=: read -r target source timestamp; do
        if [[ -f "$target" ]]; then
            rm "$target"
            print_success "Removed: $(basename "$target")"
        fi
    done < "$STATE_FILE"
    
    rm "$STATE_FILE"
    print_success "Dotfiles uninstalled"
    echo
}

show_menu() {
    clear
    cat << 'EOF'
╔══════════════════════════════════════════╗
║       Dotfiles Installation Menu        ║
╚══════════════════════════════════════════╝

  1) Install All Configurations
  2) Install Bash
  3) Install i3 + i3status
  4) Install Kitty
  5) Install Rofi
  6) Install Picom
  7) Install Tmux
  8) Install Neofetch
  
  u) Update All Configs
  r) Uninstall All
  q) Quit

EOF
    read -rp "Select option: " choice
}

interactive_mode() {
    while true; do
        show_menu
        
        case "$choice" in
            1)
                install_bash
                install_i3
                install_i3status
                install_kitty
                install_rofi
                install_picom
                install_tmux
                install_neofetch
                read -rp "Press Enter to continue..."
                ;;
            2) install_bash; read -rp "Press Enter to continue..." ;;
            3) install_i3; install_i3status; read -rp "Press Enter to continue..." ;;
            4) install_kitty; read -rp "Press Enter to continue..." ;;
            5) install_rofi; read -rp "Press Enter to continue..." ;;
            6) install_picom; read -rp "Press Enter to continue..." ;;
            7) install_tmux; read -rp "Press Enter to continue..." ;;
            8) install_neofetch; read -rp "Press Enter to continue..." ;;
            u) update_config; read -rp "Press Enter to continue..." ;;
            r) 
                read -rp "Are you sure? (y/N): " confirm
                [[ "$confirm" =~ ^[Yy]$ ]] && uninstall_config
                read -rp "Press Enter to continue..."
                ;;
            q) print_info "Goodbye!"; exit 0 ;;
            *) print_error "Invalid option"; sleep 1 ;;
        esac
    done
}

main() {
    if [[ $# -eq 0 ]]; then
        interactive_mode
    else
        case "$1" in
            --all|-a) 
                install_bash
                install_i3
                install_i3status
                install_kitty
                install_rofi
                install_picom
                install_tmux
                install_neofetch
                ;;
            --bash|-b) install_bash ;;
            --i3|-i) install_i3; install_i3status ;;
            --kitty|-k) install_kitty ;;
            --rofi|-r) install_rofi ;;
            --tmux|-t) install_tmux ;;
            --update|-u) update_config ;;
            --uninstall) uninstall_config ;;
            --help|-h)
                cat << EOF
Usage: $0 [OPTIONS]

Options:
  -a, --all        Install all configurations
  -b, --bash       Install bash configuration
  -i, --i3         Install i3 window manager
  -k, --kitty      Install kitty terminal
  -r, --rofi       Install rofi launcher
  -t, --tmux       Install tmux
  -u, --update     Update all installed configs
  --uninstall      Remove all installed configs
  -h, --help       Show this help message

No options: Run interactive mode
EOF
                ;;
            *) print_error "Unknown option: $1"; exit 1 ;;
        esac
    fi
    
    if [[ -d "$BACKUP_DIR" ]]; then
        echo
        print_info "Backups saved to: $BACKUP_DIR"
    fi
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"