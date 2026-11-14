@echo off
config -set "cpu cycles=50000"
echo Regressao final E05 > E05RRES.LOG
tasm E05REG.ASM > E05REG.LOG
if errorlevel 1 goto falha
tlink /m E05REG.OBJ >> E05REG.LOG
if errorlevel 1 goto falha
E05REG >> E05RRES.LOG
if errorlevel 1 goto falha
tasm E05JIPE.ASM > E05JIPE.LOG
if errorlevel 1 goto falha
tlink /m E05JIPE.OBJ >> E05JIPE.LOG
if errorlevel 1 goto falha
E05JIPE >> E05RRES.LOG
if errorlevel 1 goto falha
echo PASS REGRESSAO E05 >> E05RRES.LOG
goto fim
:falha
echo FAIL REGRESSAO E05 >> E05RRES.LOG
:fim
config -set "cpu cycles=auto"
