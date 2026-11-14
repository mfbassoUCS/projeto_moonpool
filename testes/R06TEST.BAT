@echo off
echo R06 - inicio > R06RESUL.LOG
config -set "cpu cycles=50000"
tasm R06REG.ASM > R06REG.LOG
if errorlevel 1 goto falha
tlink /m R06REG.OBJ >> R06REG.LOG
if errorlevel 1 goto falha
R06REG >> R06RESUL.LOG
if errorlevel 1 goto falha
tasm R06JIPE.ASM > R06JIPE.LOG
if errorlevel 1 goto falha
tlink /m R06JIPE.OBJ >> R06JIPE.LOG
if errorlevel 1 goto falha
R06JIPE >> R06RESUL.LOG
if errorlevel 1 goto falha
tasm R06LOG.ASM > R06LOG.LOG
if errorlevel 1 goto falha
tlink /m R06LOG.OBJ >> R06LOG.LOG
if errorlevel 1 goto falha
R06LOG >> R06RESUL.LOG
if errorlevel 1 goto falha
tasm R06PIX.ASM > R06PIX.LOG
if errorlevel 1 goto falha
tlink /m R06PIX.OBJ >> R06PIX.LOG
if errorlevel 1 goto falha
R06PIX >> R06RESUL.LOG
if errorlevel 1 goto falha
tasm R06AUTO.ASM > R06AUTO.LOG
if errorlevel 1 goto falha
tlink /m R06AUTO.OBJ >> R06AUTO.LOG
if errorlevel 1 goto falha
config -set "cpu cycles=auto"
R06AUTO >> R06RESUL.LOG
if errorlevel 1 goto falha
MODO >> R06RESUL.LOG
if errorlevel 1 goto falha
echo PASS R06 >> R06RESUL.LOG
goto fim
:falha
echo FAIL R06 >> R06RESUL.LOG
:fim
config -set "cpu cycles=auto"
