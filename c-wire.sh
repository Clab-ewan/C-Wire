#!/bin/bash

###########################################################################################                                                                                         #
#             ______      ____      ____  _____  _______     ________                     #
#           .' ___  |    |_  _|    |_  _||_   _||_   __ \   |_   __  |                    #
#          / .'   \_|______\ \  /\  / /    | |    | |__) |    | |_ \_|                    #
#          | |      |______|\ \/  \/ /     | |    |  __ /     |  _| _                     #
#          \ `.___.'\        \  /\  /     _| |_  _| |  \ \_  _| |__/ |                    #
#           `.____ .'         \/  \/     |_____||____| |___||________|                    # 
#                                                                                         #
###########################################################################################
#                                                                                         #
# Ce script permet de filtrer les données d'un fichier CSV en fonction du type de station #
# spécifié par l'utilisateur, d'exécuter le programme C avec les données filtrées et de   #
# sauvegarder les résultats dans un fichier temporaire.                                   #
#                                                                                         #
# Usage: ./c-wire.sh <fichier_csv> <type_station> <type_consommateur> [id_centrale]       #
#                                                                                         #
# Arguments:                                                                              #
#   - fichier_csv: fichier CSV contenant les données à traiter                            #
#   - type_station: type de station à filtrer (hvb, hva, lv)                              #
#   - type_consommateur: type de consommateur à traiter (comp, indiv)                     #
#   - id_centrale: identifiant de la centrale à traiter (optionnel)                       #
#                                                                                         #
# Exemple: ./c-wire.sh input/c-wire_v00.csv "hva" "comp"                                  #
#                                                                                         #
# cela représente le traitement des données du fichier data.csv pour les stations HV-B    #
# consommant de l'électricité et connectées à la centrale 1.                              #    
#                                                                                         #
###########################################################################################

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

# Vérification de l'existance des logiciels pour la partie graphique (Gnuplot).
check_gnuplot(){
logiciels=("gnuplot" "convert")

for logiciel in "${logiciels[@]}"
do
    if command -v "$logiciel" &> /dev/null 
    then
        echo "Les logiciels nécessaires sont installés sur votre système."
    else
        echo "les logiciels nécessaires ne sont pas installés sur votre système. Installation en cours..."
        # Installation.
        sudo apt-get update
        sudo apt-get install gnuplot imagemagick

        # Vérification de l'installation.
        if [ $? -eq 0 ]; then
            echo "Les logiciels ont été installés avec succès."
        else
            echo "Erreur lors de l'installation des logiciels."
        fi
    fi
done
}



# Vérification des arguments passés
check_arguments() {
    if [ $# -lt 3 ]; then # Si le nombre d'arguments est inférieur à 3
        echo "Usage: $0 <fichier_csv> <type_station> <type_consommateur> [id_centrale]"
        echo "Time : 0.0sec"
        exit 1
    fi
    if [ "$2" != "hva" ] && [ "$2" != "hvb" ] && [ "$2" != "lv" ]; then
        echo "Erreur : Le type de station doit être 'hva' ou 'hvb' ou 'lv' ."
        echo "Time : 0.0sec"
        exit 1
    fi
    if [ "$3" != "comp" ] && [ "$3" != "indiv" ] && [ "$3" != "all" ]; then
        echo "Erreur : Le type de consommateur doit être 'comp' ou 'indiv' ou 'all'."
        echo "Time : 0.0sec"
        exit 1
    fi
    if { [ "$2" == "hvb" ] || [ "$2" == "hva" ]; } && { [ "$3" == "all" ] || [ "$3" == "indiv" ]; }; then
        echo "Erreur : Les options suivantes sont interdites : hvb all, hvb indiv, hva all, hva indiv."
        echo "Time : 0.0sec"
        exit 1
    fi
    if ! [[ "$4" =~ ^[0-9]+$ ]] && [ -n "$4" ]; then
        echo "Erreur : L'identifiant de la centrale doit être un nombre."
        echo "Time : 0.0sec"
        exit 1
    fi
}

INPUT_FILE=$1
STATION_TYPE=$2
CONSUMER_TYPE=$3
CENTRAL_ID=${4:-"[^-]+"}

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

# Création des dossiers nécessaires pour le script et suppresion
check_directories() {
    rm -rf "./tmp/"
    for directory in "tmp" "tests" "graphs" "codeC/progO"; do
        if [ ! -d "$directory" ]; then
            mkdir "$directory"
        fi
    done
}

# Vérification de l'exécutable du programme C non veifié a refaire
executable_verification() {
    if [ ! -f ./CodeC/program ]; then
        echo "Compilation en cours..."
        make -C CodeC || { echo "Erreur de compilation"; exit 1; }
    fi
}

# PowerPlant;hvb;hva;LV;Company;Individual;Capacity;Load
# [ "$a" = "$b" ] compare character strings

data_exploration() {
case "$STATION_TYPE" in
    'hvb')  grep -E "^$CENTRAL_ID;[^-]+;-;-;-;-;[^-]+;-$" "$INPUT_FILE" | cut -d ";" -f2,7 > "./tmp/hvb_prod.csv" &&
            grep -E "^$CENTRAL_ID;[^-]+;-;-;[^-]+;-;-;[^-]+$" "$INPUT_FILE" | cut -d ";" -f2,5,8 > "./tmp/hvb_comp.csv"
    ;;
    'hva') grep -E "^$CENTRAL_ID;[^-]+;[^-]+;-;-;-;[^-]+;-$" "$INPUT_FILE" | cut -d ";" -f3,7 > "./tmp/hva_prod.csv" &&
            grep -E "^$CENTRAL_ID;-;[^-]+;-;[^-]+;-;-;[^-]+$" "$INPUT_FILE" | cut -d ";" -f3,5,8 > "./tmp/hva_comp.csv"
    ;;
    'lv') case "$CONSUMER_TYPE" in 
            'comp') grep -E "$CENTRAL_ID;-;[^-]+;[^-]+;-;-;[^-]+;-$" "$INPUT_FILE" | cut -d ";" -f4,7 > "./tmp/lv_prod.csv" &&
                    grep -E "$CENTRAL_ID;-;-;[^-]+;[^-]+;-;-;[^-]+$" "$INPUT_FILE" | cut -d ";" -f4,5,8 > "./tmp/lv_comp.csv"
            ;;
            'indiv') grep -E "$CENTRAL_ID;-;[^-]+;[^-]+;-;-;[^-]+;-$" "$INPUT_FILE" | cut -d ";" -f4,7 > "./tmp/lv_prod.csv" &&
                    grep -E "$CENTRAL_ID;-;-;[^-]+;-;[^-]+;-;[^-]+$" "$INPUT_FILE" | cut -d ";" -f4,6,8 > "./tmp/lv_indiv.csv"
            ;;
            'all') grep -E "$CENTRAL_ID;-;[^-]+;[^-]+;-;-;[^-]+;-$" "$INPUT_FILE" | cut -d ";" -f4,7 > "./tmp/lv_prod.csv" &&
            grep -E "$CENTRAL_ID;-;-;[^-]+;[^-]+;-;-;[^-]+$" "$INPUT_FILE" | cut -d ";" -f4,5,8 >> "./tmp/lv_all.csv" &&
            grep -E "$CENTRAL_ID;-;-;[^-]+;-;[^-]+;-;[^-]+$" "$INPUT_FILE" | cut -d ";" -f4,6,8 >> "./tmp/lv_all.csv"
            ;;
            *) echo "Erreur d'argument lv"
                exit 1
            ;;
        esac
    ;;
    *) echo "Erreur d'argument"
        exit 1
    ;;
esac
}



execute_program(){
    ./CodeC/program < ./tmp/${STATION_TYPE}_prod.csv > ./tmp/${STATION_TYPE}_output.csv
    cat ./tmp/${STATION_TYPE}_output.csv | ./CodeC/program
}

# Appel des fonctions
check_arguments "$@"
check_gnuplot
check_file
check_directories
# executable_verification
#execute_program
data_exploration
