# Projet Shell - Application de Monitoring

>Ce projet a été réalisé dans le cadre d'un programme universitaire en 3<sup>e</sup> année de licence en informatique.

Il s'agit d'un moniteur de système écrit en *Bash*, qui s'exécute dans la console.  
Il permet de surveiller en temps réel les ressources du système, telles que le processeur (CPU), la carte graphique (GPU), la mémoire (RAM), les disques, le réseau et les processus actifs.

## Prérequis
- Système d'exploitation **Linux**
- Ouvrir un terminal dans le répertoire du projet.

## Utilisation 
1. Utilisez la commande suivante pour lancer l'applicaton : `./main.sh`
2. Pour lancer le processus avec un [fichier de configuration](#fichier-de-configuration) spécifique, utilisez : `./main.sh configfile.txt`

## Fichier de logs
Un fichier de logs `logfile.txt` se met à jour automatiquement. Toutes les données récoltées par le processus y sont écrites.  
La réinitialisation lors du lancement du processus et l'intervalle de temps (en secondes) sont configurables dans le [fichier de configuration](#fichier-de-configuration).

## Fichier de configuration
Le fichier de configuration `configfile.txt` permet de personnaliser certains aspects graphiques et techniques comme les [couleurs](#couleurs-disponibles-) de l'interface ou l'intervalle d'écriture dans le [fichier de logs](#fichier-de-logs).

Il doit respecter la syntaxe suivante : `nom_variable=valeur`, avec une affectation par ligne. Si cette syntaxe n'est pas respectée, le processus ne se lance pas.  
La majorité des variables doivent obligatoirement avec une [couleur](#couleurs-disponibles-) ou un [caractère UNICODE](#caractères-unicode-disponibles-) comme valeur parmi celles et ceux disponibles.

Voici un exemple :
```
bg_color=DARK_BLACK
font_color=DARK_RED
border_color=DARK_BLUE
font_processus_color=BRIGHT_WHITE
```

Veuillez vous référer aux tableaux ci-dessous pour consulter les variables possibles ainsi que leurs valeurs.


####  Variables configurables avec une [couleur](#couleurs-disponibles-) :
| Nom de la variable     | Signification                                       | Valeur par défaut ([couleurs](#couleurs-disponibles-))             |
|------------------------|-----------------------------------------------------|--------------------------------------------------------------------|
| bg_color               | Couleur de fond de l'interface                      | `DARK_BLACK`                                                       |
| font_color             | Couleur de la police principale                     | `DARK_RED`                                                         |
| border_color           | Couleur de la bordure                               | `DARK_BLUE`                                                        |
| font_processus_color   | Couleur de la police pour les processus affichés    | `BRIGHT_WHITE`                                                     |
| full_cpu_bar_color     | Couleur de la barre de progression CPU (pleine)     | `DARK_YELLOW`                                                      |
| full_gpu_bar_color     | Couleur de la barre de progression GPU (pleine)     | `DARK_GREEN`                                                       |
| full_memory_bar_color  | Couleur de la barre de progression mémoire (pleine) | `DARK_MAGENTA`                                                     |
| full_disk_bar_color    | Couleur de la barre de progression disque (pleine)  | `DARK_BLUE`                                                        |
| empty_cpu_bar_color    | Couleur de la barre de progression CPU (vide)       | `BRIGHT_YELLOW`                                                    |
| empty_gpu_bar_color    | Couleur de la barre de progression GPU (vide)       | `BRIGHT_GREEN`                                                     |
| empty_memory_bar_color | Couleur de la barre de progression mémoire (vide)   | `BRIGHT_MAGENTA`                                                   |
| empty_disk_bar_color   | Couleur de la barre de progression disque (vide)    | `BRIGHT_BLUE`                                                      |


####  Variables configurables avec un [caractère UNICODE](#caractères-unicode-disponibles-) :

| Nom de la variable     | Signification                                         | Valeur par défaut ([caractère UNICODE](#caractères-unicode-disponibles-))   |
|------------------------|-------------------------------------------------------|-----------------------------------------------------------------------------|
| border_char            | Caractère représentant les bordures des fenêtres      | `unicode_full_block`                                                        |
| full_bar_char          | Caractère représentant la barre de progression pleine | `unicode_dark_shade`                                                        |
| empty_bar_char         | Caractère représentant la barre de progression vide   | `unicode_light_shade`                                                       |


####  Autres variables configurables :

| Nom de la variable  | Valeur            | Signification                                                    | Valeur par défaut |
|---------------------|------------------ |------------------------------------------------------------------|-------------------|
| minimum_lines_width | `number`          | Largeur minimale en lignes                                       | `30`              |
| minimum_cols_height | `number`          | Hauteur minimale en colonnes                                     | `70`              |
| update_log_time     | `number`          | Fréquence de mise à jour du fichier de logs en secondes          | `60`              |
| overwrite_log       | `true` ou `false` | Indique si le fichier de logs ***logfile.txt*** doit être écrasé | `true`            |

---

#### Couleurs disponibles :

| Nom de la couleur        | Code hexadécimal |  Signification            |
|--------------------------|------------------|---------------------------|
| DARK_BLACK               | `#000000`        | Noir foncé                |
| DARK_RED                 | `#800000`        | Rouge foncé               |
| DARK_GREEN               | `#008000`        | Vert foncé                |
| DARK_YELLOW              | `#808000`        | Jaune foncé               |
| DARK_BLUE                | `#000080`        | Bleu foncé                |
| DARK_MAGENTA             | `#800080`        | Magenta foncé             |
| DARK_CYAN                | `#008080`        | Cyan foncé                |
| DARK_WHITE               | `#C0C0C0`        | Blanc/gris foncé          |
| BRIGHT_BLACK             | `#808080`        | Noir clair (gris foncé)   |
| BRIGHT_RED               | `#FF0000`        | Rouge clair               |
| BRIGHT_GREEN             | `#00FF00`        | Vert clair                |
| BRIGHT_YELLOW            | `#FFFF00`        | Jaune clair               |
| BRIGHT_BLUE              | `#0000FF`        | Bleu clair                |
| BRIGHT_MAGENTA           | `#FF00FF`        | Magenta clair             |
| BRIGHT_CYAN              | `#00FFFF`        | Cyan clair                |
| BRIGHT_WHITE             | `#FFFFFF`        | Blanc/gris clair          |
| BRIGHT_BLACK_BIS         | `#555555`        | Noir clair bis            |
| BRIGHT_RED_BIS           | `#FF5555`        | Rouge clair bis           |
| BRIGHT_GREEN_BIS         | `#55FF55`        | Vert clair bis            |
| BRIGHT_YELLOW_BIS        | `#FFFF55`        | Jaune clair bis           |
| BRIGHT_BLUE_BIS          | `#5555FF`        | Bleu clair bis            |
| BRIGHT_MAGENTA_BIS       | `#FF55FF`        | Magenta clair bis         |
| BRIGHT_CYAN_BIS          | `#55FFFF`        | Cyan clair bis            |
| BRIGHT_WHITE_BIS         | `#E5E5E5`        | Blanc/gris clair bis      |
| DARK_RED_BIS             | `#800000`        | Fond rouge foncé          |
| DARK_GREEN_BIS           | `#008000`        | Fond vert foncé           |
| DARK_YELLOW_BIS          | `#808000`        | Fond jaune foncé          |
| DARK_BLUE_BIS            | `#000080`        | Fond bleu foncé           |
| DARK_MAGENTA_BIS         | `#800080`        | Fond magenta foncé        |
| DARK_CYAN_BIS            | `#008080`        | Fond cyan foncé           |
| DARK_WHITE_BIS           | `#C0C0C0`        | Fond blanc/gris foncé     |


#### Caractères UNICODE disponibles :

| Nom du caractère           | Code Unicode | Signification       | Caractère |
|----------------------------|--------------|---------------------|-----------|
| unicode_full_block         | `\u2588`     | Bloc complet        | █         |
| unicode_upper_half_block   | `\u2580`     | Demi-bloc supérieur | ▀         |
| unicode_lower_half_block   | `\u2584`     | Demi-bloc inférieur | ▄         |
| unicode_left_half_block    | `\u258C`     | Demi-bloc gauche    | ▌         |
| unicode_right_half_block   | `\u2590`     | Demi-bloc droit     | ▐         |
| unicode_light_shade        | `\u2591`     | Ombrage léger       | ░         |
| unicode_medium_shade       | `\u2592`     | Ombrage moyen       | ▒         |
| unicode_dark_shade         | `\u2593`     | Ombrage foncé       | ▓         |
| unicode_white_square       | `\u25A1`     | Carré blanc         | ▢         |
| unicode_black_circle       | `\u25CF`     | Cercle noir         | ●         |
| unicode_white_circle       | `\u25CB`     | Cercle blanc        | ○         |
| unicode_black_diamond      | `\u25C6`     | Losange noir        | ◆         |
| unicode_white_diamond      | `\u25C7`     | Losange blanc       | ◇         |
| unicode_black_star         | `\u2605`     | Étoile noire        | ★         |
| unicode_white_star         | `\u2606`     | Étoile blanche      | ☆         |
