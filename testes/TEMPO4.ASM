; Moon Patrol - E01: somente demonstracao da base tecnica.
; TASM, modo Turbo 16-bit, EXE DOS. Fonte ASCII para o ambiente DOS.
.8086
.model small
.stack 100h

VIDEO_MODO      equ 13h
VIDEO_SEG       equ 0A000h
TELA_LARG       equ 320
TELA_ALT        equ 200
TELA_BYTES      equ TELA_LARG * TELA_ALT
COR_FUNDO       equ 1
COR_FAIXA       equ 3
COR_BRANCO      equ 15
COR_TESTE       equ 14
TECLA_ESC       equ 27
TICKS_MOVIMENTO equ 4             ; aproximadamente 110 ms
PASSO_TESTE     equ 2
TESTE_LARG      equ 8
TESTE_ALT       equ 8
TESTE_Y         equ 96
TESTE_X_MAX     equ TELA_LARG - TESTE_LARG
FAIXA_Y         equ 100
FAIXA_ALT       equ 4
SEG_POR_MINUTO  equ 60
ESTADO_DEMO     equ 0
ESTADO_SAIR     equ 1

.data
modoAnterior   db 3
paginaAnterior db 0
estado         db ESTADO_DEMO
posX           dw 0
ultimoTick     dw 0
ultimoSegundo  db 0
segundos       dw 0
bitmapTeste    db TESTE_LARG * TESTE_ALT dup(COR_TESTE)
fundoSalvo     db TESTE_LARG * TESTE_ALT dup(?)
texto          db 'E01 - ESC sai | Segundos: '
digitos        db '00000'
TEXTO_TAM      equ $ - texto

.code
; Funcao: iniciar demo, consultar teclado/tempo e sair pelo DOS.
; Entrada: nenhuma. Saida: codigo DOS 0. Altera: registradores/segmentos.
inicio proc
    mov ax, @data
    mov ds, ax
    mov ah, 0Fh
    int 10h
    mov modoAnterior, al
    mov paginaAnterior, bh
    mov ax, VIDEO_MODO
    int 10h
    mov ax, VIDEO_SEG
    mov es, ax
    cld
    call DesenharFundo
    call SalvarEDesenhar
    mov ah, 00h
    int 1Ah
    mov ultimoTick, dx
    mov ah, 2Ch
    int 21h
    mov ultimoSegundo, dh
    call MostrarTempo
ciclo:
    call LerTeclado
    cmp estado, ESTADO_SAIR
    je sair
    call AtualizarTempo
    cmp segundos,5
    jb continuarTeste
    jmp sair
continuarTeste:
    mov ah, 00h
    int 1Ah                       ; CX:DX = ticks desde meia-noite
    mov ax, dx
    sub ax, ultimoTick            ; subtracao modular de 16 bits
    cmp ax, TICKS_MOVIMENTO
    jb ciclo
    mov ultimoTick, dx
    call MoverTeste
    jmp ciclo
sair:
    xor ah, ah
    mov al, modoAnterior
    int 10h
    mov ah, 05h
    mov al, paginaAnterior
    int 10h
    mov ax,posX
    call NumeroTeste
    mov ax,segundos
    call NumeroTeste
    mov ax,4C00h
    int 21h
inicio endp

; Funcao: pintar fundo e marcadores de verificacao por memoria.
; Entrada: ES=VIDEO_SEG. Saida: tela preenchida. Altera: AX,CX,DI,flags.
DesenharFundo proc near
    cld
    xor di, di
    mov al, COR_FUNDO
    mov cx, TELA_BYTES
    rep stosb
    mov di, FAIXA_Y * TELA_LARG
    mov al, COR_FAIXA
    mov cx, FAIXA_ALT * TELA_LARG
    rep stosb
    xor di, di
    mov byte ptr es:[di], COR_BRANCO
    mov di, TELA_LARG-1
    mov byte ptr es:[di], COR_BRANCO
    mov di, (TELA_ALT-1)*TELA_LARG
    mov byte ptr es:[di], COR_BRANCO
    mov di, TELA_BYTES-1
    mov byte ptr es:[di], COR_BRANCO
    mov di, 10*TELA_LARG+100       ; 0CE4h
    mov byte ptr es:[di], COR_TESTE
    ret
DesenharFundo endp

; Funcao: validar retangulo inteiro e calcular endereco inicial.
; Entrada: AX=x, BX=y, CX=largura, DX=altura (valores sem sinal).
; Saida: CF=0 valido: DI=y*320+x, BP=altura, BX=salto entre linhas.
;        CF=1 invalido, nao acessar video. Nao ha recorte parcial.
; Altera: AX,BX,DX,DI,BP,flags. Preserva: CX,SI,DS,ES.
PrepararRetangulo proc near
    cmp cx, 1
    jb retanguloInvalido
    cmp cx, TELA_LARG
    ja retanguloInvalido
    cmp dx, 1
    jb retanguloInvalido
    cmp dx, TELA_ALT
    ja retanguloInvalido
    mov di, TELA_LARG
    sub di, cx
    cmp ax, di
    ja retanguloInvalido
    mov di, TELA_ALT
    sub di, dx
    cmp bx, di
    ja retanguloInvalido
    mov bp, dx
    mov di, ax
    mov ax, bx
    mov bx, TELA_LARG
    mul bx                       ; DX:AX=y*320; sempre cabe em AX
    add di, ax
    sub bx, cx
    clc
    ret
retanguloInvalido:
    stc
    ret
PrepararRetangulo endp

; Funcao: copiar bitmap opaco linha a linha para o video.
; Entrada: DS:SI=bitmap, ES=VIDEO_SEG, AX=x,BX=y,CX=largura,DX=altura.
;          Origem deve conter largura*altura bytes no segmento DS.
; Saida: retangulo desenhado; coordenadas invalidas nao escrevem nada.
; Preserva: todos os registradores. Altera: flags (DF fica zero), video.
DesenharBitmap proc near
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp
    cld                          ; garante DF=0 inclusive se a area for invalida
    call PrepararRetangulo
    jc desenhoFim
desenhoLinha:
    push cx
    rep movsb                    ; DS:SI -> ES:DI; avanca SI e DI
    pop cx
    add di, bx                   ; pula pixels fora do retangulo
    dec bp
    jnz desenhoLinha
desenhoFim:
    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
DesenharBitmap endp

; Funcao: guardar fundo antes de colocar um bitmap sobre ele.
; Entrada: DS:SI=buffer de largura*altura bytes; demais como DesenharBitmap.
; Saida: fundo salvo no buffer; coordenadas invalidas nao copiam nada.
; Preserva: todos os registradores. Altera: flags e buffer em DS.
SalvarFundo proc near
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp
    call PrepararRetangulo
    jc salvarFim
salvarLinha:
    push cx
salvarPixel:
    mov al, es:[di]
    mov [si], al
    inc di
    inc si
    loop salvarPixel
    pop cx
    add di, bx
    dec bp
    jnz salvarLinha
salvarFim:
    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
SalvarFundo endp

; Funcao: salvar fundo na posicao atual e desenhar quadrado de teste.
; Entrada: posX em DS, ES=VIDEO_SEG. Saida: buffer e video atualizados.
; Altera: AX,BX,CX,DX,SI,flags. Preserva: DI,BP,DS,ES.
SalvarEDesenhar proc near
    mov ax, posX
    mov bx, TESTE_Y
    mov cx, TESTE_LARG
    mov dx, TESTE_ALT
    lea si, fundoSalvo
    call SalvarFundo
    lea si, bitmapTeste
    call DesenharBitmap
    ret
SalvarEDesenhar endp

; Funcao: restaurar fundo anterior e mover quadrado, com retorno a x=0.
; Entrada: posX/fundoSalvo, ES=VIDEO_SEG. Saida: posX e tela atualizados.
; Altera: AX,BX,CX,DX,SI,flags. Preserva: DI,BP,DS,ES.
MoverTeste proc near
    mov ax, posX
    mov bx, TESTE_Y
    mov cx, TESTE_LARG
    mov dx, TESTE_ALT
    lea si, fundoSalvo
    call DesenharBitmap           ; restaura azul E ciano, nao pinta preto
    add posX, PASSO_TESTE
    cmp posX, TESTE_X_MAX
    jbe moverDesenhar
    mov posX, 0
moverDesenhar:
    call SalvarEDesenhar
    ret
MoverTeste endp

; Funcao: consumir no maximo uma tecla, sem bloquear quando nao ha tecla.
; Entrada: nenhuma. Saida: estado=ESTADO_SAIR se Esc foi pressionado.
; Altera: AX,flags. Preserva: demais registradores.
LerTeclado proc near
    mov ah, 01h
    int 16h
    jz tecladoFim
    mov ah, 00h
    int 16h
    cmp al, TECLA_ESC
    jne tecladoFim
    mov estado, ESTADO_SAIR
tecladoFim:
    ret
LerTeclado endp

; Funcao: acumular segundos do relogio DOS, independente dos movimentos.
; Entrada: ultimoSegundo e segundos. Saida: contador/texto atualizados.
; Altera: AX,CX,DX,flags. Preserva: BX,SI,DI,BP,DS,ES.
; Limite: consultar ao menos uma vez por minuto; pausa longa no debugger
; nao e contabilizada integralmente. Contador word volta a zero apos 65535.
AtualizarTempo proc near
    mov ah, 2Ch
    int 21h                      ; CH=hora, CL=minuto, DH=segundo, DL=centesimo
    cmp dh, ultimoSegundo
    je tempoFim
    mov al, dh
    sub al, ultimoSegundo
    jnc tempoSomar
    add al, SEG_POR_MINUTO       ; exemplo: 59 -> 0 representa um segundo
tempoSomar:
    mov ultimoSegundo, dh
    xor ah, ah
    add segundos, ax
    call MostrarTempo
tempoFim:
    ret
AtualizarTempo endp

; Funcao: converter contador em cinco digitos e escrever texto via BIOS.
; Entrada: segundos, DS=dados. Saida: texto na linha 2, coluna 0.
; Preserva: todos os registradores, inclusive ES de video. Altera: flags.
MostrarTempo proc near
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp
    push es
    mov ax, segundos
    mov bx, 10
    mov cx, 5
    lea di, digitos+4
tempoDigito:
    xor dx, dx
    div bx                       ; AX=quociente; DX=resto (digito)
    add dl, '0'
    mov [di], dl
    dec di
    loop tempoDigito
    push ds
    pop es                       ; INT 10h/AH=13h recebe texto em ES:BP
    lea bp, texto
    mov ax, 1300h
    mov bx, COR_BRANCO           ; BH=pagina 0, BL=cor
    mov cx, TEXTO_TAM
    mov dx, 0200h                ; DH=linha 2, DL=coluna 0
    int 10h
    pop es
    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
MostrarTempo endp

; Funcao: imprimir word decimal com 5 digitos e espaco para o log.
; Entrada: AX=numero. Saida: texto DOS. Altera: AX,BX,CX,DX,DI,flags.
NumeroTeste proc near
    mov bx,10
    mov cx,5
    lea di,digitos+4
ntDiv:
    xor dx,dx
    div bx
    add dl,'0'
    mov [di],dl
    dec di
    loop ntDiv
    lea di,digitos
    mov cx,5
ntPrint:
    mov dl,[di]
    mov ah,02h
    int 21h
    inc di
    loop ntPrint
    mov dl,' '
    mov ah,02h
    int 21h
    ret
NumeroTeste endp
end inicio
