#ifndef AVL_TREE_H
#define AVL_TREE_H

typedef struct AVLNode {
    int key;
    struct AVLNode *left;
    struct AVLNode *right;
    int height;
} AVLNode;

AVLNode* insert(AVLNode* node, int key);
void inorder(AVLNode* root);

#endif // AVL_TREE_H