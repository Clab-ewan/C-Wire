tu regardera ca elle marche bien et fais un tri

data_exploration() {
    echo "Exploration des données..."
    echo "STATION_TYPE: $STATION_TYPE"
    echo "CONSUMER_TYPE: $CONSUMER_TYPE"
    echo "CENTRAL_ID: $CENTRAL_ID"
    echo "INPUT_FILE: $INPUT_FILE"

    # Préparation du motif pour CENTRAL_ID
    if [ "$CENTRAL_ID" = "*" ]; then
        CENTRAL_ID_PATTERN=".*"
    else
        CENTRAL_ID_PATTERN="^$CENTRAL_ID$"
    fi

    case "$STATION_TYPE" in
        'hvb')
            echo "Filtrage pour hvb..."
            awk -F';' -v cid="$CENTRAL_ID_PATTERN" 'NR>1 && ($1 ~ cid) && ($2 != "-")' "$INPUT_FILE" > tmp/filtered_data.csv
        ;;
        'hva')
            echo "Filtrage pour hva..."
            awk -F';' -v cid="$CENTRAL_ID_PATTERN" 'NR>1 && ($1 ~ cid) && ($3 != "-")' "$INPUT_FILE" > tmp/filtered_data.csv
        ;;
        'lv')
            echo "Filtrage pour lv..."
            case "$CONSUMER_TYPE" in 
                'comp')
                    echo "Filtrage pour comp..."
                    awk -F';' -v cid="$CENTRAL_ID_PATTERN" 'NR>1 && ($1 ~ cid) && ($5 != "-")' "$INPUT_FILE" > tmp/filtered_data.csv
                ;;
                'indiv')
                    echo "Filtrage pour indiv..."
                    awk -F';' -v cid="$CENTRAL_ID_PATTERN" 'NR>1 && ($1 ~ cid) && ($6 != "-")' "$INPUT_FILE" > tmp/filtered_data.csv
                ;;
                'all')
                    echo "Filtrage pour all..."
                    awk -F';' -v cid="$CENTRAL_ID_PATTERN" 'NR>1 && ($1 ~ cid) && ($4 != "-")' "$INPUT_FILE" > tmp/filtered_data.csv
                ;;
                *)
                    echo "Erreur : Type de consommateur inconnu pour la station 'lv'."
                    exit 1
                ;;
            esac
        ;;
        *)
            echo "Erreur : Type de station inconnu."
            exit 1
        ;;
    esac

    if [[ ! -s tmp/filtered_data.csv ]]; then
        echo "Aucune donnée trouvée pour les critères spécifiés."
        exit 1
    fi

    echo "Données filtrées :"
    cat tmp/filtered_data.csv
}