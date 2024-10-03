#!/bin/sh
export LANG=en_US.UTF-8
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
#if [ "$cols" -lt 50 ]; then 
#if [ "$lines" -lt 30 ]

clear_screen() {
	cols=$(tput cols)
	lines=$(tput lines)
	for i in $(seq 1 "$cols"); do
		for j in $(seq 1 "$lines"); do
			if [ "$i" -eq 1 ]; then
				printf "\33[%d;%dH" "$j" "$i";
				printf "%b" "$blue" "|" "$reset";
			elif [ "$j" -eq 1 ]; then
				printf "\33[%d;%dH" "$j" "$i";
				printf "%b" "$blue" "_" "$reset";
			elif [ "$j" -eq "$lines" ]; then
				printf "\33[%d;%dH" "$j" "$i";
				printf "%b" "$blue" "_" "$reset";
			elif [ "$i" -eq "$cols" ]; then
				printf "\33[%d;%dH" "$j" "$i";
				printf "%b" "$blue" "|" "$reset";
			else
				printf "\33[%d;%dH" "$j" "$i";
				printf "%b" " ";
			fi
		done
	done
}

info_proc() {
	# info 1
	printf "\33[%d;%dH" "$x" "$y";
	printf "%b" "$blue" "salut les boys" "$reset";
	# info 2
	x_plus_2=$((x + 3))
	printf "\33[%d;%dH" "$x_plus_2" "$y";
	printf "%b" "$reset" "$carre_plein" "$reset";
	# info 3
}

info_reduite() {
	#
	x=2
	y=2
	printf "\33[%d;%dH" "$x" "$y";
	printf "%b" "$blue" "Memory : " "$reset";
	print_bar_h "$blue" 3 $((cols - 3)) 50 25
}

print_bar_h() {
	# $1 = couleur
	# $2 = cols debut de barre
	# $3 = cols fin de barre
	# $4 = max var
	# $5 = current var
	res="$1"
	percent=$(( $5 * 100 / $4 ))
	for i in $(seq "$2" "$(( $3 - 3 ))"); do
		if [ $(( i * 100 / ( $3 - 4 ) )) -le "$percent" ]; then
			res="$res" "$carre_plein";
		else
			res="$res" "$reset" "$carre_plein";
		fi
	done
	printf "\33[%d;%dH" "$2" "$4";
	printf "%b" "$res" "$reset" "$percent" "%";
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
info_reduite

test_x=$(tput cols)
test_y=$(tput lines)
#printf "\33[%d;%dH" "$test_x" "$test_y";
