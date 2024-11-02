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
# Appeler la fonction
cpu_usage
