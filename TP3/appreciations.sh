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
