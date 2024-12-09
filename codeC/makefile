all: progO/exec

progO/avl_tree.o : avl_tree.c avl_tree.h
	gcc -c avl_tree.c -o progO/avl_tree.o

progO/main.o : avl_tree.h
	gcc -c main.c -o progO/main.o

progO/exec : progO/main.o progO/avl_tree.o
	gcc progO/main.o progO/avl_tree.o -o progO/exec

clean:
	rm progO/exec progO/*.o
