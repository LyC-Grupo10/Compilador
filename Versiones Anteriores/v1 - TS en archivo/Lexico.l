/*---- 1. Declaraciones ----*/
%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <math.h>
    #include <conio.h>
    #include "y.tab.h"
    int yycolumn = 1;
    #define YY_USER_ACTION  yylloc.first_line = yylloc.last_line = yylineno; \
                            yylloc.first_column = yycolumn; yylloc.last_column = yycolumn + yyleng -1; \
                            yycolumn += yyleng;

    void validarString(char[]);
    char valor[20];
    /*using namespace std;
    extern int yylex();*/ /*esto se queda esperando una cadena y la parsea, despues puede volar*/
%}

/*---- 2. Conjuntos y Regex ----*/

%option noyywrap
%option yylineno

DIGITO      [0-9]
LETRA       [a-zA-Z]
ESPACIO     [" "]
DOSPUNTOS   [":"]
COMA        [","]
PUNTOYCOMA  [";"]
CARACTER	[a-z,A-Z,0-9]
ESPECIALES  ["!","#", "$", "%", "&", "/", "?", "¿", "¡", "°", "|", "^", "~", ",", ";", ":", ".", "@",  "_", "-", "¨", "`", "*"]
TEXTO		\"({CARACTER}+|{ESPACIO}|{ESPECIALES})*\"
COMENTARIO  \*\*\*\/(.*?)\/\*\*\*

CONST_REAL      {DIGITO}*"."{DIGITO}*
CONST_INT       {DIGITO}+
ID              {LETRA}({LETRA}|{DIGITO}|_)*
OP_SUMA         ["+"]
OP_RESTA        ["-"]
OP_DIV          ["/"]
OP_MULT         ["*"]
OP_ASIG         ["="]
OP_AND          ["and"]
OP_OR           ["or"]
OP_NOT          ["not"]
COMP_BEQ        ["=="]
COMP_BNE        ["!="]
COMP_BLE        ["<="]
COMP_BLT        ["<"]
COMP_BGE        [">="]
COMP_BGT        [">"]
PAR_A           ["("]
PAR_C           [")"]
COR_A           ["["]
COR_C           ["]"]
LL_A            ["{"]
LL_C            ["}"]


/*---- 3. Definición de reglas ----*/

%%
"DEFVAR"        { return DEFVAR; }
"ENDDEF"        { return ENDDEF; }
"BEGINP"        { return BEGINP; }
"ENDP"          { return ENDP; }
"float"         { return FLOAT; }
"string"        { return STRING; }
"int"           { return INT; }
"while"         { return WHILE; }
"if"            { return IF; }
"else"          { return ELSE; }
"write"         { return WRITE; }
"="             { return OP_ASIG; }
":"             { return DOSPUNTOS; }
";"             { return PUNTOYCOMA; }
","             { return COMA; }

"+"				{ return OP_SUMA; }
"-"				{ return OP_RESTA; }
"*"				{return OP_MULT; }
"/"				{ return OP_DIV; }
"("             { return PAR_A; }
")"             { return PAR_C; }
"["             { return COR_A; }
"]"             { return COR_C; }
"{"             { return LL_A; }
"}"             { return LL_C; }
">"             { return COMP_BGT; }
">="            { return COMP_BGE; }
"<"             { return COMP_BLT; }
"<="            { return COMP_BLE; }
"=="            { return COMP_BEQ; }
"!="            { return COMP_BNE; }
"and"           { return OP_AND; }
"or"            { return OP_OR; }
"not"           { return OP_NOT; }

{COMENTARIO}    {yycolumn = 1;}

{ID}            {
                    yylval.tipo_str = yytext;
                    return ID;
                }	
{TEXTO}         {
                    yylval.tipo_str = yytext;
                    validarString(yylval.tipo_str);
                    insertarTS("", "CONST_STR", yylval.tipo_str, 0, 0);
                    return CONST_STR;
                }
{CONST_REAL}    {
                    yylval.tipo_double = atof(yytext);
                    /*validar*/
                    insertarTS("", "CONST_REAL", "--", 0, yylval.tipo_double);
                    return CONST_REAL;
                }
{CONST_INT}     {
                    yylval.tipo_int = atoi(yytext);
                    /*validar*/
                    insertarTS("", "CONST_INT", "--", yylval.tipo_int, 0);
                    return CONST_INT;
                }
                
\n            { printf("\n\t --- Nueva linea | columna: %d ---\n\n", yycolumn);
                yycolumn = 1; } /*resetear a 1 cada vez que haya una nueva linea*/
\t
%%


/*---- 4. Código ----*/
/*
int main(int argc, char *argv[])
{
    if((yyin = fopen(argv[1], "rt")) == NULL)
    {
        printf("\nNo se puede abrir el archivo: %s\n", argv[1]);
    }
    else
    {
        yylex();
    }
    fclose(yyin);
}*/

//Main para mandar desde consola (originalmente tiene que leer desde un archivo)
/*int main(int, char**) {
  // lex through the input:
  while (yylex());
}*/

void validarString(char cadena[])
{
    int largo = strlen(cadena);
    if(largo > 32)
    {
        yyerror("Error: Rango de string excedido. Se permite un maximo de 30 caracteres", 0, 0, 0);
    }
}

int yyerror(char *mensaje, int fila, int ci, int cf)
{
    if(fila == 0 || ci == 0 || cf == 0) /* || fila <= yylineno)*/
        printf("\nLinea %d: %s.\n", yylineno, mensaje);
    else
        printf("\nLinea %d, %d-%d: %s.\n", fila, ci, cf, mensaje);
    
    system("Pause");
    exit(1);
}





