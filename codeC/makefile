CC = gcc
CFLAGS = -Wall -Wextra -pedantic -std=c11
TARGET = progO/program
SRCS = main.c

all: $(TARGET)

$(TARGET): $(SRCS)
	$(CC) $(CFLAGS) -o $(TARGET) $(SRCS)

clean:
	rm -f $(TARGET)