include number.asm
include macros2.asm

.MODEL LARGE                  ; Modelo de memoria           
.386                          ; Tipo de procesador          
.STACK 200h                   ; Bytes en el stack           

.DATA

a              dd             ?              ; Variable int 
b              dd             ?              ; Variable int 
c              dd             ?              ; Variable int 
_1             dd             1.0            ; Constante int
_3             dd             3.0            ; Constante int
_2             dd             2.0            ; Constante int
_7             dd             7.0            ; Constante int
_5             dd             5.0            ; Constante int
S_true_1                      db             "true", '$', 4 dup (?); Constante string
_0             dd             0.0            ; Constante int
S_false_2                     db             "false", '$', 5 dup (?); Constante string
_10            dd             10.0           ; Constante int
S_a_es_menor_a_diez_3         db             "a es menor a diez", '$', 17 dup (?); Constante string
S_end_4                       db             "end", '$', 3 dup (?); Constante string
@ifI           dd             ?              ; Variable para condición izquierda
@ifD           dd             ?              ; Variable para condición derecha

.CODE

inicio:

mov AX,@DATA                  ; Inicializa el segmento de datos
mov DS,AX                     
mov ES,AX                     

fld _1
fstp b

fld _3
fstp c

fld b
fld c
fld _2
fmul
fadd
fstp a

fld a
fstp @ifI

fld _7
fstp @ifD

fld @ifI
fld @ifD
fxch
fcom
fstsw AX
sahf
jae branch23

fld a
fstp @ifI

fld _5
fstp @ifD

fld @ifI
fld @ifD
fxch
fcom
fstsw AX
sahf
jne branch27

branch23:

displayString S_true_1
NEWLINE
jmp branch41

branch27:

fld a
fstp @ifI

fld _1
fstp @ifD

fld @ifI
fld @ifD
fxch
fcom
fstsw AX
sahf
jae branch39

fld a
fstp @ifI

fld _0
fstp @ifD

fld @ifI
fld @ifD
fxch
fcom
fstsw AX
sahf
jne branch39

displayString S_true_1
NEWLINE
branch39:

displayString S_false_2
NEWLINE
branch41:

fld a
fstp @ifI

fld _10
fstp @ifD

fld @ifI
fld @ifD
fxch
fcom
fstsw AX
sahf
jae branch58

displayFloat a,2
NEWLINE
displayString S_a_es_menor_a_diez_3
NEWLINE
fld a
fld _1
fadd
fstp a

jmp branch41

branch58:

displayFloat a,2
NEWLINE
displayString S_end_4
NEWLINE

mov AX,4C00h                  ; Indica que debe finalizar la ejecución
int 21h

END inicio