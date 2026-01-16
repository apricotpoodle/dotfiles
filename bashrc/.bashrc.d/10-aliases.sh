# [cite_start]Navigation[cite: 1].
alias ls='ls --color=auto'
alias ll='ls -lha'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'

# [cite_start]Gestion des paquets[cite: 2].
alias update='sudo apt update && sudo apt upgrade -y'
alias install='sudo apt install'
alias remove='sudo apt remove'

# [cite_start]Système[cite: 2].
alias df='df -h'
alias du='du -h'
alias myip='curl ifconfig.me'

# [cite_start]Protection contre les erreurs[cite: 3].
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# [cite_start]Raccourcis pratiques et Apps[cite: 4, 5].
alias h='history'
alias c='clear'
alias lzg='lazygit'
alias lzd='lazydocker'
alias zj='zellij'

# [cite_start]LaTeX via Docker[cite: 5].
alias latexmk='docker run --rm -v "$(pwd):/workdir" texlive/texlive:latest latexmk -lualatex -interaction=nonstopmode'
