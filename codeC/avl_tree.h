#ifndef AVL_TREE_H
#define AVL_TREE_H
#include <stdio.h>
#include <stdlib.h>


// Each node of the AVL represents a station and will therefore contain
// the station's identifier as well as its various data such as its
// capacity, or the sum of its consumers which will be updated
// as the data is read by your program

typedef struct AVLNode {
    int station_id;
    long capacity;
    long load;
    struct AVLNode *left;
    struct AVLNode *right;
    int balance;
} AVLNode;

AVLNode * newNode(int station_id, long capacity, long load); 
int max(int a, int b);
int min(int a, int b);
void inorder(AVLNode *node);
AVLNode *rightRotate(AVLNode *node);
AVLNode *leftRotate(AVLNode *node);
AVLNode *DoubleRotateLeft(AVLNode *node);
AVLNode *DoubleRotateRight(AVLNode *node);
AVLNode *insertAVL(AVLNode *node, int station_id, long capacity, long load, int *h);
AVLNode *balanceAVL(AVLNode *node);
AVLNode *freeAVL(AVLNode *node);
void exportAVLNodeToFile(FILE *file, AVLNode *node);// Fonction pour parcourir l'arbre AVL et exporter les résultats dans un fichier
void saveAVLNodeToFile(const char *filename, AVLNode *root);// Fonction pour sauvegarder l'arbre dans un fichier en commençant par ouvrir le fichier
#endif // AVL_TREE_H