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
t_tabla tablaTS;

char idvec[32][50];
int cantid = 0, i=0;
char vecAux[20];
char* punt;

/* --- Validaciones --- */
int existeID(const char*);
int esNumero(const char*,char*);
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
char pilaAssembler[500][50];
int topePilaAssembler=0;
void generarAssembler();
void crearHeader(FILE *);
void crearSeccionData(FILE *);
void crearSeccionCode(FILE *);
void crearFooter(FILE *);
bool esValor(const char * str);
void apilarValor( char * str );
bool esComparacion( char * str );
bool esSalto( char * str );
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
        { /*guardarTS(); */grabarPolaca(); generarAssembler(); guardarTS(); printf("\nCompilacion OK! Ver archivo Final.asm\n\n"); }
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
                                                for(i=0; i<cantid; i++) //vamos agregando todos los ids que leyo
                                                {
                                                    if(insertarTS(idvec[i], "INT", "", 0, 0) != 0) //no lo guarda porque ya existe
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
            | { local++; } seleccion 
            | { local++; } iteracion
            | salida
            | entrada
            ;

salida:
        DISPLAY CONST_STR PUNTOYCOMA {                                     
                                        strcpy(vecAux, $2);
                                        strtok(vecAux," ;\n");
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
                            insertarPolaca("GET"); //cambie el orden de estos dos, espero sepan perdonar
                            insertarPolaca(vecAux);

                        }
        ;        

asignacion:
            ID OP_ASIG expresion PUNTOYCOMA {
                                                strcpy(vecAux, $1); /*en $1 esta el valor de ID*/
                                                punt = strtok(vecAux," +-*/[](){}:=,\n"); /*porque puede venir de cualquier lado, pero ver si funciona solo con el =*/
                                                if(!existeID(punt)) /*No existe: entonces no esta declarada*/
                                                {
                                                    sprintf(mensajes, "%s%s%s", "Error: no se declaro la variable '", punt, "'");
                                                    yyerror(mensajes, @1.first_line, @1.first_column, @1.last_column);
                                                }
                                                insertarPolaca("=");
                                                insertarPolaca(punt); //ya tiene el cambiazo loco para asm
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
            expresion COMP_BEQ expresion { insertarPolaca("CMP"); insertarPolaca("BNE");
                                            if(hayOr){insertarPolacaEnPosicion(pedirPos(), posActual +1); hayOr=0;} guardarPos(); delta++;}
            | expresion COMP_BLE expresion { insertarPolaca("CMP"); insertarPolaca("BGT");
                                            if(hayOr){insertarPolacaEnPosicion(pedirPos(), posActual +1); hayOr=0;} guardarPos(); delta++;}
            | expresion COMP_BGE expresion { insertarPolaca("CMP"); insertarPolaca("BLT");
                                            if(hayOr){insertarPolacaEnPosicion(pedirPos(), posActual +1); hayOr=0;} guardarPos(); delta++;}
            | expresion COMP_BGT expresion { insertarPolaca("CMP"); insertarPolaca("BLE");
                                            if(hayOr){insertarPolacaEnPosicion(pedirPos(), posActual +1); hayOr=0;} guardarPos(); delta++;}
            | expresion COMP_BLT expresion { insertarPolaca("CMP"); insertarPolaca("BGE");
                                            if(hayOr){insertarPolacaEnPosicion(pedirPos(), posActual +1); hayOr=0;} guardarPos(); delta++;}
            | expresion COMP_BNE expresion { insertarPolaca("CMP"); insertarPolaca("BEQ");
                                            if(hayOr){insertarPolacaEnPosicion(pedirPos(), posActual +1); hayOr=0;} guardarPos(); delta++;}
            | between {delta += 2;} //aca suma de a dos porque between tiene dos comparaciones
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
                if(!existeID(punt)) /*No esta declarada*/
                {
                    sprintf(mensajes, "%s%s%s", "Error: no se declaro la variable '", punt, "'");
                    yyerror(mensajes, @1.first_line, @1.first_column, @1.last_column);
                }
                insertarPolaca(punt);
           }
        | CONST_INT { $<tipo_int>$ = $1; insertarPolacaInt($<tipo_int>$);}
        | CONST_REAL { $<tipo_double>$ = $1; insertarPolacaDouble($<tipo_double>$);}
        | CONST_STR { $<tipo_str>$ = $1; insertarPolaca($<tipo_str>$);}
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
            calcularFactorial("@var","@res");
            insertarPolaca("@res");
        }
        ;

between:
        BETWEEN PAR_A ID {
                            //ver que sea una variable numérica
                            char error[50];
                            strcpy(vecAux, $3);
                            punt = strtok(vecAux," ;\n");
                            if(!esNumero(punt, error))
                            {
                                sprintf(mensajes, "%s", error);
                                yyerror(mensajes, @1.first_line, @1.first_column, @1.last_column);
                            }
                            strcpy(auxBet, insertarPolaca(punt));
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
                if(!esNumero(punt,error)) /*No existe: entonces no esta declarada --> error*/
                {
                    sprintf(mensajes, "%s", error);
                    yyerror(mensajes, @1.first_line, @1.first_column, @1.last_column);
                }
                insertarPolaca(punt);
           }
        | CONST_INT { $<tipo_int>$ = $1; insertarPolacaInt($<tipo_int>$); }
        | CONST_REAL { $<tipo_double>$ = $1; insertarPolacaDouble($<tipo_double>$); }
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

int insertarTS(const char *nombre,const char *tipo, const char* valString, int valInt, double valDouble)
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

    //Es una variable
    if(strcmp(tipo, "STRING")==0 || strcmp(tipo, "INT")==0 || strcmp(tipo, "FLOAT")==0)
    {
        //al nombre lo dejo aca porque no lleva _
        data->nombre = (char*)malloc(sizeof(char) * (strlen(nombre) + 1));
        strcpy(data->nombre, nombre);
        return data;
    }
    else
    {   //Son constantes: tenemos que agregarlos a la tabla con "_" al comienzo del nombre, hay que agregarle el valor
        if(strcmp(tipo, "CONST_STR") == 0)
        {
            data->valor.valor_str = (char*)malloc(sizeof(char) * strlen(valString) +1);
            data->nombre = (char*)malloc(sizeof(char) * (strlen(nombre) + 1));
            strcat(full, nombre);
            strcpy(data->nombre, full);    
            strcpy(data->valor.valor_str, valString);
        }
        if(strcmp(tipo, "CONST_REAL") == 0)
        {
            sprintf(aux, "%g", valDouble);
            strcat(full, aux);
            data->nombre = (char*)malloc(sizeof(char) * strlen(full));

            strcpy(data->nombre, full);
            data->valor.valor_double = valDouble;
        }
        if(strcmp(tipo, "CONST_INT") == 0)
        {
            sprintf(aux, "%d", valInt);
            strcat(full, aux);
            data->nombre = (char*)malloc(sizeof(char) * strlen(full));
            strcpy(data->nombre, full);
            data->valor.valor_int = valInt;
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
        
        if(strcmp(aux->data.tipo, "INT") == 0) //variable int
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
            sprintf(linea, "%-30s%-30s%-30s%-d\n", aux->data.nombre, aux->data.tipo, aux->data.valor.valor_str, strlen(aux->data.nombre) -1);
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
    int esID, esCTE;

    while(tablaSimbolos){  
        esID = strcmp(tablaSimbolos->data.nombre, nombreLimpio);
        esCTE = strcmp(tablaSimbolos->data.nombre, nombreCTE);
        if(esID == 0 || esCTE == 0){
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
    char nombreCTE[32] = "_";
    strcat(nombreCTE, id);
    int b1 = 0;
    int b2 = 0;

    while(tabla)
    {   
        b1 = strcmp(tabla->data.nombre, id);
        b2 = strcmp(tabla->data.nombre, nombreCTE);
        if(b1 == 0 || b2 == 0){
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

/*    Funciones extras    */

char* limpiarString(char* dest, const char* cad)
{
    //Sacarle las comillas a cad
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
	sprintf(cad,"%.10f", real);
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
	topePila++; // tope=-1 significa pila vacía, el primer elemento de la pila esta en tope=0
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
    insertarTS("@aux", "INT", "", 0, 0);
    insertarTS(res, "INT", "", 0, 0);

    insertarPolaca("="); insertarPolaca(var); 
    insertarPolaca(var); insertarPolaca("="); insertarPolaca("@aux");
    insertarPolaca(var); insertarPolaca("=");  insertarPolaca(res); 
    
    insertarPolaca("ET"); posActual--; guardarPos(); 
    insertarPolaca("@aux"); insertarPolacaInt(2); insertarPolaca("CMP"); insertarPolaca("BLE"); guardarPos();
    
    insertarPolaca(res); insertarPolaca("@aux"); insertarPolacaInt(1);
    insertarPolaca("-"); insertarPolaca("*"); insertarPolaca("="); insertarPolaca(res);
    insertarPolaca("@aux"); insertarPolacaInt(1); insertarPolaca("-"); insertarPolaca("="); insertarPolaca("@aux");
    
    insertarPolaca("BI"); insertarPolacaEnPosicion(pedirPos(), posActual + 1); insertarPolacaInt(pedirPos());
}


/* --- Funciones para Assembler --- */

void generarAssembler(){
    FILE* archAssembler = fopen("final.asm","wt");

    crearHeader(archAssembler);
    crearSeccionData(archAssembler);
    crearSeccionCode(archAssembler);

    //Código propiamente dicho   
    int i;
    for(i=0; i<posActual; i++){
	    if(esValor(vecPolaca[i])){
            t_simbolo *lexema = getLexema(vecPolaca[i]);
            fprintf(archAssembler, "fld %s\n", lexema->data.nombre);
        }
        else if(esComparacion(vecPolaca[i]))
        {
            
        }
        else if(esSalto(vecPolaca[i]))
        {

        }
        else if(esGet(vecPolaca[i]))
        {
            i++;
            t_simbolo *lexema = getLexema(vecPolaca[i]);
            //fprintf(archAssembler, "esta variable es: %s\t%s\n\n", lexema->data.nombre, lexema->data.tipo);
            if(strcmp(lexema->data.tipo, "CONST_REAL") == 0)
            {
                fprintf(archAssembler, "GetFloat %s\n\n", lexema->data.nombre);
            }
            else if( strcmp(lexema->data.tipo, "INT") == 0 )
            {
                fprintf(archAssembler, "GetInteger %s\n\n", lexema->data.nombre);
            }
            else
            {
                fprintf(archAssembler, "getString %s\n\n", lexema->data.nombre);
            }

        }
        else if(esDisplay(vecPolaca[i])){
            i++;
            t_simbolo *lexema = getLexema(vecPolaca[i]);

            if(strcmp(lexema->data.tipo, "CONST_STR") == 0){
                fprintf(archAssembler, "displayString %s\n\n", lexema->data.nombre);
            }
            else
            {
                fprintf(archAssembler, "DisplayFloat %s,2\n\n", lexema->data.nombre);
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
    //Fin código propiamente dicho

    crearFooter(archAssembler);
    fclose(archAssembler);
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

    fprintf(archAssembler, "\n%s\n\n", ".DATA");

    fprintf(archAssembler, "%-15s%-15s%-15s%-15s\n", "_get", "db", "?", "; Variable string"); //hay que sacarlo

    while(tablaSimbolos){
        aux = tablaSimbolos;
        tablaSimbolos = tablaSimbolos->next;
        
        if(strcmp(aux->data.tipo, "INT") == 0){
            fprintf(archAssembler, "%-15s%-15s%-15s%-15s\n", aux->data.nombre, "dd", "?", "; Variable int");
        }
        else if(strcmp(aux->data.tipo, "FLOAT") == 0){
            fprintf(archAssembler, "%-15s%-15s%-15s%-15s\n", aux->data.nombre, "dd", "?", "; Variable float");
        }
        else if(strcmp(aux->data.tipo, "STRING") == 0){ 
            fprintf(archAssembler, "%-15s%-15s%-15s%-15s\n", aux->data.nombre, "db", "?", "; Variable string");
        }
        else if(strcmp(aux->data.tipo, "CONST_INT") == 0){ 
            char valor[50];
            sprintf(valor, "%d", aux->data.valor.valor_int);
            strcat(valor, ".0");
            fprintf(archAssembler, "%-15s%-15s%-15s%-15s\n", aux->data.nombre, "dd", valor, "; Constante int");
        }
        else if(strcmp(aux->data.tipo, "CONST_REAL") == 0){ 
            char valor[50];
            sprintf(valor, "%g", aux->data.valor.valor_double); //tenemos que ver si al nombre le sacamos el punto
            fprintf(archAssembler, "%-15s%-15s%-15s%-15s\n", aux->data.nombre, "dd", valor, "; Constante float");
        }
        else if(strcmp(aux->data.tipo, "CONST_STR") == 0){ //ver de "T_<string>" para el nombre
            char param[50];
            strcpy(param, aux->data.valor.valor_str);
            strcat(param, ", '$', ");
            char valor[50];
            sprintf(valor, "%d", strlen(aux->data.valor.valor_str) - 2); //2 comillas
            strcat(param, valor);
            strcat(param, " dup (?)");

            fprintf(archAssembler, "%-15s%-15s%-15s%-15s\n", aux->data.nombre, "db", param, "; Constante string");
        }
    }
}

/* Habría que ver si los registros deben ir en mayúscula o en minúscula
   En caso de que puedan en ambas, los ponemos en mayúscula? */
void crearSeccionCode(FILE *archAssembler){
    fprintf(archAssembler, "\n%s\n\n%s\n\n", ".CODE", "inicio:");
    fprintf(archAssembler, "%-30s%-30s\n", "mov AX,@DATA", "; Inicializa el segmento de datos");
    fprintf(archAssembler, "%-30s\n%-30s\n\n", "mov DS,AX", "mov ES,AX");
}

void crearFooter(FILE *archAssembler){
    fprintf(archAssembler, "%-30s%-30s\n", "mov AX,4C00h", "; Indica que debe finalizar la ejecución");
    fprintf(archAssembler, "%s\n\n%s", "int 21h", "END inicio");
}

bool esValor(const char * str){
    //Si es valor, tiene que estar en la tabla de símbolos guiño guiño
    return existeID(str) == 1;
} 

void apilarValor(char * str)
{
    /*** aca tendria que guardar ese valor en una pila ***/
}
bool esComparacion(char * str)
{
    int aux = strcmp(str, "CMP");
    return aux == 0;
}
bool esSalto(char * str)
{
    //aca deberiamos poner todos los saltos o se refiere al BI?
    //los Bxx se contempan junto al CMP? como por ejemplo, pasa en la asignación que se mueve acorde a lo que usa
    return false;
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