c:\GnuWin32\bin\flex Lexico.l
c:\GnuWin32\bin\bison -dyv Sintactico.y
c:\MinGW\bin\gcc.exe lex.yy.c y.tab.c -o Juntito.exe
del lex.yy.c
del y.tab.c
del y.tab.h
del y.output

