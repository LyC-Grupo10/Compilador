/*---- 1. Declaraciones ----*/

%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>
#include <conio.h>
#include "y.tab.h"
#define YYERROR_VERBOSE 1
FILE  *yyin;


/* --- Tabla de simbolos --- */
typedef struct
{
        char *nombre;
        char *nombreASM;
        char *tipo;
        union Valor{
                int valor_int;
                double valor_double;
                char *valor_str;
        }valor;
        int longitud;
}t_data;

typedef struct s_simbolo
{
        t_data data;
        struct s_simbolo *next;
}t_simbolo;

typedef struct
{
        t_simbolo *primero;
}t_tabla;

void crearTablaTS();
int insertarTS(const char*, const char*, const char*, int, double);
t_data* crearDatos(const char*, const char*, const char*, int, double);
void guardarTS();
t_simbolo * getLexema(const char *);
char* limpiarString(char*, const char*);
char* reemplazarChar(char*, const char*, const char, const char);
char* reemplazarString(char*, const char*);
t_tabla tablaTS;

char idvec[32][50];
int cantid = 0, i=0, contadorString = 0;
char vecAux[20], vecAsignacion[30][50];
char* punt;

/* --- Validaciones --- */
int existeID(const char*);
int esNumero(const char*, char*);
void guardarAsignacion(const char*);
void guardarAsignacionInt(const int);
void guardarAsignacionDouble(const double);
bool verificarAsignacion(const char*);
bool verificarComparacion();
bool esCompatible(const char*, const char*);
int esAsig = 0, esComp = 0, topeAsignacion = -1;
char mensajes[100];

/* ---  Polaca   --- */
char vecPolaca[500][50], auxBet[50];
int pilaPolaca[50];
int posActual=0,topePila=-1;

char* insertarPolaca(char *);
void insertarPolacaInt(int);
void insertarPolacaDouble(double);
void avanzarPolaca();
void grabarPolaca();
void guardarPos();
int pedirPos();
void imprimirPolaca();
void escribirPosicionEnTodaLaPila(int, int);
char * insertarPolacaEnPosicion(const int, const int);
int local = -1, delta = 0, hayOr = 0;
int vecif[50];
void notCondicion(int);
void calcularFactorial(char *, char *);

/* --- Assembler --- */
int vectorEtiquetas[50], topeVectorEtiquetas = -1;
void generarAssembler();
void guardarPosicionDeEtiqueta(const char *);
bool esPosicionDeEtiqueta(int);
bool esEtiquetaWhile(const char *);
void crearHeader(FILE *);
void crearSeccionData(FILE *);
void crearSeccionCode(FILE *);
void crearFooter(FILE *);
bool esValor(const char *);
bool esComparacion(const char *);
bool esSalto(const char *);
char * getSalto(const char *);
bool esGet( char * str );
bool esDisplay(const char * str);
bool esAsignacion( char * str );
bool esOperacion(const char *);
char * getOperacion(const char *);
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
%token DOSPUNTOS ":"
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
%token DISPLAY "display"
%token GET "get"
%token <tipo_str>ID "identificador"
%token <tipo_int>CONST_INT "constante entera"
%token <tipo_double>CONST_REAL "constante real"
%token <tipo_str>CONST_STR "constante string"
%token FACT "fact"
%token COMB "comb"
%token BETWEEN "between"


/*---- 3. Definición de reglas gramaticales ----*/
%locations

%%

PROGRAMA:
        bloque_declaraciones algoritmo
        { grabarPolaca(); generarAssembler(); guardarTS(); printf("\nCompilacion OK! Ver archivo Final.asm\n\n"); }
        ;

bloque_declaraciones:
                    DEFVAR declaraciones ENDDEF
                    ;

declaraciones:
            declaracion
            | declaraciones declaracion
            ;

declaracion:
             INT DOSPUNTOS lista_variables  {
                                                for(i=0; i<cantid; i++)
                                                {
                                                    if(insertarTS(idvec[i], "INT", "", 0, 0) != 0)
                                                    {
                                                        sprintf(mensajes, "%s%s%s", "Error: la variable '", idvec[i], "' ya fue declarada");
                                                        yyerror(mensajes, @3.first_line, @3.first_column, @3.last_column);
                                                    }
                                                }
                                                cantid = 0;
                                            } 
            | STRING DOSPUNTOS lista_variables  {
                                                    for(i=0; i<cantid; i++)
                                                    {
                                                        if(insertarTS(idvec[i], "STRING", "", 0, 0) != 0)
                                                        {
                                                            sprintf(mensajes, "%s%s%s", "Error: la variable '", idvec[i], "' ya fue declarada");
                                                            yyerror(mensajes, @3.first_line, @3.first_column, @3.last_column);
                                                        }
                                                    } cantid = 0;
                                                }
            | FLOAT DOSPUNTOS lista_variables   {
                                                    for(i=0; i<cantid; i++)
                                                    {
                                                        if(insertarTS(idvec[i], "FLOAT", "", 0, 0) != 0)
                                                        {
                                                            sprintf(mensajes, "%s%s%s", "Error: la variable '", idvec[i], "' ya fue declarada");
                                                            yyerror(mensajes, @3.first_line, @3.first_column, @3.last_column);
                                                        }
                                                    } cantid = 0;
                                                }
            ;

lista_variables:
                ID  {
                        strcpy(vecAux, yylval.tipo_str); /*tomamos el nombre de la variable*/
                        punt = strtok(vecAux, " ;\n"); /*eliminamos extras*/
                        strcpy(idvec[cantid], punt); /*copiamos al array de ids*/
                        cantid++;
                    }
                | ID {
                        strcpy(vecAux, yylval.tipo_str); /*se repite por cada vez que se usa un No Terminal*/
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
            | { local++; esComp = 1;} seleccion 
            | { local++; esComp = 1;} iteracion
            | salida
            | entrada
            ;

salida:
        DISPLAY CONST_STR PUNTOYCOMA {                                     
                                        strcpy(vecAux, $2);
                                        strtok(vecAux,";\n");
                                        insertarPolaca("DISPLAY");
                                        insertarPolaca(vecAux);
                                     }
        | DISPLAY ID PUNTOYCOMA {
                                    char error[50];                                   
                                    strcpy(vecAux, $2);
                                    punt = strtok(vecAux," ;\n");
                                    if(!esNumero(punt, error)) {
                                        sprintf(mensajes, "%s", error);
                                        yyerror(mensajes, @1.first_line, @1.first_column, @1.last_column);
                                    }
                                    insertarPolaca("DISPLAY");
                                    insertarPolaca(vecAux);                               
                                }
        ;

entrada:
        GET ID PUNTOYCOMA { 
                            strcpy(vecAux, $2);
                            punt = strtok(vecAux," ;\n");
                            if(!existeID(punt)) {
                                sprintf(mensajes, "%s%s%s", "Error: no se declaro la variable '", punt, "'");
                                yyerror(mensajes, @1.first_line, @1.first_column, @1.last_column);
                            }
                            insertarPolaca("GET");
                            insertarPolaca(vecAux);
                        }
        ;        

asignacion:
            ID OP_ASIG { esAsig = 1; } expresion PUNTOYCOMA {
                                                strcpy(vecAux, $1); /*en $1 esta el valor de ID*/
                                                punt = strtok(vecAux," +-*/[](){}:=,\n");
                                                if(!existeID(punt))
                                                {
                                                    sprintf(mensajes, "%s%s%s", "Error: no se declaro la variable '", punt, "'");
                                                    yyerror(mensajes, @1.first_line, @1.first_column, @1.last_column);
                                                }
                                                //Verifica que los tipos de datos sean compatibles
                                                if(!verificarAsignacion(punt))
                                                {
                                                    sprintf(mensajes, "%s", "Error: se hacen asignaciones de distinto tipo de datos");
                                                    yyerror(mensajes, @1.first_line, @1.first_column, @5.last_column);
                                                }
                                                insertarPolaca("=");
                                                insertarPolaca(punt);
                                                esAsig = 0; topeAsignacion = -1;
                                            }
            ;

// Se usa un delta para saber cuántas comparaciones hay y a cuántas celdas se debe asignar el valor que indica dónde branchear.
// Este delta se guarda en el vector de condiciones, la posición dentro del mismo es determinada x la variable "local".
seleccion: 
            IF PAR_A condicion PAR_C LL_A bloque LL_C { escribirPosicionEnTodaLaPila(vecif[local], posActual); local--; }
            | IF PAR_A condicion PAR_C LL_A bloque LL_C
            ELSE { insertarPolaca("BI");
                    escribirPosicionEnTodaLaPila(vecif[local], posActual +1);
                    local--; //decrementa local porque ese bloque if ya terminó
                    guardarPos(); 
            }
            LL_A bloque LL_C { insertarPolacaEnPosicion(pedirPos(), posActual); }
            ;

iteracion: 
            WHILE { insertarPolaca("ET"); posActual--; guardarPos(); } 
            PAR_A condicion PAR_C LL_A bloque LL_C {
                insertarPolaca("BI");
                escribirPosicionEnTodaLaPila(vecif[local], posActual +1);
                local--; //decrementa local porque ese bloque while ya terminó
                insertarPolacaInt(pedirPos());
            }
            ;

//Acá guardamos el delta correspondiente a cada if/while, para que no se pisen ni usen los deltas de otro.
condicion:
            comparacion { vecif[local] = delta; delta=0; }
            | comparacion OP_AND comparacion { vecif[local] = delta; delta=0; }
            | comparacion {     //cuando ya lee la primera comparacion, avisamos que se trata de un OR
                                hayOr=1;
                                delta--; //decrementamos porque ya vamos a trabajar con esa celda ahora, no hace falta que lo haga arriba
                                vecif[local] = delta;
                                notCondicion(delta); //invierto el condicional: el salto va a ser adentro del bloque en lugar de al final
            } OP_OR comparacion { vecif[local] = delta; delta=0; }
            | OP_NOT comparacion { vecif[local] = delta; notCondicion(delta); delta=0;}
            | PAR_A comparacion PAR_C OP_AND PAR_A comparacion PAR_C { vecif[local] = delta; delta=0; }
            | PAR_A comparacion PAR_C {
                                        hayOr=1;
                                        delta--;
                                        vecif[local] = delta;
                                        notCondicion(delta);
            }           
            OP_OR PAR_A comparacion PAR_C { vecif[local] = delta; delta=0; }
            | OP_NOT PAR_A comparacion PAR_C { vecif[local] = delta; notCondicion(delta); delta=0;}
            ;

//Acá vemos si es un or, en tal caso, se setea a la comparación anterior la celda a la que tiene que saltar para ir al bloque true.
comparacion: 
            expresionNumerica COMP_BEQ { insertarPolaca("CMP"); } expresionNumerica
            {
                if(!verificarComparacion())
                {
                    sprintf(mensajes, "%s", "Error: se hacen comparaciones con distintos tipos de datos");
                    yyerror(mensajes, @1.first_line, @1.first_column, @4.last_column);
                }
                esComp = 0; topeAsignacion = -1;
                insertarPolaca("BNE"); if(hayOr){insertarPolacaEnPosicion(pedirPos(), posActual +1); hayOr=0;} guardarPos(); delta++;}
            | expresionNumerica COMP_BLE { insertarPolaca("CMP"); } expresionNumerica
            {
                if(!verificarComparacion())
                {
                    sprintf(mensajes, "%s", "Error: se hacen comparaciones con distintos tipos de datos");
                    yyerror(mensajes, @1.first_line, @1.first_column, @4.last_column);
                }
                esComp = 0; topeAsignacion = -1;
                insertarPolaca("BGT"); if(hayOr){insertarPolacaEnPosicion(pedirPos(), posActual +1); hayOr=0;} guardarPos(); delta++;}

            | expresionNumerica COMP_BGE { insertarPolaca("CMP"); } expresionNumerica
            {
                if(!verificarComparacion())
                {
                    sprintf(mensajes, "%s", "Error: se hacen comparaciones con distintos tipos de datos");
                    yyerror(mensajes, @1.first_line, @1.first_column, @4.last_column);
                }
                esComp = 0; topeAsignacion = -1;
                insertarPolaca("BLT"); if(hayOr){insertarPolacaEnPosicion(pedirPos(), posActual +1); hayOr=0;} guardarPos(); delta++;}

            | expresionNumerica COMP_BGT { insertarPolaca("CMP"); } expresionNumerica
            {
                if(!verificarComparacion())
                {
                    sprintf(mensajes, "%s", "Error: se hacen comparaciones con distintos tipos de datos");
                    yyerror(mensajes, @1.first_line, @1.first_column, @4.last_column);
                }
                esComp = 0; topeAsignacion = -1;
                insertarPolaca("BLE"); if(hayOr){insertarPolacaEnPosicion(pedirPos(), posActual +1); hayOr=0;} guardarPos(); delta++;}

            | expresionNumerica COMP_BLT { insertarPolaca("CMP"); } expresionNumerica
            {
                if(!verificarComparacion())
                {
                    sprintf(mensajes, "%s", "Error: se hacen comparaciones con distintos tipos de datos");
                    yyerror(mensajes, @1.first_line, @1.first_column, @4.last_column);
                }
                esComp = 0; topeAsignacion = -1;
                insertarPolaca("BGE"); if(hayOr){insertarPolacaEnPosicion(pedirPos(), posActual +1); hayOr=0;} guardarPos(); delta++;}

            | expresionNumerica COMP_BNE { insertarPolaca("CMP"); } expresionNumerica
            {
                if(!verificarComparacion())
                {
                    sprintf(mensajes, "%s", "Error: se hacen comparaciones con distintos tipos de datos");
                    yyerror(mensajes, @1.first_line, @1.first_column, @4.last_column);
                }
                esComp = 0; topeAsignacion = -1;
                insertarPolaca("BEQ"); if(hayOr){insertarPolacaEnPosicion(pedirPos(), posActual +1); hayOr=0;} guardarPos(); delta++;}

            | between {
                if(!verificarComparacion())
                {
                    sprintf(mensajes, "%s", "Error: se hacen comparaciones con distintos tipos de datos");
                    yyerror(mensajes, @1.first_line, @1.first_column, @1.last_column);
                }
                esComp = 0; topeAsignacion = -1;
                delta += 2;} //aca suma de a dos porque between tiene dos comparaciones
            ;

expresion:
            expresion OP_SUMA termino { insertarPolaca("+"); }
            | expresion OP_RESTA termino { insertarPolaca("-"); }
            | termino
            ;

termino:
        termino OP_MULT factor { insertarPolaca("*"); }
        | termino OP_DIV factor { insertarPolaca("/"); }
        | factor
        ;

factor:
        ID {
                strcpy(vecAux, $1);
                punt = strtok(vecAux," +-*/[](){}:=,\n");
                if(!existeID(punt))
                {
                    sprintf(mensajes, "%s%s%s", "Error: no se declaro la variable '", punt, "'");
                    yyerror(mensajes, @1.first_line, @1.first_column, @1.last_column);
                }
                if(esAsig == 1)
                    guardarAsignacion(punt);
                
                insertarPolaca(punt);
           }
        | CONST_INT { $<tipo_int>$ = $1; if(esAsig == 1){guardarAsignacionInt($<tipo_int>$);} insertarPolacaInt($<tipo_int>$);}
        | CONST_REAL { $<tipo_double>$ = $1; if(esAsig == 1){guardarAsignacionDouble($<tipo_double>$);} insertarPolacaDouble($<tipo_double>$);}
        | CONST_STR { $<tipo_str>$ = $1; if(esAsig == 1){guardarAsignacion($<tipo_str>$);} insertarPolaca($<tipo_str>$);}
        | PAR_A expresion PAR_C
        | combinatorio
        | factorial
        ;

        
combinatorio:
        COMB PAR_A expresionNumerica { insertarPolaca("="); insertarPolaca("@varN"); } 
        COMA expresionNumerica 	{ insertarPolaca("="); insertarPolaca("@varM"); } PAR_C {
            calcularFactorial("@varN","@resN");
            calcularFactorial("@varM","@resM");
            insertarPolaca("@varN");
            insertarPolaca("@varM");
            insertarPolaca("-");
            calcularFactorial("@varNM","@resNM");
            insertarPolaca("@resN");
            insertarPolaca("@resM");
            insertarPolaca("/");
            insertarPolaca("@resNM");
            insertarPolaca("/");
        }
        ;

factorial:
        FACT PAR_A expresionNumerica PAR_C {           
            calcularFactorial("@varFact","@resFact");
            insertarPolaca("@resFact");
        }
        ;

between:
        BETWEEN PAR_A ID {
                            char error[50];
                            strcpy(vecAux, $3);
                            punt = strtok(vecAux," ;\n");
                            if(!esNumero(punt, error))
                            {
                                sprintf(mensajes, "%s", error);
                                yyerror(mensajes, @1.first_line, @1.first_column, @1.last_column);
                            }
                            strcpy(auxBet, insertarPolaca(punt));
                            if(esComp == 1)
                                guardarAsignacion(punt);
                        }
        COMA COR_A expresionNumerica { insertarPolaca("CMP"); insertarPolaca("BLT"); guardarPos(); }
        PUNTOYCOMA { insertarPolaca(auxBet); }
        expresionNumerica { insertarPolaca("CMP"); insertarPolaca("BGT"); guardarPos(); }
        COR_C PAR_C
        ; 

expresionNumerica:
            expresionNumerica OP_SUMA terminoNumerico {insertarPolaca("+");}
            | expresionNumerica OP_RESTA terminoNumerico {insertarPolaca("-");}
            | terminoNumerico
            ;

terminoNumerico:
        terminoNumerico OP_MULT factorNumerico {insertarPolaca("*");}
        | terminoNumerico OP_DIV factorNumerico {insertarPolaca("/");}
        | factorNumerico
        ;

factorNumerico:
        ID {
                char error[50];
                strcpy(vecAux, $1);
                punt = strtok(vecAux," +-*/[](){}:=,\n");
                if(!esNumero(punt,error))
                {
                    sprintf(mensajes, "%s", error);
                    yyerror(mensajes, @1.first_line, @1.first_column, @1.last_column);
                }
                if(esAsig == 1 || esComp == 1){guardarAsignacion(punt);}
                insertarPolaca(punt);
           }
        | CONST_INT { $<tipo_int>$ = $1; if(esAsig == 1 || esComp == 1){guardarAsignacionInt($<tipo_int>$);} insertarPolacaInt($<tipo_int>$); }
        | CONST_REAL { $<tipo_double>$ = $1; if(esAsig == 1 || esComp == 1){guardarAsignacionDouble($<tipo_double>$);} insertarPolacaDouble($<tipo_double>$); }
        | PAR_A expresionNumerica PAR_C
        | combinatorio
        | factorial
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
    else
    { 
        crearTablaTS();
        yyparse();
        fclose(yyin);
        system("Pause"); /*Esta pausa la puse para ver lo que hace via mensajes*/
        return 0;
    }
}

/*---- Tabla de Símbolos ----*/

int insertarTS(const char *nombre, const char *tipo, const char* valString, int valInt, double valDouble)
{
    t_simbolo *tabla = tablaTS.primero;
    char nombreCTE[32] = "_";
    strcat(nombreCTE, nombre);
    
    while(tabla)
    {
        if(strcmp(tabla->data.nombre, nombre) == 0 || strcmp(tabla->data.nombre, nombreCTE) == 0)
        {
            return 1;
        }
        
        if(tabla->next == NULL)
        {
            break;
        }
        tabla = tabla->next;
    }

    t_data *data = (t_data*)malloc(sizeof(t_data));
    data = crearDatos(nombre, tipo, valString, valInt, valDouble);

    if(data == NULL)
    {
        return 1;
    }

    t_simbolo* nuevo = (t_simbolo*)malloc(sizeof(t_simbolo));

    if(nuevo == NULL)
    {
        return 2;
    }

    nuevo->data = *data;
    nuevo->next = NULL;

    if(tablaTS.primero == NULL)
    {
        tablaTS.primero = nuevo;
    }
    else
    {
        tabla->next = nuevo;
    }

    return 0;
}

t_data* crearDatos(const char *nombre, const char *tipo, const char* valString, int valInt, double valDouble)
{
    char full[32] = "_";
    char aux[20];

    t_data *data = (t_data*)calloc(1, sizeof(t_data));
    if(data == NULL)
    {
        return NULL;
    }

    data->tipo = (char*)malloc(sizeof(char) * (strlen(tipo) + 1));
    strcpy(data->tipo, tipo);

    if(strcmp(tipo, "STRING")==0 || strcmp(tipo, "INT")==0 || strcmp(tipo, "FLOAT")==0)
    {
        data->nombre = (char*)malloc(sizeof(char) * (strlen(nombre) + 1));
        strcpy(data->nombre, nombre);
        data->nombreASM = (char*)malloc(sizeof(char) * (strlen(nombre) + 1));
        strcpy(data->nombreASM, nombre);
        return data;
    }
    else
    {
        if(strcmp(tipo, "CONST_STR") == 0)
        {
            contadorString++;
            
            data->valor.valor_str = (char*)malloc(sizeof(char) * (strlen(valString) + 1));
            strcpy(data->valor.valor_str, valString);

            char auxString[32];
            strcpy(full, ""); 
            strcpy(full, "S_");  // "S_"
            reemplazarString(auxString, nombre);
            strcat(full, auxString); // "S_<nombre>"  
            char numero[10];
            sprintf(numero, "_%d", contadorString);
            strcat(full, numero); // "S_<nombre>_#"

            data->nombre = (char*)malloc(sizeof(char) * (strlen(full) + 1));
            data->nombreASM = (char*)malloc(sizeof(char) * (strlen(full) + 1));
            strcpy(data->nombre, full);
            strcpy(data->nombreASM, data->nombre);
        }
        if(strcmp(tipo, "CONST_REAL") == 0)
        {
            char dest[32];
            sprintf(aux, "%g", valDouble);
            strcat(full, aux);
            data->nombre = (char*)malloc(sizeof(char) * strlen(full) + 1);
            strcpy(data->nombre, full);
            data->valor.valor_double = valDouble;
            reemplazarChar(dest, full, '.', '_');
            data->nombreASM = (char*)malloc(sizeof(char) * (strlen(dest) + 1));
            strcpy(data->nombreASM, dest);
        }
        if(strcmp(tipo, "CONST_INT") == 0)
        {
            sprintf(aux, "%d", valInt);
            strcat(full, aux);
            data->nombre = (char*)malloc(sizeof(char) * (strlen(full) + 1));
            strcpy(data->nombre, full);
            data->valor.valor_int = valInt;
            data->nombreASM = (char*)malloc(sizeof(char) * (strlen(full) + 1));
            strcpy(data->nombreASM, full);
        }
        return data;
    }
    return NULL;
}

void guardarTS()
{
    FILE* arch;
    if((arch = fopen("ts.txt", "wt")) == NULL)
    {
            printf("\nNo se pudo crear la tabla de simbolos.\n\n");
            return;
    }
    else if(tablaTS.primero == NULL)
            return;
    
    fprintf(arch, "%-30s%-30s%-30s%-30s\n", "NOMBRE", "TIPODATO", "VALOR", "LONGITUD");

    t_simbolo *aux;
    t_simbolo *tabla = tablaTS.primero;
    char linea[100];

    while(tabla)
    {
        aux = tabla;
        tabla = tabla->next;
        
        if(strcmp(aux->data.tipo, "INT") == 0)
        {
            sprintf(linea, "%-30s%-30s%-30s%-d\n", aux->data.nombre, aux->data.tipo, "--", strlen(aux->data.nombre));
        }
        else if(strcmp(aux->data.tipo, "CONST_INT") == 0)
        {
            sprintf(linea, "%-30s%-30s%-30d%-d\n", aux->data.nombre, aux->data.tipo, aux->data.valor.valor_int, strlen(aux->data.nombre) -1);
        }
        else if(strcmp(aux->data.tipo, "FLOAT") ==0)
        {
            sprintf(linea, "%-30s%-30s%-30s%-d\n", aux->data.nombre, aux->data.tipo, "--", strlen(aux->data.nombre));
        }
        else if(strcmp(aux->data.tipo, "CONST_REAL") == 0)
        {
            sprintf(linea, "%-30s%-30s%-30g%-d\n", aux->data.nombre, aux->data.tipo, aux->data.valor.valor_double, strlen(aux->data.nombre) -1);
        }
        else if(strcmp(aux->data.tipo, "STRING") == 0)
        {
            sprintf(linea, "%-30s%-30s%-30s%-d\n", aux->data.nombre, aux->data.tipo, "--", strlen(aux->data.nombre));
        }
        else if(strcmp(aux->data.tipo, "CONST_STR") == 0)
        {
            sprintf(linea, "%-30s%-30s%-30s%-d\n", aux->data.nombre, aux->data.tipo, aux->data.valor.valor_str, strlen(aux->data.valor.valor_str) -2);
        }
        fprintf(arch, "%s", linea);
        free(aux);
    }
    fclose(arch); 
}

void crearTablaTS()
{
    tablaTS.primero = NULL;
}

t_simbolo * getLexema(const char *valor){
    t_simbolo *lexema;
    t_simbolo *tablaSimbolos = tablaTS.primero;

    char nombreLimpio[32];
    limpiarString(nombreLimpio, valor);
    char nombreCTE[32] = "_";
    strcat(nombreCTE, nombreLimpio);
    int esID, esCTE, esASM, esValor =-1;
    char valorFloat[32];

    while(tablaSimbolos){  
        esID = strcmp(tablaSimbolos->data.nombre, nombreLimpio);
        esCTE = strcmp(tablaSimbolos->data.nombre, nombreCTE);
        esASM = strcmp(tablaSimbolos->data.nombreASM, valor);

        if(strcmp(tablaSimbolos->data.tipo, "CONST_STR") == 0)
        {
            esValor = strcmp(valor, tablaSimbolos->data.valor.valor_str);
        }

        if(esID == 0 || esCTE == 0 || esASM == 0 || esValor == 0)
        { 
            lexema = tablaSimbolos;
            return lexema;
        }
        tablaSimbolos = tablaSimbolos->next;
    }
    return NULL;
}

int existeID(const char* id)
{
    t_simbolo *tabla = tablaTS.primero;
    char valor[32];
    char nombreCTE[32] = "_";
    strcat(nombreCTE, id);
    int b1, b2, b3, b4 = -1;

    while(tabla)
    {   
        b1 = strcmp(tabla->data.nombre, id);
        b2 = strcmp(tabla->data.nombre, nombreCTE);
        b3 = strcmp(tabla->data.nombreASM, id);

        if(strcmp(tabla->data.tipo, "CONST_STR") == 0)
        {
            b4 = strcmp(tabla->data.valor.valor_str, id);
        }

        if(b1 == 0 || b2 == 0 || b3 == 0 || b4 == 0)
        {
            return 1;
        }
        tabla = tabla->next;
    }
    return 0;
}

int esNumero(const char* id,char* error)
{
    t_simbolo *tabla = tablaTS.primero;
    char nombreCTE[32] = "_";
    strcat(nombreCTE, id);

    while(tabla)
    {
        if(strcmp(tabla->data.nombre, id) == 0 || strcmp(tabla->data.nombre, nombreCTE) == 0)
        {
            if(strcmp(tabla->data.tipo, "INT")==0 || strcmp(tabla->data.tipo, "FLOAT")==0)
            {
                return 1;
            }
            else
            {
                sprintf(error,"%s%s%s","Error: tipo de dato de la variable '",id,"' incorrecto. Los tipos permitidos son 'int' y 'float'");
                return 0;
            }
        }
        tabla = tabla->next;
    }
    sprintf(error, "%s%s%s", "Error: no se declaro la variable '", id, "'");
    return 0;
}

void guardarAsignacion(const char* id)
{
    topeAsignacion++;
    strcpy(vecAsignacion[topeAsignacion], id);
}

void guardarAsignacionInt(const int id)
{
    char aux[32];
    sprintf(aux, "%d", id);
    guardarAsignacion(aux);
}

void guardarAsignacionDouble(const double id)
{
    char aux[32];
    sprintf(aux, "%g", id);
    guardarAsignacion(aux);
}

bool verificarAsignacion(const char* id)
{
    t_simbolo* lexemaI = getLexema(id);
    t_simbolo* lexemaD;
    int i;

    for(i=0; i<=topeAsignacion; i++)
    {
        lexemaD = getLexema(vecAsignacion[i]);
        if(!esCompatible(lexemaI->data.tipo, lexemaD->data.tipo))
        {
            return false;
        }
    }
    return true;
}

bool verificarComparacion()
{
    int i;
    t_simbolo* lex;
    if(topeAsignacion >= 0)
        lex = getLexema(vecAsignacion[0]);

    for(i=1; i<=topeAsignacion; i++)
    {
        t_simbolo* lex2 = getLexema(vecAsignacion[i]);
        if(!esCompatible(lex->data.tipo, lex2->data.tipo))
        {
            return false;
        }
    }
    return true;
}

bool esCompatible(const char* tipo1, const char* tipo2)
{
    if(strcmp("INT", tipo1) == 0)
    {
        return (strcmp("INT", tipo2) == 0 || strcmp("CONST_INT", tipo2) == 0);
    }
    else if(strcmp("FLOAT", tipo1) == 0)
    {
        return (strcmp("FLOAT", tipo2) == 0 || strcmp("CONST_REAL", tipo2) == 0);
    }
    else if(strcmp("STRING", tipo1) == 0)
    {
        return (strcmp("STRING", tipo2) == 0 || strcmp("CONST_STR", tipo2) == 0);
    }
}


/*    Funciones extras    */

char* limpiarString(char* dest, const char* cad)
{
    int i, longitud, j=0;
    longitud = strlen(cad);
    for(i=0; i<longitud; i++)
    {
        if(cad[i] != '"')
        {
            dest[j] = cad[i];
            j++;
        }
    }
    dest[j] = '\0';
    return dest;
}

char* reemplazarChar(char* dest, const char* cad, const char viejo, const char nuevo)
{
    int i, longitud;
    longitud = strlen(cad);

    for(i=0; i<longitud; i++)
    {
        if(cad[i] == viejo)
        {
            dest[i] = nuevo;
        }
        else
        {
            dest[i] = cad[i];
        }
    }
    dest[i] = '\0';
    return dest;
}

char* reemplazarString(char* dest, const char* cad)
{
    int i, longitud;
    longitud = strlen(cad);

    for(i=0; i<longitud; i++)
    {
        if((cad[i] >= 'a' && cad[i] <= 'z') || (cad[i] >='A' && cad[i] <= 'Z') || (cad[i] >= '0' && cad[i] <= '9'))
        {
            dest[i] = cad[i];
        }
        else
        {
            dest[i] = '_';
        }
    }
    dest[i] = '\0';
    return dest;
}

/*------ Funciones Polaca ------*/

char* insertarPolaca(char * cad){
	strcpy(vecPolaca[posActual],cad);
	posActual++;
	return cad;
}

void insertarPolacaInt(int entero){
	char cad[20];
	itoa(entero, cad, 10);
	insertarPolaca(cad);
}

void insertarPolacaDouble(double real){
	char cad[20];
    sprintf(cad,"%g", real);
	insertarPolaca(cad);
}

void avanzarPolaca(){
	posActual++;
}

void imprimirPolaca(){
	int i;
	for (i=0;i<posActual;i++){
	    printf("posActual: %d, valor: %s \r\n",i,vecPolaca[i]);
    }
}

void guardarPos(){
	topePila++;
	pilaPolaca[topePila]=posActual;
	posActual++;
}

int pedirPos(){
	if(topePila>-1){
	    int retorno = pilaPolaca[topePila];
	    topePila--;
	    return retorno;
	}else{
	    return -1;
	}
}

void escribirPosicionEnTodaLaPila(int cant, int celda){
	while(cant > 0)
    {
        char cad[20];
        itoa(celda, cad, 10);
        strcpy(vecPolaca[pedirPos()],cad);
        cant --;
	}
}

void grabarPolaca(){
  FILE* pf = fopen("intermedia.txt","wt");
  int i;
	for (i=0;i<posActual;i++){
	fprintf(pf,"pos: %d, valor: %s \r\n",i,vecPolaca[i]);
	}
    fclose(pf);
}

/* Esta función está pensada para cuando desapilamos el valor
de una celda y lo debemos insertar en la polaca. */

char * insertarPolacaEnPosicion(const int posicion, const int valorCelda){
    char aux[6]; //Ponele que tenemos hasta 1M celdas.
    return strcpy(vecPolaca[posicion], itoa(valorCelda, aux, 10));
}

void notCondicion(int cant) //aca le pasamos por parametro el delta correspondiente a cada if
{
    int j;
    for( j=0; j<=cant;j++){
        char cad[50];
        int k = topePila-j;
        int i = pilaPolaca[k] - 1;
        strcpy(cad,vecPolaca[i]);
        
        if(strcmp(cad, "BGE") == 0){
            strcpy(vecPolaca[i], "BLT");
        }else if(strcmp(cad, "BLT") == 0){
            strcpy(vecPolaca[i], "BGE");
        }else if(strcmp(cad, "BLE") == 0){
            strcpy(vecPolaca[i], "BGT");
        }else if(strcmp(cad, "BGT") == 0){
            strcpy(vecPolaca[i], "BLE");
        }else if(strcmp(cad, "BEQ") == 0){
            strcpy(vecPolaca[i], "BNE");
        }else if(strcmp(cad, "BNE") == 0){
            strcpy(vecPolaca[i], "BEQ");
        }
    }
}

/*    Funciones extras    */

void calcularFactorial(char * var, char * res)
{	
	insertarTS(var, "INT", "", 0, 0);
    insertarTS("@auxFact", "INT", "", 0, 0);
    insertarTS(res, "INT", "", 0, 0);

    insertarPolaca("="); insertarPolaca(var); 
    insertarPolaca(var); insertarPolaca("="); insertarPolaca("@auxFact");
    insertarPolaca(var); insertarPolaca("=");  insertarPolaca(res); 
    
    insertarPolaca("ET"); posActual--; guardarPos(); 
    insertarPolaca("@auxFact"); insertarPolaca("CMP"); insertarPolacaInt(2); insertarPolaca("BLE"); guardarPos();
    
    insertarPolaca(res); insertarPolaca("@auxFact"); insertarPolacaInt(1);
    insertarPolaca("-"); insertarPolaca("*"); insertarPolaca("="); insertarPolaca(res);
    insertarPolaca("@auxFact"); insertarPolacaInt(1); insertarPolaca("-"); insertarPolaca("="); insertarPolaca("@auxFact");
    
    insertarPolaca("BI"); insertarPolacaEnPosicion(pedirPos(), posActual + 1); insertarPolacaInt(pedirPos());
}


/* --- Funciones para Assembler --- */

void generarAssembler(){
    FILE* archAssembler = fopen("final.asm","wt");

    crearHeader(archAssembler);
    crearSeccionData(archAssembler);
    crearSeccionCode(archAssembler);

    int i;
    for(i=0; i<posActual; i++){

        if(esPosicionDeEtiqueta(i) || esEtiquetaWhile(vecPolaca[i])){
            fprintf(archAssembler, "branch%d:\n\n", i);
        }        

	    if(esValor(vecPolaca[i])){
            t_simbolo *lexema = getLexema(vecPolaca[i]);
            fprintf(archAssembler, "fld %s\n", lexema->data.nombreASM);
        }
        else if(esComparacion(vecPolaca[i])){
            fprintf(archAssembler, "fstp @ifI\n\n");
        }
        else if(esSalto(vecPolaca[i])){
            char *tipoSalto = getSalto(vecPolaca[i]);
            if(strcmp(tipoSalto, "jmp") != 0){
                fprintf(archAssembler, "fstp @ifD\n\n");
                fprintf(archAssembler, "fld @ifI\nfld @ifD\n");
                fprintf(archAssembler, "fxch\nfcom\nfstsw AX\nsahf\n");
            }
            i++;
            fprintf(archAssembler, "%s branch%s\n\n", tipoSalto, vecPolaca[i]);
            guardarPosicionDeEtiqueta(vecPolaca[i]);
        }
        else if(esGet(vecPolaca[i])){
            i++;
            t_simbolo *lexema = getLexema(vecPolaca[i]);

            if(strcmp(lexema->data.tipo, "CONST_REAL") == 0 || strcmp(lexema->data.tipo, "INT") == 0)
            {
                fprintf(archAssembler, "GetFloat %s\nNEWLINE\n", lexema->data.nombreASM);
            }
            else
            {
                fprintf(archAssembler, "getString %s\nNEWLINE\n", lexema->data.nombreASM);
            }
        }
        else if(esDisplay(vecPolaca[i])){
            i++;
            t_simbolo *lexema = getLexema(vecPolaca[i]);

            if(strcmp(lexema->data.tipo, "CONST_STR") == 0){
                fprintf(archAssembler, "displayString %s\nNEWLINE\n", lexema->data.nombreASM);
            }
            else{
                fprintf(archAssembler, "displayFloat %s,2\nNEWLINE\n", lexema->data.nombreASM);
            }
        }
        else if(esAsignacion(vecPolaca[i])){
            i++;
            fprintf(archAssembler, "fstp %s\n\n", vecPolaca[i]);          
        }
        else if(esOperacion(vecPolaca[i])){
            fprintf(archAssembler, "%s\n", getOperacion(vecPolaca[i]));
        }
	}      

    crearFooter(archAssembler);
    fclose(archAssembler);
}

//Podríamos verificar de no introducir duplicados, pero creo que al cohete.
void guardarPosicionDeEtiqueta(const char *posicion){
	topeVectorEtiquetas++;
	vectorEtiquetas[topeVectorEtiquetas] = atoi(posicion);
}

bool esPosicionDeEtiqueta(int posicion){
    int i;
    for(i = 0; i <= topeVectorEtiquetas; i++){
        if(posicion == vectorEtiquetas[i]){
            return true;
        }
    }
    return false;
}

bool esEtiquetaWhile(const char *str){
    return strcmp(str, "ET") == 0;
}

void crearHeader(FILE *archAssembler){
    fprintf(archAssembler, "%s\n%s\n\n", "include number.asm", "include macros2.asm");
    fprintf(archAssembler, "%-30s%-30s\n", ".MODEL LARGE", "; Modelo de memoria");
    fprintf(archAssembler, "%-30s%-30s\n", ".386", "; Tipo de procesador");
    fprintf(archAssembler, "%-30s%-30s\n\n", ".STACK 200h", "; Bytes en el stack");
}

void crearSeccionData(FILE *archAssembler){
    t_simbolo *aux;
    t_simbolo *tablaSimbolos = tablaTS.primero;

    fprintf(archAssembler, "%s\n\n", ".DATA");

    while(tablaSimbolos){
        aux = tablaSimbolos;
        tablaSimbolos = tablaSimbolos->next;
        
        if(strcmp(aux->data.tipo, "INT") == 0){
            fprintf(archAssembler, "%-15s%-15s%-15s%-15s\n", aux->data.nombreASM, "dd", "?", "; Variable int");
        }
        else if(strcmp(aux->data.tipo, "FLOAT") == 0){
            fprintf(archAssembler, "%-15s%-15s%-15s%-15s\n", aux->data.nombreASM, "dd", "?", "; Variable float");
        }
        else if(strcmp(aux->data.tipo, "STRING") == 0){ 
            fprintf(archAssembler, "%-15s%-15s%-15s%-15s\n", aux->data.nombreASM, "db", "?", "; Variable string");
        }
        else if(strcmp(aux->data.tipo, "CONST_INT") == 0){ 
            char valor[50];
            sprintf(valor, "%d.0", aux->data.valor.valor_int);
            fprintf(archAssembler, "%-15s%-15s%-15s%-15s\n", aux->data.nombreASM, "dd", valor, "; Constante int");
        }
        else if(strcmp(aux->data.tipo, "CONST_REAL") == 0){ 
            char valor[50];
            sprintf(valor, "%g", aux->data.valor.valor_double);
            fprintf(archAssembler, "%-15s%-15s%-15s%-15s\n", aux->data.nombreASM, "dd", valor, "; Constante float");
        }
        else if(strcmp(aux->data.tipo, "CONST_STR") == 0){
            char valor[50];
            sprintf(valor, "%s, '$', %d dup (?)",aux->data.valor.valor_str, strlen(aux->data.valor.valor_str) - 2);
            fprintf(archAssembler, "%-30s%-15s%-15s%-15s\n", aux->data.nombreASM, "db", valor, "; Constante string");
        }
    }
    fprintf(archAssembler, "%-15s%-15s%-15s%-15s\n", "@ifI", "dd", "?", "; Variable para condición izquierda");
    fprintf(archAssembler, "%-15s%-15s%-15s%-15s\n", "@ifD", "dd", "?", "; Variable para condición derecha");
}

void crearSeccionCode(FILE *archAssembler){
    fprintf(archAssembler, "\n%s\n\n%s\n\n", ".CODE", "inicio:");
    fprintf(archAssembler, "%-30s%-30s\n", "mov AX,@DATA", "; Inicializa el segmento de datos");
    fprintf(archAssembler, "%-30s\n%-30s\n\n", "mov DS,AX", "mov ES,AX");
}

void crearFooter(FILE *archAssembler){
    fprintf(archAssembler, "\n%-30s%-30s\n", "mov AX,4C00h", "; Indica que debe finalizar la ejecución");
    fprintf(archAssembler, "%s\n\n%s", "int 21h", "END inicio");
}

bool esValor(const char * str){
    //Si es valor, tiene que estar en la tabla de símbolos guiño guiño
    return existeID(str) == 1;
} 

bool esComparacion(const char * str){
    int aux = strcmp(str, "CMP");
    return aux == 0;
}

//La última comparación no es obligatoria, pero es para no perder de vista todos los saltos.
bool esSalto(const char * str){
    if(strcmp(str, "BNE") == 0){
       return true; 
    }
    else if(strcmp(str, "BGT") == 0){
        return true;
    }
    else if(strcmp(str, "BLT") == 0){
        return true;
    }
    else if(strcmp(str, "BLE") == 0){
       return true; 
    }
    else if(strcmp(str, "BGE") == 0){
        return true;
    }
    else if(strcmp(str, "BEQ") == 0){
        return true;
    }
    else if(strcmp(str, "BI") == 0){
        return true;
    }
    return false;
}

//La última comparación no es obligatoria, pero es más fácil de ver a qué salto corresponde.
char * getSalto(const char * salto){
    if(strcmp(salto, "BNE") == 0){
       return "jne"; 
    }
    else if(strcmp(salto, "BGT") == 0){
        return "ja";
    }
    else if(strcmp(salto, "BLT") == 0){
        return "jb";
    }
    else if(strcmp(salto, "BLE") == 0){
       return "jbe"; 
    }
    else if(strcmp(salto, "BGE") == 0){
        return "jae";
    }
    else if(strcmp(salto, "BEQ") == 0){
        return "je";
    }
    else if(strcmp(salto, "BI") == 0){
        return "jmp";
    }
}

bool esGet(char * str)
{
    int aux = strcmp(str, "GET");
    return aux == 0;
}

bool esDisplay(const char * str){
    int aux = strcmp(str, "DISPLAY");
    return aux == 0;
}

bool esAsignacion(char * str)
{
    int aux = strcmp(str, "=");
    return aux == 0;
}

bool esOperacion(const char * str){
    if(strcmp(str, "+") == 0){
       return true; 
    }
    else if(strcmp(str, "-") == 0){
        return true;
    }
    else if(strcmp(str, "*") == 0){
        return true;
    }
    else if(strcmp(str, "/") == 0){
        return true;
    }        
    return false;
}
 
char * getOperacion(const char * operacion){
    if(strcmp(operacion, "+") == 0){
       return "fadd"; 
    }
    else if(strcmp(operacion, "-") == 0){
        return "fsub";
    }
    else if(strcmp(operacion, "*") == 0){
        return "fmul";
    }
    else {
        return "fdiv";
    }
}