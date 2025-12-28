#!/usr/bin/env bash

mkcd() {
    mkdir -p "$1" && cd "$1" || return
}

take() {
    mkdir -p "$1" && cd "$1" || return
}

backup() {
    local file="$1"
    [[ -z "$file" ]] && { echo "Usage: backup <file>"; return 1; }
    cp "$file" "${file}.backup.$(date +%Y%m%d_%H%M%S)"
    echo "Backed up: $file"
}

extract() {
    if [[ ! -f "$1" ]]; then
        echo "Error: '$1' is not a valid file"
        return 1
    fi
    
    case "$1" in
        *.tar.bz2)   tar xjf "$1"     ;;
        *.tar.gz)    tar xzf "$1"     ;;
        *.tar.xz)    tar xJf "$1"     ;;
        *.tar.zst)   tar --zstd -xf "$1" ;;
        *.bz2)       bunzip2 "$1"     ;;
        *.rar)       unrar x "$1"     ;;
        *.gz)        gunzip "$1"      ;;
        *.tar)       tar xf "$1"      ;;
        *.tbz2)      tar xjf "$1"     ;;
        *.tgz)       tar xzf "$1"     ;;
        *.zip)       unzip "$1"       ;;
        *.Z)         uncompress "$1"  ;;
        *.7z)        7z x "$1"        ;;
        *.deb)       ar x "$1"        ;;
        *.rpm)       rpm2cpio "$1" | cpio -idmv ;;
        *)           echo "Error: '$1' cannot be extracted" ;;
    esac
}

ff() {
    find . -type f -iname "*$1*" 2>/dev/null
}

fd_func() {
    find . -type d -iname "*$1*" 2>/dev/null
}

fcd() {
    local dir
    dir=$(find . -type d -iname "*$1*" 2>/dev/null | head -1)
    [[ -n "$dir" ]] && cd "$dir" || echo "Directory not found"
}

# ── Git Helpers ──────────────────────────────────────────────────────
git_clone_cd() {
    git clone "$1" && cd "$(basename "$1" .git)" || return
}

git_root() {
    local root
    root=$(git rev-parse --show-toplevel 2>/dev/null)
    [[ -n "$root" ]] && cd "$root" || echo "Not in a git repository"
}

git_fresh() {
    git fetch --all && git reset --hard origin/$(git branch --show-current)
}

git_undo() {
    git reset --soft HEAD~1
}

git_uncommit() {
    git reset --soft HEAD~1
}

git_stats() {
    git log --author="$(git config user.name)" --pretty=tformat: --numstat | \
    awk '{ add += $1; subs += $2; loc += $1 - $2 } END { 
        printf "Added: %s\nRemoved: %s\nTotal: %s\n", add, subs, loc 
    }'
}

# ── Process Management ───────────────────────────────────────────────
kill_port() {
    if [[ -z "$1" ]]; then
        echo "Usage: kill_port <port>"
        return 1
    fi
    
    local pid
    pid=$(lsof -ti:"$1")
    
    if [[ -n "$pid" ]]; then
        kill -9 "$pid"
        echo "Killed process on port $1 (PID: $pid)"
    else
        echo "No process found on port $1"
    fi
}

port_check() {
    if [[ -z "$1" ]]; then
        echo "Usage: port_check <port>"
        return 1
    fi
    
    lsof -i:"$1" || echo "Port $1 is available"
}

# ── Docker Helpers ───────────────────────────────────────────────────
docker_clean_all() {
    echo "Stopping all containers..."
    docker stop $(docker ps -aq) 2>/dev/null
    echo "Removing all containers..."
    docker rm $(docker ps -aq) 2>/dev/null
    echo "Removing all images..."
    docker rmi $(docker images -q) 2>/dev/null
    echo "Pruning system..."
    docker system prune -af --volumes
    echo "Docker cleanup complete!"
}

docker_shell() {
    if [[ -z "$1" ]]; then
        echo "Usage: docker_shell <container>"
        return 1
    fi
    docker exec -it "$1" /bin/bash || docker exec -it "$1" /bin/sh
}

# ── File Operations ──────────────────────────────────────────────────
size() {
    du -sh "$@" 2>/dev/null | sort -rh
}

largest() {
    du -ah . 2>/dev/null | sort -rh | head -20
}

count_files() {
    find . -type f | wc -l
}

count_lines() {
    find . -type f -exec wc -l {} + | sort -rn | head -20
}

# ── System Info ──────────────────────────────────────────────────────
sysinfo() {
    echo "── System Information ──────────────────────"
    echo "OS:       $(uname -s)"
    echo "Kernel:   $(uname -r)"
    echo "Uptime:   $(uptime -p)"
    echo "Shell:    $SHELL"
    echo "User:     $USER"
    echo "Hostname: $(hostname)"
    echo
    echo "── Hardware ────────────────────────────────"
    echo "CPU:      $(lscpu | grep 'Model name' | cut -d: -f2 | xargs)"
    echo "Memory:   $(free -h | awk 'NR==2 {print $3 " / " $2}')"
    echo "Disk:     $(df -h / | awk 'NR==2 {print $3 " / " $2 " (" $5 ")"}')"
}

# ── Wallpaper ────────────────────────────────────────────────────────
cbg() {
    local wallpaper_dir="${HOME}/Pictures"
    [[ ! -d "$wallpaper_dir" ]] && { echo "Directory not found: $wallpaper_dir"; return 1; }
    
    local wallpaper
    wallpaper=$(find "$wallpaper_dir" -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.jpeg' \) 2>/dev/null | shuf -n 1)
    
    if [[ -n "$wallpaper" ]] && command -v feh &>/dev/null; then
        feh --bg-fill "$wallpaper"
        echo "Wallpaper: $(basename "$wallpaper")"
    else
        echo "No wallpapers found or feh not installed"
    fi
}

note() {
    local note_file="$HOME/.notes.txt"
    if [[ -z "$1" ]]; then
        [[ -f "$note_file" ]] && cat "$note_file" || echo "No notes yet"
    else
        echo "$(date '+%Y-%m-%d %H:%M') - $*" >> "$note_file"
        echo "Note saved"
    fi
}

copy() {
    if command -v xclip &>/dev/null; then
        xclip -selection clipboard
    elif command -v xsel &>/dev/null; then
        xsel --clipboard --input
    else
        echo "No clipboard tool found"
    fi
}

paste() {
    if command -v xclip &>/dev/null; then
        xclip -selection clipboard -o
    elif command -v xsel &>/dev/null; then
        xsel --clipboard --output
    else
        echo "No clipboard tool found"
    fi
}