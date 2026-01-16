# Ajout du répertoire bin local.
if [ -d "$HOME/.local/bin" ] && [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# Chemins spécifiques (Composer, NPM).
export PATH="$PATH:/home/fbouillerot/.config/composer/vendor/bin"
export PATH="~/.npm-global/bin:$PATH"

# Éditeur et clés API.
export VISUAL="hx"
export EDITOR="$VISUAL"

# Clés API.
export OPENAI_API_KEY="sk-votre-cle-openai-ici..."

# Navigateur
export BROWSER=chromium
# export BROWSER=firefox
# export BROWSER=google-chrome
# export BROWSER=brave-browser
# export BROWSER=opera
# export BROWSER=vivaldi
