#!/bin/bash
#pour les couleur tu peux aussi utiliser "\033[38;5<code couleurs>m" code en 256
. ./recup_info.sh

# Définir les valeurs par défaut
font_color_default="black"
color_default="red"
lang_default="en"
os_default="ubuntu"

red="\033[31m" #couleur caractères
fred="\033[41m" #couleur de fond
green="\033[32m"
yellow="\033[33m"
blue="\033[34m" # bleu
reset="\033[0m"

carre_plein="\u2588"
carre_vide="\u25A1"

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
	for ((i=1;i<=$cols;i++)); do
		for ((j=1;j<=$lines;j++)); do
			if (( i == 1 )); then
				printf "\33[%d;%dH" "$j" "$i"
				echo -en "${!color_default}+${reset}"
			elif (( j == 1 )); then
				printf "\33[%d;%dH" "$j" "$i"
				echo -en "${!color_default}+${reset}"
			elif (( j == lines )); then
				printf "\33[%d;%dH" "$j" "$i"
				echo -en "${!color_default}+${reset}"
			elif (( i == cols)); then
				printf "\33[%d;%dH" "$j" "$i"
				echo -en "${!color_default}+${reset}"
			else
				printf "\33[%d;%dH" "$j" "$i"
				echo -en " "
			fi
		done
	done
}

info_proc() {
	# info 1
	printf "\33[%d;%dH" "$x" "$y"
	echo -en "${!color_default}salut les boys${reset}"
	# info 2
	local x_plus_2=$((x + 3))
	printf "\33[%d;%dH" "$x_plus_2" "$y"
	echo -en "${reset}${carre_plein}${reset}"
}

info_reduite() { # Jamel Bailleul
	#Mémoire
	if recup_mem "used" >/dev/null 2>&1; then # afficher la RAM
		x=2
		y=3
		printf "\33[%d;%dH" "$x" "$y" # Permet de placer le curseur au coordonner x y
		echo -en "${!color_default}Memory : ${reset}"
		max=100 #$(recup_mem total) # recup la quantité max de la RAM
		current=$(generate_random 1 $max) #$(recup_mem used) # recup la quantité utilisé de la RAM
		print_bar_h "${!color_default}" "$y" $((cols - 2)) "$((x + 1))" "$current" "$max" # afficher la bar d'état de la memoire
	fi
	#CPU
	erreur=$(recup_cpu 2>&1)
	if (( $? != 1 )); then
		cpu_x=$((x+3))
		cpu_y=3
		printf "\33[%d;%dH" "$cpu_x" "$cpu_y" # Permet de placer le curseur au coordonner x y
		echo -en "${!color_default}CPU : $(recup_cpu)${reset}"
        #bar cpu
        max=100 #$(recup_gpu vramTotal)
		current=$(generate_random 1 $max) #$(recup_gpu vramUsed)
		print_bar_h "${!color_default}" "$cpu_y" $((cols - 2)) "$((cpu_x + 1))" "$current" "$max"
	fi
	#GPU
	if recup_gpu vramUsed >/dev/null 2>&1; then
		gpu_x=$((cpu_x+3))
		gpu_y=3
		printf "\33[%d;%dH" "$gpu_x" "$gpu_y" # Permet de placer le curseur au coordonner x y
		echo -en "${!color_default}GPU : ${reset}"
		max=100 #$(recup_gpu vramTotal)
		current=$(generate_random 1 $max) #$(recup_gpu vramUsed)
		print_bar_h "${!color_default}" "$gpu_y" $((cols - 2)) "$((gpu_x + 1))" "$current" "$max"
    else
        gpu_x=$((cpu_x+3))
		gpu_y=3
		printf "\33[%d;%dH" "$gpu_x" "$gpu_y" # Permet de placer le curseur au coordonner x y
		echo -en "${!color_default}GPU : info sur les gpu impossible à trouver${reset}"
        max=100 #$(recup_gpu vramTotal)
		current=$(generate_random 1 $max) #$(recup_gpu vramUsed)
		print_bar_h "${!color_default}" "$gpu_y" $((cols - 2)) "$((gpu_x + 1))" "$current" "$max"
    fi
	#Disk
	if recup_disk used >/dev/null 2>&1; then
		disk_x=$((gpu_x+3))
		disk_y=3
		printf "\33[%d;%dH" "$disk_x" "$disk_y" # Permet de placer le curseur au coordonner x y
		max=100 #$(recup_disk total | grep -o '[0-9.]*')
		current=$(generate_random 1 $max) #$(recup_disk used | grep -o '[0-9.]*')
		echo -en "${!color_default}Disk : ${reset}"
		print_bar_h "${!color_default}" "$disk_y" $((cols - 2)) $(echo "$disk_x + 1" | bc) "$current" "$max"
	else
        disk_x=$((x+3))
		disk_y=3
		printf "\33[%d;%dH" "$disk_x" "$disk_y" # Permet de placer le curseur au coordonner x y
		echo -en "${!color_default}Disk : info sur les disk impossible à trouver${reset}"
    fi
}

info_cpu() { # Jamel Bailleul
	# $1 = x lines
	# $2 = y cols
	# $3 = nb coeur
	# $4 = 
	printf "\33[%d;%dH" "$1" "$2"
	echo -en "${!color_default}CPU : ${reset}"
	print_bar_h "${!color_default}" "$y" $((cols - 2)) "$((x + 1))" 25 50
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
	percent=$(($current_tmp_bar * 100 / $max_tmp_bar))

	#echo "étape 2"
	for ((i=$2; i<=$3 - 3; i++)); do
		if (( $(echo "$i * 100 / ($3 - 4)" | bc) <= percent )); then
			res+="${carre_plein}"
		else
			res+="${reset}${carre_plein}"
		fi
	done
	
	printf "\33[%d;%dH" "$4" "$2"
	echo -en "$res${reset} $percent%"
}

exporter_variables() {  # Jamel Bailleul
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

	# vérifie la présence d'un fichier de config
	if [[ -f "$1" ]]; then
		exporter_variables "$1"
	else
		echo "Non, le fichier '$1' n'existe pas."
	fi

	clear_screen
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
			clear_screen
		fi
		info_reduite

		# Pause de 1 seconde avant d'afficher à nouveau les info
		#sleep 1
	done
	stty sane
}

main "$@"
stty sane
