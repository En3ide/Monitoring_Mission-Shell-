#!/bin/bash
# Chargement du script d'information
. ./recup_info.sh

# Variables de couleur
font_color_default="\033[38;5;231m"  # Couleur par défaut (texte blanc)
color_default="\033[48;5;196m"       # Fond rouge par défaut
reset="\033[0m"                       # Réinitialisation des couleurs
carre_plein="\u2588"                  # Caractère pour barre pleine
carre_vide="\u25A1"                   # Caractère pour barre vide

# Fonction de génération aléatoire pour la simulation de valeurs
generate_random() {
    local min=$1
    local max=$2
    echo $(( RANDOM % (max - min + 1) + min ))
}

# Fonction pour dessiner une bordure avec remplissage
clear_screen() {
    local cols=$(tput cols)
    local lines=$(tput lines)
    local output=""

    for ((i=1; i<=lines; i++)); do
        for ((j=1; j<=cols; j++)); do
            if (( i == 1 || i == lines || j == 1 || j == cols )); then
                output+=$(printf "\033[%d;%dH${font_color_default}${color_default}+${reset}" "$i" "$j")
            else
                output+=$(printf "\033[%d;%dH${color_default} ${reset}" "$i" "$j")
            fi
        done
    done
    echo -e "$output"
}

# Affichage d'une barre de progression
print_bar_h() {
    local res="$1"
    local x=$2
    local y=$3
    local current=$4
    local max=$5
    local percent=$(( current * 100 / max ))
    local bar=""
    local output=""

    for ((i=0; i<10; i++)); do
        if (( i < percent / 10 )); then
            bar+="$carre_plein"
        else
            bar+="$carre_vide"
        fi
    done
    output=$(printf "\033[%d;%dH${res}${bar}${reset} ${percent}%%" "$y" "$x")
    echo -e "$output"
}

# Affichage des infos système avec des barres de progression
info_reduite() {
    local x=$1
    local y=$2
    local width=$3
    local output=""

    output+=$(printf "\033[%d;%dHMemory :" "$x" "$y")
    local mem_used=$(generate_random 1 100)
    output+=$(print_bar_h "${font_color_default}${color_default}" "$((y+9))" "$x" "$mem_used" 100)

    output+=$(printf "\033[%d;%dHCPU :" "$((x+3))" "$y")
    local cpu_used=$(generate_random 1 100)
    output+=$(print_bar_h "${font_color_default}${color_default}" "$((y+9))" "$((x+3))" "$cpu_used" 100)

    output+=$(printf "\033[%d;%dHGPU :" "$((x+6))" "$y")
    local gpu_used=$(generate_random 1 100)
    output+=$(print_bar_h "${font_color_default}${color_default}" "$((y+9))" "$((x+6))" "$gpu_used" 100)

    output+=$(printf "\033[%d;%dHDisk :" "$((x+9))" "$y")
    local disk_used=$(generate_random 1 100)
    output+=$(print_bar_h "${font_color_default}${color_default}" "$((y+9))" "$((x+9))" "$disk_used" 100)

    echo -e "$output"
}

# Fonction pour charger un fichier de configuration
config_file() {
    local fichier="$1"
    if [[ -f "$fichier" ]]; then
        while IFS='=' read -r cle valeur; do
            export "$cle=$valeur"
        done < "$fichier"
        echo "Les variables d'environnement ont été définies."
    else
        echo "Le fichier '$fichier' n'existe pas."
    fi
}

# Installation automatique de bc si non installé
install_bc_if_not_installed() {
    if ! command -v bc &> /dev/null; then
        sudo apt update -y > /dev/null 2>&1
        sudo apt install -y bc > /dev/null 2>&1
    fi
}

# Fonction principale
main() {
    # Configuration de l'affichage
    stty -icanon -echo
    trap "stty sane; exit" INT TERM

    # Chargement d'un fichier de configuration si fourni
    if [[ -f "$1" ]]; then
        config_file "$1"
    else
        echo "Le fichier '$1' n'existe pas."
    fi

    local output=""
    output+=$(clear_screen)
    local cols=$(tput cols)
    local lines=$(tput lines)

    while true; do
        if (( $(tput cols) != cols || $(tput lines) != lines )); then
            output+=$(clear_screen)
        fi

        if (( $(tput cols) <= 30 || $(tput lines) <= 15 )); then
            output+=$(info_reduite 2 3 $(( $(tput cols) - 2 )))
        fi

        echo -e "$output"
        sleep 0.1
    done
    stty sane
}

# Exécution de la fonction principale
main "$@"
stty sane

