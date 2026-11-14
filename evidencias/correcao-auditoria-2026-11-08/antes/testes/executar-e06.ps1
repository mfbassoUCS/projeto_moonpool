$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
python (Join-Path $PSScriptRoot 'gerar-e06.py')
if ($LASTEXITCODE -ne 0) { throw 'Falha na geracao E06.' }
$proc = Start-Process -FilePath (Join-Path $root 'ferramentas/guitasm/BIN/guiTasmX64.exe') -WorkingDirectory $root -ArgumentList '-conf ferramentas\e06.conf -c "cd testes" -c "call E06TEST.BAT" -c exit' -WindowStyle Hidden -PassThru
$proc.WaitForExit()
Get-Content (Join-Path $root 'MONTAGEM.LOG'), (Join-Path $root 'LINK.LOG'), (Join-Path $PSScriptRoot 'R06RESUL.LOG'), (Join-Path $PSScriptRoot 'E06RESUL.LOG')
foreach ($test in @('R06','E06')) {
    $result = Get-Content -Raw (Join-Path $PSScriptRoot ($test+'RESUL.LOG'))
    if ($result -match 'FAIL' -or $result -notmatch "(?m)^PASS $test\s*$") { throw "$test nao passou; conferir logs." }
}
