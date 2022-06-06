build: stack.c
	gcc -ansi -std=c99 -pedantic-errors -Wall -Wextra -g -O -c stack.c

test: test.c
	gcc -std=c99 -pedantic-errors -Wall -Wextra -g -o test stack.c test.c
	./test
	rm test 
	        
dslib: stack.o
	ar r dslib.a stack.o
        
clean:
	rm *.o 
                
