param([int]$ProcessId=11928,[int]$Vk=13,[int]$Scan=28,[switch]$Up)
Add-Type @"
using System;using System.Runtime.InteropServices;
public class KeyE09 {[DllImport("user32.dll")] public static extern bool PostMessage(IntPtr h,uint m,IntPtr w,IntPtr l);}
"@
$p=Get-Process -Id $ProcessId
if($p.ProcessName -ne 'guiTasmX64'){throw 'Destino deve ser o emulador desta verificacao.'}
$bits=1L -bor ($Scan -shl 16)
if($Vk -in @(37,38,39,40)){$bits=$bits -bor 0x01000000L}
$msg=0x100
if($Up){$bits=$bits -bor 0xC0000000L;$msg=0x101}
if(-not [KeyE09]::PostMessage($p.MainWindowHandle,$msg,[IntPtr]$Vk,[IntPtr]$bits)){throw 'Evento nao enviado'}
"PostMessage PID=$ProcessId VK=$Vk scan=$Scan soltura=$Up" | Add-Content "$PSScriptRoot/gui-eventos.log"
