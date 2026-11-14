@echo off
echo inicio > AJUSTE.LOG
z:\config.com -get "cpu cycles" >> AJUSTE.LOG
echo. >> AJUSTE.LOG
tasm E08LOG.ASM > E08LOG.LOG
if errorlevel 1 goto falha
tlink /m E08LOG.OBJ >> E08LOG.LOG
if errorlevel 1 goto falha
E08LOG >> AJUSTE.LOG
if errorlevel 1 goto falha
tasm E08PIX.ASM > E08PIX.LOG
if errorlevel 1 goto falha
tlink /m E08PIX.OBJ >> E08PIX.LOG
if errorlevel 1 goto falha
E08PIX >> AJUSTE.LOG
if errorlevel 1 goto falha
tasm AJAUTO.ASM > AJAUTO.LOG
if errorlevel 1 goto falha
tlink /m AJAUTO.OBJ >> AJAUTO.LOG
if errorlevel 1 goto falha
AJAUTO >> AJUSTE.LOG
if errorlevel 1 goto falha
tasm AJNAVE.ASM > AJNAVE.LOG
if errorlevel 1 goto falha
tlink /m AJNAVE.OBJ >> AJNAVE.LOG
if errorlevel 1 goto falha
AJNAVE >> AJUSTE.LOG
if errorlevel 1 goto falha
MODO >> AJUSTE.LOG
if errorlevel 1 goto falha
echo PASS AJUSTE >> AJUSTE.LOG
goto fim
:falha
echo FAIL AJUSTE >> AJUSTE.LOG
:fim
