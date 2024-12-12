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
# Exemple: ./c-wire.sh input/c-wire_v00.csv hva comp                                      #
#                                                                                         #
# cela représente le traitement des données du fichier data.csv pour les stations HV-B    #
# consommant de l'électricité et connectées à la centrale 1.                              #    
#                                                                                         #
###########################################################################################

#--------------------------------------------------------------------------------------------------------------#

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

#--------------------------------------------------------------------------------------------------------------#

# Vérification de l'existance des logiciels pour la partie graphique (Gnuplot).
check_gnuplot(){
    if command -v gnuplot &> /dev/null 
    then
        echo "Gnuplot est installé sur votre système."
    else
        echo "Gnuplot n'est pas installé sur votre système."
        # Installation.
        echo "Voulez-vous installer Gnuplot ? (y/n)"
        read -r reponse
        if [ "$reponse" == "y" ]; then
            echo "Installation de Gnuplot..."
            sudo apt-get update
            sudo apt-get install gnuplot
        fi
        if [ "$reponse" == "n" ]; then
            echo "Gnuplot n'est pas installé. nous ne pouvons pas continuer."
            exit 1
        fi
        # Vérification de l'installation.
        if [ $? -eq 0 ]; then
            echo "Gnuplot a été installé avec succès."
        else
            echo "Erreur lors de l'installation de Gnuplot."
            exit 1
        fi
    fi
}

#--------------------------------------------------------------------------------------------------------------#

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
    if ! [[ "$4" =~ ^[1-5]+$ ]] && [ -n "$4" ]; then
        echo "Erreur : L'identifiant de la centrale doit être un nombre."
        echo "Time : 0.0sec"
        exit 1
    fi
    echo "Arguments valides."
}

#--------------------------------------------------------------------------------------------------------------#

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

#--------------------------------------------------------------------------------------------------------------#

# Création des dossiers nécessaires pour le script et suppresion
check_directories() {
    rm -rf "./tmp/"
    for directory in "tmp" "tests" "graphs" "codeC/progO"; do
        if [ ! -d "$directory" ]; then
            mkdir "$directory"
        fi
    done
    echo "Dossiers tmp, tests, graphs, codeC/progO créés."
}

#--------------------------------------------------------------------------------------------------------------#

# Vérification de l'exécutable du programme C et compilation si nécessaire
executable_verification() {
    if [ ! -f ./CodeC/progO/exec ]; then
        echo "Compilation en cours..."
        make -C codeC > /dev/null 2>&1 || { echo "Erreur de compilation"; exit 1; }
    fi
    echo "Programme C compilé sans erreurs."
}

# PowerPlant;hvb;hva;LV;Company;Individual;Capacity;Load
# [ "$a" = "$b" ] compare character strings

#--------------------------------------------------------------------------------------------------------------#

data_exploration() {
case "$STATION_TYPE" in
    'hvb')  grep -E "^$CENTRAL_ID;[^-]+;-;-;-;-;[^-]+;-$" "$INPUT_FILE" | cut -d ";" -f2,7,8 | sed 's/-/0/g' > "./tmp/hvb_comp_input.csv" &&
            grep -E "^$CENTRAL_ID;[^-]+;-;-;[^-]+;-;-;[^-]+$" "$INPUT_FILE" | cut -d ";" -f2,7,8 | sed 's/-/0/g' >> "./tmp/hvb_comp_input.csv"
    ;;
    'hva') grep -E "^$CENTRAL_ID;[^-]+;[^-]+;-;-;-;[^-]+;-$" "$INPUT_FILE" | cut -d ";" -f3,7,8 | sed 's/-/0/g' > "./tmp/hva_comp_input.csv" &&
            grep -E "^$CENTRAL_ID;-;[^-]+;-;[^-]+;-;-;[^-]+$" "$INPUT_FILE" | cut -d ";" -f3,7,8 | sed 's/-/0/g' >> "./tmp/hva_comp_input.csv"
    ;;
    'lv') case "$CONSUMER_TYPE" in 
            'comp') grep -E "$CENTRAL_ID;-;[^-]+;[^-]+;-;-;[^-]+;-$" "$INPUT_FILE" | cut -d ";" -f4,7,8 | sed 's/-/0/g' > "./tmp/lv_comp_input.csv" &&
                    grep -E "$CENTRAL_ID;-;-;[^-]+;[^-]+;-;-;[^-]+$" "$INPUT_FILE" | cut -d ";" -f4,7,8 | sed 's/-/0/g' >> "./tmp/lv_comp_input.csv"
            ;;
            'indiv') grep -E "$CENTRAL_ID;-;[^-]+;[^-]+;-;-;[^-]+;-$" "$INPUT_FILE" | cut -d ";" -f4,7,8 | sed 's/-/0/g' > "./tmp/lv_indiv_input.csv" &&
                    grep -E "$CENTRAL_ID;-;-;[^-]+;-;[^-]+;-;[^-]+$" "$INPUT_FILE" | cut -d ";" -f4,7,8 | sed 's/-/0/g' >> "./tmp/lv_indiv_input.csv"
            ;;
            'all') grep -E "$CENTRAL_ID;-;[^-]+;[^-]+;-;-;[^-]+;-$" "$INPUT_FILE" | cut -d ";" -f4,7,8 | sed 's/-/0/g' > "./tmp/lv_all_input.csv" &&
            grep -E "$CENTRAL_ID;-;-;[^-]+;[^-]+;-;-;[^-]+$" "$INPUT_FILE" | cut -d ";" -f4,7,8 | sed 's/-/0/g' >> "./tmp/lv_all_input.csv" &&
            grep -E "$CENTRAL_ID;-;-;[^-]+;-;[^-]+;-;[^-]+$" "$INPUT_FILE" | cut -d ";" -f4,7,8 | sed 's/-/0/g' >> "./tmp/lv_all_input.csv"

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
echo "Exploitation des données terminée et tri des données avec succès."
}

# sort -t ":" -k2hr >

#--------------------------------------------------------------------------------------------------------------#

execute_program(){
    if [ ${CENTRAL_ID} = "[^-]+" ]; then
    (./codeC/progO/exec < ./tmp/${STATION_TYPE}_${CONSUMER_TYPE}_input.csv) > ./tmp/${STATION_TYPE}_${CONSUMER_TYPE}.csv
    else
    (./codeC/progO/exec < ./tmp/${STATION_TYPE}_${CONSUMER_TYPE}_input.csv) > ./tmp/${STATION_TYPE}_${CONSUMER_TYPE}_${CENTRAL_ID}.csv
    fi
    echo "Programme C exécuté avec succès."
}

#--------------------------------------------------------------------------------------------------------------#

create_lv_all_graphs() {
    if [ -s "tmp/lv_all_minmax.csv" ]; then
        input_file="tmp/lv_all_minmax.csv"
    else
        echo "Error: file isn't corresponding"
        exit 1
    fi

    # Extract the top 10 most loaded and 10 least loaded stations, excluding the first line (header)
    top_10=$(tail -n +2 "$input_file" | sort -t ";" -k3 -nr | head -n 10)
    bottom_10=$(tail -n +2 "$input_file" | sort -t ";" -k3 -n | head -n 10)

    # Create graphs using gnuplot
    gnuplot -e "
    set terminal png size 800,600;
    set output 'graphs/top_10_lv.png';
    set title 'Top 10 Most Loaded LV Stations';
    set xlabel 'Station';
    set ylabel 'Load';
    set style data histogram;
    set style histogram cluster gap 1;
    set style fill solid border -1;
    set boxwidth 0.9;
    set datafile separator ';';
    plot '-' using (column(3)+0.0):xtic(1) title 'Load' linecolor rgb '#FF0000' with boxes;
    $top_10
    e"

    gnuplot -e "
    set terminal png size 800,600;
    set output 'graphs/bottom_10_lv.png';
    set title 'Top 10 Least Loaded LV Stations';
    set xlabel 'Station';
    set ylabel 'Load';
    set style data histogram;
    set style histogram cluster gap 1;
    set style fill solid border -1;
    set boxwidth 0.9;
    set datafile separator ';';
    plot '-' using (column(3)+0.0):xtic(1) title 'Load' linecolor rgb '#00FF00' with boxes;
    $bottom_10
    e"

    # Combine top and bottom 10 into one graph
    gnuplot -e "
    set terminal png size 1200,800;
    set output 'graphs/top_bottom_10_lv.png';
    set title 'Top and Bottom 10 LV Stations Load';
    set xlabel 'Station';
    set ylabel 'Load';
    set style data histogram;
    set style histogram cluster gap 1;
    set style fill solid border -1;
    set boxwidth 0.9;
    set datafile separator ';';
    plot '-' using (column(3)+0.0):xtic(1) title 'Top 10 Load' linecolor rgb '#FF0000' with boxes, \
         '-' using (column(3)+0.0):xtic(1) title 'Bottom 10 Load' linecolor rgb '#00FF00' with boxes;
    $top_10
    e
    $bottom_10
    e"
    echo "Graphiques créés avec succès."
}

#--------------------------------------------------------------------------------------------------------------#

# Appel des fonctions
check_arguments "$@"
check_gnuplot
check_file
check_directories
executable_verification
data_exploration
execute_program
if [ ${STATION_TYPE} = 'lv' ]; then
create_lv_all_graphs
fi