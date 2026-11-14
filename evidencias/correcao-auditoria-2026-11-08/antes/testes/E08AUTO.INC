; Funcao: fluxo completo com clocks reais e encounters controlados.
; Entrada: nenhuma. Saida: log, duracao DOS e sinais para Stopwatch Windows.
inicio proc
    mov ax,@data
    mov ds,ax
    mov ax,3509h
    int 21h
    mov autoVetor,bx
    mov autoVetor+2,es
    mov modoAnterior,3
    mov paginaAnterior,0
    mov ax,13h
    int 10h
    mov ax,VIDEO_SEG
    mov es,ax
    call EntrarMenu
    call ComecarAutoE08
    mov caso,1
    cmp tempoRestante,90
    jne FalhaE08
    mov tempoRestante,6       ; somente harness, depois de verificar reset normal
    mov proximoEm,10000
    mov obstTipo,4
    mov obstX,45
    mov naveAtiva,1
    mov naveAtiva+2,0
    mov naveAtiva+4,0
    mov naveX,22
    mov naveY,86
    mov esperaNave,0
    mov al,SCAN_ESPACO
    call RegistrarScanJipe
    call LerCentissegundos
    mov autoInicioLo,ax
    mov autoInicioHi,dx
    mov autoSinal,1
    call SinalAutoE08
autoRodar:
    call AtualizarPartida
    inc autoMedidas+6
    cmp scorePartida,150
    jne autoRodarEstado
    cmp autoMedidas+4,0
    jne autoRodarEstado
    mov autoMedidas+4,1
    mov jipeX,20             ; arranjo: entrar na trajetoria do branco ja emitido
    mov jipeMudou,1
autoRodarEstado:
    cmp estado,ESTADO_PARTIDA
    je autoRodar
    call LerCentissegundos
    sub ax,autoInicioLo
    sbb dx,autoInicioHi
    mov autoMedidas,ax
    mov autoMedidas+2,dx
    mov autoSinal,2
    call SinalAutoE08
    mov caso,2
    cmp estado,ESTADO_FIM
    jne FalhaE08
    mov caso,21
    cmp tempoRestante,0
    jne FalhaE08
    mov caso,22
    cmp scoreFinal,150
    jne FalhaE08
    mov caso,23
    cmp vidas,2               ; branco da nave destruida ainda atingiu o jipe
    jne FalhaE08
    mov caso,24
    cmp jipeAtivo,1           ; voltou em X=0 por D14
    jne FalhaE08
    mov caso,25
    cmp jipeX,0
    jne FalhaE08
    call ConferirVetorE08
    mov cx,1E61h
    call TeclaAutoE08
    call LerTeclado
    call ComecarAutoE08
    mov caso,3
    cmp vidas,3
    jne FalhaE08
    cmp scorePartida,0
    jne FalhaE08
    cmp tempoRestante,90
    jne FalhaE08
    xor di,di
autoResetTiros:
    cmp tiroAtivo[di],0
    jne FalhaE08
    add di,2
    cmp di,TIRO_MAX*2
    jb autoResetTiros
    mov vidas,1
    mov scorePartida,150
    mov tiroAtivo+TIRO_INI_INICIO,1
    mov tiroX+TIRO_INI_INICIO,3
    mov tiroY+TIRO_INI_INICIO,179
    call AtualizarPartida
    mov caso,4
    cmp estado,ESTADO_FIM
    jne FalhaE08
    cmp vidas,0
    jne FalhaE08
    cmp scoreFinal,150
    jne FalhaE08
    call ConferirVetorE08
    mov cx,4800h
    call TeclaAutoE08
    call LerTeclado
    mov cx,5000h
    call TeclaAutoE08
    call LerTeclado
    mov cx,1C0Dh
    call TeclaAutoE08
    call LerTeclado
    cmp estado,ESTADO_SAIR
    jne FalhaE08
    mov ax,3
    int 10h
    lea dx,autoNomeTempo
    xor cx,cx
    mov ah,3Ch
    int 21h
    jc FalhaE08
    mov bx,ax
    lea dx,autoMedidas
    mov cx,8
    mov ah,40h
    int 21h
    jc FalhaE08
    cmp ax,8
    jne FalhaE08
    mov ah,3Eh
    int 21h
    lea dx,okE08
    mov ah,09h
    int 21h
    mov ax,4C00h
    int 21h
inicio endp
; Funcao: menu -> setor -> partida. Entrada: MENU. Saida: PARTIDA por BIOS.
ComecarAutoE08 proc near
    mov cx,1C0Dh
    call TeclaAutoE08
    call LerTeclado
    cmp estado,ESTADO_SETOR
    jne FalhaE08
    mov cx,1C0Dh
    call TeclaAutoE08
    call LerTeclado
    cmp estado,ESTADO_PARTIDA
    jne FalhaE08
    ret
ComecarAutoE08 endp
; Funcao: inserir tecla sintetica. Entrada: CX=scan/ASCII. Saida: buffer BIOS.
TeclaAutoE08 proc near
    mov ah,05h
    int 16h
    or al,al
    jnz FalhaE08
    ret
TeclaAutoE08 endp
; Funcao: conferir retorno da IRQ. Entrada: vetor salvo. Saida: PASS ou falha.
ConferirVetorE08 proc near
    push es
    mov ax,3509h
    int 21h
    cmp bx,autoVetor
    jne FalhaE08
    mov ax,es
    cmp ax,autoVetor+2
    jne FalhaE08
    pop es
    ret
ConferirVetorE08 endp
; Funcao: sinalizar instante ao host. Entrada: autoSinal. Saida: byte no DOS.
SinalAutoE08 proc near
    lea dx,autoNome
    xor cx,cx
    mov ah,3Ch
    int 21h
    jc FalhaE08
    mov bx,ax
    lea dx,autoSinal
    mov cx,1
    mov ah,40h
    int 21h
    jc FalhaE08
    mov ah,3Eh
    int 21h
    ret
SinalAutoE08 endp
