# Projet Shell - Application de Monitoring
---
>Ce projet a été réalisé dans le cadre d'un programme universitaire d'une 3<sup>ème</sup> année de licence Informatique.

Il s'agit est un moniteur de système écrit en *Bash*. Il permet de surveiller en temps réel les ressources du système comme le processeur (CPU), la carte graphique (GPU), la mémoire, les disques, le réseau, et les processus actifs

## Prérequis
- Système d'exploitation **LINUX**
- Ouvrir un terminal dans le repertoire du projet.

## Utilisation 
1. Vous pouvez utiliser la commande  : `./interface.sh`
2. Lancer le processus avec le [fichier de configuration](#fichier-de-configuration) : `./interface.sh configfile.txt`

## Fichier de log
Un fichier de log ***logfile.txt*** se met à jour automatiquement, il y est écrit toutes les données récoltés par le processus.
La réinitialisation lors du lancement du processus et l'intervalle de temps (en secondes) sont configurables dans le [fichier de configuration ***configfile.txt***](#fichier-de-configuration).

## Fichier de configuration
Le fichier de configuration ***configfile.txt*** permet de définir les couleurs de l'interface, l'intervalle en secondes du temps d'écriture et la réinitialisation du fichier des logs (fichier ***logfile.txt***).

**Voici les _<ins>couleurs configurables</ins>_** :

| Nom de variable          | Couleur        |
|--------------------------|----------------|
| FONT_BLACK               | `#0A0A0A`      |
| FONT_RED                 | `#B22222`      |
| FONT_GREEN               | `#228B22`      |
| FONT_YELLOW              | `#B8860B`      |
| FONT_BLUE                | `#4682B4`      |
| FONT_MAGENTA             | `#8B008B`      |
| FONT_CYAN                | `#20B2AA`      |
| FONT_WHITE               | `#D3D3D3`      |
| FONT_BRIGHT_BLACK        | `#4B4B4B`      |
| FONT_BRIGHT_RED          | `#FF6347`      |
| FONT_BRIGHT_GREEN        | `#32CD32`      |
| FONT_BRIGHT_YELLOW       | `#FFD700`      |
| FONT_BRIGHT_BLUE         | `#1E90FF`      |
| FONT_BRIGHT_MAGENTA      | `#FF00FF`      |
| FONT_BRIGHT_CYAN         | `#00CED1`      |
| FONT_BRIGHT_WHITE        | `#FFFFFF`      |
| BG_BLACK                 | `#141414`      |
| BG_RED                   | `#8B0000`      |
| BG_GREEN                 | `#006400`      |
| BG_YELLOW                | `#8B8B00`      |
| BG_BLUE                  | `#00008B`      |
| BG_MAGENTA               | `#8B008B`      |
| BG_CYAN                  | `#008B8B`      |
| BG_WHITE                 | `#C0C0C0`      |
| BG_BRIGHT_BLACK          | `#2F4F4F`      |
| BG_BRIGHT_RED            | `#FF4500`      |
| BG_BRIGHT_GREEN          | `#7FFF00`      |
| BG_BRIGHT_YELLOW         | `#FFD700`      |
| BG_BRIGHT_BLUE           | `#4169E1`      |
| BG_BRIGHT_MAGENTA        | `#DA70D6`      |
| BG_BRIGHT_CYAN           | `#40E0D0`      |
| BG_BRIGHT_WHITE          | `#F8F8FF`      |



