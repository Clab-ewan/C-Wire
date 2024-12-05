CC = gcc
CFLAGS = -Wall -Wextra -pedantic -std=c11
TARGET = progO/program
SRCS = $(wildcard *.c) # Inclut tous les fichiers .c

all: $(TARGET)

$(TARGET): $(SRCS)
	@mkdir -p $(dir $(TARGET))
	$(CC) $(CFLAGS) -o $(TARGET) $(SRCS)

clean:
	rm -f $(TARGET)
	if [ -d "progO" ]; then rmdir progO; fi