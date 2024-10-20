#!/bin/bash

# Fonction pour exporter les variables d'un fichier de configuration
exporter_variables() {
    local fichier="$1"

    if [[ -f "$fichier" ]]; then # Vérifie si le fichier existe
        while IFS='=' read -r cle valeur; do # Boucle pour lire chaque ligne du fichier
            if [[ -n "$cle" && -n "$valeur" ]]; then
                export "$cle"="$valeur" # Exporter chaque clé comme une variable d'environnement
            fi
        done < "$fichier"
        echo "Les variables d'environnement ont été définies."
    else
        echo "Le fichier '$fichier' n'existe pas."
    fi
}

exporter_variables "config.txt"

echo "font_color=$font_color"
echo "color=$color"
echo "lang=$lang"
echo "os=$os"