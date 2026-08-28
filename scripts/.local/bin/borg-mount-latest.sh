#!/bin/bash

# Configuration
MOUNT_POINT="/media/fbouillerot/MyPassport"
REPO="$MOUNT_POINT/backup-borg"
export BORG_PASSPHRASE=$(cat ~/.borg_pass)
TEMP_MOUNT_DIR="$HOME/borg-mount"

# Créer le point de montage s'il n'existe pas
mkdir -p "$TEMP_MOUNT_DIR"

# Vérifier si l'option --unmount est passée
if [ "$1" = "--unmount" ]; then
    if borg umount "$TEMP_MOUNT_DIR" 2>/dev/null; then
        notify-send "Borg Umount" "Démontage réussi de $TEMP_MOUNT_DIR" -i folder
        echo "Démontage réussi."
    else
        notify-send -u critical "❌ Échec du démontage" "Le point de montage $TEMP_MOUNT_DIR n'est pas monté ou n'existe pas." -i error
        echo "Échec du démontage : vérifiez que $TEMP_MOUNT_DIR est monté."
    fi
    exit 0
fi

# Trouver la dernière archive XPS
LATEST_ARCHIVE=$(borg list --last 1 "$REPO" | awk '{print $1}' | cut -d: -f2)

if [ -z "$LATEST_ARCHIVE" ]; then
    notify-send -u critical "❌ Aucune archive trouvée" "Vérifiez que le dépôt existe et est accessible." -i error
    exit 1
fi

# Monter l'archive
if borg mount "$REPO::$LATEST_ARCHIVE" "$TEMP_MOUNT_DIR"; then
    notify-send "Borg Mount" "Archive montée dans : $TEMP_MOUNT_DIR" -i folder
    echo "L'archive $LATEST_ARCHIVE est montée dans : $TEMP_MOUNT_DIR"
    echo "Pour démonter, exécutez : $0 --unmount"
else
    notify-send -u critical "❌ Échec du montage" "Vérifiez la passphrase et le dépôt." -i error
    exit 1
fi
