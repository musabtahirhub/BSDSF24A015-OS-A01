# Step 1: Default target builds both static and dynamic clients
all: bin/client_static bin/client_dynamic

# Step 2: Build client linking dynamically against libmyutils.so
bin/client_dynamic: obj/main.o lib/libmyutils.so
	mkdir -p bin
	gcc obj/main.o -Llib -lmyutils -o bin/client_dynamic

# Step 3: Build dynamic shared library (.so)
lib/libmyutils.so: obj/mystrfunctions_pic.o obj/myfilefunctions_pic.o
	mkdir -p lib
	gcc -shared obj/mystrfunctions_pic.o obj/myfilefunctions_pic.o -o lib/libmyutils.so

# Compile PIC object files for dynamic library (-fPIC)
obj/mystrfunctions_pic.o: src/mystrfunctions.c include/mystrfunctions.h
	mkdir -p obj
	gcc -fPIC -Iinclude -c src/mystrfunctions.c -o obj/mystrfunctions_pic.o

obj/myfilefunctions_pic.o: src/myfilefunctions.c include/myfilefunctions.h
	mkdir -p obj
	gcc -fPIC -Iinclude -c src/myfilefunctions.c -o obj/myfilefunctions_pic.o

# Step 4: Build client linking statically against libmyutils.a
bin/client_static: obj/main.o lib/libmyutils.a
	mkdir -p bin
	gcc obj/main.o lib/libmyutils.a -o bin/client_static

# Build static library (.a)
lib/libmyutils.a: obj/mystrfunctions.o obj/myfilefunctions.o
	mkdir -p lib
	ar rcs lib/libmyutils.a obj/mystrfunctions.o obj/myfilefunctions.o

# Compile normal object files for static library and main
obj/mystrfunctions.o: src/mystrfunctions.c include/mystrfunctions.h
	mkdir -p obj
	gcc -Iinclude -c src/mystrfunctions.c -o obj/mystrfunctions.o

obj/myfilefunctions.o: src/myfilefunctions.c include/myfilefunctions.h
	mkdir -p obj
	gcc -Iinclude -c src/myfilefunctions.c -o obj/myfilefunctions.o

obj/main.o: src/main.c include/mystrfunctions.h include/myfilefunctions.h
	mkdir -p obj
	gcc -Iinclude -c src/main.c -o obj/main.o

# Clean up build artifacts
clean:
	rm -rf obj/*.o lib/*.a lib/*.so bin/*

