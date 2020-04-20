c:\GnuWin32\bin\flex lexico.l
pause
c:\GnuWin32\bin\bison -dyv sintactico.y
pause
c:\MinGW\bin\gcc.exe lex.yy.c y.tab.c -o PrimeraEntrega.exe
pause
PrimeraEntrega.exe Prueba.txt
del lex.yy.c
del y.tab.c
del y.output
del y.tab.h
del PrimeraEntrega.exe
pause