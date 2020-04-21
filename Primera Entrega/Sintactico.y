/*---- 1. Declaraciones ----*/

%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <conio.h>
#include "y.tab.h"
#define YYERROR_VERBOSE
FILE  *yyin;
%}

%union {
int tipo_int;
double tipo_double;
char *tipo_str;
}


/*---- 2. Tokens - Start ----*/

%start PROGRAMA
%token DEFVAR ENDDEF BEGINP ENDP
%token INT FLOAT STRING
%token IF ELSE WHILE
%token PUNTOYCOMA COMA DOSPUNTOS
%token OP_ASIG OP_SUMA OP_RESTA OP_MULT OP_DIV
%token PAR_A PAR_C COR_A COR_C LL_A LL_C
%token COMP_BEQ COMP_BNE COMP_BLT COMP_BLE COMP_BGT COMP_BGE
%token OP_AND OP_OR OP_NOT
%token WRITE
%token <tipo_str>ID
%token <tipo_int>CONST_INT
%token <tipo_double>CONST_REAL
%token <tipo_str>CONST_STR


/*---- 3. Definición de reglas gramaticales ----*/
%locations

%%

PROGRAMA:
        bloque_declaraciones algoritmo
        {printf("\nCompilacion OK.\n");}
        ;

bloque_declaraciones:
                    DEFVAR declaraciones ENDDEF {printf("\nTermina el bloque de declaraciones de variables.\n");}
                    ;

declaraciones:
            declaracion
            | declaraciones declaracion
            ;

declaracion:
            INT DOSPUNTOS lista_variables {printf("\nLeyendo la declaracion de un int.\n");}
            | STRING DOSPUNTOS lista_variables {printf("\nLeyendo la declaracion de un string.\n");}
            | FLOAT DOSPUNTOS lista_variables {printf("\nLeyendo la declaracion de un ifloat.\n");}
            ;

lista_variables:
                ID {$<tipo_str>$ = $1; printf("\nLeyo la variable <%s>", $<tipo_str>$);}
                | ID PUNTOYCOMA lista_variables
                ;

algoritmo:
            BEGINP bloque ENDP
            ;

bloque:
        sentencia
        | bloque sentencia
        ;

sentencia:
            asignacion
            | seleccion
            | iteracion
            | salida
            ;

salida:
        WRITE factor PUNTOYCOMA {printf("WRITE>>>\n");}
        ;

asignacion:
            ID OP_ASIG expresion PUNTOYCOMA {$<tipo_str>$ = $1; printf("\n---Se asigno la expresion a <%s> ---\n", $<tipo_str>$);}
            ;

seleccion:
            IF PAR_A condicion PAR_C LL_A sentencia LL_C {printf("IF\n");}
            | IF PAR_A condicion PAR_C LL_A sentencia LL_C ELSE LL_A sentencia LL_C {printf("IF-ELSE\n");}
            ;

iteracion: 
            WHILE PAR_A condicion PAR_C LL_A sentencia LL_C {printf("WHILE\n");}
            ;

condicion:
            comparacion
            | comparacion OP_AND comparacion {printf("AND\n");}
            | comparacion OP_OR comparacion {printf("OR\n");}
            | OP_NOT comparacion {printf("NOT\n");}
            ;

comparacion:
            expresion COMP_BEQ expresion {printf("<expresion> == <expresion>\n");}
            | expresion COMP_BLE expresion {printf("<expresion> <= <expresion>\n");}
            | expresion COMP_BGE expresion {printf("<expresion> >= <expresion>\n");}
            | expresion COMP_BGT expresion{printf("<expresion> > <expresion>\n");}
            | expresion COMP_BLT expresion{printf("<expresion> < <expresion>\n");}
            | expresion COMP_BNE expresion{printf("<expresion> != <expresion>\n");}
            ;

expresion:
            expresion OP_SUMA termino {printf("Suma OK\n");}
            | expresion OP_RESTA termino {printf("Resta OK\n");}
            | termino
            ;

termino:
        termino OP_MULT factor {printf("Multiplicacion OK\n");}
        | termino OP_DIV factor {printf("Division OK\n");}
        | factor
        ;

factor:
        ID { $<tipo_str>$ = strtok($1," +-*/[](){}:=,\n") ; printf("ID: %s\n", $<tipo_str>$);}
        | CONST_INT { $<tipo_int>$ = $1; printf("CTE entera: %d\n", $<tipo_int>$);}
        | CONST_REAL { $<tipo_double>$ = $1; printf("CTE real: %f\n", $<tipo_double>$);}
        | CONST_STR { $<tipo_str>$ = $1; printf("String: %s\n", $<tipo_str>$);}
        | PAR_A expresion PAR_C
        ;
%%


/*---- 4. Código ----*/

int main(int argc, char *argv[])
{
    if((yyin = fopen(argv[1], "rt"))==NULL)
    {
        printf("\nNo se puede abrir el archivo de prueba: %s\r\n", argv[1]);
        return -1;
    }
    /*printf("\n\nAbri el archivo, ahora voy a comenzar con el analisis.\n\n");*/
    yyparse();
    fclose(yyin);
    system("Pause"); /*Esta pausa la puse para ver lo que hace via mensajes*/
    return 0;
}
