# Reproduz a validacao historica da E01 a partir do snapshot E01BASE.ASM.
# Nao altera o fonte entregue e nao adiciona dependencias ao jogo.
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$source = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'E01BASE.ASM'))
function Save-Ascii($name, $text) {
    [IO.File]::WriteAllText((Join-Path $PSScriptRoot $name), ($text -replace '\r?\n',"`r`n"), [Text.Encoding]::ASCII)
}
$testData = @'
testeOk db 'PASS: limites, fundo, DF, teclado e retorno das rotinas',13,10,'$'
testeErro db 'FAIL: verificacao da base',13,10,'$'
casos dw 313,192,8,8, 312,193,8,8, 0,0,0,8, 0,0,8,0
      dw 0,0,321,1, 0,0,1,201, 65535,0,8,8, 0,65535,8,8
indice dw 0
.fardata videoTeste
    db 65000 dup(55h)
.code
'@
$testMain = @'
inicio proc
    mov ax,@data
    mov ds,ax
    mov ax,videoTeste
    mov es,ax
    cld
    ; Canto inferior direito valido. Salvar os 64 bytes antes do desenho.
    mov ax,312
    mov bx,192
    mov cx,8
    mov dx,8
    lea si,fundoSalvo
    call SalvarFundo
    lea si,bitmapTeste
    call DesenharBitmap
    ; Contar todos os pixels: exatamente 64 amarelos e resto 55h.
    xor di,di
    xor bx,bx
    mov cx,64999
varrerDesenho:
    mov al,es:[di]
    cmp al,COR_TESTE
    jne conferirFundo
    inc bx
    jmp proximoPixel
conferirFundo:
    cmp al,55h
    jne falhaPerto1
proximoPixel:
    inc di
    loop varrerDesenho
    cmp byte ptr es:[di],55h
    jne falhaPerto1
    cmp bx,64
    jne falhaPerto1
    mov di,63999
    cmp byte ptr es:[di],COR_TESTE
    jne falhaPerto1
    mov ax,312
    mov bx,192
    mov cx,8
    mov dx,8
    lea si,fundoSalvo
    call DesenharBitmap
    call ConferirIntacto
    jmp testarInvalidos
falhaPerto1:
    jmp falha
testarInvalidos:
    mov di,indice
    mov ax,casos[di]
    mov bx,casos[di+2]
    mov cx,casos[di+4]
    mov dx,casos[di+6]
    lea si,bitmapTeste
    std
    call DesenharBitmap
    pushf
    pop ax
    test ax,0400h
    jnz falhaPerto2
    call ConferirIntacto
    add indice,8
    cmp indice,64
    jb testarInvalidos
    ; Limpar buffer, verificar retorno sem tecla e injetar letra/seta/Esc.
limparTeclas:
    mov ah,01h
    int 16h
    jz semTecla
    mov ah,00h
    int 16h
    jmp limparTeclas
semTecla:
    call LerTeclado
    cmp estado,ESTADO_DEMO
    jne falhaPerto2
    mov cx,1E61h
    call InjetarTecla
    call LerTeclado
    cmp estado,ESTADO_DEMO
    jne falhaPerto2
    mov cx,4B00h
    call InjetarTecla
    call LerTeclado
    cmp estado,ESTADO_DEMO
    jne falhaPerto2
    mov cx,011Bh
    call InjetarTecla
    call LerTeclado
    cmp estado,ESTADO_SAIR
    jne falhaPerto2
    lea dx,testeOk
    mov ah,09h
    int 21h
    mov ax,4C00h
    int 21h
falhaPerto2:
    jmp falha
inicio endp
; Funcao: verificar os 64000 bytes visiveis e 1000 bytes de guarda.
; Entrada: ES=videoTeste. Saida: retorna se intacto, encerra com erro se nao.
; Altera: AX,CX,DI,flags.
ConferirIntacto proc near
    xor di,di
    mov cx,64999
    mov al,55h
    cld
    repe scasb
    jne falha
    cmp byte ptr es:[di],55h
    jne falha
    ret
ConferirIntacto endp
; Funcao: inserir tecla no buffer do BIOS, sem depender do foco do Windows.
; Entrada: CH=scan code, CL=ASCII. Saida: tecla inserida ou erro DOS.
; Altera: AX,flags.
InjetarTecla proc near
    mov ah,05h
    int 16h
    cmp al,0
    jne falha
    ret
InjetarTecla endp
falha:
    cld
    lea dx,testeErro
    mov ah,09h
    int 21h
    mov ax,4C01h
    int 21h
'@
$test = $source.Replace('.code',$testData)
$test = [regex]::Replace($test,'(?s)inicio proc.*?inicio endp',$testMain)
Save-Ascii 'BASE.ASM' $test
# Variante identica do programa: a unica adicao injeta Esc antes da entrada.
$escape = $source.Replace('inicio proc', "inicio proc`r`n    mov cx,011Bh`r`n    mov ah,05h`r`n    int 16h")
Save-Ascii 'ESC.ASM' $escape
# Variantes de observacao: encerram em 5 segundos e imprimem X e segundos.
$report = @'
    mov ax,posX
    call NumeroTeste
    mov ax,segundos
    call NumeroTeste
    mov ax,4C00h
'@
$numberRoutine = @'
; Funcao: imprimir word decimal com 5 digitos e espaco para o log.
; Entrada: AX=numero. Saida: texto DOS. Altera: AX,BX,CX,DX,DI,flags.
NumeroTeste proc near
    mov bx,10
    mov cx,5
    lea di,digitos+4
ntDiv:
    xor dx,dx
    div bx
    add dl,'0'
    mov [di],dl
    dec di
    loop ntDiv
    lea di,digitos
    mov cx,5
ntPrint:
    mov dl,[di]
    mov ah,02h
    int 21h
    inc di
    loop ntPrint
    mov dl,' '
    mov ah,02h
    int 21h
    ret
NumeroTeste endp
end inicio
'@
$timed = $source.Replace('    call AtualizarTempo',"    call AtualizarTempo`r`n    cmp segundos,5`r`n    jb continuarTeste`r`n    jmp sair`r`ncontinuarTeste:")
$timed = $timed.Replace('    mov ax, 4C00h',$report).Replace('end inicio',$numberRoutine)
Save-Ascii 'TEMPO2.ASM' $timed
Save-Ascii 'TEMPO4.ASM' $timed.Replace('TICKS_MOVIMENTO equ 2','TICKS_MOVIMENTO equ 4')
