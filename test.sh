#!/bin/bash

# Configuration de l'animation
width=40
height=10
ball="o"
delay=0.1

# Fonction pour effacer l'écran
clear_screen() {
    printf "\033c"
}

# Fonction pour afficher la balle à une position donnée
draw_ball() {
    local x=$1
    local y=$2
    for (( i=0; i<height; i++ )); do
        if (( i == y )); then
            for (( j=0; j<width; j++ )); do
                if (( j == x )); then
                    echo -n "$ball"
                else
                    echo -n " "
                fi
            done
        else
            echo
        fi
    done
}

# Position initiale et direction
x=0
y=0
dx=1
dy=1

while true; do
    clear_screen
    draw_ball $x $y
    sleep $delay

    # Mise à jour de la position
    x=$((x + dx))
    y=$((y + dy))

    # Changement de direction lorsqu'on atteint les bords
    if (( x <= 0 || x >= width - 1 )); then
        dx=$(( -dx ))
    fi

    if (( y <= 0 || y >= height - 1 )); then
        dy=$(( -dy ))
    fi
done
