#include <stdio.h>
#include <stdlib.h>
#include "avl_tree.h"


int main(){
    AVLNode *root = NULL;
    int station_id = 0;
    int *h = 0;
    long load, capacity;

    while (scanf("%d;%ld;%ld", &station_id, &load, &capacity) != EOF) {
        root = insertAVL(root, station_id, capacity, load, &h);
    }
}