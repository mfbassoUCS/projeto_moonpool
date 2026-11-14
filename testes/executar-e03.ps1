$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
& (Join-Path $PSScriptRoot 'gerar-e03.ps1')
# Marcas externas: FileSystemWatcher recebe escritas reais, sem usar hora DOS.
# Pequeno auxiliar de testes Windows; nao e dependencia do EXE.
Add-Type -TypeDefinition @'
using System;
using System.IO;
using System.Diagnostics;
using System.Collections.Concurrent;
public class MarcasE03 : IDisposable {
    FileSystemWatcher w;
    Stopwatch s = Stopwatch.StartNew();
    public ConcurrentQueue<string> Linhas = new ConcurrentQueue<string>();
    public MarcasE03(string pasta) {
        w = new FileSystemWatcher(pasta, "E03*.BIN");
        w.NotifyFilter = NotifyFilters.LastWrite | NotifyFilters.Size | NotifyFilters.FileName;
        w.Created += Marca;
        w.Changed += Marca;
        w.EnableRaisingEvents = true;
    }
    void Marca(object sender, FileSystemEventArgs e) {
        if (e.Name == "E03HOST.BIN" || e.Name == "E03TEMPO.BIN")
            Linhas.Enqueue(e.Name + " " + s.Elapsed.TotalSeconds.ToString("F6", System.Globalization.CultureInfo.InvariantCulture));
    }
    public void Dispose() { w.Dispose(); }
}
'@
$watch = New-Object MarcasE03 $PSScriptRoot
try {
    $proc = Start-Process -FilePath (Join-Path $root 'ferramentas/guitasm/BIN/guiTasmX64.exe') -WorkingDirectory $root -ArgumentList '-conf ferramentas\e03.conf -c "cd testes" -c "call E03TEST.BAT" -c exit' -WindowStyle Hidden -PassThru
    $proc.WaitForExit()
} finally {
    $watch.Dispose()
    $watch.Linhas.ToArray() | Set-Content -Encoding ASCII (Join-Path $PSScriptRoot 'E03HOST.LOG')
}
Get-Content (Join-Path $PSScriptRoot 'E03RESUL.LOG')
