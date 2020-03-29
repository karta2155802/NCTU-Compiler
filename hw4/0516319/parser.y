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

program : {Create_SymbolTable();}decl_list funct_def decl_and_def_list {Print_SymbolTable(program.back());}
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
              if(!CheckFuncDecl($2, $1))
              {
                Create_Entry(0);
                SetEntry($2, "function", $1, type_list);
              }
              Create_FuncSymbolTable();
              func_type.push_back($1);
              GenFuncInitial($2, $1);
            }
            compound_statement
            {
              if(!HasDefi($2))
              {
                Print_SymbolTable(program.back());
              }
              else  {program.pop_back(); global_level--;}
              func_type.pop_back();
              if(ifreturn==0){printf("##########Error at Line #%2d: need return statement.##########\n", linenum);}
              else ifreturn=0;
            }
          | scalar_type ID L_PAREN parameter_list R_PAREN  
            {
              para_list = type_list;
              if(!CheckFuncDecl($2, $1))
              {                
                Create_Entry(0);
                SetEntry($2, "function", $1, type_list);
                type_list.clear();                
              }
              else type_list.clear();
              Create_FuncSymbolTable();
              func_type.push_back($1);
              GenFuncInitial($2, $1);
            }
            compound_statement
            {
              if(!HasDefi($2))
              {
                Print_SymbolTable(program.back());
              }
              else  {program.pop_back(); global_level--;}
              func_type.pop_back();
              if(ifreturn==0){printf("##########Error at Line #%2d: need return statement.##########\n", linenum);}
              else ifreturn=0;
            }
          | VOID ID L_PAREN R_PAREN 
            {
              if(!CheckFuncDecl($2, $1))
              {
                Create_Entry(0);
                SetEntry($2, "function", $1, type_list);
              }
              Create_FuncSymbolTable();
              func_type.push_back($1);
              GenFuncInitial($2, $1);
            }
            compound_statement
            {
              if(!HasDefi($2))
              {
                Print_SymbolTable(program.back());
              }
              else  {program.pop_back(); global_level--;}
              func_type.pop_back();
            }
          | VOID ID L_PAREN parameter_list R_PAREN 
            {
              para_list = type_list;
              if(!CheckFuncDecl($2, $1))
              {                
                Create_Entry(0);
                SetEntry($2, "function", $1, type_list);
                type_list.clear();
              }
              else type_list.clear();
              Create_FuncSymbolTable();
              func_type.push_back($1);
              GenFuncInitial($2, $1);
            }
            compound_statement
            {
              if(!HasDefi($2))
              {
                Print_SymbolTable(program.back());
              }
              else  {program.pop_back(); global_level--;}
              func_type.pop_back();
            }
          ;

funct_decl : scalar_type ID L_PAREN R_PAREN SEMICOLON
            {
              if(!FuncExist($2))
              {
                Create_Entry(0);
                SetEntry($2, "function", $1, type_list);
              }
            }
           | scalar_type ID L_PAREN parameter_list R_PAREN SEMICOLON
            {
              if(!FuncExist($2))
              {
                Create_Entry(0);
                SetEntry($2, "function", $1, type_list);
                type_list.clear();
              }
            }         
           | VOID ID L_PAREN R_PAREN SEMICOLON
            {
              if(!FuncExist($2))
              {
                Create_Entry(0);
                SetEntry($2, "function", $1, type_list);
              }
            }
           | VOID ID L_PAREN parameter_list R_PAREN SEMICOLON
            {
              if(!FuncExist($2))
              {
                Create_Entry(0);
                SetEntry($2, "function", $1, type_list);
                type_list.clear();
              }
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
            int entry_len = program.back().entry.size();
            for(int i=type_len;i>0;i--)
            {
              int j=entry_len-i;
              program.back().entry[j].name = type_list.front().var_name;
              program.back().entry[j].kind = "variable";
              
              if(program.back().entry[j].array == 1)
              {
                program.back().entry[j].type = type_list.front();
              }
              program.back().entry[j].type.name = $1;
              type_list.erase(type_list.begin());
            }
            CheckVarDeclType($1);
          }
         ;

identifier_list : identifier_list COMMA ID 
                  { 
                    if(!CheckExistVarName($3) && !CheckExistVarNameInList($3))
                    {
                      Create_Type_Var_Name($3); Create_Entry(0);
                    } 
                  }
                | identifier_list COMMA ID ASSIGN_OP logical_expression 
                  { 
                    if(!CheckExistVarName($3) && !CheckExistVarNameInList($3))
                    {
                      Create_Type_Var_Name($3); Create_Entry(0);
                    } 
                  }
                | identifier_list COMMA array_decl ASSIGN_OP initial_array 
                  { 
                    if(!CheckExistVarName($3) && !CheckExistArrayName($3) && CheckArrayInitialize())
                    {
                      Create_Entry(1); 
                    }
                    else type_list.pop_back();
                  }
                | identifier_list COMMA array_decl 
                  { 
                    if(!CheckExistVarName($3) && !CheckExistArrayName($3))
                    {
                      Create_Entry(1); 
                    }
                    else type_list.pop_back();
                  }
                | array_decl ASSIGN_OP initial_array
                  { 

                    if(!CheckExistVarName($1) && !CheckExistArrayName($1) && CheckArrayInitialize())
                    {
                      Create_Entry(1);

                    }
                    else type_list.pop_back();
                  }
                | array_decl 
                  { 
                    if(!CheckExistVarName($1) && !CheckExistArrayName($1))
                    {
                      Create_Entry(1); 
                    }
                    else type_list.pop_back();
                  }
                | ID ASSIGN_OP logical_expression 
                  { 
                    if(!CheckExistVarName($1) && !CheckExistVarNameInList($1))
                    {
                      Create_Type_Var_Name($1); Create_Entry(0);
                    } 
                  }
                | ID 
                  { 
                    if(!CheckExistVarName($1) && !CheckExistVarNameInList($1))
                    {
                      Create_Type_Var_Name($1); Create_Entry(0);
                    } 
                  }
                ;

initial_array : L_BRACE literal_list R_BRACE 
              ;

literal_list : literal_list COMMA logical_expression { array_size++; }
             | logical_expression { array_size++; }
             | 
             ;

const_decl : CONST scalar_type const_list SEMICOLON
            {
              int type_len = type_list.size();
              for(int i=type_len;i>0;i--)
              {
                int entry_len = program.back().entry.size();
                int j = entry_len-i;
                program.back().entry[j].name = type_list.front().var_name;
                type_list.erase(type_list.begin());
                program.back().entry[j].kind = "constant";
                program.back().entry[j].type.name = $2;
              }
              CheckVarDeclType($2);
            }
            ;

const_list : const_list COMMA ID ASSIGN_OP literal_const
              {
                if(!CheckExistVarName($3) && !CheckExistVarNameInList($3)){
                  Create_Type_Var_Name($3);
                  Create_Entry(0);
                  int entry_len = program.back().entry.size();
                  struct Type type;
                  type.name  = $5;
                  program.back().entry[entry_len-1].attribute.push_back(type);
                }
              }
            | ID ASSIGN_OP literal_const
              {
                if(!CheckExistVarName($1) && !CheckExistVarNameInList($1)){
                  Create_Type_Var_Name($1);
                  Create_Entry(0);
                  int entry_len = program.back().entry.size();
                  struct Type type;
                  type.name  = $3;
                  program.back().entry[entry_len-1].attribute.push_back(type);
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

compound_statement : L_BRACE var_const_stmt_list R_BRACE
                   ;

var_const_stmt_list : var_const_stmt_list statement 
                    | var_const_stmt_list var_decl
                    | var_const_stmt_list const_decl
                    |
                    ;

statement : {Create_SymbolTable();} compound_statement {Print_SymbolTable(program.back());}
          | simple_statement
          | conditional_statement
          | while_statement
          | for_statement
          | function_invoke_statement
          | jump_statement
          ;     

simple_statement : variable_reference ASSIGN_OP logical_expression SEMICOLON { SimpleStatementTypeCoercion(); }
                 | PRINT logical_expression SEMICOLON { return_list.clear(); }
                 | READ variable_reference SEMICOLON { return_list.clear(); }
                 ;

conditional_statement : IF L_PAREN logical_expression { BoolExpression(); }
                      R_PAREN L_BRACE { Create_SymbolTable(); } 
                      var_const_stmt_list R_BRACE { Print_SymbolTable(program.back()); }
                    | IF L_PAREN logical_expression { BoolExpression(); }
                      R_PAREN L_BRACE { Create_SymbolTable(); }
                      var_const_stmt_list R_BRACE { Print_SymbolTable(program.back()); }
                      ELSE L_BRACE { Create_SymbolTable(); }  
                      var_const_stmt_list R_BRACE { Print_SymbolTable(program.back()); }
                      ;

while_statement : WHILE L_PAREN logical_expression { BoolExpression(); }
                  R_PAREN L_BRACE { Create_SymbolTable(); loop++; } 
                  var_const_stmt_list R_BRACE { Print_SymbolTable(program.back()); loop--; }
                | DO L_BRACE { Create_SymbolTable(); loop++; } 
                  var_const_stmt_list R_BRACE { Print_SymbolTable(program.back()); loop--; } 
                  WHILE L_PAREN logical_expression { BoolExpression(); }
                  R_PAREN SEMICOLON
                ;

for_statement : FOR L_PAREN initial_expression_list SEMICOLON control_expression_list SEMICOLON increment_expression_list R_PAREN 
                    L_BRACE { Create_SymbolTable(); loop++; } 
                    var_const_stmt_list R_BRACE { Print_SymbolTable(program.back()); loop--; }
              ;

initial_expression_list : initial_expression
                        |
                        ;

initial_expression : initial_expression COMMA variable_reference ASSIGN_OP logical_expression { SimpleStatementTypeCoercion(); }
                   | initial_expression COMMA logical_expression { return_list.clear(); }
                   | logical_expression { return_list.clear(); }
                   | variable_reference ASSIGN_OP logical_expression { SimpleStatementTypeCoercion(); }

control_expression_list : control_expression
                        |
                        ;

control_expression : control_expression COMMA variable_reference ASSIGN_OP logical_expression { SimpleStatementTypeCoercion(); CheckControlExpression(); }
                   | control_expression COMMA logical_expression { CheckControlExpression(); }
                   | logical_expression { CheckControlExpression(); }
                   | variable_reference ASSIGN_OP logical_expression { SimpleStatementTypeCoercion(); CheckControlExpression(); }
                   ;

increment_expression_list : increment_expression 
                          |
                          ;

increment_expression : increment_expression COMMA variable_reference ASSIGN_OP logical_expression { SimpleStatementTypeCoercion(); }
                     | increment_expression COMMA logical_expression { return_list.clear(); }
                     | logical_expression { return_list.clear(); }
                     | variable_reference ASSIGN_OP logical_expression { SimpleStatementTypeCoercion(); }
                     ;

function_invoke_statement : ID L_PAREN logical_expression_list R_PAREN SEMICOLON { FuncInvoke($1); }
                          | ID L_PAREN R_PAREN SEMICOLON { FuncInvoke($1); }
                          ;

jump_statement : CONTINUE SEMICOLON { if(loop==0)printf("##########Error at Line #%2d: not in loop.##########\n", linenum); }
               | BREAK SEMICOLON { if(loop==0)printf("##########Error at Line #%2d: not in loop.##########\n", linenum); }
               | RETURN logical_expression SEMICOLON { 
                  CheckReturnType();
                  ifreturn=1;
                }
               ;

variable_reference : array_list
                   | ID { CheckVariableType($1); }
                   ;


logical_expression : logical_expression OR_OP logical_term { LogicalTypeCoercion(); }
                   | logical_term
                   ;

logical_term : logical_term AND_OP logical_factor { LogicalTypeCoercion(); }
             | logical_factor
             ;

logical_factor : NOT_OP logical_factor
                {
                  if(return_list.front().name != "bool")
                  {
                    printf("##########Error at Line #%2d: wrong type to do NOT_op.##########\n", linenum);
                    return_list.front().name = "bool";
                  }
                }
               | relation_expression
               ;

relation_expression : relation_expression relation_operator arithmetic_expression { RelationTypeCoercion(); }
                    | arithmetic_expression
                    ;

relation_operator : LT_OP
                  | LE_OP
                  | EQ_OP
                  | GE_OP
                  | GT_OP
                  | NE_OP
                  ;

arithmetic_expression : arithmetic_expression ADD_OP term { ArithmeticTypeCoercion(); }
                      | arithmetic_expression SUB_OP term { ArithmeticTypeCoercion(); }
                      | term
                      ;

term : term MUL_OP factor { ArithmeticTypeCoercion(); }
     | term DIV_OP factor { ArithmeticTypeCoercion(); }
     | term MOD_OP factor { CheckModOp; }
     | factor
     ;

factor : SUB_OP factor { SubType(); }
       | literal_const
       | variable_reference
       | L_PAREN logical_expression R_PAREN
       | ID L_PAREN logical_expression_list R_PAREN { FuncType($1); }
       | ID L_PAREN R_PAREN { FuncType($1); }
       ;

logical_expression_list : logical_expression_list COMMA logical_expression { return_list.pop_back(); }
                        | logical_expression { return_list.pop_back(); }
                        ;

array_list : ID dimension { CheckArrayType($1); }
           ;

dimension : dimension ML_BRACE logical_expression { return_list.pop_back(); } MR_BRACE { dim_size++; }
          | ML_BRACE logical_expression { return_list.pop_back(); } MR_BRACE { dim_size++;}
          ;



scalar_type : INT { $$ = $1; }
            | DOUBLE { $$ = $1; }
            | STRING { $$ = $1; }
            | BOOL { $$ = $1; }
            | FLOAT { $$ = $1; }
            ;
 
literal_const : INT_CONST { $$ = $1; Return.name = "int"; return_list.push_back(Return); }
              | FLOAT_CONST { $$ = $1; Return.name = "float"; return_list.push_back(Return); }
              | SCIENTIFIC { $$ = $1; Return.name = "double"; return_list.push_back(Return); }
              | STR_CONST { $$ = $1; Return.name = "string"; return_list.push_back(Return); }
              | TRUE { $$ = $1; Return.name = "bool"; return_list.push_back(Return); }
              | FALSE { $$ = $1; Return.name = "bool"; return_list.push_back(Return); }
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


