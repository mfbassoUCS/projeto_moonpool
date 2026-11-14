$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
python (Join-Path $PSScriptRoot 'gerar-e08.py')
if ($LASTEXITCODE -ne 0) { throw 'Falha na geracao E08.' }
$signal = Join-Path $PSScriptRoot 'E08SINAL.BIN'
if (Test-Path -LiteralPath $signal) { Remove-Item -LiteralPath $signal }
$proc = Start-Process -FilePath (Join-Path $root 'ferramentas/guitasm/BIN/guiTasmX64.exe') -WorkingDirectory $root -ArgumentList '-conf ferramentas\e08.conf -c "cd testes" -c "call E08TEST.BAT" -c exit' -WindowStyle Hidden -PassThru
$deadline = [Diagnostics.Stopwatch]::StartNew()
$watch = $null
$elapsed = $null
try {
    while (-not $proc.HasExited) {
        if ($deadline.Elapsed.TotalSeconds -gt 600) { throw 'Timeout E08; conferir logs.' }
        if (Test-Path -LiteralPath $signal) {
            # O DOSBox pode manter o sinal aberto durante esta amostra.
            # Repetir a leitura no proximo polling, sem abortar o jogo/teste.
            try { $bytes = [IO.File]::ReadAllBytes($signal) }
            catch [IO.IOException] { $bytes = @() }
            if ($bytes.Length -eq 1) {
                if ($bytes[0] -eq 1 -and $null -eq $watch) { $watch = [Diagnostics.Stopwatch]::StartNew() }
                if ($bytes[0] -eq 2 -and $null -eq $elapsed -and $null -ne $watch) { $elapsed = $watch.Elapsed.TotalSeconds }
            }
        }
        Start-Sleep -Milliseconds 10
    }
} finally {
    if (-not $proc.HasExited) { Stop-Process -Id $proc.Id }
}
if ($null -eq $elapsed) { throw 'Sinais de tempo E08 incompletos.' }
@{segundos=$elapsed;metodo='Stopwatch Windows entre sinais DOS; polling 10 ms'} | ConvertTo-Json | Set-Content -Encoding UTF8 (Join-Path $PSScriptRoot 'E08HOST.json')
Get-Content (Join-Path $root 'MONTAGEM.LOG'), (Join-Path $root 'LINK.LOG')
foreach ($test in @('R08','N08','E08')) {
    $result = Get-Content -Raw (Join-Path $PSScriptRoot ($test+'RESUL.LOG'))
    Write-Output $result
    if ($result -match 'FAIL' -or $result -notmatch "(?m)^PASS $test\s*$") { throw "$test nao passou; conferir logs." }
}
