#!/bin/bash
REPO="/media/fbouillerot/MyPassport/backup-borg"
export BORG_PASSPHRASE=$(cat ~/.borg_pass)
# borg list --format '{archive} {time} \n' "$REPO" | sort 
borg list "$REPO" | sort 
