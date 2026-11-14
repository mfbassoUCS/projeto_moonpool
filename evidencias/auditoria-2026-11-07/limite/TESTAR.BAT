@echo off
tasm LIMITE.ASM > LIMITE.LOG
if errorlevel 1 goto falha
tlink LIMITE.OBJ >> LIMITE.LOG
if errorlevel 1 goto falha
LIMITE >> LIMITE.LOG
if errorlevel 1 goto falha
goto fim
:falha
echo FAIL BUILD/EXEC >> LIMITE.LOG
:fim
