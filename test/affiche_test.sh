#!/bin/bash
. ./recup_info.sh

# Définir les couleurs
red="\033[31m"
green="\033[32m"
yellow="\033[33m"
blue="\033[34m"
reset="\033[0m"

carre_plein="\u2588"
carre_vide="\u25A1"

# Fonction pour générer un nombre aléatoire
generate_random() {
    local min=$1
    local max=$2
    local range=$((max - min + 1))
    local random_number=$((RANDOM % range + min))
    echo "$random_number"
}

# Effacer l'écran
clear_screen() {
    clear
}

# Fonction pour afficher les informations système
info_reduite() {
    local output=""
    
    # Mémoire
    if recup_mem "used" >/dev/null 2>&1; then
        max=100 #$(recup_mem total)
        current=$(generate_random 1 $max) #$(recup_mem used)
        output+="Memory: ${current}/${max} MB\n"
        output+="["
        output+=$(printf "%-${current}s" "#" | tr ' ' '=')
        output+=$(printf "%-$((max-current))s" " " | tr ' ' ' ')
        output+="] $((current * 100 / max))% used\n"
    fi

    # CPU
    erreur=$(recup_cpu 2>&1)
    if (( $? != 1 )); then
        cpu_usage=$(recup_cpu)
        output+="CPU: $cpu_usage%\n"
        max=100
        current=$(generate_random 1 $max)
        output+="["
        output+=$(printf "%-${current}s" "#" | tr ' ' '=')
        output+=$(printf "%-$((max-current))s" " " | tr ' ' ' ')
        output+="] $((current * 100 / max))% used\n"
    fi

    # GPU
    if recup_gpu vramUsed >/dev/null 2>&1; then
        output+="GPU: ${current}/${max} MB\n"
        max=100
        current=$(generate_random 1 $max) #$(recup_gpu vramUsed)
        output+="["
        output+=$(printf "%-${current}s" "#" | tr ' ' '=')
        output+=$(printf "%-$((max-current))s" " " | tr ' ' ' ')
        output+="] $((current * 100 / max))% used\n"
    else
        output+="GPU: info sur le GPU impossible à trouver\n"
    fi

    # Disque
    if recup_disk used >/dev/null 2>&1; then
        max=100 #$(recup_disk total | grep -o '[0-9.]*')
        current=$(generate_random 1 $max) #$(recup_disk used | grep -o '[0-9.]*')
        output+="Disk: ${current}/${max} MB\n"
        output+="["
        output+=$(printf "%-${current}s" "#" | tr ' ' '=')
        output+=$(printf "%-$((max-current))s" " " | tr ' ' ' ')
        output+="] $((current * 100 / max))% used\n"
    else
        output+="Disk: info sur le disque impossible à trouver\n"
    fi

    # Retourner le contenu pour affichage
    echo -e "$output"
}

# Fonction pour afficher les processus
afficher_processus() {
    echo -e "\nTop 10 processes:\n"
    ps -eo pid,comm,%cpu,%mem --sort=-%mem | head -n 10
}

# Fonction principale
main() {
    clear_screen

    while true; do
        clear_screen
        
        # Obtenir la largeur du terminal
        cols=$(tput cols)

        # Diviser l'espace
        let "right_width=cols/3"
        let "left_width=cols-right_width"

        # Afficher les informations système sur la gauche
        {
            info_reduite
        } | column -t -s $'\n' | awk -v width="$left_width" '{printf "%-*s\n", width, $0}'

        # Afficher les processus sur la droite
        {
            afficher_processus
        } | awk -v width="$right_width" '{printf "%-*s\n", width, $0}' | sed 's/^/   /' # Décalage pour la droite

        # Pause d'une seconde avant la mise à jour
        sleep 1
    done
}

main "$@"
