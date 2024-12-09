
all: exec

avl_tree.o : avl_tree.c avl_tree.h
		gcc -c avl_tree.c -o avl_tree.o

main.o : avl_tree.h
		gcc -c main.c -o main.o

exec : main.o avl_tree.o
	gcc main.o avl_tree.o -o exec

ajouter_dans_arbre.o : ajouter_dans_arbre.c 
	gcc ajouter_dans_arbre.c -o ajouter_dans_arbre
	progO/ajouter_dans_arbre


clean:
	rm -f exec main.o avl_tree.o
