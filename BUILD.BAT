@echo off
rem Executar dentro do DOSBox com BIN do GUI Turbo Assembler no PATH.
tasm /l MOON.ASM > MONTAGEM.LOG
if errorlevel 1 goto falha
tlink /m MOON.OBJ > LINK.LOG
if errorlevel 1 goto falha
echo Montagem e link concluidos.
goto fim
:falha
echo Falha. Confira MONTAGEM.LOG e LINK.LOG. Nao execute EXE antigo.
:fim
