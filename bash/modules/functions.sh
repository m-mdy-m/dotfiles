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

tree() {
    local depth=3
    local show_files=true
    local show_dirs=true
    local show_hidden=false
    local show_git=false
    local path="."
    local show_size=false
    local show_permissions=false
    
    # Parse arguments
    while (( $# > 0 )); do
        case $1 in
            -L)
                depth="$2"
                shift 2
                ;;
            -f)
                show_dirs=false
                shift
                ;;
            -d)
                show_files=false
                shift
                ;;
            -a)
                show_hidden=true
                shift
                ;;
            -g)
                show_git=true
                shift
                ;;
            -s)
                show_size=true
                shift
                ;;
            -p)
                show_permissions=true
                shift
                ;;
            -h|--help)
                printf "Usage: tree [OPTIONS] [PATH]\n"
                printf "Options:\n"
                printf "  -L N        Limit depth to N levels (default: 3)\n"
                printf "  -f          Show only files\n"
                printf "  -d          Show only directories\n"
                printf "  -a          Show hidden files/directories\n"
                printf "  -g          Include .git and other VCS directories\n"
                printf "  -s          Show file sizes\n"
                printf "  -p          Show permissions\n"
                printf "  -h, --help  Show this help\n"
                return 0
                ;;
            -*)
                printf "Unknown option: %s\n" "$1"
                return 1
                ;;
            *)
                path="$1"
                shift
                ;;
        esac
    done
    
    # Check if path exists
    if [[ ! -d "$path" && ! -f "$path" ]]; then
        printf "Path not found: %s\n" "$path"
        return 1
    fi

    # Internal recursive function to build tree
    _tree_recursive() {
        local current_path="$1"
        local current_depth="$2"
        local prefix="$3"
        local is_last="$4"
        
        # Check depth limit
        if (( current_depth > depth )); then
            return
        fi
        
        # Get items in directory
        local items=()
        local item
        
        # Use different approaches based on what we want to show
        if [[ "$show_hidden" == true ]]; then
            while IFS= read -r -d '' item; do
                items+=("$item")
            done < <(find "$current_path" -maxdepth 1 -mindepth 1 -print0 2>/dev/null | sort -z)
        else
            while IFS= read -r -d '' item; do
                local basename="${item##*/}"
                if [[ "$basename" != .* ]]; then
                    items+=("$item")
                fi
            done < <(find "$current_path" -maxdepth 1 -mindepth 1 -print0 2>/dev/null | sort -z)
        fi
        
        # Filter out VCS directories unless explicitly requested
        if [[ "$show_git" == false ]]; then
            local filtered_items=()
            for item in "${items[@]}"; do
                local basename="${item##*/}"
                if [[ "$basename" != ".git" && "$basename" != ".svn" && "$basename" != ".hg" && "$basename" != ".bzr" ]]; then
                    filtered_items+=("$item")
                fi
            done
            items=("${filtered_items[@]}")
        fi
        
        # Filter by file type
        local final_items=()
        for item in "${items[@]}"; do
            if [[ -d "$item" ]]; then
                if [[ "$show_dirs" == true ]]; then
                    final_items+=("$item")
                fi
            else
                if [[ "$show_files" == true ]]; then
                    final_items+=("$item")
                fi
            fi
        done
        
        # Process each item
        local item_count=${#final_items[@]}
        local i=0
        
        for item in "${final_items[@]}"; do
            i=$((i + 1))
            local is_last_item=false
            if (( i == item_count )); then
                is_last_item=true
            fi
            
            local basename="${item##*/}"
            local tree_char="├── "
            local new_prefix="$prefix│   "
            
            if [[ "$is_last_item" == true ]]; then
                tree_char="└── "
                new_prefix="$prefix    "
            fi
            
            # Determine file type and styling
            local color=""
            local icon=""
            if [[ -d "$item" ]]; then
                color="${colors[blue]}"
                icon="📁"
            elif [[ -x "$item" ]]; then
                color="${colors[green]}"
                icon="⚡"
            else
                case "$basename" in
                    *.txt|*.md|*.rst) color="${colors[white]}"; icon="📄" ;;
                    *.sh|*.bash|*.zsh) color="${colors[green]}"; icon="🔧" ;;
                    *.py) color="${colors[yellow]}"; icon="🐍" ;;
                    *.js|*.ts|*.jsx|*.tsx) color="${colors[yellow]}"; icon="⚡" ;;
                    *.html|*.css|*.scss) color="${colors[purple]}"; icon="🌐" ;;
                    *.json|*.xml|*.yaml|*.yml) color="${colors[cyan]}"; icon="📋" ;;
                    *.jpg|*.jpeg|*.png|*.gif|*.svg) color="${colors[red]}"; icon="🖼️" ;;
                    *.mp3|*.mp4|*.avi|*.mov) color="${colors[red]}"; icon="🎵" ;;
                    *.zip|*.tar|*.gz|*.bz2) color="${colors[gray]}"; icon="📦" ;;
                    *.pdf) color="${colors[red]}"; icon="📕" ;;
                    *.log) color="${colors[gray]}"; icon="📜" ;;
                    *) color="${colors[white]}"; icon="📄" ;;
                esac
            fi
            
            # Build output line
            local output="${colors[gray]}${prefix}${tree_char}${colors[reset]}${icon} ${color}${basename}${colors[reset]}"
            
            # Add size if requested
            if [[ "$show_size" == true && -f "$item" ]]; then
                local size
                if command -v du >/dev/null 2>&1; then
                    size=$(du -h "$item" 2>/dev/null | cut -f1)
                    output+=" ${colors[gray]}(${size})${colors[reset]}"
                fi
            fi
            
            # Add permissions if requested
            if [[ "$show_permissions" == true ]]; then
                local perms
                perms=$(ls -ld "$item" 2>/dev/null | cut -d' ' -f1)
                output+=" ${colors[dim]}${perms}${colors[reset]}"
            fi
            
            printf "%b\n" "$output"
            
            # Recurse into directories
            if [[ -d "$item" && $current_depth -lt $depth ]]; then
                _tree_recursive "$item" $((current_depth + 1)) "$new_prefix" "$is_last_item"
            fi
        done
    }
    
    # Start the tree
    if [[ "$path" != "." ]]; then
        local basename="${path##*/}"
        printf "%s📁 %s%s%s\n" "${colors[blue]}" "${colors[blue]}" "$basename" "${colors[reset]}"
    fi
    
    _tree_recursive "$path" 1 "" false
}

alias t1='tree -L 1'     
alias t2='tree -L 2'      
alias t3='tree -L 3'      
alias t4='tree -L 4'      
alias t5='tree -L 5'      

alias td='tree -d'        
alias tf='tree -f'        
alias ta='tree -a'        
alias tg='tree -g'        
alias ts='tree -s'        
alias tp='tree -p'        

alias tds='tree -d -s'    
alias tfs='tree -f -s'    
alias tas='tree -a -s'    
alias tgas='tree -g -a -s'