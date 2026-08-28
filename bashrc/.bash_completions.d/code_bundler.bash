#!/bin/bash
# ==============================================================================
# Fichier : ~/.bash_completions.d/code_bundler.bash
# Rôle : Règles d'autocomplétion intelligentes (TAB) pour la commande `code_bundler`
# ==============================================================================

_code_bundler_completions()
{
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    opts="--output -o --help -h"

    # 1. Si l'utilisateur tape un tiret, on propose les options standards
    if [[ ${cur} == -* ]] ; then
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        return 0
    fi

    # 2. Si l'argument précédent était -o ou --output, on laisse l'utilisateur
    # taper son nom de fichier librement (pas de complétion spécifique)
    if [[ "$prev" == "-o" || "$prev" == "--output" ]]; then
        return 0
    fi

    # 3. Par défaut, on propose uniquement des DOSSIERS (répertoires) du dossier courant
    # Le flag -d de compgen filtre exclusivement les répertoires
    COMPREPLY=( $(compgen -d -- "${cur}") )
    return 0
}

# Liaison de la fonction à la commande exécutable
complete -F _code_bundler_completions code_bundler
