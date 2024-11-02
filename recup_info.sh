#!/bin/bash

# Affiche la mémoire libre, utilisé, libre, utilisé et le cache de la mémoire en kB.
recup_mem() { # Tim Lamour
    test "$#" -ne 1 && echo "Un seul paramètre est requis. Utilisez 'total', 'available', 'free', 'cache', ou 'used'." && return 1

    # test si le fichier meminfo existe
    test ! -f "/proc/meminfo" && echo "Le fichier meminfo n'existe pas" && return 1

    param="$1" # recupere le premier argument comme paramètre

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
            return 1
            ;;
    esac
    echo "$res"
}

recup_nb_core_cpu() {
    nproc
}

# Renvoie les infos sur le cpu, usage : recup_cpu ['name' | 'cpu']
recup_cpu() { 
    # Vérifier le nombre de paramètres
    test "$#" -ne 1 && echo "Usage : recup_cpu ['name' | 'cpu{0,1,n}']" && return 1

    # Si un seul paramètre, vérifier que c'est "name"
    if [ "$#" -eq 1 ]; then
        if [ "$1" == "name" ]; then
            # Vérifier l'existence de /proc/cpuinfo et récupérer le nom du CPU
            test ! -f /proc/cpuinfo && echo "Erreur : Le fichier /proc/cpuinfo n'existe pas" && return 2
            cpu_name=$(grep "model name" /proc/cpuinfo | uniq | awk -F: '{print $2}' | sed 's/^ *//')
            echo "$cpu_name"
            return 0
        elif [[ "$1" =~ ^cpu([0-9]+)?$ ]]; then
            # Vérifier l'existence de /proc/stat pour récupérer les infos du CPU
            test ! -f /proc/stat && echo "Erreur : Le fichier /proc/stat n'existe pas" && return 3
            
            nb_core=$(nproc)  # on recupere le nombre de coeur du cpu

            # Extraire le numéro de CPU demandé
            num=${BASH_REMATCH[1]:-""}
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
            lign=$(grep "^$num " /proc/stat)

            # Extraire les valeurs user, nice, system, idle
            user=$(echo "$lign" | awk '{print $2}')
            nice=$(echo "$lign" | awk '{print $3}')
            system=$(echo "$lign" | awk '{print $4}')
            idle=$(echo "$lign" | awk '{print $5}')

            # Calculer le total de toutes les valeurs
            total=$(echo "$lign" | awk '{sum=0; for(i=2; i<=NF; i++) sum+=$i; print sum}')

            # Calculer l'utilisation du CPU en pourcentage
            if [ "$total" -ne 0 ]; then
                cpu_usage=$(( (user + nice + system) * 100 / total ))
            else
                cpu_usage=0
            fi
 
            echo "$cpu_usage"
            return 0
        fi
    fi

    # Message d'erreur si les paramètres sont incorrects
    echo "Usage : recup_cpu ['name' | 'cpu{0,1,n}']" && return 5
}


# Renvoie le pourcentage d'utilisation, l'utilisation et la VRAM total du GPU.
recup_gpu() { # Tim Lamour
    # Vérifie s'il y a exactement un paramètre
    test "$#" -ne 1 && echo "Un seul paramètre est requis. Utilisez 'percent', 'vramUsed', 'vramTotal'." && return 1

    # On teste si les répertoires card0 ou card1 existent (card0 prioritaire)
    path="/sys/class/drm/card"
    if [ -d "${path}0" ] && [ -f "${path}0/device/gpu_busy_percent" ]; then
        path="${path}0"
    elif [ -d "${path}1" ] && [ -f "${path}1/device/gpu_busy_percent" ]; then
        path="${path}1"
    else
        return 1
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
    param="$1" # recupere le premier argument comme paramètre

    info_disk=$(df -h .)
    res=""

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
            res=$(echo "$info_disk" | awk 'NR==2 {print $2}')
            ;;
        *)
            echo "Paramètre non reconnu. Utilisez 'percent', 'name', 'total', 'used'."
            return 1
            ;;
    esac
    res=$(echo "$res" | grep -o '[0-9]*.');
    echo "$res"
}
