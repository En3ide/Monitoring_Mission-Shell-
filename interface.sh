#!/bin/bash
#pour les couleur tu peux aussi utiliser "\033[38;5<code couleurs>m" code en 256
. ./recup_info.sh

# Définir les valeurs par défaut
bg_color_default="BG_BLACK"
font_color_default="FONT_RED"
lang_default="en"
os_default="ubuntu"
climit="full_block"
char_bar_plein="dark_shade"
char_bar_vide="light_shade"
color_limiteur="FONT_BLUE"
color_bar_cpu="FONT_YELLOW"
color_bar_gpu="FONT_GREEN"
color_bar_memory="FONT_MAGENTA"
color_bar_disk="FONT_BLUE"
color_proc="FONT_BRIGHT_WHITE"

# Variables pour les couleurs de texte (foreground)
FONT_BLACK="\033[30m"
FONT_RED="\033[31m"
FONT_GREEN="\033[32m"
FONT_YELLOW="\033[33m"
FONT_BLUE="\033[34m"
FONT_MAGENTA="\033[35m"
FONT_CYAN="\033[36m"
FONT_WHITE="\033[37m"
FONT_RESET="\033[0m"

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
FONT_BRIGHT_BLACK="\033[90m"
FONT_BRIGHT_RED="\033[91m"
FONT_BRIGHT_GREEN="\033[92m"
FONT_BRIGHT_YELLOW="\033[93m"
FONT_BRIGHT_BLUE="\033[94m"
FONT_BRIGHT_MAGENTA="\033[95m"
FONT_BRIGHT_CYAN="\033[96m"
FONT_BRIGHT_WHITE="\033[97m"

# Variables pour les couleurs claires de fond (bright background)
BG_BRIGHT_BLACK="\033[100m"
BG_BRIGHT_RED="\033[101m"
BG_BRIGHT_GREEN="\033[102m"
BG_BRIGHT_YELLOW="\033[103m"
BG_BRIGHT_BLUE="\033[104m"
BG_BRIGHT_MAGENTA="\033[105m"
BG_BRIGHT_CYAN="\033[106m"
BG_BRIGHT_WHITE="\033[107m"

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
    local cols=$(tput cols)
    local lines=$(tput lines)
    local separateur="0"
    
    # Définir la position du séparateur
    if [ -n "$1" ]; then
        separateur="$1"
    fi

    # Effacer et redessiner l'écran
    local i j
    for ((i = 1; i <= cols; i++)); do
        for ((j = 1; j <= lines; j++)); do
            printf "\033[%d;%dH" "$j" "$i"  # Positionnement du curseur

            if (( i == 1 || i == cols || j == 1 || j == lines || i == separateur )); then
                # Afficher la bordure
                echo -en "${!bg_color_default}${!color_limiteur}${!climit}${reset}"
            else
                # Remplir avec un espace vide
                echo -en "${!bg_color_default}${!color_limiteur} ${reset}"
            fi
        done
    done
}


info_reduite() { # Jamel Bailleul
    local position="0"

    # Mémoire
    local used_memory=$(recup_mem "used" 2>/dev/null)
    if [ -n "$used_memory" ]; then # Afficher la RAM si une valeur a été récupérée
        local x=$(($1 + (3 * position)))
        local y="$2"
        position=$((position + 1))
        printf "\33[%d;%dH" "$x" "$y" # Placer le curseur aux coordonnées x y
        local max_memory=$(recup_mem "total") # Récupération de la quantité maximale de RAM une seule fois
        echo -en "${!bg_color_default}${!font_color_default}Memory : ${used_memory}Kb / ${max_memory}Kb${reset}"
        print_bar_h "${!bg_color_default}${!color_bar_memory}" "$y" "$3" "$((x + 1))" "$used_memory" "$max_memory" # Afficher la barre d'état de la mémoire
    fi

    # CPU
    local cpu_name=$(recup_cpu "name" 2>/dev/null)
    if [ -n "$cpu_name" ]; then # Afficher le CPU si une valeur a été récupérée
        local cpu_x=$(($1 + (3 * position)))
        local cpu_y="$2"
        position=$((position + 1))
        printf "\33[%d;%dH" "$cpu_x" "$cpu_y" # Placer le curseur aux coordonnées x y
        echo -en "${!bg_color_default}${!font_color_default}CPU : ${cpu_name:0:$(( $3 - 7 ))}${reset}"
        # Afficher la barre d'état du CPU
        local max_cpu=99
        local current_cpu=$(recup_cpu)
        print_bar_h "${!bg_color_default}${!color_bar_cpu}" "$cpu_y" "$3" "$((cpu_x + 1))" "$current_cpu" "$max_cpu"
    fi

    # GPU
    local used_gpu=$(recup_gpu "vramUsed" 2>/dev/null)
    if [ -n "$used_gpu" ]; then # Afficher le GPU si une valeur a été récupérée
        local gpu_x=$(($1 + (3 * position)))
        local gpu_y="$2"
        position=$((position + 1))
        printf "\33[%d;%dH" "$gpu_x" "$gpu_y" # Placer le curseur aux coordonnées x y
        local max_gpu=$(recup_gpu "vramTotal") # Récupération de la quantité maximale de VRAM une seule fois
        echo -en "${!bg_color_default}${!font_color_default}GPU : ${reset}"
        print_bar_h "${!bg_color_default}${!color_bar_gpu}" "$gpu_y" "$3" "$((gpu_x + 1))" "$used_gpu" "$max_gpu"
    fi

    # Disque
    local used_disk=$(recup_disk "used" 2>/dev/null)
    if [ -n "$used_disk" ]; then # Afficher le disque si une valeur a été récupérée
        local disk_x=$(($1 + (3 * position)))
        local disk_y="$2"
        position=$((position + 1))
        local max_disk=$(recup_disk "total") # Récupération de la quantité maximale du disque une seule fois
        printf "\33[%d;%dH" "$disk_x" "$disk_y" # Placer le curseur aux coordonnées x y
        echo -en "${!bg_color_default}${!font_color_default}Disk : ${used_disk} / ${max_disk}${reset}"
        print_bar_h "${!bg_color_default}${!color_bar_disk}" "$disk_y" "$3" "$((disk_x + 1))" "$used_disk" "$max_disk"
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

    # Appel de la fonction affiche_processus avec les colonnes et lignes ajustées
    affiche_processus $(($cols_proc + 2)) $lines $(( max_lines - 2)) $(tput cols)
}

affiche_processus() { # Jamel Bailleul
    local start_col="$1"   # Colonne de début
    local start_line="$2"  # Ligne de début
    local end_line="$3"    # Nombre total de lignes à afficher
    local end_col="$4"     # Colonne de fin
	# Récupérer le résultat de la commande ps dans la variable text
	local text=$(ps -eo %cpu,%mem,pid,user,cmd --sort=-%cpu)

    # Boucle pour afficher chaque processus dans la zone délimitée
    for (( i=$(($start_line - 1)); i < end_line; i++ )); do

		# Obtenir la première ligne de "text"
		local first_line=$(echo "$text" | head -n 1)
		#first_15_chars=${first_line:0:15}	# Obtenir les 15 premiers caractères de la première ligne

		# Afficher les 15 premiers caractères de la première ligne au milieu de l'écran
		printf "\033[%d;%dH" "$i" "$start_col"  # Positionne le curseur
		local nb_char=$(($end_col - $start_col))
		echo -en "${!bg_color_default}${!color_proc}${first_line:0:${nb_char}}"
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

    # Gère les valeurs à virgules (on choisit de les retirer)
    local res="$1"
    
    local max_tmp_bar current_tmp_bar
    max_tmp_bar=$(echo "$6" | tr -cd '0-9')
    max_tmp_bar=$(echo "$max_tmp_bar" | tr -d '.')
    current_tmp_bar=$(echo "$5" | tr -cd '0-9')
    current_tmp_bar=$(echo "$current_tmp_bar" | tr -d '.')

    local percent=$(($current_tmp_bar * 99 / $max_tmp_bar))

    for ((i=$2; i<=$3 - 3; i++)); do
        if (( $(echo "$i * 100 / ($3 - 4)" | bc) <= percent )); then
            res+="${!bg_color_default}${!char_bar_plein}"
        else
            res+="${reset}${!char_bar_vide}"
        fi
    done

    printf "\33[%d;%dH" "$4" "$2"
    echo -en "${!bg_color_default}${!font_color_default}$res${!bg_color_default}${!font_color_default}$percent%${reset}"
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
        sudo "apt" "update" -y > /dev/null 2>&1
        sudo "apt" "install" -y bc > /dev/null 2>&1
    fi
}

main() {  # Jamel Bailleul
    # on sauvegarde l'état du terminal
    local old_stty=$(stty -g)
    tput "smcup"

    # prepare la zone de texte pour ne pas afficher le curseur ou les caractères tapés
    stty -icanon -echo
    tput civis # Rendre le curseur invisible

    # si le programme est interrompu avec ctrl+c, on remet l'état initial du terminal
    trap 'tput "rmcup"; tput "cnorm"; stty "$old_stty"; exit' INT TERM

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
	local cols=$(tput cols)
	local lines=$(tput lines)
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
			if (( $(tput cols) > 15 && $(tput lines) > 20 )); then 
				clear_screen $(($(tput cols) / 2))
			else
				clear_screen
			fi
		fi
		
		if (( $(tput cols) <= 50 | $(tput lines) <= 20)); then
			info_reduite 2 3 $(($(tput cols)-2))
		else
			info_scinder 2 3 $(($(tput cols)-2))
		fi

		# Pause de 1 seconde avant d'afficher à nouveau les info
		#sleep 1
	done

    # on remet l'état initial du terminal si l'utilisateur quitte normalement
    tput "rmcup"
    tput "cnorm"
    stty "$old_stty"
}

main "$@"
