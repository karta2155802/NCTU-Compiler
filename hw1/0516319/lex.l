%{
#define LIST                { strncat(buf, yytext, sizeof(buf) - strlen(buf) - 1); }
#define token(t)            { LIST; if (Opt_Token) printf("<%s>\n", #t); }
#define tokenString(t, s)   { LIST; if (Opt_Token) printf("<%s:%s>\n", t, s); }
#define MAX_LINE_LENGTH 257
#define MAX_ID_LENGTH 257
int Opt_Source = 1;
int Opt_Token = 1;
int Opt_Statistic = 1;
int linenum = 1;
char buf[MAX_LINE_LENGTH];
char s[MAX_LINE_LENGTH];

struct table{
    char arr[MAX_ID_LENGTH];
    int freq;
    struct table* next;
};
struct table* head = NULL;
struct table* tail = NULL;
void create(char*);
void travel(char*);
void printfre();

%}

letter  [a-zA-Z_]
digit   [0-9]
float   [0-9]+\.[0-9]*
space   [ \t]+
delim   [,;\(\)\[\]\{\}]
KW  ("while"|"do"|"if"|"else"|"true"|"false"|"for"|"int"|"print"|"const"|"read"|"boolean"|"bool"|"void"|"float"|"double"|"string"|"continue"|"break"|"return")


%x COMMENT
%x STRING
%x PRAGMA
%x PRAGMACOMMENT
%%

"/*" {LIST; BEGIN COMMENT;}
<COMMENT>. {LIST;}
<COMMENT>"*/" {LIST;BEGIN 0;}
"//".* {LIST;printf(yytext);}
<COMMENT>\n {
    LIST;
    if (Opt_Source)
        printf("%d:%s\n", linenum, buf);
    ++linenum;
    buf[0] = '\0';
}


^"#pragma"{space}"source"{space}"on"{space}* {Opt_Source=1; LIST; BEGIN PRAGMA;}
^"#pragma"{space}"source"{space}"off"{space}* {Opt_Source=0; LIST; BEGIN PRAGMA;}
^"#pragma"{space}"token"{space}"on"{space}* {Opt_Token=1; LIST;BEGIN PRAGMA;}
^"#pragma"{space}"token"{space}"off"{space}* {Opt_Token=0; LIST;BEGIN PRAGMA;}
^"#pragma"{space}"statistic"{space}"on"{space}* {Opt_Statistic=1; LIST; BEGIN PRAGMA;}
^"#pragma"{space}"statistc"{space}"off"{space}* {Opt_Statistic=0; LIST; BEGIN PRAGMA;}
<PRAGMA>"/*" {LIST; BEGIN PRAGMACOMMENT;}
<PRAGMACOMMENT>. {LIST;}
<PRAGMACOMMENT>"*/" {LIST; BEGIN PRAGMA;}
<PRAGMACOMMENT>\n {
    LIST;
    if (Opt_Source)
        printf("%d:%s\n", linenum, buf);
    ++linenum;
    buf[0] = '\0';
}
<PRAGMA>"//".* {LIST;}
<PRAGMA>\n {
    LIST;
    if (Opt_Source)
        printf("%d:%s\n", linenum, buf);
    ++linenum;
    buf[0] = '\0';
    BEGIN 0;
}
<PRAGMA>\r {LIST;}


\" {
    LIST; 
    s[0] = '\0'; 
    BEGIN STRING;
}
<STRING>\\\" {
    LIST; 
    strncat(s, "\"", sizeof(buf) - strlen(buf) - 1) ;
}

<STRING>\\\\ {
    LIST; 
    strncat(s, "\\", sizeof(buf) - strlen(buf) - 1);
}
<STRING>\" {
    tokenString("string",s); 
    BEGIN 0;
}
<STRING>. {
    LIST; 
    strncat(s, yytext, sizeof(buf) - strlen(buf) - 1);
}
<STRING>\n {
    fprintf(stderr, "Error at line %d: %s\n", linenum, yytext);
    exit(1);
}

[,;\(\)\[\]\{\}] {tokenString("delim", yytext);}

{KW} {tokenString("KW", yytext);}

"+" {token("+");}
"-" {token("-");}
"*" {token("*");}
"/" {token("/");}
"%" {token("%");}
"=" {token("=");}
"<" {token("<");}
"<=" {token("<=");}
"==" {token("==");}
">=" {token(">=");}
">" {token(">");}
"!=" {token("!=");}
"&&" {token("&&");}
"||" {token("||");}
"!" {token("!");}

0|([1-9]{digit}*) {tokenString("integer",yytext);}
{digit}+\.{digit}+ {tokenString("float",yytext);}
({float}|{digit}*)[Ee][+-]?{digit}+ {tokenString("scientific",yytext);}
{letter}({digit}|{letter})* {
    tokenString("id",yytext);
    travel(yytext);
}


\r {LIST;}
\n {
    LIST;
    if (Opt_Source)
        printf("%d:%s\n", linenum, buf);
    ++linenum;
    buf[0] = '\0';
}
{space} {LIST;}


. { // Unrecognized character
    fprintf(stderr, "Error at line %d: %s\n", linenum, yytext);
    exit(1);
}
<PRAGMA>. { // Unrecognized character
    fprintf(stderr, "Error at line %d: %s\n", linenum, yytext);
    exit(1);
}


%%
void create(char* id){
    struct table* temp = (struct table*) malloc(sizeof(struct table));
    strcpy(temp->arr,id);
    temp->freq = 1;
    temp->next = NULL;
    if(tail != NULL){
        tail->next = temp;
        tail = temp;
    }
    else{
        head = temp;
        tail = temp;
    }
}

void travel(char* id){
    struct table* temp=head;
    if(temp == NULL){
        create(id);
        return ;
    }
    while(temp != NULL){
        if(strcmp(temp->arr,id) == 0){
            (temp->freq)++;
            return ;
        }
        else{
            temp = temp->next;
        }
    }
    create(id);
    return ;
}

void printfreq(){
    struct table* temp=head;
    while(temp != NULL){
        printf("%s\t%d\n",temp->arr,temp->freq);
        temp = temp->next;;
    }
}

int main( int argc, char **argv )
{
    if (argc >= 2)
    {
        yyin = fopen( argv[1], "r" );
        if ( NULL == yyin ) {
            fprintf( stderr, "Cannot open: %s\n", argv[1] );
            exit(-1);
        }
    }
    else
    {
        yyin = stdin;
    }

    yylex();

    if (Opt_Statistic)
    {
        printf("frequencies of identifiers:\n");
        printfreq();
    }
    exit(0);
}