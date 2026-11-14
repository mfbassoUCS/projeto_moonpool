@echo off
tasm BASE.ASM > BASE.LOG
if errorlevel 1 goto falha
tlink BASE.OBJ >> BASE.LOG
if errorlevel 1 goto falha
BASE > RESULT.LOG
if errorlevel 1 goto falha
tasm ESC.ASM > ESC.LOG
if errorlevel 1 goto falha
tlink ESC.OBJ >> ESC.LOG
if errorlevel 1 goto falha
tasm MODO.ASM > MODO.LOG
if errorlevel 1 goto falha
tlink MODO.OBJ >> MODO.LOG
if errorlevel 1 goto falha
ESC
if errorlevel 1 goto falha
MODO >> RESULT.LOG
if errorlevel 1 goto falha
tasm TEMPO2.ASM > TEMPO2.LOG
if errorlevel 1 goto falha
tlink TEMPO2.OBJ >> TEMPO2.LOG
if errorlevel 1 goto falha
tasm TEMPO4.ASM > TEMPO4.LOG
if errorlevel 1 goto falha
tlink TEMPO4.OBJ >> TEMPO4.LOG
if errorlevel 1 goto falha
TEMPO2 > TEMPO2.TXT
TEMPO4 > TEMPO4.TXT
echo PASS: sequencia de testes encerrada >> RESULT.LOG
goto fim
:falha
echo FAIL: montagem ou execucao >> RESULT.LOG
:fim
type RESULT.LOG
