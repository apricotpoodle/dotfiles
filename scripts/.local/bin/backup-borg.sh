#!/bin/bash

# =============================================================================
# CONFIGURATION
# =============================================================================
MOUNT_POINT="/media/fbouillerot/MyPassport"
REPO="$MOUNT_POINT/backup-borg"
export BORG_PASSPHRASE=$(cat ~/.borg_pass)
ARCHIVE="XPS-$(date +%Y-%m-%d_%H%M)"

# Liste des dossiers à sauvegarder (uniquement s'ils existent)
SOURCES=""
[ -d "$HOME/latex" ] && SOURCES="$SOURCES $HOME/latex"
[ -d "$HOME/Documents/PKM" ] && SOURCES="$SOURCES $HOME/Documents/PKM"

# =============================================================================
# VÉRIFICATION ET EXÉCUTION
# =============================================================================

if [ ! -d "$MOUNT_POINT" ]; then
    notify-send -u critical "⚠️ Sauvegarde impossible" "Le disque MyPassport n'est pas détecté." -i warning
    exit 1
fi

if [ -z "$SOURCES" ]; then
    notify-send "Sauvegarde" "Aucune source (latex/notes) trouvée. Rien à faire."
    exit 0
fi

notify-send "Sauvegarde Borg" "Sécurisation en cours..." -i drive-harddisk

# 2. Création de la sauvegarde
borg create --stats \
    --compression zstd,3 \
    --exclude '*/.aux' \
    --exclude '*/.log' \
    --exclude '*/.fls' \
    --exclude '*/.fdb_latexmk' \
    --exclude '*/.stversions' \
    "$REPO::$ARCHIVE" \
    $SOURCES

# 3. Nettoyage (Syntaxe corrigée pour éviter le Warning)
# On remplace --prefix par -a (ou --glob-archives)
borg prune -v --list "$REPO" -a 'XPS-*' \
    --keep-daily=7 --keep-weekly=4 --keep-monthly=6

# 4. Compactage
borg compact "$REPO"

# =============================================================================
# NOTIFICATION FINALE
# =============================================================================
if [ $? -eq 0 ]; then
    notify-send "Sauvegarde Terminée ✅" "Dépôt mis à jour sur MyPassport." -i checkbox-checked-symbolic
else
    notify-send -u critical "❌ Erreur Sauvegarde" "Vérifiez les logs de Borg." -i error
fi
