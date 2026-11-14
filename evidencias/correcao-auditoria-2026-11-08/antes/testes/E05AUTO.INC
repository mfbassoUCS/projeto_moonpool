; Funcao: guiar laco REAL pelas telas e eventos E05. Entrada: estado.
; Saida: testes/arquivos e teclas BIOS; erro encerra com codigo 1.
DirigirE05 proc near
    mov al,faseAuto
    cmp al,0
    je autoMenu
    cmp al,1
    je autoSetor
    cmp al,2
    je autoInicio
    cmp al,3
    je autoNatural
    cmp al,4
    je autoRepor
    cmp al,5
    je autoSegunda
    cmp al,6
    je autoOutraReposicao
    cmp al,7
    je autoUltima
    cmp al,8
    je autoVoltou
    cmp al,9
    je autoNovoSetor
    cmp al,10
    je autoNovaPartida
    cmp al,11
    je autoTempo
    cmp al,12
    je autoSair
    ret
autoMenu:
    cmp estado,ESTADO_MENU
    jne autoFalhaE05
    inc faseAuto
    mov cx,1C0Dh
    jmp autoTecla
autoSetor:
    cmp estado,ESTADO_SETOR
    jne autoFalhaE05
    inc faseAuto
    mov cx,1C0Dh
    jmp autoTecla
autoInicio:
    cmp estado,ESTADO_PARTIDA
    jne autoFalhaE05
    cmp scorePartida,0
    jne autoFalhaE05
    cmp vidas,3
    jne autoFalhaE05
    cmp tecladoJogoAtivo,1
    jne autoFalhaE05
    mov scorePartida,150        ; valor de teste para conferir Game Over real
    mov statusMudou,1
    call LerCentissegundos
    mov horaInicioLo,ax
    mov horaInicioHi,dx
    mov ah,0
    int 1Ah
    mov tickInicioTeste,dx
    inc faseAuto
    ret
autoNatural:
    cmp estado,ESTADO_PARTIDA
    jne autoFalhaE05
    mov ah,0
    int 1Ah
    sub dx,tickInicioTeste
    cmp dx,600                 ; timeout 33 segundos, sem depender do host
    ja autoFalhaE05
    cmp vidas,3
    je autoRetorno
    cmp vidas,2
    jne autoFalhaE05
    cmp jipeAtivo,0
    jne autoFalhaE05
    cmp jipeNaTela,0
    jne autoFalhaE05
    cmp scorePartida,150
    jne autoFalhaE05
    cmp tempoRestante,80
    ja autoFalhaE05
    call LerCentissegundos
    sub ax,horaInicioLo
    sbb dx,horaInicioHi
    mov registroAuto,ax
    mov registroAuto+2,dx
    mov ax,tempoRestante
    mov tempoAntesMorte,ax
    mov registroAuto+4,ax
    mov ax,rolagem
    mov rolagemAntesMorte,ax
    mov registroAuto+6,ax
    lea dx,nomeMorte
    call DumpTelaE05
    inc faseAuto
    ret
autoRepor:
    cmp vidas,2
    jne autoFalhaE05
    cmp jipeAtivo,0
    je autoRetorno
    cmp jipeX,0
    jne autoFalhaE05
    cmp jipeY,183
    jne autoFalhaE05
    mov ax,tempoRestante
    cmp ax,tempoAntesMorte
    ja autoFalhaE05
    mov registroAuto+8,ax
    mov ax,rolagem
    cmp ax,rolagemAntesMorte
    je autoFalhaE05
    mov registroAuto+10,ax
    lea dx,nomeRepor
    call DumpTelaE05
    call ForcarChoque
    inc faseAuto
    ret
autoSegunda:
    cmp vidas,1
    jne autoFalhaE05
    cmp jipeAtivo,0
    jne autoFalhaE05
    mov obstX,-14
    inc faseAuto
    ret
autoOutraReposicao:
    cmp vidas,1
    jne autoFalhaE05
    cmp jipeAtivo,0
    je autoRetorno
    call ForcarChoque
    inc faseAuto
    ret
autoUltima:
    cmp estado,ESTADO_FIM
    jne autoFalhaE05
    cmp vidas,0
    jne autoFalhaE05
    cmp scoreFinal,150
    jne autoFalhaE05
    call ConferirVetorE05
    lea dx,nomeFimAuto
    call DumpTelaE05
    inc faseAuto
    mov cx,1E61h
    jmp autoTecla
autoVoltou:
    cmp estado,ESTADO_MENU
    jne autoFalhaE05
    inc faseAuto
    mov cx,1C0Dh
    jmp autoTecla
autoNovoSetor:
    cmp estado,ESTADO_SETOR
    jne autoFalhaE05
    inc faseAuto
    mov cx,1C0Dh
    jmp autoTecla
autoNovaPartida:
    cmp estado,ESTADO_PARTIDA
    jne autoFalhaE05
    cmp scorePartida,0
    jne autoFalhaE05
    cmp vidas,3
    jne autoFalhaE05
    cmp rolagem,0
    jne autoFalhaE05
    cmp tempoRestante,90
    jne autoFalhaE05
    cmp jipeAtivo,1
    jne autoFalhaE05
    cmp teclasJipe,0
    jne autoFalhaE05
    cmp obstTipo,OBST_LIVRE
    jne autoFalhaE05
    cmp proximoEm,0
    jne autoFalhaE05
    mov tempoRestante,4         ; expirar outra sessao pelo relogio real
    mov scorePartida,250
    mov statusMudou,1
    call LerCentissegundos
    mov horaInicioLo,ax
    mov horaInicioHi,dx
    inc faseAuto
    ret
autoTempo:
    cmp estado,ESTADO_PARTIDA
    je autoRetorno
    cmp estado,ESTADO_FIM
    jne autoFalhaE05
    cmp scoreFinal,250
    jne autoFalhaE05
    cmp vidas,3
    jne autoFalhaE05
    cmp tempoRestante,0
    jne autoFalhaE05
    call ConferirVetorE05
    call LerCentissegundos
    sub ax,horaInicioLo
    sbb dx,horaInicioHi
    cmp dx,0
    jne autoFalhaE05
    cmp ax,400
    jb autoFalhaE05
    cmp ax,450
    ja autoFalhaE05
    mov registroAuto+12,ax
    mov ax,scoreFinal
    mov registroAuto+14,ax
    call GravarRegistroE05
    inc faseAuto
    mov cx,1E61h
    jmp autoTecla
autoSair:
    cmp estado,ESTADO_MENU
    jne autoFalhaE05
    mov cx,5000h
    call autoTecla
    mov cx,1C0Dh
    call autoTecla
    inc faseAuto
    lea dx,autoOk
    mov ah,09h
    int 21h
autoRetorno:
    ret
autoTecla:
    mov ah,05h
    int 16h
    ret
DirigirE05 endp

; Funcao: preparar colisao controlada sem chamar rotina de dano.
; Entrada: nenhuma. Saida: rocha no jipe para o laco real detectar.
ForcarChoque proc near
    mov obstTipo,3
    mov obstX,0
    mov obstPassagem,PASS_NOVO
    ret
ForcarChoque endp

; Funcao: confirmar retorno do vetor BIOS apos Game Over.
; Entrada: vetorTeclado. Saida: erro se alterado. Preserva ES.
ConferirVetorE05 proc near
    cmp tecladoJogoAtivo,0
    jne autoFalhaE05
    push es
    mov ax,3509h
    int 21h
    cmp bx,vetorTeclado
    jne autoFalhaE05
    mov ax,es
    cmp ax,vetorTeclado+2
    jne autoFalhaE05
    pop es
    ret
ConferirVetorE05 endp

; Funcao: exportar tela A000h. Entrada: DX=nome. Saida: dump 64000 bytes.
DumpTelaE05 proc near
    xor cx,cx
    mov ah,3Ch
    int 21h
    jc autoFalhaE05
    mov bx,ax
    push ds
    mov ax,VIDEO_SEG
    mov ds,ax
    xor dx,dx
    mov cx,64000
    mov ah,40h
    int 21h
    pop ds
    jc autoFalhaE05
    mov ah,3Eh
    int 21h
    ret
DumpTelaE05 endp

; Funcao: exportar medidas reais. Entrada: registroAuto. Saida: BIN 16 bytes.
GravarRegistroE05 proc near
    lea dx,nomeAuto
    xor cx,cx
    mov ah,3Ch
    int 21h
    jc autoFalhaE05
    mov bx,ax
    lea dx,registroAuto
    mov cx,16
    mov ah,40h
    int 21h
    jc autoFalhaE05
    mov ah,3Eh
    int 21h
    ret
GravarRegistroE05 endp
autoFalhaE05:
    call RestaurarTecladoJogo
    xor ax,ax
    mov al,faseAuto
    call FormatarScore
    lea dx,erroAuto
    mov ah,09h
    int 21h
    lea dx,digitosScore
    mov cx,5
    mov bx,1
    mov ah,40h
    int 21h
    mov ax,3
    int 10h
    mov ax,4C01h
    int 21h
