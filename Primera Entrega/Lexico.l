/*---- 1. Declaraciones ----*/
%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <math.h>
    #include <conio.h>
    #include "y.tab.h"
    void validarString(char[]);
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
"write"         { return WRITE; }
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
"="             { return OP_ASIG; }
"and"           { return OP_AND; }
"or"            { return OP_OR; }
"not"           { return OP_NOT; }

"\n"
"\t"
"while"         { return WHILE; }
"if"            { return IF; }
"else"          { return ELSE; }
{TEXTO}         {
                    yylval.tipo_str = yytext;
                    validarString(yylval.tipo_str);
                    /*insertar el valor en la tabla de símbolos*/
                    return CONST_STR;
                }
{COMENTARIO}	
{CONST_REAL}    {
                    yylval.tipo_double = atof(yytext);
                    /*validar real, agregar a la tabla*/
                    return CONST_REAL;
                }
{CONST_INT}     {
                    yylval.tipo_int = atoi(yytext);
                    /*validar int, agregar a la tabla*/
                    return CONST_INT;
                }
{ID}            {
                    yylval.tipo_str = yytext;
                    return ID;
                }
%%


/*---- 4. Código ----*/

//Main para mandar desde consola (originalmente tiene que leer desde un archivo)
/*int main(int, char**) {
  // lex through the input:
  while (yylex());;
}*/

void validarString(char cadena[])
{
    int largo = strlen(cadena);
    if(largo > 32)
    {
        yyerror("\nRango de string excedido. Se permite un máximo de 30 caracteres.\n");
    }
}

int yyerror(char *s)
{
    printf("\nError: %s\nLinea: %d\n", s, yylineno);
    system("Pause");
    exit(1);
}