# =====================================================================
# CONFIGURATION ET ABSTRACTION MULTI-DISTRIBUTION (Debian, Arch, Void)
# =====================================================================

# 1. Détection universelle de bat / batcat
if command -v batcat >/dev/null 2>&1; then
    _V_BAT="batcat"
elif command -v bat >/dev/null 2>&1; then
    _V_BAT="bat"
else
    _V_BAT="cat" # Solution de repli si absent
fi

# 2. Détection universelle de ripgrep / rg
if command -v rg >/dev/null 2>&1; then
    _V_RG="rg"
elif command -v ripgrep >/dev/null 2>&1; then
    _V_RG="ripgrep"
else
    _V_RG="" # Sera géré comme erreur dans findnote
fi

# 3. Définition du dossier de notes (Centralisé pour les 3 fonctions)
export NOTES_DIR="$HOME/Documents/Notes"


# =====================================================================
# FONCTION 1 : hxf (Recherche globale d'un fichier + aperçu Helix)
# =====================================================================
hxf() {
    local file
    # On utilise $_V_BAT déterminé dynamiquement
    file=$(fzf --ansi -i --preview "$_V_BAT --color=always --style=numbers {} 2>/dev/null || cat {}")
    
    if [ -n "$file" ]; then
        hx "$file"
    fi
}


# =====================================================================
# FONCTION 2 : findnote (Recherche stricte dans l'en-tête YAML)
# =====================================================================
findnote() {
    # Sécurité si ripgrep n'est installé sur aucune forme
    if [ -z "$_V_RG" ]; then
        echo "Erreur : ripgrep ou rg n'est pas installé sur ce système." >&2
        return 1
    fi

    if [ ! -d "$NOTES_DIR" ]; then
        echo "Erreur : Le dossier $NOTES_DIR n'existe pas." >&2
        return 1
    fi

    local fichier
    # Utilisation des variables dynamiques $_V_RG et $_V_BAT
    fichier=$($_V_RG "$*" "$NOTES_DIR" \
        --type md \
        --multiline \
        --multiline-dotall \
        --passthru \
        --files-with-matches \
        --regexp "(?s)^---.*?$*.*?---" 2>/dev/null | fzf --ansi --preview "$_V_BAT --color=always --style=numbers {} 2>/dev/null || cat {}")

    if [ -n "$fichier" ]; then
        hx "$fichier"
    fi
}


# =====================================================================
# FONCTION 3 : notenew (Création avec respect des règles de nommage)
# =====================================================================
notenew() {
    mkdir -p "$NOTES_DIR"
    
    # 1. Gestion dynamique des types de documents
    local types_file="$HOME/.config/notenew_types.txt"
    
    # Création du fichier avec les abréviations officielles s'il n'existe pas
    if [ ! -f "$types_file" ]; then
        mkdir -p "$HOME/.config"
        cat <<EOF > "$types_file"
AE - Acte d'Engagement
ANN - Annexe
APRJ - Appel à Projet
ARR - Arrêté
ATL - Atlas
ATT - Attestation
AUD - Audit
AVP - Avant-Projet
AVEN - Avenant
AV - Avis
BIL - Bilan
BC - Bon de Commande
BE - Bordereau d'Envoi
BUDG - Budget
CC - Cahier des Charges
CIRC - Circulaire
CR - Compte-Rendu
CL - Courriel
C - Courrier
DECI - Décision
DECR - Décret
DEVI - Devis
DIAP - Diaporama
DCE - Dossier de Consultation des entreprises
DT - Dossier Technique
EC - Engagement comptable
ENQ - Enquête
EP - Entretien Professionnel
ETU - Étude
FAC - Facture
FAX - FAX
FORM - Formulaire
FOR - Formation
FD - Frais de déplacement
GUID - Guide
INDIC - Indicateurs
PRES - Insertion presse
LIS - Liste
LET - Lettre
LOI - Loi
MEM - Mémoire
MOD - Modèle
NOT - Note
NOTF - Notification
OJ - Ordre du jour
OM - Ordre de mission
OS - Ordre de service
PC - Permis de construire
PROC - Procédure
PV - Procès-verbal
PROG - Programme
PROJ - Projet
PROP - Proposition
QUES - Questionnaire
RAP - Rapport
REGL - Règlement
RDEC - Relevé de décisions
SCH - Schéma
STAT - Statistiques
SUIV - Suivi
TAB - Tableau/grille
TDB - Tableau de bord
EOF
    fi

    # Sélection du type via fzf (facultatif selon les règles)
    local type_doc
    type_doc=$(cat "$types_file" | fzf --prompt="Type de document (Entrée pour valider, Échap pour ignorer) : " --height=40% --reverse)
    # On ne garde que l'abréviation de 1 à 4 lettres majuscules
    type_doc=$(echo "$type_doc" | awk '{print $1}')

    # 2. Définition du sujet
    echo "Sujet du document ?"
    read -r raw_sujet
    
    if [ -z "$raw_sujet" ]; then
        echo "Opération annulée : Le sujet est obligatoire."
        return 1
    fi

    # Nettoyage selon les règles : minuscules, sans accents, sans caractères spéciaux (sauf _)
    local sujet
    sujet=$(echo "$raw_sujet" | tr '[:upper:]' '[:lower:]' | sed 's/[éèêë]/e/g; s/[àâä]/a/g; s/[ùûü]/u/g; s/[îï]/i/g; s/[ôö]/o/g; s/ç/c/g')
    
    # Suppression des mots vides (liste non exhaustive basée sur la consigne)
    sujet=$(echo "$sujet" | sed -E 's/\b(le|la|les|un|une|des|et|ou|en|de|du|a|au|pour|dans|aux|sur|avec)\b//g')
    
    # Remplacement des espaces par des underscores et suppression des caractères non alphanumériques
    sujet=$(echo "$sujet" | tr -cd 'a-z0-9 ' | tr -s ' ' | sed 's/^ //;s/ $//' | tr ' ' '_')

    # 3. Définition de la version
    echo "Version du document (ex: V00, VP, VF, VV) ? [Défaut: VP]"
    read -r version
    if [ -z "$version" ]; then
        version="VP"
    fi
    version=$(echo "$version" | tr '[:lower:]' '[:upper:]')

    # 4. Construction du nom de fichier final
    local curr_date
    curr_date=$(date +%Y%m%d)
    
    local filename_no_ext
    # Format chronologique par type : date_type_sujet_version
    if [ -n "$type_doc" ]; then
        filename_no_ext="${curr_date}_${type_doc}_${version}_${sujet}"
    else
        filename_no_ext="${curr_date}_${version}_${sujet}"
    fi

    # Tronquer à 53 caractères maximum, extension (.md = 3 caractères) comprise
    local max_len=50
    if [ ${#filename_no_ext} -gt $max_len ]; then
        echo "⚠️  Le nom généré dépasse la limite de $max_len caractères."
        filename_no_ext="${filename_no_ext:0:$max_len}"
        # On nettoie un éventuel underscore terminal laissé par la troncature
        filename_no_ext=$(echo "$filename_no_ext" | sed 's/_$//')
    fi
    
    local filename="${NOTES_DIR}/${filename_no_ext}.md"

    # 5. Création du fichier et ouverture dans Helix
    cat <<EOF > "$filename"
---
title: "$raw_sujet"
date: $(date +%Y-%m-%d)
type: "$type_doc"
version: "$version"
status: brouillon
---

# $raw_sujet

EOF

    hx "$filename"
}

