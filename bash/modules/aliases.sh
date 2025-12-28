#!/usr/bin/env bash

# ── Core ─────────────────────────────────────────────────────────────
alias c='clear'
alias q='exit'
alias h='history'
alias reload='exec $SHELL -l'

# ── Navigation ───────────────────────────────────────────────────────
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias -- -='cd -'

# ── Listing ──────────────────────────────────────────────────────────
alias ls='ls --color=auto --group-directories-first'
alias l='ls -lh'
alias ll='ls -lah'
alias la='ls -A'
alias lt='ls -laht'    
alias lsize='ls -lSrh'
alias lx='ls -lXBh' 

# ── File Operations ──────────────────────────────────────────────────
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -Iv --preserve-root'
alias mkdir='mkdir -pv'
alias mkd='mkdir -pv'

# ── System Info ──────────────────────────────────────────────────────
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ps='ps auxf'
alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'
alias ports='netstat -tulanp'
alias listening='ss -tuln'

# ── Network ──────────────────────────────────────────────────────────
alias ping='ping -c 5'
alias myip='curl -s ifconfig.me'
alias localip="ip -4 addr | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v 127.0.0.1"
alias speedtest='curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -'

# ── Git ──────────────────────────────────────────────────────────────
alias g='git'
alias gs='git status -sb'
alias gss='git status'
alias ga='git add'
alias gaa='git add .'
alias gap='git add -p'
alias gc='git commit -v'
alias gcm='git commit -m'
alias gcs='git commit -S -m'
alias gca='git commit --amend'
alias gcan='git commit --amend --no-edit'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpl='git pull'
alias gplr='git pull --rebase'
alias gf='git fetch'
alias gfa='git fetch --all'
alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -d'
alias gbD='git branch -D'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gcm='git checkout main || git checkout master'
alias gm='git merge'
alias gma='git merge --abort'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log --oneline --graph --decorate -20'
alias gla='git log --oneline --graph --decorate --all -20'
alias gll='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'
alias gst='git stash'
alias gsta='git stash apply'
alias gstp='git stash pop'
alias gstl='git stash list'
alias gstd='git stash drop'
alias gclean='git clean -fd'
alias greset='git reset --hard'
alias gr='git remote -v'
alias grao='git remote add origin'

# ── Docker ───────────────────────────────────────────────────────────
alias d='docker'
alias dc='docker compose'
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dpsa='docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias di='docker images'
alias drmi='docker rmi'
alias drm='docker rm'
alias dex='docker exec -it'
alias dlogs='docker logs -f'
alias dstop='docker stop $(docker ps -q)'
alias dclean='docker system prune -af'

alias dcup='docker compose up -d'
alias dcdown='docker compose down'
alias dclogs='docker compose logs -f'
alias dcps='docker compose ps'
alias dcrestart='docker compose restart'
alias dclogs='docker compose logs -f'

# Docker shell
dsh() { docker exec -it "$1" sh -c "bash || sh"; }

# ── Tmux ─────────────────────────────────────────────────────────────
alias t='tmux'
alias ta='tmux attach -t'
alias tl='tmux list-sessions'
alias tn='tmux new -s'
alias tk='tmux kill-session -t'
alias tka='tmux kill-server'

# ── Editor ───────────────────────────────────────────────────────────
alias v='$EDITOR'
alias vim='$EDITOR'
alias vi='$EDITOR'

# ── Config Shortcuts ─────────────────────────────────────────────────
alias bashrc='$EDITOR ~/.bashrc'
alias aliases='$EDITOR ~/.bash/aliases.sh'
alias vimrc='$EDITOR ~/.vimrc'

# ── Disk Usage ───────────────────────────────────────────────────────
alias usage='du -sh * | sort -rh | head -10'
alias biggest='find . -type f -exec du -h {} + | sort -rh | head -20'
alias diskspace='df -h | grep -E "^(/dev/|Filesystem)"'

# ── Process Management ───────────────────────────────────────────────
alias killport='kill_port'
alias ps='ps auxf'
alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'
alias psmem='ps auxf | sort -nr -k 4 | head -10'
alias pscpu='ps auxf | sort -nr -k 3 | head -10'

# ── Time & Date ──────────────────────────────────────────────────────
alias now='date +"%T"'
alias today='date +"%Y-%m-%d"'
alias timestamp='date +%s'
alias week='date +%V'

# ── Shortcuts ────────────────────────────────────────────────────────
alias path='echo -e ${PATH//:/\\n}'
alias cleanup='find . -type f -name "*.DS_Store" -ls -delete'
alias reload-bashrc='source ~/.bashrc'

# ── Background Jobs ──────────────────────────────────────────────────
alias j='jobs -l'
