#!/bin/bash
#pour les couleur tu peux aussi utiliser "\033[38;5<code couleurs>m" code en 256
. ./recup_info.sh

# Définir les valeurs par défaut
font_color_default="BG_BLACK"
color_default="RED"
lang_default="en"
os_default="ubuntu"
climit="full_block"
char_bar_plein="dark_shade"
char_bar_vide="light_shade"
color_limiteur="BLUE"
color_bar_cpu="YELLOW"
color_bar_gpu="GREEN"
color_bar_memory="MAGENTA"
color_bar_disk="BLUE"
color_proc="BRIGHT_WHITE"

# Variables pour les couleurs de texte (foreground)
BLACK="\033[30m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
CYAN="\033[36m"
WHITE="\033[37m"
RESET="\033[0m"

# Variables pour les couleurs de fond (background)
BG_BLACK="\033[40m"
BG_RED="\033[41m"
BG_GREEN="\033[42m"
BG_YELLOW="\033[43m"
BG_BLUE="\033[44m"
BG_MAGENTA="\033[45m"
BG_CYAN="\033[46m"
BG_WHITE="\033[47m"

# Variables pour les couleurs claires (bright foreground)
BRIGHT_BLACK="\033[90m"
BRIGHT_RED="\033[91m"
BRIGHT_GREEN="\033[92m"
BRIGHT_YELLOW="\033[93m"
BRIGHT_BLUE="\033[94m"
BRIGHT_MAGENTA="\033[95m"
BRIGHT_CYAN="\033[96m"
BRIGHT_WHITE="\033[97m"

# Variables pour les couleurs claires de fond (bright background)
BRIGHT_BG_BLACK="\033[100m"
BRIGHT_BG_RED="\033[101m"
BRIGHT_BG_GREEN="\033[102m"
BRIGHT_BG_YELLOW="\033[103m"
BRIGHT_BG_BLUE="\033[104m"
BRIGHT_BG_MAGENTA="\033[105m"
BRIGHT_BG_CYAN="\033[106m"
BRIGHT_BG_WHITE="\033[107m"

carre_plein="\u2588"
carre_vide="\u25A1"

# Caractères Unicode de type carré
full_block="█"             # Full Block
upper_half_block="▀"       # Upper Half Block
lower_half_block="▄"       # Lower Half Block
left_half_block="▌"        # Left Half Block
right_half_block="▐"       # Right Half Block
light_shade="░"            # Light Shade
medium_shade="▒"           # Medium Shade
dark_shade="▓"             # Dark Shade
white_square="▢"           # White Square
black_circle="●"           # Black Circle
white_circle="○"           # White Circle
black_diamond="◆"          # Black Diamond
white_diamond="◇"          # White Diamond
black_star="★"             # Black Star
white_star="☆"             # White Star

generate_random() {  # Jamel Bailleul
    local min=$1
    local max=$2
    # Utiliser $RANDOM pour générer un nombre aléatoire
    local range=$((max - min + 1))
    local random_number=$((RANDOM % range + min))

    echo "$random_number"
}

clear_screen() { # Jamel Bailleul
    cols=$(tput cols)
    lines=$(tput lines)
    
    # Définir la position du séparateur
    if [ -z "$1" ]; then
        separateur=0
    else
        separateur=$1
    fi

    # Effacer et redessiner l'écran
    for ((i=1; i<=cols; i++)); do
        for ((j=1; j<=lines; j++)); do
            printf "\033[%d;%dH" "$j" "$i"  # Positionnement du curseur

            if (( i == 1 || i == cols || j == 1 || j == lines || i == separateur )); then
                # Afficher la bordure
                echo -en "${!font_color_default}${!color_limiteur}${!climit}${reset}"
            else
                # Remplir avec un espace vide
                echo -en "${!font_color_default}${!color_limiteur} ${reset}"
            fi
        done
    done
}


info_reduite() { # Jamel Bailleul
    # Mémoire
    if recup_mem "used" >/dev/null 2>&1; then # afficher la RAM
        x=$1
        y=$2
        printf "\33[%d;%dH" "$x" "$y" # Placer le curseur aux coordonnées x y
        echo -en "${!font_color_default}${!color_default}Memory : ${reset}"
        max=99 #$(recup_mem total) # recup la quantité max de la RAM
        current=$(generate_random 1 $max) #$(recup_mem used) # recup la quantité utilisée de la RAM
        print_bar_h "${!font_color_default}${!color_bar_memory}" "$y" "$3" "$((x + 1))" "$current" "$max" # afficher la barre d'état de la mémoire
    fi

    # CPU
    erreur=$(recup_cpu 2>&1)
    if (( $? != 1 )); then
        cpu_x=$((x + 3))
        cpu_y=3
        printf "\33[%d;%dH" "$cpu_x" "$cpu_y" # Placer le curseur aux coordonnées x y
        echo -en "${!font_color_default}${!color_default}CPU : $(recup_cpu)${reset}"
        # bar cpu
        max=99 #$(recup_gpu vramTotal)
        current=$(generate_random 1 $max) #$(recup_gpu vramUsed)
        print_bar_h "${!font_color_default}${!color_bar_cpu}" "$cpu_y" "$3" "$((cpu_x + 1))" "$current" "$max"
    fi

    # GPU
    if recup_gpu vramUsed >/dev/null 2>&1; then
        gpu_x=$((cpu_x + 3))
        gpu_y=3
        printf "\33[%d;%dH" "$gpu_x" "$gpu_y" # Placer le curseur aux coordonnées x y
        echo -en "${!font_color_default}${!color_default}GPU : ${reset}"
        max=99 #$(recup_gpu vramTotal)
        current=$(generate_random 1 $max) #$(recup_gpu vramUsed)
        print_bar_h "${!font_color_default}${!color_bar_gpu}" "$gpu_y" "$3" "$((gpu_x + 1))" "$current" "$max"
    else
        gpu_x=$((cpu_x + 3))
        gpu_y=3
        printf "\33[%d;%dH" "$gpu_x" "$gpu_y" # Placer le curseur aux coordonnées x y
        echo -en "${!font_color_default}${!color_default}GPU : info sur les GPU impossible à trouver${reset}"
    fi

    # Disk
    if recup_disk used >/dev/null 2>&1; then
        disk_x=$((gpu_x + 3))
        disk_y=3
        printf "\33[%d;%dH" "$disk_x" "$disk_y" # Placer le curseur aux coordonnées x y
        max=99 #$(recup_disk total | grep -o '[0-9.]*')
        current=$(generate_random 1 $max) #$(recup_disk used | grep -o '[0-9.]*')
        echo -en "${!font_color_default}${!color_default}Disk : ${reset}"
        print_bar_h "${!font_color_default}${!color_bar_disk}" "$disk_y" "$3" "$((disk_x + 1))" "$current" "$max"
    else
        disk_x=$((x + 3))
        disk_y=3
        printf "\33[%d;%dH" "$disk_x" "$disk_y" # Placer le curseur aux coordonnées x y
        echo -en "${!font_color_default}${!color_default}Disk : info sur les disques impossible à trouver${reset}"
    fi
}

info_scinder() { # Jamel Bailleul
    local cols="$1"  # Colonne de début
    local lines="$2" # Ligne de début
    local max_cols=$(tput cols)
    local max_lines=$(tput lines)
	local cols_proc=$(($max_cols / 2)) # Moitié des colonnes pour diviser la zone
    local lines_proc=$(($max_lines / 2)) # Moitié des lignes pour diviser la zone

    # Appel de la fonction info_reduite avec les paramètres ajustés
    info_reduite $cols $lines $((($max_cols / 2) - 2))

    # Appel de la fonction affiche_proc avec les colonnes et lignes ajustées
    affiche_proc $(($cols_proc + 2)) $lines $(( max_lines - 2)) $(tput cols)
}

affiche_proc() { # Jamel Bailleul
    local start_col=$1   # Colonne de début
    local start_line=$2  # Ligne de début
    local end_line=$3    # Nombre total de lignes à afficher
    local end_col=$4     # Colonne de fin
	# Récupérer le résultat de la commande ps dans la variable text
	text=$(ps -eo %cpu,%mem,pid,user,cmd --sort=-%cpu)

    # Boucle pour afficher chaque processus dans la zone délimitée
    for (( i=$(($start_line - 1)); i < end_line; i++ )); do

		# Obtenir la première ligne de "text"
		first_line=$(echo "$text" | head -n 1)
		#first_15_chars=${first_line:0:15}	# Obtenir les 15 premiers caractères de la première ligne

		# Afficher les 15 premiers caractères de la première ligne au milieu de l'écran
		printf "\033[%d;%dH" "$i" "$start_col"  # Positionne le curseur
		nb_char=$(($end_col - $start_col))
		echo -en "${!font_color_default}${!color_proc}${first_line:0:${nb_char}}"
		text=$(echo "$text" | sed '1d')
    done
}

print_bar_h() { # Jamel Bailleul
	# $1 = couleur
	# $2 = cols debut de barre
	# $3 = cols fin de barre
	# $4 = lines
	# $5 = current var
	# $6 = max var
	res="$1"
	#echo "etape 1 "
	# Utilisation de bc pour gérer les nombres à virgule
    max_tmp_bar=$(echo "$6" | tr -cd '0-9')
    max_tmp_bar=$(echo "$max_tmp_bar" | tr -d '.')
    current_tmp_bar=$(echo "$5" | tr -cd '0-9')
    current_tmp_bar=$(echo "$current_tmp_bar" | tr -d '.')
	percent=$(($current_tmp_bar * 99 / $max_tmp_bar))

	#echo "étape 2"
	for ((i=$2; i<=$3 - 3; i++)); do
		if (( $(echo "$i * 100 / ($3 - 4)" | bc) <= percent )); then
			res+="${!font_color_default}${!char_bar_plein}"
		else
			res+="${reset}${!char_bar_vide}"
		fi
	done
	
	printf "\33[%d;%dH" "$4" "$2"
	echo -en "${!font_color_default}${!color_default}$res${!font_color_default}${!color_default}$percent%${reset}"
}

config_file() {  # Jamel Bailleul
    local fichier="$1"

    if [[ -f "$fichier" ]]; then # Vérifie si le fichier existe
        while IFS='=' read -r cle valeur; do # Boucle pour lire chaque ligne du fichier
            if [[ -n "$cle" && -n "$valeur" ]]; then
                export "$cle=$valeur" # Exporter chaque clé comme une variable d'environnement
            fi
        done < "$fichier"
        echo "Les variables d'environnement ont été définies."
    else
        echo "Le fichier '$fichier' n'existe pas."
    fi
}

install_bc_if_not_installed() {  # Jamel Bailleul
    if ! command -v bc &> /dev/null; then # Vérifie si bc est installé
        # Installation de bc
        sudo apt update -y > /dev/null 2>&1
        sudo apt install -y bc > /dev/null 2>&1
    fi
}

main() {  # Jamel Bailleul
    # prepare la zone de texte pour ne pas afficher le curseur ou les caractères taper
	stty -icanon -echo
    trap "stty sane; exit" INT TERM
	tput civis # Rendre le curseur invisible
	trap 'echo -en "${reset}";stty sane;clear; exit' SIGINT

	# vérifie la présence d'un fichier de config
	if [[ -f "$1" ]]; then
		config_file "$1"
	else
		echo "Non, le fichier '$1' n'existe pas."
	fi

	if (( $(tput cols) > 15 && $(tput lines) > 30 )); then 
		clear_screen $(($(tput cols) / 2))
	else
		clear_screen
	fi
	cols=$(tput cols)
	lines=$(tput lines)
    #while true; do
    #    # Utilise la commande read avec l'option -n1 pour lire un seul caractère
	#	read -n 1 -s input
    #	# Si l'utilisateur appuie sur 'q', on sort de la boucle
	#	if [[ "$input" == "q" ]]; then
    #        printf "\33[%d;%dH" "$lines" "0"
	#		echo "Au revoir!"
    #        stty sane
	#		exit 1
	#	fi
    #done &

	while true; do
		if (( $(tput cols) != $cols || $(tput lines) != $lines )); then
			if (( $(tput cols) > 15 && $(tput lines) > 30 )); then 
				clear_screen $(($(tput cols) / 2))
			else
				clear_screen
			fi
			clear_screen
		fi
		
		if (( $(tput cols) <= 30 | $(tput lines) <= 15)); then
			info_reduite 2 3 $(($(tput cols)-2))
		else
			info_scinder 2 3 $(($(tput cols)-2))
		fi

		# Pause de 1 seconde avant d'afficher à nouveau les info
		#sleep 1
	done
	stty sane
}

main "$@"
stty sane
