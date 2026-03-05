#!/bin/sh 

# On vérifie que l'utilisateur est root 
if [ "$(echo $USER)" != "root" ]; then 
  echo "Vous devez être root pour exécuter ce script."
  exit 1
fi

# Poser les questions 
echo "--- Nouvel utilisateur ---"
read -p "Login : " LOGIN
read -p "Nom : " NOM
read -p "Prénom : " PRENOM
read -p "UID : " UID_RECHERCHE
read -p "GID : " GID_VAL
read -p "Commentaires : " COMM

# On vérifie si l'utilisateur ou l'UID existe déjà 
# On réutilise le script de vérification 
EXISTE=$(./userexists.sh "$LOGIN")
EXISTE_UID=$(./userexists.sh "$UID_RECHERCHE")

if [ -n "$EXISTE" ] || [ -n "$EXISTE_UID" ]; then 
  echo "Erreur : L'utilisateur '$LOGIN' ou l'UID '$UID_RECHERCHE' existe déjà."
  exit 1
fi

# Vérifier si le répertoire home existe déjà
HOME_DIR="/home/$LOGIN"
if [ -d "$HOME_DIR" ]; then
  echo "Le répertoire $HOME_DIR existe déjà."
  exit 1
fi

# Crétion de l'utilisateur 
# -u : définit l'UID
# -g : définit le groupe principal (GID)
# -c : définit le champ commentaire (GECOS) : on combine Nom, Prénom et Comm
# -m : force la création du répertoire personnel
# -d : définit le chemin du home
useradd -u "$UID_RECHERCHE" -g "$GID_VAL" -c "PRENOM $PRENOM, NOM $NOM, $COMM" -m -d "$HOME_DIR" "$LOGIN"

# $? contient le code de retour de la dernière commande exécutée
if [ $? -eq 0 ]; then 
  echo "L'utilisateur $LOGIN a été créé avec succès."
  echo "Répertoire personnel : $HOME_DIR"
else 
  echo "Une erreur est survenue lors de la création de l'utilisateur $LOGIN."
  exit 1
fi
