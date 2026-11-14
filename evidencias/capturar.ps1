param([string]$Processo = 'GUI Turbo Assembler', [string]$Arquivo = 'gui.png', [int]$ProcessId = 0)
$ErrorActionPreference = 'Stop'
# Auxilio de verificacao do ambiente Windows; nao faz parte do jogo.
Add-Type -AssemblyName System.Drawing
Add-Type -TypeDefinition 'using System; using System.Runtime.InteropServices; public class CaptureE01 { [DllImport("user32.dll")] public static extern bool PrintWindow(IntPtr h, IntPtr dc, uint f); [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r); public struct RECT { public int L,T,R,B; } }'
$process = if ($ProcessId) { Get-Process -Id $ProcessId } else { Get-Process $Processo | Select-Object -First 1 }
$windowHandle = $process.MainWindowHandle
$rect = New-Object CaptureE01+RECT
[CaptureE01]::GetWindowRect($windowHandle, [ref]$rect) | Out-Null
$bmp = New-Object Drawing.Bitmap ($rect.R-$rect.L),($rect.B-$rect.T)
$graphics = [Drawing.Graphics]::FromImage($bmp)
$dc = $graphics.GetHdc()
[CaptureE01]::PrintWindow($windowHandle, $dc, 2) | Out-Null
$graphics.ReleaseHdc($dc)
$bmp.Save((Join-Path $PSScriptRoot $Arquivo))
$graphics.Dispose()
$bmp.Dispose()
