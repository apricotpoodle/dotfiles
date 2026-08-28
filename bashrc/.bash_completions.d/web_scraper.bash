#!/bin/bash
# ==============================================================================
# Fichier : ~/.bash_completions.d/web_scraper.bash
# Rôle : Règles d'autocomplétion (TAB) pour la commande `web_scraper`
# ==============================================================================

_web_scraper_completions()
{
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    opts="-u --url -d --depth -o --output -h --help"

    # Si l'utilisateur cherche une option (commençant par un tiret)
    if [[ ${cur} == -* ]] ; then
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        return 0
    fi

    # Si l'option précédente était le dossier de sortie (-o), on propose uniquement des répertoires
    if [[ "$prev" == "-o" || "$prev" == "--output" ]]; then
        COMPREPLY=( $(compgen -d -- "${cur}") )
        return 0
    fi
}

complete -F _web_scraper_completions web_scraper
