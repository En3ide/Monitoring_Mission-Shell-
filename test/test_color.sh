#!/bin/bash

# Codes ANSI pour le fond blanc et le texte noir
BACKGROUND_WHITE="\033[48;5;255m"  # Fond blanc
TEXT_BLACK="\033[30m"               # Texte noir
RESET="\033[0m"                      # Réinitialiser les attributs

# Message de bienvenue
MESSAGE="Bienvenue dans notre programme !"

# Affichage du message
echo -e "${BACKGROUND_WHITE}${TEXT_BLACK}${MESSAGE}${RESET}"
