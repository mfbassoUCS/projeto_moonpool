@echo off
rem Atalho Windows: monta no emulador do GUI Turbo Assembler.
rem No prompt DOS resultante, digite MOON e pressione Enter.
start "" "%~dp0ferramentas\guitasm\BIN\guiTasmX64.exe" -conf "%~dp0ferramentas\e01.conf"
