@echo off
echo E05 - inicio > E05RESUL.LOG
config -set "cpu cycles=50000"
tasm E05REG.ASM > E05REG.LOG
if errorlevel 1 goto falha
tlink /m E05REG.OBJ >> E05REG.LOG
if errorlevel 1 goto falha
E05REG >> E05RESUL.LOG
if errorlevel 1 goto falha
tasm E05JIPE.ASM > E05JIPE.LOG
if errorlevel 1 goto falha
tlink /m E05JIPE.OBJ >> E05JIPE.LOG
if errorlevel 1 goto falha
E05JIPE >> E05RESUL.LOG
if errorlevel 1 goto falha
tasm E05LOG.ASM > E05LOG.LOG
if errorlevel 1 goto falha
tlink /m E05LOG.OBJ >> E05LOG.LOG
if errorlevel 1 goto falha
E05LOG >> E05RESUL.LOG
if errorlevel 1 goto falha
tasm E05PIX.ASM > E05PIX.LOG
if errorlevel 1 goto falha
tlink /m E05PIX.OBJ >> E05PIX.LOG
if errorlevel 1 goto falha
E05PIX >> E05RESUL.LOG
if errorlevel 1 goto falha
tasm E05AUTO.ASM > E05AUTO.LOG
if errorlevel 1 goto falha
tlink /m E05AUTO.OBJ >> E05AUTO.LOG
if errorlevel 1 goto falha
config -set "cpu cycles=auto"
E05AUTO >> E05RESUL.LOG
if errorlevel 1 goto falha
MODO >> E05RESUL.LOG
if errorlevel 1 goto falha
echo PASS E05 >> E05RESUL.LOG
goto fim
:falha
echo FAIL E05 >> E05RESUL.LOG
:fim
config -set "cpu cycles=auto"
