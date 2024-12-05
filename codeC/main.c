#include <stdio.h>
#include <stdlib.h>
#include "avl_tree.h"

int main() {
    AVLNode *root = NULL;
    FILE *file = fopen("tmp/lv_all.csv", "r");
    if (file == NULL) {
        perror("Erreur lors de l'ouverture du fichier");
        return EXIT_FAILURE;
    }

    char line[256];
    while (fgets(line, sizeof(line), file)) {
        int key;
        // Supposons que la clé est le premier nombre de chaque ligne
        if (sscanf(line, "%d;", &key) == 1) {
            root = insert(root, key);
        }
    }

    fclose(file);

    // Affichage de l'arbre en parcours infixe
    inorder(root);

    // N'oubliez pas de libérer la mémoire allouée pour l'arbre

    return EXIT_SUCCESS;
}