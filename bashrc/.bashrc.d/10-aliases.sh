# Navigation.
alias ls='ls --color=auto'
alias ll='ls -lha --color=auto'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'

# Gestion des paquets.
alias update='sudo apt autoremove --purge && sudo apt update && sudo apt upgrade -y && sudo apt autoremove --purge'
alias install='sudo apt install'
alias remove='sudo apt remove'

# Système.
alias df='df -h'
alias du='du -h'
alias myip='curl ifconfig.me'

# Protection contre les erreurs.
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Raccourcis pratiques et Apps.
alias h='history'
alias c='clear'
alias lzg='lazygit'
alias lzd='lazydocker'
alias zj='zellij'

# LaTeX via Docker.
# alias latexmk='docker run --rm -v "$(pwd):/workdir" texlive/texlive:latest latexmk -lualatex -interaction=nonstopmode'
