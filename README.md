
# C-Wire Project

Ce projet consiste à développer un programme pour synthétiser les données d'un système de distribution d'électricité.

Pour ce faire, un fichier .csv est requis, contenant un ensemble de données détaillant la distribution d'électricité en France, depuis les centrales électriques, à travers les sous-stations de distribution, jusqu'aux entreprises et particuliers, qui sont les clients finaux.

## Contenu du projet

Le répertoire contient les fichiers suivants :
- **README.md** : Ce fichier que vous êtes en train de lire.
- **.gitignore** : Fichier pour ignorer certains fichiers lors de l'utilisation de Git.
- **Projet_C-Wire_Consigne.pdf** : Documentation sur la consigne et les spécifications du projet.
- **rapport.pdf** : Rapport détaillant les résultats et l'analyse du projet.
- **c-wire.sh** : Script shell pour l'exécution des commandes principales du projet.
- **codeC/** : Répertoire contenant le code C source du projet.
- **test/** : Répertoire contenant les fichiers generer a l'aide du fichier c-wire_v25.csv
- **input/** : Répertoire contenant des fichiers d'entrée nécessaires pour l'exécution du projet.
- **graphs/** : Répertoire contenant le graphique dans le cas de lv all

## Installation

Pour installer et exécuter ce projet, suivez ces étapes :

1. Clonez le dépôt :
   ```bash
   git clone https://github.com/Clab-ewan/C-Wire.git
   ```

2. Allez dans le répertoire du projet :
   ```bash
   cd C-Wire
   ```

3. Allez dans le répertoire input du projet et déposer votre fichier données requis 

## Utilisation

### Lancer le projet

Une fois le projet installé, vous pouvez l'exécuter en utilisant le fichier `c-wire.sh`.

### Commande du script

Exécutez le script de la manière suivante :
```bash
./c-wire.sh <csv_file> <station_type> <consumer_type> [central_id]
```

### Options du script

Le script `c-wire.sh` accepte les arguments suivants :

- `<csv_file>` : Chemin vers le fichier CSV contenant les données de distribution d'électricité.
- `<station_type>` : Type de station (ex. `hvb` pour haute tension B, `hva` pour haute tension A, `lv` pour basse tension). L’énergie est d’abord envoyée à très haute tension (~400 kV) vers les sous-stations HV-B, qui la réduisent à plus de 50 kV pour une grande zone. Elle est ensuite transférée aux sous-stations HV-A pour une réduction à plus de 1000 V pour une zone régionale. Enfin, les postes LV distribuent l’énergie aux particuliers et petites entreprises (230 V).

- `<consumer_type>` : Type de consommateur (par exemple, `comp` pour compagnie, `ind` pour individuel, `all` pour tout type).

- `[central_id]` : (Optionnel) Identifiant de la centrale électrique spécifique à analyser.

- `-h` : permettant d'activer l'option d'aide en cas d'oublie de cette consigne

### Exemple d'exécution

Vous pouvez exécuter le script de la manière suivante :
```bash
./c-wire.sh input/c-wire_v00.dat hvb comp
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

