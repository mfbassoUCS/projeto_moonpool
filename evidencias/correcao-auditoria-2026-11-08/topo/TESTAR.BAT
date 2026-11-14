@echo off
tasm TOPO.ASM > TOPO.LOG
if errorlevel 1 goto falha
tlink /m TOPO.OBJ >> TOPO.LOG
if errorlevel 1 goto falha
TOPO >> TOPO.LOG
if errorlevel 1 goto falha
goto fim
:falha
echo FAIL BUILD/EXEC >> TOPO.LOG
:fim
