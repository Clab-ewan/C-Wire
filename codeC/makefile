all: exec

progO/avl_tree.o : avl_tree.c avl_tree.h
	gcc -c avl_tree.c -o progO/avl_tree.o

progO/main.o : avl_tree.h
	gcc -c main.c -o progO/program

exec : progO/main.o progO/avl_tree.o
	gcc progO/main.o progO/avl_tree.o -o exec

clean:
	rm -f exec progO/*.o
