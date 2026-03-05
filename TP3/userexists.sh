#!/bin/sh 

# On vérifie qu'un argument a été passé
if [ $# -ne 1 ]; then
  echo "Vueillez entrer uniquement le login ou l'UID d'un utilisateur"
  exit 1;
fi;

# On passe l'argument du script à awk
# On utilise awk pour chercher dans le champ 1 (login) OU le champ 3 (UID)
# Si trouvé, on affiche le champ 3 (UID)
awk -v arg=$1 -F: '$3 == arg || $1 == arg { print $3 }' /etc/passwd
