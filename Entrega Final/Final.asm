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
_10            dd             10.0           ; Constante int
S_true_1                      db             "true", '$', 4 dup (?); Constante string
_0             dd             0.0            ; Constante int
S_true2_2                     db             "true2", '$', 5 dup (?); Constante string
S_false_3                     db             "false", '$', 5 dup (?); Constante string
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

displayFloat a,2
NEWLINE
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
jae branch25

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
jne branch39

branch25:

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
jb branch35

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
jne branch37

branch35:

displayString S_true_1
NEWLINE
branch37:

jmp branch63

branch39:

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
jae branch61

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
jne branch61

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
jbe branch61

fld a
fstp @ifI

fld _2
fstp @ifD

fld @ifI
fld @ifD
fxch
fcom
fstsw AX
sahf
je branch61

displayString S_true2_2
NEWLINE
branch61:

displayString S_false_3
NEWLINE
branch63:

displayString S_end_4
NEWLINE

mov AX,4C00h                  ; Indica que debe finalizar la ejecución
int 21h

END inicio