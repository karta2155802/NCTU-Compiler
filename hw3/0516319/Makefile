parser: parser.y lex.l
	yacc -d  parser.y
	lex lex.l
	g++  -o  parser  symboltable.h  main.cpp  lex.yy.c y.tab.c -ly -lfl
clean:	
	rm -f out.o
	rm -f y.tab.h
	rm -f y.tab.c