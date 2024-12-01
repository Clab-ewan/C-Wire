CC = gcc
CFLAGS = -Wall -Wextra -pedantic -std=c11
TARGET = progO/program
SRCS = $(wildcard *.c) # Tous les fichiers .c automatiquement dans le répertoire courant

all: $(TARGET)
	@./$(TARGET)
	@if [ ! -d "progO" ]; then mkdir -p progO; fi # Si le répertoire n'existe pas, le créer

$(TARGET): $(SRCS)
	@mkdir -p $(dir $(TARGET)) # Crée le répertoire si nécessaire
	$(CC) $(CFLAGS) -o $(TARGET) $(SRCS)

clean:
	rm -f $(TARGET)
	if [ -d "progO" ]; then rmdir progO; fi