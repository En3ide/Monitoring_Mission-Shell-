#!/bin/bash
#pour les couleur tu peux aussi utiliser "\033[38;5<code couleurs>m" code en 256
. ./src/recup_info.sh
. ./src/update_log.sh

# Définir les valeurs par défaut

# bg
bg_color="BG_BLACK"

# FONT
font_color="FONT_WHITE"
border_color="FONT_BRIGHT_MAGENTA"
font_processus_color="FONT_WHITE"

full_memory_bar_color="FONT_GREEN"
empty_memory_bar_color="FONT_WHITE"

full_gpu_bar_color="FONT_CYAN"
empty_gpu_bar_color="FONT_WHITE"

full_disk_bar_color="FONT_RED"
empty_disk_bar_color="FONT_WHITE"

full_cpu_bar_color="FONT_BLUE"
empty_cpu_bar_color="FONT_WHITE"

full_core_bar_color="FONT_BRIGHT_BLUE"
empty_core_bar_color="FONT_WHITE"

full_net_bar_color="FONT_YELLOW"
empty_net_bar_color="FONT_WHITE"

# CARACTERE
border_char="unicode_full_block"
full_bar_char="unicode_dark_shade"
empty_bar_char="unicode_light_shade"

# OTHERS
minimum_lines_width=30
minimum_cols_height=70
update_log_time=1
overwrite_log="true"

# Variables pour les couleurs de fond (background)
BG_BLACK="\033[40m"
BG_RED="\033[41m"
BG_GREEN="\033[42m"
BG_YELLOW="\033[43m"
BG_BLUE="\033[44m"
BG_MAGENTA="\033[45m"
BG_CYAN="\033[46m"
BG_WHITE="\033[47m"

# Variables pour les couleurs claires de fond (bright background)
BG_BRIGHT_BLACK="\033[100m"
BG_BRIGHT_RED="\033[101m"
BG_BRIGHT_GREEN="\033[102m"
BG_BRIGHT_YELLOW="\033[103m"
BG_BRIGHT_BLUE="\033[104m"
BG_BRIGHT_MAGENTA="\033[105m"
BG_BRIGHT_CYAN="\033[106m"
BG_BRIGHT_WHITE="\033[107m"

# Variables pour les couleurs de texte (foreground)
FONT_BLACK="\033[30m"
FONT_RED="\033[31m"
FONT_GREEN="\033[32m"
FONT_YELLOW="\033[33m"
FONT_BLUE="\033[34m"
FONT_MAGENTA="\033[35m"
FONT_CYAN="\033[36m"
FONT_WHITE="\033[37m"

# Variables pour les couleurs claires (bright foreground)
FONT_BRIGHT_BLACK="\033[90m"
FONT_BRIGHT_RED="\033[91m"
FONT_BRIGHT_GREEN="\033[92m"
FONT_BRIGHT_YELLOW="\033[93m"
FONT_BRIGHT_BLUE="\033[94m"
FONT_BRIGHT_MAGENTA="\033[95m"
FONT_BRIGHT_CYAN="\033[96m"
FONT_BRIGHT_WHITE="\033[97m"

# Réinitialiser les couleurs
DEFAULT_COLOR='\033[0m'                 # Réinitialiser les couleurs

# Caractères Unicode random
unicode_up_row="\u2191"                 # fleche vers le haut
unicode_down_row="\u2193"               # fleche vers le bas

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

read_config_file() {  # Jamel Bailleul & Tim Lamour
    local fichier="$1"
    # Vérifie si le fichier existe
    if [ -f "$fichier" ]; then 
        while IFS='=' read -r cle valeur; do # Boucle pour lire chaque ligne du fichier

            # Supprime les espaces inutiles autour
            cle=$(echo "$cle" | xargs)
            valeur=$(echo "$valeur" | xargs)

            saved_cle="$cle"
            saved_valeur="$valeur"

            # Ignore ligne vide et commentaire
            if [[ -z "$cle" || "$cle" == \#* ]]; then
                continue
            fi

            # Vérifier qu'une clé et une valeur ont bien été lu
            if [ -z "$cle" ]; then
                echo "Syntax error with '$saved_cle' in config file : no affection." >&2
                exit 2
            elif [ -z "$valeur" ]; then
                echo "Syntax error with '$saved_cle' in config file : no value." >&2
                exit 3
            fi

            # Vérifier la clé est correcte
            if [[ -z "${!cle}" ]]; then
                echo "Syntax error with '$saved_cle=$saved_valeur' in config file : unknown variable." >&2
                exit 4
            fi

            case "$cle" in 
                "minimum_lines_width"|"minimum_cols_height"|"update_log_time")
                    if ! [[ "$valeur" =~ ^[0-9]+$ ]] || [[ "$valeur" -le 0 ]]; then
                    echo "Syntax error with '$saved_cle=$saved_valeur' in config file : need to be a positive number." >&2
                    exit 6
                    fi
                    ;;
                "overwrite_log")
                    if [[ "$valeur" != "true" && "$valeur" != "false" ]]; then
                        echo "Syntax error with '$saved_cle=$saved_valeur' in config file : need to be true or false." >&2
                        exit 7
                    fi
                    ;;
                *_color|*_char)
                    if [[ "$cle" == "bg_color" ]]; then
                        valeur="BG_$valeur"
                    else 
                        valeur="FONT_$valeur"
                    fi

                    if [[ -z "${!valeur}" ]]; then
                        echo "Syntax error with '$saved_cle=$saved_valeur' in config file : unknown variable value." >&2
                        exit 5
                    fi
                    ;;
            esac

            export "$cle=$valeur"
        done < "$fichier"
    else
        echo "Le fichier '$fichier' n'existe pas." >&2
        exit 1
    fi
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
        x=$(( $1 + ( 3 * position ) ))  # Position en ligne ajustée selon la position
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
            logfile_content="${logfile_content}Memory     : Used ${used_memory} MB / Total ${max_memory} MB (Usage ${percent}%)\n"
        fi

        # Afficher les informations de mémoire sous forme de texte
        echo -en "${!bg_color}${!font_color}Memory : ${used_memory}Kb / ${max_memory}Kb${reset}"

        # Afficher la barre d'état de la mémoire
        print_bar "${!bg_color}${!full_memory_bar_color}" "$y" "$3" "$(( x + 1 ))" "$percent" "${empty_memory_bar_color}"
    fi

    # GPU (%)
    local used_gpu=$(recup_gpu "percent" 2>/dev/null)
    if [ -n "$used_gpu" ]; then
        # Calcul de la position pour afficher les informations de GPU
        x=$(( $1 + ( 3 * position ) ))  # Position en ligne ajustée selon la position actuelle
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
            logfile_content="${logfile_content}GPU        : Usage ${percent}%\n"
        fi

        # Afficher l'en-tête de la section GPU
        echo -en "${!bg_color}${!font_color}GPU % : ${reset}"

        # Afficher la barre d'état pour l'utilisation de la VRAM
        print_bar "${!bg_color}${!full_gpu_bar_color}" "$y" "$3" "$(( x + 1 ))" "$percent" "${empty_gpu_bar_color}"
    fi

    # GPU (vram)
    local used_vram_gpu=$(recup_gpu "vramUsed" 2>/dev/null)
    if [ -n "$used_vram_gpu" ]; then
        # Calcul de la position pour afficher les informations de GPU
        x=$(( $1 + ( 3 * position ) ))  # Position en ligne ajustée selon la position actuelle
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
            logfile_content="${logfile_content}GPU VRAM   : Used ${used_vram_gpu} MB / Total ${max_vram_gpu} MB (Usage ${percent}%)\n"
        fi

        # Afficher l'en-tête de la section GPU
        echo -en "${!bg_color}${!font_color}GPU VRAM : ${reset}"

        # Afficher la barre d'état pour l'utilisation de la VRAM
        print_bar "${!bg_color}${!full_gpu_bar_color}" "$y" "$3" "$(( x + 1 ))" "$percent" "${empty_gpu_bar_color}"
    fi

    # Disque
    local used_disk=$(recup_disk "used" 2>/dev/null)
    if [ -n "$used_disk" ]; then
        # Calcul de la position pour afficher les informations de disque
        x=$(( $1 + ( 3 * position ) ))  # Position en ligne ajustée selon la position actuelle
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
            logfile_content="${logfile_content}Disk       : Used ${used_disk} GB / Total ${max_disk} GB (Usage ${percent}%)\n"
        fi

        # Afficher les informations de disque sous forme de texte
        echo -en "${!bg_color}${!font_color}Disk : ${used_disk} / ${max_disk}${reset}"

        # Afficher la barre d'état pour l'utilisation du disque
        print_bar "${!bg_color}${!full_disk_bar_color}" "$y" "$3" "$(( x + 1 ))" "$percent" "${empty_disk_bar_color}"
    fi

    # CPU (%)
    local cpu_name=$(recup_cpu "name" 2>/dev/null)
    local used_cpu=$(recup_cpu "cpu" 2>/dev/null)
    if [[ -n "$cpu_name" && -n "$used_cpu" ]]; then
        # Calcul de la position pour afficher les informations de CPU
        x=$(( $1 + ( 3 * position ) ))  # Position en ligne ajustée selon la position actuelle
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
            logfile_content="${logfile_content}CPU        : Total ${percent}%\n             "
        fi

        # Afficher le nom du CPU avec une longueur limitée par la largeur disponible
        echo -en "${!bg_color}${!font_color}CPU % : ${cpu_name:0:$(( $3 - 10 ))}${reset}"

        # Afficher la barre d'état pour l'utilisation du CPU
        print_bar "${!bg_color}${!full_cpu_bar_color}" "$y" "$3" "$(( x + 1 ))" "$percent" "${empty_cpu_bar_color}"
    fi

    # CPU CORE (%)
    local used_cpu=$(recup_cpu "cpu1" 2>/dev/null)
    if [[ -n "$used_cpu" && $(tput lines) > 20 ]]; then
        local position_tmp="$position"
        local fin_bar=$(($3 / 2 ))
        local nb_core=$(recup_nb_core_cpu)
        local espace=1
        if [[ $(( $1 + ( 3 * (( $nb_core / 2 ) + $position )))) < $(tput lines) ]]; then
            local count=0
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
                    x=$(( $1 + ( 3 * position ) ))  # Position en ligne ajustée selon la position

                    # Incrémenter la position pour la prochaine section
                    position=$(( position + 1 ))

                    # Placer le curseur aux coordonnées (x, y) pour l'affichage
                    printf "\33[%d;%dH" "$x" "$y"

                    # Calculer le pourcentage
                    percent=$(calculate_percent "$used_cpu" "$max_cpu")
                    
                    # Concatener dans le contenu à rajouter au logfile si demandé
                    if [ "$logfile_enabled" == 1 ]; then
                        logfile_content="${logfile_content}Core $j : ${percent}% | "
                        count=$(( count + 1 ))
                        if [[ "$count" -ge 6 && "$j" -ne "$nb_core" ]]; then
                            logfile_content="${logfile_content}\n             "
                            count=0
                        fi
                    fi

                    # Afficher le nom du CPU avec une longueur limitée par la largeur disponible
                    echo -en "${!bg_color}${!font_color}CORE : ${j}${reset}"

                    # Afficher la barre d'état pour l'utilisation du CPU
                    print_bar "${!bg_color}${!full_core_bar_color}" "$y" "$(($fin_bar - $espace))" "$(( x + 1 ))" "$percent" "${empty_core_bar_color}"
                else
                    return 1
                fi
            done
        fi
    fi

    logfile_content="${logfile_content}\n"
    # Net
    local inter_name=$(get_interface_name 2>/dev/null)
    if [[ -n "$inter_name" && $(tput lines) > $(( $1 + ( 3 * position ) + 9 )) ]]; then
        # Calcul de la position pour afficher les informations de reseaux
        x=$(( $1 + ( 3 * position ) ))  # Position en ligne ajustée selon la position actuelle
        y="$2"  # Position en colonne reçue en argument

        # Incrémenter la position pour la prochaine section
        position=$(( position + 1 ))

        printf "\33[%d;%dH" "$x" "$(($y - 1))"
        for ((i=0; i < $3 ; i++)); do
            echo -en "${!bg_color}${!border_color}${!border_char}${reset}"
        done
        local nb_inter=$( echo $inter_name | awk '{print NF}')
        for (( i=1 ; i <= $nb_inter ; i++)); do
            local name=$(echo $inter_name | awk -v var="$variable" '{print var, $1}')
            # Calcul de la position pour afficher les informations de reseaux
            x=$(( $1 + ( 3 * position ) - 2 ))  # Position en ligne ajustée selon la position actuelle
            y="$2"  # Position en colonne reçue en argument

            # Incrémenter la position pour la prochaine section
            position=$(( position + 1 ))
            
            # Calculer le pourcentage
            local download=$(recup_network "download" $name)
            local upload=$(recup_network "upload" $name)

            # Concatener dans le contenu à rajouter au logfile si demandé
            if [ "$logfile_enabled" == 1 ]; then
                logfile_content="${logfile_content}Network    : Download ${download} Bytes | Download/S ${download_s} Bytes/S | Upload ${upload} Bytes | Upload/S ${upload_s} Bytes/S\n"
            fi

            # Placer le curseur aux coordonnées (x, y) pour l'affichage
            printf "\33[%d;%dH" "$x" "$y"
            echo -en "${!bg_color}${!font_color}${!empty_bar_char}${name:0:$(( $3 - 7 ))} ${!empty_bar_char}${reset}"
            printf "\33[%d;%dH" "$(($x + 1))" "$y"
            if [[ $download -ne $(recup_network "download" $name) ]]; then
                download_s=$(($(recup_network "download" $name) - $download))
            fi
            if [[ $upload -ne $(recup_network "upload" $name) ]]; then
                upload_s=$(($(recup_network "upload" $name) - $upload))
            fi
            echo -en "${!bg_color}${!font_color}Download total : ${download:0:$(( $3 - 7 ))} Bytes${reset}"
            printf "\33[%d;%dH" "$(($x + 2))" "$y"
            echo -en "${!bg_color}${!font_color}Speed Download/s : ${download_s} Bytes/s${reset}"
            printf "\33[%d;%dH" "$(($x + 3))" "$y"
            echo -en "${!bg_color}${!font_color}Download Errors : ${reset}"

            # Calculer le pourcentage
            percent=$(calculate_percent $(recup_network "downloadErr" $name) $(recup_network "downloadPackets" $name))
            print_bar "${!bg_color}${!full_net_bar_color}" "$y" "$(($fin_bar - $espace))" "$(( x + 4 ))" "$percent" "${empty_net_bar_color}"
            printf "\33[%d;%dH" "$(($x + 5))" "$y"
            echo -en "${!bg_color}${!font_color}Upload total : ${upload:0:$(( $3 - 7 ))} Bytes${reset}"
            printf "\33[%d;%dH" "$(($x + 6))" "$y"
            echo -en "${!bg_color}${!font_color}Upload/s : ${upload_s} Bytes/s${reset}"

            # Calculer le pourcentage
            printf "\33[%d;%dH" "$(($x + 7))" "$y"
            echo -en "${!bg_color}${!font_color}Upload Errors : ${reset}"
            percent=$(calculate_percent $(recup_network "downloadErr" $name) $(recup_network "downloadPackets" $name))
            print_bar "${!bg_color}${!full_net_bar_color}" "$y" "$(($fin_bar - $espace))" "$(( x + 8 ))" "$percent" "${empty_net_bar_color}"
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
    local cols_proc=$(($max_cols / 2 )) # Moitié des colonnes pour diviser la zone
    local lines_proc=$(($max_lines / 2 )) # Moitié des lignes pour diviser la zone

    # Appel de la fonction info_reduite avec les paramètres ajustés
    info_reduite "$cols" "$lines" "$((($max_cols / 2) - 2))" "$logfile_enabled"

    # Appel initial de la fonction récursive
    affiche_processus "$(($cols_proc + 2))" "$lines" "$(( max_lines - 2))" "$(tput cols)" "$(recup_processus)"
}

affiche_processus() { # Jamel Bailleul - fonction récursive (en récursif c'est pas optimisé mais on devait en faire une)
    local start_col="$1"    # Colonne de début
    local start_line="$2"   # Ligne de début
    local end_line="$3"     # Ligne de fin
    local end_col="$4"      # Colonne de fin
    local text="$5"         # Texte contenant les informations des processus

    # Condition d'arrêt : Si la ligne actuelle dépasse la fin, arrêter la récursion
    if (( start_line >= end_line )); then
        return
    fi

    # Obtenir la première ligne du texte
    local first_line=$(echo "$text" | head -n 1)
    
    # Calculer le nombre de caractères à afficher
    local nb_char=$(($end_col - $start_col))
    
    # Positionner le curseur et afficher les premiers caractères de la ligne
    printf "\033[%d;%dH" "$start_line" "$start_col"
    echo -en "${!bg_color}${!font_processus_color}${first_line:0:${nb_char}}"
    
    # Appel récursif : avancer d'une ligne et supprimer la première ligne du texte
    local new_text=$(echo "$text" | sed '1d')
    affiche_processus "$start_col" "$((start_line + 1))" "$end_line" "$end_col" "$new_text"
}

print_bar() { # Jamel Bailleul
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
