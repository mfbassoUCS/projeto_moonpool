; Teste auxiliar: substitui somente inicio; executa rotinas reais da E02.
; Funcao: conferir sprites, limites, fundos sobrepostos e varios ciclos.
; Entrada: nenhuma. Saida: DOS 0 PASS ou DOS 1 FAIL. Altera: registradores.
inicio proc
    mov ax,@data
    mov ds,ax
    mov ax,videoTeste
    mov es,ax
    cld
    xor di,di
preencherPadrao:
    mov ax,di
    and al,0Fh
    stosb
    cmp di,64000
    jb preencherPadrao
    mov al,55h
    mov cx,1000
    rep stosb

    ; Preto opaco e transparente FFh no ultimo pixel; guarda apos 63999.
    mov ax,318
    mov bx,199
    mov cx,2
    mov dx,1
    lea si,pixelsTeste
    std
    call DesenharSprite
    pushf
    pop ax
    test ax,0400h
    jz memDFok
    jmp memFalha
memDFok:
    mov di,63998
    cmp byte ptr es:[di],0Eh
    je memTransOk
    jmp memFalha
memTransOk:
    inc di
    cmp byte ptr es:[di],0
    je memPretoOk
    jmp memFalha
memPretoOk:
    mov byte ptr es:[di],0Fh
    call ConferirPadrao
    ; Invalidos: direita, baixo, zero, dimensao excessiva e -1.
    mov indiceCaso,0
memInvalido:
    mov di,indiceCaso
    mov ax,casos[di]
    mov bx,casos[di+2]
    mov cx,casos[di+4]
    mov dx,casos[di+6]
    lea si,pixelsTeste
    std
    call DesenharSprite
    pushf
    pop ax
    test ax,0400h
    jz memInvalidoDFok
    jmp memFalha
memInvalidoDFok:
    call ConferirPadrao
    add indiceCaso,8
    cmp indiceCaso,64
    jb memInvalido

    ; Sobrepor os quatro objetos (mesmo x e y) e restaurar fundo listrado.
    mov menuY[0],100
    mov menuY[2],100
    mov menuY[4],100
    mov menuY[6],100
    call CapturarEDesenharMenu
    call ApagarSpritesMenu
    call ConferirPadrao
    ; Posicoes normais, 400 quadros: todos devem completar >=2 voltas.
    xor di,di
memPosicoes:
    mov ax,menuXInicial[di]
    mov menuX[di],ax
    add di,2
    cmp di,8
    jb memPosicoes
    mov menuY[0],100
    mov menuY[2],96
    mov menuY[4],96
    mov menuY[6],96
    call CapturarEDesenharMenu
    ; Pixels reconheciveis das artes proprias; tamanhos conferidos no TASM.
    mov di,320*100+6
    cmp byte ptr es:[di],0Fh
    jne memFalha
    mov di,320*97+80+5
    cmp byte ptr es:[di],0Bh
    jne memFalha
    mov di,320*96+160+3
    cmp byte ptr es:[di],0Bh
    jne memFalha
    mov di,320*96+240+6
    cmp byte ptr es:[di],0Dh
    jne memFalha
memQuadro:
    call MoverSpritesMenu
    xor di,di
memContarVoltas:
    mov ax,320
    sub ax,menuLarg[di]
    cmp menuX[di],ax
    ja memFalha
    cmp menuX[di],0
    jne memProximo
    inc voltas[di]
memProximo:
    add di,2
    cmp di,8
    jb memContarVoltas
    call ApagarSpritesMenu
    call ConferirPadrao
    call CapturarEDesenharMenu
    dec quadrosRestantes
    jnz memQuadro
    xor di,di
memVerVoltas:
    cmp voltas[di],2
    jb memFalha
    add di,2
    cmp di,8
    jb memVerVoltas
    call ApagarSpritesMenu
    call ConferirPadrao
    lea dx,memOk
    mov ah,09h
    int 21h
    mov ax,4C00h
    int 21h
memFalha:
    cld
    lea dx,memErro
    mov ah,09h
    int 21h
    mov ax,4C01h
    int 21h
inicio endp

; Funcao: conferir todos os pixels e os 1000 bytes de guarda.
; Entrada: ES=RAM de teste. Saida: retorna ou DOS FAIL. Altera: AX,CX,DI,flags.
ConferirPadrao proc near
    xor di,di
padraoPixel:
    mov ax,di
    and al,0Fh
    cmp es:[di],al
    jne memFalha
    inc di
    cmp di,64000
    jb padraoPixel
    mov al,55h
    mov cx,1000
    cld
    repe scasb
    jne memFalha
    ret
ConferirPadrao endp
