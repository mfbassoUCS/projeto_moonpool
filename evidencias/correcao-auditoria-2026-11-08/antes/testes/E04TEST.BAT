@echo off
echo E04 - inicio > E04RESUL.LOG
config -set "cpu cycles=50000"
tasm E04REG.ASM > E04REG.LOG
if errorlevel 1 goto falha
tlink /m E04REG.OBJ >> E04REG.LOG
if errorlevel 1 goto falha
E04REG >> E04RESUL.LOG
if errorlevel 1 goto falha
tasm E04MEM.ASM > E04MEM.LOG
if errorlevel 1 goto falha
tlink /m E04MEM.OBJ >> E04MEM.LOG
if errorlevel 1 goto falha
E04MEM >> E04RESUL.LOG
if errorlevel 1 goto falha
tasm E04AUTO.ASM > E04AUTO.LOG
if errorlevel 1 goto falha
tlink /m E04AUTO.OBJ >> E04AUTO.LOG
if errorlevel 1 goto falha
tasm E04T2.ASM > E04T2.LOG
if errorlevel 1 goto falha
tlink /m E04T2.OBJ >> E04T2.LOG
if errorlevel 1 goto falha
tasm E04T4.ASM > E04T4.LOG
if errorlevel 1 goto falha
tlink /m E04T4.OBJ >> E04T4.LOG
if errorlevel 1 goto falha
config -set "cpu cycles=auto"
E04T2 >> E04RESUL.LOG
if errorlevel 1 goto falha
copy E04TEMPO.BIN TEMPOE42.BIN > NUL
copy E04HOST.BIN HOSTE42.BIN > NUL
E04T4 >> E04RESUL.LOG
if errorlevel 1 goto falha
copy E04TEMPO.BIN TEMPOE44.BIN > NUL
copy E04HOST.BIN HOSTE44.BIN > NUL
E04AUTO >> E04RESUL.LOG
if errorlevel 1 goto falha
MODO >> E04RESUL.LOG
if errorlevel 1 goto falha
echo PASS E04 >> E04RESUL.LOG
goto fim
:falha
echo FAIL E04: montagem ou execucao >> E04RESUL.LOG
:fim
config -set "cpu cycles=auto"
type E04RESUL.LOG
