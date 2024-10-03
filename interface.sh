#!/bin/sh
clear
#pour les couleur tu peux aussi utiliser "\033[38;5<code couleurs>m" code en 256

red="\033[31m" #couleur caractères
fred="\033[41m" #couleur de fond
green="\033[32m"
yellow="\033[33m"
blue="\033[34m"
reset="\033[0m"

carre_plein="\u2588"
carre_vide="\u25A1"
#if (( cols < 50 )); then 
#if (( lines < 30 ))

clear_screen() {
	cols=$(tput cols)
	lines=$(tput lines)
	for ((i=1;i<=$cols;i++)); do
		for ((j=1;j<=$lines;j++)); do
			if (( i == 1 )); then
				printf "\33[%d;%dH" "$j" "$i";
				echo -en "${blue}|${reset}";
			elif (( j == 1 )); then
				printf "\33[%d;%dH" "$j" "$i";
				echo -en "${blue}_${reset}";
			elif (( j == lines )); then
				printf "\33[%d;%dH" "$j" "$i";
				echo -en "${blue}_${reset}";
			elif (( i == cols)); then
				printf "\33[%d;%dH" "$j" "$i";
				echo -en "${blue}|${reset}";
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
	echo -en "${blue}salut les boys${reset}";
	# info 2
	local x_plus_2=$((x + 3))
	printf "\33[%d;%dH" "$x_plus_2" "$y";
	echo -en "${reset}${carre_plein}${reset}";
	# info 3
}

info_reduite() {
	#
	x=2
	y=2
	printf "\33[%d;%dH" "$x" "$y";
	echo -en "${blue}Memory : ${reset}";
	print_bar_h ${blue} 3 $((cols - 3)) 50 25
}

print_bar_h() {
	# $1 = couleur
	# $2 = cols debut de barre
	# $3 = cols fin de barre
	# $4 = max var
	# $5 = current var
	local res=($1)
	percent=$(( $5 * 100 / $4 ))
	for((i=$2;i<=$3 - 3;i++)); do
		if (( ($i * 100) / ($3 - 4) <= percent )); then
			res+="${carre_plein}";
		else
			res+="${reset}${carre_plein}";
		fi
	done
	printf "\33[%d;%dH" "$2" "$4";
	echo -en "$res${reset} $percent%";
}

main() {
    stty -icanon -echo
    trap "stty sane; exit" INT TERM
	while true; do
		clear_screen
		info_proc
		
	done
}

clear_screen
##info_proc 2 2
info_reduite
##print_bar_h "${blue}" 0 10 30 15

test_x=$(tput cols)
test_y=$(tput lines)
printf "\33[%d;%dH" "$test_x" "$test_y";