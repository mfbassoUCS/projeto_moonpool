$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
python (Join-Path $PSScriptRoot 'gerar-e07.py')
if ($LASTEXITCODE -ne 0) { throw 'Falha na geracao E07.' }
$proc = Start-Process -FilePath (Join-Path $root 'ferramentas/guitasm/BIN/guiTasmX64.exe') -WorkingDirectory $root -ArgumentList '-conf ferramentas\e07.conf -c "cd testes" -c "call E07TEST.BAT" -c exit' -WindowStyle Hidden -PassThru
$proc.WaitForExit()
Get-Content (Join-Path $root 'MONTAGEM.LOG'), (Join-Path $root 'LINK.LOG'), (Join-Path $PSScriptRoot 'R07RESUL.LOG'), (Join-Path $PSScriptRoot 'E07RESUL.LOG')
foreach ($test in @('R07','E07')) {
    $result = Get-Content -Raw (Join-Path $PSScriptRoot ($test+'RESUL.LOG'))
    if ($result -match 'FAIL' -or $result -notmatch "(?m)^PASS $test\s*$") { throw "$test nao passou; conferir logs." }
}
