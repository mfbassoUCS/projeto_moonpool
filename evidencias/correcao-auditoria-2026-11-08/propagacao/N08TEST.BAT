@echo off
if exist N08.OK del N08.OK
echo N08 - inicio > N08RESUL.LOG
if exist R08.OK del R08.OK
call R08TEST.BAT
if not exist R08.OK goto falha
config -set "cpu cycles=50000"
tasm N08LOG.ASM > N08LOG.LOG
if errorlevel 1 goto falha
tlink /m N08LOG.OBJ >> N08LOG.LOG
if errorlevel 1 goto falha
N08LOG >> N08RESUL.LOG
if errorlevel 1 goto falha
tasm N08PIX.ASM > N08PIX.LOG
if errorlevel 1 goto falha
tlink /m N08PIX.OBJ >> N08PIX.LOG
if errorlevel 1 goto falha
N08PIX >> N08RESUL.LOG
if errorlevel 1 goto falha
tasm N08MEM.ASM > N08MEM.LOG
if errorlevel 1 goto falha
tlink /m N08MEM.OBJ >> N08MEM.LOG
if errorlevel 1 goto falha
N08MEM >> N08RESUL.LOG
if errorlevel 1 goto falha
tasm N08TELA.ASM > N08TELA.LOG
if errorlevel 1 goto falha
tlink /m N08TELA.OBJ >> N08TELA.LOG
if errorlevel 1 goto falha
N08TELA >> N08RESUL.LOG
if errorlevel 1 goto falha
MODO >> N08RESUL.LOG
if errorlevel 1 goto falha
echo PASS N08 >> N08RESUL.LOG
echo PASS > N08.OK
goto fim
:falha
echo FAIL N08 >> N08RESUL.LOG
:fim
