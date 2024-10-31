#!/bin/bash

# Configuration de l'animation
width=40
height=10
ball="o"
delay=0.1

# Fonction pour déplacer le curseur à une position donnée
move_cursor() {
    local x=$1
    local y=$2
    printf "\033[%d;%dH" "$y" "$x"
}

# Fonction pour afficher la balle à une position donnée
draw_ball() {
    local x=$1
    local y=$2
    move_cursor $x $y
    echo -n "$ball"
}

# Position initiale et direction
x=1
y=1
dx=1
dy=1

while true; do
    # Afficher la balle
    draw_ball $x $y
    sleep $delay

    # Effacer la balle de la position précédente en déplaçant le curseur
    move_cursor $x $y
    echo -n " "

    # Mise à jour de la position
    x=$((x + dx))
    y=$((y + dy))

    # Changement de direction lorsqu'on atteint les bords
    if (( x <= 1 || x >= width )); then
        dx=$(( -dx ))
    fi

    if (( y <= 1 || y >= height )); then
        dy=$(( -dy ))
    fi
done
