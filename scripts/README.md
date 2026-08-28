# 🛠️ Paquet Stow : Scripts Personnels

Ce paquet contient tous les scripts Bash/Python personnalisés de l'utilisateur.

## 🚀 Le Lanceur TUI : `my_tools`
Pour éviter de devoir mémoriser tous les scripts, tapez simplement `my_tools` dans le terminal.
Un menu interactif (propulsé par `fzf`) listera tous vos scripts et leurs descriptions.

## ➕ Comment ajouter un nouveau script (La Règle d'Or) ?

1. Placez votre script dans `~/.dotfiles/scripts/.local/bin/mon_nouveau_script` sans extension `.sh`.
2. **OBLIGATOIRE :** La ligne 2 de votre script doit contenir sa description pour le lanceur :
   ```bash
   #!/bin/bash
   # Description: Résumé de ce que fait mon script en une ligne
   ```
3. Rendez-le exécutable (chmod +x ...) et redéployez avec stow scripts.
