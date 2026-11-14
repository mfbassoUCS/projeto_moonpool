$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$source = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'E03BASE.ASM'))
function Save-Ascii($name, $text) {
    [IO.File]::WriteAllText((Join-Path $PSScriptRoot $name), ($text -replace '\r?\n',"`r`n"), [Text.Encoding]::ASCII)
}
$memData = @'
passoTeste dw 0
faseMem db 0
relogioLo dw 0
relogioHi dw 0
memOk db 'PASS MEM: 320 quadros/2 voltas; todos os pixels; HUD/ceu; guarda;',13,10
      db 'offsets 1/319; FF/00; 99/100/350 centesimos; pausa; meia-noite.',13,10,'$'
memErro db 'FAIL MEM fase='
erroFase db '?',13,10,'$'
.fardata videoTeste
    db 65000 dup(?)
.fardata referencia
    db 32000 dup(?)
.code
jumps
'@
$mem = $source.Replace('.code',$memData)
$main = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'E03MEM.INC'))
$mem = [regex]::Replace($mem, '(?s)inicio proc.*?inicio endp', [Text.RegularExpressions.MatchEvaluator]{ param($m) $main })
# So a fonte de teste usa hora sintetica; subtracao/consumo sao os reais.
$mem = $mem.Replace('call LerCentissegundos','call LerHoraTeste')
Save-Ascii 'E03MEM.ASM' $mem
$autoData = @'
faseAuto db 0
quadrosAuto dw 0
voltasAuto dw 0
inicioRealLo dw 0
inicioRealHi dw 0
fimRealLo dw 0
fimRealHi dw 0
tempoVisto dw 0
ultimoDump dw 65535
registro dw 0,0,0,0,0,0
nomeInicial db 'E03INI.RAW',0
nomeEmenda db 'E03EMEN.RAW',0
nomeVolta db 'E03VOLTA.RAW',0
nomeDois db 'E03DOIS.RAW',0
nomeFim db 'E03FIM.RAW',0
nomeVidas2 db 'E03VID2.RAW',0
nomeVidas1 db 'E03VID1.RAW',0
nomeVidas0 db 'E03VID0.RAW',0
nomeTempo db 'E03TEMPO.BIN',0
nomeInicioHost db 'E03HOST.BIN',0
autoOk db 'PASS AUTO: fluxo real; segundos; expiracao; score; reset; Sair.',13,10,'$'
autoErro db 'FAIL AUTO fase='
autoFaseErro db '?',13,10,'$'
.code
jumps
'@
$helpers = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'E03AUTO.INC'))
foreach ($variant in @(@('E03AUTO',45,2),@('E03T2',4,2),@('E03T4',4,4))) {
    $auto = $source.Replace('.code',$autoData)
    $auto = $auto.Replace('DURACAO_SEGUNDOS equ 90',('DURACAO_SEGUNDOS equ '+$variant[1]))
    $auto = $auto.Replace('TICKS_CENARIO    equ 2',('TICKS_CENARIO    equ '+$variant[2]))
    $auto = $auto.Replace("ciclo:`r`n", "ciclo:`r`n    call DirigirE03`r`n")
    $auto = $auto.Replace('    call AvancarCenario', "    call AvancarCenario`r`n    inc quadrosAuto`r`n    cmp rolagem,0`r`n    jne autoNaoVoltou`r`n    inc voltasAuto`r`nautoNaoVoltou:")
    # Registrar instante imediatamente antes de o fluxo real entrar no FIM.
    $auto = $auto.Replace('partidaExpirou:', "partidaExpirou:`r`n    call RegistrarFim")
    $auto = $auto.Replace('    mov ax,4C00h', "    lea dx,autoOk`r`n    mov ah,09h`r`n    int 21h`r`n    mov ax,4C00h")
    $auto = $auto.Replace('end inicio', $helpers + "`r`nend inicio")
    Save-Ascii ($variant[0]+'.ASM') $auto
}
Get-FileHash (Join-Path $PSScriptRoot 'E03BASE.ASM') | Format-List | Out-String | Set-Content (Join-Path $PSScriptRoot 'E03-FONTE.txt')
Write-Output 'Gerados E03MEM/E03AUTO/E03T2/E03T4; fonte principal preservado.'
