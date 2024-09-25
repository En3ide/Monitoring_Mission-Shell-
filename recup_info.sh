#!/bin/sh

recup_mem() { #tout est en kB
    info_mem=$(cat /proc/meminfo)
    mem_total=$(echo "$info_mem" | grep "MemTotal" | awk '{print $2}') # mémoire total
    mem_available=$(echo "$info_mem" | grep "MemAvailable" | awk '{print $2}') # mémoire disponible
    mem_free=$(echo "$info_mem" | grep "MemFree" | awk '{print $2}') # mémoire libre
    mem_cache=$(echo "$info_mem" | grep "Cached" | awk '{print $2}') # cache de la mémoire
    mem_used=$((mem_total - mem_available)) # mémoire actuellement utilisé

    echo "$mem_total"
    echo "$mem_available"
    echo "$mem_free"
    echo "$mem_cache"
    echo "$mem_used"
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
get_cpu_usage