#!/bin/bash

# Affiche la mémoire libre, utilisé, libre, utilisé et le cache de la mémoire en kB.
recup_mem() { # Tim Lamour
    # Vérifie le nombre de paramètres
    test "$#" -ne 1 && echo "Un seul paramètre est requis. Utilisez 'total', 'available', 'free', 'cache', ou 'used'." && return 1
    # Vérifie si le fichier meminfo existe
    test ! -f "/proc/meminfo" && echo "Le fichier meminfo n'existe pas" && return 2

    local param="$1" # Récupère le premier argument comme paramètre

    # Lit les informations de mémoire depuis /proc/meminfo
    local info_mem=$(cat /proc/meminfo)
    local res=""
    # Renvoie l'information demandée en fonction du paramètre
    case $param in
        "total") # Mémoire totale
            res=$(echo "$info_mem" | grep "MemTotal" | awk '{print $2}') 
            ;;
        "available") # Mémoire disponible
            res=$(echo "$info_mem" | grep "MemAvailable" | awk '{print $2}')
            ;;
        "free") # Mémoire libre
            res=$(echo "$info_mem" | grep "MemFree" | awk '{print $2}') 
            ;;
        "cache") # Mémoire cache
            res=$(echo "$info_mem" | grep "Cached" | awk '{print $2}') 
            ;;
        "used") # Mémoire utilisée
            local mem_total=$(echo "$info_mem" | grep "MemTotal" | awk '{print $2}')
            local mem_available=$(echo "$info_mem" | grep "MemAvailable" | awk '{print $2}')
            res=$((mem_total - mem_available)) 
            ;;
        *)
            echo "Paramètre non reconnu. Utilisez 'total', 'available', 'free', 'cache', ou 'used'."
            return 1
            ;;
    esac
    echo "$res"
}


recup_nb_core_cpu() { # Tim Lamour
    nproc
}

# Renvoie les infos sur le cpu, usage : recup_cpu ['name' | 'cpu']
recup_cpu() { # Tim Lamour
    # Vérifier le nombre de paramètres
    test "$#" -ne 1 && echo "Usage : recup_cpu ['name' | 'cpu{0,1,n}']" && return 1

    # Si un seul paramètre, vérifier que c'est "name"
    if [ "$1" == "name" ]; then
        # Vérifier l'existence de /proc/cpuinfo et récupérer le nom du CPU
        test ! -f /proc/cpuinfo && echo "Erreur : Le fichier /proc/cpuinfo n'existe pas" && return 2

        # On récupère le nom du cpu
        local cpu_name=$(grep "model name" /proc/cpuinfo | uniq | awk -F: '{print $2}' | sed 's/^ *//')
        echo "$cpu_name"
        return 0

    elif [[ "$1" =~ ^cpu([0-9]+)?$ ]]; then
        # Vérifier l'existence de /proc/stat pour récupérer les infos du CPU
        test ! -f /proc/stat && echo "Erreur : Le fichier /proc/stat n'existe pas" && return 3
        
        local nb_core=$(nproc)  # on recupere le nombre de coeur du cpu

        # Extraire le numéro de CPU demandé
        local num=${BASH_REMATCH[1]:-""}
        if [[ -z "$num" ]]; then
            num="cpu"  # Total du CPU
        else
            # Vérifier que le numéro du coeur est valide
            if [ "$num" -gt "$nb_core" ] || [ "$num" -lt 1 ]; then
                echo "Erreur : CPU $num inexistant. Nombre de cœurs : $nb_core."
                return 4
            fi
            num="cpu$((num - 1))" #Total du core num du CPU
        fi

        # Récupérer la ligne correspondant au CPU demandé dans /proc/stat
        local lign=$(grep "^$num " /proc/stat)

        # Extraire les valeurs user, nice, system, idle
        local user=$(echo "$lign" | awk '{print $2}')
        local nice=$(echo "$lign" | awk '{print $3}')
        local system=$(echo "$lign" | awk '{print $4}')
        local idle=$(echo "$lign" | awk '{print $5}')

        # Calculer le total de toutes les valeurs
        local total=$(echo "$lign" | awk '{sum=0; for(i=2; i<=NF; i++) sum+=$i; print sum}')

        # Calculer l'utilisation du CPU en pourcentage
        local cpu_usage=""
        if [ "$total" -ne 0 ]; then
            cpu_usage=$(( (user + nice + system) * 100 / total ))
        else
            cpu_usage=0
        fi

        echo "$cpu_usage"
        return 0
    fi

    # Message d'erreur si les paramètres sont incorrects
    echo "Usage : recup_cpu ['name' | 'cpu{0,1,n}']"
    return 4
}


# Renvoie le pourcentage d'utilisation, l'utilisation et la VRAM total du GPU.
recup_gpu() { # Tim Lamour
    # Vérifie s'il y a exactement un paramètre
    test "$#" -ne 1 && echo "Un seul paramètre est requis. Utilisez 'percent', 'vramUsed', 'vramTotal'." && return 1

    # On teste si les répertoires card0 ou card1 existent (card0 prioritaire)
    local path="/sys/class/drm/card"
    if [ -d "${path}0" ] && [ -f "${path}0/device/gpu_busy_percent" ]; then
        path="${path}0"
    elif [ -d "${path}1" ] && [ -f "${path}1/device/gpu_busy_percent" ]; then
        path="${path}1"
    else
        return 1
    fi
    # Si un répertoire a été trouvé
    local param=$1
    local res=""

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
            return 1
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
    local param="$1" # recupere le premier argument comme paramètre

    local info_disk=$(df -h .)
    local res=""

    case $param in
        "percent")
            res=$(echo "$info_disk" | awk 'NR==2 {print $5}')
            ;;
        "name")
            res=$(echo "$info_disk" | awk 'NR==2 {print $1}')
            ;;
        "total")
            res=$(echo "$info_disk" | awk 'NR==2 {print $2}')
            ;;
        "used")
            res=$(echo "$info_disk" | awk 'NR==2 {print $3}')
            ;;
        *)
            echo "Paramètre non reconnu. Utilisez 'percent', 'name', 'total', 'used'."
            return 1
            ;;
    esac
    if [ -n "$res" ]; then
        res=$(echo "$res" | grep -o '[0-9]*.');
    fi
    echo "$res"
}

# Renovie le nom de l'interface actuellement utilisé
get_interface_name() { # Tim Lamour
    # Liste toutes les interfaces réseau disponibles
    local interfaces=$(ls /sys/class/net)

    # Boucle pour vérifier chaque interface
    for interface in $interfaces; do
        # Vérifie si l'interface est active (état UP)
        if [[ $(cat /sys/class/net/$interface/operstate) == "up" ]]; then
            echo "$interface"
            return 0
        fi
    done

    # Si aucune interface active n'est trouvée
    echo ""
}

# Renvoie les bytes d'updload ou de download du réseau
get_network() { # Tim Lamour & Jamel Bailleul
    # Vérifier le nombre de paramètres
    test "$#" -ne 2 && echo "Usage : get_network [download | downloadPackets | downloadErr | upload | uploadPackets | uploadErr ] nom_interface_reseau" && return 1
    # Vérifier que le fichier /proc/net/dev existe
    test ! -f /proc/net/dev && echo "Erreur : Le fichier /proc/net/dev n'existe pas" && return 2

    local param="$1"
    local interface=$(grep "$2" /proc/net/dev)
    
    local res=""
    case "$param" in
        "download")
            res=$(echo "$interface" | awk '{print $2}')
            ;;
        "downloadPackets")
            res=$(echo "$interface" | awk '{print $3}')
            ;;
        "downloadErr")
            res=$(echo "$interface" | awk '{print $4}')
            ;;
        "upload")
            res=$(echo "$interface" | awk '{print $10}')
            ;;
        "uploadPackets")
            res=$(echo "$interface" | awk '{print $11}')
            ;;
        "uploadErr")
            res=$(echo "$interface" | awk '{print $12}')
            ;;
        *)
            echo "Paramètre non reconnu. Utilisez 'download' ou 'upload'."
            return 1
            ;;
    esac

    echo "$res"
}
