#!/usr/bin/env bash

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
export DOTFILES_DIR

. "$DOTFILES_DIR/scripts/common.sh"

ask_confirmation() {
    local prompt="$1"
    local default="${2:-n}"
    local response
    
    if [[ "$default" == "y" ]]; then
        prompt="$prompt [Y/n]: "
    else
        prompt="$prompt [y/N]: "
    fi
    
    read -p "$prompt" response
    response="${response:-$default}"
    
    [[ "$response" =~ ^[Yy]$ ]]
}

backup_file() {
    local file="$1"
    if [[ -e "$file" ]] || [[ -L "$file" ]]; then
        mkdir -p "$BACKUP_DIR"
        print_warning "Backing up existing $(basename "$file")"
        mv "$file" "$BACKUP_DIR/"
    fi
}

create_symlink() {
    local source="$1"
    local target="$2"
    
    if [ -e "$target" ] || [ -L "$target" ]; then
        backup_file "$target"
    fi
    
    mkdir -p "$(dirname "$target")"
    ln -sf "$source" "$target"
    print_success "Linked: $target -> $source"
}

install_bash() {
    print_info "Installing Bash configuration..."
    
    create_symlink "$DOTFILES_DIR/bash/.bashrc" "$HOME/.bashrc"
    
    source "$HOME/.bashrc" 2>/dev/null || true
    mkdir -p "$HOME/.bash"
    for module in "$DOTFILES_DIR"/bash/modules/*.sh; do
        if [ -f "$module" ]; then
            module_name=$(basename "$module")
            create_symlink "$module" "$HOME/.bash/$module_name"
        fi
    done
    print_info "Sourcing new bashrc..."
    echo
}

install_i3() {
    print_info "Installing i3 configuration..."
    
    create_symlink "$DOTFILES_DIR/i3/config" "$HOME/.config/i3/config"
    create_symlink "$DOTFILES_DIR/i3/scripts/random-bg.sh" "$HOME/.config/i3/random-bg.sh"
    
    chmod +x "$HOME/.config/i3/random-bg.sh"
    
    echo
}

install_i3status() {
    print_info "Installing i3status configuration..."
    
    create_symlink "$DOTFILES_DIR/i3status/config" "$HOME/.config/i3status/config"
    
    echo
}

install_kitty() {
    print_info "Installing Kitty configuration..."
    
    create_symlink "$DOTFILES_DIR/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
    
    echo
}

install_neofetch() {
    print_info "Installing Neofetch configuration..."
    
    create_symlink "$DOTFILES_DIR/neofetch/config.conf" "$HOME/.config/neofetch/config.conf"
    
    echo
}

install_picom() {
    print_info "Installing Picom configuration..."
    
    create_symlink "$DOTFILES_DIR/picom/picom.conf" "$HOME/.config/picom/picom.conf"
    
    echo
}

install_rofi() {
    print_info "Installing Rofi configuration..."
    
    create_symlink "$DOTFILES_DIR/rofi/config.rasi" "$HOME/.config/rofi/config.rasi"
    
    echo
}

install_all() {
    install_bash
    install_i3
    install_i3status
    install_kitty
    install_neofetch
    install_picom
    install_rofi
}

main() {
    print_header
    
    echo "This script will symlink dotfiles from:"
    echo "$DOTFILES_DIR"
    echo
    echo "Existing configurations will be backed up to:"
    echo "$BACKUP_DIR"
    echo
    
    if ! ask_confirmation "Continue with installation?" "y"; then
        print_error "Installation cancelled"
        exit 0
    fi
    
    echo
    
    if ask_confirmation "Install Bash configuration?" "y"; then
        install_bash
    fi
    
    if ask_confirmation "Install i3 window manager configuration?" "n"; then
        install_i3
        
        if ask_confirmation "Install i3status configuration?" "y"; then
            install_i3status
        fi
    fi
    
    if ask_confirmation "Install Kitty terminal configuration?" "n"; then
        install_kitty
    fi
    
    if ask_confirmation "Install Neofetch configuration?" "n"; then
        install_neofetch
    fi
    
    if ask_confirmation "Install Picom compositor configuration?" "n"; then
        install_picom
    fi
    
    if ask_confirmation "Install Rofi launcher configuration?" "n"; then
        install_rofi
    fi
    
    echo
    print_success "Installation complete!"
    
    if [[ -d "$BACKUP_DIR" ]]; then
        echo
        print_info "Your old configurations have been backed up to:"
        echo "$BACKUP_DIR"
    fi
    
    echo
    print_info "You may need to restart your terminal or run: source ~/.bashrc"
}

main "$@"