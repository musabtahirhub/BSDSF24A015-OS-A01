# Variables
CC = gcc
CFLAGS = -Wall -Wextra -Iinclude
PREFIX = /usr/local
BIN_DIR = $(PREFIX)/bin
LIB_DIR = $(PREFIX)/lib
INCLUDE_DIR = $(PREFIX)/include
MAN_DIR = $(PREFIX)/share/man/man3

all: bin/client_static bin/client_dynamic

# Dynamic Client
bin/client_dynamic: obj/main.o lib/libmyutils.so
	mkdir -p bin
	gcc obj/main.o -Llib -lmyutils -o bin/client_dynamic

# Dynamic Shared Library (.so)
lib/libmyutils.so: obj/mystrfunctions_pic.o obj/myfilefunctions_pic.o
	mkdir -p lib
	gcc -shared obj/mystrfunctions_pic.o obj/myfilefunctions_pic.o -o lib/libmyutils.so

obj/mystrfunctions_pic.o: src/mystrfunctions.c include/mystrfunctions.h
	mkdir -p obj
	gcc -fPIC -Iinclude -c src/mystrfunctions.c -o obj/mystrfunctions_pic.o

obj/myfilefunctions_pic.o: src/myfilefunctions.c include/myfilefunctions.h
	mkdir -p obj
	gcc -fPIC -Iinclude -c src/myfilefunctions.c -o obj/myfilefunctions_pic.o

# Static Client (linking statically against the archive)
bin/client_static: obj/main.o lib/libmyutils.a
	mkdir -p bin
	gcc obj/main.o lib/libmyutils.a -o bin/client_static

# Static Archive (.a)
lib/libmyutils.a: obj/mystrfunctions.o obj/myfilefunctions.o
	mkdir -p lib
	ar rcs lib/libmyutils.a obj/mystrfunctions.o obj/myfilefunctions.o

# Standard Object files
obj/mystrfunctions.o: src/mystrfunctions.c include/mystrfunctions.h
	mkdir -p obj
	gcc -Iinclude -c src/mystrfunctions.c -o obj/mystrfunctions.o

obj/myfilefunctions.o: src/myfilefunctions.c include/myfilefunctions.h
	mkdir -p obj
	gcc -Iinclude -c src/myfilefunctions.c -o obj/myfilefunctions.o

obj/main.o: src/main.c include/mystrfunctions.h include/myfilefunctions.h
	mkdir -p obj
	gcc -Iinclude -c src/main.c -o obj/main.o

# Install Target: Installs binaries, shared libs, headers, and man pages into system directories
install: bin/client_dynamic lib/libmyutils.so
	mkdir -p $(BIN_DIR) $(LIB_DIR) $(INCLUDE_DIR) $(MAN_DIR)
	cp bin/client_dynamic $(BIN_DIR)/client
	cp lib/libmyutils.so $(LIB_DIR)/
	cp include/*.h $(INCLUDE_DIR)/
	cp man/man3/*.3 $(MAN_DIR)/
	ldconfig $(LIB_DIR)
	mandb

# Uninstall Target: Clean system directories
uninstall:
	rm -f $(BIN_DIR)/client
	rm -f $(LIB_DIR)/libmyutils.so
	rm -f $(INCLUDE_DIR)/mystrfunctions.h $(INCLUDE_DIR)/myfilefunctions.h
	rm -f $(MAN_DIR)/mystrfunctions.3 $(MAN_DIR)/myfilefunctions.3
	ldconfig $(LIB_DIR)
	mandb

clean:
	rm -rf obj/*.o lib/*.a lib/*.so bin/*

.PHONY: all clean install uninstall