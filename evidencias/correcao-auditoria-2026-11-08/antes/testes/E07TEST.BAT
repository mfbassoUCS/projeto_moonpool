@echo off
echo E07 - inicio > E07RESUL.LOG
call R07TEST.BAT
config -set "cpu cycles=50000"
tasm E07LOG.ASM > E07LOG.LOG
if errorlevel 1 goto falha
tlink /m E07LOG.OBJ >> E07LOG.LOG
if errorlevel 1 goto falha
E07LOG >> E07RESUL.LOG
if errorlevel 1 goto falha
tasm E07PIX.ASM > E07PIX.LOG
if errorlevel 1 goto falha
tlink /m E07PIX.OBJ >> E07PIX.LOG
if errorlevel 1 goto falha
E07PIX >> E07RESUL.LOG
if errorlevel 1 goto falha
tasm E07MEM.ASM > E07MEM.LOG
if errorlevel 1 goto falha
tlink /m E07MEM.OBJ >> E07MEM.LOG
if errorlevel 1 goto falha
E07MEM >> E07RESUL.LOG
if errorlevel 1 goto falha
tasm E07TELA.ASM > E07TELA.LOG
if errorlevel 1 goto falha
tlink /m E07TELA.OBJ >> E07TELA.LOG
if errorlevel 1 goto falha
config -set "cpu cycles=auto"
E07TELA >> E07RESUL.LOG
if errorlevel 1 goto falha
MODO >> E07RESUL.LOG
if errorlevel 1 goto falha
echo PASS E07 >> E07RESUL.LOG
goto fim
:falha
echo FAIL E07 >> E07RESUL.LOG
:fim
config -set "cpu cycles=auto"
