@echo off
echo N08 - inicio > N08RESUL.LOG
call R08TEST.BAT
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
config -set "cpu cycles=auto"
N08TELA >> N08RESUL.LOG
if errorlevel 1 goto falha
MODO >> N08RESUL.LOG
if errorlevel 1 goto falha
echo PASS N08 >> N08RESUL.LOG
goto fim
:falha
echo FAIL N08 >> N08RESUL.LOG
:fim
config -set "cpu cycles=auto"
