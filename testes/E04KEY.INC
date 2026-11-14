; Teste do caminho Windows -> SDL/DOSBox -> IRQ1 -> rotina real.
; Entrada: eventos PostMessage do executor. Saida: sinal de etapa e PASS/FAIL.
inicio proc
    mov ax,@data
    mov ds,ax
    mov ax,13h
    int 10h
    mov ax,VIDEO_SEG
    mov es,ax
    call EntrarPartida
    call SinalKey
keyDireita:
    cmp teclasJipe,BIT_DIREITA
    jne keyDireita
    call AtualizarJipe
    cmp jipeX,3
    jne keyFalha
    inc etapaKey
    call SinalKey
keyCima:
    cmp teclasJipe,BIT_DIREITA+BIT_CIMA
    jne keyCima
    call AtualizarJipe
    cmp jipeX,6
    jne keyFalha
    cmp jipeY,180
    jne keyFalha
    mov cx,4
keySubida:
    push cx
    call AtualizarJipe
    pop cx
    loop keySubida
    cmp jipeY,168
    jne keyFalha
    mov ax,5
    call ContarTopo
    mov cx,5
keyDescida:
    push cx
    call AtualizarJipe
    pop cx
    loop keyDescida
    call AtualizarJipe
    cmp jipeY,183
    jne keyFalha
    cmp estadoSalto,SALTO_CHAO
    jne keyFalha
    cmp pedidoSalto,0
    jne keyFalha
    inc etapaKey
    call SinalKey
keyEsquerda:
    cmp teclasJipe,BIT_ESQUERDA+BIT_CIMA
    jne keyEsquerda
    mov ax,jipeX
    sub ax,3
    mov esperadoKey,ax
    call AtualizarJipe
    mov ax,esperadoKey
    cmp jipeX,ax
    jne keyFalha
    inc etapaKey
    call SinalKey
keySoltar:
    cmp teclasJipe,0
    jne keySoltar
    inc etapaKey
    call SinalKey
keyNovoSalto:
    cmp teclasJipe,BIT_CIMA
    jne keyNovoSalto
    call AtualizarJipe
    cmp jipeY,180
    jne keyFalha
    mov ax,43210
    call EntrarGameOver
    cmp scoreFinal,43210
    jne keyFalha
    cmp tecladoJogoAtivo,0
    jne keyFalha
    inc etapaKey
    call SinalKey
keyMenu:
    call LerTeclado
    cmp estado,ESTADO_MENU
    jne keyMenu
    mov ax,3
    int 10h
    lea dx,keyOk
    mov ah,09h
    int 21h
    mov ax,4C00h
    int 21h
inicio endp

; Funcao: publicar uma etapa para o executor Windows. Entrada: etapaKey.
; Saida: E04KEY.SIG com um byte; falha se a escrita nao for completa.
SinalKey proc near
    lea dx,nomeKey
    xor cx,cx
    mov ah,3Ch
    int 21h
    jc keyFalha
    mov bx,ax
    lea dx,etapaKey
    mov cx,1
    mov ah,40h
    int 21h
    jc keyFalha
    cmp ax,1
    jne keyFalha
    mov ah,3Eh
    int 21h
    ret
SinalKey endp

keyFalha:
    call RestaurarTecladoJogo
    mov ax,3
    int 10h
    lea dx,keyErro
    mov ah,09h
    int 21h
    mov ax,4C01h
    int 21h
