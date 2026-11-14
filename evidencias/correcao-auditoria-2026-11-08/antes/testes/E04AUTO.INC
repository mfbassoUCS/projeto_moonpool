
; Funcao: conferir reset do jipe no fluxo real. Entrada: dados. Saida: PASS/FAIL.
ConferirJipeReset proc near
    cmp jipeX,JIPE_X_INICIAL
    jne autoFalha
    cmp jipeY,JIPE_Y_CHAO
    jne autoFalha
    cmp estadoSalto,SALTO_CHAO
    jne autoFalha
    cmp pixelsTopo,0
    jne autoFalha
    cmp teclasJipe,0
    jne autoFalha
    cmp pedidoSalto,0
    jne autoFalha
    cmp tecladoJogoAtivo,1
    jne autoFalha
    ret
ConferirJipeReset endp

; Funcao: conferir vetor BIOS restaurado. Entrada: vetor salvo. Saida: PASS/FAIL.
ConferirVetorTeste proc near
    push ax
    push bx
    push es
    mov ax,3509h
    int 21h
    cmp bx,vetorTeclado
    jne autoFalha
    mov ax,es
    cmp ax,vetorTeclado+2
    jne autoFalha
    pop es
    pop bx
    pop ax
    ret
ConferirVetorTeste endp

; Funcao: dirigir com scans sinteticos somente uma vez por quadro do terreno.
; Entrada: quadrosAuto. Saida: direita, esquerda, parado e salto periodico.
ControlarJipeTeste proc near
    mov ax,quadrosAuto
    cmp ax,ultimoControle
    je controleFim
    mov ultimoControle,ax
    cmp ax,20
    jb controleDireita
    mov al,SCAN_DIREITA+80h
    call RegistrarScanJipe
    cmp quadrosAuto,45
    jae controleParado
    mov al,SCAN_ESQUERDA
    call RegistrarScanJipe
    jmp controleSalto
controleParado:
    mov al,SCAN_ESQUERDA+80h
    call RegistrarScanJipe
    jmp controleSalto
controleDireita:
    mov al,SCAN_DIREITA
    call RegistrarScanJipe
controleSalto:
    mov ax,quadrosAuto
    xor dx,dx
    mov bx,20
    div bx
    mov al,SCAN_CIMA+80h
    cmp dx,5
    jne controleScan
    mov al,SCAN_CIMA
controleScan:
    call RegistrarScanJipe
controleFim:
    ret
ControlarJipeTeste endp

; Funcao: exportar primeira imagem de cada fase e suas coordenadas/rolagem.
; Entrada: quadro pronto, faseAuto=3. Saida: quatro RAW e POS (4x4 words).
CapturarJipeTeste proc near
    cmp faseAuto,3
    jne capturaFim
    xor bx,bx
    mov bl,estadoSalto
    mov cl,bl
    mov al,1
    shl al,cl
    test capturasJipe,al
    jnz capturaFim
    or capturasJipe,al
    mov al,bl
    add al,'0'
    mov nomeJipe+4,al
    shl bx,1
    shl bx,1
    shl bx,1
    mov ax,jipeX
    mov posCapturas[bx],ax
    mov ax,jipeY
    mov posCapturas[bx+2],ax
    mov ax,rolagem
    mov posCapturas[bx+4],ax
    mov ax,pixelsTopo
    mov posCapturas[bx+6],ax
    lea dx,nomeJipe
    call SalvarTelaE04
    lea dx,nomePos
    xor cx,cx
    mov ah,3Ch
    int 21h
    jc autoFalha
    mov bx,ax
    lea dx,posCapturas
    mov cx,32
    mov ah,40h
    int 21h
    jc autoFalha
    cmp ax,32
    jne autoFalha
    mov ah,3Eh
    int 21h
capturaFim:
    ret
CapturarJipeTeste endp

; Funcao: gravar coordenadas junto de cada dump, sem inferir estado por pixels.
; Entrada: DS:DX=nome RAW. Saida: arquivo POS de 8 bytes. Preserva registradores.
SalvarMetaTeste proc near
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    mov si,dx
    lea di,nomeMeta
metaNome:
    lodsb
    mov [di],al
    inc di
    cmp al,0
    jne metaNome
    mov byte ptr [di-4],'P'
    mov byte ptr [di-3],'O'
    mov byte ptr [di-2],'S'
    mov ax,jipeX
    mov metaPos,ax
    mov ax,jipeY
    mov metaPos+2,ax
    mov ax,rolagem
    mov metaPos+4,ax
    mov ax,pixelsTopo
    mov metaPos+6,ax
    lea dx,nomeMeta
    xor cx,cx
    mov ah,3Ch
    int 21h
    jc autoFalha
    mov bx,ax
    lea dx,metaPos
    mov cx,8
    mov ah,40h
    int 21h
    jc autoFalha
    cmp ax,8
    jne autoFalha
    mov ah,3Eh
    int 21h
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
SalvarMetaTeste endp
