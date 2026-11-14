@echo off
echo inicio > ENSAIO.LOG
tasm JOLD.ASM >> ENSAIO.LOG
if errorlevel 1 goto falha
tlink JOLD.OBJ >> ENSAIO.LOG
if errorlevel 1 goto falha
tasm JNEW.ASM >> ENSAIO.LOG
if errorlevel 1 goto falha
tlink JNEW.OBJ >> ENSAIO.LOG
if errorlevel 1 goto falha
z:\config.com -set "cpu cycles=3000"
z:\config.com -get "cpu cycles" > ANTAUTO.CPU
JOLD
if errorlevel 1 goto falha
copy SALTO.BIN ANTAUTOS.BIN > nul
copy TEMPO.BIN ANTAUTOT.BIN > nul
z:\config.com -set "cpu cycles=50000"
z:\config.com -get "cpu cycles" > ANTFAST.CPU
JOLD
if errorlevel 1 goto falha
copy SALTO.BIN ANTFASTS.BIN > nul
copy TEMPO.BIN ANTFASTT.BIN > nul
z:\config.com -set "cpu cycles=50000"
z:\config.com -get "cpu cycles" > NOVFAST.CPU
JNEW
if errorlevel 1 goto falha
copy SALTO.BIN NOVFASTS.BIN > nul
copy TEMPO.BIN NOVFASTT.BIN > nul
echo PASS ENSAIO >> ENSAIO.LOG
goto fim
:falha
echo FAIL ENSAIO >> ENSAIO.LOG
:fim
