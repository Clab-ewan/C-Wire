#!/bin/bash

# Affichage de l'aide
for arg in "$@"; do
    if [ "$arg" == "-h" ]; then
        echo "Usage: $0 <fichier_csv> <type_station> <type_consommateur> [id_centrale]"
        echo "Description: Ce script permet de traiter des données de consommation énergétique."
        echo "Paramètres:"
        echo "  <fichier_csv>         : Chemin vers le fichier CSV contenant les données."
        echo "  <type_station>        : Type de station ('hva', 'hvb', 'lv')."
        echo "  <type_consommateur>   : Type de consommateur ('comp', 'indiv', 'all')."
        echo "  [id_centrale]         : (Optionnel) Identifiant de la centrale (doit être un nombre)."
        echo "Options:"
        echo "  -h                    : Affiche cette aide et quitte."
        exit 0
    fi
done

# Vérification des arguments passés
check_arguments() {
    if [ $# -lt 3 ]; then # Si le nombre d'arguments est inférieur à 3
        echo "Usage: $0 <fichier_csv> <type_station> <type_consommateur> [id_centrale]"
        exit 1
    fi
    if [ "$2" != "hva" ] && [ "$2" != "hvb" ] && [ "$2" != "lv" ]; then
        echo "Erreur : Le type de station doit être 'hva' ou 'hvb' ou 'lv' ."
        exit 1
    fi
    if [ "$3" != "comp" ] && [ "$3" != "indiv" ] && [ "$3" != "all" ]; then
        echo "Erreur : Le type de consommateur doit être 'comp' ou 'indiv' ou 'all'."
        exit 1
    fi
    if { [ "$2" == "hvb" ] || [ "$2" == "hva" ]; } && { [ "$3" == "all" ] || [ "$3" == "indiv" ]; }; then
        echo "Erreur : Les options suivantes sont interdites : hvb all, hvb indiv, hva all, hva indiv."
        exit 1
    fi
    if ! [[ "$4" =~ ^[0-9]+$ ]] && [ -n "$4" ]; then
        echo "Erreur : L'identifiant de la centrale doit être un nombre."
        exit 1
    fi
}

INPUT_FILE=$1
STATION_TYPE=$2
CONSUMER_TYPE=$3
CENTRAL_ID=${4:-"ALL"}

# Vérification si le fichier CSV existe et n'est pas vide
check_file() {
    if [ ! -f "$INPUT_FILE" ]; then
        echo "Erreur : Le fichier '$INPUT_FILE' n'existe pas."
        exit 1
    elif [ ! -s "$INPUT_FILE" ]; then
        echo "Erreur : Le fichier '$INPUT_FILE' est vide."
        exit 1
    fi
}

# Création des dossiers nécessaires pour le script
create_directories() {
    for directory in "tmp" "tests" "graphs"; do
        if [ ! -d "$directory" ]; then
            mkdir "$directory"
        fi
    done
}

# Vérification de l'exécutable du programme C
executable_verification() {
    if [ ! -f CodeC/program ]; then
        echo "Compilation en cours..."
        make -C CodeC || { echo "Erreur de compilation"; exit 1; }
    fi
}

data_exploration() {
case $a in
    hvb) grep "$0;| cut -d ";" -f1,2,7 ;;
    hva) ;;
    lv) case $b in 
            comp) ;;
            indiv) ;;
            all) ;;
            *) ;;
            esac
            ;;
    *) ;;
esac
}

# Appel des fonctions
check_arguments "$@"
check_file
create_directories
executable_verification
data_exploration
