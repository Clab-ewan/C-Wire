#ifndef AVL_TREE_H
#define AVL_TREE_H
#include <stdio.h>
#include <stdlib.h>


// Chaque   nœud   de   l’AVL   représente   une   station   et   va   donc   contenir
// l’identifiant de la station ainsi que ses différentes données comme sa
// capacité, ou bien la somme de ses consommateurs qui sera mise à jour
// au fur et à mesure de la lecture des données par votre programme

typedef struct AVLNode {
    int station_id;
    long capacity;
    long load;
    struct AVLNode *left;
    struct AVLNode *right;
    int balance;
} AVLNode;

AVLNode * newNode(int station_id, long load, long capacity); 
int max(int a, int b);
int height(AVLNode *node);
int getBalance(AVLNode *node);
AVLNode * rightRotate(AVLNode *y);
AVLNode * leftRotate(AVLNode *x);
AVLNode * DoubleRotateLeft(AVLNode *node);
AVLNode * DoubleRotateRight(AVLNode *node);
AVLNode * insert(AVLNode *node, int station_id, long load, long capacity);


#endif // AVL_TREE_H