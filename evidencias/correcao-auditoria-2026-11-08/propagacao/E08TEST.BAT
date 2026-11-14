@echo off
if exist E08.OK del E08.OK
echo E08 - inicio > E08RESUL.LOG
if exist N08.OK del N08.OK
call N08TEST.BAT
if not exist N08.OK goto falha
config -set "cpu cycles=50000"
tasm E08LOG.ASM > E08LOG.LOG
if errorlevel 1 goto falha
tlink /m E08LOG.OBJ >> E08LOG.LOG
if errorlevel 1 goto falha
E08LOG >> E08RESUL.LOG
if errorlevel 1 goto falha
tasm E08PIX.ASM > E08PIX.LOG
if errorlevel 1 goto falha
tlink /m E08PIX.OBJ >> E08PIX.LOG
if errorlevel 1 goto falha
E08PIX >> E08RESUL.LOG
if errorlevel 1 goto falha
tasm E08AUTO.ASM > E08AUTO.LOG
if errorlevel 1 goto falha
tlink /m E08AUTO.OBJ >> E08AUTO.LOG
if errorlevel 1 goto falha
E08AUTO >> E08RESUL.LOG
if errorlevel 1 goto falha
MODO >> E08RESUL.LOG
if errorlevel 1 goto falha
echo PASS E08 >> E08RESUL.LOG
echo PASS > E08.OK
goto fim
:falha
echo FAIL E08 >> E08RESUL.LOG
:fim
