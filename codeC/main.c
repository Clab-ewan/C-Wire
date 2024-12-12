#include <stdio.h>
#include <stdlib.h>
#include "avl_tree.h"


int main(){
    AVLNode *root = NULL;
    int station_id = 0;
    int h = 0;
    long load = 0, capacity = 0;
    while (scanf("%d;%ld;%ld\n", &station_id, &capacity, &load) != EOF) {
        root = insertAVL(root, station_id, capacity, load, &h);
    }
    printf("Station_id;capacity;load\n");
    inorder(root);
    root = freeAVL(root);
    return 0;
}