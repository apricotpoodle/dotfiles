#!/bin/bash
# ==============================================================================
# Fichier : ~/.bash_completions.d/finish_feature.bash
# Rôle : Règles d'autocomplétion (TAB) pour la commande `finish_feature`
# ==============================================================================

_finish_feature_completions()
{
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    # Définition des paramètres supportés par le script
    opts="--title -t --auto-merge"

    # Si la frappe actuelle commence par un tiret (ex: finish_feature -[TAB])
    if [[ ${cur} == -* ]] ; then
        # On demande à compgen de filtrer $opts en fonction de ce qui est tapé
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        return 0
    fi
}

# Lier la fonction de complétion générée à la commande exécutable "finish_feature"
complete -F _finish_feature_completions finish_feature
