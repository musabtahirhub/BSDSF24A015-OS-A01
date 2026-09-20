bin/client: obj/mystrfunctions.o obj/myfilefunctions.o obj/main.o
	mkdir -p bin
	gcc obj/mystrfunctions.o obj/myfilefunctions.o obj/main.o -o bin/client

obj/mystrfunctions.o: src/mystrfunctions.c
	mkdir -p obj
	gcc -Iinclude -c src/mystrfunctions.c -o obj/mystrfunctions.o

obj/myfilefunctions.o: src/myfilefunctions.c
	mkdir -p obj
	gcc -Iinclude -c src/myfilefunctions.c -o obj/myfilefunctions.o

obj/main.o: src/main.c
	mkdir -p obj
	gcc -Iinclude -c src/main.c -o obj/main.o

clean:
	rm -rf obj/*.o bin/client