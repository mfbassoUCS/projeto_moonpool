@echo off
tasm E08KEY.ASM > E08KEY.LOG
if errorlevel 1 goto falha
tlink /m E08KEY.OBJ >> E08KEY.LOG
if errorlevel 1 goto falha
E08KEY > E08KRES.LOG
if errorlevel 1 goto falha
goto fim
:falha
echo FAIL KEY >> E08KRES.LOG
:fim