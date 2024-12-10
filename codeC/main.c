#include <stdio.h>
#include <stdlib.h>
#include "avl_tree.h"


int main(){
    AVLNode *root = NULL;
    int station_id = 0;
    int h = 0;
    long load = 0, capacity = 0;
    // while (scanf("%d;%ld;%ld\n", &station_id, &capacity, &load) != EOF) {
    //     root = insertAVL(root, station_id, capacity, load, &h);
    // }
    root = insertAVL(root, 10, 158768, 0, &h);
    root = insertAVL(root, 12, 1657653, 0, &h);
    root = insertAVL(root, 13, 7858737, 0, &h);
    root = insertAVL(root, 13, 0, 17628762, &h);
    root = insertAVL(root, 14, 0, 17628762, &h);
    root = insertAVL(root, 7, 0, 17628762, &h);
    root = insertAVL(root, 103, 0, 17628762, &h);
    root = insertAVL(root, 6, 0, 17628762, &h);
    printf("Display AVL :\nstation_id;capacity;load;balance\n");
    inorder(root);
    root = freeAVL(root);
    inorder(root);
    return 0;
}