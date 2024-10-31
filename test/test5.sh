#!/bin/bash

# On récupère la mémoire totale et la mémoire utilisée
total_mem=$(free -m | awk '/Mem:/ {print $2}')
used_mem=$(free -m | awk '/Mem:/ {print $3}')

# On crée un fichier de données pour gnuplot
echo "Utilisé Total" > mem_data.txt
echo "$used_mem $total_mem" >> mem_data.txt

# Commande pour générer le graphique avec gnuplot
gnuplot -persist <<-EOFMarker
    set title "Utilisation de la Mémoire"
    set xlabel "Type de Mémoire"
    set ylabel "Mémoire en Mo"
    set style data histograms
    set style fill solid 1.00 border -1
    set boxwidth 0.9
    set terminal dumb
    set palette rgbformulae 33,13,10
    plot "mem_data.txt" using 2:xtic(1) title "Mémoire" lt rgb "cyan"
EOFMarker

# Nettoyage
rm mem_data.txt
