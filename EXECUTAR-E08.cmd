@echo off
rem Confira os logs; no prompt DOS digite MOON.
start "" /D "%~dp0." "%~dp0ferramentas\guitasm\BIN\guiTasmX64.exe" -conf "%~dp0ferramentas\e08.conf"
