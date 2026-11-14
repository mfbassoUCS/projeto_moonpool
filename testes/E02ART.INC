; Prancha ESTATICA auxiliar. Nao integra telas ou regras da partida.
.data
nomeGaleria db 'GALERIA.RAW',0
nomeBitmaps db 'ARTES.BIN',0
fundoCratera db CRATERA_BYTES dup(0Eh)
galeriaIndice dw 0
galeriaX dw 16,80,144,208,16,80,144,208,208,248,288,16,64,112,160,0,0
galeriaY dw 24,24,24,24,64,64,64,64,102,102,102,102,102,102,102,136,168
galeriaLarg dw 20,14,14,14,18,18,18,7,14,14,14,12,12,12,12,320,320
galeriaAlt dw 10,14,14,14,11,11,11,8,7,7,7,10,10,10,10,64,32
galeriaBitmap dw offset bitmapJipe,offset bitmapNave1,offset bitmapNave2,offset bitmapNave3
 dw offset bitmapVidas3,offset bitmapVidas2,offset bitmapVidas1,offset bitmapRelogio
 dw offset bitmapCratera1,offset bitmapCratera2,offset bitmapCratera3
 dw offset bitmapRocha1,offset bitmapRocha2,offset bitmapRocha3,offset bitmapRocha4
 dw offset bitmapMontanhas,offset bitmapMontes
galTitulo db 'ARTES AUTORAIS - E02'
GAL_TITULO_TAM equ $-galTitulo
galMenu db '  JIPE    NAVE 1  NAVE 2  NAVE 3'
GAL_MENU_TAM equ $-galMenu
galHud db ' VIDAS 3 VIDAS 2 VIDAS 1 RELOGIO'
GAL_HUD_TAM equ $-galHud
galObst db '  R1    R2    R3    R4    C1   C2   C3'
GAL_OBST_TAM equ $-galObst
galRelevo db 'RELEVO: APENAS DADOS ESTATICOS'
GAL_RELEVO_TAM equ $-galRelevo
.code
; Funcao: desenhar 17 artes com rotinas reais e exportar pixels/bitmaps.
; Entrada: DS=dados, ES=A000h, modo 13h. Saida: GALERIA.RAW e ARTES.BIN.
; Altera: AX,BX,CX,DX,SI,DI,flags e video. Nao movimenta objetos.
TestarGaleria proc near
    call LimparTela
    lea si,galTitulo
    mov cx,GAL_TITULO_TAM
    mov dx,000Ah
    mov bl,COR_BRANCO
    call EscreverTexto
    lea si,galMenu
    mov cx,GAL_MENU_TAM
    mov dx,0200h
    call EscreverTexto
    lea si,galHud
    mov cx,GAL_HUD_TAM
    mov dx,0700h
    call EscreverTexto
    lea si,galObst
    mov cx,GAL_OBST_TAM
    mov dx,0B00h
    call EscreverTexto
    lea si,galRelevo
    mov cx,GAL_RELEVO_TAM
    mov dx,0F00h
    call EscreverTexto
    mov galeriaIndice,0
galeriaObjeto:
    mov di,galeriaIndice
    mov ax,galeriaX[di]
    mov bx,galeriaY[di]
    mov cx,galeriaLarg[di]
    mov dx,galeriaAlt[di]
    cmp di,16
    jb galeriaSprite
    cmp di,20
    ja galeriaSprite
    lea si,fundoCratera
    call DesenharBitmap
galeriaSprite:
    mov si,galeriaBitmap[di]
    call DesenharSprite
    add galeriaIndice,2
    cmp galeriaIndice,34
    jb galeriaObjeto
    lea dx,nomeGaleria
    call SalvarTelaTeste
    ; Exportar os dados efetivamente montados (inclui FFh e preto opaco).
    lea dx,nomeBitmaps
    xor cx,cx
    mov ah,3Ch
    int 21h
    jc galeriaFalha
    mov bx,ax
    lea dx,bitmapJipe
    mov cx,bitmapMontesFim-bitmapJipe
    mov ah,40h
    int 21h
    jc galeriaFalha
    cmp ax,bitmapMontesFim-bitmapJipe
    jne galeriaFalha
    mov ah,3Eh
    int 21h
    jc galeriaFalha
    ret
galeriaFalha:
    jmp autoFalha
TestarGaleria endp
