include number.asm
include macros2.asm

.MODEL LARGE                  ; Modelo de memoria           
.386                          ; Tipo de procesador          
.STACK 200h                   ; Bytes en el stack           


.DATA

a              dd             ?              ; Variable int 
b              dd             ?              ; Variable int 
c              dd             ?              ; Variable int 
i              dd             ?              ; Variable int 
x              dd             ?              ; Variable int 
z              db             ?              ; Variable string
_4             dd             4.0            ; Constante int
_5             dd             5.0            ; Constante int
_2             dd             2.0            ; Constante int
S_HolaGrupo10_1               db             "HolaGrupo10", '$', 11 dup (?); Constante string

.CODE

inicio:

mov AX,@DATA                  ; Inicializa el segmento de datos
mov DS,AX                     
mov ES,AX                     

fld _4
fstp b

fld _5
fstp c

fld b
fld _2
fdiv
fld c
fadd
fstp a

displayFloat a,2
NEWLINE
displayString S_HolaGrupo10_1
NEWLINE

mov AX,4C00h                  ; Indica que debe finalizar la ejecución
int 21h

END inicio