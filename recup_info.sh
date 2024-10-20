#!/bin/bash

# Affiche la mémoire libre, utilisé, libre, utilisé et le cache de la mémoire en kB.
recup_mem() { # Tim Lamour
    test "$#" -ne 1 && echo "Un seul paramètre est requis. Utilisez 'total', 'available', 'free', 'cache', ou 'used'." && exit 1
    param="$1" # recupere le premier argument comme paramètre

    # renvoie une chaine vide si le le fichier meminfo n'existe pas
    if [ ! -f "/proc/meminfo" ]; then
        exit 1
    fi

    info_mem=$(cat /proc/meminfo)
    res=""

    # renvoie l'info demande en parametre
    case $param in
        "total") # mémoire total
            res=$(echo "$info_mem" | grep "MemTotal" | awk '{print $2}') 
            ;;
        "available") # mémoire disponible
            res=$(echo "$info_mem" | grep "MemAvailable" | awk '{print $2}')
            ;;
        "free") # mémoire libre
            res=$(echo "$info_mem" | grep "MemFree" | awk '{print $2}') 
            ;;
        "cache") # cache de la mémoire
            res=$(echo "$info_mem" | grep "Cached" | awk '{print $2}') 
            ;;
        "used") # mémoire actuellement utilisé
            mem_total=$(echo "$info_mem" | grep "MemTotal" | awk '{print $2}')
            mem_available=$(echo "$info_mem" | grep "MemAvailable" | awk '{print $2}')
            res=$((mem_total - mem_available)) 
            ;;
        *)
            echo "Paramètre non reconnu. Utilisez 'total', 'available', 'free', 'cache', ou 'used'."
            exit 1
            ;;
    esac
    echo "$res"
}


get_cpu_usage() {
    # Lire les données initiales du CPU
    read cpu a b c idle rest < /proc/stat

    # Somme de tous les temps d'activité
    total=$((a+b+c+idle))

    # Pause pour une mesure à intervalle
    sleep 1

    # Lire les données du CPU après l'intervalle
    read cpu a b c idle rest < /proc/stat

    # Somme de tous les temps d'activité après l'intervalle
    total_new=$((a+b+c+idle))

    # Calcul de la variation du total et de l'inactivité
    total_delta=$((total_new - total))
    idle_delta=$((idle - idle))

    # Calcul du pourcentage d'utilisation
    cpu_usage=$((100 * (total_delta - idle_delta) / total_delta))

    echo "Utilisation globale du CPU : $cpu_usage %"
}

recup_cpu() {
    info_cpu=$(cat /proc/cpuinfo)
    cpu_name=$(echo "$info_cpu" | grep "model name" | uniq | awk -F: '{print $2}' | sed 's/^ *//')

    echo "$cpu_name"
}

# Renvoie le pourcentage d'utilisation, l'utilisation et la VRAM total du GPU.
recup_gpu() { # Tim Lamour
    # Vérifie s'il y a exactement un paramètre
    test "$#" -ne 1 && echo "Un seul paramètre est requis. Utilisez 'percent', 'vramUsed', 'vramTotal'." && exit 1

    # On teste si les répertoires card0 ou card1 existent (card0 prioritaire)
    path="/sys/class/drm/card"
    if [ -d "${path}0" ] && [ -f "${path}0/device/gpu_busy_percent" ]; then
        path="${path}0"
    elif [ -d "${path}1" ] && [ -f "${path}1/device/gpu_busy_percent" ]; then
        path="${path}1"
    else
        exit 1
    fi
    # Si un répertoire a été trouvé
    param=$1
    res=""

    # Renvoie l'info demandée en paramètre
    case $param in
        "percent") # Pourcentage d'utilisation (en %)
            res=$(cat "${path}/device/gpu_busy_percent") 
            ;;
        "vramUsed") # VRAM utilisé (en kB)
            res=$(cat "${path}/device/mem_info_vram_used") 
            ;;
        "vramTotal") # VRAM total (en kB)
            res=$(cat "${path}/device/mem_info_vram_total")  
            ;;
        *)
            echo "Paramètre non reconnu. Utilisez 'percent', 'vramUsed' ou 'vramTotal'."
            exit 1
            ;;
    esac

    # Affichage du résultat
    echo "$res"
}


# Affiche la liste des processus (utilise la commande ps aux).
recup_processus() { # Tim Lamour
    ps aux
}

# Affiche les pourcentages d'utilisations, les noms, l'espace total ou les l'espace utilisé des partitions de disques (sous forme de liste)
recup_disk() { # Tim Lamour
    test "$#" -ne 1 && echo "Un seul paramètre est requis. Utilisez 'percent', 'name', 'total', 'used'." && exit 1
    param="$1" # recupere le premier argument comme paramètre

    info_disk=$(df -h | grep '^/dev/')
    res=""

    case $param in
        "percent")
            res=$(echo "$info_disk" | awk '{print $5}')
            ;;
        "name")
            res=$(echo "$info_disk" | awk '{print $1}')
            ;;
        "total")
           res=$(echo "$info_disk" | awk '{print $2}')
            ;;
        "used")
            res=$(echo "$info_disk" | awk '{print $3}')
            ;;
        *)
            echo "Paramètre non reconnu. Utilisez 'percent', 'name', 'total', 'used'."
            exit 1
            ;;
    esac
    res=$(echo "$res" | grep -o '[0-9]*.');
    echo "$res"
}

#recup_disk name
#recup_mem total