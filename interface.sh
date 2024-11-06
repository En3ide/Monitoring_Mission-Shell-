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
    local separateur=0
    
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
                echo -en "${!bg_color}${!color_limiteur}${!climit}${reset}"
            else
                # Remplir avec un espace vide
                echo -en "${!bg_color}${!color_limiteur} ${reset}"
            fi
        done
    done
}

info_reduite() { # Jamel Bailleul & Tim Lamour & ChatGPT
    local position=0
    local x y
    local var_info
    local percent

    # logfile
    local logfile_content=""
    local logfile_enabled="$4"

    # Mémoire
    local used_memory=$(recup_mem "used" 2>/dev/null)
    if [ -n "$used_memory" ]; then
        # Calcul de la position pour afficher les informations de mémoire
        x=$(( $1 + (3 * position) ))  # Position en ligne ajustée selon la position
        y="$2"  # Position en colonne reçue en argument

        # Incrémenter la position pour la prochaine section
        position=$(( position + 1 ))

        # Placer le curseur aux coordonnées (x, y) pour l'affichage
        printf "\33[%d;%dH" "$x" "$y"

        # Récupération de la quantité totale de RAM en Kb
        local max_memory=$(recup_mem "total")
        
        # Calculer le pourcentage
        percent=$(calculate_percent "$used_memory" "$max_memory")

        # Concatener dans le contenu à rajouter au logfile si demandé
        if [ "$logfile_enabled" == 1 ]; then
            logfile_content="$logfile_content Memory => Used_memory : $used_memory'kb'      Total_memory : $max_memory'kb'      Usage : $percent%\n"
        fi

        # Afficher les informations de mémoire sous forme de texte
        echo -en "${!bg_color}${!font_color}Memory : ${used_memory}Kb / ${max_memory}Kb${reset}"

        # Afficher la barre d'état de la mémoire
        print_bar_h "${!bg_color}${!color_bar_memory}" "$y" "$3" "$(( x + 1 ))" "$percent"
    fi

    # GPU (%)
    local used_gpu=$(recup_gpu "percent" 2>/dev/null)
    if [ -n "$used_gpu" ]; then
        # Calcul de la position pour afficher les informations de GPU
        x=$(( $1 + (3 * position) ))  # Position en ligne ajustée selon la position actuelle
        y="$2"  # Position en colonne reçue en argument

        # Incrémenter la position pour la prochaine section
        position=$(( position + 1 ))

        # Placer le curseur aux coordonnées (x, y) pour l'affichage
        printf "\33[%d;%dH" "$x" "$y"

        # Valeur maximal en pourcentage du GPU
        local max_gpu=99

        # Calculer le pourcentage
        percent=$(calculate_percent "$used_gpu" "$max_gpu")

        # Concatener dans le contenu à rajouter au logfile si demandé
        if [ "$logfile_enabled" == 1 ]; then
            logfile_content="$logfile_content GPU => usage : $percent%\n"
        fi

        # Afficher l'en-tête de la section GPU
        echo -en "${!bg_color}${!font_color}GPU % : ${reset}"

        # Afficher la barre d'état pour l'utilisation de la VRAM
        print_bar_h "${!bg_color}${!color_bar_gpu}" "$y" "$3" "$(( x + 1 ))" "$percent"
    fi

    # GPU (vram)
    local used_vram_gpu=$(recup_gpu "vramUsed" 2>/dev/null)
    if [ -n "$used_vram_gpu" ]; then
        # Calcul de la position pour afficher les informations de GPU
        x=$(( $1 + (3 * position) ))  # Position en ligne ajustée selon la position actuelle
        y="$2"  # Position en colonne reçue en argument

        # Incrémenter la position pour la prochaine section
        position=$(( position + 1 ))

        # Placer le curseur aux coordonnées (x, y) pour l'affichage
        printf "\33[%d;%dH" "$x" "$y"

        # Récupération de la quantité totale de VRAM en Kb
        local max_vram_gpu=$(recup_gpu "vramTotal")

        # Calculer le pourcentage
        percent=$(calculate_percent "$used_vram_gpu" "$max_vram_gpu")

        # Concatener dans le contenu à rajouter au logfile si demandé
        if [ "$logfile_enabled" == 1 ]; then
            logfile_content="$logfile_content GPU VRAM => Used_memory : $used_vram_gpu'Kb'      Total_memory : $max_vram_gpu'Kb'      Usage : $percent%\n"
        fi

        # Afficher l'en-tête de la section GPU
        echo -en "${!bg_color}${!font_color}GPU VRAM : ${reset}"

        # Afficher la barre d'état pour l'utilisation de la VRAM
        print_bar_h "${!bg_color}${!color_bar_gpu}" "$y" "$3" "$(( x + 1 ))" "$percent"
    fi

    # Disque
    local used_disk=$(recup_disk "used" 2>/dev/null)
    if [ -n "$used_disk" ]; then
        # Calcul de la position pour afficher les informations de disque
        x=$(( $1 + (3 * position) ))  # Position en ligne ajustée selon la position actuelle
        y="$2"  # Position en colonne reçue en argument

        # Incrémenter la position pour la prochaine section
        position=$(( position + 1 ))

        # Placer le curseur aux coordonnées (x, y) pour l'affichage
        printf "\33[%d;%dH" "$x" "$y"

        # Récupération de la quantité totale de disque en Mo
        local max_disk=$(recup_disk "total")

        # Calculer le pourcentage
        percent=$(calculate_percent "$used_disk" "$max_disk")

        # Concatener dans le contenu à rajouter au logfile si demandé
        if [ "$logfile_enabled" == 1 ]; then
            logfile_content="$logfile_content Disk => Used_disk : $used_disk'Mo'      Total_disk : $max_disk'Mo'      Usage : $percent%\n"
        fi

        # Afficher les informations de disque sous forme de texte
        echo -en "${!bg_color}${!font_color}Disk : ${used_disk} / ${max_disk}${reset}"

        # Afficher la barre d'état pour l'utilisation du disque
        print_bar_h "${!bg_color}${!color_bar_disk}" "$y" "$3" "$(( x + 1 ))" "$percent"
    fi

    # CPU (%)
    local cpu_name=$(recup_cpu "name" 2>/dev/null)
    local used_cpu=$(recup_cpu "cpu" 2>/dev/null)
    if [[ -n "$cpu_name" && -n "$used_cpu" ]]; then
        # Calcul de la position pour afficher les informations de CPU
        x=$(( $1 + (3 * position) ))  # Position en ligne ajustée selon la position actuelle
        y="$2"  # Position en colonne reçue en argument

        # Incrémenter la position pour la prochaine section
        position=$(( position + 1 ))

        # Placer le curseur aux coordonnées (x, y) pour l'affichage
        printf "\33[%d;%dH" "$x" "$y"

        # Valeur maximal en pourcentage du CPU
        local max_cpu=99
        
        # Calculer le pourcentage
        percent=$(calculate_percent "$used_cpu" "$max_cpu")

        # Concatener dans le contenu à rajouter au logfile si demandé
        if [ "$logfile_enabled" == 1 ]; then
            logfile_content="$logfile_content CPU => Usage : $percent%\n"
        fi

        # Afficher le nom du CPU avec une longueur limitée par la largeur disponible
        echo -en "${!bg_color}${!font_color}CPU % : ${cpu_name:0:$(( $3 - 7 ))}${reset}"

        # Afficher la barre d'état pour l'utilisation du CPU
        print_bar_h "${!bg_color}${!color_bar_cpu}" "$y" "$3" "$(( x + 1 ))" "$percent"
    fi

    local used_cpu=$(recup_cpu "cpu1" 2>/dev/null)
    if [[ -n "$used_cpu" && $(tput lines) > 20 ]]; then
        local position_tmp="$position"
        local fin_bar=$(($3 /2))
        local div=$(recup_nb_core_cpu)
        local espace=1
        for (( j=1; j <= div ; j++ )); do
            if [[ $j == $((($div / 2) + 1 )) ]]; then
                local i=2
                local y=$fin_bar
                local position="$position_tmp"
                local fin_bar="$3"
                local espace=0
            fi
            used_cpu=$(recup_cpu "cpu$((j))" 2>/dev/null)
            if [[ -n "$used_cpu" ]]; then
                x=$(( $1 + (3 * position) ))  # Position en ligne ajustée selon la position

                # Incrémenter la position pour la prochaine section
                position=$(( position + 1 ))

                # Placer le curseur aux coordonnées (x, y) pour l'affichage
                printf "\33[%d;%dH" "$x" "$y"

                # Calculer le pourcentage
                percent=$(calculate_percent "$used_cpu" "$max_cpu")
                
                # Concatener dans le contenu à rajouter au logfile si demandé
                if [ "$logfile_enabled" == 1 ]; then
                    logfile_content="$logfile_content CORE ${j} => Usage : $percent%\n"
                fi

                # Afficher le nom du CPU avec une longueur limitée par la largeur disponible
                echo -en "${!bg_color}${!font_color}CORE : ${j}${reset}"

                # Afficher la barre d'état pour l'utilisation du CPU
                print_bar_h "${!bg_color}${!color_bar_cpu}" "$y" "$(($fin_bar - $espace))" "$(( x + 1 ))" "$percent"
            else
                return 1
            fi
        done
    fi

    # Net
    local inter_name=$(get_interface_name 2>/dev/null)
    if [[ -n "$inter_name" ]]; then
        # Calcul de la position pour afficher les informations de reseaux
        x=$(( $1 + (3 * position) ))  # Position en ligne ajustée selon la position actuelle
        y="$2"  # Position en colonne reçue en argument

        # Incrémenter la position pour la prochaine section
        position=$(( position + 1 ))

        printf "\33[%d;%dH" "$x" "$(($y - 1))"
        for ((i=0; i < $3 ; i++)); do
            echo -en "${!bg_color}${!color_limiteur}${!climit}${reset}"
        done
        nb_inter=$( echo $inter_name | awk '{print NF}')
        for (( i=1 ; i <= $nb_inter ; i++)); do
            name=$(echo $inter_name | awk -v var="$variable" '{print var, $1}')
            # Calcul de la position pour afficher les informations de reseaux
            x=$(( $1 + (3 * position) - 2 ))  # Position en ligne ajustée selon la position actuelle
            y="$2"  # Position en colonne reçue en argument

            # Incrémenter la position pour la prochaine section
            position=$(( position + 1 ))
            
            # Calculer le pourcentage
            download=$(get_network_usage "download" $name)
            upload=$(get_network_usage "upload" $name)

            # Concatener dans le contenu à rajouter au logfile si demandé
            if [ "$logfile_enabled" == 1 ]; then
                logfile_content="$logfile_content $name => Download : $download Bytes | Download/S : $download_s Bytes/S | Upload = $upload Bytes | Upload/S : $upload_s Bytes/S\n"
            fi

            # Placer le curseur aux coordonnées (x, y) pour l'affichage
            printf "\33[%d;%dH" "$x" "$y"
            echo -en "${!bg_color}${!font_color}${!char_bar_vide}${name:0:$(( $3 - 7 ))} ${!char_bar_vide}${reset}"
            printf "\33[%d;%dH" "$(($x + 1))" "$y"
            if [[ $download -ne $(get_network_usage "download" $name) ]]; then
                download_s=$(($download - $(get_network_usage "download" $name)))
            fi
            if [[ $upload -ne $(get_network_usage "upload" $name) ]]; then
                upload_s=$(($upload - $(get_network_usage "upload" $name)))
            fi
            echo -en "${!bg_color}${!font_color}Download total : ${download:0:$(( $3 - 7 ))} Bytes | Download/s : ${download_s} Bytes/s${reset}"
            printf "\33[%d;%dH" "$(($x + 2))" "$y"
            echo -en "${!bg_color}${!font_color}Upload total : ${upload:0:$(( $3 - 7 ))} Bytes | Upload/s : ${upload_s} Bytes/s${reset}"
        done
    fi

    # On écrit dans les logs si c'est demandé en paramètre
    if [ "$logfile_enabled" == 1 ]; then
        write_in_logfile "$logfile_content"
    fi
    
}

info_scinder() { # Jamel Bailleul
    local cols="$1"  # Colonne de début
    local lines="$2" # Ligne de début
    local logfile_enabled="$4"

    local max_cols=$(tput cols)
    local max_lines=$(tput lines)
	local cols_proc=$(($max_cols / 2)) # Moitié des colonnes pour diviser la zone
    local lines_proc=$(($max_lines / 2)) # Moitié des lignes pour diviser la zone

    # Appel de la fonction info_reduite avec les paramètres ajustés
    info_reduite "$cols" "$lines" "$((($max_cols / 2) - 2))" "$logfile_enabled"

    # Appel de la fonction affiche_processus avec les colonnes et lignes ajustées
    affiche_processus "$(($cols_proc + 2))" "$lines" "$(( max_lines - 2))" "$(tput cols)"
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
		echo -en "${!bg_color}${!color_proc}${first_line:0:${nb_char}}"
		text=$(echo "$text" | sed '1d')
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


config_file() {  # Jamel Bailleul
    local fichier="$1"

    # Vérifie si le fichier existe
    if [ -f "$fichier" ]; then 
        while IFS='=' read -r cle valeur; do # Boucle pour lire chaque ligne du fichier

            # Supprime les espaces inutiles autour
            cle=$(echo "$cle" | xargs)
            valeur=$(echo "$valeur" | xargs)

            # Ignore ligne vide et commentaire
            if [[ -z "$cle" || "$cle" == \#* ]]; then
                continue
            fi

            if [ -z "$cle" ]; then
                echo "Erreur de syntaxe le configfile : variable non reconnue." >&2
                exit 2
            elif [ -z "$valeur" ]; then
                echo "Erreur de syntaxe le configfile : valeur de variable reconnue." >&2
                exit 3
            else
                export "$cle=$valeur" # Exporter chaque clé comme une variable d'environnement
            fi
        done < "$fichier"
    else
        echo "Le fichier '$fichier' n'existe pas." >&2
        exit 1
    fi
}

install_bc_if_not_installed() {  # Jamel Bailleul
    if ! command -v bc &> /dev/null; then # Vérifie si bc est installé
        # Installation de bc
        sudo "apt" "update" -y > /dev/null 2>&1
        sudo "apt" "install" -y bc > /dev/null 2>&1
    fi
}

main() {  # Jamel Bailleul & Tim Lamour

    # vérifie la présence d'un fichier de config
	if [ "$#" -eq 1 ]; then
        config_file "$1"
    fi

    # on sauvegarde l'état du terminal
    local old_stty=$(stty -g)
    tput "smcup"

    # prepare la zone de texte pour ne pas afficher le curseur ou les caractères tapés
    stty -icanon -echo
    tput civis # Rendre le curseur invisible

    # si le programme est interrompu avec ctrl+c, on remet l'état initial du terminal
    trap 'tput "rmcup"; tput "cnorm"; stty "$old_stty"; exit' INT TERM

	if (( $(tput cols) > 15 && $(tput lines) > 30 )); then 
		clear_screen "$(($(tput cols) / 2))"
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

    # Créer le logfile
    create_logfile

    local logfile_enabled=0
    local start_time="$SECONDS"
	while true; do
		if (( $(tput cols) != $cols || $(tput lines) != $lines )); then
			if (( $(tput cols) > 15 && $(tput lines) > 20 )); then 
				clear_screen "$(($(tput cols) / 2))"
			else
				clear_screen
			fi
		fi
		
		if (( $(tput cols) <= 50 | $(tput lines) <= 20)); then
			info_reduite 2 3 "$(($(tput cols)-2))" "$logfile_enabled"
		else
			info_scinder 2 3 "$(($(tput cols)-2))" "$logfile_enabled"
		fi

        # Ecris dans les logs toutes les update_log_time secondes
        if (( SECONDS - start_time >= update_log_time )); then
            logfile_enabled=1       # Active l'écriture dans le log
            start_time=$SECONDS     # Réinitialise le compteur de temps
        else
            logfile_enabled=0       # Désactive l'écriture dans le log
        fi
	done

    # on remet l'état initial du terminal si l'utilisateur quitte normalement
    tput "rmcup"
    tput "cnorm"
    stty "$old_stty"
}

main "$@"
