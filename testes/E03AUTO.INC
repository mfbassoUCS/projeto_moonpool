; Harness do laco real: injeta teclas BIOS, nunca depende do foco Windows.
; Funcao: conferir fluxo, HUD, duas voltas (variante 45s), tempo e reinicio.
; Entrada: faseAuto/estado. Saida: capturas/teclas ou FAIL. Altera: registradores.
DirigirE03 proc near
    cmp faseAuto,0
    jne autoFase1
    mov cx,1C0Dh
    call TeclaE03
    call TeclaE03
    inc faseAuto
    ret
autoFase1:
    cmp faseAuto,1
    jne autoFase2
    cmp estado,ESTADO_SETOR
    jne autoFalha
    call BufferE03
    mov cx,1C0Dh
    call TeclaE03
    call TeclaE03
    inc faseAuto
    ret
autoFase2:
    cmp faseAuto,2
    jne autoFase3
    cmp estado,ESTADO_PARTIDA
    jne autoFalha
    call BufferE03
    call ConferirReset
    mov ax,tempoAnteriorLo
    mov inicioRealLo,ax
    mov ax,tempoAnteriorHi
    mov inicioRealHi,ax
    mov tempoVisto,DURACAO_SEGUNDOS
    ; Carimbo do filesystem Windows: referencia externa ao relogio DOS.
    lea dx,nomeInicioHost
    xor cx,cx
    mov ah,3Ch
    int 21h
    jc autoFalha
    mov bx,ax
    lea dx,faseAuto
    mov cx,1
    mov ah,40h
    int 21h
    jc autoFalha
    mov ah,3Eh
    int 21h
    jc autoFalha
    lea dx,nomeInicial
    call SalvarTelaE03
    mov vidas,2
    mov scorePartida,65535
    mov tempoRestante,100
    call DesenharStatus
    lea dx,nomeVidas2
    call SalvarTelaE03
    mov vidas,1
    mov scorePartida,9
    mov tempoRestante,99
    call DesenharStatus
    lea dx,nomeVidas1
    call SalvarTelaE03
    mov vidas,0
    mov scorePartida,0
    mov tempoRestante,0
    call DesenharStatus
    lea dx,nomeVidas0
    call SalvarTelaE03
    mov vidas,VIDAS_INICIAIS
    mov scorePartida,43210       ; dado de teste, nao pontuacao da E03 normal
    mov tempoRestante,DURACAO_SEGUNDOS
    call DesenharStatus
    inc faseAuto
    ret
autoFase3:
    cmp faseAuto,3
    jne autoFase4
    cmp estado,ESTADO_FIM
    je autoExpirou
    cmp estado,ESTADO_PARTIDA
    jne autoFalha
    mov ax,tempoRestante
    cmp ax,tempoVisto
    je autoVerVoltas
    cmp ax,tempoVisto
    ja autoFalha
    mov tempoVisto,ax
    call LerCentissegundos
    sub ax,inicioRealLo
    sbb dx,inicioRealHi
    jnc autoTempoDiaOk
    add ax,CENT_DIA_BAIXO
    adc dx,CENT_DIA_ALTO
autoTempoDiaOk:
    cmp registro+10,0
    jne autoTempoConferir
    mov registro+10,ax
autoTempoConferir:
    mov bx,CENT_POR_SEG
    div bx
    mov bx,DURACAO_SEGUNDOS
    sub bx,tempoRestante
    cmp ax,bx
    jb autoFalha                ; nao antecipar o desconto de um segundo
autoVerVoltas:
    mov ax,quadrosAuto
    cmp ax,ultimoDump
    je autoAguardar
    mov ultimoDump,ax
    cmp quadrosAuto,159
    jne autoVolta1
    lea dx,nomeEmenda
    call SalvarTelaE03
autoVolta1:
    cmp quadrosAuto,160
    jne autoVolta2
    lea dx,nomeVolta
    call SalvarTelaE03
autoVolta2:
    cmp quadrosAuto,320
    jne autoAguardar
    lea dx,nomeDois
    call SalvarTelaE03
autoAguardar:
    ret
autoExpirou:
    cmp tempoRestante,0
    jne autoFalha
    cmp scoreFinal,43210
    jne autoFalha
IF DURACAO_SEGUNDOS EQ 45
    cmp voltasAuto,2
    jb autoFalha
ENDIF
    mov ax,fimRealLo
    mov dx,fimRealHi
    sub ax,inicioRealLo
    sbb dx,inicioRealHi
    jnc autoFimDiaOk
    add ax,CENT_DIA_BAIXO
    adc dx,CENT_DIA_ALTO
autoFimDiaOk:
    mov registro+6,ax
    mov registro+8,dx
    mov bx,CENT_POR_SEG
    div bx
    cmp ax,DURACAO_SEGUNDOS
    jb autoFalha
    cmp ax,DURACAO_SEGUNDOS+2
    jae autoFalha
    mov registro,DURACAO_SEGUNDOS
    mov registro+2,TICKS_CENARIO
    mov ax,quadrosAuto
    mov registro+4,ax
    lea dx,nomeTempo
    xor cx,cx
    mov ah,3Ch
    int 21h
    jc autoFalha
    mov bx,ax
    lea dx,registro
    mov cx,12
    mov ah,40h
    int 21h
    jc autoFalha
    cmp ax,12
    jne autoFalha
    mov ah,3Eh
    int 21h
    jc autoFalha
    lea dx,nomeFim
    call SalvarTelaE03
    mov cx,1E61h
    call TeclaE03
    inc faseAuto
    ret
autoFase4:
    cmp faseAuto,4
    jne autoFase5
    cmp estado,ESTADO_MENU
    jne autoFalha
    cmp opcao,OPCAO_JOGAR
    jne autoFalha
    mov cx,1C0Dh
    call TeclaE03
    call LerTeclado
    cmp estado,ESTADO_SETOR
    jne autoFalha
    mov cx,1C0Dh
    call TeclaE03
    inc faseAuto
    ret
autoFase5:
    cmp faseAuto,5
    jne autoFase6
    cmp estado,ESTADO_PARTIDA
    jne autoFalha
    call ConferirReset
    ; Reinicio ja conferido com duracao integral. Encurtar apenas este teste.
    mov tempoRestante,1
    call DesenharStatus
    inc faseAuto
    ret
autoFase6:
    cmp faseAuto,6
    jne autoFase7
    cmp estado,ESTADO_PARTIDA
    je autoAguardar
    cmp estado,ESTADO_FIM
    jne autoFalha
    cmp scoreFinal,0
    jne autoFalha
    mov cx,4800h
    call TeclaE03
    inc faseAuto
    ret
autoFase7:
    cmp estado,ESTADO_MENU
    jne autoFalha
    mov cx,5000h
    call TeclaE03
    call LerTeclado
    cmp opcao,OPCAO_SAIR
    jne autoFalha
    mov cx,1C0Dh
    call TeclaE03
    ret
DirigirE03 endp

; Funcao: validar nova sessao. Entrada: dados reais. Saida: retorna/FAIL.
ConferirReset proc near
    cmp scorePartida,0
    jne autoFalha
    cmp vidas,VIDAS_INICIAIS
    jne autoFalha
    cmp tempoRestante,DURACAO_SEGUNDOS
    jne autoFalha
    cmp fracaoSegundo,0
    jne autoFalha
    cmp rolagem,0
    jne autoFalha
    ret
ConferirReset endp

; Funcao: registrar instante do fim. Entrada: nenhuma. Saida: fimRealHi/Lo.
RegistrarFim proc near
    call LerCentissegundos
    mov fimRealLo,ax
    mov fimRealHi,dx
    ret
RegistrarFim endp

; Funcao: confirmar limpeza de teclado. Entrada: BIOS. Saida: retorna/FAIL.
BufferE03 proc near
    mov ah,01h
    int 16h
    jnz autoFalha
    ret
BufferE03 endp

; Funcao: inserir tecla. Entrada: CH=scan, CL=ASCII. Saida: tecla ou FAIL.
TeclaE03 proc near
    mov ah,05h
    int 16h
    cmp al,0
    jne autoFalha
    ret
TeclaE03 endp

; Funcao: exportar A000h real. Entrada: DS:DX=arquivo. Saida: RAW 64000 bytes.
SalvarTelaE03 proc near
    xor cx,cx
    mov ah,3Ch
    int 21h
    jc autoFalha
    mov bx,ax
    push ds
    mov ax,VIDEO_SEG
    mov ds,ax
    xor dx,dx
    mov cx,64000
    mov ah,40h
    int 21h
    pop ds
    jc autoFalha
    cmp ax,64000
    jne autoFalha
    mov ah,3Eh
    int 21h
    jc autoFalha
    ret
SalvarTelaE03 endp

autoFalha:
    mov ax,3
    int 10h
    mov al,faseAuto
    add al,'0'
    mov autoFaseErro,al
    lea dx,autoErro
    mov ah,09h
    int 21h
    mov ax,4C01h
    int 21h
