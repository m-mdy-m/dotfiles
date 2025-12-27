#!/usr/bin/env bash

mkcd() {
    mkdir -p "$1" && cd "$1"
}

extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.tar.xz)    tar xJf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

ff() {
    find . -type f -iname "*$1*" 2>/dev/null
}

fd() {
    find . -type d -iname "*$1*" 2>/dev/null
}

fcd() {
    local dir
    dir=$(find . -type d -iname "*$1*" 2>/dev/null | head -1)
    if [[ -n "$dir" ]]; then
        cd "$dir" || return
    else
        echo "Directory not found"
    fi
}

cbg() {
    local wallpaper_dir="${HOME}/Pictures"
    if [ ! -d "$wallpaper_dir" ]; then
        echo "Wallpaper directory not found: $wallpaper_dir"
        return 1
    fi
    
    local wallpaper=$(find "$wallpaper_dir" -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.jpeg' \) | shuf -n 1)
    
    if [ -n "$wallpaper" ]; then
        feh --bg-fill "$wallpaper"
        echo "Changed wallpaper to: $(basename "$wallpaper")"
    else
        echo "No wallpapers found in $wallpaper_dir"
    fi
}
