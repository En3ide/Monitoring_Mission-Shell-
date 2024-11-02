. ./recup_info.sh

#recup_disk "used"
#recup_disk "total"

cpu_usage_proc_stat() {
    # Lire les premières valeurs de la ligne "cpu" dans /proc/stat
    local cpu=($(grep '^cpu ' /proc/stat))
    local idle1=${cpu[4]} # Temps d'inactivité initial
    local total1=0

    # Calculer le total initial des temps CPU
    for value in "${cpu[@]:1}"; do
        total1=$((total1 + value))
    done

    # Pause d'une seconde
    sleep 1

    # Lire les valeurs finales de la ligne "cpu" dans /proc/stat
    cpu=($(grep '^cpu ' /proc/stat))
    local idle2=${cpu[4]} # Temps d'inactivité final
    local total2=0

    # Calculer le total final des temps CPU
    for value in "${cpu[@]:1}"; do
        total2=$((total2 + value))
    done

    # Calculer la différence de temps total et de temps d'inactivité
    local total_diff=$((total2 - total1))
    local idle_diff=$((idle2 - idle1))

    # Calculer le pourcentage d'utilisation du CPU
    local usage=$((100 * (total_diff - idle_diff) / total_diff))

    echo "Utilisation CPU : $usage%"
}

cpu_usage_top() {
    # Utiliser top en mode batch et en filtrant la ligne avec %Cpu(s)
    local usage=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
    echo "Utilisation CPU : ${usage}%"
}

cpu_usage_vmstat() {
    # Utiliser vmstat et prendre la deuxième ligne (car la première est un en-tête)
    local idle=$(vmstat 1 2 | tail -1 | awk '{print $15}')
    local usage=$((100 - idle))
    echo "Utilisation CPU : ${usage}%"
}

cpu_usage() {
    # Utiliser mpstat et prendre le dernier champ (idle) pour tous les CPU
    local idle=$(mpstat 1 1 | tail -1 | awk '{print $NF}')
    local usage=$(echo "100 - $idle" | bc)
    echo "Utilisation CPU : ${usage}%"
}

network_info_v1() {
    if [[ "$1" == "list" ]]; then
        # Lister les noms des interfaces disponibles
        awk -F':' '/:/ {print $1}' /proc/net/dev | tr -d ' '
    elif [[ -n "$1" && -n "$2" ]]; then
        local interface="$1"
        local direction="$2"

        # Vérifier si l'interface existe
        if ! grep -q "^ *$interface:" /proc/net/dev; then
            echo "L'interface '$interface' n'existe pas."
            return 1
        fi

        # Récupérer les statistiques de l'interface
        local stats=$(grep "^ *$interface:" /proc/net/dev | awk '{print $2, $3, $10, $11}')

        # Extraire les valeurs nécessaires
        local rx_bytes=$(echo "$stats" | awk '{print $1}')
        local rx_errors=$(echo "$stats" | awk '{print $2}')
        local tx_bytes=$(echo "$stats" | awk '{print $3}')
        local tx_errors=$(echo "$stats" | awk '{print $4}')

        case "$direction" in
            "down")
                echo "Octets reçus : $rx_bytes"
                echo "Erreurs de réception : $rx_errors"
                ;;
            "up")
                echo "Octets envoyés : $tx_bytes"
                echo "Erreurs d'envoi : $tx_errors"
                ;;
            *)
                echo "Option invalide. Utilisez 'down' ou 'up'."
                return 1
                ;;
        esac
    else
        echo "Usage : network_info list"
        echo "       network_info <interface> down"
        echo "       network_info <interface> up"
        return 1
    fi
}

network_info() {
    if [[ "$1" == "list" ]]; then
        # Lister les noms des interfaces disponibles
        awk -F':' '/:/ {print $1}' /proc/net/dev | tr -d ' '
    elif [[ -n "$1" && -n "$2" ]]; then
        local interface="$1"
        local direction="$2"

        # Vérifier si l'interface existe
        if ! grep -q "^ *$interface:" /proc/net/dev; then
            echo "L'interface '$interface' n'existe pas."
            return 1
        fi

        # Récupérer les statistiques de l'interface
        local stats=$(grep "^ *$interface:" /proc/net/dev | awk '{print $2, $3, $10, $11}')

        # Extraire les valeurs nécessaires
        local rx_bytes=$(echo "$stats" | awk '{print $1}')
        local rx_errors=$(echo "$stats" | awk '{print $2}')
        local tx_bytes=$(echo "$stats" | awk '{print $3}')
        local tx_errors=$(echo "$stats" | awk '{print $4}')

        case "$direction" in
            "down")
                echo "$rx_bytes $rx_errors"
                ;;
            "up")
                echo "$tx_bytes $tx_errors"
                ;;
            *)
                echo "Option invalide. Utilisez 'down' ou 'up'."
                return 1
                ;;
        esac
    else
        echo "Usage : network_info list"
        echo "       network_info <interface> down"
        echo "       network_info <interface> up"
        return 1
    fi
}


# Appeler la fonction
#cpu_usage
#network_info list
#echo ""
#network_info eth0 down