; Funcao: exportar quadros reais em RAM. Entrada: nenhuma. Saida: arquivo/pass.
inicio proc
    mov ax,@data
    mov ds,ax
    lea dx,nomePixels
    xor cx,cx
    mov ah,3Ch
    int 21h
    jc pixFalha
    mov handlePixels,ax
    mov ax,videoTeste
    mov es,ax
    xor di,di
    mov al,55h
    mov cx,64000
    cld
    rep stosb
    mov al,0AAh
    mov cx,1000
    rep stosb
pixTipo:
    mov xIndice,0
pixPos:
    call ReiniciarJipe
    mov ax,tipoTeste
    mov obstTipo,ax
    mov bx,xIndice
    mov ax,posTeste[bx]
    mov obstX,ax
    mov cenarioMudou,1
    std
    call DesenharQuadroPartida
    call ExportarQuadro
    ; Movimento so do jipe: fundo contem obstaculo da MESMA rolagem.
    mov cenarioMudou,0
    mov jipeX,13
    mov jipeY,174
    std
    call DesenharQuadroPartida
    call ExportarQuadro
    ; Morte: restaura uma vez, sem desenhar outro jipe.
    mov jipeAtivo,0
    call DesenharQuadroPartida
    call ExportarQuadro
    ; Rolar ausente apaga local antigo de obstaculo; reaparecer depois.
    call AvancarCenario
    sub obstX,PASSO_CENARIO
    mov cenarioMudou,1
    mov jipeAtivo,1
    mov jipeX,0
    mov jipeY,183
    call DesenharQuadroPartida
    call ExportarQuadro
    add xIndice,2
    cmp xIndice,24
    jb pixPos
    inc tipoTeste
    cmp tipoTeste,7
    jb pixTipo
    mov bx,handlePixels
    mov ah,3Eh
    int 21h
    lea dx,okE05
    mov ah,09h
    int 21h
    mov ax,4C00h
    int 21h
inicio endp

; Funcao: gravar metadados + 65000 bytes reais. Entrada: estado/videoTeste.
; Saida: um quadro binario; confere DF. Preserva ES.
ExportarQuadro proc near
    pushf
    pop ax
    test ax,0400h
    jnz pixFalha
    mov ax,rolagem
    mov meta,ax
    mov ax,jipeX
    mov meta+2,ax
    mov ax,jipeY
    mov meta+4,ax
    xor ax,ax
    mov al,jipeAtivo
    mov meta+6,ax
    mov ax,obstTipo
    mov meta+8,ax
    mov ax,obstX
    mov meta+10,ax
    mov ax,caso
    mov meta+12,ax
    inc caso
    mov bx,handlePixels
    lea dx,meta
    mov cx,16
    mov ah,40h
    int 21h
    jc pixFalha
    cmp ax,cx
    jne pixFalha
    push ds
    mov ax,videoTeste
    mov ds,ax
    xor dx,dx
    mov cx,65000
    mov ah,40h
    int 21h
    pop ds
    jc pixFalha
    cmp ax,cx
    jne pixFalha
    ret
ExportarQuadro endp
pixFalha:
    mov ax,4C01h
    int 21h
