#!/bin/bash
# Ce script utilise l'image déjà téléchargée par le Makefile

if [ -f /etc/arch-release ]; then
    IMAGE="texlive/texlive:small"
else
    IMAGE="texlive/texlive:latest"
fi

docker run --rm -i --user "$(id -u):$(id -g)" -v "$(pwd):/workdir" -w /workdir $IMAGE latexmk "$@"
