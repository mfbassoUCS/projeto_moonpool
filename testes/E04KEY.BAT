@echo off
tasm E04KEY.ASM > E04KEY.LOG
if errorlevel 1 goto falha
tlink /m E04KEY.OBJ >> E04KEY.LOG
if errorlevel 1 goto falha
E04KEY > E04KRES.LOG
if errorlevel 1 goto falha
goto fim
:falha
echo FAIL KEY >> E04KRES.LOG
:fim