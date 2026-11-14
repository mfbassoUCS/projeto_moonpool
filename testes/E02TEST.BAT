@echo off
echo E02 - inicio > E02RESUL.LOG
rem Acelera apenas as varreduras exaustivas de RAM; menu volta a cycles=auto.
config -set "cpu cycles=50000"
tasm E02MEM.ASM > E02MEM.LOG
if errorlevel 1 goto falha
tlink E02MEM.OBJ >> E02MEM.LOG
if errorlevel 1 goto falha
E02MEM >> E02RESUL.LOG
if errorlevel 1 goto falha
tasm E02AUTO.ASM > E02AUTO.LOG
if errorlevel 1 goto falha
tlink E02AUTO.OBJ >> E02AUTO.LOG
if errorlevel 1 goto falha
config -set "cpu cycles=auto"
E02AUTO >> E02RESUL.LOG
if errorlevel 1 goto falha
tasm MODO.ASM > MODO.LOG
if errorlevel 1 goto falha
tlink MODO.OBJ >> MODO.LOG
if errorlevel 1 goto falha
MODO >> E02RESUL.LOG
if errorlevel 1 goto falha
echo PASS E02: sequencia encerrada >> E02RESUL.LOG
goto fim
:falha
echo FAIL E02: montagem ou execucao >> E02RESUL.LOG
:fim
type E02RESUL.LOG
