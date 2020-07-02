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
_30             dd             30.0            ; Constante int
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
_@calc  dd  ?

.CODE

inicio:

mov AX,@DATA                  ; Inicializa el segmento de datos
mov DS,AX                     
mov ES,AX                     

fld _1
fstp a
fld _1
fstp b

ffree

; empieza mi comparacion
;parte izquierda:
; 2*a+30

fld _2
fld a
fmul
fld _30
fadd

fld _2
fld a
fmul
fld _30
fadd
fld _5
fld a
fld b
fadd
fmul
fld _1
fsub
fstp @res
displayFloat @res, 2

mov AX,4C00h                  ; Indica que debe finalizar la ejecuci?n
int 21h

END inicio