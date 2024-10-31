#!/bin/bash

# Configuration de l'aire de jeu
width=20
height=10
player="O"
x=10
y=5

# Fonction pour déplacer le curseur à une position donnée
move_cursor() {
    local x=$1
    local y=$2
    printf "\033[%d;%dH" "$y" "$x"
}

# Fonction pour effacer le caractère à la position actuelle
clear_position() {
    local x=$1
    local y=$2
    move_cursor $x $y
    echo -n " "
}

# Fonction pour dessiner le personnage à une position donnée
draw_player() {
    local x=$1
    local y=$2
    move_cursor $x $y
    echo -n "$player"
}

# Fonction pour lire une touche de manière non bloquante
read_key() {
    local key
    IFS= read -r -s -n 1 key
    echo "$key"
}

# Configuration du terminal pour lire les touches sans attendre la touche "Entrée"
stty -icanon -echo

# Affichage du personnage initial
draw_player $x $y

while true; do
    key=$(read_key)

    # Gestion des mouvements en fonction des touches fléchées
    case "$key" in
        $'\x1b') # Séquence d'échappement
            read -r -s -n 1 -t 0.1 key
            if [ "$key" = "[" ]; then
                read -r -s -n 1 -t 0.1 key
                case "$key" in
                    "A") # Flèche haut
                        clear_position $x $y
                        ((y--))
                        ;;
                    "B") # Flèche bas
                        clear_position $x $y
                        ((y++))
                        ;;
                    "C") # Flèche droite
                        clear_position $x $y
                        ((x++))
                        ;;
                    "D") # Flèche gauche
                        clear_position $x $y
                        ((x--))
                        ;;
                esac
                # Assurer que le personnage reste dans les limites
                if (( x < 1 )); then x=1; fi
                if (( x > width )); then x=$width; fi
                if (( y < 1 )); then y=1; fi
                if (( y > height )); then y=$height; fi
                draw_player $x $y
            fi
            ;;
    esac
done

# Réinitialisation du terminal
stty sane
