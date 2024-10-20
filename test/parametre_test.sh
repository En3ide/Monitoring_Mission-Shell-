#!/bin/bash

# Vérifie si un fichier a été passé en paramètre
if [ -z "$1" ]; then
    echo "Erreur : Aucun nom de fichier fourni."
    exit 1
fi

# Vérifie si le fichier existe
if [ -f "$1" ]; then
    echo "Oui, le fichier '$1' existe."
else
    echo "Non, le fichier '$1' n'existe pas."
fi

