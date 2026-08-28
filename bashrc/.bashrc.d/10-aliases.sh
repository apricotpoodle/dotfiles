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
alias python='python3'

# # recherche via helix

# hxf() {
#     local file
#     file=$(fzf -i --ansi --preview 'batcat --color=always --style=numbers {} 2>/dev/null || cat {}')
    
#     # On vérifie si l'utilisateur a bien sélectionné un fichier ou s'il a fait Échap
#     if [ -n "$file" ]; then
#         hx "$file"
#     fi
# }

# # Création d'une nouvelle note
# notenew() {
#     # Demande le titre de la note
#     echo "Titre de la note ?"
#     read -r title
    
#     # Formate le nom du fichier (ex: 2026-05-27_mon-titre.md)
#     local slug
#     slug=$(echo "$title" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
#     local filename="$(date +%Y-%m-%d)_${slug}.md"
    
#     # Génère le fichier avec l'en-tête YAML automatique
#     cat <<EOF > "$filename"
# ---
# title: "$title"
# date: $(date +%Y-%m-%d)
# tags: []
# status: brouillon
# ---

# # $title

# EOF

#     # Ouvre directement la note dans Helix
#     hx "$filename"
# }

# # LaTeX via Docker.
# # alias latexmk='docker run --rm -v "$(pwd):/workdir" texlive/texlive:latest latexmk -lualatex -interaction=nonstopmode'
