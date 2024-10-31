#!/bin/bash

# Configuration du jeu
width=20
height=10
snake="O"
food="X"
empty=" "
delay=0.1

# Initialisation du jeu
x=5
y=5
dx=1
dy=0
snake_body=()

# Fonction pour déplacer le curseur
move_cursor() {
    printf "\033[%d;%dH" "$2" "$1"
}

# Fonction pour afficher le terrain de jeu
draw_game() {
    clear
    for ((i=0; i<$height; i++)); do
        for ((j=0; j<$width; j++)); do
            if [[ $i -eq $y && $j -eq $x ]]; then
                echo -n "$snake"
            else
                echo -n "$empty"
            fi
        done
        echo
    done
}

# Fonction pour lire une touche
read_key() {
    local key
    IFS= read -r -s -n 1 key
    echo "$key"
}

stty -icanon -echo
trap "stty sane; exit" INT TERM

while true; do
    draw_game
    key=$(read_key)

    case "$key" in
        A) dy=-1; dx=0;;  # Flèche haut
        B) dy=1; dx=0;;   # Flèche bas
        C) dx=1; dy=0;;   # Flèche droite
        D) dx=-1; dy=0;;  # Flèche gauche
    esac

    x=$((x + dx))
    y=$((y + dy))

    # Vérification des limites
    if (( x < 0 )); then x=$((width - 1)); fi
    if (( x >= width )); then x=0; fi
    if (( y < 0 )); then y=$((height - 1)); fi
    if (( y >= height )); then y=0; fi

    sleep $delay
done
