#include "avl_tree.h"
#include <stdio.h>
#include <stdlib.h>

// Fonction pour obtenir la hauteur d'un nœud
int height(AVLNode *N) {
    if (N == NULL)
        return 0;
    return N->height;
}

// Fonction pour créer un nouveau nœud
AVLNode* newNode(int key) {
    AVLNode* node = (AVLNode*) malloc(sizeof(AVLNode));
    node->key   = key;
    node->left   = NULL;
    node->right  = NULL;
    node->height = 1;  // Nouveau nœud ajouté à la feuille
    return(node);
}

// Ajoutez ici les fonctions pour les rotations gauche, droite, et l'insertion avec équilibrage

// Exemple simple de parcours en ordre
void inorder(AVLNode* root) {
    if(root != NULL) {
        inorder(root->left);
        printf("%d\n", root->key);
        inorder(root->right);
    }
}