; Teste de RAM: entradas/fases e dois caminhos de desenho sobre fundo movel.
; Entrada: nenhuma. Saida: PASS/FAIL DOS; nao instala IRQ neste teste.
inicio proc
    mov ax,@data
    mov ds,ax
    call CasosJipe
    mov faseMem,2
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
    mov rolagem,0
    call DesenharCenario
    push ds
    push es
    mov ax,videoTeste
    mov ds,ax
    mov ax,referencia
    mov es,ax
    xor si,si
    xor di,di
    mov cx,64000
    rep movsb
    pop es
    pop ds
    call ReiniciarJipe
    call CapturarEDesenharJipe
    call CompararQuadro
    mov al,SCAN_DIREITA
    call RegistrarScanJipe
memQuadro:
    ; Ida e volta; inicia saltos regularmente e solta cima no quadro seguinte.
    mov al,SCAN_CIMA+80h
    call RegistrarScanJipe
    mov ax,passoTeste
    xor dx,dx
    mov bx,20
    div bx
    cmp dx,0
    jne memDirecao
    mov al,SCAN_CIMA
    call RegistrarScanJipe
memDirecao:
    cmp jipeX,JIPE_X_MAX
    jne memBordaEsquerda
    mov al,SCAN_DIREITA+80h
    call RegistrarScanJipe
    mov al,SCAN_ESQUERDA
    call RegistrarScanJipe
memBordaEsquerda:
    cmp jipeX,0
    jne memDesenhar
    mov al,SCAN_ESQUERDA+80h
    call RegistrarScanJipe
    mov al,SCAN_DIREITA
    call RegistrarScanJipe
memDesenhar:
    call AvancarCenario
    mov ax,PASSO_CENARIO
    call ContarTopo
    call AtualizarJipe
    mov cenarioMudou,1
    std
    call DesenharQuadroPartida
    call CompararQuadro
    ; Quadro intercalado sem rolagem: apagar com a captura atual e redesenhar.
    call AtualizarJipe
    mov cenarioMudou,0
    std
    call DesenharQuadroPartida
    call CompararQuadro
    inc passoTeste
    cmp passoTeste,320
    jb memQuadro
    cmp rolagem,0
    jne memFalha
    lea dx,memOk
    mov ah,09h
    int 21h
    mov ax,4C00h
    int 21h
inicio endp

; Funcao: executar tabela de resultados esperados, com scans make/break reais.
; Entrada: casos. Saida: cada X/Y/fase/contador conferido ou FAIL.
CasosJipe proc near
    mov faseMem,1
    lea si,casos
casoProximo:
    inc numeroCaso
    mov ax,[si]
    cmp ax,0FFFFh
    je casosFim
    cmp ax,0
    jne casoX
    call ReiniciarJipe
    jmp casoConferir
casoX:
    cmp ax,1
    jne casoScan
    mov ax,[si+2]
    mov jipeX,ax
    jmp casoConferir
casoScan:
    cmp ax,2
    jne casoFrame
    mov ax,[si+2]
    call RegistrarScanJipe
    jmp casoConferir
casoFrame:
    cmp ax,3
    jne casoTerreno
    call AtualizarJipe
    jmp casoConferir
casoTerreno:
    mov ax,[si+2]
    call ContarTopo
casoConferir:
    mov ax,[si+4]
    cmp jipeX,ax
    jne memFalha
    mov ax,[si+6]
    cmp jipeY,ax
    jne memFalha
    mov al,[si+8]
    cmp estadoSalto,al
    jne memFalha
    mov ax,[si+10]
    cmp pixelsTopo,ax
    jne memFalha
    add si,12
    jmp casoProximo
casosFim:
    ret
CasosJipe endp

; Funcao: oraculo de pixels independente do apagamento/desenho do jogo.
; Entrada: tela inicial limpa e posicoes atuais. Saida: compara 65000 bytes.
; Rotaciona linhas da referencia, sobrepoe 200 bytes manualmente e confere.
CompararQuadro proc near
    pushf
    pop ax
    test ax,0400h
    jnz memFalha
    push es
    mov bx,rolagem
    push ds
    mov ax,referencia
    mov ds,ax
    mov ax,esperado
    mov es,ax
    xor si,si
    xor di,di
    mov cx,32000
    rep movsb
    mov bp,32000
compararLinha:
    mov si,bp
    add si,bx
    mov cx,320
    sub cx,bx
    rep movsb
    mov si,bp
    mov cx,bx
    rep movsb
    add bp,320
    cmp bp,64000
    jb compararLinha
    mov al,0AAh
    mov cx,1000
    rep stosb
    pop ds
    mov ax,jipeY
    mov bx,320
    mul bx
    add ax,jipeX
    mov di,ax
    lea si,bitmapJipe
    mov dx,10
compararSpriteLinha:
    mov cx,20
compararSpritePixel:
    lodsb
    cmp al,0FFh
    je compararTransparente
    mov es:[di],al
compararTransparente:
    inc di
    loop compararSpritePixel
    add di,300
    dec dx
    jnz compararSpriteLinha
    push ds
    mov ax,videoTeste
    mov ds,ax
    xor si,si
    xor di,di
    mov cx,65000
    repe cmpsb
    pop ds
    pop es
    jne memFalha
    ret
CompararQuadro endp

memFalha:
    mov al,faseMem
    add al,'0'
    mov erroFase,al
    mov ax,numeroCaso
    call FormatarScore
    lea dx,memErro
    mov ah,09h
    int 21h
    lea dx,digitosScore
    mov bx,1
    mov cx,5
    mov ah,40h
    int 21h
    mov ax,4C01h
    int 21h
