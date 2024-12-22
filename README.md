
# C-Wire Project

Ce projet consiste à développer un programme pour synthétiser les données d'un système de distribution d'électricité. L'objectif est de permettre d’analyser les stations (centrales, stations HV-A, stations HV-B, postes LV) afin de déterminer si elles sont en situation de surproduction ou de sous-production d’énergie, ainsi que d’évaluer quelle proportion de leur énergie est consommée par les entreprises et les particuliers.
Pour ce faire, un fichier .csv est requis, contenant un ensemble de données détaillant la distribution d'électricité en France, depuis les centrales électriques, en passant par les sous-stations de distributions, jusqu'aux entreprises et aux particuliers, qui sont les clients finaux.

## Contenu du projet

Le répertoire contient les fichiers suivants :
- **README.md** : le fichier que vous êtes en train de lire.
- **.gitignore** : fichier pour ignorer certains fichiers lors de l'utilisation de Git.
- **Projet_C-Wire_Consigne.pdf** : documentation sur les consignes et les spécificités du projet.
- **rapport.pdf** : rapport détaillant les résultats et l'analyse du projet.
- **c-wire.sh** : script shell pour le tri et l'analyse du fichier de données.
- **codeC/** : répertoire contenant le code C du projet (utilisé pour effectuer les calculs nécessaires au projet).
- **test/** : répertoire contenant les fichiers générés a l'aide du fichier c-wire_v25.csv
- **input/** : répertoire contenant des fichiers d'entrées nécessaires pour l'exécution du projet.
- **graphs/** : répertoire contenant le graphique dans le cas de la demande "lv all"

 ## Installation

Pour installer et exécuter ce projet, suivez ces étapes :

1. Clonez le dépôt :
   ```bash
   git clone https://github.com/Clab-ewan/C-Wire.git
   ```

2. Allez dans le répertoire du projet :
   ```bash
   cd ./chemin/vers/C-Wire
   ```

3. Allez dans le répertoire input du projet et déposer votre fichier de données à traiter. 

## Utilisation

### Lancer le projet

Une fois le projet installé, vous pouvez l'exécuter en utilisant le script `c-wire.sh`.

### Commande du script

Exécutez le script de la manière suivante :
```bash
./c-wire.sh <csv_file> <station_type> <consumer_type> [central_id]
```

### Options du script

Le script `c-wire.sh` accepte les arguments suivants :

- `<csv_file>` : chemin vers le fichier CSV contenant les données de distribution d'électricité à traiter.
- `<station_type>` : type de station (ex. `hvb` pour haute tension B, `hva` pour haute tension A, `lv` pour basse tension). L’énergie est d’abord envoyée à très haute tension (~400 kV) vers les sous-stations HV-B, qui la réduisent à plus de 50 kV pour une grande zone. Elle est ensuite transférée aux sous-stations HV-A pour une réduction à plus de 1000 V pour une zone régionale. Enfin, les postes LV distribuent l’énergie aux particuliers et petites entreprises (230 V).

- `<consumer_type>` : type de consommateur (par exemple, `comp` pour compagnie, `ind` pour individuel, `all` pour tout type). Les stations HVB et HVA ne peuvent accueillir que l'option comp puisqu'elles ne sont pas raccordées aux particuliers.

- `[central_id]` : (optionnel) identifiant de la centrale électrique spécifique à analyser.

- `-h` : permet d'activer l'option d'aide en cas d'oublie de cette consigne.

### Résultats du script

A la fin de l'exécution, le script produit dans le dossier 'tmp' un fichier nommé '$TYPE_STATION'_'$CONSOMMATEUR'.csv qui contiendra les données de capacité et de charge de chaque station étudiée, les stations sont triées dans l'ordre croissant en fonction de leur capacité.

### Exemple d'exécution

Vous pouvez exécuter le script de la manière suivante :
```bash
./c-wire.sh input/c-wire_v25.dat hvb comp
```

Cela exécutera les processus définis dans le script pour gérer ou simuler les aspects du projet C-Wire pour les stations de type HV-B avec les compagnies.

## Documentation

La documentation du projet est disponible sous forme de fichiers PDF :
- **Projet_C-Wire_Consigne.pdf** : contient les spécifications détaillées du projet et des consignes à suivre.
- **rapport.pdf** : contient un rapport détaillé des résultats du projet, les analyses, et les conclusions.


## Auteurs

- **HAMELIN Simon**  - [Simonhamel1](https://github.com/Simonhamel1)
- **CLABAUT Ewan** - [Clab-ewan](https://github.com/Clab-ewan)
- **MARMELAT Paul** - [paulmarmelat](https://github.com/paulmarmelat)

