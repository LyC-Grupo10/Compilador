include number.asm
include macros2.asm

.MODEL LARGE                  ; Modelo de memoria           
.386                          ; Tipo de procesador          
.STACK 200h                   ; Bytes en el stack           

.DATA

a              dd             ?              ; Variable int 
b              dd             ?              ; Variable int 
c              dd             ?              ; Variable int 
d              dd             ?              ; Variable int 
e              dd             ?              ; Variable int 
f              dd             ?              ; Variable float
z              db             ?              ; Variable string
_1             dd             1.0            ; Constante int
_30            dd             30.0           ; Constante int
_2             dd             2.0            ; Constante int
_7             dd             7.0            ; Constante int
_5             dd             5.0            ; Constante int
S_true_1                           db             "true", '$', 4 dup (?); Constante string
_23_11         dd             23.11          ; Constante float
_102_3         dd             102.3          ; Constante float
_0_3           dd             0.3            ; Constante float
S_false_2                          db             "false", '$', 5 dup (?); Constante string
_10            dd             10.0           ; Constante int
S_a_es_menor_a_diez_3              db             "a es menor a diez", '$', 17 dup (?); Constante string
S_between_4                        db             "between", '$', 7 dup (?); Constante string
_3             dd             3.0            ; Constante int
@varFact       dd             ?              ; Variable int 
@auxFact       dd             ?              ; Variable int 
@resFact       dd             ?              ; Variable int 
S_El_factorial_es__5               db             "El factorial es:", '$', 16 dup (?); Constante string
S_fin_del_programa_6               db             "fin del programa", '$', 16 dup (?); Constante string
@ifI           dd             ?              ; Variable para condición izquierda
@ifD           dd             ?              ; Variable para condición derecha

.CODE

inicio:

mov AX,@DATA                  ; Inicializa el segmento de datos
mov DS,AX                     
mov ES,AX                     

fld _1
fstp b

fld _30
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
jne branch30

branch23:

displayString S_true_1
NEWLINE
fld _23_11
fstp f

jmp branch44

branch30:

fld f
fstp @ifI

fld _102_3
fstp @ifD

fld @ifI
fld @ifD
fxch
fcom
fstsw AX
sahf
jae branch42

fld f
fstp @ifI

fld _0_3
fstp @ifD

fld @ifI
fld @ifD
fxch
fcom
fstsw AX
sahf
jne branch42

displayString S_true_1
NEWLINE
branch42:

displayString S_false_2
NEWLINE
branch44:

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
jae branch61

displayFloat a,2
NEWLINE
displayString S_a_es_menor_a_diez_3
NEWLINE
fld a
fld _1
fadd
fstp a

jmp branch44

branch61:

fld a
fstp @ifI

fld b
fld _2
fmul
fld _30
fadd
fstp @ifD

fld @ifI
fld @ifD
fxch
fcom
fstsw AX
sahf
jb branch83

fld a
fstp @ifI

fld a
fld b
fadd
fld c
fadd
fld _2
fmul
fstp @ifD

fld @ifI
fld @ifD
fxch
fcom
fstsw AX
sahf
ja branch83

displayString S_between_4
NEWLINE
branch83:

fld _2
fld _3
fmul
fstp @varFact

fld @varFact
fstp @auxFact

fld @varFact
fstp @resFact

fld @auxFact
fstp @ifI

fld _1
fstp @ifD

fld @ifI
fld @ifD
fxch
fcom
fstsw AX
sahf
ja branch104

fld _1
fstp @resFact

jmp branch124

branch104:

fld @auxFact
fstp @ifI

fld _2
fstp @ifD

fld @ifI
fld @ifD
fxch
fcom
fstsw AX
sahf
jbe branch124

fld @resFact
fld @auxFact
fld _1
fsub
fmul
fstp @resFact

fld @auxFact
fld _1
fsub
fstp @auxFact

jmp branch104

branch124:

fld @resFact
fstp d

displayString S_El_factorial_es__5
NEWLINE
displayFloat d,2
NEWLINE
displayString S_fin_del_programa_6
NEWLINE

mov AX,4C00h                  ; Indica que debe finalizar la ejecución
int 21h

END inicio