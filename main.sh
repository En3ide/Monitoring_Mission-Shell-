#!/bin/bash
. ./interface.sh

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