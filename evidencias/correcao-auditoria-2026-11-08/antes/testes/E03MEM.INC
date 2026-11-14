; Harness independente do jogo, com RAM de video e referencia separadas.
; Funcao: testar pixels, limites e tempo. Entrada: nenhuma. Saida: DOS PASS/FAIL.
inicio proc
    mov ax,@data
    mov ds,ax
    mov ax,videoTeste
    mov es,ax
    cld
    xor di,di
    mov al,55h
    mov cx,64000
    rep stosb
    mov al,0AAh
    mov cx,1000
    rep stosb
    call DesenharCenario
    push ds
    push es
    mov ax,videoTeste
    mov ds,ax
    mov ax,referencia
    mov es,ax
    mov si,32000
    xor di,di
    mov cx,32000
    rep movsb
    pop es
    pop ds
memQuadro:
    call AvancarCenario
    call DesenharCenario
    call CompararCenario
    inc passoTeste
    cmp passoTeste,320
    jb memQuadro
    cmp rolagem,0
    jne memFalha
    mov faseMem,1
    mov rolagem,1
    call DesenharCenario
    call CompararCenario
    mov rolagem,319
    call DesenharCenario
    call CompararCenario
    ; Composicao explicita de FFh e 00h, sem modificar a arte permanente.
    mov faseMem,2
    mov rolagem,0
    mov linhaCenario,55h
    mov linhaCenario+1,55h
    lea si,bitmapMontanhas
    mov al,[si]
    mov ah,[si+1]
    push ax
    mov byte ptr [si],0FFh
    mov byte ptr [si+1],0
    std
    call ComporLinhaCircular
    pushf
    pop bx
    pop ax
    mov [si],al
    mov [si+1],ah
    test bx,0400h
    jnz memFalha
    cmp linhaCenario,55h
    jne memFalha
    cmp linhaCenario+1,0
    jne memFalha
    mov faseMem,3
    mov tempoRestante,90
    mov fracaoSegundo,0
    xor dx,dx
    mov ax,99
    call ConsumirTempo
    jc memFalha
    cmp tempoRestante,90
    jne memFalha
    cmp fracaoSegundo,99
    jne memFalha
    xor dx,dx
    mov ax,1
    call ConsumirTempo
    jnc memFalha
    cmp tempoRestante,89
    jne memFalha
    mov faseMem,6
    mov margemInicial,MARGEM_RELOGIO
    mov fracaoSegundo,0
    mov tempoRestante,90
    xor dx,dx
    mov ax,3
    call ConsumirTempo
    jc memFalha
    cmp margemInicial,3
    jne memFalha
    xor dx,dx
    mov ax,102                  ; total 105: 6 de margem e 99 de fracao
    call ConsumirTempo
    jc memFalha
    cmp fracaoSegundo,99
    jne memFalha
    xor dx,dx
    mov ax,1
    call ConsumirTempo
    jnc memFalha
    cmp tempoRestante,89
    jne memFalha
    mov fracaoSegundo,0
    cmp fracaoSegundo,0
    jne memFalha
    xor dx,dx
    mov ax,350
    call ConsumirTempo
    cmp tempoRestante,86
    jne memFalha
    cmp fracaoSegundo,50
    jne memFalha
    ; 70 segundos sem consulta nao se perdem na virada de minuto.
    mov faseMem,4
    xor dx,dx
    mov ax,7000
    call ConsumirTempo
    cmp tempoRestante,16
    jne memFalha
    cmp fracaoSegundo,50
    jne memFalha
    mov dx,100
    xor ax,ax
    call ConsumirTempo
    cmp tempoRestante,0
    jne memFalha
    cmp fracaoSegundo,0
    jne memFalha
    mov faseMem,5
    mov tempoRestante,90
    mov tempoAnteriorHi,CENT_DIA_ALTO
    mov tempoAnteriorLo,CENT_DIA_BAIXO-50
    mov relogioHi,0
    mov relogioLo,75
    call AtualizarRelogio       ; meia-noite: 125 centesimos, nao um dia inteiro
    cmp tempoRestante,89
    jne memFalha
    cmp fracaoSegundo,25
    jne memFalha
    call AtualizarRelogio       ; mesmo instante nao desconta outra vez
    jc memFalha
    cmp tempoRestante,89
    jne memFalha
    lea dx,memOk
    mov ah,09h
    int 21h
    mov ax,4C00h
    int 21h
inicio endp

; Funcao: comparar todos os pixels com rotacao da primeira tela, mais guardas.
; Entrada: rolagem, ES=videoTeste. Saida: retorna ou FAIL. Altera: registradores.
CompararCenario proc near
    cld
    xor di,di
    mov cx,32000
    mov al,55h
    repe scasb
    jne memFalha
    mov di,64000
    mov cx,1000
    mov al,0AAh
    repe scasb
    jne memFalha
    mov bx,rolagem
    push ds
    mov ax,referencia
    mov ds,ax
    xor bp,bp
    mov di,32000
compararLinha:
    mov si,bp
    add si,bx
    mov cx,320
    sub cx,bx
    repe cmpsb
    jne compararErro
    mov si,bp
    mov cx,bx
    jcxz compararSeguinte
    repe cmpsb
    jne compararErro
compararSeguinte:
    add bp,320
    cmp bp,32000
    jb compararLinha
    pop ds
    ret
compararErro:
    pop ds
    jmp memFalha
CompararCenario endp

; Funcao: substituir apenas a fonte do relogio no harness de memoria.
; Entrada: relogioHi/Lo. Saida: DX:AX. Altera: AX,DX.
LerHoraTeste proc near
    mov ax,relogioLo
    mov dx,relogioHi
    ret
LerHoraTeste endp

memFalha:
    mov al,faseMem
    add al,'0'
    mov erroFase,al
    lea dx,memErro
    mov ah,09h
    int 21h
    mov ax,4C01h
    int 21h
