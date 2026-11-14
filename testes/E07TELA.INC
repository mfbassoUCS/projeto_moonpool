; Funcao: exercitar telas e entrada BIOS reais, com tempo e capturas.
; Entrada: nenhuma. Saida: PASS/FAIL DOS, seis RAW e medidas de duracao.
inicio proc
    mov ax,@data
    mov ds,ax
    mov ah,0Fh
    int 10h
    mov modoAnterior,al
    mov paginaAnterior,bh
    mov ax,13h
    int 10h
    mov ax,VIDEO_SEG
    mov es,ax
    call EntrarMenu
    lea dx,nomeTela
    call DumpTelaE07
    call LerCentissegundos
    mov horaTelaLo,ax
    mov horaTelaHi,dx
telaAnimar:
    call AtualizarAnimacao
    cmp quadrosTela,320
    jb telaAnimar
    call LerCentissegundos
    sub ax,horaTelaLo
    sbb dx,horaTelaHi
    mov medidasTela,ax
    mov medidasTela+2,dx
    lea dx,nomeMov
    call DumpTelaE07
    mov faseTela,1
    mov cx,5000h
    call TeclaTelaE07
    call LerTeclado
    cmp opcao,OPCAO_SAIR
    jne FalhaTelaE07
    lea dx,nomeSel
    call DumpTelaE07
    mov cx,4800h
    call TeclaTelaE07
    call LerTeclado
    cmp opcao,OPCAO_JOGAR
    jne FalhaTelaE07
    mov cx,011Bh
    call TeclaTelaE07
    call LerTeclado
    mov cx,1E61h
    call TeclaTelaE07
    call LerTeclado
    cmp estado,ESTADO_MENU
    jne FalhaTelaE07
    mov faseTela,2
    mov tempoRestante,47       ; estado velho nao deve correr durante SETOR
    mov cx,1C0Dh
    call TeclaTelaE07
    call TeclaTelaE07          ; Enter ja enfileirado nao deve pular a tela
    call LerTeclado
    cmp estado,ESTADO_SETOR
    jne FalhaTelaE07
    call BufferVazioE07
    lea dx,nomeSet
    call DumpTelaE07
    mov cx,5000h
    call TeclaTelaE07
    call LerTeclado
    mov cx,1E61h
    call TeclaTelaE07
    call LerTeclado
    call LerCentissegundos
    mov esperaTelaLo,ax
    mov esperaTelaHi,dx
telaEsperarSetor:
    call LerTeclado
    cmp estado,ESTADO_SETOR
    jne FalhaTelaE07
    cmp tempoRestante,47
    jne FalhaTelaE07
    call LerCentissegundos
    sub ax,esperaTelaLo
    sbb dx,esperaTelaHi
    or dx,dx
    jnz telaEsperou
    cmp ax,200
    jb telaEsperarSetor
telaEsperou:
    mov medidasTela+4,ax
    mov medidasTela+6,dx
    mov faseTela,3
    mov cx,1C0Dh
    call TeclaTelaE07
    call TeclaTelaE07
    call LerTeclado
    cmp estado,ESTADO_PARTIDA
    jne FalhaTelaE07
    cmp tempoRestante,90
    jne FalhaTelaE07
    cmp scorePartida,0
    jne FalhaTelaE07
    cmp vidas,3
    jne FalhaTelaE07
    cmp rolagem,0
    jne FalhaTelaE07
    call BufferVazioE07
    mov ax,65535               ; tela no limite do formato, nao ganho de jogo
    call EntrarGameOver
    cmp tecladoJogoAtivo,0
    jne FalhaTelaE07
    lea dx,nomeFim
    call DumpTelaE07
    mov faseTela,4
    mov cx,4800h               ; seta tambem vale como qualquer tecla
    call TeclaTelaE07
    call LerTeclado
    cmp estado,ESTADO_MENU
    jne FalhaTelaE07
    cmp opcao,OPCAO_JOGAR
    jne FalhaTelaE07
    lea dx,nomeRet
    call DumpTelaE07
    ; Outra tela final: letra comum tambem retorna, sem ficar enfileirada.
    xor ax,ax
    call EntrarGameOver
    mov cx,1E61h
    call TeclaTelaE07
    call LerTeclado
    cmp estado,ESTADO_MENU
    jne FalhaTelaE07
    call BufferVazioE07
    mov cx,5000h
    call TeclaTelaE07
    call LerTeclado
    mov cx,1C0Dh
    call TeclaTelaE07
    call LerTeclado
    cmp estado,ESTADO_SAIR
    jne FalhaTelaE07
    call GravarMedidasE07
    call VoltarVideoE07
    lea dx,telaOk
    mov ah,09h
    int 21h
    mov ax,4C00h
    int 21h
inicio endp
; Funcao: inserir uma tecla BIOS. Entrada: CX=scan/ASCII. Saida: buffer.
TeclaTelaE07 proc near
    mov ah,05h
    int 16h
    or al,al
    jnz FalhaTelaE07
    ret
TeclaTelaE07 endp
; Funcao: verificar descarte de teclas antigas. Entrada: buffer BIOS.
; Saida: falha se houver tecla, sem consumir uma entrada para esconder erro.
BufferVazioE07 proc near
    mov ah,01h
    int 16h
    jnz FalhaTelaE07
    ret
BufferVazioE07 endp
; Funcao: exportar video real. Entrada: DX=nome. Saida: RAW de 64000 bytes.
DumpTelaE07 proc near
    xor cx,cx
    mov ah,3Ch
    int 21h
    jc FalhaTelaE07
    mov bx,ax
    push ds
    mov ax,VIDEO_SEG
    mov ds,ax
    xor dx,dx
    mov cx,64000
    mov ah,40h
    int 21h
    pop ds
    jc FalhaTelaE07
    cmp ax,cx
    jne FalhaTelaE07
    mov ah,3Eh
    int 21h
    ret
DumpTelaE07 endp
; Funcao: gravar duracoes medidas no DOS. Entrada: quatro words.
; Saida: arquivo E07TELA.BIN.
GravarMedidasE07 proc near
    lea dx,nomeMedidas
    xor cx,cx
    mov ah,3Ch
    int 21h
    jc FalhaTelaE07
    mov bx,ax
    lea dx,medidasTela
    mov cx,8
    mov ah,40h
    int 21h
    jc FalhaTelaE07
    cmp ax,cx
    jne FalhaTelaE07
    mov ah,3Eh
    int 21h
    ret
GravarMedidasE07 endp
; Funcao: restaurar vetor e video anterior. Entrada: modo/pagina salvos.
; Saida: DOS em modo anterior, sem IRQ de jogo instalada.
VoltarVideoE07 proc near
    call RestaurarTecladoJogo
    xor ah,ah
    mov al,modoAnterior
    int 10h
    mov ah,05h
    mov al,paginaAnterior
    int 10h
    ret
VoltarVideoE07 endp
FalhaTelaE07:
    call VoltarVideoE07
    mov ax,faseTela
    call FormatarScore
    lea dx,telaErro
    mov ah,09h
    int 21h
    lea dx,digitosScore
    mov bx,1
    mov cx,5
    mov ah,40h
    int 21h
    mov ax,4C01h
    int 21h
