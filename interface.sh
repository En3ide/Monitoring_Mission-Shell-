#!/bin/bash
#pour les couleur tu peux aussi utiliser "\033[38;5<code couleurs>m" code en 256
. ./recup_info.sh
. ./update_log.sh

# Définir les valeurs par défaut
os_default="ubuntu"

bg_color="DARK_BLACK_BIS"
font_color="DARK_WHITE"
border_color="BRIGHT_MAGENTA"
font_processus_color="DARK_WHITE"

full_net_bar_color="DARK_BLUE"
full_cpu_bar_color="DARK_BLUE"
full_core_bar_color="BRIGHT_BLUE"
full_gpu_bar_color="DARK_GREEN"
full_memory_bar_color="DARK_GREEN"
full_disk_bar_color="DARK_RED"

empty_net_bar_color="DARK_WHITE"
empty_cpu_bar_color="DARK_WHITE"
empty_core_bar_color="DARK_WHITE"
empty_gpu_bar_color="DARK_WHITE"
empty_memory_bar_color="DARK_WHITE"
empty_disk_bar_color="DARK_WHITE"

border_char="unicode_full_block"
full_bar_char="unicode_dark_shade"
empty_bar_char="unicode_light_shade"

minimum_lines_width=30
minimum_cols_height=70
update_log_time=60
overwrite_log="true"

# Couleurs sombres (Dark)
DARK_BLACK='\033[0;30m'      # Noir foncé
DARK_RED='\033[0;31m'        # Rouge foncé
DARK_GREEN='\033[0;32m'      # Vert foncé
DARK_YELLOW='\033[0;33m'     # Jaune foncé
DARK_BLUE='\033[0;34m'       # Bleu foncé
DARK_MAGENTA='\033[0;35m'    # Magenta foncé
DARK_CYAN='\033[0;36m'       # Cyan foncé
DARK_WHITE='\033[0;37m'      # Blanc/gris foncé

# Couleurs vives (Bright)
BRIGHT_BLACK='\033[1;30m'     # Noir clair (gris foncé)
BRIGHT_RED='\033[1;31m'       # Rouge clair
BRIGHT_GREEN='\033[1;32m'     # Vert clair
BRIGHT_YELLOW='\033[1;33m'    # Jaune clair
BRIGHT_BLUE='\033[1;34m'      # Bleu clair
BRIGHT_MAGENTA='\033[1;35m'   # Magenta clair
BRIGHT_CYAN='\033[1;36m'      # Cyan clair
BRIGHT_WHITE='\033[1;37m'     # Blanc/gris clair

# Couleurs BIS pour Bright
BRIGHT_BLACK_BIS='\033[1;90m'   # Noir clair bis
BRIGHT_RED_BIS='\033[1;91m'     # Rouge clair bis
BRIGHT_GREEN_BIS='\033[1;92m'   # Vert clair bis
BRIGHT_YELLOW_BIS='\033[1;93m'  # Jaune clair bis
BRIGHT_BLUE_BIS='\033[1;94m'    # Bleu clair bis
BRIGHT_MAGENTA_BIS='\033[1;95m' # Magenta clair bis
BRIGHT_CYAN_BIS='\033[1;96m'    # Cyan clair bis
BRIGHT_WHITE_BIS='\033[1;97m'   # Blanc/gris clair bis

# Couleurs supplémentaires pour le texte de fond (Background)
DARK_RED_BIS='\033[41m'         # Fond rouge foncé
DARK_GREEN_BIS='\033[42m'       # Fond vert foncé
DARK_YELLOW_BIS='\033[43m'      # Fond jaune foncé
DARK_BLUE_BIS='\033[44m'        # Fond bleu foncé
DARK_MAGENTA_BIS='\033[45m'     # Fond magenta foncé
DARK_CYAN_BIS='\033[46m'        # Fond cyan foncé
DARK_WHITE_BIS='\033[47m'       # Fond blanc/gris foncé

# Réinitialiser les couleurs
RESET_COLOR='\033[0m'                 # Réinitialiser les couleurs

# Caractères Unicode de type carré
unicode_full_block="\u2588"             # Bloc complet (Full Block)
unicode_upper_half_block="\u2580"       # Demi-bloc supérieur (Upper Half Block)
unicode_lower_half_block="\u2584"       # Demi-bloc inférieur (Lower Half Block)
unicode_left_half_block="\u258C"        # Demi-bloc gauche (Left Half Block)
unicode_right_half_block="\u2590"       # Demi-bloc droit (Right Half Block)

unicode_light_shade="\u2591"            # Ombrage léger (Light Shade)
unicode_medium_shade="\u2592"           # Ombrage moyen (Medium Shade)
unicode_dark_shade="\u2593"             # Ombrage foncé (Dark Shade)

unicode_white_square="\u25A1"           # Carré blanc (White Square)
unicode_black_circle="\u25CF"           # Cercle noir (Black Circle)
unicode_white_circle="\u25CB"           # Cercle blanc (White Circle)
unicode_black_diamond="\u25C6"          # Losange noir (Black Diamond)
unicode_white_diamond="\u25C7"          # Losange blanc (White Diamond)
unicode_black_star="\u2605"             # Étoile noire (Black Star)
unicode_white_star="\u2606"             # Étoile blanche (White Star)

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
                echo -en "${!bg_color}${!border_color}${!border_char}${reset}"
            else
                # Remplir avec un espace vide
                echo -en "${!bg_color}${!border_color} ${reset}"
            fi
        done
    done
}

info_reduite() { # Jamel Bailleul & Tim Lamour
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
        print_bar_h "${!bg_color}${!full_memory_bar_color}" "$y" "$3" "$(( x + 1 ))" "$percent" "${empty_memory_bar_color}"
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
        print_bar_h "${!bg_color}${!full_gpu_bar_color}" "$y" "$3" "$(( x + 1 ))" "$percent" "${empty_gpu_bar_color}"
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
        print_bar_h "${!bg_color}${!full_gpu_bar_color}" "$y" "$3" "$(( x + 1 ))" "$percent" "${empty_gpu_bar_color}"
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
        print_bar_h "${!bg_color}${!full_disk_bar_color}" "$y" "$3" "$(( x + 1 ))" "$percent" "${empty_disk_bar_color}"
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
        local max_cpu=100
        
        # Calculer le pourcentage
        percent=$(calculate_percent "$used_cpu" "$max_cpu")

        # Concatener dans le contenu à rajouter au logfile si demandé
        if [ "$logfile_enabled" == 1 ]; then
            logfile_content="$logfile_content CPU => Usage : $percent%\n"
        fi

        # Afficher le nom du CPU avec une longueur limitée par la largeur disponible
        echo -en "${!bg_color}${!font_color}CPU % : ${cpu_name:0:$(( $3 - 10 ))}${reset}"

        # Afficher la barre d'état pour l'utilisation du CPU
        print_bar_h "${!bg_color}${!full_cpu_bar_color}" "$y" "$3" "$(( x + 1 ))" "$percent" "${empty_cpu_bar_color}"
    fi

    local used_cpu=$(recup_cpu "cpu1" 2>/dev/null)
    if [[ -n "$used_cpu" && $(tput lines) > 20 ]]; then
        local position_tmp="$position"
        local fin_bar=$(($3 /2))
        local nb_core=$(recup_nb_core_cpu)
        local espace=1
        if [[ $(( $1 + (3 * (( $nb_core / 2 ) + $position )))) < $(tput lines) ]]; then
            for (( j=1; j <= nb_core ; j++ )); do
                if [[ $j == $((( $nb_core / 2 ) + 1 )) ]]; then
                    local i=2
                    local y=$(( $fin_bar + 1 ))
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
                    print_bar_h "${!bg_color}${!full_core_bar_color}" "$y" "$(($fin_bar - $espace))" "$(( x + 1 ))" "$percent" "${empty_core_bar_color}"
                else
                    return 1
                fi
            done
        fi
    fi

    # Net
    local inter_name=$(get_interface_name 2>/dev/null)
    if [[ -n "$inter_name" && $(tput lines) > $(( $1 + (3 * position) + 9 )) ]]; then
        # Calcul de la position pour afficher les informations de reseaux
        x=$(( $1 + (3 * position) ))  # Position en ligne ajustée selon la position actuelle
        y="$2"  # Position en colonne reçue en argument

        # Incrémenter la position pour la prochaine section
        position=$(( position + 1 ))

        printf "\33[%d;%dH" "$x" "$(($y - 1))"
        for ((i=0; i < $3 ; i++)); do
            echo -en "${!bg_color}${!border_color}${!border_char}${reset}"
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
            download=$(get_network "download" $name)
            upload=$(get_network "upload" $name)

            # Concatener dans le contenu à rajouter au logfile si demandé
            if [ "$logfile_enabled" == 1 ]; then
                logfile_content="$logfile_content $name => Download : $download Bytes | Download/S : $download_s Bytes/S | Upload = $upload Bytes | Upload/S : $upload_s Bytes/S\n"
            fi

            # Placer le curseur aux coordonnées (x, y) pour l'affichage
            printf "\33[%d;%dH" "$x" "$y"
            echo -en "${!bg_color}${!font_color}${!empty_bar_char}${name:0:$(( $3 - 7 ))} ${!empty_bar_char}${reset}"
            printf "\33[%d;%dH" "$(($x + 1))" "$y"
            if [[ $download -ne $(get_network "download" $name) ]]; then
                download_s=$(($(get_network "download" $name) - $download))
            fi
            if [[ $upload -ne $(get_network "upload" $name) ]]; then
                upload_s=$(($(get_network "upload" $name) - $upload))
            fi
            echo -en "${!bg_color}${!font_color}Download total : ${download:0:$(( $3 - 7 ))} Bytes${reset}"
            printf "\33[%d;%dH" "$(($x + 2))" "$y"
            echo -en "${!bg_color}${!font_color}Speed Download/s : ${download_s} Bytes/s${reset}"
            printf "\33[%d;%dH" "$(($x + 3))" "$y"
            echo -en "${!bg_color}${!font_color}Net Error Download : ${reset}"
            # Calculer le pourcentage
            percent=$(calculate_percent $(get_network "downloadErr" $name) $(get_network "downloadPackets" $name))
            print_bar_h "${!bg_color}${!full_net_bar_color}" "$y" "$(($fin_bar - $espace))" "$(( x + 4 ))" "$percent" "${empty_net_bar_color}"
            printf "\33[%d;%dH" "$(($x + 5))" "$y"
            echo -en "${!bg_color}${!font_color}Upload total : ${upload:0:$(( $3 - 7 ))} Bytes${reset}"
            printf "\33[%d;%dH" "$(($x + 6))" "$y"
            echo -en "${!bg_color}${!font_color}Upload/s : ${upload_s} Bytes/s${reset}"
            # Calculer le pourcentage
            printf "\33[%d;%dH" "$(($x + 7))" "$y"
            echo -en "${!bg_color}${!font_color}Net Error Upload : ${reset}"
            percent=$(calculate_percent $(get_network "downloadErr" $name) $(get_network "downloadPackets" $name))
            print_bar_h "${!bg_color}${!full_net_bar_color}" "$y" "$(($fin_bar - $espace))" "$(( x + 8 ))" "$percent" "${empty_net_bar_color}"
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
		echo -en "${!bg_color}${!font_processus_color}${first_line:0:${nb_char}}"
		text=$(echo "$text" | sed '1d')
    done
}

print_bar_h() { # Jamel Bailleul
    # $1 = couleur
    # $2 = cols debut de barre
    # $3 = cols fin de barre
    # $4 = lines
    # $5 = percent
    # $6 = couleur bar vide

    if [[ -z "$6" ]]; then
        bar_vide=""
    else
        bar_vide="$6"
    fi

    current_tmp_bar=$(echo "$current_tmp_bar" | tr -d '.')

    local percent="$5"

    local res="$1"
    for ((i=$2; i<=$3 - 3; i++)); do
        calculated_percent=$(( i * 100 / ( $3 - 4 ) ))
        if (( calculated_percent <= percent )); then
            res+="${!bg_color}${!full_bar_char}"
        else
            if [[ -z "$bar_vide" ]]; then
                res+="${!empty_bar_char}"
            else
                res+="${!bar_vide}${!empty_bar_char}"
            fi
        fi
    done

    printf "\33[%d;%dH" "$4" "$2"
    if [[ "$percent" -lt 100 ]]; then
        percent="${percent}% "
    fi
    echo -en "${!bg_color}${!font_color}$res${!bg_color}${!font_color}$percent${reset}"
}


config_file() {  # Jamel Bailleul
    local fichier="$1"

    # Vérifie si le fichier existe
    if [ -f "$fichier" ]; then 
        while IFS='=' read -r cle valeur; do # Boucle pour lire chaque ligne du fichier

            # Supprime les espaces inutiles autour
            cle=$(echo "$cle" | xargs)
            valeur=$(echo "$valeur" | xargs)
            echo $cle >> test.txt
            echo $valeur >> test.txt
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

	if (( $(tput cols) > $minimum_cols_height && $(tput lines) > minimum_lines_width )); then 
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
    create_logfile "$overwrite_log"

    local logfile_enabled=0
    local start_time="$SECONDS"
	while true; do
		if (( $(tput cols) != $cols || $(tput lines) != $lines )); then
            	local cols=$(tput cols)
	            local lines=$(tput lines)
			if (( $cols > minimum_cols_height && $lines > $minimum_lines_width )); then 
				clear_screen "$(($(tput cols) / 2))"
			else
				clear_screen
			fi
		fi

        # Ecris dans les logs toutes les update_log_time secondes
        if (( SECONDS - start_time >= update_log_time )); then
            logfile_enabled=1       # Active l'écriture dans le log
            start_time=$SECONDS     # Réinitialise le compteur de temps
        else
            logfile_enabled=0       # Désactive l'écriture dans le log
        fi
		
		if (( $(tput cols) <= minimum_cols_height | $(tput lines) <= minimum_lines_width)); then
			info_reduite 2 3 "$(($(tput cols)-2))" "$logfile_enabled"
		else
			info_scinder 2 3 "$(($(tput cols)-2))" "$logfile_enabled"
		fi
	done

    # on remet l'état initial du terminal si l'utilisateur quitte normalement
    tput "rmcup"
    tput "cnorm"
    stty "$old_stty"
}

main "$@"
