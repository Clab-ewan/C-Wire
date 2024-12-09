#include <stdio.h>
#include <stdlib.h>

// Structure d'un nœud de l'arbre AVL
typedef struct AVLNode {
    int station_id;
    long load;
    long capacity;
    int balance;
    struct AVLNode *left;
    struct AVLNode *right;
} AVLNode;

// Fonction pour ajouter dans l'arbre AVL
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

        // il faut rajouter les fonctions d'équilibrage
    }

    // 2. Mettre à jour l'équilibre
    node->balance = 1 + max(balance(node->left), balance(node->right));

    // 3. Calculer le facteur d'équilibre
    int balance = getBalance(node);
    node = balanceAVL(node);
    // Retourner le nœud inchangé
    return node;
}

int main(){
    AVLNode *root = NULL;
    int station_id;
    long load, capacity;

    while (scanf("%d %ld %ld", &station_id, &load, &capacity) != EOF) {
        root = insert(root, station_id, load, capacity);
    }
}