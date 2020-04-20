/* aca declaro las cosas que voy a usar include y variables globales y eso */
%{
  #include <iostream>
  using namespace std;
  extern int yylex(); /*esto se queda esperando una cadena y la parsea, despues puede volar*/
%}

/* opciones de flex */
%option noyywrap
DIGITO			[0-9]
LETRA			[a-zA-Z]
/* Aca van las regex que reconocen tokens 
y entre corchetes hay que tirar el return que agarra el programa de bison */
%%
"+"				{ cout << "OP_SUMA" << endl; } /*{ return OP_SUMA; }*/
"-"				{ cout << "OP_RESTA" << endl; }/*{ return OP_RESTA; }*/
"*"				{ cout << "OP_MULT" << endl; }/*{ return OP_MULT; }*/
"/"				{ cout << "OP_DIV" << endl; }/*{ return OP_DIV; }*/
[ \t\n]                     { cout << "space" << endl; }
.                           { cout << "." << endl; }
%%

/*este es el main, lo estuve usando para ir probando directamente en la terminal, despues vuela*/
int main(int, char**) {
  // lex through the input:
  while (yylex());
}
