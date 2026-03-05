#!/bin/sh 

if [ $# -ne 1 ]; then
  echo "Veuillez entrer uninquement 1 répertoire"
  exit 1
fi 

DIR="$1"

# Verifier si c'est bien un répertoire 
if [ ! -d "$DIR" ]; then 
  echo "'$DIR' n'est pas un répertoire"
  exit 1
fi 

# Boucle sur tous les éléments du répertoire 
for fichier in "$DIR"/*; do
  # On vérifie que c'est un fichier (pas un dossier)
  if [ -f "$fichier" ]; then 
    # On utlise 'file' pour détecter si c'est du texte
    # On cherche le mot "text" dans le résultat de 'file'
    if file "$fichier" | grep -q "text"; then 
      # Intercation utilisateur avec 'read'
      echo "-------------------------------------"
      echo "Voulez-vous visualiser le fichier $(basename "$fichier") ? (o/n)"
      read response

      # On vérifie que la réponse commence par "o" ou "O"
      if [ "$response" = "o" ] || [ "$response" = "O" ]; then 
        more "$fichier"
      fi 
    fi
  fi 
done

echo "Examen terminé."
