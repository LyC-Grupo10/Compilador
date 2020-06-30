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
_5             dd             5.0            ; Constante int
_10            dd             10.0           ; Constante int
_3             dd             3.0            ; Constante int
_else          db             "else", '$', 4 dup (?); Constante string
_7             dd             7.0            ; Constante int
_1             dd             1.0            ; Constante int
_menor         db             "menor", '$', 5 dup (?); Constante string
_mayor         db             "mayor", '$', 5 dup (?); Constante string
_2             dd             2.0            ; Constante int
_Test          db             "Test", '$', 4 dup (?); Constante string
@var           dd             ?              ; Variable int 
@aux           dd             ?              ; Variable int 
@res           dd             ?              ; Variable int 
@varN          dd             ?              ; Variable int 
@resN          dd             ?              ; Variable int 
@varM          dd             ?              ; Variable int 
@resM          dd             ?              ; Variable int 
@varNM         dd             ?              ; Variable int 
@resNM         dd             ?              ; Variable int 

.CODE

inicio:

mov AX,@DATA                  ; Inicializa el segmento de datos
mov DS,AX                     
mov ES,AX                     

fld a
fld _5
fld c
fld _10
fld _5
fstp c

fld a
fld _10
fld a
fld _3
fld _10
fstp c

displayString "Hola"

fld _7
fstp i

fld a
fld _1
fld b
fld _1
fld c
fld _1
fld _1
fstp x

fld c
fld _10
displayString "Hola"

displayString "Hola"

fld i
fld _3
fld i
fld c
fld _2
fmul
fld a
fadd
displayString "Hola"

displayFloat a,2

fld z
GET en assembler
fld a
fld b
fadd
fstp @var

fld @var
fstp @aux

fld @var
fstp @res

fld @aux
fld _2
fld @res
fld @aux
fld _1
fsub
fmul
fstp @res

fld @aux
fld _1
fsub
fstp @aux

fld @res
fstp a

fld a
fstp @varN

fld b
fstp @varM

fstp @varN

fld @varN
fstp @aux

fld @varN
fstp @resN

fld @aux
fld _2
fld @resN
fld @aux
fld _1
fsub
fmul
fstp @resN

fld @aux
fld _1
fsub
fstp @aux

fstp @varM

fld @varM
fstp @aux

fld @varM
fstp @resM

fld @aux
fld _2
fld @resM
fld @aux
fld _1
fsub
fmul
fstp @resM

fld @aux
fld _1
fsub
fstp @aux

fld @varN
fld @varM
fsub
fstp @varNM

fld @varNM
fstp @aux

fld @varNM
fstp @resNM

fld @aux
fld _2
fld @resNM
fld @aux
fld _1
fsub
fmul
fstp @resNM

fld @aux
fld _1
fsub
fstp @aux

fld @resN
fld @resM
fdiv
fld @resNM
fdiv
fstp c

mov AX,4C00h                  ; Indica que debe finalizar la ejecución
int 21h

END inicio