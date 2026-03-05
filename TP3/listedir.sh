#!/bin/sh 

if [ $# -ne 1 ]; then
  echo "Veuillez entrer exactement 1 paramètre"
  exit 1;
fi;

if [ ! -e "$1" ]; then
  echo "$1 n'existe pas"
  exit 1;
fi;

# On vérifie que le paramètre est un répertoire
if [ ! -d "$1" ]; then 
  echo "Veuillez entrer un répertoir en paramètre"
  exit 1;
fi;

echo "####### fichiers dans $1/"
# On parcours tous les fichiers du répertoire
for item in "$1"/*; do
    # Si c'est un fichier on l'affiche
    if [ -f "$item" ]; then
        echo "$item"
    fi
    # si c'est un répertoire on le parcourt et on affiche son contenu
    if [ -d "$item" ]; then 
      echo "####### répértoires dans $item/"
      for sub_item in "$item"/*; do
        echo "$sub_item"
      done
    fi;
done
