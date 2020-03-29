%{
#include <stdio.h>
#include <stdlib.h>
#include "symboltable.h"


extern int linenum;
extern FILE *yyin;
extern char *yytext;
extern char buf[256];

int yylex();
int yyerror( char *msg );

%}

%union  {
  int num;
  double dnum;
  char* str;
  struct Type* type;
  struct Value* value;
  struct Attribute* attribute;
  struct TypeList* typelist;
  struct Expr* expr;
  struct ExprList* exprlist;
}

%token  <str> ID
%token  <str> INT_CONST
%token  <str> FLOAT_CONST
%token  <str> SCIENTIFIC
%token  <str> STR_CONST

%token  <str> LE_OP
%token  <str> NE_OP
%token  <str> GE_OP
%token  <str> EQ_OP
%token  <str> AND_OP
%token  <str> OR_OP

%token  <str> READ
%token  <str> BOOLEAN
%token  <str> WHILE
%token  <str> DO
%token  <str> IF
%token  <str> ELSE
%token  <str> TRUE
%token  <str> FALSE
%token  <str> FOR
%token  <str> INT
%token  <str> PRINT
%token  <str> BOOL
%token  <str> VOID
%token  <str> FLOAT
%token  <str> DOUBLE
%token  <str> STRING
%token  <str> CONTINUE
%token  <str> BREAK
%token  <str> RETURN
%token  <str> CONST

%token  <str> L_PAREN
%token  <str> R_PAREN
%token  <str> COMMA
%token  <str> SEMICOLON
%token  <str> ML_BRACE
%token  <str> MR_BRACE
%token  <str> L_BRACE
%token  <str> R_BRACE
%token  <str> ADD_OP
%token  <str> SUB_OP
%token  <str> MUL_OP
%token  <str> DIV_OP
%token  <str> MOD_OP
%token  <str> ASSIGN_OP
%token  <str> LT_OP
%token  <str> GT_OP
%token  <str> NOT_OP

%type <str> scalar_type
%type <str> identifier_list
%type <str> array_decl
%type <str> dim
%type <str> literal_const

/*  Program 
    Function 
    Array 
    Const 
    IF 
    ELSE 
    RETURN 
    FOR 
    WHILE
*/
%start program
%%

program : {Create_SymbolTable();}decl_list funct_def decl_and_def_list {Print_SymbolTable(program.top());}
        ;

decl_list : decl_list var_decl
          | decl_list const_decl
          | decl_list funct_decl
          |
          ;


decl_and_def_list : decl_and_def_list var_decl
                  | decl_and_def_list const_decl
                  | decl_and_def_list funct_decl
                  | decl_and_def_list funct_def
                  | 
                  ;

funct_def : scalar_type ID L_PAREN R_PAREN 
            {
              if(!CheckExistFunc($2))
              {
                Create_Entry(0);
                int entry_len = program.top().entry.size();
                program.top().entry[entry_len-1].name = $2;
                program.top().entry[entry_len-1].kind = "function";
                program.top().entry[entry_len-1].type.name = $1;
              }
            }
            compound_statement
          | scalar_type ID L_PAREN parameter_list R_PAREN  
            {
              para_list = type_list;
              if(!CheckExistFunc($2))
              {                
                Create_Entry(0);
                int entry_len = program.top().entry.size();
                program.top().entry[entry_len-1].name = $2;
                program.top().entry[entry_len-1].kind = "function";
                program.top().entry[entry_len-1].type.name = $1;                             
                program.top().entry[entry_len-1].attribute = type_list;
                type_list.clear();                
              }
              else
              {
                type_list.clear();
              }
            }
            compound_statement
          | VOID ID L_PAREN R_PAREN 
            {
              if(!CheckExistFunc($2))
              {
                Create_Entry(0);
                int entry_len = program.top().entry.size();
                program.top().entry[entry_len-1].name = $2;
                program.top().entry[entry_len-1].kind = "function";
                program.top().entry[entry_len-1].type.name = "void";
              }
            }
            compound_statement
          | VOID ID L_PAREN parameter_list R_PAREN 
            {
              para_list = type_list;
              if(!CheckExistFunc($2))
              {                
                Create_Entry(0);
                int entry_len = program.top().entry.size();
                program.top().entry[entry_len-1].name = $2;
                program.top().entry[entry_len-1].kind = "function";
                program.top().entry[entry_len-1].type.name = $1;
                program.top().entry[entry_len-1].attribute = type_list;
                type_list.clear();
              }
              else
              {
                type_list.clear();
              }
            }
            compound_statement
          ;

funct_decl : scalar_type ID L_PAREN R_PAREN SEMICOLON
            {
              Create_Entry(0);
              int entry_len = program.top().entry.size();
              program.top().entry[entry_len-1].name = $2;
              program.top().entry[entry_len-1].kind = "function";
              program.top().entry[entry_len-1].type.name = $1;
            }
           | scalar_type ID L_PAREN parameter_list R_PAREN SEMICOLON
            {
              Create_Entry(0);
              int entry_len = program.top().entry.size();
              program.top().entry[entry_len-1].name = $2;
              program.top().entry[entry_len-1].kind = "function";
              program.top().entry[entry_len-1].type.name = $1;
              program.top().entry[entry_len-1].attribute = type_list;
              type_list.clear();
            }         
           | VOID ID L_PAREN R_PAREN SEMICOLON
            {
              Create_Entry(0);
              int entry_len = program.top().entry.size();
              program.top().entry[entry_len-1].name = $2;
              program.top().entry[entry_len-1].kind = "function";
              program.top().entry[entry_len-1].type.name = $1;
            }
           | VOID ID L_PAREN parameter_list R_PAREN SEMICOLON
            {
              Create_Entry(0);
              int entry_len = program.top().entry.size();
              program.top().entry[entry_len-1].name = $2;
              program.top().entry[entry_len-1].kind = "function";
              program.top().entry[entry_len-1].type.name = $1;
              program.top().entry[entry_len-1].attribute = type_list;
              type_list.clear();
            }
           ;

parameter_list : parameter_list COMMA scalar_type ID
               {
                  Create_Type_Var_Name($4);
                  type_list.back().name = $3;                  
               }
              | parameter_list COMMA scalar_type array_decl
               {
                type_list.back().name = $3;
               }
              | scalar_type array_decl
               {
                type_list.back().name = $1;
               }
              | scalar_type ID
               {
                Create_Type_Var_Name($2);
                type_list.back().name = $1;
               }
               ;

var_decl : scalar_type identifier_list SEMICOLON
          { 
            int type_len = type_list.size();
            int entry_len = program.top().entry.size();
            for(int i=type_len;i>0;i--)
            {
              int j=entry_len-i;
              program.top().entry[j].name = type_list.front().var_name;
              program.top().entry[j].kind = "variable";
              
              if(program.top().entry[j].array == 1)
              {
                program.top().entry[j].type = type_list.front();
              }
              program.top().entry[j].type.name = $1;
              type_list.erase(type_list.begin());
            }
          }
         ;

identifier_list : identifier_list COMMA ID 
                  { 
                    if(!CheckExist($3) && !CheckExistVarName($3))
                    {
                      Create_Type_Var_Name($3); Create_Entry(0);
                    } 
                  }
                | identifier_list COMMA ID ASSIGN_OP logical_expression 
                  { 
                    if(!CheckExist($3) && !CheckExistVarName($3))
                    {
                      Create_Type_Var_Name($3); Create_Entry(0);
                    } 
                  }
                | identifier_list COMMA array_decl ASSIGN_OP initial_array 
                  { 
                    if(!CheckExist($3) && !CheckExistArrayName($3))
                    {
                      Create_Entry(1); 
                    }
                    else type_list.erase(type_list.end()-1);
                  }
                | identifier_list COMMA array_decl 
                  { 
                    if(!CheckExist($3) && !CheckExistArrayName($3))
                    {
                      Create_Entry(1); 
                    }
                    else type_list.erase(type_list.end()-1);
                  }
                | array_decl ASSIGN_OP initial_array
                  { 
                    if(!CheckExist($1) && !CheckExistArrayName($1))
                    {
                      Create_Entry(1); 
                    }
                    else type_list.erase(type_list.end()-1);
                  }
                | array_decl 
                  { 
                    if(!CheckExist($1) && !CheckExistArrayName($1))
                    {
                      Create_Entry(1); 
                    }
                    else type_list.erase(type_list.end()-1);
                  }
                | ID ASSIGN_OP logical_expression 
                  { 
                    if(!CheckExist($1) && !CheckExistVarName($1))
                    {
                      Create_Type_Var_Name($1); Create_Entry(0);
                    } 
                  }
                | ID 
                  { 
                    if(!CheckExist($1) && !CheckExistVarName($1))
                    {
                      Create_Type_Var_Name($1); Create_Entry(0);
                    } 
                  }
                ;

initial_array : L_BRACE literal_list R_BRACE
              ;

literal_list : literal_list COMMA logical_expression
             | logical_expression
             | 
             ;

const_decl : CONST scalar_type const_list SEMICOLON
            {
              int type_len = type_list.size();
              for(int i=type_len;i>0;i--)
              {
                int entry_len = program.top().entry.size();
                int j = entry_len-i;
                program.top().entry[j].name = type_list.front().var_name;
                type_list.erase(type_list.begin());
                program.top().entry[j].kind = "constant";
                program.top().entry[j].type.name = $2;
              }
            }
            ;

const_list : const_list COMMA ID ASSIGN_OP literal_const
              {
                if(!CheckExist($3) && !CheckExistVarName($3)){
                  Create_Type_Var_Name($3);
                  Create_Entry(0);
                  int entry_len = program.top().entry.size();
                  struct Type type;
                  type.name  = $5;
                  program.top().entry[entry_len-1].attribute.push_back(type);
                }
              }
            | ID ASSIGN_OP literal_const
              {
                if(!CheckExist($1) && !CheckExistVarName($1)){
                  Create_Type_Var_Name($1);
                  Create_Entry(0);
                  int entry_len = program.top().entry.size();
                  struct Type type;
                  type.name  = $3;
                  program.top().entry[entry_len-1].attribute.push_back(type);
                }
              }
              
           ;

array_decl : ID dim {type_list.back().var_name = $1; $$ = $1;}
           ;

dim : dim ML_BRACE INT_CONST MR_BRACE 
      { 
        type_list.back().dimention.push_back($3); 
      }
    | ML_BRACE INT_CONST MR_BRACE 
      { 
        struct Type type;
        type.dimention.push_back($2);
        type_list.push_back(type);
      }
    ;

compound_statement : L_BRACE 
                    {     
                      
                      Create_SymbolTable();
                      int para_len = para_list.size();
                      for(int i=0;i<para_len;i++)
                      {
                        Create_Entry(0);
                        program.top().entry[program.top().entry.size()-1].type = para_list.front();
                        program.top().entry[program.top().entry.size()-1].name = para_list.front().var_name;
                        program.top().entry[program.top().entry.size()-1].kind = "parameter";
                        para_list.erase(para_list.begin());
                      }                      
                    }
                    var_const_stmt_list R_BRACE
                    {
                      Print_SymbolTable(program.top());
                    }
                   ;

var_const_stmt_list : var_const_stmt_list statement 
                    | var_const_stmt_list var_decl
                    | var_const_stmt_list const_decl
                    |
                    ;

statement : compound_statement
          | simple_statement
          | conditional_statement
          | while_statement
          | for_statement
          | function_invoke_statement
          | jump_statement
          ;     

simple_statement : variable_reference ASSIGN_OP logical_expression SEMICOLON
                 | PRINT logical_expression SEMICOLON
                 | READ variable_reference SEMICOLON
                 ;

conditional_statement : IF L_PAREN logical_expression R_PAREN L_BRACE { Create_SymbolTable(); } 
                      var_const_stmt_list R_BRACE { Print_SymbolTable(program.top()); }
                    | IF L_PAREN logical_expression R_PAREN L_BRACE { Create_SymbolTable(); }
                      var_const_stmt_list R_BRACE { Print_SymbolTable(program.top()); }
                      ELSE L_BRACE { Create_SymbolTable(); }  
                      var_const_stmt_list R_BRACE { Print_SymbolTable(program.top()); }
                      ;

while_statement : WHILE L_PAREN logical_expression R_PAREN L_BRACE { Create_SymbolTable(); } 
                  var_const_stmt_list R_BRACE { Print_SymbolTable(program.top()); }
                | DO L_BRACE { Create_SymbolTable(); } 
                    var_const_stmt_list R_BRACE { Print_SymbolTable(program.top()); } 
                  WHILE L_PAREN logical_expression R_PAREN SEMICOLON
                ;

for_statement : FOR L_PAREN initial_expression_list SEMICOLON control_expression_list SEMICOLON increment_expression_list R_PAREN 
                    L_BRACE { Create_SymbolTable(); } 
                    var_const_stmt_list R_BRACE { Print_SymbolTable(program.top()); }
              ;

initial_expression_list : initial_expression
                        |
                        ;

initial_expression : initial_expression COMMA variable_reference ASSIGN_OP logical_expression
                   | initial_expression COMMA logical_expression
                   | logical_expression
                   | variable_reference ASSIGN_OP logical_expression

control_expression_list : control_expression
                        |
                        ;

control_expression : control_expression COMMA variable_reference ASSIGN_OP logical_expression
                   | control_expression COMMA logical_expression
                   | logical_expression
                   | variable_reference ASSIGN_OP logical_expression
                   ;

increment_expression_list : increment_expression 
                          |
                          ;

increment_expression : increment_expression COMMA variable_reference ASSIGN_OP logical_expression
                     | increment_expression COMMA logical_expression
                     | logical_expression
                     | variable_reference ASSIGN_OP logical_expression
                     ;

function_invoke_statement : ID L_PAREN logical_expression_list R_PAREN SEMICOLON
                          | ID L_PAREN R_PAREN SEMICOLON
                          ;

jump_statement : CONTINUE SEMICOLON
               | BREAK SEMICOLON
               | RETURN logical_expression SEMICOLON
               ;

variable_reference : array_list
                   | ID
                   ;


logical_expression : logical_expression OR_OP logical_term
                   | logical_term
                   ;

logical_term : logical_term AND_OP logical_factor
             | logical_factor
             ;

logical_factor : NOT_OP logical_factor
               | relation_expression
               ;

relation_expression : relation_expression relation_operator arithmetic_expression
                    | arithmetic_expression
                    ;

relation_operator : LT_OP
                  | LE_OP
                  | EQ_OP
                  | GE_OP
                  | GT_OP
                  | NE_OP
                  ;

arithmetic_expression : arithmetic_expression ADD_OP term
                      | arithmetic_expression SUB_OP term
                      | term
                      ;

term : term MUL_OP factor
     | term DIV_OP factor
     | term MOD_OP factor
     | factor
     ;

factor : SUB_OP factor
       | literal_const
       | variable_reference
       | L_PAREN logical_expression R_PAREN
       | ID L_PAREN logical_expression_list R_PAREN
       | ID L_PAREN R_PAREN
       ;

logical_expression_list : logical_expression_list COMMA logical_expression
                        | logical_expression
                        ;

array_list : ID dimension
           ;

dimension : dimension ML_BRACE logical_expression MR_BRACE         
          | ML_BRACE logical_expression MR_BRACE
          ;



scalar_type : INT { $$ = $1; }
            | DOUBLE { $$ = $1; }
            | STRING { $$ = $1; }
            | BOOL { $$ = $1; }
            | FLOAT { $$ = $1; }
            ;
 
literal_const : INT_CONST { $$ = $1; }
              | FLOAT_CONST { $$ = $1; }
              | SCIENTIFIC { $$ = $1; }
              | STR_CONST { $$ = $1; }
              | TRUE { $$ = $1; }
              | FALSE { $$ = $1; }
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
    //  fprintf( stderr, "%s\t%d\t%s\t%s\n", "Error found in Line ", linenum, "next token: ", yytext );
}


