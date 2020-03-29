%{
#include <stdio.h>
#include <stdlib.h>

extern int linenum;             /* declared in lex.l */
extern FILE *yyin;              /* declared by lex */
extern char *yytext;            /* declared by lex */
extern char buf[256];           /* declared in lex.l */
int yyerror(char* msg);
int yylex();

%}

%token SEMICOLON    /* ; */
%token LP RP	/* () */
%token COMMA	/* , */
%token LS RS	/* [] */
%token LC RC	/* {} */

%token ID           /* identifier */

%token READ WHILE DO IF TRUE FALSE FOR CONST INT PRINT BOOL 	/* keyword */
%token VOID FLOAT DOUBLE STRING CONTINUE BREAK RETURN	/* keyword */
%nonassoc ELSE

%right N EQUAL
%left OR AND 
%left SMALLER SE NE LE LARGER EE
%left PLUS MINUS 
%left MUL DIV MOD

%token STRING_LIT INT_NUM FLOAT_NUM SCIENTIFIC


%%
program : decl_and_def_list
  		;

decl_and_def_list : decl_and_def_list funct_decl
				  | decl_and_def_list funct_defi
				  | decl_and_def_list var_decl
				  | decl_and_def_list const_decl 
				  |
				  ;
/*
decl_list : decl_and_def_list funct_decl
		  | decl_and_def_list var_decl
		  | decl_and_def_list const_decl 
		  |
		  ;
*/

/*void main(){}   int main(){}*/
funct_defi : type ID LP argument_list RP compound
  		   | VOID ID LP argument_list RP compound
		   ;

statement : statement_integration
		  ;

statement_integration : compound
					  | simple
					  | conditional
					  | while
					  | for
					  | jump
					  ;

/*{...}*/
compound : LC compound_inside RC
		 ;

compound_inside : compound_inside var_decl
				| compound_inside const_decl
				| compound_inside statement
				|
				;
				
simple : simple_inside SEMICOLON
	   ;

simple_inside : var_ref EQUAL expr
			  | PRINT expr
			  | READ var_ref
			  | function_invocation
			  ;

expr : expr_integration
	 ;

expr_integration : expr OR expr
				 | expr AND expr
				 | expr SMALLER expr
				 | expr SE expr
				 | expr EE expr
				 | expr LE expr
				 | expr LARGER expr
				 | expr NE expr
				 | N expr
				 | expr PLUS expr
				 | expr MINUS expr
				 | expr MUL expr
				 | expr DIV expr
				 | expr MOD expr
				 | MINUS expr %prec MUL
				 | LP expr RP %prec MUL
				 | literal_const
				 | var_ref
				 | function_invocation
				 ;

/*call function*/
function_invocation : ID LP expr_list RP
					;

expr_list : many_expr
		  |
		  ;

many_expr : many_expr COMMA expr
		  | expr
		  ;

/*a[b+c]*/
var_ref : ID
		| array_ref
		;

array_ref : ID square_breackets
		  ;

square_breackets : square_breackets LS expr RS
				 | LS expr RS
				 ;

conditional : IF LP expr RP compound ELSE compound
			| IF LP expr RP compound
			;

while : WHILE LP expr RP compound
	  | DO compound WHILE LP expr RP SEMICOLON
	  ;

for : FOR LP for_expr SEMICOLON for_expr SEMICOLON for_expr RP compound
	;

for_expr : ID EQUAL expr
		 | expr
		 |
		 ;

jump : RETURN expr SEMICOLON
	 | BREAK SEMICOLON
	 | CONTINUE SEMICOLON
	 ;

const_decl : CONST type const_list SEMICOLON
		   ;

/*const int a=4*/
const_list : const_list COMMA const
		   | const
		   ;

const : ID EQUAL literal_const
	  ;

literal_const : literal_integration
			  ;

literal_integration : INT_NUM
				    | FLOAT_NUM
				    | SCIENTIFIC
				    | STRING_LIT
				    | TRUE
				    | FALSE
				    ;

/*int a=4,b=c+d,e[5],f[1]={1}*/
var_decl : type identifier_list SEMICOLON
         ;

type : type_integration
	 ;

type_integration : INT
				 | FLOAT
				 | DOUBLE
				 | STRING
				 | BOOL
			     ; 

/*a,b[5]*/
identifier_list : identifier_list COMMA identifier
				| identifier
				;

identifier : identifier_no_init
		   | identifier_init
	   	   ;

identifier_no_init : ID
				   | ID array
				   ;

identifier_init : ID EQUAL expr
				| ID array EQUAL LC expr_list RC
				;

/*[5][5][5]*/
array : array LS INT_NUM RS
	  | LS INT_NUM RS
	  ;

/*int main(int a);*/
funct_decl : type ID LP argument_list RP SEMICOLON
		   | VOID ID LP argument_list RP SEMICOLON
		   ;

/*use at function's parameters: can have many or zero parameters*/
argument_list : many_argument 
			  | 
			  ;

/*int i, float b*/
many_argument : many_argument COMMA type identifier_no_init
			  | type identifier_no_init
			  ;


%%

int yyerror( char *msg )
{
  fprintf( stderr, "\n|--------------------------------------------------------------------------\n" );
	fprintf( stderr, "| Error found in Line #%d: %s\n", linenum, buf );
	fprintf( stderr, "|\n" );
	fprintf( stderr, "| Unmatched token: %s\n", yytext );
  fprintf( stderr, "|--------------------------------------------------------------------------\n" );
  exit(-1);
}

int  main( int argc, char **argv )
{
	if( argc != 2 ) {
		fprintf(  stdout,  "Usage:  ./parser  [filename]\n"  );
		exit(0);
	}

	FILE *fp = fopen( argv[1], "r" );
	
	if( fp == NULL )  {
		fprintf( stdout, "Open  file  error\n" );
		exit(-1);
	}
	
	yyin = fp;
	yyparse();

	fprintf( stdout, "\n" );
	fprintf( stdout, "|--------------------------------|\n" );
	fprintf( stdout, "|  There is no syntactic error!  |\n" );
	fprintf( stdout, "|--------------------------------|\n" );
	exit(0);
}
