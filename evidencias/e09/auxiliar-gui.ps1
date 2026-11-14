param([string]$Action='inspect',[int]$Item=0)
Add-Type @"
using System;using System.Runtime.InteropServices;
public class AccE09 {
[DllImport("oleacc.dll")] public static extern int AccessibleObjectFromWindow(IntPtr h,uint id,ref Guid iid,[MarshalAs(UnmanagedType.Interface)] out object o);
public static object Get(long h){Guid g=new Guid("618736e0-3c3d-11cf-810c-00aa00389b71");object o;AccessibleObjectFromWindow(new IntPtr(h),0xfffffffc,ref g,out o);return o;}
}
"@
Add-Type -AssemblyName UIAutomationClient
$proc=Get-Process -Id (Get-Content "$PSScriptRoot/gui-pid.txt")
$w=[System.Windows.Automation.AutomationElement]::FromHandle([IntPtr]329298)
$all=$w.FindAll([System.Windows.Automation.TreeScope]::Descendants,[System.Windows.Automation.Condition]::TrueCondition)
if($Action -eq 'toolbar') { $bar=$all | Where-Object {$_.Current.Name -eq 'IDE Menubar'}; [AccE09]::Get($bar.Current.NativeWindowHandle).accDoDefaultAction($Item) }
elseif($Action -eq 'file') { $bar=$all | Where-Object {$_.Current.Name -eq 'menuStrip1'}; [AccE09]::Get($bar.Current.NativeWindowHandle).accDoDefaultAction(1) }
elseif($Action -eq 'output') { $all | Where-Object {$_.Current.Name -like '### Welcome*'} | ForEach-Object {$_.Current.Name} }
else { foreach($e in $all) { $c=$e.Current; "$($c.NativeWindowHandle) | $($c.ControlType.ProgrammaticName) | $($c.Name)" } }
