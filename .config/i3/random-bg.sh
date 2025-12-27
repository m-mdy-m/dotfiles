#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/Pictures"

if [ ! -d "$WALLPAPER_DIR" ]; then
    exit 0
fi

RANDOM_WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.jpeg' \) 2>/dev/null | shuf -n 1)

if [ -n "$RANDOM_WALLPAPER" ] && command -v feh &> /dev/null; then
    feh --bg-fill "$RANDOM_WALLPAPER"
fi