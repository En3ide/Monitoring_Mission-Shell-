#!/bin/bash
#pour les couleur tu peux aussi utiliser "\033[38;5<code couleurs>m" code en 256
. ./recup_info.sh

# Définir les valeurs par défaut
local font_color_default="black"
local color_default="red"
local lang_default="en"
local os_default="ubuntu"
local 

red="\033[31m" #couleur caractères
fred="\033[41m" #couleur de fond
green="\033[32m"
yellow="\033[33m"
blue="\033[34m" # bleu
reset="\033[0m"


carre_plein="\u2588"
carre_vide="\u25A1"
#if (( cols < 50 )); then 
#if (( lines < 30 ))

clear_screen() { # Jamel Bailleul
	cols=$(tput cols)
	lines=$(tput lines)
	for ((i=1;i<=$cols;i++)); do
		for ((j=1;j<=$lines;j++)); do
			if (( i == 1 )); then
				printf "\33[%d;%dH" "$j" "$i";
				echo -en "${!color_default}+${reset}";
			elif (( j == 1 )); then
				printf "\33[%d;%dH" "$j" "$i";
				echo -en "${!color_default}+${reset}";
			elif (( j == lines )); then
				printf "\33[%d;%dH" "$j" "$i";
				echo -en "${!color_default}+${reset}";
			elif (( i == cols)); then
				printf "\33[%d;%dH" "$j" "$i";
				echo -en "${!color_default}+${reset}";
			else
				printf "\33[%d;%dH" "$j" "$i";
				echo -en " ";
			fi
		done
	done
}

info_proc() {
	# info 1
	printf "\33[%d;%dH" "$x" "$y";
	echo -en "${!color_default}salut les boys${reset}";
	# info 2
	local x_plus_2=$((x + 3))
	printf "\33[%d;%dH" "$x_plus_2" "$y";
	echo -en "${reset}${carre_plein}${reset}";
	# info 3
}

info_reduite() { # Jamel Bailleul
	#Mémoire
	if recup_mem "used"; then # afficher la RAM
		x=2;
		y=3;
		printf "\33[%d;%dH" "$x" "$y"; # Permet de placer le curseur au coordonner x y
		echo -en "${!color_default}Memory : ${reset}";
		max=$(recup_mem total); # recup la quantité max de la RAM
		current=$(recup_mem used); # recup la quantité utilisé de la RAM
		print_bar_h "${!color_default}" "$y" $((cols - 2)) "$((x + 1))" "$current" "$max"; # afficher la bar d'état de la memoire
	fi
	#CPU
	erreur=$(recup_cpu 2>&1);
	if [[ $? -ne 1 ]]; then
		x=$((x+3));
		y=3;
		printf "\33[%d;%dH" "$x" "$y"; # Permet de placer le curseur au coordonner x y
		echo -en "${!color_default}CPU : $(recup_cpu)${reset}";
		# if ! get_cpu_usage; then
		#	print_bar_h "${color_default}" "$y" $((cols - 2)) "$((x + 1))" 25 50; # afficher la bar d'état du cpu
		#fi
	fi
	#GPU
	if ! recup_gpu vramUsed; then
		x=$((x+3));
		y=3;
		printf "\33[%d;%dH" "$x" "$y"; # Permet de placer le curseur au coordonner x y
		echo -en "${!color_default}GPU : ${reset}";
		max=$(recup_gpu vramTotal);
		current=$(recup_gpu vramUsed);
		print_bar_h "${!color_default}" "$y" $((cols - 2)) "$((x + 1))" "$current" "$max";
	fi
	#Disk
	if ! recup_disk used; then
		x=$((x+3));
		y=3;
		printf "\33[%d;%dH" "$x" "$y"; # Permet de placer le curseur au coordonner x y
		max=$(recup_disk total | grep -o '[0-9.]*');
		current=$(recup_disk used | grep -o '[0-9.]*');
		echo -en "${!color_default}Disk : ${reset}";
		print_bar_h "${!color_default}" "$y" $((cols - 2)) $(echo "$x + 1" | bc) "$current" "$max";
	fi
}

info_cpu() { # Jamel Bailleul
	# $1 = x lines
	# $2 = y cols
	# $3 = nb coeur
	# $4 = 
	printf "\33[%d;%dH" "$1" "$2";
	echo -en "${!color_default}CPU : ${reset}";
	print_bar_h "${!color_default}" "$y" $((cols - 2)) "$((x + 1))" 25 50;
}

print_bar_h() { # Jamel Bailleul
	# $1 = couleur
	# $2 = cols debut de barre
	# $3 = cols fin de barre
	# $4 = lines
	# $5 = current var
	# $6 = max var
	res="$1"
	echo "etape 1 "
	# Utilisation de bc pour gérer les nombres à virgule
	percent=$(echo "scale=2; $5 * 100 / $6" | bc);

	echo "étape 2"
	for ((i=$2; i<=$3 - 3; i++)); do
		tmp=$((echo "" | bc));
		if (( $(echo "$i * 100 / ($3 - 4)" | bc) <= percent )); then
			res+="${carre_plein}"
		else
			res+="${reset}${carre_plein}"
		fi
	done
	
	printf "\33[%d;%dH" "$4" "$2"
	echo -en "$res${reset} $percent%"
}

exporter_variables() {
    local fichier="$1"

    if [[ -f "$fichier" ]]; then # Vérifie si le fichier existe
        while IFS='=' read -r cle valeur; do # Boucle pour lire chaque ligne du fichier
            if [[ -n "$cle" && -n "$valeur" ]]; then
                export "$cle"="$valeur" # Exporter chaque clé comme une variable d'environnement
            fi
        done < "$fichier"
        echo "Les variables d'environnement ont été définies."
    else
        echo "Le fichier '$fichier' n'existe pas."
    fi
}

main() {
    # prepare la zone de texte pour ne pas afficher le curseur ou les caratère taper
	stty -icanon -echo
    trap "stty sane; exit" INT TERM

	# vérifie la presence de d'un fichier de config
	if [ -f "$1" ]; then
		exporter_variables $1
	else
		echo "Non, le fichier '$1' n'existe pas."
	fi

	clear_screen
	cols=$(tput cols)
	lines=$(tput lines)
	while true; do
		if (($(tput cols) != $cols || $(tput lines) != $lines)); then
			clear_screen;
		fi
		info_reduite
		# Utilise la commande read avec l'option -n1 pour lire un seul caractère
		read -n 1 -s input

		# Si l'utilisateur appuie sur 'q', on sort de la boucle
		if [ "$input" == "q" ]; then
			echo "Au revoir!"
			break
		fi

		# Pause de 1 seconde avant d'afficher à nouveau les info
		#sleep 1
	done
	stty sane
}

main $1 $2 $3 $4 $5 $6 $7
stty sane
#clear_screen
##info_proc 2 2
#info_reduite
##print_bar_h "${color_default}" 0 10 30 15

#test_x=$(tput cols)
#test_y=$(tput lines)
#printf "\33[%d;%dH" "$test_x" "$test_y";
