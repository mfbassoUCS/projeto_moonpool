@echo off
echo E06 - inicio > E06RESUL.LOG
call R06TEST.BAT
config -set "cpu cycles=50000"
tasm E06LOG.ASM > E06LOG.LOG
if errorlevel 1 goto falha
tlink /m E06LOG.OBJ >> E06LOG.LOG
if errorlevel 1 goto falha
E06LOG >> E06RESUL.LOG
if errorlevel 1 goto falha
tasm E06PIX.ASM > E06PIX.LOG
if errorlevel 1 goto falha
tlink /m E06PIX.OBJ >> E06PIX.LOG
if errorlevel 1 goto falha
E06PIX >> E06RESUL.LOG
if errorlevel 1 goto falha
echo PASS E06 >> E06RESUL.LOG
goto fim
:falha
echo FAIL E06 >> E06RESUL.LOG
:fim
config -set "cpu cycles=auto"
