/*---- 1. Declaraciones ----*/

%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
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
char vecPolaca[500][50];
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
void escribirPosicionEnTodaLaPila(int);
char * insertarPolacaEnPosicion(const int, const int);
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
        { guardarTS(); printf("\nCompilacion OK.\n"); grabarPolaca();}
        ;

bloque_declaraciones:
                    DEFVAR declaraciones ENDDEF {printf("\nTermina el bloque de declaraciones de variables.\n");}
                    ;

declaraciones:
            declaracion
            | declaraciones declaracion
            ;

declaracion:
             INT DOSPUNTOS lista_variables  {
                                                for(i=0;i<cantid;i++) /*vamos agregando todos los ids que leyo*/
                                                {
                                                    if(insertarTS(idvec[i], "INT", "", 0, 0) != 0) //no lo guarda porque ya existe
                                                    {
                                                        sprintf(mensajes, "%s%s%s", "Error: la variable '", idvec[i], "' ya fue declarada");
                                                        yyerror(mensajes, @3.first_line, @3.first_column, @3.last_column);
                                                    }
                                                }
                                                cantid=0;
                                            } 
            | STRING DOSPUNTOS lista_variables  {
                                                    for(i=0;i<cantid;i++)
                                                    {
                                                        if(insertarTS(idvec[i], "STRING", "", 0, 0) != 0)
                                                        {
                                                            sprintf(mensajes, "%s%s%s", "Error: la variable '", idvec[i], "' ya fue declarada");
                                                            yyerror(mensajes, @3.first_line, @3.first_column, @3.last_column);
                                                        }
                                                    } cantid=0;
                                                }
            | FLOAT DOSPUNTOS lista_variables   {
                                                    for(i=0;i<cantid;i++)
                                                    {
                                                        if(insertarTS(idvec[i], "FLOAT", "", 0, 0) != 0)
                                                        {
                                                            sprintf(mensajes, "%s%s%s", "Error: la variable '", idvec[i], "' ya fue declarada");
                                                            yyerror(mensajes, @3.first_line, @3.first_column, @3.last_column);
                                                        }
                                                    } cantid=0;
                                                }
            ;

lista_variables:
                ID  {
                        strcpy(vecAux, yylval.tipo_str); /*tomamos el nombre de la variable*/
                        punt = strtok(vecAux, " ;\n"); /*eliminamos extras*/
                        strcpy(idvec[cantid], punt); /*copiamos al array de ids*/
                        cantid++;
                    }
                |ID {
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
            | entrada
            ;

salida:
        DISPLAY CONST_STR PUNTOYCOMA {printf("Display OK\n");}
        | DISPLAY ID PUNTOYCOMA {
                                    char error[50];
                                    strcpy(vecAux, $2);
                                    punt = strtok(vecAux," ;\n");
                                    if(!esNumero(punt, error)) {
                                        sprintf(mensajes, "%s", error);
                                        yyerror(mensajes, @1.first_line, @1.first_column, @1.last_column);
                                    }
                                    printf("Display OK\n");
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
                            printf("Get OK\n");
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
                                            }
            ;

seleccion:
            IF PAR_A condicion PAR_C LL_A bloque LL_C { insertarPolacaEnPosicion(pedirPos(), posActual); }
            | IF PAR_A condicion PAR_C LL_A bloque LL_C {
                insertarPolaca("BI"); insertarPolacaEnPosicion(pedirPos(), posActual + 1); guardarPos();
              } 
              ELSE LL_A bloque LL_C { insertarPolacaEnPosicion(pedirPos(), posActual); }
            ;

iteracion: 
            WHILE PAR_A condicion PAR_C LL_A bloque LL_C {printf("WHILE\n");}
            ;

condicion:
            comparacion
            | comparacion OP_AND comparacion {printf("AND\n");}
            | comparacion OP_OR comparacion {printf("OR\n");}
            | OP_NOT comparacion {printf("NOT\n");}
            | PAR_A comparacion PAR_C OP_AND PAR_A comparacion PAR_C {printf("AND\n");}
            | PAR_A comparacion PAR_C OP_OR PAR_A comparacion PAR_C {printf("OR\n");}
            | OP_NOT PAR_A comparacion PAR_C{printf("NOT\n");}
            | between
            ;

comparacion:
            expresion COMP_BEQ expresion {printf("<expresion> == <expresion>\n"); insertarPolaca("CMP"); insertarPolaca("BNE"); guardarPos();}
            | expresion COMP_BLE expresion {printf("<expresion> <= <expresion>\n"); insertarPolaca("CMP"); insertarPolaca("BGT"); guardarPos();}
            | expresion COMP_BGE expresion {printf("<expresion> >= <expresion>\n"); insertarPolaca("CMP"); insertarPolaca("BLT"); guardarPos();}
            | expresion COMP_BGT expresion{printf("<expresion> > <expresion>\n"); insertarPolaca("CMP"); insertarPolaca("BLE"); guardarPos();}
            | expresion COMP_BLT expresion{printf("<expresion> < <expresion>\n"); insertarPolaca("CMP"); insertarPolaca("BGE"); guardarPos();}
            | expresion COMP_BNE expresion{printf("<expresion> != <expresion>\n"); insertarPolaca("CMP"); insertarPolaca("BEQ"); guardarPos();}
            ;

expresion:
            expresion OP_SUMA termino {printf("Suma OK\n");insertarPolaca("+");}
            | expresion OP_RESTA termino {printf("Resta OK\n"); insertarPolaca("-");}
            | termino
            ;

termino:
        termino OP_MULT factor {printf("Multiplicacion OK\n"); insertarPolaca("*");}
        | termino OP_DIV factor {printf("Division OK\n"); insertarPolaca("/");}
        | factor
        ;

factor:/*verificando aca en este ID si existe o no, se cubre en todas las apariciones en el codigo fuente????*/
        ID {
                strcpy(vecAux, $1);
                punt = strtok(vecAux," +-*/[](){}:=,\n"); /*porque puede venir de cualquier lado*/
                if(!existeID(punt)) /*No existe: entonces no esta declarada --> error*/
                {
                    sprintf(mensajes, "%s%s%s", "Error: no se declaro la variable '", punt, "'");
                    yyerror(mensajes, @1.first_line, @1.first_column, @1.last_column);
                }

           }
        | CONST_INT { $<tipo_int>$ = $1; printf("CTE entera: %d\n", $<tipo_int>$); insertarPolacaInt($<tipo_int>$);}
        | CONST_REAL { $<tipo_double>$ = $1; printf("CTE real: %g\n", $<tipo_double>$); insertarPolacaDouble($<tipo_double>$);}
        | CONST_STR { $<tipo_str>$ = $1; printf("String: %s\n", $<tipo_str>$); insertarPolaca($<tipo_str>$);}
        | PAR_A expresion PAR_C
        | combinatorio
        | factorial
        ;

expresionNumerica:
            expresionNumerica OP_SUMA terminoNumerico {printf("Suma OK\n");}
            | expresionNumerica OP_RESTA terminoNumerico {printf("Resta OK\n");}
            | terminoNumerico
            ;

terminoNumerico:
        terminoNumerico OP_MULT factorNumerico {printf("Multiplicacion OK\n");}
        | terminoNumerico OP_DIV factorNumerico {printf("Division OK\n");}
        | factorNumerico
        ;

factorNumerico:
        ID {
                char error[50];
                strcpy(vecAux, $1);
                punt = strtok(vecAux," +-*/[](){}:=,\n"); /*porque puede venir de cualquier lado*/
                if(!esNumero(punt,error)) /*No existe: entonces no esta declarada --> error*/
                {
                    sprintf(mensajes, "%s", error);
                    yyerror(mensajes, @1.first_line, @1.first_column, @1.last_column);
                }
           }
        | CONST_INT { $<tipo_int>$ = $1; printf("CTE entera: %d\n", $<tipo_int>$);}
        | CONST_REAL { $<tipo_double>$ = $1; printf("CTE real: %f\n", $<tipo_double>$);}
        | PAR_A expresionNumerica PAR_C
        | combinatorio
        | factorial
        ;

combinatorio:
        COMB PAR_A expresionNumerica COMA expresionNumerica PAR_C {printf("Combinatorio OK\n");}
        ;

factorial:
        FACT PAR_A expresionNumerica PAR_C {printf("Factorial OK\n");}
        ;

between:
        BETWEEN PAR_A ID COMA COR_A expresionNumerica PUNTOYCOMA expresionNumerica COR_C PAR_C {printf("Between OK\n");}
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
        crearTablaTS();//tablaTS.primero = NULL;
        yyparse();
        fclose(yyin);
        system("Pause"); /*Esta pausa la puse para ver lo que hace via mensajes*/
        return 0;
    }
}

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
    {      //Son constantes: tenemos que agregarlos a la tabla con "_" al comienzo del nombre, hay que agregarle el valor
        if(strcmp(tipo, "CONST_STR") == 0)
        {
            data->valor.valor_str = (char*)malloc(sizeof(char) * strlen(valString) +1);
            data->nombre = (char*)malloc(sizeof(char) * (strlen(valString) + 1));
            strcat(full, valString);
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

int existeID(const char* id) //y hasta diria que es igual para existeCTE
{
    //tengo que ver el tema del _ en el nombre de las cte
    t_simbolo *tabla = tablaTS.primero;
    char nombreCTE[32] = "_";
    strcat(nombreCTE, id);
    int b1 = 0;
    int b2 = 0;

    while(tabla)
    {   
        b1 = strcmp(tabla->data.nombre, id);
        b2 = strcmp(tabla->data.nombre, nombreCTE);
        if(b1 == 0 || b2 == 0)
        {
            insertarPolaca(nombreCTE);
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
                strcpy(error,"Tipo de dato incorrecto");
                sprintf(error,"%s%s%s","Error: tipo de dato de la variable '",id,"' incorrecto. Tipos permitidos: int y float");
                return 0;
            }
        }
        tabla = tabla->next;
    }
    sprintf(error, "%s%s%s", "Error: no se declaro la variable '", id, "'");
    return 0;
}

/**     Funciones Polaca    **/
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
void escribirPosicionEnTodaLaPila(int num){
	char c[20];
	while(topePila>=0){
        	char cad[20];
	        itoa(num, cad, 10);
            strcpy(vecPolaca[ pedirPos() ],cad);
	}
}
void grabarPolaca(){
  FILE* pf = fopen("intermedia.txt","wt");
  int i;
	for (i=0;i<posActual;i++){
	fprintf(pf,"pos: %d, valor: %s \r\n",i,vecPolaca[i]);
	}
}
/**
* Esta función está pensada para cuando desapilamos el valor
* de una celda y lo debemos insertar en la polaca. 
*/
char * insertarPolacaEnPosicion(const int posicion, const int valorCelda){
    char aux[6]; //Ponele que tenemos hasta 1M celdas.
    return strcpy(vecPolaca[posicion], itoa(valorCelda, aux, 10));
}
