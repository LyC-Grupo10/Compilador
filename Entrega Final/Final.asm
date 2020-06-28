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
_var           dd             ?              ; Variable int 
_aux           dd             ?              ; Variable int 
_res           dd             ?              ; Variable int 
_varN          dd             ?              ; Variable int 
_resN          dd             ?              ; Variable int 
_varM          dd             ?              ; Variable int 
_resM          dd             ?              ; Variable int 
_varNM         dd             ?              ; Variable int 
_resNM         dd             ?              ; Variable int 

.CODE

mov AX,@DATA                  ; Inicializa el segmento de datos
mov DS,AX                     
mov es,ax                     

pos: 1, valor: 5 
pos: 2, valor: CMP 
pos: 3, valor: BLE 
pos: 4, valor: 15 
pos: 6, valor: 10 
pos: 7, valor: CMP 
pos: 8, valor: BGT 
pos: 9, valor: 15 
pos: 11, valor: = 
pos: 13, valor: BI 
pos: 14, valor: 35 
pos: 16, valor: 10 
pos: 17, valor: CMP 
pos: 18, valor: BLT 
pos: 19, valor: 25 
pos: 21, valor: 3 
pos: 22, valor: CMP 
pos: 23, valor: BNE 
pos: 24, valor: 30 
pos: 26, valor: = 
pos: 28, valor: BI 
pos: 29, valor: 32 
pos: 30, valor: "else" 
DISPLAY en assembler
pos: 31, valor: DISPLAY 
pos: 33, valor: = 
pos: 35, valor: ET 
pos: 37, valor: 1 
pos: 38, valor: CMP 
pos: 39, valor: BGT 
pos: 40, valor: 46 
pos: 42, valor: 1 
pos: 43, valor: CMP 
pos: 44, valor: BLE 
pos: 45, valor: 70 
pos: 46, valor: ET 
pos: 48, valor: 1 
pos: 49, valor: CMP 
pos: 50, valor: BLE 
pos: 51, valor: 68 
pos: 53, valor: = 
pos: 55, valor: c 
pos: 57, valor: CMP 
pos: 58, valor: BGE 
pos: 59, valor: 64 
pos: 60, valor: "menor" 
DISPLAY en assembler
pos: 61, valor: DISPLAY 
pos: 62, valor: BI 
pos: 63, valor: 66 
pos: 64, valor: "mayor" 
DISPLAY en assembler
pos: 65, valor: DISPLAY 
pos: 66, valor: BI 
pos: 67, valor: 46 
pos: 68, valor: BI 
pos: 69, valor: 35 
pos: 71, valor: 3 
pos: 72, valor: CMP 
pos: 73, valor: BLT 
pos: 74, valor: 86 
pos: 76, valor: c 
pos: 78, valor: * 
pos: 80, valor: + 
pos: 81, valor: CMP 
pos: 82, valor: BGT 
pos: 83, valor: 86 
pos: 84, valor: "Test" 
DISPLAY en assembler
pos: 85, valor: DISPLAY 
pos: 87, valor: DISPLAY 
pos: 89, valor: GET 
pos: 91, valor: b 
pos: 92, valor: + 
FSTP var
pos: 95, valor: var 
FSTP aux
pos: 98, valor: var 
FSTP res
pos: 101, valor: ET 
pos: 103, valor: 2 
pos: 104, valor: CMP 
pos: 105, valor: BLE 
pos: 106, valor: 121 
pos: 108, valor: aux 
pos: 110, valor: - 
pos: 111, valor: * 
FSTP res
pos: 114, valor: aux 
pos: 116, valor: - 
FSTP aux
pos: 119, valor: BI 
pos: 120, valor: 101 
pos: 122, valor: = 
pos: 124, valor: a 
FSTP varN
pos: 127, valor: b 
FSTP varM
pos: 130, valor: = 
pos: 132, valor: varN 
FSTP aux
pos: 135, valor: varN 
FSTP resN
pos: 138, valor: ET 
pos: 140, valor: 2 
pos: 141, valor: CMP 
pos: 142, valor: BLE 
pos: 143, valor: 158 
pos: 145, valor: aux 
pos: 147, valor: - 
pos: 148, valor: * 
FSTP resN
pos: 151, valor: aux 
pos: 153, valor: - 
FSTP aux
pos: 156, valor: BI 
pos: 157, valor: 138 
FSTP varM
pos: 160, valor: varM 
FSTP aux
pos: 163, valor: varM 
FSTP resM
pos: 166, valor: ET 
pos: 168, valor: 2 
pos: 169, valor: CMP 
pos: 170, valor: BLE 
pos: 171, valor: 186 
pos: 173, valor: aux 
pos: 175, valor: - 
pos: 176, valor: * 
FSTP resM
pos: 179, valor: aux 
pos: 181, valor: - 
FSTP aux
pos: 184, valor: BI 
pos: 185, valor: 166 
pos: 187, valor: varM 
pos: 188, valor: - 
FSTP varNM
pos: 191, valor: varNM 
FSTP aux
pos: 194, valor: varNM 
FSTP resNM
pos: 197, valor: ET 
pos: 199, valor: 2 
pos: 200, valor: CMP 
pos: 201, valor: BLE 
pos: 202, valor: 217 
pos: 204, valor: aux 
pos: 206, valor: - 
pos: 207, valor: * 
FSTP resNM
pos: 210, valor: aux 
pos: 212, valor: - 
FSTP aux
pos: 215, valor: BI 
pos: 216, valor: 197 
pos: 218, valor: resM 
pos: 219, valor: / 
pos: 221, valor: / 
FSTP c
pos: 224, valor:  
pos: 225, valor:  
pos: 226, valor:  
pos: 227, valor:  
pos: 228, valor:  
pos: 229, valor:  
pos: 230, valor:  
pos: 231, valor:  
pos: 232, valor:  
pos: 233, valor:  
pos: 234, valor:  
pos: 235, valor:  
pos: 236, valor:  
pos: 237, valor:  
pos: 238, valor:  
pos: 239, valor:  
pos: 240, valor:  
pos: 241, valor:  
pos: 242, valor:  
pos: 243, valor:  
pos: 244, valor:  
pos: 245, valor:  
mov AX,4C00h                  ; Indica que debe finalizar la ejecución
int 21h

END