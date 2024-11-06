#!/bin/bash

# Créer le fichier de log s'il existe pas déjà
create_logfile() { # Tim Lamour
   # On rewrite par défaut le logfile
   # Si il y a un argument et qu'il vaut "true", on supprime le fichier log s'il existe
   if [[ "$#" -eq 0 || "$1" == "true" ]]; then
      if [[ -f "logfile.txt" ]]; then
         rm "logfile.txt"
      fi
      # On le crééer si un fichier log n'existe pas
      touch "logfile.txt"
      chmod 644 "logfile.txt"
   fi

}

# Ecrire ce qui donné en paramètre dans le log file
write_in_logfile() { # Tim Lamour
   local deco="-----------------------------"
   local content="$1"
   echo -e "$deco $(date '+%Y-%m-%d %H:%M:%S') $deco\n$content\n" >> logfile.txt
}

# Calculer le pourcentage entre 2 valeurs
calculate_percent() { # Jamel Bailleul
   #Gère les valeurs à virgules (on choisit de les retirer)
   local var1 var2
   var1=$(echo "$1" | tr -cd '0-9' | tr -d '.')
   var2=$(echo "$2" | tr -cd '0-9' | tr -d '.')

   if [ "$var2" -eq 0 ]; then
      echo 0
   else
      echo $(($var1 * 99 / $var2))
   fi
   
}
