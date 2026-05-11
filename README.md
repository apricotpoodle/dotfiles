# 📁 Dotfiles avec Stow (version cachée)

Gestion centralisée des dotfiles avec **GNU Stow** et **Makefile**.
Répertoire : `~/.dotfiles` (caché, conforme convention Unix)

## 🚀 Installation Rapide

```bash
# 1. Créer le dossier caché
mkdir -p ~/.dotfiles
cd ~/.dotfiles

# 2. Initialiser Git
git init

# 3. Vérifier les dépendances
make check-deps

# 4. Installer tous les packages
make all

# 5. Vérifier l'installation
make verify
