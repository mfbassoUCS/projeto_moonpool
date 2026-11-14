; Funcao: exercitar composicao real em RAM com projeteis independentes.
; Entrada: nenhuma. Saida: metadados e 65000 bytes por quadro.
inicio proc
    mov ax,@data
    mov ds,ax
    lea dx,nomeE08
    xor cx,cx
    mov ah,3Ch
    int 21h
    jc FalhaE08
    mov handleE08,ax
    mov ax,videoTeste
    mov es,ax
    xor di,di
    mov cx,64000
    mov al,55h
    cld
    rep stosb
    mov cx,1000
    mov al,0AAh
    rep stosb
    call ZerarE08
    mov obstTipo,6
    mov obstX,50
    mov naveAtiva,1
    mov naveX,100
    mov naveY,86
    mov cenarioMudou,1
    call QuadroE08
    ; Encher todas as vagas e testar dimensoes, recorte e cruzamento de y=100.
    xor di,di
pixEncher:
    mov tiroAtivo[di],1
    mov ax,di
    mov bx,6
    mul bx
    mov tiroX[di],ax
    mov tiroY[di],97
    add di,2
    cmp di,TIRO_MAX*2
    jb pixEncher
    mov tiroX,-1
    mov tiroX+2,319
    mov tiroY+2,16
    mov tiroY+16,187
    mov tiroX+16,8
    mov tiroY+32,188
    mov tiroX+32,319
    mov tirosMudou,1
    call QuadroE08
    mov di,0
    call RemoverNave          ; so nave muda: seus tiros nao podem sumir
    call QuadroE08
    mov jipeX,12              ; so jipe muda: captura contem um tiro frontal
    call QuadroE08
    mov jipeX,30
    call QuadroE08
    call AvancarCenario       ; so terreno muda, tiros permanecem
    mov cenarioMudou,1
    call QuadroE08
    call MoverDisparos        ; somente tiros: limpar ceu E terreno
    call QuadroE08
    mov tiroAtivo+16,0
    mov tirosMudou,1
    call QuadroE08
    call ReiniciarDisparos
    mov tirosMudou,1
    call QuadroE08
    ; 160 quadros mistos: entrada mantida, salto, disparos, impactos e morte.
    call ZerarE08
    mov rolagem,0
    mov obstTipo,4
    mov obstX,45
    mov naveAtiva,1
    mov naveX,6
    mov naveY,86
    mov esperaNave,0
    mov teclasJipe,BIT_ESPACO
    mov cenarioMudou,1
    call QuadroE08
pixMisto:
    inc tickE08
    test tickE08,1
    jnz pixJipe
    call AvancarCenario
    call AvancarObstaculos
    call AtualizarNaves
    mov ax,PASSO_CENARIO
    call ContarTopo
    mov cenarioMudou,1
pixJipe:
    cmp tickE08,60
    jne pixMovimento
    mov al,SCAN_CIMA
    call RegistrarScanJipe
    mov al,SCAN_DIREITA
    call RegistrarScanJipe
pixMovimento:
    cmp jipeAtivo,0
    je pixRepor
    call AtualizarJipe
    jmp pixTiros
pixRepor:
    call TentarReporJipe
pixTiros:
    mov dx,tickE08
    call AtualizarCadenciaDisparos
    call ConferirDisparos
    call ConferirObstaculos
    call RetirarObstaculos
    call QuadroE08
    cmp tickE08,160
    jb pixMisto
    mov bx,handleE08
    mov ah,3Eh
    int 21h
    jc FalhaE08
    lea dx,okE08
    mov ah,09h
    int 21h
    mov ax,4C00h
    int 21h
inicio endp

; Funcao: desenhar e exportar estado+RAM; Entrada: estado. Saida: quadro DOS.
QuadroE08 proc near
    mov ax,numeroQuadroE08
    mov caso,ax
    std
    call DesenharQuadroPartida
    pushf
    pop ax
    test ax,0400h
    jnz FalhaE08
    mov ax,numeroQuadroE08
    mov metaE08,ax
    mov ax,rolagem
    mov metaE08+2,ax
    mov ax,jipeX
    mov metaE08+4,ax
    mov ax,jipeY
    mov metaE08+6,ax
    xor ax,ax
    mov al,jipeAtivo
    mov metaE08+8,ax
    mov ax,naveTipo
    mov metaE08+10,ax
    mov bx,handleE08
    lea dx,metaE08
    mov cx,12
    call GravarE08
    lea dx,obstX
    mov cx,OBST_MAX*4       ; X e tipo, tabelas consecutivas
    call GravarE08
    lea dx,naveX
    mov cx,NAVE_MAX*6       ; X,Y,atividade
    call GravarE08
    lea dx,tiroAtivo
    mov cx,TIRO_MAX*8       ; atividade,X,Y,distancia
    call GravarE08
    push ds
    push es
    pop ds
    xor dx,dx
    mov cx,65000
    call GravarE08
    pop ds
    mov cenarioMudou,0
    mov jipeMudou,0
    inc numeroQuadroE08
    ret
QuadroE08 endp
; Funcao: escrita verificada. Entrada: BX=handle,DS:DX,CX. Saida: bytes DOS.
GravarE08 proc near
    mov ah,40h
    int 21h
    jc pixGravaFalha
    cmp ax,cx
    jne pixGravaFalha
    ret
pixGravaFalha:
    mov ax,@data
    mov ds,ax
    jmp FalhaE08
GravarE08 endp
