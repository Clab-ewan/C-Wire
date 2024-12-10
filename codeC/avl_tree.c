#include "avl_tree.h"

// Fonction pour créer un nouveau nœud
AVLNode* newNode(int station_id, long capacity, long load) {
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

AVLNode *leftRotate(AVLNode *node){
	if(node == NULL){
	exit(3);
	}
	int eq_a;
	int eq_p;
	AVLNode *pivot =node->right;
	node->right = pivot->left;
	pivot->left = node;
	eq_a = node->balance;
	eq_p = pivot->balance;
	node->balance = eq_a - max(eq_p, 0) - 1;
	pivot->balance = min(min(eq_a - 2, eq_a + eq_p - 2), eq_p - 1);
	node = pivot;
	return node;
}

AVLNode *rightRotate(AVLNode *node){
	if(node == NULL){
	exit(4);
	}
	int eq_a;
	int eq_p;
	AVLNode *pivot =node->left;
	node->left = pivot->right;
	pivot->right = node;
	eq_a = node->balance;
	eq_p = pivot->balance;
	node->balance = eq_a - min(eq_p, 0) + 1;
	pivot->balance = max(max(eq_a + 2, eq_a + eq_p + 2), eq_p + 1);
	node = pivot;
	return node;
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

AVLNode *balanceAVL(AVLNode *node){
	if(node == NULL){
		printf("error\n");
	}
	if(node->balance >= 2){
		if(node->right->balance >= 0){
			return leftRotate(node);
		}
		else{
			return DoubleRotateLeft(node);
		}
	}
	else if(node->balance <= -2){
		if(node->left->balance <=0){
			return rightRotate(node);
		}
		else{
			return DoubleRotateRight(node);
		}
	}
	return node;
}

AVLNode *insertAVL(AVLNode *node, int station_id, long capacity, long load, int *h){
	if(node == NULL){
		*h = 1;
		return newNode(station_id, capacity, load);
	}
	else if(station_id < node->station_id){
		node->left = insertAVL(node->left, station_id, capacity, load, h);
		*h = -(*h);
	}
	else if(station_id > node->station_id){
		node->right = insertAVL(node->right, station_id, capacity, load, h);
	}
	else{
		node->load += load;
		*h = 0;
		return node;
	}
	if( *h != 0){
		node->balance += *h;
		node = balanceAVL(node);
		if(node->balance == 0){
			*h = 0;
		}
		else{
			*h = 1;
		}
	}
	return node;
}

void inorder(AVLNode *node){
	if(node != NULL){
		inorder(node->left);
		printf("%d;%ld;%ld\n", node->station_id, node->capacity, node->load);
		inorder(node->right);
	}
}

AVLNode *freeAVL(AVLNode *node){
	if (node == NULL) {
		return node;
	}
	node->left = freeAVL(node->left);
	node->left = NULL;
	node->right = freeAVL(node->right);
	node->right = NULL;
	free(node);
	node = NULL;
	return node;
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
void saveAVLNodeToFile(const char *filename, AVLNode *node) {
    FILE *file = fopen(filename, "w");
    if (file == NULL) {
        perror("Erreur lors de l'ouverture du fichier pour l'export");
        return;
    }
    // Écrire l'en-tête du fichier
    fprintf(file, "Station_ID:Capacity:Load\n");
    // Appeler la fonction récursive pour exporter les données
    exportAVLNodeToFile(file, node);
    // Fermer le fichier
    fclose(file);
}
