#!/bin/bash

# Nom du fichier source à compiler
source_file="$1"

# Appeler gcc et capturer la sortie d'erreur
output=$(gcc $source_file -o hapsycode 2>&1)

# Vérifier si la compilation a échoué
if [ $? -ne 0 ]; then
    echo "$output" | while IFS= read -r line; do
        # Filtrer les lignes d'erreur spécifiques
        if [[ $line == *"error:"* ]]; then
            # Extraire et afficher uniquement le message d'erreur
            error_message=$(echo $line | sed -n 's/.*error: \(.*\)/\1/p')
            echo "➥ 💥 COMPILATION ERROR ($error_message)"
        fi
    done
    exit 1
fi
