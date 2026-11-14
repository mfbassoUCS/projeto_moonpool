$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
python (Join-Path $PSScriptRoot 'gerar-e05.py')
if ($LASTEXITCODE -ne 0) { throw 'Falha na geracao E05.' }
$proc = Start-Process -FilePath (Join-Path $root 'ferramentas/guitasm/BIN/guiTasmX64.exe') -WorkingDirectory $root -ArgumentList '-conf ferramentas\e05.conf -c "cd testes" -c "call E05TEST.BAT" -c exit' -WindowStyle Hidden -PassThru
$proc.WaitForExit()
Get-Content (Join-Path $root 'MONTAGEM.LOG'), (Join-Path $root 'LINK.LOG'), (Join-Path $PSScriptRoot 'E05RESUL.LOG')
if ((Get-Content -Raw (Join-Path $PSScriptRoot 'E05RESUL.LOG')) -notmatch '(?m)^PASS E05\s*$') { throw 'E05 nao passou; conferir logs.' }
