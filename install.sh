#!/bin/bash

# Arrête le script immédiatement si une commande échoue
set -e

echo "🚀 Démarrage de la configuration de l'environnement..."

# --- 1. Installation des dépendances système via apt ---
echo "📦 Mise à jour et installation des paquets système de base..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y git stow curl build-essential unzip nodejs npm php-cli php-mbstring php-xml composer keychain

# --- 2. Installation de l'éditeur Helix (via PPA pour les mises à jour faciles) ---
echo "Installing Helix Editor..."
sudo add-apt-repository ppa:maveonair/helix-editor -y
sudo apt update
sudo apt install helix -y

# --- 3. Installation de la police JetBrainsMono Nerd Font ---
FONT_DIR="/usr/local/share/fonts/truetype/JetBrainsMonoNerdFont"
if [ ! -d "$FONT_DIR" ]; then
    echo "✒️ Installation de la police JetBrainsMono Nerd Font..."
    # Crée le répertoire de destination
    sudo mkdir -p "$FONT_DIR"
    # Télécharge l'archive dans un dossier temporaire
    cd /tmp
    curl -fLO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
    # Décompresse les polices au bon endroit
    sudo unzip -o JetBrainsMono.zip -d "$FONT_DIR"
    # Supprime l'archive
    rm JetBrainsMono.zip
    # Met à jour le cache des polices du système
    echo "Mise à jour du cache des polices..."
    sudo fc-cache -f -v
else
    echo "✒️ La police JetBrainsMono Nerd Font est déjà installée."
fi

# --- 4. Installation des outils globaux (Node.js) ---
echo "🛠️ Installation des outils globaux : Prettier et serveurs de langage..."
sudo npm install -g prettier @prettier/plugin-php intelephense

# --- 5. Installation de Starship Prompt ---
echo "✨ Installation de Starship..."
# L'option -y automatise la réponse aux questions
curl -sS https://starship.rs/install.sh | sh -s -- -y

# --- 6. Déploiement des dotfiles avec Stow ---
echo "🔗 Déploiement des configurations avec Stow..."
# Se place dans le dossier où se trouve le script (la racine des dotfiles)
cd "$(dirname "$0")"

# Liste de tous vos paquets gérés par Stow
# Adaptez cette liste si vous en ajoutez ou en retirez
packages=(bash git helix kitty starship)

for pkg in "${packages[@]}"; do
    echo "   -> Déploiement de $pkg"
    stow "$pkg"
done

echo ""
echo "✅ Configuration terminée ! Veuillez redémarrer votre terminal pour que tous les changements prennent effet."
