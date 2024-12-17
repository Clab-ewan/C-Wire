#!/bin/bash

###########################################################################################
#             ______      ____      ____  _____  _______     ________                     #
#           .' ___  |    |_  _|    |_  _||_   _||_   __ \   |_   __  |                    #
#          / .'   \_|______\ \  /\  / /    | |    | |__) |    | |_ \_|                    #
#          | |      |______|\ \/  \/ /     | |    |  __ /     |  _| _                     #
#          \ `.___.'\        \  /\  /     _| |_  _| |  \ \_  _| |__/ |                    #
#           `.____ .'         \/  \/     |_____||____| |___||________|                    # 
#                                                                                         #
###########################################################################################
#                                                                                         #
# This script filters data from a CSV file based on the station type specified by the     #
# user, executes the C program with the filtered data, and saves the results in a         #
# temporary file.                                                                         #
#                                                                                         #
# Usage: ./c-wire.sh <csv_file> <station_type> <consumer_type> [central_id]               #
#                                                                                         #
# Arguments:                                                                              #
#   - csv_file: CSV file containing the data to be processed                              #
#   - station_type: type of station to filter (hvb, hva, lv)                              #
#   - consumer_type: type of consumer to process (comp, indiv, all)                       #
#   - central_id: identifier of the central to process (optional)                         #
#                                                                                         #
# Example: ./c-wire.sh input/c-wire_v00.csv hva comp                                      #
#                                                                                         #
# This represents the processing of data from the file data.csv for HV-B stations         #
# consuming electricity and connected to central 1.                                       #    
#                                                                                         #
###########################################################################################

#--------------------------------------------------------------------------------------------------------------#

for arg in "$@"; do
    if [ "$arg" == "-h" ]; then
        echo "                            CENTRAL"
        echo "                                │"
        echo "                ┌───────────────┴───────────────┬────────────────────..."
        echo "                │                               │"               
        echo "          HV-B STATION                    other HV-B stations"
        echo "                │"                     
        echo "        ┌───────┴───────────────────┬────────────────────────────────────┬──────────────..."
        echo "        │                           │                                    │"
        echo "   HV-A STATION          HV-B Consumers (hvb comp)        other HV-A stations"
        echo "        │"
        echo "       ┌┴──────────────────────────────────┬────────────────────────────────────┬──────────────..."
        echo "       │                                   │                                    │"
        echo "    LV STATION                   HV-A Consumer (hva comp)              other LV stations"
        echo "       │"
        echo "   ┌───┴──────────────────────────────────┐"
        echo "   │                                      │"
        echo "Companies   (lv comp)             individuals (lv indiv)  "
        echo ""
        echo ""
        echo "Usage: $0 <csv_file> <station_type> <consumer_type> [central_id]"
        echo "Description: This script processes energy consumption data."
        echo "Parameters:"
        echo "  <csv_file>         : Path to the CSV file containing the data."
        echo "  <station_type>     : Type of station ('hva', 'hvb', 'lv')."
        echo "  <consumer_type>    : Type of consumer ('comp', 'indiv', 'all')."
        echo "  [central_id]       : (Optional) Central identifier (must be a number)."
        echo "Options:"
        echo "  -h                 : Displays this help and exits."
        exit 0
    fi
done

#--------------------------------------------------------------------------------------------------------------#

# Check for the existence of software for the graphical part (Gnuplot).
check_gnuplot(){
    if command -v gnuplot &> /dev/null 
    then
        echo "Gnuplot is installed on your system."
    else
        echo "Gnuplot is not installed on your system."
        # Installation.
        echo "Do you want to install Gnuplot? (y/n)"
        read -r answer
        if [ "$answer" == "y" ]; then
            echo "Installing Gnuplot..."
            sudo apt-get update
            sudo apt-get install gnuplot
        fi
        if [ "$answer" == "n" ]; then
            echo "Gnuplot is mandatory for this program."
            exit 1
        fi
        # Check the installation.
        if [ $? -eq 0 ]; then
            echo "Gnuplot was successfully installed."
        else
            echo "Error during the installation of Gnuplot."
            exit 1
        fi
    fi
}

#--------------------------------------------------------------------------------------------------------------#

# Check passed arguments
check_arguments() {
    if [ $# -lt 3 ]; then # If the number of arguments is less than 3
        echo "Usage: $0 <csv_file> <station_type> <consumer_type> [central_id]"
        echo "Time : 0.0sec"
        exit 1
    fi
    if [ "$2" != "hva" ] && [ "$2" != "hvb" ] && [ "$2" != "lv" ]; then
        echo "Error: The station type must be 'hva', 'hvb', or 'lv'."
        echo "Time : 0.0sec"
        exit 1
    fi
    if [ "$3" != "comp" ] && [ "$3" != "indiv" ] && [ "$3" != "all" ]; then
        echo "Error: The consumer type must be 'comp', 'indiv', or 'all'."
        echo "Time : 0.0sec"
        exit 1
    fi
    if { [ "$2" == "hvb" ] || [ "$2" == "hva" ]; } && { [ "$3" == "all" ] || [ "$3" == "indiv" ]; }; then
        echo "Error: The following options are not allowed: hvb all, hvb indiv, hva all, hva indiv."
        echo "Time : 0.0sec"
        exit 1
    fi
    if ! [[ "$4" =~ ^[1-5]+$ ]] && [ -n "$4" ]; then
        echo "Error: The central identifier must be a number."
        echo "Time : 0.0sec"
        exit 1
    fi
    echo "Valid arguments."
}

#--------------------------------------------------------------------------------------------------------------#

INPUT_FILE=$1
STATION_TYPE=$2
CONSUMER_TYPE=$3
CENTRAL_ID=${4:-"[^-]+"}

# Check if the CSV file exists and is not empty
check_file() {
    if [ ! -f "$INPUT_FILE" ]; then
        echo "Error: The file '$INPUT_FILE' does not exist."
        exit 1
    elif [ ! -s "$INPUT_FILE" ]; then
        echo "Error: The file '$INPUT_FILE' is empty."
        exit 1
    fi
}

#--------------------------------------------------------------------------------------------------------------#

# Create necessary directories for the script and remove old ones
check_directories() {
    rm -rf "./tmp/" 
    for directory in "tmp" "tests" "graphs" "codeC/progO"; do
        if [ ! -d "$directory" ]; then
            mkdir "$directory"
        fi
    done
    echo "Directories tmp, tests, graphs, codeC/progO created."
}

#--------------------------------------------------------------------------------------------------------------#

# Verification of the C program executable and compilation if necessary
executable_verification() {
    if [ ! -f ./CodeC/progO/exec ]; then
        echo "Compiling..."
        make -C codeC > /dev/null 2>&1 || { echo "Compilation error"; exit 1; }
    fi
    echo "C program compiled without errors."
}

#--------------------------------------------------------------------------------------------------------------#

# Data exploration and filtering
data_exploration() {
case "$STATION_TYPE" in
    'hvb')  grep -E "^$CENTRAL_ID;[^-]+;-;-;[^;]+;-;[^;]+;[^;]+$" "$INPUT_FILE" | cut -d ";" -f2,7,8 | tr "-" "0" | ./codeC/progO/exec | file_modifier
    ;;
    'hva') grep -E "^$CENTRAL_ID;[^-]+;[^-]+;-;-;-;[^;]+;-$|^$CENTRAL_ID;-;[^-]+;-;[^-]+;-;-;[^-]+$" "$INPUT_FILE" | cut -d ";" -f3,7,8 | tr "-" "0" | ./codeC/progO/exec | file_modifier
    ;;
    'lv') case "$CONSUMER_TYPE" in 
            'comp') grep -E "^$CENTRAL_ID;-;[^-]+;[^-]+;-;-;[^-]+;-$|^$CENTRAL_ID;-;-;[^-]+;[^-]+;-;-;[^-]+$" "$INPUT_FILE" | cut -d ";" -f4,7,8 | tr "-" "0" | ./codeC/progO/exec | file_modifier
            ;;
            'indiv') grep -E "^$CENTRAL_ID;-;[^-]+;[^-]+;-;-;[^-]+;-$|^$CENTRAL_ID;-;-;[^-]+;-;[^-]+;-;[^-]+$" "$INPUT_FILE" | cut -d ";" -f4,7,8 | tr "-" "0" | ./codeC/progO/exec | file_modifier
            ;;
            'all') grep -E "^$CENTRAL_ID;-;[^-]+;[^-]+;-;-;[^-]+;-$|^$CENTRAL_ID;-;-;[^-]+;[^-]+;-;-;[^-]+$|^$CENTRAL_ID;-;-;[^-]+;-;[^-]+;-;[^-]+$" "$INPUT_FILE" | cut -d ";" -f4,7,8 | tr "-" "0" | ./codeC/progO/exec | file_modifier
            ;;
            *) echo "Error argument"
                exit 1
            ;;
        esac
    ;;
    *) echo "Error argument"
        exit 1
    ;;
esac
}

#--------------------------------------------------------------------------------------------------------------#

# Execution of the C program
file_modifier(){
    if [ ${CENTRAL_ID} = "[^-]+" ]; then
    sort -t ":" -k2n | sed "1s/^/Station ${STATION_TYPE}:Capacity:Load\n/" > ./tmp/${STATION_TYPE}_${CONSUMER_TYPE}.csv
    else
    sort -t ":" -k2n | sed "1s/^/Station ${STATION_TYPE}:Capacity:Load\n/" > ./tmp/${STATION_TYPE}_${CONSUMER_TYPE}_${CENTRAL_ID}.csv
    fi
}

#--------------------------------------------------------------------------------------------------------------#

# function to create the top 10 and bottom 10 consumers of the LV station
create_lvallminmax() {
    if [ ${CENTRAL_ID} = "[^-]+" ]; then
        tail -n +2 "./tmp/lv_all.csv" | awk -F: '{print $0 ":" ($2 - $3)}' | sort -t ":" -k4n | (head -n 10; tail -n 10) >> "./tmp/lv_all_minmax.csv"
    else
        tail -n +2 "./tmp/lv_all_${CENTRAL_ID}.csv" | awk -F: '{print $0 ":" ($2 - $3)}' | sort -t ":" -k4n | (head -n 10; tail -n 10) >> "./tmp/lv_all_minmax.csv"
    fi 
}

#--------------------------------------------------------------------------------------------------------------#

# function to create the graphs of the top 10 and bottom 10 consumers of the LV station
create_lv_all_graphs() {

    gnuplot <<EOF
        set terminal pngcairo size 800,600
        set output "./graphs/lv_all_minmax.png"

        set object 1 rectangle from screen 0,0 to screen 1,1 behind fc rgb "white" fillstyle solid 1.0
        set border lc rgb "black"
        set grid lc rgb "gray"
        set key textcolor rgb "black"
        set title textcolor rgb "black"
        set xlabel textcolor rgb "black"
        set xtics rotate by -45
        set ylabel textcolor rgb "black"

        set title "Top 10 and Bottom 10 LV Consumers" font "Arial, 16"
        set xlabel "LV Station" font "Arial, 12"
        set ylabel "Consumption (kW)" font "Arial, 12"
        set key left top

        set datafile separator ":"

        set style data histogram
        set style histogram rowstacked 
        set style fill solid 1.0 border -1
        set boxwidth 0.8 relative
        set grid ytics lw 1
        set border 3


    plot    './tmp/lv_all_minmax.csv' using (column(4) < column(1) ? abs(column(2)-column(3)) : column(3)):xtic(1) title 'Load' lc rgb "green", \
            '< tail -n +11 ./tmp/lv_all_minmax.csv' using 3-2:xtic(1) title 'Surplus' lc rgb "red", \
            './tmp/lv_all_minmax.csv' using (column(4) < column(1) ? 0 : column(2)-column(3)):xtic(1) title 'Capacity' lc rgb "blue"
            
            
EOF

}

#--------------------------------------------------------------------------------------------------------------#

# Function calls
check_arguments "$@"
check_gnuplot
check_file
check_directories
executable_verification
start_time=$(date +%s)
data_exploration
if [[ ${STATION_TYPE} = 'lv' && ${CONSUMER_TYPE} = 'all' ]]; then
create_lvallminmax
create_lv_all_graphs
fi
end_time=$(date +%s.%N)
execution_time=$(echo "$end_time - $start_time" | bc)
echo "Program executed successfully in $execution_time sec."
