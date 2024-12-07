#include "avl_tree.h"

// Fonction pour créer un nouveau nœud
AVLNode* newNode(int station_id, long load, long capacity) {
    AVLNode* node = (AVLNode*) malloc(sizeof(AVLNode));
    if (node == NULL) {
        fprintf(stderr, "Erreur d'allocation mémoire\n");
        exit(EXIT_FAILURE);
    }
    node->station_id = station_id;
    node->load = load;
    node->capacity = capacity;
    node->left = NULL;
    node->right = NULL;
    node->balance = 1; // Le nouveau nœud est une feuille
    return node;
}

// Fonction pour obtenir le maximum entre deux entiers
int max(int a, int b) {
    return (a > b) ? a : b;
}

// Fonction pour obtenir la hauteur d'un nœud
int print_balance(AVLNode *node) {
    if (node == NULL)
        return 0;
    return node->balance;
}

// Fonction pour obtenir le facteur d'équilibre d'un nœud
int getBalance(AVLNode *node) {
    if (node == NULL)
        return 0;
    return balance(node->left) - balance(node->right);
}

// Rotation à droite
AVLNode* rightRotate(AVLNode *y) {
    AVLNode *x = y->left;
    AVLNode *T2 = x->right;

    // Effectuer la rotation
    x->right = y;
    y->left = T2;

    // Mettre à jour les hauteurs
    y->balance = max(balance(y->left), balance(y->right)) + 1;
    x->balance = max(balance(x->left), balance(x->right)) + 1;

    // Retourner la nouvelle racine
    return x;
}

// Rotation à gauche
AVLNode* leftRotate(AVLNode *x) {
    AVLNode *y = x->right;
    AVLNode *T2 = y->left;

    // Effectuer la rotation
    y->left = x;
    x->right = T2;

    // Mettre à jour les hauteurs
    x->balance = max(balance(x->left), balance(x->right)) + 1;
    y->balance = max(balance(y->left), balance(y->right)) + 1;

    // Retourner la nouvelle racine
    return y;
}

// Double rotation à gauche
AVLNode* DoubleRotateLeft(AVLNode *node) {
    node->right = rightRotate(node->right);
    return leftRotate(node);
}

// Double rotation à droite
AVLNode* DoubleRotateRight(AVLNode *node) {
    node->left = leftRotate(node->left);
    return rightRotate(node);
}

AVLNode *balanceAVL(AVLNode *node){
    if (node->balance >= 2){
        if(node->right->balance >= 0){
            return rightRotate(node);
        }
        else{
            return DoubleRotateRight(node);
        }
    }
    if (node->balance <= -2){
        if(node->left->balance <= 0){
            return leftRotate(node);
        }
        else{
            return DoubleRotateLeft(node);
        }
    }
    return node;
}


// Fonction pour insérer un nœud dans l'arbre AVL
AVLNode* insert(AVLNode *node, int station_id, long load, long capacity) {      // A finir //
    // 1. Effectuer l'insertion normale
    if (node == NULL)
        return newNode(station_id, load, capacity);

    if (station_id < node->station_id)
        node->left = insert(node->left, station_id, load, capacity);
    else if (station_id > node->station_id)
        node->right = insert(node->right, station_id, load, capacity);
    else { // Station déjà présente, cumuler les valeurs
        node->load += load;
        node->capacity += capacity;
        return node;
    }

    // 2. Mettre à jour l'équilibre
    node->balance = 1 + max(balance(node->left), balance(node->right));

    // 3. Calculer le facteur d'équilibre
    int balance = getBalance(node);
    node = balanceAVL(node);
    // Retourner le nœud inchangé
    return node;
}


// Fonction récursive pour parcourir l'arbre en ordre croissant et écrire les données dans un fichier
void exportTreeToFile(FILE *file, AVLNode *node) {
    if (node == NULL)
        return;

    // Parcourir le sous-arbre gauche
    exportTreeToFile(file, node->left);

    // Écrire les données du nœud courant
    fprintf(file, "%d:%ld:%ld\n", node->station_id, node->capacity, node->load);

    // Parcourir le sous-arbre droit
    exportTreeToFile(file, node->right);
}

// Fonction pour ouvrir un fichier et démarrer l'export
void saveTreeToFile(const char *filename, AVLNode *root) {
    FILE *file = fopen(filename, "w");
    if (file == NULL) {
        perror("Erreur lors de l'ouverture du fichier pour l'export");
        return;
    }

    // Écrire l'en-tête du fichier
    fprintf(file, "Station_ID:Capacity:Load\n");

    // Appeler la fonction récursive pour exporter les données
    exportTreeToFile(file, root);

    // Fermer le fichier
    fclose(file);
}