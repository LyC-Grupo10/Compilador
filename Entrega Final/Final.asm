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

pos: 0, valor: a 
pos: 1, valor: 5 
pos: 2, valor: CMP 
pos: 3, valor: BLE 
pos: 4, valor: 15 
pos: 5, valor: c 
pos: 6, valor: 10 
pos: 7, valor: CMP 
pos: 8, valor: BGT 
pos: 9, valor: 15 
pos: 10, valor: 5 
pos: 11, valor: = 
pos: 12, valor: c 
pos: 13, valor: BI 
pos: 14, valor: 35 
pos: 15, valor: a 
pos: 16, valor: 10 
pos: 17, valor: CMP 
pos: 18, valor: BLT 
pos: 19, valor: 25 
pos: 20, valor: a 
pos: 21, valor: 3 
pos: 22, valor: CMP 
pos: 23, valor: BNE 
pos: 24, valor: 30 
pos: 25, valor: 10 
pos: 26, valor: = 
pos: 27, valor: c 
pos: 28, valor: BI 
pos: 29, valor: 32 
pos: 30, valor: "else" 
DISPLAY en assembler
pos: 31, valor: DISPLAY 
pos: 32, valor: 7 
pos: 33, valor: = 
pos: 34, valor: i 
pos: 35, valor: ET 
pos: 36, valor: a 
pos: 37, valor: 1 
pos: 38, valor: CMP 
pos: 39, valor: BGT 
pos: 40, valor: 46 
pos: 41, valor: b 
pos: 42, valor: 1 
pos: 43, valor: CMP 
pos: 44, valor: BLE 
pos: 45, valor: 70 
pos: 46, valor: ET 
pos: 47, valor: c 
pos: 48, valor: 1 
pos: 49, valor: CMP 
pos: 50, valor: BLE 
pos: 51, valor: 68 
pos: 52, valor: 1 
pos: 53, valor: = 
pos: 54, valor: x 
pos: 55, valor: c 
pos: 56, valor: 10 
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
pos: 70, valor: i 
pos: 71, valor: 3 
pos: 72, valor: CMP 
pos: 73, valor: BLT 
pos: 74, valor: 86 
pos: 75, valor: i 
pos: 76, valor: c 
pos: 77, valor: 2 
pos: 78, valor: * 
pos: 79, valor: a 
pos: 80, valor: + 
pos: 81, valor: CMP 
pos: 82, valor: BGT 
pos: 83, valor: 86 
pos: 84, valor: "Test" 
DISPLAY en assembler
pos: 85, valor: DISPLAY 
pos: 86, valor: a 
DISPLAY en assembler
pos: 87, valor: DISPLAY 
pos: 88, valor: z 
GET en assembler
pos: 89, valor: GET 
pos: 90, valor: a 
pos: 91, valor: b 
pos: 92, valor: + 
pos: 93, valor: = 
pos: 94, valor: var 
pos: 95, valor: var 
pos: 96, valor: = 
pos: 97, valor: aux 
pos: 98, valor: var 
pos: 99, valor: = 
pos: 100, valor: res 
pos: 101, valor: ET 
pos: 102, valor: aux 
pos: 103, valor: 2 
pos: 104, valor: CMP 
pos: 105, valor: BLE 
pos: 106, valor: 121 
pos: 107, valor: res 
pos: 108, valor: aux 
pos: 109, valor: 1 
pos: 110, valor: - 
pos: 111, valor: * 
pos: 112, valor: = 
pos: 113, valor: res 
pos: 114, valor: aux 
pos: 115, valor: 1 
pos: 116, valor: - 
pos: 117, valor: = 
pos: 118, valor: aux 
pos: 119, valor: BI 
pos: 120, valor: 101 
pos: 121, valor: res 
pos: 122, valor: = 
pos: 123, valor: a 
pos: 124, valor: a 
pos: 125, valor: = 
pos: 126, valor: varN 
pos: 127, valor: b 
pos: 128, valor: = 
pos: 129, valor: varM 
pos: 130, valor: = 
pos: 131, valor: varN 
pos: 132, valor: varN 
pos: 133, valor: = 
pos: 134, valor: aux 
pos: 135, valor: varN 
pos: 136, valor: = 
pos: 137, valor: resN 
pos: 138, valor: ET 
pos: 139, valor: aux 
pos: 140, valor: 2 
pos: 141, valor: CMP 
pos: 142, valor: BLE 
pos: 143, valor: 158 
pos: 144, valor: resN 
pos: 145, valor: aux 
pos: 146, valor: 1 
pos: 147, valor: - 
pos: 148, valor: * 
pos: 149, valor: = 
pos: 150, valor: resN 
pos: 151, valor: aux 
pos: 152, valor: 1 
pos: 153, valor: - 
pos: 154, valor: = 
pos: 155, valor: aux 
pos: 156, valor: BI 
pos: 157, valor: 138 
pos: 158, valor: = 
pos: 159, valor: varM 
pos: 160, valor: varM 
pos: 161, valor: = 
pos: 162, valor: aux 
pos: 163, valor: varM 
pos: 164, valor: = 
pos: 165, valor: resM 
pos: 166, valor: ET 
pos: 167, valor: aux 
pos: 168, valor: 2 
pos: 169, valor: CMP 
pos: 170, valor: BLE 
pos: 171, valor: 186 
pos: 172, valor: resM 
pos: 173, valor: aux 
pos: 174, valor: 1 
pos: 175, valor: - 
pos: 176, valor: * 
pos: 177, valor: = 
pos: 178, valor: resM 
pos: 179, valor: aux 
pos: 180, valor: 1 
pos: 181, valor: - 
pos: 182, valor: = 
pos: 183, valor: aux 
pos: 184, valor: BI 
pos: 185, valor: 166 
pos: 186, valor: varN 
pos: 187, valor: varM 
pos: 188, valor: - 
pos: 189, valor: = 
pos: 190, valor: varNM 
pos: 191, valor: varNM 
pos: 192, valor: = 
pos: 193, valor: aux 
pos: 194, valor: varNM 
pos: 195, valor: = 
pos: 196, valor: resNM 
pos: 197, valor: ET 
pos: 198, valor: aux 
pos: 199, valor: 2 
pos: 200, valor: CMP 
pos: 201, valor: BLE 
pos: 202, valor: 217 
pos: 203, valor: resNM 
pos: 204, valor: aux 
pos: 205, valor: 1 
pos: 206, valor: - 
pos: 207, valor: * 
pos: 208, valor: = 
pos: 209, valor: resNM 
pos: 210, valor: aux 
pos: 211, valor: 1 
pos: 212, valor: - 
pos: 213, valor: = 
pos: 214, valor: aux 
pos: 215, valor: BI 
pos: 216, valor: 197 
pos: 217, valor: resN 
pos: 218, valor: resM 
pos: 219, valor: / 
pos: 220, valor: resNM 
pos: 221, valor: / 
pos: 222, valor: = 
pos: 223, valor: c 
mov AX,4C00h                  ; Indica que debe finalizar la ejecución
int 21h

END