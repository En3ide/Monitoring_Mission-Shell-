# Projet Shell - Application de Monitoring

---

*Ce projet a été réalisé dans le cadre d'un programme universitaire d'une 3ème année de licence Informatique.*

Il s'agit est un moniteur de système écrit en Bash. Il permet de surveiller en temps réel les ressources du système comme le processeur, la mémoire, les disques, le réseau, et les processus actifs


## Prérequis
- Système d'exploitation **LINUX**
- Ouvrir un terminal dans le repertoire du projet.

## Utilisation 
1. Vous pouvez utiliser la commande  : `./interface.sh`
2. Lancer le processus avec le fichier de configuration : `./interface.sh configfile.txt`

## Fichier de log
Un fichier de log ***logfile.txt*** se créé automatiquement lors du lancement du processus.
La réinitialisation et l'intervalle de temps (en secondes) sont configurables dans le fichier de configuration ***configfile.txt***.

## Fichier de configuration
Le fichier de configuration ***configfile.txt*** permet de définir les couleurs de l'interface, l'intervalle en secondes du temps d'écriture dans les logs (fichier ***logfile.txt***).


