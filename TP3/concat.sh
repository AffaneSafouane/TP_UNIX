#!/bin/sh

# On vérifie que le nombre de paramètres est uniquement 2 
if [ $# -ne 2 ]; then
  echo "Veuillez entrer exactement 2 paramètres."
  # On quitte en renvoyant une erreur
  exit 1;
fi;
CONCAT="$1$2"
echo "$CONCAT"
