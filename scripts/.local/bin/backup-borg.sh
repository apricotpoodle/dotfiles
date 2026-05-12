#!/bin/bash
# Script de sauvegarde intelligente avec Borg
MOUNT_POINT="/media/fbouillerot/MyPassport" # À adapter selon le nom de ton disque
REPO="$MOUNT_POINT/backup-borg"
BACKUP_NAME="::$(date +%Y-%m-%d_%H:%M)"

if [ -d "$MOUNT_POINT" ]; then
    notify-send "Sauvegarde" "Disque détecté. Lancement de BorgBackup..." -i drive-harddisk
    
    # Exécution de la sauvegarde (on exclut les fichiers temporaires LaTeX)
    borg create --stats \
        --exclude '*/.aux' \
        --exclude '*/.log' \
        "$REPO$BACKUP_NAME" \
        ~/latex ~/notes
        
    notify-send "Sauvegarde Terminée" "Vos données LaTeX et Notes sont sécurisées." -i checkbox-checked-symbolic
else
    notify-send -u critical "⚠️ Sauvegarde Échouée" "Veuillez brancher votre disque dur externe." -i warning
fi
