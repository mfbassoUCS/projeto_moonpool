@echo off
echo E03 - inicio > E03RESUL.LOG
config -set "cpu cycles=50000"
tasm E03MEM.ASM > E03MEM.LOG
if errorlevel 1 goto falha
tlink /m E03MEM.OBJ >> E03MEM.LOG
if errorlevel 1 goto falha
E03MEM >> E03RESUL.LOG
if errorlevel 1 goto falha
tasm E03AUTO.ASM > E03AUTO.LOG
if errorlevel 1 goto falha
tlink /m E03AUTO.OBJ >> E03AUTO.LOG
if errorlevel 1 goto falha
tasm E03T2.ASM > E03T2.LOG
if errorlevel 1 goto falha
tlink /m E03T2.OBJ >> E03T2.LOG
if errorlevel 1 goto falha
tasm E03T4.ASM > E03T4.LOG
if errorlevel 1 goto falha
tlink /m E03T4.OBJ >> E03T4.LOG
if errorlevel 1 goto falha
config -set "cpu cycles=auto"
E03T2 >> E03RESUL.LOG
if errorlevel 1 goto falha
copy E03TEMPO.BIN TEMPOE32.BIN > NUL
copy E03HOST.BIN HOSTE32.BIN > NUL
E03T4 >> E03RESUL.LOG
if errorlevel 1 goto falha
copy E03TEMPO.BIN TEMPOE34.BIN > NUL
copy E03HOST.BIN HOSTE34.BIN > NUL
E03AUTO >> E03RESUL.LOG
if errorlevel 1 goto falha
MODO >> E03RESUL.LOG
if errorlevel 1 goto falha
echo PASS E03 >> E03RESUL.LOG
goto fim
:falha
echo FAIL E03: montagem ou execucao >> E03RESUL.LOG
:fim
config -set "cpu cycles=auto"
type E03RESUL.LOG
