@echo off
echo R08 - inicio > R08RESUL.LOG
config -set "cpu cycles=50000"
tasm R08REG.ASM > R08REG.LOG
if errorlevel 1 goto falha
tlink /m R08REG.OBJ >> R08REG.LOG
if errorlevel 1 goto falha
R08REG >> R08RESUL.LOG
if errorlevel 1 goto falha
tasm R08JIPE.ASM > R08JIPE.LOG
if errorlevel 1 goto falha
tlink /m R08JIPE.OBJ >> R08JIPE.LOG
if errorlevel 1 goto falha
R08JIPE >> R08RESUL.LOG
if errorlevel 1 goto falha
tasm R08LOG.ASM > R08LOG.LOG
if errorlevel 1 goto falha
tlink /m R08LOG.OBJ >> R08LOG.LOG
if errorlevel 1 goto falha
R08LOG >> R08RESUL.LOG
if errorlevel 1 goto falha
tasm R08PIX.ASM > R08PIX.LOG
if errorlevel 1 goto falha
tlink /m R08PIX.OBJ >> R08PIX.LOG
if errorlevel 1 goto falha
R08PIX >> R08RESUL.LOG
if errorlevel 1 goto falha
tasm R08AUTO.ASM > R08AUTO.LOG
if errorlevel 1 goto falha
tlink /m R08AUTO.OBJ >> R08AUTO.LOG
if errorlevel 1 goto falha
config -set "cpu cycles=auto"
R08AUTO >> R08RESUL.LOG
if errorlevel 1 goto falha
MODO >> R08RESUL.LOG
if errorlevel 1 goto falha
echo PASS R08 >> R08RESUL.LOG
goto fim
:falha
echo FAIL R08 >> R08RESUL.LOG
:fim
config -set "cpu cycles=auto"
