#!/bin/sh 

if [ $# -ne 1 ]; then
  echo "Vueillez entrer exactement 1 paramètre."
  exit 1;
fi;

# On vérifie que le fichier en paramètre existe 
if [ ! -e "$1" ]; then 
  echo "Le fichier $1 n'existe pas"
  exit 1;
fi;

if [ -f "$1" ]; then 
  echo "$1 est un fichier"
  if [ -S "$1" ]; then 
    echo "Le fichier $1 n'est pas vide"
  else 
    echo "Le fichier $1 est vide"
  fi;
elif [ -d "$1" ]; then 
  echo "$1 est un répertoire"
elif [ -p "$1" ]; then 
  echo "$1 est une représentation interne d’un dispositif de communication"
elif [ -c "$1" ]; then 
  echo "$1 est un pseudo-fichier du type accès caractère par caractère"
elif [ -b "$1" ]; then 
  echo "$1 est un pseudo-fichier du type accès par bloc"
elif [ -L "$1" ]; then 
  echo "$1 est un lien symbolique"
else 
  echo "Le type du paramètre n'est pas reconnu"
  exit 1;
fi;

# On vérifie les permissions de l'utilisateur courant et on les concaténe
PERM=""
if [ -r "$1" ]; then 
  PERM="$PERM lecture"
fi;

if [ -w "$1" ]; then 
  PERM="$PERM écriture"
fi;

if [ -x "$1" ]; then 
  PERM="$PERM exéctutable"
fi;

# Récupérer l'utilisateur courant
USER=$(whoami)

echo "Le fichier $1 est accessible par $USER avec les permissions suivantes :$PERM"
