#!/bin/bash
#pour les couleur tu peux aussi utiliser "\033[38;5<code couleurs>m" code en 256
. ./recup_info.sh
. ./update_log.sh

# Définir les valeurs par défaut
bg_color="BG_BLACK"
font_color="FONT_RED"
os_default="ubuntu"
climit="unicode_full_block"
char_bar_plein="unicode_dark_shade"
char_bar_vide="unicode_light_shade"
color_limiteur="FONT_BLUE"
color_bar_cpu="FONT_YELLOW"
color_bar_gpu="FONT_GREEN"
color_bar_memory="FONT_MAGENTA"
color_bar_disk="FONT_BLUE"
color_proc="FONT_BRIGHT_WHITE"
update_log_time=60

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
unicode_full_block="█"             # Bloc complet (Full Block)
unicode_upper_half_block="▀"       # Demi-bloc supérieur (Upper Half Block)
unicode_lower_half_block="▄"       # Demi-bloc inférieur (Lower Half Block)
unicode_left_half_block="▌"        # Demi-bloc gauche (Left Half Block)
unicode_right_half_block="▐"       # Demi-bloc droit (Right Half Block)

unicode_light_shade="░"            # Ombrage léger (Light Shade)
unicode_medium_shade="▒"           # Ombrage moyen (Medium Shade)
unicode_dark_shade="▓"             # Ombrage foncé (Dark Shade)

unicode_white_square="▢"           # Carré blanc (White Square)
unicode_black_circle="●"           # Cercle noir (Black Circle)
unicode_white_circle="○"           # Cercle blanc (White Circle)
unicode_black_diamond="◆"          # Losange noir (Black Diamond)
unicode_white_diamond="◇"          # Losange blanc (White Diamond)
unicode_black_star="★"             # Étoile noire (Black Star)
unicode_white_star="☆"             # Étoile blanche (White Star)

print_cpu() {
    local max_cols="$3"
    local max_lines="$4"
    local cpu_="$5"
    local used_cpu=$(recup_cpu "cpu${cpu_}" 2>/dev/null)
    if [[ -n "$used_cpu" ]]; then
        x=1
        y=1
        position=$(( position + 1 ))
        cpu_=1
        printf "\33[%d;%dH" "$x" "$y"

        local max_cpu=99

        percent=$(calculate_percent "$used_cpu" "$max_cpu")

        echo -en "${!bg_color}${!font_color}CPU : ${cpu_}${reset}"
        # Afficher la barre d'état pour l'utilisation du CPU
        print_bar_h "${!bg_color}${!color_bar_cpu}" "$y" "$max_cols" "$(( x + 1 ))" "$percent"
    fi
}

print_core() {
    local max_cols="$3"
    local max_lines="$4"
    local position=0
    local div=$(recup_nb_core_cpu)
    local max_cpu=99
    local x="$1"
    local y="$2"
    local fin_bar=$(($max_cols /2))
    local i=1
    for (( j=1; j <= div ; j++ )); do
        if [[ $j == $((($div / 2) + 1 )) ]]; then
            i=2
            y=$fin_bar
            position=0
            fin_bar="$3"
        fi
        used_cpu=$(recup_cpu "cpu$((j))" 2>/dev/null)
        if [[ -n "$used_cpu" ]]; then
            x=$(( $1 + (3 * position) ))  # Position en ligne ajustée selon la position

            # Incrémenter la position pour la prochaine section
            position=$(( position + 1 ))
            printf "\33[%d;%dH" "$x" "$y"

            percent=$(calculate_percent "$used_cpu" "$max_cpu")

            echo -en "${!bg_color}${!font_color}CORE : ${j}${reset}"
            # Afficher la barre d'état pour l'utilisation du CPU
            print_bar_h "${!bg_color}${!color_bar_cpu}" "$y" "$(($fin_bar - 1))" "$(( x + 1 ))" "$percent"
        else
            return 1
        fi
    done
}

print_bar_h() { # Jamel Bailleul
    # $1 = couleur
    # $2 = cols debut de barre
    # $3 = cols fin de barre
    # $4 = lines
    # $5 = percent

    current_tmp_bar=$(echo "$current_tmp_bar" | tr -d '.')

    local percent="$5"

    local res="$1"
    for ((i=$2; i<=$3 - 3; i++)); do
        if (( $(echo "$i * 100 / ($3 - 4)" | bc) <= percent )); then
            res+="${!bg_color}${!char_bar_plein}"
        else
            res+="${reset}${!char_bar_vide}"
        fi
    done

    printf "\33[%d;%dH" "$4" "$2"
    echo -en "${!bg_color}${!font_color}$res${!bg_color}${!font_color}$percent%${reset}"
}

get_network_usage "upload" $(get_interface_name)