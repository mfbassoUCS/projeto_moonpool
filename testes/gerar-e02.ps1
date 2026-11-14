$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$source = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'E02BASE.ASM'))
function Save-Ascii($name, $text) {
    [IO.File]::WriteAllText((Join-Path $PSScriptRoot $name), ($text -replace '\r?\n',"`r`n"), [Text.Encoding]::ASCII)
}
# Tamanhos reais: o montador rejeita reservas/bitmaps fora das medidas.
$assertions = @'
IF (bitmapJipeFim-bitmapJipe) NE 200
 .ERR
ENDIF
IF (bitmapNave1Fim-bitmapNave1) NE 196
 .ERR
ENDIF
IF (bitmapNave2Fim-bitmapNave2) NE 196
 .ERR
ENDIF
IF (bitmapNave3Fim-bitmapNave3) NE 196
 .ERR
ENDIF
IF (bitmapVidas2-bitmapVidas3) NE 198
 .ERR
ENDIF
IF (bitmapVidas1-bitmapVidas2) NE 198
 .ERR
ENDIF
IF (bitmapRelogio-bitmapVidas1) NE 198
 .ERR
ENDIF
IF (bitmapCratera1-bitmapRelogio) NE 56
 .ERR
ENDIF
IF (bitmapCratera2-bitmapCratera1) NE 98
 .ERR
ENDIF
IF (bitmapCratera3-bitmapCratera2) NE 98
 .ERR
ENDIF
IF (bitmapRocha1-bitmapCratera3) NE 98
 .ERR
ENDIF
IF (bitmapRocha2-bitmapRocha1) NE 120
 .ERR
ENDIF
IF (bitmapRocha3-bitmapRocha2) NE 120
 .ERR
ENDIF
IF (bitmapRocha4-bitmapRocha3) NE 120
 .ERR
ENDIF
IF (bitmapsFim-bitmapRocha4) NE 120
 .ERR
ENDIF
IF (bitmapMontanhasFim-bitmapMontanhas) NE (320*64)
 .ERR
ENDIF
IF (bitmapMontesFim-bitmapMontes) NE (320*32)
 .ERR
ENDIF
'@
$memData = @'
pixelsTeste db 0FFh,0
indiceCaso dw 0
casos dw 319,199,2,1, 0,200,1,1, 0,0,0,1, 0,0,1,0
      dw 0,0,321,1, 0,0,1,201, 65535,0,1,1, 0,65535,1,1
quadrosRestantes dw 400
voltas dw 4 dup(0)
memOk db 'PASS MEM: dimensoes; FF transparente/00 opaco; DF; 8 invalidos;',13,10
      db 'sobreposicao; 400 quadros/2 voltas cada; fundo inteiro; guarda 1000.',13,10,'$'
memErro db 'FAIL MEM',13,10,'$'
.fardata videoTeste
    db 65000 dup(?)
.code
'@
$mem = $source.Replace('.code', $assertions + "`r`n" + $memData)
$main = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'E02MEM.INC'))
$mem = [regex]::Replace($mem, '(?s)inicio proc.*?inicio endp', [Text.RegularExpressions.MatchEvaluator]{ param($m) $main })
Save-Ascii 'E02MEM.ASM' $mem
$autoData = @'
faseTeste db 0
quadroTeste dw 0
nomeInicial db 'MENU0.RAW',0
nomeCiclo db 'MENU2.RAW',0
nomeSelecao db 'SELECAO.RAW',0
nomeSetor db 'SETOR.RAW',0
nomeFim db 'FIM.RAW',0
nomeRetorno db 'RETORNO.RAW',0
scoreEsperado db '12345'
scoreZero db '00000'
scoreMaximo db '65535'
autoOk db 'PASS AUTO: 320 quadros por ticks; cima/baixo/Enter; setor/fim/menu;',13,10
       db 'buffer antigo limpo; 2 demos; score 0/12345/65535; Sair pelo laco real.',13,10,'$'
autoErro db 'FAIL AUTO',13,10,'$'
.code
'@
$auto = $source.Replace('.code',$autoData)
$auto = $auto.Replace("    call EntrarMenu`r`nciclo:", "    call TestarGaleria`r`n    call EntrarMenu`r`n    lea dx,nomeInicial`r`n    call SalvarTelaTeste`r`nciclo:")
$auto = $auto.Replace("ciclo:`r`n", "ciclo:`r`n    call DirigirTeste`r`n")
$auto = $auto.Replace('    call MoverSpritesMenu', "    call MoverSpritesMenu`r`n    inc quadroTeste")
$auto = $auto.Replace('    mov ax,4C00h', "    lea dx,autoOk`r`n    mov ah,09h`r`n    int 21h`r`n    mov ax,4C00h")
$helpers = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'E02AUTO.INC'))
$helpers += "`r`n" + [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'E02ART.INC'))
$auto = $auto.Replace('end inicio', $helpers + "`r`nend inicio")
Save-Ascii 'E02AUTO.ASM' $auto
Get-FileHash (Join-Path $PSScriptRoot 'E02BASE.ASM') | Format-List | Out-String | Set-Content (Join-Path $PSScriptRoot 'E02-FONTE.txt')
Write-Output 'Gerados E02MEM.ASM e E02AUTO.ASM a partir do snapshot E02BASE.ASM.'
