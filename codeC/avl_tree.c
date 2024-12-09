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
    node->balance = 0; // Le nouveau nœud est une feuille
    return node;
}

// Fonction pour obtenir le maximum entre deux entiers
int max(int a, int b) {
    return (a > b) ? a : b;
}

// Fonction pour obtenir le minimum entre deux entiers
int min(int a, int b) {
    return (a > b) ? b : a;
}

// Fonction pour obtenir la hauteur d'un nœud
int print_balance(AVLNode *node) {
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

AVLNode *leftRotate(AVLNode *t){
	if(t == NULL){
	exit(3);
	}
	int eq_a;
	int eq_p;
	AVLNode *pivot =t->right;
	t->right = pivot->left;
	pivot->left = t;
	eq_a = t->balance;
	eq_p = pivot->balance;
	t->balance = eq_a - max(eq_p, 0) - 1;
	pivot->balance = min(min(eq_a - 2, eq_a + eq_p - 2), eq_p - 1);
	t = pivot;
	return t;
}

AVLNode *rightRotate(AVLNode *t){
	if(t == NULL){
	exit(4);
	}
	int eq_a;
	int eq_p;
	AVLNode *pivot =t->left;
	t->left = pivot->right;
	pivot->right = t;
	eq_a = t->balance;
	eq_p = pivot->balance;
	t->balance = eq_a - min(eq_p, 0) + 1;
	pivot->balance = max(max(eq_a + 2, eq_a + eq_p + 2), eq_p + 1);
	t = pivot;
	return t;
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

AVLNode *balanceAVL(AVLNode *t){
	if(t == NULL){
		printf("error\n");
	}
	if(t->balance >= 2){
		if(t->right->balance >= 0){
			return LeftRotation(t);
		}
		else{
			return DLeftRotation(t);
		}
	}
	else if(t->balance <= -2){
		if(t->left->balance <=0){
			return RightRotation(t);
		}
		else{
			return DRightRotation(t);
		}
	}
	return t;
}

AVLNode *insertAVL(AVLNode *root, int station_id, long capacity, long load, int *h){
	if(root == NULL){
		*h = 1;
		return newNode(station_id, load, capacity);
	}
	else if(station_id < root->station_id){
		root->left = insertAVL(root->left, station_id, capacity, load, h);
		*h = -(*h);
	}
	else if(station_id > root->station_id){
		root->right = insertAVL(root->right, station_id, capacity, load, h);
	}
	else{
		root->load += load;
		*h = 0;
		return root;
	}
	if( *h != 0){
		root->balance += *h;
		root = BalanceAVL(root);
		if(root->balance == 0){
			*h = 0;
		}
		else{
			*h = 1;
		}
	}
	return root;
}

// Fonction récursive pour parcourir l'arbre en ordre croissant et écrire les données dans un fichier
void exportAVLNodeToFile(FILE *file, AVLNode *node) {
    if (node == NULL)return;
    // Parcourir le sous-arbre gauche
    exportAVLNodeToFile(file, node->left);
    // Écrire les données du nœud courant
    fprintf(file, "%d:%ld:%ld\n", node->station_id, node->capacity, node->load);
    // Parcourir le sous-arbre droit
    exportAVLNodeToFile(file, node->right);
}

// Fonction pour ouvrir un fichier et démarrer l'export
void saveAVLNodeToFile(const char *filename, AVLNode *root) {
    FILE *file = fopen(filename, "w");
    if (file == NULL) {
        perror("Erreur lors de l'ouverture du fichier pour l'export");
        return;
    }
    // Écrire l'en-tête du fichier
    fprintf(file, "Station_ID:Capacity:Load\n");
    // Appeler la fonction récursive pour exporter les données
    exportAVLNodeToFile(file, root);
    // Fermer le fichier
    fclose(file);
}
