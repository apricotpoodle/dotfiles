# 🐚 Paquet Stow : Environnement Bash

Ce paquet centralise l'intégralité de la configuration du terminal Bash de l'utilisateur. Il inclut le fichier principal, le chargement modulaire des sous-scripts, et un système dynamique de règles d'autocomplétion.

## 🏗️ Architecture Modulaire

- **`.bashrc`** : Le point d'entrée principal lu au démarrage du terminal.
- **`.bashrc.d/*.sh`** : Scripts exécutés automatiquement au lancement (alias, variables d'environnement, chargeurs).
- **`.bash_completions.d/*.bash`** : Définitions des règles d'autocomplétion (touche `TAB`) pour les commandes personnalisées.

---

## 🪄 Autocomplétion : Mode d'Emploi

Le script `10-completions.sh` scrute automatiquement le dossier `.bash_completions.d/` et charge toutes les règles actives qu'il contient.

### Comment ajouter l'autocomplétion pour un nouveau script ?

Pour vous faire gagner du temps, un patron (*template*) est mis à votre disposition.

1. **Dupliquer le patron** pour créer votre fichier de règle (portant le nom de votre script) :
   ```bash
   cd ~/.dotfiles/bashrc/.bash_completions.d/
   cp _template.bash.example mon_nouveau_script.bash
   ```
2. Éditer le fichier `mon_nouveau_script.bash` :
    - Remplacer toute occurrence de `NOM_SCRIPT` par le nom réel de votre exécutable.
    - Modifiez la variable `opts="--mes --flags"` pour y lister les paramètres attendus par votre script.

3. Déployer et recharger :
   ```bash
   cd ~/.dotfiles
   stow bashrc
   source ~/.bashrc
   ```
