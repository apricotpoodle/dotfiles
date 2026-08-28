#!/bin/bash
# ==============================================================================
# Fichier : ~/.bashrc.d/30-completions.sh
# Rôle : Chargeur dynamique du système d'autocomplétion personnalisé.
# ==============================================================================

COMPLETIONS_DIR="$HOME/.bash_completions.d"

# Si le dossier des complétions personnalisées existe
if [ -d "$COMPLETIONS_DIR" ]; then
    # On boucle sur tous les fichiers .bash qu'il contient
    for completion_file in "$COMPLETIONS_DIR"/*.bash; do
        # S'il est lisible, on le source (l'exécute dans le contexte courant)
        if [ -r "$completion_file" ]; then
            . "$completion_file"
        fi
    done
    unset completion_file
fi
