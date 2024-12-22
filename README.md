
# C-Wire Project

Ce projet consiste à développer un programme pour synthétiser les données d'un système de distribution d'électricité. L'objectif est de permettre d’analyser les stations (centrales, stations HV-A, stations HV-B, postes LV) afin de déterminer si elles sont en situation de surproduction ou de sous-production d’énergie, ainsi que d’évaluer quelle proportion de leur énergie est consommée par les entreprises et les particuliers.
Pour ce faire, un fichier .csv est requis, contenant un ensemble de données détaillant la distribution d'électricité en France, depuis les centrales électriques, en passant par les sous-stations de distributions, jusqu'aux entreprises et aux particuliers, qui sont les clients finaux.

   ## Contenu du projet

Le répertoire contient les fichiers suivants :
- **README.md** : Le fichier que vous êtes en train de lire.
- **.gitignore** : Fichier pour ignorer certains fichiers lors de l'utilisation de Git.
- **Projet_C-Wire_Consigne.pdf** : Documentation sur les consignes et les spécificités du projet.
- **rapport.pdf** : Rapport détaillant les résultats et l'analyse du projet.
- **c-wire.sh** : Script shell pour le tri et l'analyse du fichier de données.
- **codeC/** : Répertoire contenant le code C du projet (utilisé pour effectuées les calculs nécessaires au projet).
- **test/** : Répertoire contenant les fichiers génerées a l'aide du fichier c-wire_v25.csv
- **input/** : Répertoire contenant des fichiers d'entrées nécessaires pour l'exécution du projet.
- **graphs/** : Répertoire contenant le graphique dans le cas de la demande "lv all"

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

3. Allez dans le répertoire input du projet et déposer votre fichier données requis 

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

- `<csv_file>` : Chemin vers le fichier CSV contenant les données de distribution d'électricité à traiter.
- `<station_type>` : Type de station (ex. `hvb` pour haute tension B, `hva` pour haute tension A, `lv` pour basse tension). L’énergie est d’abord envoyée à très haute tension (~400 kV) vers les sous-stations HV-B, qui la réduisent à plus de 50 kV pour une grande zone. Elle est ensuite transférée aux sous-stations HV-A pour une réduction à plus de 1000 V pour une zone régionale. Enfin, les postes LV distribuent l’énergie aux particuliers et petites entreprises (230 V).

- `<consumer_type>` : Type de consommateur (par exemple, `comp` pour compagnie, `ind` pour individuel, `all` pour tout type). Les staions HVB et HVA ne peuvent accueillir que l'option comp puisqu'elles ne sont pas raccordées aux particuliers

- `[central_id]` : (Optionnel) Identifiant de la centrale électrique spécifique à analyser.

- `-h` : permettant d'activer l'option d'aide en cas d'oublie de cette consigne

### Résultat du script
// a faire //

### Exemple d'exécution

Vous pouvez exécuter le script de la manière suivante :
```bash
./c-wire.sh input/c-wire_v25.dat hvb comp
```

Cela exécutera les processus définis dans le script pour gérer ou simuler les aspects du projet C-Wire pour les stations de type HV-B avec les compagnies.

## Documentation

La documentation du projet est disponible sous forme de fichiers PDF :
- **Projet_C-Wire_Consigne.pdf** : Contient les spécifications détaillées du projet et des consignes à suivre.
- **rapport.pdf** : Contient un rapport détaillé des résultats du projet, les analyses, et les conclusions.


## Auteurs

- **HAMELIN Simon**  - [Simonhamel1](https://github.com/Simonhamel1)
- **CLABAUT Ewan** - [Clab-ewan](https://github.com/Clab-ewan)
- **MARMELAT Paul** - [paulmarmelat](https://github.com/paulmarmelat)

