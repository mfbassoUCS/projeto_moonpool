; Funcao: exercitar compositor real em RAM. Entrada: nenhuma.
; Saida: 390 quadros de 65000 bytes com metadados, sem usar BIOS de pixels.
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
    mov yTeste,15
pixY:
    mov xIndice,0
pixPos:
    call ReiniciarJipe
    call ReiniciarNaves
    mov ax,tipoTeste
    mov naveTipo,ax
    add ax,3
    mov obstTipo,ax
    mov obstX,10
    mov bx,xIndice
    mov ax,posTeste[bx]
    xor di,di
pixPreparar:
    mov naveX[di],ax
    mov bx,yTeste
    mov naveY[di],bx
    mov naveAtiva[di],1
    add ax,44
    add di,2
    cmp di,6
    jb pixPreparar
    mov cenarioMudou,1
    std
    call DesenharQuadroPartida
    call ExportarQuadroE06
    ; Somente naves: nao depender da rolagem ou do jipe para apagar.
    mov cenarioMudou,0
    call AtualizarNaves
    std
    call DesenharQuadroPartida
    call ExportarQuadroE06
    ; Somente jipe: ceu fica exatamente igual.
    mov jipeX,13
    mov jipeY,174
    std
    call DesenharQuadroPartida
    call ExportarQuadroE06
    ; Remocao de uma nave visivel sem movimento do terreno.
    mov di,4
    call RemoverNave
    std
    call DesenharQuadroPartida
    call ExportarQuadroE06
    ; Rolagem e naves, com jipe ausente: nao restaurar qualquer fundo velho.
    call AvancarCenario
    sub obstX,PASSO_CENARIO
    call AtualizarNaves
    mov cenarioMudou,1
    mov jipeAtivo,0
    std
    call DesenharQuadroPartida
    call ExportarQuadroE06
    add xIndice,2
    cmp xIndice,26
    jb pixPos
    cmp yTeste,86
    je pixProximoTipo
    mov yTeste,86
    jmp pixY
pixProximoTipo:
    inc tipoTeste
    cmp tipoTeste,3
    jb pixTipo
    mov bx,handlePixels
    mov ah,3Eh
    int 21h
    lea dx,okE06
    mov ah,09h
    int 21h
    mov ax,4C00h
    int 21h
inicio endp
; Funcao: exportar estado e quadro real. Entrada: ES=videoTeste/dados.
; Saida: metadados de 34 bytes e 65000 bytes de pixels/guarda; verifica DF.
ExportarQuadroE06 proc near
    pushf
    pop ax
    test ax,0400h
    jnz pixFalha
    mov ax,caso
    mov meta,ax
    inc caso
    mov ax,rolagem
    mov meta+2,ax
    mov ax,jipeX
    mov meta+4,ax
    mov ax,jipeY
    mov meta+6,ax
    xor ax,ax
    mov al,jipeAtivo
    mov meta+8,ax
    mov ax,obstTipo
    mov meta+10,ax
    mov ax,obstX
    mov meta+12,ax
    mov ax,naveTipo
    mov meta+14,ax
    xor di,di
pixMeta:
    mov ax,naveX[di]
    mov meta[di+16],ax
    mov ax,naveY[di]
    mov meta[di+22],ax
    mov ax,naveAtiva[di]
    mov meta[di+28],ax
    add di,2
    cmp di,6
    jb pixMeta
    mov bx,handlePixels
    lea dx,meta
    mov cx,34
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
ExportarQuadroE06 endp
pixFalha:
    mov ax,4C01h
    int 21h
