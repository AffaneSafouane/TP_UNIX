# TP 03 : Shell bash

## Exercice : paramètres

**Script**
```bash
#!/bin/sh

echo "Bonjour vous avez rentré $# paramètres"
echo "Le nom du script est $0"
echo "Le 3e paramètre est $3"
echo "Voici la liste des paramètres : $@"
```

**Résultat**
```bash
./analyse.sh poil 89 palindrome nose
Bonjour vous avez rentré 4 paramètres
Le nom du script est ./analyse.sh
Le 3e paramètre est palindrome
Voici la liste des paramètres : poil 89 palindrome nose
```

## Exercice : vérification du nombre de paramètres

**Script**
```bash
#!/bin/sh

# On vérifie que le nombre de paramètres est uniquement 2 
if [ $# -ne 2 ]; then
  echo "Veuillez entrer exactement 2 paramètres."
  # On quitte en renvoyant une erreur
  exit 1;
fi;
CONCAT="$1$2"
echo "$CONCAT" 
```

**Résultat**
```bash
$ ./concat.sh tulipe
Veuillez entrer exactement 2 paramètres.

$ ./concat.sh tulipe rose
tuliperose

$ ./concat.sh tulipe rose poil
Veuillez entrer exactement 2 paramètres.
```

## Exercice : argument type et droits

**Script**
```bash
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
```

**Résultat**
```bash
$ ./test-fichier.sh /etc
Le fichier /etc est un répertoire
Le fichier /etc est accessible par saf avec les permissions suivantes : lecture exéctutable

$ ./test-fichier.sh /etc/host.conf
Le fichier /etc/host.conf est un fichier
Le fichier /etc/host.conf n\'est pas vide
Le fichier /etc/host.conf est accessible par saf avec les permissions suivantes : lecture
```

## Exercice : Afficher le contenu d’un répertoire

**Script**

```bash
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
```

**Résultat**
```bash 
$ ./listedir.sh /boot
####### fichiers dans /boot/
####### répértoires dans /boot/157c1d809f5e4276a358d030bbb56fc8/
/boot/157c1d809f5e4276a358d030bbb56fc8/limine_history
/boot/BackupSbb.bin
####### répértoires dans /boot/EFI/
/boot/EFI/BOOT
/boot/EFI/Insyde
/boot/EFI/limine
/boot/EFI/Linux
/boot/EFI/Microsoft
####### répértoires dans /boot/grub/
/boot/grub/fonts
/boot/grub/grub.cfg
/boot/grub/grubenv
/boot/grub/locale
/boot/grub/themes
/boot/grub/x86_64-efi
/boot/intel-ucode.img
/boot/limine.conf
/boot/limine.conf.old
####### répértoires dans /boot/loader/
/boot/loader/credentials
/boot/loader/random-seed
####### répértoires dans /boot/System Volume Information/
/boot/System Volume Information/*
```

## Exercice : Lister les utilisateurs

**Script**

```bash
#!/bin/sh

OLD_IFS=$IFS
IFS='
' 
for user in $(cat /etc/passwd); do
    uid=$(echo "$user" | cut -d':' -f 3)
    if [ "$uid" -gt 100 ] 2>/dev/null; then
        echo "$user" | cut -d':' -f 1
    fi
done
IFS=$OLD_IFS
```

Ce script est une astuce classique pour contourner le problème des espaces dans les fichiers texte pour afficher proprement les utilisateurs dont l'UID est supérieur à 100.

### 1. La gestion de l'IFS (le séparateur)

C’est la partie la plus importante du script.

- **`OLD_IFS=$IFS`** : On sauvegarde le séparateur actuel du système. Par défaut, l'IFS (*Internal Field Separator*) contient l'**espace**, la **tabulation** et le **saut de ligne**.

- **`IFS='...'`** : On redéfinit l'IFS pour qu'il ne contienne **que** le saut de ligne.

  > **Pourquoi ?** Pour que la boucle `for` considère chaque ligne de `/etc/passwd` comme un seul bloc, même s'il y a des espaces dans les noms ou les descriptions (comme "Service User"). Sans cela, le `for` couperait la ligne au premier espace trouvé.

### 2. La boucle de lecture

- **`for user in $(cat /etc/passwd); do`** : On parcourt le fichier. Grâce au changement d'IFS juste au-dessus, la variable `$user` contient maintenant une ligne complète du fichier à chaque tour de boucle.

### 3. Extraction et Test

- **`uid=$(echo "$user" | cut -d':' -f 3)`** :
  - On prend la ligne entière (`$user`).
  - On utilise `cut` avec le délimiteur `:` (`-d':'`).
  - On récupère le 3ème champ (`-f 3`), qui correspond à l'UID de l'utilisateur.
- **`if [ "$uid" -gt 100 ] 2>/dev/null; then`** :
  - On compare l'UID pour voir s'il est strictement supérieur à 100 (`-gt`).
  - **`2>/dev/null`** : C'est une sécurité. Si jamais `$uid` contient du texte par erreur (ce qui arrive sur des lignes mal formées), le shell affichera une erreur. Ce petit bout de code envoie l'erreur à la "poubelle" (`/dev/null`) pour garder un affichage propre.

### 4. Affichage et Restauration

- **`echo "$user" | cut -d':' -f 1`** : Si le test est réussi, on reprend la ligne et on extrait cette fois le 1er champ (`-f 1`), qui est le nom d'utilisateur (login).
- **`IFS=$OLD_IFS`** : Une fois la boucle finie, on remet l'IFS comme il était au début. C'est une **bonne pratique** indispensable : si on ne le fais pas, le reste de notre script risquerait de se comporter de manière très bizarre avec les espaces !

**Résultat**

```bash
./listeusers.sh
nobody
systemd-coredump
systemd-network
systemd-oom
systemd-journal-remote
systemd-resolve
systemd-timesync
tss
uuidd
alpm
saf
avahi
git
cups
_talkd
polkitd
rtkit
sddm
nvidia-persistenced
pcscd
mysql
mongodb
```

**Script awk**

```bash
#!/bin/sh
awk -F: '$3 > 100 { print $1 }' /etc/passwd
```

`awk` a été conçu spécifiquement pour traiter des fichiers structurés en colonnes et a une gestion native des espaces. Il traite chaque ligne comme un enregistrement unique. Voici comment il découpe la commande :

- **`-F:`** : C'est le "Field Separator". On dit à `awk` que les colonnes sont séparées par des deux-points (`:`).
- **`$3 > 100`** : C'est la condition. `awk` regarde la 3ème colonne ($3) et vérifie si elle est supérieure à 100.
- **`{ print $1 }`** : C'est l'action. Si la condition est vraie, il affiche le contenu de la 1ère colonne ($1), qui est le nom d'utilisateur.

## Exercice : Mon utilisateur existe-t-il ?

**Script**

```bash
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
```

**Résultat**

```bash
$ ./userexists.sh saf
1000
$ ./userexists.sh 1000
1000
```

## Exercice : Création utilisateur

**Script**

```bash
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
# -c : définit le champ commentaire (GECOS) : on combine Nom, Prénom et Commentaire
# -m : force la création du répertoire personnel
# -d : définit le chemin du home
useradd -u "$UID_RECHERCHE" -g "$GID_VAL" -c "PRENOM $PRENOM, NOM $NOM, $COMM" -m -d "$HOME_DIR" "$LOGIN"

# `$?` contient le code de retour de la dernière commande exécutée
if [ $? -eq 0 ]; then 
  echo "L'utilisateur $LOGIN a été créé avec succès."
  echo "Répertoire personnel : $HOME_DIR"
else 
  echo "Une erreur est survenue lors de la création de l'utilisateur $LOGIN."
  exit 1
fi
```

**Résultat**

```bash
./createuser.sh
--- Nouvel utilisateur ---
Login : goku
Nom : Son
Prénom : Goku
UID : 1000
GID : 100
Commentaires : Sayan
L'utilisateur goku a été créé avec succès.
Répertoire personnel : /home/goku
$ grep "goku" /etc/passwd
goku:x:1000:100:PRENOM Goku, NOM Son, Sayan:/home/goku:/bin/sh
```

## Exercice : lecture au clavier

**more**

**Comment quitter `more` ?** La touche **`q`** (pour *Quit*). Cela ramène immédiatement à l'invite de commande.

**Comment avancer d’une ligne ?** La touche **`Entrée`**. C'est pratique pour descendre doucement dans le texte.

**Comment avancer d’une page ?** La touche **`Espace`**. C'est la méthode la plus rapide pour lire un long fichier.

**Comment remonter d’une page ?** La touche **`b`** (pour *Back*).

**Comment chercher une chaîne de caractères ?** On tape le symbole **`/`** (slash), puis on écris notre mot et appuie sur **`Entrée`**. 

**Passer à l’occurrence suivante ?** Après avoir lancé une recherche avec `/`, on appuie sur la touche **`n`** (pour *Next*) pour aller au prochain endroit où le mot apparaît.

**Script**

```bash
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
```

**Résultat**

```bash
./visutxt.sh /etc/
-------------------------------------
Voulez-vous visualiser le fichier bash.bash_logout ? (o/n)
o
#
# /etc/bash.bash_logout
#
-------------------------------------
Voulez-vous visualiser le fichier bash.bashrc ? (o/n)
```

## Exercice : appréciation

**Script**

```bash
#!/bin/sh

# On lance une boucle infinie
while true; do
    echo -n "Saisir une note (0-20) ou 'q' pour quitter : "
    read NOTE

    # Vérifier si l'utilisateur veut quitter
    if [ "$NOTE" = "q" ]; then
        break
    fi

    # Vérification des tranches de notes
    # On commence par la note la plus haute pour simplifier la logique
    if [ "$NOTE" -ge 16 ] && [ "$NOTE" -le 20 ]; then
        echo "Résultat : très bien"
    elif [ "$NOTE" -ge 14 ] && [ "$NOTE" -lt 16 ]; then
        echo "Résultat : bien"
    elif [ "$NOTE" -ge 12 ] && [ "$NOTE" -lt 14 ]; then
        echo "Résultat : assez bien"
    elif [ "$NOTE" -ge 10 ] && [ "$NOTE" -lt 12 ]; then
        echo "Résultat : moyen"
    elif [ "$NOTE" -lt 10 ] && [ "$NOTE" -ge 0 ]; then
        echo "Résultat : insuffisant"
    else
        echo "Erreur : Veuillez saisir une note valide entre 0 et 20."
    fi
done
```

**Résultat**

```bash
./appreciations.sh
Saisir une note (0-20) ou 'q' pour quitter : 17
Résultat : très bien
Saisir une note (0-20) ou 'q' pour quitter : 15
Résultat : bien
Saisir une note (0-20) ou 'q' pour quitter : 13
Résultat : assez bien
Saisir une note (0-20) ou 'q' pour quitter : 10
Résultat : moyen
Saisir une note (0-20) ou 'q' pour quitter : 5
Résultat : insuffisant
Saisir une note (0-20) ou 'q' pour quitter : q
```

