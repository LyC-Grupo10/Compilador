/*---- 1. Declaraciones ----*/

%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <conio.h>
#include "y.tab.h"
#define YYERROR_VERBOSE 1
//#define parse.lac 1
FILE  *yyin;
/*extern char *yytext;
extern YYSTYPE yylval;*/


/* --- Tabla de simbolos --- */
//char headerTS[] = "NOMBRE           TIPO            VALOR           LONGITUD\n";
int insertarTS(char*, char*, char*, int, double);
char idvec[32][50];
int cantid = 0, i=0;
char vecAux[20];
char* punt;

/* --- Validaciones --- */
int existeID(char*);
char mensajes[100];

%}

%union {
int tipo_int;
double tipo_double;
char *tipo_str;
}

/*---- 2. Tokens - Start ----*/

%start PROGRAMA
%token DEFVAR "DEFVAR"
%token ENDDEF "ENDDEF"
%token BEGINP "BEGINP"
%token ENDP "ENDP"
%token INT "int"
%token FLOAT "float"
%token STRING "string"
%token IF "if"
%token ELSE "else"
%token WHILE "while"
%token PUNTOYCOMA ";"
%token COMA ","
%token DOSPUNTOS "."
%token OP_ASIG "="
%token OP_SUMA "+"
%token OP_RESTA "-"
%token OP_MULT "*"
%token OP_DIV "/"
%token PAR_A "("
%token PAR_C ")"
%token COR_A "["
%token COR_C "]"
%token LL_A "{"
%token LL_C "}"
%token COMP_BEQ "=="
%token COMP_BNE "!="
%token COMP_BLT "<"
%token COMP_BLE "<="
%token COMP_BGT ">"
%token COMP_BGE ">="
%token OP_AND "and" 
%token OP_OR "or"
%token OP_NOT "not"
%token WRITE "write"
%token <tipo_str>ID "ID"
%token <tipo_int>CONST_INT "constante entera"
%token <tipo_double>CONST_REAL "constante real"
%token <tipo_str>CONST_STR "constante string"


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

declaracion:/*loop para insertar en TS. Reinicio a cero para que la prox declaracion tome solos los que faltan*/
                /*agregamos que tire error si detecta que una variable ya fue declarada*/
             INT DOSPUNTOS lista_variables {
                                                for(i=0;i<cantid;i++) /*vamos agregando todos los ids que leyo*/
                                                {
                                                        if(insertarTS(idvec[i], "INT", "--", 0, 0) != 0) //no lo guarda porque ya existe
                                                        {
                                                                //printf("\nFila: <%d> Columna: <%d-%d>\n", @$.first_line, @$.first_column, @$.last_column);
                                                                sprintf(mensajes, "%s%s%s", "Error: la variable '", idvec[i], "' ya fue declarada");
                                                                yyerror(mensajes, @3.first_line, @3.first_column, @3.last_column);
                                                        }
                                                }
                                                cantid=0;
                                          } 
            | STRING DOSPUNTOS lista_variables {
                                                for(i=0;i<cantid;i++)
                                                {
                                                        if(insertarTS(idvec[i], "STRING", "--", 0, 0) != 0)
                                                        {
                                                                sprintf(mensajes, "%s%s%s", "Error: la variable '", idvec[i], "' ya fue declarada");
                                                                yyerror(mensajes, @3.first_line, @3.first_column, @3.last_column);
                                                        }
                                                } cantid=0;}
            | FLOAT DOSPUNTOS lista_variables {
                                                for(i=0;i<cantid;i++)
                                                {
                                                        if(insertarTS(idvec[i], "FLOAT", "--", 0, 0) != 0)
                                                        {
                                                                sprintf(mensajes, "%s%s%s", "Error: la variable '", idvec[i], "' ya fue declarada");
                                                                yyerror(mensajes, @3.first_line, @3.first_column, @3.last_column);
                                                        }
                                                } cantid=0;}
            ;

lista_variables:
                ID {
                    strcpy(vecAux, yylval.tipo_str); /*tomamos el nombre de la variable*/
                    punt = strtok(vecAux, " ;\n"); /*eliminamos extras*/
                    strcpy(idvec[cantid], punt); /*copiamos al array de ids*/
                    cantid++;
                    }
                | ID
                        {
                        strcpy(vecAux, yylval.tipo_str); /*se repite aca tambien, no lo toma de arriba*/
                        punt = strtok(vecAux, " ;\n");
                        strcpy(idvec[cantid], punt);
                        cantid++;
                        } 
                PUNTOYCOMA lista_variables
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
       /* | WRITE factor {yyerror("Error: se esperaba ';'", @$.first_line, @$.first_column, @$.last_column);}*/
       ;

asignacion:
            ID OP_ASIG expresion PUNTOYCOMA {
                                                //$<tipo_str>$ = $1; printf("\n---Se asigno la expresion a <%s> ---\n", $<tipo_str>$);

                                                strcpy(vecAux, $1); /*en $1 esta el valor de ID*/
                                                punt = strtok(vecAux," +-*/[](){}:=,\n"); /*porque puede venir de cualquier lado, pero ver si funciona solo con el =*/
                                                if(existeID(punt) != 0) /*No existe: entonces no esta declarada*/
                                                {
                                                        sprintf(mensajes, "%s%s%s", "Error: no se declaro la variable '", punt, "'");
                                                        yyerror(mensajes, @1.first_line, @1.first_column, @1.last_column);
                                                }
                                        }
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

factor:/*verificando aca en este ID si existe o no, se cubre en todas las apariciones en el codigo fuente????*/
        ID {
                strcpy(vecAux, $1);
                punt = strtok(vecAux," +-*/[](){}:=,\n"); /*porque puede venir de cualquier lado*/
                printf("\n\t --- Encontre este Id para verificar si existe: <%s> --- \n", punt);
                if(existeID(punt) != 0) /*No existe: entonces no esta declarada --> error*/
                {
                        sprintf(mensajes, "%s%s%s", "Error: no se declaro la variable '", punt, "'");
                        yyerror(mensajes, @1.first_line, @1.first_column, @1.last_column);
                }
           }
        | CONST_INT { $<tipo_int>$ = $1; printf("CTE entera: %d\n", $<tipo_int>$);}
        | CONST_REAL { $<tipo_double>$ = $1; printf("CTE real: %f\n", $<tipo_double>$);}
        | CONST_STR { $<tipo_str>$ = $1; printf("String: %s\n", $<tipo_str>$);}
        | PAR_A expresion PAR_C
        ;
%%


/*---- 4. Código ----*/

int main(int argc, char *argv[])
{
    FILE* archTS;
    
    if((yyin = fopen(argv[1], "rt"))==NULL)
    {
        printf("\nNo se puede abrir el archivo de prueba: %s\r\n", argv[1]);
        return -1;
    }
    else
    { 
        if((archTS = fopen("ts.txt", "wt"))==NULL)
        {
                printf("\nNo se pudo crear la tabla de simbolos.\n\n");
                return -2;
        }
        else
        {
                fprintf(archTS, "%-30s%-30s%-30s%-30s\n", "NOMBRE", "TIPODATO", "VALOR", "LONGITUD");
                fclose(archTS);
        }
        yyparse();
        fclose(yyin);
    }
    system("Pause"); /*Esta pausa la puse para ver lo que hace via mensajes*/
    return 0;
}

int insertarTS(char* nombre, char* tipo, char* valString, int valInt, double valDouble)
{
        //nombre es lexema
        //Formato de columna: Nombre - TipoDato - Valor - Longitud
        FILE* arch = fopen("ts.txt", "a");
        char valor[20];
        char cadena[30];
        char full[32] = "_";
        int ret=1;

        //Es una variable
        if(strcmp(tipo, "STRING")==0 || strcmp(tipo, "INT")==0 || strcmp(tipo, "FLOAT")==0)
        {
                if(existeID(nombre) !=0)
                {
                        fprintf(arch, "%-30s%-30s%-30s%-2d\n", nombre, tipo, "--", strlen(nombre));
                        ret=0;
                }
        }
        else
        {      //Son constantes: tenemos que agregarlos a la tabla con "_" al comienzo del nombre, hay que agregarle el valor
                if(strcmp(tipo, "CONST_STR") == 0)
                {
                        if(existeID(strcat(full, valString)) != 0)
                        {
                                fprintf(arch, "%-30s%-30s%-30s%-2d\n", full, tipo, valString, strlen(full)-1);
                                ret=0;
                        }
                }
                if(strcmp(tipo, "CONST_REAL") == 0)
                {
                        sprintf(valor, "%.5f", valDouble);
                        if(existeID(strcat(full, valor)) != 0)
                        {
                                fprintf(arch, "%-30s%-30s%-30s%-2d\n", full, tipo, valDouble, strlen(full)-1);
                                ret=0;
                        }
                }
                if(strcmp(tipo, "CONST_INT") == 0)
                {
                        sprintf(valor, "%d", valInt);
                        if(existeID(strcat(full, valor)) != 0)
                        {
                                fprintf(arch, "%-30s%-30s%-30s%-2d\n", full, tipo, valor, strlen(full)-1);
                                ret=0;
                        }
                }
        }

        fclose(arch);
        return ret; //para saber si lo agrego a la tabla o no
}

int existeID(char* id) //y hasta diria que es igual para existeCTE
{
        FILE* arch = fopen("ts.txt", "rt");
        char linea[100];
        char nombre[30]; //max 30 caracteres
        char* aux;

        fgets(linea, sizeof(linea), arch);
        while(fgets(linea, sizeof(linea), arch) != NULL)
        {
                aux = strchr(linea, '\n'); //me voy al final
                aux -= 62; /*le resto la cantidad de caracteres para pararme sobre lo que quiero*/
                /*Teniendo en cuenta esto : %-30s%-30s%-30s%-2d  tengo que restarle 62*/
                *aux = '\0'; //lo clavo aca
                aux -= 30; //me voy al principio
                strcpy(nombre, aux);
                strtok(nombre, " "); //no necesariamente son 30 caracteres de nombre, esto rellena con espacios
                
                if(strcmp(nombre, id) == 0) //existe
                {
                        fclose(arch);
                        return 0;
                }
        }
        //no lo encontro
        fclose(arch);
        return 1;
}
