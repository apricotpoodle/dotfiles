# ~/.dotfiles/Makefile
# Gestion des dotfiles avec Stow - Version corrigée (messages make nettoyés)


# =============================================================================
# NETTOYAGE DES MESSAGES MAKE (CORRECTION DU BUG VISUEL)
# =============================================================================
# Empêche l'affichage de "make[1]: on quitte le répertoire..."
# MAKEFLAGS += -s

# =============================================================================
# DÉFINITION DES COULEURS ANSI
# =============================================================================
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
PURPLE := \033[0;35m
CYAN := \033[0;36m
WHITE := \033[1;37m
BOLD := \033[1m
RESET := \033[0m

# =============================================================================
# VARIABLES
# =============================================================================
DOTFILES_DIR := $(shell pwd)
HOME_DIR := $(HOME)

# Détection dynamique des packages (CORRIGÉ)
# Utilise find pour détecter TOUS les dossiers, puis filtre les exclus
PACKAGES := $(shell find . -maxdepth 1 -type d ! -name '.' ! -name '.git' ! -name '.*' -printf '%f\n' 2>/dev/null | sort)

# Liste des exclusions (fichiers et dossiers à ignorer)
EXCLUDED := Makefile README.md readme.md .git .gitignore install.sh check-deps.sh

# =============================================================================
# ÉMOJIS
# =============================================================================
EMOJI_SUCCESS := ✅
EMOJI_ERROR := ❌
EMOJI_WARNING := ⚠️
EMOJI_INFO := ℹ️
EMOJI_STAR := 🚀
EMOJI_PACKAGE := 📦
EMOJI_CHECK := ✔️
EMOJI_CROSS := ✘

# =============================================================================
# HEADER DU MENU (DÉFINI UNE SEULE FOIS)
# =============================================================================
define MENU_HEADER
@clear
@echo ""
@echo "$(BOLD)$(PURPLE)╔═══════════════════════════════════════════════════════════╗$(RESET)"
@echo "$(BOLD)$(PURPLE)║  $(EMOJI_STAR)  Gestion des Dotfiles avec Stow  $(EMOJI_STAR)                   ║$(RESET)"
@echo "$(BOLD)$(PURPLE)╚═══════════════════════════════════════════════════════════╝$(RESET)"
@echo ""
endef

# SHELL := /bin/bash

# =============================================================================
# CIBLES PHARES
# =============================================================================

.PHONY: welcome menu all verify uninstall list list-installed check-deps clean help

welcome:
	$(MENU_HEADER)
# @echo ""
# @echo "$(BOLD)$(PURPLE)╔═══════════════════════════════════════════════════════════╗$(RESET)"
# @echo "$(BOLD)$(PURPLE)║  $(EMOJI_STAR)  Gestion des Dotfiles avec Stow  $(EMOJI_STAR)                   ║$(RESET)"
# @echo "$(BOLD)$(PURPLE)╚═══════════════════════════════════════════════════════════╝$(RESET)"
# @echo ""

# =============================================================================
# INSTALLATION
# =============================================================================

.PHONY: all
all: welcome $(PACKAGES) setup-timers
	@echo ""
	@echo "$(BOLD)$(GREEN)🚀 Tous les packages dotfiles ont été traités.$(RESET)"
	@echo ""

# Installer un package spécifique
# 1. Déclaration propre (SANS le : à la fin)
.PHONY: $(PACKAGES)

# 2. Règle de motif statique (la plus robuste pour GNU Make)
$(PACKAGES): %:
	@echo "$(BOLD)$(GREEN)=== Installation de $@ ===$(RESET)"
	@if [ -d "$(DOTFILES_DIR)/$@" ]; then \
		if stow -v -t $(HOME_DIR) $@ 2>/dev/null; then \
			echo "$(EMOJI_SUCCESS) $(GREEN)$@$(RESET) installé avec succès"; \
		else \
			echo "$(EMOJI_ERROR) $(RED)$@$(RESET) échec de l'installation"; \
			exit 1; \
		fi; \
	else \
		echo "$(EMOJI_ERROR) $(RED)Package $@ introuvable$(RESET)"; \
		exit 1; \
	fi

# =============================================================================
# DÉSINSTALLATION
# =============================================================================

.PHONY: uninstall
uninstall: welcome
	@echo "$(BOLD)$(RED)=== Désinstallation de TOUS les packages ===$(RESET)"
	@echo ""
	@total=0; success=0; \
	for pkg in $(PACKAGES); do \
		total=$$((total + 1)); \
		echo "$(EMOJI_INFO) Désinstallation de $$pkg..."; \
		if stow -t $(HOME_DIR) --delete $$pkg 2>/dev/null; then \
			echo "$(EMOJI_SUCCESS) $(GREEN)$$pkg$(RESET) désinstallé"; \
			success=$$((success + 1)); \
		else \
			echo "$(EMOJI_WARNING) $(YELLOW)$$pkg$(RESET) n'était pas installé"; \
		fi; \
	done; \
	echo ""; \
	echo "$(BOLD)=== Résumé ===$(RESET)"; \
	echo "$(EMOJI_PACKAGE) Total : $$total package(s)"; \
	echo "$(EMOJI_CHECK) Désinstallés : $$success"; \
	echo ""

uninstall-%:
	@echo "$(BOLD)$(RED)=== Désinstallation de $* ===$(RESET)"
	@if stow -t $(HOME_DIR) --delete $* 2>/dev/null; then \
		echo "$(EMOJI_SUCCESS) $(GREEN)$*$(RESET) désinstallé avec succès"; \
	else \
		echo "$(EMOJI_WARNING) $(YELLOW)$*$(RESET) n'était pas installé"; \
	fi

# =============================================================================
# VÉRIFICATION UNIFIÉE (RÉSOLUTION DÉFINITIVE "CHOUX VS CAROTTES")
# =============================================================================

verify: welcome
	@echo "$(BOLD)$(CYAN)=== Vérification de l'intégrité des packages ===$(RESET)"
	@ok=0; error=0; \
	for pkg in $(PACKAGES); do \
		# 1. On compte les fichiers réels (carottes) dans le package \
		expected=$$(find $(DOTFILES_DIR)/$$pkg -type f | wc -l); \
		found_links=0; \
		# 2. Pour chaque fichier, on vérifie sa présence dans le HOME (choux) \
		for f in $$(find $(DOTFILES_DIR)/$$pkg -type f); do \
			rel_path=$${f#$(DOTFILES_DIR)/$$pkg/}; \
			target="$(HOME_DIR)/$$rel_path"; \
			# On vérifie si le fichier est un lien OU si l'un de ses parents est un lien \
			# (Cas où Stow lie le dossier entier comme pour 'scripts' ou 'helix') \
			check_path="$$target"; \
			while [ "$$check_path" != "$(HOME_DIR)" ] && [ "$$check_path" != "/" ]; do \
				if [ -L "$$check_path" ]; then \
					t=$$(readlink "$$check_path"); \
					case "$$t" in *".dotfiles/$$pkg"*) found_links=$$((found_links + 1)); break ;; esac; \
				fi; \
				check_path=$$(dirname "$$check_path"); \
			done; \
		done; \
		if [ "$$found_links" -eq "$$expected" ]; then \
			echo "$(EMOJI_SUCCESS) $(GREEN)$$pkg$(RESET) : Intégrité totale ($$found_links/$$expected)"; \
			ok=$$((ok + 1)); \
		elif [ "$$found_links" -gt 0 ]; then \
			echo "$(EMOJI_WARNING) $(YELLOW)$$pkg$(RESET) : PARTIEL ($$found_links/$$expected trouvé(s))"; \
			error=$$((error + 1)); \
		else \
			echo "$(EMOJI_ERROR) $(RED)$$pkg$(RESET) : Non installé"; \
			error=$$((error + 1)); \
		fi; \
	done

check-%:
	@echo "$(BOLD)$(CYAN)=== Vérification de l'intégrité de $* ===$(RESET)"
	@expected=$$(find $(DOTFILES_DIR)/$* -type f 2>/dev/null | wc -l); \
	if [ "$$expected" -eq 0 ]; then \
		echo "$(EMOJI_ERROR) $(RED)Package $* introuvable$(RESET)"; exit 1; \
	fi; \
	found_links=0; \
	for f in $$(find $(DOTFILES_DIR)/$* -type f); do \
		rel_path=$${f#$(DOTFILES_DIR)/$*/}; \
		target="$(HOME_DIR)/$$rel_path"; \
		check_path="$$target"; \
		while [ "$$check_path" != "$(HOME_DIR)" ] && [ "$$check_path" != "/" ]; do \
			if [ -L "$$check_path" ]; then \
				t=$$(readlink "$$check_path"); \
				case "$$t" in *".dotfiles/$*"*) found_links=$$((found_links + 1)); break ;; esac; \
			fi; \
			check_path=$$(dirname "$$check_path"); \
		done; \
	done; \
	if [ "$$found_links" -eq "$$expected" ]; then \
		echo "$(EMOJI_SUCCESS) $(GREEN)$*$(RESET) : Intégrité totale ($$found_links/$$expected)"; \
	elif [ "$$found_links" -gt 0 ]; then \
		echo "$(EMOJI_WARNING) $(YELLOW)$*$(RESET) : PARTIEL ($$found_links/$$expected trouvé(s))"; \
	else \
		echo "$(EMOJI_ERROR) $(RED)$*$(RESET) : Non installé"; \
	fi

.PHONY: check-sync
check-sync:
	@echo "$(BOLD)$(PURPLE)=== État de la synchronisation ===$(RESET)"
	@if systemctl --user is-active --quiet syncthing; then \
		echo "$(EMOJI_SUCCESS) $(GREEN)Syncthing est actif.$(RESET)"; \
	else \
		echo "$(EMOJI_ERROR) $(RED)Syncthing est arrêté. Lancez 'systemctl --user start syncthing'$(RESET)"; \
	fi

# =============================================================================
# LISTAGE
# =============================================================================

.PHONY: list
list: welcome
	@echo "$(BOLD)$(CYAN)=== Packages disponibles ===$(RESET)"
	@echo ""
	@if [ -z "$(PACKAGES)" ]; then \
		echo "$(EMOJI_WARNING) $(YELLOW)AUCUN PACKAGE DÉTECTÉ$(RESET)"; \
		echo "$(EMOJI_INFO) Créez des dossiers dans $(DOTFILES_DIR)"; \
	else \
		count=0; \
		for pkg in $(PACKAGES); do \
			echo "  $(EMOJI_PACKAGE) $$pkg"; \
			count=$$((count + 1)); \
		done; \
		echo ""; \
		echo "$(BOLD)$(WHITE)Total : $$count package(s)$(RESET)"; \
	fi
	@echo ""

.PHONY: list-installed
list-installed: welcome
	@echo "$(BOLD)$(CYAN)=== Packages installés ===$(RESET)"
	@echo ""
	@if [ -z "$(PACKAGES)" ]; then \
		echo "$(EMOJI_WARNING) $(YELLOW)AUCUN PACKAGE DÉTECTÉ$(RESET)"; \
	else \
		count=0; \
		for pkg in $(PACKAGES); do \
			if [ -L "$(HOME_DIR)/.config/$$pkg" ] || [ -L "$(HOME_DIR)/.$$pkg" ]; then \
				link=$$(readlink "$(HOME_DIR)/.config/$$pkg" 2>/dev/null || readlink "$(HOME_DIR)/.$$pkg" 2>/dev/null); \
				echo "$(EMOJI_SUCCESS) $(GREEN)$$pkg$(RESET) → $$link"; \
				count=$$((count + 1)); \
			fi; \
		done; \
		if [ $$count -eq 0 ]; then \
			echo "$(EMOJI_WARNING) $(YELLOW)Aucun package installé$(RESET)"; \
		fi; \
		echo ""; \
		echo "$(BOLD)$(WHITE)Total : $$count package(s) installé(s)$(RESET)"; \
	fi
	@echo ""


# =============================================================================
# DÉPENDANCES (VERSION OPTIMISÉE)
# =============================================================================

# Liste des commandes à vérifier et leurs paquets respectifs (Debian:Arch)
DEPS := stow:stow git:git borg:borgbackup/borg docker:docker.io/docker

.PHONY: check-deps
check-deps:
	@echo "$(BOLD)$(PURPLE)=== Vérification des dépendances ===$(RESET)"
	@echo ""
	@for item in $(DEPS); do \
		cmd=$${item%%:*}; \
		pkgs=$${item#*:}; \
		deb=$${pkgs%/*}; \
		arch=$${pkgs#*/}; \
		[ "$$deb" = "$$pkgs" ] && arch=$$deb; \
		\
		echo "$(EMOJI_INFO) Vérification de $$cmd..."; \
		if command -v $$cmd >/dev/null 2>&1; then \
			version=$$($$cmd --version 2>&1 | head -n 1); \
			echo "$(EMOJI_SUCCESS) $(GREEN)$$cmd$(RESET) : installé ($$version)"; \
		else \
			echo "$(EMOJI_ERROR) $(RED)$$cmd$(RESET) : NON installé"; \
			echo "  → sudo apt install $$deb (Debian)"; \
			echo "  → sudo pacman -S $$arch (Arch)"; \
		fi; \
		echo ""; \
	done

# =============================================================================
# NETTOYAGE
# =============================================================================

.PHONY: clean
clean:
	@echo "$(BOLD)$(YELLOW)=== Nettoyage ===$(RESET)"
	@echo ""
	@echo "$(EMOJI_INFO) Suppression des fichiers temporaires..."; \
	find . -name "*.swp" -delete 2>/dev/null || true; \
	find . -name "*~" -delete 2>/dev/null || true; \
	find . -name ".DS_Store" -delete 2>/dev/null || true; \
	echo "$(EMOJI_SUCCESS) $(GREEN)Nettoyage terminé$(RESET)"; \
	echo ""

# =============================================================================
# AIDE
# =============================================================================

.PHONY: help
help: welcome
	@echo "$(BOLD)$(CYAN)=== Commandes disponibles ===$(RESET)"
	@echo ""
	@echo "$(BOLD)$(GREEN)Installation :$(RESET)"
	@echo "  $(CYAN)make all$(RESET)              - Installer TOUS les packages"
	@echo "  $(CYAN)make bashrc$(RESET)           - Installer uniquement bashrc"
	@echo "  $(CYAN)make espanso$(RESET)          - Installer uniquement espanso"
	@echo "  $(CYAN)make i3$(RESET)               - Installer uniquement i3"
	@echo ""
	@echo "$(BOLD)$(GREEN)Vérification :$(RESET)"
	@echo "  $(CYAN)make verify$(RESET)           - Vérifier TOUS les packages"
	@echo "  $(CYAN)make check-bashrc$(RESET)     - Vérifier un package spécifique"
	@echo ""
	@echo "$(BOLD)$(GREEN)Désinstallation :$(RESET)"
	@echo "  $(CYAN)make uninstall$(RESET)        - Désinstaller TOUS les packages"
	@echo "  $(CYAN)make uninstall-bashrc$(RESET) - Désinstaller uniquement bashrc"
	@echo ""
	@echo "$(BOLD)$(GREEN)Listage :$(RESET)"
	@echo "  $(CYAN)make list$(RESET)             - Lister les packages disponibles"
	@echo "  $(CYAN)make list-installed$(RESET)   - Lister les packages installés"
	@echo ""
	@echo "$(BOLD)$(GREEN)Autres :$(RESET)"
	@echo "  $(CYAN)make help$(RESET)             - Afficher cette aide"
	@echo "  $(CYAN)make check-deps$(RESET)       - Vérifier les dépendances"
	@echo "  $(CYAN)make clean$(RESET)            - Nettoyer les fichiers temporaires"
	@echo ""
	@echo "$(BOLD)$(WHITE)Packages détectés :$(RESET) $(PACKAGES)"
	@echo ""

# =============================================================================
# MENU INTERACTIF (VERSION CORRIGÉE)
# =============================================================================

.PHONY: menu
menu:
	@clear
	$(MENU_HEADER)
	@echo "$(CYAN)1)$(RESET) Installer TOUS les packages"
	@echo "$(CYAN)2)$(RESET) Installer un package spécifique"
	@echo "$(CYAN)3)$(RESET) Désinstaller TOUS les packages"
	@echo "$(CYAN)4)$(RESET) Désinstaller un package spécifique"
	@echo "$(CYAN)5)$(RESET) Vérifier TOUS les packages"
	@echo "$(CYAN)6)$(RESET) Lister les packages disponibles"
	@echo "$(CYAN)7)$(RESET) Lister les packages installés"
	@echo "$(CYAN)8)$(RESET) Vérifier les dépendances"
	@echo "$(CYAN)9)$(RESET) Aide"
	@echo "$(CYAN)0)$(RESET) Quitter"
	@echo ""
	@read -p "$(EMOJI_INFO) Choisissez une option (0-9) : " choice; \
	case "$$choice" in \
		1) $(MAKE) all ;; \
		2) read -p "$(EMOJI_INFO) Nom du package : " pkg; $(MAKE) $$pkg ;; \
		3) $(MAKE) uninstall ;; \
		4) read -p "$(EMOJI_INFO) Nom du package : " pkg; $(MAKE) uninstall-$$pkg ;; \
		5) $(MAKE) verify ;; \
		6) $(MAKE) list ;; \
		7) $(MAKE) list-installed ;; \
		8) $(MAKE) check-deps ;; \
		9) $(MAKE) help ;; \
		0) echo "$(EMOJI_SUCCESS) Au revoir !"; exit 0 ;; \
		*) echo "$(EMOJI_ERROR) Option invalide"; sleep 1; $(MAKE) menu ;; \
	esac

# =============================================================================
# GESTION DES IMAGES LATEX (DOCKER)
# =============================================================================

.PHONY: setup-latex
setup-latex:
	@echo "$(BOLD)$(PURPLE)=== Configuration de l'image TeX Live ===$(RESET)"
	@if [ -f /etc/arch-release ]; then \
		echo "$(EMOJI_INFO) Machine Arch détectée (Pentium). Utilisation de l'image SMALL."; \
		docker pull texlive/texlive:small; \
	else \
		echo "$(EMOJI_INFO) Machine Debian détectée (XPS). Utilisation de l'image LATEST."; \
		docker pull texlive/texlive:latest; \
	fi
	@echo "$(EMOJI_SUCCESS) Image prête pour vlatex."



# =============================================================================
# GESTION DE LA SAUVEGARDE (Borg & Systemd)
# =============================================================================

.PHONY: backup
backup:
	@echo "$(BOLD)$(BLUE)=== Lancement manuel de la sauvegarde ===$(RESET)"
	@bash $(HOME_DIR)/.local/bin/backup-borg.sh

.PHONY: setup-timers
setup-timers:
	@echo "$(BOLD)$(PURPLE)=== Activation des automates de sauvegarde ===$(RESET)"
	@systemctl --user daemon-reload
	@systemctl --user enable --now backup-borg.timer
	@systemctl --user enable --now backup-remoteness.timer
	@echo "$(EMOJI_SUCCESS) Timers activés (Hebdomadaire & Mensuel)."

# Ton bouton "Magique" pour un nouveau PC
.PHONY: install
install: check-deps bashrc scripts helix setup-timers
	@echo "$(BOLD)$(GREEN)🚀 PRA terminé : Système prêt et sauvegardes actives !$(RESET)"

# =============================================================================
# CIBLE PAR DÉFAUT
# =============================================================================

.DEFAULT_GOAL := help
