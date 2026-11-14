$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$source = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'E04BASE.ASM'))
$data = @'
etapaKey db 0
esperadoKey dw 0
nomeKey db 'E04KEY.SIG',0
keyOk db 'PASS KEY: IRQ1, simultaneas, soltura, novo salto, retorno BIOS.',13,10,'$'
keyErro db 'FAIL KEY',13,10,'$'
.code
jumps
'@
$source = $source.Replace('.code',$data)
$main = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'E04KEY.INC'))
$source = [regex]::Replace($source,'(?s)inicio proc.*?inicio endp',[Text.RegularExpressions.MatchEvaluator]{param($m) $main})
[IO.File]::WriteAllText((Join-Path $PSScriptRoot 'E04KEY.ASM'),$source,[Text.Encoding]::ASCII)
$batch = @'
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
'@
[IO.File]::WriteAllText((Join-Path $PSScriptRoot 'E04KEY.BAT'),($batch -replace '\r?\n',"`r`n"),[Text.Encoding]::ASCII)
$signal = Join-Path $PSScriptRoot 'E04KEY.SIG'
if (Test-Path -LiteralPath $signal) { Remove-Item -LiteralPath $signal }
Add-Type @'
using System;
using System.Runtime.InteropServices;
public static class TeclasE04 {
    public delegate bool EnumProc(IntPtr hWnd, IntPtr lParam);
    [DllImport("user32.dll")] public static extern bool EnumWindows(EnumProc callback, IntPtr param);
    [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint id);
    public static IntPtr Window(int pid) {
        IntPtr found = IntPtr.Zero;
        EnumWindows((h, p) => { uint id; GetWindowThreadProcessId(h, out id);
            if (id == pid) { found = h; return false; } return true; }, IntPtr.Zero);
        return found;
    }
    [DllImport("user32.dll", SetLastError=true)]
    public static extern bool PostMessage(IntPtr hWnd, uint msg, IntPtr wParam, IntPtr lParam);
}
'@
$driverAnterior = $env:SDL_VIDEODRIVER
try {
    # SDL DirectInput ignora WM_KEYDOWN. Windib permite eventos direcionados
    # a janela oculta do teste, sem tomar o foco nem digitar em outro aplicativo.
    $env:SDL_VIDEODRIVER = 'windib'
    $proc = Start-Process -FilePath (Join-Path $root 'ferramentas/guitasm/BIN/guiTasmX64.exe') -WorkingDirectory $root -ArgumentList '-conf ferramentas\e04.conf -c "cd testes" -c "call E04KEY.BAT" -c exit' -WindowStyle Hidden -PassThru
} finally {
    $env:SDL_VIDEODRIVER = $driverAnterior
}
function Key($vk,$scan,$up) {
    $proc.Refresh()
    $bits = 1L -bor ($scan -shl 16)
    if ($vk -ne 13) { $bits = $bits -bor 0x01000000L }
    if ($up) { $bits = $bits -bor 0xC0000000L; $msg = 0x101 } else { $msg = 0x100 }
    $handle = [TeclasE04]::Window($proc.Id)
    if ($handle -eq [IntPtr]::Zero) { throw 'Janela DOSBox nao encontrada' }
    if (-not [TeclasE04]::PostMessage($handle,$msg,[IntPtr]$vk,[IntPtr]$bits)) { throw 'PostMessage falhou' }
}
$deadline = [Diagnostics.Stopwatch]::StartNew()
$last = -1
try {
    while (-not $proc.HasExited) {
        if ($deadline.Elapsed.TotalSeconds -gt 55) { throw 'Timeout de teclado E04; conferir logs/sinal' }
        if (Test-Path -LiteralPath $signal) {
            $bytes = [IO.File]::ReadAllBytes($signal)
            if ($bytes.Length -eq 1 -and $bytes[0] -ne $last) {
                $last = [int]$bytes[0]
                Write-Output "IRQ: etapa $last"
                switch ($last) {
                    0 { Key 39 77 $false }
                    1 { Key 38 72 $false }
                    2 { Key 39 77 $true; Key 37 75 $false }
                    3 { Key 37 75 $true; Key 38 72 $true }
                    4 { Key 38 72 $false }
                    5 { Key 38 72 $true; Key 13 28 $false; Key 13 28 $true }
                }
            }
        }
        Start-Sleep -Milliseconds 30
    }
} finally {
    if (-not $proc.HasExited) { Stop-Process -Id $proc.Id }
}
$result = Get-Content (Join-Path $PSScriptRoot 'E04KRES.LOG') -Raw
Write-Output $result
if ($result -notmatch 'PASS KEY' -or $result -match 'FAIL') { throw 'Teste IRQ nao passou' }
