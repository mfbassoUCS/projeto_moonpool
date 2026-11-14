@echo off
echo R07 - inicio > R07RESUL.LOG
config -set "cpu cycles=50000"
tasm R07REG.ASM > R07REG.LOG
if errorlevel 1 goto falha
tlink /m R07REG.OBJ >> R07REG.LOG
if errorlevel 1 goto falha
R07REG >> R07RESUL.LOG
if errorlevel 1 goto falha
tasm R07JIPE.ASM > R07JIPE.LOG
if errorlevel 1 goto falha
tlink /m R07JIPE.OBJ >> R07JIPE.LOG
if errorlevel 1 goto falha
R07JIPE >> R07RESUL.LOG
if errorlevel 1 goto falha
tasm R07LOG.ASM > R07LOG.LOG
if errorlevel 1 goto falha
tlink /m R07LOG.OBJ >> R07LOG.LOG
if errorlevel 1 goto falha
R07LOG >> R07RESUL.LOG
if errorlevel 1 goto falha
tasm R07PIX.ASM > R07PIX.LOG
if errorlevel 1 goto falha
tlink /m R07PIX.OBJ >> R07PIX.LOG
if errorlevel 1 goto falha
R07PIX >> R07RESUL.LOG
if errorlevel 1 goto falha
tasm R07AUTO.ASM > R07AUTO.LOG
if errorlevel 1 goto falha
tlink /m R07AUTO.OBJ >> R07AUTO.LOG
if errorlevel 1 goto falha
config -set "cpu cycles=auto"
R07AUTO >> R07RESUL.LOG
if errorlevel 1 goto falha
MODO >> R07RESUL.LOG
if errorlevel 1 goto falha
echo PASS R07 >> R07RESUL.LOG
goto fim
:falha
echo FAIL R07 >> R07RESUL.LOG
:fim
config -set "cpu cycles=auto"
