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
int balance(AVLNode *node) {
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

// Fonction pour insérer un nœud dans l'arbre AVL
AVLNode* insert(AVLNode *node, int station_id, long load, long capacity) {
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

    // 2. Mettre à jour la hauteur
    node->balance = 1 + max(balance(node->left), balance(node->right));

    // 3. Calculer le facteur d'équilibre
    int balance = getBalance(node);

    // 4. Vérifier les cas de déséquilibre

    // Gauche Gauche
    if (balance > 1 && station_id < node->left->station_id)
        return rightRotate(node);

    // Droite Droite
    if (balance < -1 && station_id > node->right->station_id)
        return leftRotate(node);

    // Gauche Droite
    if (balance > 1 && station_id > node->left->station_id) {
        node->left = leftRotate(node->left);
        return rightRotate(node);
    }

    // Droite Gauche
    if (balance < -1 && station_id < node->right->station_id) {
        node->right = rightRotate(node->right);
        return leftRotate(node);
    }

    // Retourner le nœud inchangé
    return node;
}