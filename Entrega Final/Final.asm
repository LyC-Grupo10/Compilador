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
f              dd             ?              ; Variable float
z              db             ?              ; Variable string
_4             dd             4.0            ; Constante int
_5             dd             5.0            ; Constante int
_2             dd             2.0            ; Constante int
_1             dd             1.0            ; Constante int
_3             dd             3.0            ; Constante int
S_otro_if_en_la_parte_true_1  db             "otro if en la parte true", '$', 24 dup (?); Constante string
_10            dd             10.0           ; Constante int
S_parte_else_del_if_2         db             "parte else del if", '$', 17 dup (?); Constante string
_4_2           dd             4.2            ; Constante float
S_between_true_3              db             "between true", '$', 12 dup (?); Constante string

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
fmul
fld _1
fadd
fld b
fld c
fadd
fld _3
fdiv
displayString S_otro_if_en_la_parte_true_1

fld c
fld _10
fld _2
fstp a

fld _1
fstp a

displayString S_parte_else_del_if_2

fld b
fld _1
fld b
fld a
fld _10
fmul
fld _4_2
fsub
displayString S_between_true_3

mov AX,4C00h                  ; Indica que debe finalizar la ejecución
int 21h

END inicio