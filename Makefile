# Step 1: Default target builds the static client
bin/client_static: obj/main.o lib/libmyutils.a
	mkdir -p bin
	gcc obj/main.o -Llib -lmyutils -o bin/client_static

# Step 2: Build static archive library from utility object files
lib/libmyutils.a: obj/mystrfunctions.o obj/myfilefunctions.o
	mkdir -p lib
	ar rcs lib/libmyutils.a obj/mystrfunctions.o obj/myfilefunctions.o

# Step 3: Compile individual source files to object files
obj/mystrfunctions.o: src/mystrfunctions.c include/mystrfunctions.h
	mkdir -p obj
	gcc -Iinclude -c src/mystrfunctions.c -o obj/mystrfunctions.o

obj/myfilefunctions.o: src/myfilefunctions.c include/myfilefunctions.h
	mkdir -p obj
	gcc -Iinclude -c src/myfilefunctions.c -o obj/myfilefunctions.o

obj/main.o: src/main.c include/mystrfunctions.h include/myfilefunctions.h
	mkdir -p obj
	gcc -Iinclude -c src/main.c -o obj/main.o

# Step 4: Cleanup
clean:
	rm -rf obj/*.o lib/*.a bin/*

