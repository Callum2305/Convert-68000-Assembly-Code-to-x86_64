# Makefile for project 2, saves me having to type the commands in bash every time
# C00306572 Callum Matthews

ASM      = nasm
LINKER   = ld
CC       = gcc
ASMFLAGS = -f elf64

TARGET   = project2
OBJ      = project2.o
SRC      = project2.asm
TEST     = test_project2
TEST_SRC = test_project2.c

all: $(TARGET)

$(TARGET): $(OBJ)
	$(LINKER) $(OBJ) -o $(TARGET)

$(OBJ): $(SRC)
	$(ASM) $(ASMFLAGS) $(SRC) -o $(OBJ)

test: $(TEST)
	./$(TEST)

$(TEST): $(TEST_SRC)
	$(CC) $(TEST_SRC) -o $(TEST)

clean:
	rm -f $(OBJ) $(TARGET) $(TEST)