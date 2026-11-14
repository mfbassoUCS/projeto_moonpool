; Moon Patrol - E04: jipe e salto sobre o cenario continuo da E03.
; TASM 4.1 / TLINK, Turbo 16-bit. Fonte ASCII, instrucoes 8086.
; Menu -> SETOR 1 -> partida com jipe -> fim por tempo. Sem obstaculos.
.8086
.model small
.stack 100h

VIDEO_MODO       equ 13h
VIDEO_SEG        equ 0A000h
TELA_LARG        equ 320
TELA_ALT         equ 200
TELA_BYTES       equ TELA_LARG * TELA_ALT
TEXTO_COLUNAS    equ 40
COR_FUNDO        equ 00h
COR_TITULO       equ 0Ah
COR_SELECAO      equ 0Ch
COR_BRANCO       equ 0Fh
COR_GAMEOVER     equ 04h
COR_AVISO        equ 0Eh
TRANSPARENTE     equ 0FFh         ; preto 00h continua sendo pixel opaco
TECLA_ENTER      equ 13
SCAN_CIMA        equ 48h
SCAN_BAIXO       equ 50h
SCAN_ESQUERDA    equ 4Bh
SCAN_DIREITA     equ 4Dh
BIT_ESQUERDA    equ 1
BIT_DIREITA     equ 2
BIT_CIMA        equ 4
TICKS_MOVIMENTO  equ 2            ; mesma cadencia da E01 (~110 ms)
PASSO_MENU       equ 2
MENU_QUANT       equ 4
MENU_Y          equ 96
MENU_X_JIPE      equ 0
MENU_X_NAVE1     equ 80
MENU_X_NAVE2     equ 160
MENU_X_NAVE3     equ 240
OPCAO_JOGAR      equ 0
OPCAO_SAIR       equ 1
ESTADO_MENU      equ 0
ESTADO_SETOR     equ 1
ESTADO_FIM       equ 2
ESTADO_SAIR      equ 3
ESTADO_PARTIDA   equ 4
; Escolhas tecnicas E03 (D01/D02/D03/D10), nao confirmacoes do professor.
DURACAO_SEGUNDOS equ 4           ; configuravel: 1..999
VIDAS_INICIAIS   equ 3            ; configuravel: 1..3
TICKS_CENARIO    equ 2
PASSO_CENARIO    equ 2            ; 1..319 pixels para a esquerda
CENARIO_Y       equ 100
MONTES_Y        equ 132           ; bases das artes alinhadas em y=163
PISTA_ALT       equ 7
PISTA_Y         equ TELA_ALT-PISTA_ALT
COR_PISTA       equ 0Eh
HUD_ALT         equ 15
HUD_VIDAS_X     equ (TELA_LARG-VIDAS_LARG)/2
HUD_VIDAS_Y     equ 2
HUD_RELOGIO_X   equ 280
HUD_RELOGIO_Y   equ 3
HUD_SCORE_POS   equ 0             ; linha 0, coluna 0
TEMPO_DIGITOS   equ 3
HUD_TEMPO_POS   equ TEXTO_COLUNAS-TEMPO_DIGITOS
CENT_POR_SEG    equ 100
MARGEM_RELOGIO  equ 6            ; 60 ms uma vez: cobre quantum DOS (~55 ms)
CENT_DIA_BAIXO  equ 0D600h        ; 8640000 = 0083:D600h centesimos/dia
CENT_DIA_ALTO   equ 0083h
SCORE_DIGITOS    equ 5
TITULO_LINHA     equ 2
AVISO_LINHA      equ 8
CAIXA_COL        equ 14
CAIXA_JOGAR      equ 16
CAIXA_SAIR       equ 20
CAIXA_LARG       equ 11
CAIXA_ALT        equ 3
AJUDA_LINHA      equ 24
SETOR_LINHA      equ 7
DEMO_LINHA       equ 19
AVANCO_LINHA     equ 21
GAME_LINHA       equ 3
OVER_LINHA       equ 10
SCORE_LINHA      equ 17
JIPE_LARG        equ 20
JIPE_ALT         equ 10
JIPE_BYTES       equ JIPE_LARG * JIPE_ALT
; D08: x e a borda esquerda; ultimo pixel x+19 <= 159.
JIPE_X_INICIAL  equ 0
JIPE_X_MAX      equ TELA_LARG/2-JIPE_LARG
JIPE_Y_CHAO     equ PISTA_Y-JIPE_ALT ; 193-10=183; ocupa 183..192
TICKS_JIPE      equ 1
PASSO_JIPE      equ 3
; Reserva de velocidade para E06, nao implementa naves na partida.
TICKS_NAVE      equ 2
PASSO_NAVE      equ 1
SALTO_ALTURA    equ 15
SALTO_PASSO     equ 3
SALTO_TOPO_PX   equ 5
SALTO_CHAO      equ 0
SALTO_SUBINDO   equ 1
SALTO_TOPO      equ 2
SALTO_DESCENDO  equ 3
NAVE_LARG        equ 14
NAVE_ALT         equ 14
NAVE_BYTES       equ NAVE_LARG * NAVE_ALT
VIDAS_LARG       equ 18
VIDAS_ALT        equ 11
VIDAS_BYTES      equ VIDAS_LARG * VIDAS_ALT
RELOGIO_LARG     equ 7
RELOGIO_ALT      equ 8
RELOGIO_BYTES    equ RELOGIO_LARG * RELOGIO_ALT
CRATERA_LARG     equ 14
CRATERA_ALT      equ 7
CRATERA_BYTES    equ CRATERA_LARG * CRATERA_ALT
ROCHA_LARG       equ 12
ROCHA_ALT        equ 10
ROCHA_BYTES      equ ROCHA_LARG * ROCHA_ALT
MONTANHAS_LARG   equ 320
MONTANHAS_ALT    equ 64           ; escolha de arte: abaixo do maximo 95
MONTES_LARG      equ 320
MONTES_ALT       equ 32           ; arte autoral E02 preservada

IF (DURACAO_SEGUNDOS LT 1) OR (DURACAO_SEGUNDOS GT 999)
 .ERR
ENDIF
IF (VIDAS_INICIAIS LT 1) OR (VIDAS_INICIAIS GT 3)
 .ERR
ENDIF
IF (PASSO_CENARIO LT 1) OR (PASSO_CENARIO GE TELA_LARG)
 .ERR
ENDIF
IF (TICKS_JIPE LT 1) OR (TICKS_NAVE LT 1) OR (TICKS_CENARIO LT 1)
 .ERR
ENDIF
IF (PASSO_JIPE LT 1) OR (PASSO_JIPE GT JIPE_X_MAX) OR (PASSO_NAVE LT 1)
 .ERR
ENDIF
IF (PASSO_JIPE*TICKS_NAVE LE PASSO_NAVE*TICKS_JIPE)
 .ERR                         ; velocidade do jipe deve superar a das naves
ENDIF
IF (JIPE_X_INICIAL LT 0) OR (JIPE_X_INICIAL GT JIPE_X_MAX)
 .ERR
ENDIF

.data
modoAnterior    db 3
paginaAnterior  db 0
estado          db ESTADO_MENU
opcao           db OPCAO_JOGAR
demonstracao    db 1             ; aviso de escopo E04, ainda sem obstaculos
ultimoTick      dw 0
scoreFinal      dw 0
scorePartida    dw 0             ; E03 nao gera pontos; sem risco de overflow
vidas           db VIDAS_INICIAIS
tempoRestante   dw DURACAO_SEGUNDOS
rolagem         dw 0             ; coluna da arte exibida na esquerda
tickCenario     dw 0
tempoAnteriorLo dw 0             ; instante DOS em centesimos desde meia-noite
tempoAnteriorHi dw 0
fracaoSegundo   dw 0             ; resto 0..99, preservado entre consultas
margemInicial   dw 0             ; evita fim antecipado pela quantizacao DOS
digitosTempo    db TEMPO_DIGITOS dup('0')
linhaCenario    db TELA_LARG dup(?) ; unica linha de composicao, nao tela inteira
jipeX          dw JIPE_X_INICIAL
jipeY          dw JIPE_Y_CHAO
jipeDesenhoX    dw 0             ; posicao do fundo capturado no quadro anterior
jipeDesenhoY    dw 0
tickJipe       dw 0
estadoSalto    db SALTO_CHAO
pixelsTopo     dw 0             ; D05: avanco do terreno, nao frames/teclas
teclasJipe     db 0             ; bits: esquerda, direita, cima pressionadas
pedidoSalto    db 0             ; borda de pressionamento; nunca fila de saltos
tecladoJogoAtivo db 0
vetorTeclado   dw 0,0           ; INT 09h anterior: offset, segmento
cenarioMudou   db 0
jipeMudou      db 0
fundoPartida   db JIPE_BYTES dup(?) ; so o fundo ATUAL sob o jipe, 200 bytes
menuXInicial    dw MENU_X_JIPE,MENU_X_NAVE1,MENU_X_NAVE2,MENU_X_NAVE3
menuX           dw MENU_QUANT dup(0)
menuY           dw MENU_Y+NAVE_ALT-JIPE_ALT,MENU_Y,MENU_Y,MENU_Y
menuLarg        dw JIPE_LARG,NAVE_LARG,NAVE_LARG,NAVE_LARG
menuAlt         dw JIPE_ALT,NAVE_ALT,NAVE_ALT,NAVE_ALT
menuBitmap      dw offset bitmapJipe,offset bitmapNave1,offset bitmapNave2,offset bitmapNave3
menuFundo       dw offset fundoJipe,offset fundoNave1,offset fundoNave2,offset fundoNave3
fundoJipe       db JIPE_BYTES dup(?)
fundoNave1      db NAVE_BYTES dup(?)
fundoNave2      db NAVE_BYTES dup(?)
fundoNave3      db NAVE_BYTES dup(?)

; ARTES_INICIO
; Desenhos proprios E02, autorizados em 25/10/2026.
; Grade editavel/origem: artes/gerar-artes.py e desenhos.json.
; Cada DB e uma linha. DUP repete bytes na montagem, nao no jogo.
; FFh transparente; 00h preto opaco. Nao sao copias do arcade.
; Jipe - 20 x 10
bitmapJipe db 6 dup(0FFh),0Fh,13 dup(0FFh)
           db 6 dup(0FFh),07h,4 dup(0FFh),3 dup(0Bh),6 dup(0FFh)
           db 6 dup(0FFh),07h,3 dup(0FFh),0Bh,2 dup(09h),2 dup(0Bh),5 dup(0FFh)
           db 6 dup(0FFh),07h,2 dup(0FFh),0Bh,3 dup(09h),3 dup(0Bh),4 dup(0FFh)
           db 3 dup(0FFh),13 dup(0Dh),3 dup(07h),0Fh
           db 2 dup(0FFh),3 dup(05h),2 dup(0Dh),7 dup(0Fh),4 dup(0Dh),2 dup(0FFh)
           db 18 dup(05h),2 dup(0FFh)
           db 3 dup(0FFh),08h,5 dup(0FFh),08h,5 dup(0FFh),08h,4 dup(0FFh)
           db 2 dup(0FFh),08h,0Fh,08h,3 dup(0FFh),08h,0Fh,08h,3 dup(0FFh),08h,0Fh,08h,3 dup(0FFh)
           db 3 dup(0FFh),08h,5 dup(0FFh),08h,5 dup(0FFh),08h,4 dup(0FFh)
bitmapJipeFim label byte
; Nave 1 - disco - 14 x 14
bitmapNave1 db 14 dup(0FFh)
            db 5 dup(0FFh),4 dup(0Bh),5 dup(0FFh)
            db 4 dup(0FFh),0Bh,4 dup(09h),0Bh,4 dup(0FFh)
            db 3 dup(0FFh),0Bh,6 dup(09h),0Bh,3 dup(0FFh)
            db 3 dup(0FFh),8 dup(07h),3 dup(0FFh)
            db 2 dup(0FFh),10 dup(0Eh),2 dup(0FFh)
            db 0FFh,2 dup(0Eh),06h,6 dup(0Eh),06h,2 dup(0Eh),0FFh
            db 14 dup(0Eh)
            db 2 dup(0FFh),10 dup(06h),2 dup(0FFh)
            db 3 dup(0FFh),0Eh,6 dup(0FFh),0Eh,3 dup(0FFh)
            db 2 dup(0FFh),0Ch,8 dup(0FFh),0Ch,2 dup(0FFh)
            db 3 dup(0FFh),04h,6 dup(0FFh),04h,3 dup(0FFh)
            db 14 dup(0FFh)
            db 14 dup(0FFh)
bitmapNave1Fim label byte
; Nave 2 - asas - 14 x 14
bitmapNave2 db 3 dup(0FFh),0Bh,6 dup(0FFh),0Bh,3 dup(0FFh)
            db 3 dup(0FFh),2 dup(0Bh),4 dup(0FFh),2 dup(0Bh),3 dup(0FFh)
            db 2 dup(0FFh),03h,2 dup(0Bh),03h,2 dup(0FFh),03h,2 dup(0Bh),03h,2 dup(0FFh)
            db 2 dup(0FFh),03h,3 dup(0Bh),2 dup(03h),3 dup(0Bh),03h,2 dup(0FFh)
            db 3 dup(0FFh),03h,6 dup(0Bh),03h,3 dup(0FFh)
            db 4 dup(0FFh),0Bh,4 dup(0Fh),0Bh,4 dup(0FFh)
            db 3 dup(0FFh),2 dup(0Bh),09h,2 dup(00h),09h,2 dup(0Bh),3 dup(0FFh)
            db 2 dup(0FFh),10 dup(0Bh),2 dup(0FFh)
            db 0FFh,03h,2 dup(0Bh),03h,4 dup(0Bh),03h,2 dup(0Bh),03h,0FFh
            db 03h,2 dup(0Bh),03h,2 dup(0FFh),2 dup(03h),2 dup(0FFh),03h,2 dup(0Bh),03h
            db 0FFh,03h,4 dup(0FFh),2 dup(0Ch),4 dup(0FFh),03h,0FFh
            db 6 dup(0FFh),2 dup(04h),6 dup(0FFh)
            db 14 dup(0FFh)
            db 14 dup(0FFh)
bitmapNave2Fim label byte
; Nave 3 - losango - 14 x 14
bitmapNave3 db 6 dup(0FFh),2 dup(0Dh),6 dup(0FFh)
            db 5 dup(0FFh),0Dh,2 dup(05h),0Dh,5 dup(0FFh)
            db 4 dup(0FFh),0Dh,4 dup(05h),0Dh,4 dup(0FFh)
            db 3 dup(0FFh),0Dh,6 dup(05h),0Dh,3 dup(0FFh)
            db 2 dup(0FFh),0Dh,2 dup(05h),0Fh,2 dup(05h),0Fh,2 dup(05h),0Dh,2 dup(0FFh)
            db 0FFh,0Dh,3 dup(05h),00h,2 dup(05h),00h,3 dup(05h),0Dh,0FFh
            db 0FFh,0Dh,10 dup(05h),0Dh,0FFh
            db 2 dup(0FFh),10 dup(0Dh),2 dup(0FFh)
            db 3 dup(0FFh),05h,6 dup(0Dh),05h,3 dup(0FFh)
            db 2 dup(0FFh),05h,2 dup(0FFh),0Dh,2 dup(05h),0Dh,2 dup(0FFh),05h,2 dup(0FFh)
            db 0FFh,05h,4 dup(0FFh),2 dup(0Ch),4 dup(0FFh),05h,0FFh
            db 6 dup(0FFh),2 dup(04h),6 dup(0FFh)
            db 14 dup(0FFh)
            db 14 dup(0FFh)
bitmapNave3Fim label byte
; Vidas 3 - 18 x 11
bitmapVidas3 db 18 dup(0FFh)
             db 18 dup(0FFh)
             db 18 dup(0FFh)
             db 0FFh,0Ch,0FFh,0Ch,3 dup(0FFh),0Ch,0FFh,0Ch,3 dup(0FFh),0Ch,0FFh,0Ch,2 dup(0FFh)
             db 0Ch,0Fh,3 dup(0Ch),0FFh,0Ch,0Fh,3 dup(0Ch),0FFh,0Ch,0Fh,3 dup(0Ch),0FFh
             db 5 dup(0Ch),0FFh,5 dup(0Ch),0FFh,5 dup(0Ch),0FFh
             db 0FFh,3 dup(0Ch),3 dup(0FFh),3 dup(0Ch),3 dup(0FFh),3 dup(0Ch),2 dup(0FFh)
             db 2 dup(0FFh),0Ch,5 dup(0FFh),0Ch,5 dup(0FFh),0Ch,3 dup(0FFh)
             db 18 dup(0FFh)
             db 18 dup(0FFh)
             db 18 dup(0FFh)
bitmapVidas3Fim label byte
; Vidas 2 - 18 x 11
bitmapVidas2 db 18 dup(0FFh)
             db 18 dup(0FFh)
             db 18 dup(0FFh)
             db 0FFh,0Ch,0FFh,0Ch,3 dup(0FFh),0Ch,0FFh,0Ch,3 dup(0FFh),08h,0FFh,08h,2 dup(0FFh)
             db 0Ch,0Fh,3 dup(0Ch),0FFh,0Ch,0Fh,3 dup(0Ch),0FFh,5 dup(08h),0FFh
             db 5 dup(0Ch),0FFh,5 dup(0Ch),0FFh,5 dup(08h),0FFh
             db 0FFh,3 dup(0Ch),3 dup(0FFh),3 dup(0Ch),3 dup(0FFh),3 dup(08h),2 dup(0FFh)
             db 2 dup(0FFh),0Ch,5 dup(0FFh),0Ch,5 dup(0FFh),08h,3 dup(0FFh)
             db 18 dup(0FFh)
             db 18 dup(0FFh)
             db 18 dup(0FFh)
bitmapVidas2Fim label byte
; Vidas 1 - 18 x 11
bitmapVidas1 db 18 dup(0FFh)
             db 18 dup(0FFh)
             db 18 dup(0FFh)
             db 0FFh,0Ch,0FFh,0Ch,3 dup(0FFh),08h,0FFh,08h,3 dup(0FFh),08h,0FFh,08h,2 dup(0FFh)
             db 0Ch,0Fh,3 dup(0Ch),0FFh,5 dup(08h),0FFh,5 dup(08h),0FFh
             db 5 dup(0Ch),0FFh,5 dup(08h),0FFh,5 dup(08h),0FFh
             db 0FFh,3 dup(0Ch),3 dup(0FFh),3 dup(08h),3 dup(0FFh),3 dup(08h),2 dup(0FFh)
             db 2 dup(0FFh),0Ch,5 dup(0FFh),08h,5 dup(0FFh),08h,3 dup(0FFh)
             db 18 dup(0FFh)
             db 18 dup(0FFh)
             db 18 dup(0FFh)
bitmapVidas1Fim label byte
; Relogio - 7 x 8
bitmapRelogio db 2 dup(0FFh),3 dup(0Eh),2 dup(0FFh)
              db 0FFh,0Eh,3 dup(00h),0Eh,0FFh
              db 0Eh,2 dup(00h),0Eh,2 dup(00h),0Eh
              db 0Eh,2 dup(00h),0Eh,2 dup(00h),0Eh
              db 0Eh,2 dup(00h),2 dup(0Eh),00h,0Eh
              db 0Eh,5 dup(00h),0Eh
              db 0FFh,0Eh,3 dup(00h),0Eh,0FFh
              db 2 dup(0FFh),3 dup(0Eh),2 dup(0FFh)
bitmapRelogioFim label byte
; Cratera 1 - 14 x 7
bitmapCratera1 db 3 dup(0FFh),8 dup(06h),3 dup(0FFh)
               db 0FFh,2 dup(06h),8 dup(08h),2 dup(06h),0FFh
               db 06h,08h,10 dup(00h),08h,06h
               db 06h,12 dup(00h),06h
               db 0FFh,06h,08h,8 dup(00h),08h,06h,0FFh
               db 2 dup(0FFh),2 dup(06h),6 dup(08h),2 dup(06h),2 dup(0FFh)
               db 4 dup(0FFh),6 dup(06h),4 dup(0FFh)
bitmapCratera1Fim label byte
; Cratera 2 - 14 x 7
bitmapCratera2 db 0FFh,3 dup(06h),4 dup(0FFh),3 dup(06h),3 dup(0FFh)
               db 06h,08h,2 dup(00h),4 dup(06h),08h,00h,08h,2 dup(06h),0FFh
               db 06h,11 dup(00h),08h,06h
               db 06h,08h,11 dup(00h),06h
               db 0FFh,06h,08h,8 dup(00h),08h,06h,0FFh
               db 2 dup(0FFh),2 dup(06h),08h,3 dup(00h),08h,3 dup(06h),2 dup(0FFh)
               db 4 dup(0FFh),5 dup(06h),5 dup(0FFh)
bitmapCratera2Fim label byte
; Cratera 3 - 14 x 7
bitmapCratera3 db 6 dup(0FFh),4 dup(06h),4 dup(0FFh)
               db 3 dup(0FFh),3 dup(06h),08h,2 dup(00h),08h,2 dup(06h),2 dup(0FFh)
               db 0FFh,2 dup(06h),08h,7 dup(00h),08h,06h,0FFh
               db 06h,08h,10 dup(00h),08h,06h
               db 06h,10 dup(00h),08h,06h,0FFh
               db 0FFh,2 dup(06h),08h,4 dup(00h),08h,3 dup(06h),2 dup(0FFh)
               db 3 dup(0FFh),6 dup(06h),5 dup(0FFh)
bitmapCratera3Fim label byte
; Rocha 1 - 12 x 10
bitmapRocha1 db 4 dup(0FFh),3 dup(07h),5 dup(0FFh)
             db 3 dup(0FFh),07h,2 dup(0Fh),2 dup(07h),4 dup(0FFh)
             db 2 dup(0FFh),07h,2 dup(0Fh),2 dup(07h),08h,07h,3 dup(0FFh)
             db 2 dup(0FFh),07h,0Fh,2 dup(07h),2 dup(08h),07h,3 dup(0FFh)
             db 0FFh,07h,0Fh,2 dup(07h),4 dup(08h),07h,2 dup(0FFh)
             db 0FFh,3 dup(07h),5 dup(08h),07h,2 dup(0FFh)
             db 2 dup(07h),8 dup(08h),07h,0FFh
             db 07h,3 dup(08h),07h,6 dup(08h),07h
             db 07h,10 dup(08h),07h
             db 12 dup(08h)
bitmapRocha1Fim label byte
; Rocha 2 - 12 x 10
bitmapRocha2 db 5 dup(0FFh),2 dup(06h),5 dup(0FFh)
             db 4 dup(0FFh),06h,2 dup(0Eh),06h,4 dup(0FFh)
             db 3 dup(0FFh),06h,2 dup(0Eh),3 dup(06h),3 dup(0FFh)
             db 2 dup(0FFh),06h,2 dup(0Eh),5 dup(06h),2 dup(0FFh)
             db 0FFh,06h,2 dup(0Eh),7 dup(06h),0FFh
             db 06h,2 dup(0Eh),9 dup(06h)
             db 06h,0Eh,10 dup(06h)
             db 0FFh,10 dup(06h),0FFh
             db 2 dup(0FFh),8 dup(06h),2 dup(0FFh)
             db 3 dup(0FFh),6 dup(06h),3 dup(0FFh)
bitmapRocha2Fim label byte
; Rocha 3 - 12 x 10
bitmapRocha3 db 2 dup(0FFh),03h,6 dup(0FFh),03h,2 dup(0FFh)
             db 2 dup(0FFh),0Bh,03h,4 dup(0FFh),0Bh,03h,2 dup(0FFh)
             db 0FFh,2 dup(0Bh),2 dup(03h),2 dup(0FFh),2 dup(0Bh),2 dup(03h),0FFh
             db 0FFh,2 dup(0Bh),2 dup(03h),0FFh,3 dup(0Bh),2 dup(03h),0FFh
             db 3 dup(0Bh),2 dup(03h),0FFh,2 dup(0Bh),3 dup(03h),0FFh
             db 2 dup(0Bh),3 dup(03h),3 dup(0Bh),3 dup(03h),0FFh
             db 2 dup(0Bh),3 dup(03h),2 dup(0Bh),5 dup(03h)
             db 0Bh,4 dup(03h),0Bh,6 dup(03h)
             db 12 dup(03h)
             db 12 dup(03h)
bitmapRocha3Fim label byte
; Rocha 4 - 12 x 10
bitmapRocha4 db 3 dup(0FFh),6 dup(04h),3 dup(0FFh)
             db 2 dup(0FFh),04h,2 dup(0Ch),5 dup(04h),2 dup(0FFh)
             db 0FFh,04h,2 dup(0Ch),7 dup(04h),0FFh
             db 0FFh,04h,0Ch,3 dup(04h),0Ch,4 dup(04h),0FFh
             db 04h,2 dup(0Ch),2 dup(04h),0Ch,6 dup(04h)
             db 04h,0Ch,3 dup(04h),2 dup(0Ch),5 dup(04h)
             db 6 dup(04h),0Ch,5 dup(04h)
             db 5 dup(04h),0Ch,6 dup(04h)
             db 0FFh,4 dup(04h),2 dup(0Ch),4 dup(04h),0FFh
             db 2 dup(0FFh),8 dup(04h),2 dup(0FFh)
bitmapRocha4Fim label byte
bitmapsFim label byte
; Montanhas - 320 x 64
bitmapMontanhas db 151 dup(0FFh),03h,168 dup(0FFh)
                db 150 dup(0FFh),3 dup(03h),167 dup(0FFh)
                db 149 dup(0FFh),5 dup(03h),166 dup(0FFh)
                db 149 dup(0FFh),6 dup(03h),165 dup(0FFh)
                db 148 dup(0FFh),2 dup(03h),01h,5 dup(03h),164 dup(0FFh)
                db 43 dup(0FFh),03h,103 dup(0FFh),2 dup(03h),2 dup(01h),6 dup(03h),163 dup(0FFh)
                db 42 dup(0FFh),3 dup(03h),101 dup(0FFh),3 dup(03h),2 dup(01h),7 dup(03h),162 dup(0FFh)
                db 41 dup(0FFh),5 dup(03h),100 dup(0FFh),2 dup(03h),3 dup(01h),8 dup(03h),161 dup(0FFh)
                db 40 dup(0FFh),7 dup(03h),98 dup(0FFh),2 dup(03h),4 dup(01h),9 dup(03h),160 dup(0FFh)
                db 40 dup(0FFh),2 dup(03h),01h,5 dup(03h),96 dup(0FFh),2 dup(03h),5 dup(01h),10 dup(03h),107 dup(0FFh),2 dup(03h),50 dup(0FFh)
                db 39 dup(0FFh),2 dup(03h),2 dup(01h),6 dup(03h),95 dup(0FFh),2 dup(03h),5 dup(01h),10 dup(03h),106 dup(0FFh),4 dup(03h),49 dup(0FFh)
                db 38 dup(0FFh),2 dup(03h),3 dup(01h),6 dup(03h),94 dup(0FFh),2 dup(03h),6 dup(01h),11 dup(03h),104 dup(0FFh),6 dup(03h),48 dup(0FFh)
                db 37 dup(0FFh),3 dup(03h),3 dup(01h),7 dup(03h),92 dup(0FFh),2 dup(03h),7 dup(01h),12 dup(03h),102 dup(0FFh),8 dup(03h),47 dup(0FFh)
                db 37 dup(0FFh),2 dup(03h),4 dup(01h),8 dup(03h),90 dup(0FFh),3 dup(03h),7 dup(01h),13 dup(03h),100 dup(0FFh),3 dup(03h),01h,6 dup(03h),46 dup(0FFh)
                db 36 dup(0FFh),2 dup(03h),5 dup(01h),9 dup(03h),89 dup(0FFh),2 dup(03h),8 dup(01h),14 dup(03h),98 dup(0FFh),3 dup(03h),2 dup(01h),8 dup(03h),44 dup(0FFh)
                db 35 dup(0FFh),2 dup(03h),6 dup(01h),10 dup(03h),87 dup(0FFh),2 dup(03h),9 dup(01h),15 dup(03h),39 dup(0FFh),3 dup(03h),54 dup(0FFh),3 dup(03h),3 dup(01h),9 dup(03h),43 dup(0FFh)
                db 34 dup(0FFh),3 dup(03h),6 dup(01h),11 dup(03h),85 dup(0FFh),2 dup(03h),10 dup(01h),16 dup(03h),36 dup(0FFh),6 dup(03h),52 dup(0FFh),3 dup(03h),4 dup(01h),10 dup(03h),42 dup(0FFh)
                db 34 dup(0FFh),2 dup(03h),7 dup(01h),11 dup(03h),84 dup(0FFh),3 dup(03h),10 dup(01h),17 dup(03h),34 dup(0FFh),8 dup(03h),50 dup(0FFh),3 dup(03h),5 dup(01h),11 dup(03h),41 dup(0FFh)
                db 33 dup(0FFh),2 dup(03h),8 dup(01h),12 dup(03h),39 dup(0FFh),2 dup(03h),42 dup(0FFh),2 dup(03h),11 dup(01h),14 dup(03h),01h,3 dup(03h),31 dup(0FFh),5 dup(03h),01h,5 dup(03h),48 dup(0FFh),3 dup(03h),6 dup(01h),12 dup(03h),40 dup(0FFh)
                db 32 dup(0FFh),2 dup(03h),9 dup(01h),13 dup(03h),37 dup(0FFh),4 dup(03h),40 dup(0FFh),2 dup(03h),12 dup(01h),14 dup(03h),2 dup(01h),3 dup(03h),29 dup(0FFh),4 dup(03h),3 dup(01h),7 dup(03h),45 dup(0FFh),3 dup(03h),7 dup(01h),14 dup(03h),38 dup(0FFh)
                db 31 dup(0FFh),3 dup(03h),9 dup(01h),14 dup(03h),35 dup(0FFh),6 dup(03h),38 dup(0FFh),2 dup(03h),13 dup(01h),14 dup(03h),3 dup(01h),3 dup(03h),26 dup(0FFh),5 dup(03h),4 dup(01h),8 dup(03h),43 dup(0FFh),3 dup(03h),8 dup(01h),15 dup(03h),37 dup(0FFh)
                db 31 dup(0FFh),2 dup(03h),10 dup(01h),15 dup(03h),32 dup(0FFh),4 dup(03h),01h,4 dup(03h),37 dup(0FFh),2 dup(03h),13 dup(01h),14 dup(03h),4 dup(01h),2 dup(03h),25 dup(0FFh),4 dup(03h),6 dup(01h),9 dup(03h),41 dup(0FFh),3 dup(03h),9 dup(01h),16 dup(03h),36 dup(0FFh)
                db 30 dup(0FFh),3 dup(03h),10 dup(01h),16 dup(03h),30 dup(0FFh),4 dup(03h),2 dup(01h),5 dup(03h),35 dup(0FFh),2 dup(03h),14 dup(01h),14 dup(03h),5 dup(01h),2 dup(03h),22 dup(0FFh),5 dup(03h),7 dup(01h),10 dup(03h),39 dup(0FFh),3 dup(03h),10 dup(01h),12 dup(03h),2 dup(01h),3 dup(03h),35 dup(0FFh)
                db 29 dup(0FFh),4 dup(03h),10 dup(01h),13 dup(03h),01h,3 dup(03h),28 dup(0FFh),4 dup(03h),3 dup(01h),6 dup(03h),33 dup(0FFh),2 dup(03h),15 dup(01h),14 dup(03h),6 dup(01h),2 dup(03h),20 dup(0FFh),4 dup(03h),9 dup(01h),12 dup(03h),36 dup(0FFh),3 dup(03h),11 dup(01h),12 dup(03h),3 dup(01h),3 dup(03h),34 dup(0FFh)
                db 28 dup(0FFh),5 dup(03h),10 dup(01h),13 dup(03h),2 dup(01h),2 dup(03h),26 dup(0FFh),4 dup(03h),5 dup(01h),7 dup(03h),31 dup(0FFh),3 dup(03h),15 dup(01h),14 dup(03h),6 dup(01h),3 dup(03h),17 dup(0FFh),5 dup(03h),10 dup(01h),13 dup(03h),34 dup(0FFh),3 dup(03h),12 dup(01h),12 dup(03h),4 dup(01h),4 dup(03h),32 dup(0FFh)
                db 28 dup(0FFh),5 dup(03h),10 dup(01h),13 dup(03h),3 dup(01h),2 dup(03h),24 dup(0FFh),4 dup(03h),6 dup(01h),8 dup(03h),30 dup(0FFh),2 dup(03h),16 dup(01h),14 dup(03h),7 dup(01h),3 dup(03h),15 dup(0FFh),4 dup(03h),12 dup(01h),14 dup(03h),32 dup(0FFh),3 dup(03h),13 dup(01h),12 dup(03h),5 dup(01h),4 dup(03h),31 dup(0FFh)
                db 27 dup(0FFh),6 dup(03h),10 dup(01h),13 dup(03h),4 dup(01h),2 dup(03h),22 dup(0FFh),4 dup(03h),7 dup(01h),9 dup(03h),28 dup(0FFh),3 dup(03h),16 dup(01h),14 dup(03h),8 dup(01h),3 dup(03h),12 dup(0FFh),5 dup(03h),13 dup(01h),15 dup(03h),30 dup(0FFh),3 dup(03h),14 dup(01h),12 dup(03h),6 dup(01h),4 dup(03h),30 dup(0FFh)
                db 26 dup(0FFh),7 dup(03h),10 dup(01h),13 dup(03h),4 dup(01h),3 dup(03h),19 dup(0FFh),4 dup(03h),9 dup(01h),10 dup(03h),26 dup(0FFh),4 dup(03h),16 dup(01h),14 dup(03h),9 dup(01h),3 dup(03h),10 dup(0FFh),6 dup(03h),13 dup(01h),17 dup(03h),27 dup(0FFh),3 dup(03h),15 dup(01h),12 dup(03h),8 dup(01h),3 dup(03h),29 dup(0FFh)
                db 25 dup(0FFh),8 dup(03h),10 dup(01h),13 dup(03h),5 dup(01h),3 dup(03h),17 dup(0FFh),4 dup(03h),10 dup(01h),11 dup(03h),24 dup(0FFh),5 dup(03h),16 dup(01h),14 dup(03h),10 dup(01h),3 dup(03h),7 dup(0FFh),8 dup(03h),13 dup(01h),18 dup(03h),25 dup(0FFh),3 dup(03h),16 dup(01h),12 dup(03h),9 dup(01h),3 dup(03h),28 dup(0FFh)
                db 25 dup(0FFh),8 dup(03h),10 dup(01h),13 dup(03h),6 dup(01h),3 dup(03h),15 dup(0FFh),4 dup(03h),11 dup(01h),12 dup(03h),23 dup(0FFh),5 dup(03h),16 dup(01h),14 dup(03h),11 dup(01h),3 dup(03h),5 dup(0FFh),9 dup(03h),13 dup(01h),19 dup(03h),23 dup(0FFh),4 dup(03h),16 dup(01h),12 dup(03h),10 dup(01h),3 dup(03h),27 dup(0FFh)
                db 23 dup(0FFh),10 dup(03h),10 dup(01h),13 dup(03h),7 dup(01h),2 dup(03h),13 dup(0FFh),4 dup(03h),13 dup(01h),12 dup(03h),22 dup(0FFh),6 dup(03h),16 dup(01h),14 dup(03h),12 dup(01h),3 dup(03h),2 dup(0FFh),11 dup(03h),13 dup(01h),15 dup(03h),2 dup(01h),3 dup(03h),21 dup(0FFh),5 dup(03h),16 dup(01h),12 dup(03h),11 dup(01h),5 dup(03h),24 dup(0FFh)
                db 21 dup(0FFh),12 dup(03h),10 dup(01h),13 dup(03h),8 dup(01h),2 dup(03h),11 dup(0FFh),5 dup(03h),13 dup(01h),13 dup(03h),20 dup(0FFh),7 dup(03h),16 dup(01h),14 dup(03h),13 dup(01h),2 dup(03h),0FFh,12 dup(03h),13 dup(01h),15 dup(03h),3 dup(01h),4 dup(03h),18 dup(0FFh),6 dup(03h),16 dup(01h),12 dup(03h),12 dup(01h),6 dup(03h),22 dup(0FFh)
                db 19 dup(0FFh),14 dup(03h),10 dup(01h),13 dup(03h),9 dup(01h),2 dup(03h),9 dup(0FFh),6 dup(03h),13 dup(01h),14 dup(03h),19 dup(0FFh),7 dup(03h),16 dup(01h),14 dup(03h),14 dup(01h),14 dup(03h),13 dup(01h),15 dup(03h),4 dup(01h),4 dup(03h),16 dup(0FFh),7 dup(03h),16 dup(01h),12 dup(03h),13 dup(01h),7 dup(03h),20 dup(0FFh)
                db 17 dup(0FFh),6 dup(03h),01h,9 dup(03h),10 dup(01h),13 dup(03h),9 dup(01h),3 dup(03h),6 dup(0FFh),8 dup(03h),13 dup(01h),15 dup(03h),17 dup(0FFh),8 dup(03h),16 dup(01h),14 dup(03h),15 dup(01h),13 dup(03h),13 dup(01h),15 dup(03h),5 dup(01h),4 dup(03h),14 dup(0FFh),8 dup(03h),16 dup(01h),12 dup(03h),13 dup(01h),9 dup(03h),18 dup(0FFh)
                db 15 dup(0FFh),6 dup(03h),3 dup(01h),9 dup(03h),10 dup(01h),13 dup(03h),10 dup(01h),3 dup(03h),4 dup(0FFh),9 dup(03h),13 dup(01h),12 dup(03h),01h,3 dup(03h),15 dup(0FFh),9 dup(03h),16 dup(01h),14 dup(03h),15 dup(01h),13 dup(03h),13 dup(01h),15 dup(03h),7 dup(01h),3 dup(03h),12 dup(0FFh),9 dup(03h),16 dup(01h),12 dup(03h),13 dup(01h),11 dup(03h),16 dup(0FFh)
                db 13 dup(0FFh),6 dup(03h),5 dup(01h),9 dup(03h),10 dup(01h),13 dup(03h),11 dup(01h),3 dup(03h),2 dup(0FFh),10 dup(03h),13 dup(01h),12 dup(03h),2 dup(01h),3 dup(03h),13 dup(0FFh),10 dup(03h),16 dup(01h),14 dup(03h),15 dup(01h),13 dup(03h),13 dup(01h),15 dup(03h),8 dup(01h),4 dup(03h),9 dup(0FFh),10 dup(03h),16 dup(01h),12 dup(03h),13 dup(01h),13 dup(03h),14 dup(0FFh)
                db 11 dup(0FFh),6 dup(03h),7 dup(01h),9 dup(03h),10 dup(01h),13 dup(03h),12 dup(01h),2 dup(03h),0FFh,11 dup(03h),13 dup(01h),12 dup(03h),3 dup(01h),3 dup(03h),12 dup(0FFh),10 dup(03h),16 dup(01h),14 dup(03h),15 dup(01h),13 dup(03h),13 dup(01h),15 dup(03h),9 dup(01h),4 dup(03h),7 dup(0FFh),11 dup(03h),16 dup(01h),12 dup(03h),13 dup(01h),16 dup(03h),11 dup(0FFh)
                db 9 dup(0FFh),6 dup(03h),9 dup(01h),9 dup(03h),10 dup(01h),13 dup(03h),13 dup(01h),13 dup(03h),13 dup(01h),12 dup(03h),4 dup(01h),3 dup(03h),10 dup(0FFh),11 dup(03h),16 dup(01h),14 dup(03h),15 dup(01h),13 dup(03h),13 dup(01h),15 dup(03h),10 dup(01h),4 dup(03h),5 dup(0FFh),12 dup(03h),16 dup(01h),12 dup(03h),13 dup(01h),18 dup(03h),9 dup(0FFh)
                db 7 dup(0FFh),6 dup(03h),11 dup(01h),9 dup(03h),10 dup(01h),13 dup(03h),14 dup(01h),12 dup(03h),13 dup(01h),12 dup(03h),5 dup(01h),3 dup(03h),8 dup(0FFh),12 dup(03h),16 dup(01h),14 dup(03h),15 dup(01h),13 dup(03h),13 dup(01h),15 dup(03h),12 dup(01h),3 dup(03h),3 dup(0FFh),13 dup(03h),16 dup(01h),12 dup(03h),13 dup(01h),20 dup(03h),7 dup(0FFh)
                db 5 dup(0FFh),7 dup(03h),12 dup(01h),9 dup(03h),10 dup(01h),13 dup(03h),14 dup(01h),12 dup(03h),13 dup(01h),12 dup(03h),6 dup(01h),3 dup(03h),6 dup(0FFh),13 dup(03h),16 dup(01h),14 dup(03h),15 dup(01h),13 dup(03h),13 dup(01h),15 dup(03h),13 dup(01h),3 dup(03h),0FFh,14 dup(03h),16 dup(01h),12 dup(03h),13 dup(01h),13 dup(03h),3 dup(01h),6 dup(03h),5 dup(0FFh)
                db 3 dup(0FFh),9 dup(03h),12 dup(01h),9 dup(03h),10 dup(01h),13 dup(03h),14 dup(01h),12 dup(03h),13 dup(01h),12 dup(03h),7 dup(01h),3 dup(03h),5 dup(0FFh),13 dup(03h),16 dup(01h),14 dup(03h),15 dup(01h),13 dup(03h),13 dup(01h),15 dup(03h),14 dup(01h),17 dup(03h),16 dup(01h),12 dup(03h),13 dup(01h),13 dup(03h),5 dup(01h),6 dup(03h),3 dup(0FFh)
                db 0FFh,11 dup(03h),12 dup(01h),9 dup(03h),10 dup(01h),13 dup(03h),14 dup(01h),12 dup(03h),13 dup(01h),12 dup(03h),8 dup(01h),3 dup(03h),3 dup(0FFh),14 dup(03h),16 dup(01h),14 dup(03h),15 dup(01h),13 dup(03h),13 dup(01h),15 dup(03h),15 dup(01h),16 dup(03h),16 dup(01h),12 dup(03h),13 dup(01h),13 dup(03h),7 dup(01h),6 dup(03h),0FFh
                db 12 dup(03h),12 dup(01h),9 dup(03h),10 dup(01h),13 dup(03h),14 dup(01h),12 dup(03h),13 dup(01h),12 dup(03h),9 dup(01h),3 dup(03h),0FFh,15 dup(03h),16 dup(01h),14 dup(03h),15 dup(01h),13 dup(03h),13 dup(01h),15 dup(03h),16 dup(01h),15 dup(03h),16 dup(01h),12 dup(03h),13 dup(01h),13 dup(03h),9 dup(01h),5 dup(03h)
                db 12 dup(03h),12 dup(01h),9 dup(03h),10 dup(01h),13 dup(03h),14 dup(01h),12 dup(03h),13 dup(01h),12 dup(03h),10 dup(01h),2 dup(03h),0FFh,15 dup(03h),16 dup(01h),14 dup(03h),15 dup(01h),13 dup(03h),13 dup(01h),15 dup(03h),16 dup(01h),15 dup(03h),16 dup(01h),12 dup(03h),13 dup(01h),13 dup(03h),11 dup(01h),3 dup(03h)
                db 12 dup(03h),12 dup(01h),9 dup(03h),10 dup(01h),13 dup(03h),14 dup(01h),12 dup(03h),13 dup(01h),12 dup(03h),11 dup(01h),17 dup(03h),16 dup(01h),14 dup(03h),15 dup(01h),13 dup(03h),13 dup(01h),15 dup(03h),16 dup(01h),15 dup(03h),16 dup(01h),12 dup(03h),13 dup(01h),13 dup(03h),13 dup(01h),03h
                db 12 dup(03h),12 dup(01h),9 dup(03h),10 dup(01h),13 dup(03h),14 dup(01h),12 dup(03h),13 dup(01h),12 dup(03h),12 dup(01h),16 dup(03h),16 dup(01h),14 dup(03h),15 dup(01h),13 dup(03h),13 dup(01h),15 dup(03h),16 dup(01h),15 dup(03h),16 dup(01h),12 dup(03h),13 dup(01h),13 dup(03h),13 dup(01h),03h
                db 12 dup(03h),12 dup(01h),9 dup(03h),10 dup(01h),13 dup(03h),14 dup(01h),12 dup(03h),13 dup(01h),12 dup(03h),12 dup(01h),16 dup(03h),16 dup(01h),14 dup(03h),15 dup(01h),13 dup(03h),13 dup(01h),15 dup(03h),16 dup(01h),15 dup(03h),16 dup(01h),12 dup(03h),13 dup(01h),13 dup(03h),13 dup(01h),03h
                db 12 dup(03h),12 dup(01h),9 dup(03h),10 dup(01h),13 dup(03h),14 dup(01h),12 dup(03h),13 dup(01h),12 dup(03h),12 dup(01h),16 dup(03h),16 dup(01h),14 dup(03h),15 dup(01h),13 dup(03h),13 dup(01h),15 dup(03h),16 dup(01h),15 dup(03h),16 dup(01h),12 dup(03h),13 dup(01h),13 dup(03h),13 dup(01h),03h
                db 12 dup(03h),12 dup(01h),9 dup(03h),10 dup(01h),13 dup(03h),14 dup(01h),12 dup(03h),13 dup(01h),12 dup(03h),12 dup(01h),16 dup(03h),16 dup(01h),14 dup(03h),15 dup(01h),13 dup(03h),13 dup(01h),15 dup(03h),16 dup(01h),15 dup(03h),16 dup(01h),12 dup(03h),13 dup(01h),13 dup(03h),13 dup(01h),03h
                db 12 dup(03h),12 dup(01h),9 dup(03h),10 dup(01h),13 dup(03h),14 dup(01h),12 dup(03h),13 dup(01h),12 dup(03h),12 dup(01h),16 dup(03h),16 dup(01h),14 dup(03h),15 dup(01h),13 dup(03h),13 dup(01h),15 dup(03h),16 dup(01h),15 dup(03h),16 dup(01h),12 dup(03h),13 dup(01h),13 dup(03h),13 dup(01h),03h
                db 12 dup(03h),12 dup(01h),9 dup(03h),10 dup(01h),13 dup(03h),14 dup(01h),12 dup(03h),13 dup(01h),12 dup(03h),12 dup(01h),16 dup(03h),16 dup(01h),14 dup(03h),15 dup(01h),13 dup(03h),13 dup(01h),15 dup(03h),16 dup(01h),15 dup(03h),16 dup(01h),12 dup(03h),13 dup(01h),13 dup(03h),13 dup(01h),03h
                db 12 dup(03h),12 dup(01h),9 dup(03h),10 dup(01h),13 dup(03h),14 dup(01h),12 dup(03h),13 dup(01h),12 dup(03h),12 dup(01h),16 dup(03h),16 dup(01h),14 dup(03h),15 dup(01h),13 dup(03h),13 dup(01h),15 dup(03h),16 dup(01h),15 dup(03h),16 dup(01h),12 dup(03h),13 dup(01h),13 dup(03h),13 dup(01h),03h
                db 12 dup(03h),12 dup(01h),9 dup(03h),10 dup(01h),13 dup(03h),14 dup(01h),12 dup(03h),13 dup(01h),12 dup(03h),12 dup(01h),16 dup(03h),16 dup(01h),14 dup(03h),15 dup(01h),13 dup(03h),13 dup(01h),15 dup(03h),16 dup(01h),15 dup(03h),16 dup(01h),12 dup(03h),13 dup(01h),13 dup(03h),13 dup(01h),03h
                db 12 dup(03h),12 dup(01h),9 dup(03h),10 dup(01h),13 dup(03h),14 dup(01h),12 dup(03h),13 dup(01h),12 dup(03h),12 dup(01h),16 dup(03h),16 dup(01h),14 dup(03h),15 dup(01h),13 dup(03h),13 dup(01h),15 dup(03h),16 dup(01h),15 dup(03h),16 dup(01h),12 dup(03h),13 dup(01h),13 dup(03h),13 dup(01h),03h
                db 12 dup(03h),12 dup(01h),9 dup(03h),10 dup(01h),13 dup(03h),14 dup(01h),12 dup(03h),13 dup(01h),12 dup(03h),12 dup(01h),16 dup(03h),16 dup(01h),14 dup(03h),15 dup(01h),13 dup(03h),13 dup(01h),15 dup(03h),16 dup(01h),15 dup(03h),16 dup(01h),12 dup(03h),13 dup(01h),13 dup(03h),13 dup(01h),03h
                db 12 dup(03h),12 dup(01h),9 dup(03h),10 dup(01h),13 dup(03h),14 dup(01h),12 dup(03h),13 dup(01h),12 dup(03h),12 dup(01h),16 dup(03h),16 dup(01h),14 dup(03h),15 dup(01h),13 dup(03h),13 dup(01h),15 dup(03h),16 dup(01h),15 dup(03h),16 dup(01h),12 dup(03h),13 dup(01h),13 dup(03h),13 dup(01h),03h
                db 12 dup(03h),12 dup(01h),9 dup(03h),10 dup(01h),13 dup(03h),14 dup(01h),12 dup(03h),13 dup(01h),12 dup(03h),12 dup(01h),16 dup(03h),16 dup(01h),14 dup(03h),15 dup(01h),13 dup(03h),13 dup(01h),15 dup(03h),16 dup(01h),15 dup(03h),16 dup(01h),12 dup(03h),13 dup(01h),13 dup(03h),13 dup(01h),03h
                db 12 dup(03h),12 dup(01h),9 dup(03h),10 dup(01h),13 dup(03h),14 dup(01h),12 dup(03h),13 dup(01h),12 dup(03h),12 dup(01h),16 dup(03h),16 dup(01h),14 dup(03h),15 dup(01h),13 dup(03h),13 dup(01h),15 dup(03h),16 dup(01h),15 dup(03h),16 dup(01h),12 dup(03h),13 dup(01h),13 dup(03h),13 dup(01h),03h
                db 12 dup(03h),12 dup(01h),9 dup(03h),10 dup(01h),13 dup(03h),14 dup(01h),12 dup(03h),13 dup(01h),12 dup(03h),12 dup(01h),16 dup(03h),16 dup(01h),14 dup(03h),15 dup(01h),13 dup(03h),13 dup(01h),15 dup(03h),16 dup(01h),15 dup(03h),16 dup(01h),12 dup(03h),13 dup(01h),13 dup(03h),13 dup(01h),03h
                db 12 dup(03h),12 dup(01h),9 dup(03h),10 dup(01h),13 dup(03h),14 dup(01h),12 dup(03h),13 dup(01h),12 dup(03h),12 dup(01h),16 dup(03h),16 dup(01h),14 dup(03h),15 dup(01h),13 dup(03h),13 dup(01h),15 dup(03h),16 dup(01h),15 dup(03h),16 dup(01h),12 dup(03h),13 dup(01h),13 dup(03h),13 dup(01h),03h
                db 12 dup(03h),12 dup(01h),9 dup(03h),10 dup(01h),13 dup(03h),14 dup(01h),12 dup(03h),13 dup(01h),12 dup(03h),12 dup(01h),16 dup(03h),16 dup(01h),14 dup(03h),15 dup(01h),13 dup(03h),13 dup(01h),15 dup(03h),16 dup(01h),15 dup(03h),16 dup(01h),12 dup(03h),13 dup(01h),13 dup(03h),13 dup(01h),03h
                db 12 dup(03h),12 dup(01h),9 dup(03h),10 dup(01h),13 dup(03h),14 dup(01h),12 dup(03h),13 dup(01h),12 dup(03h),12 dup(01h),16 dup(03h),16 dup(01h),14 dup(03h),15 dup(01h),13 dup(03h),13 dup(01h),15 dup(03h),16 dup(01h),15 dup(03h),16 dup(01h),12 dup(03h),13 dup(01h),13 dup(03h),13 dup(01h),03h
                db 12 dup(03h),12 dup(01h),9 dup(03h),10 dup(01h),13 dup(03h),14 dup(01h),12 dup(03h),13 dup(01h),12 dup(03h),12 dup(01h),16 dup(03h),16 dup(01h),14 dup(03h),15 dup(01h),13 dup(03h),13 dup(01h),15 dup(03h),16 dup(01h),15 dup(03h),16 dup(01h),12 dup(03h),13 dup(01h),13 dup(03h),13 dup(01h),03h
                db 12 dup(03h),12 dup(01h),9 dup(03h),10 dup(01h),13 dup(03h),14 dup(01h),12 dup(03h),13 dup(01h),12 dup(03h),12 dup(01h),16 dup(03h),16 dup(01h),14 dup(03h),15 dup(01h),13 dup(03h),13 dup(01h),15 dup(03h),16 dup(01h),15 dup(03h),16 dup(01h),12 dup(03h),13 dup(01h),13 dup(03h),13 dup(01h),03h
bitmapMontanhasFim label byte
; Montes - 320 x 32
bitmapMontes db 174 dup(0FFh),5 dup(0Ah),141 dup(0FFh)
             db 172 dup(0FFh),9 dup(0Ah),139 dup(0FFh)
             db 170 dup(0FFh),13 dup(0Ah),137 dup(0FFh)
             db 168 dup(0FFh),6 dup(0Ah),2 dup(02h),9 dup(0Ah),135 dup(0FFh)
             db 54 dup(0FFh),5 dup(0Ah),106 dup(0FFh),7 dup(0Ah),4 dup(02h),12 dup(0Ah),132 dup(0FFh)
             db 52 dup(0FFh),10 dup(0Ah),101 dup(0FFh),7 dup(0Ah),6 dup(02h),14 dup(0Ah),130 dup(0FFh)
             db 49 dup(0FFh),16 dup(0Ah),96 dup(0FFh),7 dup(0Ah),8 dup(02h),16 dup(0Ah),128 dup(0FFh)
             db 47 dup(0FFh),7 dup(0Ah),2 dup(02h),12 dup(0Ah),91 dup(0FFh),6 dup(0Ah),11 dup(02h),18 dup(0Ah),126 dup(0FFh)
             db 45 dup(0FFh),7 dup(0Ah),4 dup(02h),15 dup(0Ah),85 dup(0FFh),7 dup(0Ah),13 dup(02h),21 dup(0Ah),123 dup(0FFh)
             db 42 dup(0FFh),7 dup(0Ah),7 dup(02h),18 dup(0Ah),80 dup(0FFh),8 dup(0Ah),14 dup(02h),14 dup(0Ah),2 dup(02h),7 dup(0Ah),69 dup(0FFh),5 dup(0Ah),47 dup(0FFh)
             db 40 dup(0FFh),7 dup(0Ah),9 dup(02h),21 dup(0Ah),75 dup(0FFh),10 dup(0Ah),14 dup(02h),14 dup(0Ah),4 dup(02h),7 dup(0Ah),65 dup(0FFh),11 dup(0Ah),43 dup(0FFh)
             db 37 dup(0FFh),8 dup(0Ah),11 dup(02h),24 dup(0Ah),70 dup(0FFh),12 dup(0Ah),14 dup(02h),14 dup(0Ah),7 dup(02h),6 dup(0Ah),61 dup(0FFh),17 dup(0Ah),39 dup(0FFh)
             db 35 dup(0FFh),7 dup(0Ah),14 dup(02h),16 dup(0Ah),2 dup(02h),9 dup(0Ah),64 dup(0FFh),15 dup(0Ah),14 dup(02h),14 dup(0Ah),9 dup(02h),6 dup(0Ah),57 dup(0FFh),6 dup(0Ah),02h,15 dup(0Ah),36 dup(0FFh)
             db 33 dup(0FFh),7 dup(0Ah),16 dup(02h),16 dup(0Ah),5 dup(02h),9 dup(0Ah),59 dup(0FFh),17 dup(0Ah),14 dup(02h),14 dup(0Ah),11 dup(02h),8 dup(0Ah),51 dup(0FFh),6 dup(0Ah),3 dup(02h),19 dup(0Ah),32 dup(0FFh)
             db 30 dup(0FFh),10 dup(0Ah),16 dup(02h),16 dup(0Ah),8 dup(02h),9 dup(0Ah),53 dup(0FFh),20 dup(0Ah),14 dup(02h),14 dup(0Ah),13 dup(02h),9 dup(0Ah),46 dup(0FFh),6 dup(0Ah),5 dup(02h),23 dup(0Ah),28 dup(0FFh)
             db 28 dup(0FFh),12 dup(0Ah),16 dup(02h),16 dup(0Ah),11 dup(02h),9 dup(0Ah),48 dup(0FFh),7 dup(0Ah),2 dup(02h),13 dup(0Ah),14 dup(02h),14 dup(0Ah),15 dup(02h),10 dup(0Ah),41 dup(0FFh),6 dup(0Ah),7 dup(02h),13 dup(0Ah),2 dup(02h),11 dup(0Ah),25 dup(0FFh)
             db 26 dup(0FFh),14 dup(0Ah),16 dup(02h),16 dup(0Ah),14 dup(02h),8 dup(0Ah),44 dup(0FFh),7 dup(0Ah),4 dup(02h),13 dup(0Ah),14 dup(02h),14 dup(0Ah),15 dup(02h),13 dup(0Ah),36 dup(0FFh),6 dup(0Ah),9 dup(02h),13 dup(0Ah),6 dup(02h),11 dup(0Ah),21 dup(0FFh)
             db 21 dup(0FFh),19 dup(0Ah),16 dup(02h),16 dup(0Ah),17 dup(02h),8 dup(0Ah),38 dup(0FFh),7 dup(0Ah),7 dup(02h),13 dup(0Ah),14 dup(02h),14 dup(0Ah),15 dup(02h),16 dup(0Ah),31 dup(0FFh),6 dup(0Ah),11 dup(02h),13 dup(0Ah),10 dup(02h),10 dup(0Ah),18 dup(0FFh)
             db 17 dup(0FFh),23 dup(0Ah),16 dup(02h),16 dup(0Ah),17 dup(02h),10 dup(0Ah),34 dup(0FFh),7 dup(0Ah),9 dup(02h),13 dup(0Ah),14 dup(02h),14 dup(0Ah),15 dup(02h),20 dup(0Ah),25 dup(0FFh),6 dup(0Ah),13 dup(02h),13 dup(0Ah),13 dup(02h),11 dup(0Ah),14 dup(0FFh)
             db 13 dup(0FFh),27 dup(0Ah),16 dup(02h),16 dup(0Ah),17 dup(02h),13 dup(0Ah),29 dup(0FFh),7 dup(0Ah),11 dup(02h),13 dup(0Ah),14 dup(02h),14 dup(0Ah),15 dup(02h),23 dup(0Ah),20 dup(0FFh),6 dup(0Ah),15 dup(02h),13 dup(0Ah),13 dup(02h),14 dup(0Ah),11 dup(0FFh)
             db 9 dup(0FFh),12 dup(0Ah),4 dup(02h),15 dup(0Ah),16 dup(02h),16 dup(0Ah),17 dup(02h),15 dup(0Ah),24 dup(0FFh),7 dup(0Ah),14 dup(02h),13 dup(0Ah),14 dup(02h),14 dup(0Ah),15 dup(02h),26 dup(0Ah),15 dup(0FFh),8 dup(0Ah),15 dup(02h),13 dup(0Ah),13 dup(02h),18 dup(0Ah),7 dup(0FFh)
             db 5 dup(0FFh),12 dup(0Ah),8 dup(02h),15 dup(0Ah),16 dup(02h),16 dup(0Ah),17 dup(02h),18 dup(0Ah),19 dup(0FFh),7 dup(0Ah),16 dup(02h),13 dup(0Ah),14 dup(02h),14 dup(0Ah),15 dup(02h),17 dup(0Ah),3 dup(02h),9 dup(0Ah),10 dup(0FFh),10 dup(0Ah),15 dup(02h),13 dup(0Ah),13 dup(02h),21 dup(0Ah),4 dup(0FFh)
             db 0FFh,12 dup(0Ah),12 dup(02h),15 dup(0Ah),16 dup(02h),16 dup(0Ah),17 dup(02h),20 dup(0Ah),15 dup(0FFh),8 dup(0Ah),17 dup(02h),13 dup(0Ah),14 dup(02h),14 dup(0Ah),15 dup(02h),17 dup(0Ah),6 dup(02h),9 dup(0Ah),5 dup(0FFh),12 dup(0Ah),15 dup(02h),13 dup(0Ah),13 dup(02h),12 dup(0Ah),2 dup(02h),10 dup(0Ah),0FFh
             db 12 dup(0Ah),13 dup(02h),15 dup(0Ah),16 dup(02h),16 dup(0Ah),17 dup(02h),13 dup(0Ah),2 dup(02h),8 dup(0Ah),9 dup(0FFh),11 dup(0Ah),17 dup(02h),13 dup(0Ah),14 dup(02h),14 dup(0Ah),15 dup(02h),17 dup(0Ah),9 dup(02h),9 dup(0Ah),0FFh,13 dup(0Ah),15 dup(02h),13 dup(0Ah),13 dup(02h),12 dup(0Ah),6 dup(02h),7 dup(0Ah)
             db 12 dup(0Ah),13 dup(02h),15 dup(0Ah),16 dup(02h),16 dup(0Ah),17 dup(02h),13 dup(0Ah),5 dup(02h),7 dup(0Ah),5 dup(0FFh),13 dup(0Ah),17 dup(02h),13 dup(0Ah),14 dup(02h),14 dup(0Ah),15 dup(02h),17 dup(0Ah),12 dup(02h),20 dup(0Ah),15 dup(02h),13 dup(0Ah),13 dup(02h),12 dup(0Ah),9 dup(02h),4 dup(0Ah)
             db 12 dup(0Ah),13 dup(02h),15 dup(0Ah),16 dup(02h),16 dup(0Ah),17 dup(02h),13 dup(0Ah),7 dup(02h),7 dup(0Ah),0FFh,15 dup(0Ah),17 dup(02h),13 dup(0Ah),14 dup(02h),14 dup(0Ah),15 dup(02h),17 dup(0Ah),15 dup(02h),17 dup(0Ah),15 dup(02h),13 dup(0Ah),13 dup(02h),12 dup(0Ah),12 dup(02h),0Ah
             db 12 dup(0Ah),13 dup(02h),15 dup(0Ah),16 dup(02h),16 dup(0Ah),17 dup(02h),13 dup(0Ah),10 dup(02h),20 dup(0Ah),17 dup(02h),13 dup(0Ah),14 dup(02h),14 dup(0Ah),15 dup(02h),17 dup(0Ah),18 dup(02h),14 dup(0Ah),15 dup(02h),13 dup(0Ah),13 dup(02h),12 dup(0Ah),12 dup(02h),0Ah
             db 12 dup(0Ah),13 dup(02h),15 dup(0Ah),16 dup(02h),16 dup(0Ah),17 dup(02h),13 dup(0Ah),12 dup(02h),18 dup(0Ah),17 dup(02h),13 dup(0Ah),14 dup(02h),14 dup(0Ah),15 dup(02h),17 dup(0Ah),18 dup(02h),14 dup(0Ah),15 dup(02h),13 dup(0Ah),13 dup(02h),12 dup(0Ah),12 dup(02h),0Ah
             db 12 dup(0Ah),13 dup(02h),15 dup(0Ah),16 dup(02h),16 dup(0Ah),17 dup(02h),13 dup(0Ah),14 dup(02h),16 dup(0Ah),17 dup(02h),13 dup(0Ah),14 dup(02h),14 dup(0Ah),15 dup(02h),17 dup(0Ah),18 dup(02h),14 dup(0Ah),15 dup(02h),13 dup(0Ah),13 dup(02h),12 dup(0Ah),12 dup(02h),0Ah
             db 12 dup(0Ah),13 dup(02h),15 dup(0Ah),16 dup(02h),16 dup(0Ah),17 dup(02h),13 dup(0Ah),14 dup(02h),16 dup(0Ah),17 dup(02h),13 dup(0Ah),14 dup(02h),14 dup(0Ah),15 dup(02h),17 dup(0Ah),18 dup(02h),14 dup(0Ah),15 dup(02h),13 dup(0Ah),13 dup(02h),12 dup(0Ah),12 dup(02h),0Ah
             db 12 dup(0Ah),13 dup(02h),15 dup(0Ah),16 dup(02h),16 dup(0Ah),17 dup(02h),13 dup(0Ah),14 dup(02h),16 dup(0Ah),17 dup(02h),13 dup(0Ah),14 dup(02h),14 dup(0Ah),15 dup(02h),17 dup(0Ah),18 dup(02h),14 dup(0Ah),15 dup(02h),13 dup(0Ah),13 dup(02h),12 dup(0Ah),12 dup(02h),0Ah
             db 12 dup(0Ah),13 dup(02h),15 dup(0Ah),16 dup(02h),16 dup(0Ah),17 dup(02h),13 dup(0Ah),14 dup(02h),16 dup(0Ah),17 dup(02h),13 dup(0Ah),14 dup(02h),14 dup(0Ah),15 dup(02h),17 dup(0Ah),18 dup(02h),14 dup(0Ah),15 dup(02h),13 dup(0Ah),13 dup(02h),12 dup(0Ah),12 dup(02h),0Ah
bitmapMontesFim label byte
; ARTES_FIM

; TAAG: Mini / Moon Patrol
arteTitulo db '                     _                 '
           db ' |\/|  _   _  ._    |_) _. _|_ ._ _  | '
           db ' |  | (_) (_) | |   |  (_|  |_ | (_) | '
           db '                                       '
TITULO_LARG equ 39
TITULO_ALT equ 4
; TAAG: Small / GAME
arteGame db '   ___   _   __  __ ___ '
           db '  / __| /_\ |  \/  | __|'
           db ' | (_ |/ _ \| |\/| | _| '
           db '  \___/_/ \_\_|  |_|___|'
           db '                        '
GAME_LARG equ 24
GAME_ALT equ 5
; TAAG: Small / OVER
arteOver db '   _____   _____ ___ '
           db '  / _ \ \ / / __| _ \'
           db ' | (_) \ V /| _||   /'
           db '  \___/ \_/ |___|_|_\'
           db '                     '
OVER_LARG equ 21
OVER_ALT equ 5

caixaJogar db 218,9 dup(196),191
           db 179,'  Jogar  ',179
           db 192,9 dup(196),217
caixaSair  db 218,9 dup(196),191
           db 179,'  Sair   ',179
           db 192,9 dup(196),217
avisoArtes db 'E04 - ARTES AUTORAIS'
AVISO_TAM equ $-avisoArtes
ajudaMenu db 'Setas: selecionar   Enter: confirmar'
AJUDA_TAM equ $-ajudaMenu
textoSetor db 'SETOR 1'
SETOR_TAM equ $-textoSetor
textoDemo db 'E04: JIPE E SALTO - SEM OBSTACULOS'
DEMO_TAM equ $-textoDemo
textoAvanco db 'Enter: iniciar   Setas: mover/saltar'
AVANCO_TAM equ $-textoAvanco
textoRetorno db 'Qualquer tecla: voltar ao menu'
RETORNO_TAM equ $-textoRetorno
textoScore db 'SCORE: '
digitosScore db SCORE_DIGITOS dup('0')
SCORE_TAM equ $-textoScore

ultimoControle dw 65535
capturasJipe db 0
nomeJipe db 'E04J0.RAW',0
nomePos db 'E04POS.BIN',0
posCapturas dw 16 dup(0)
nomeMeta db 16 dup(0)
metaPos dw 4 dup(0)
faseAuto db 0
quadrosAuto dw 0
voltasAuto dw 0
inicioRealLo dw 0
inicioRealHi dw 0
fimRealLo dw 0
fimRealHi dw 0
tempoVisto dw 0
ultimoDump dw 65535
registro dw 0,0,0,0,0,0
nomeInicial db 'E04INI.RAW',0
nomeEmenda db 'E04EMEN.RAW',0
nomeVolta db 'E04VOLTA.RAW',0
nomeDois db 'E04DOIS.RAW',0
nomeFim db 'E04FIM.RAW',0
nomeVidas2 db 'E04VID2.RAW',0
nomeVidas1 db 'E04VID1.RAW',0
nomeVidas0 db 'E04VID0.RAW',0
nomeTempo db 'E04TEMPO.BIN',0
nomeInicioHost db 'E04HOST.BIN',0
autoOk db 'PASS AUTO: fluxo real; segundos; expiracao; score; reset; Sair.',13,10,'$'
autoErro db 'FAIL AUTO fase='
autoFaseErro db '?',13,10,'$'
.code
jumps
; Funcao: iniciar video, executar telas e devolver controle ao DOS.
; Entrada: nenhuma. Saida: codigo DOS 0, modo/pagina anteriores restaurados.
; Altera: registradores, segmentos e video. Partida restrita ao escopo E04.
inicio proc
    mov ax,@data
    mov ds,ax
    mov ah,0Fh
    int 10h
    mov modoAnterior,al
    mov paginaAnterior,bh
    mov ax,VIDEO_MODO
    int 10h
    mov ax,VIDEO_SEG
    mov es,ax
    cld
    call EntrarMenu
ciclo:
    call DirigirE04
    call LerTeclado
    cmp estado,ESTADO_SAIR
    je sair
    cmp estado,ESTADO_MENU
    jne cicloPartida
    call AtualizarAnimacao
    jmp ciclo
cicloPartida:
    cmp estado,ESTADO_PARTIDA
    jne ciclo
    call AtualizarPartida
    jmp ciclo
sair:
    call RestaurarTecladoJogo
    xor ah,ah
    mov al,modoAnterior
    int 10h
    mov ah,05h
    mov al,paginaAnterior
    int 10h
    lea dx,autoOk
    mov ah,09h
    int 21h
    mov ax,4C00h
    int 21h
inicio endp

; Funcao: limpar os pixels por memoria, sem mudar o modo de video.
; Entrada: ES=video. Saida: 64000 bytes pretos. Altera: AX,CX,DI,flags.
LimparTela proc near
    cld
    xor di,di
    mov al,COR_FUNDO
    mov cx,TELA_BYTES
    rep stosb
    ret
LimparTela endp

; Funcao: imprimir texto BIOS, preservando ES de video para os bitmaps.
; Entrada: DS:SI=texto, CX=tamanho, DH=linha, DL=coluna, BL=cor.
; Saida: texto na pagina 0. Preserva: todos os registradores. Altera: flags.
EscreverTexto proc near
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp
    push es
    push ds
    pop es
    mov bp,si
    xor bh,bh
    mov ax,1300h
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
EscreverTexto endp

; Funcao: imprimir bloco ASCII retangular (titulo, GAME/OVER ou caixa).
; Entrada: como EscreverTexto, BP=numero de linhas, CX=largura fixa.
; Saida: bloco no video. Preserva: registradores. Altera: flags.
MostrarArte proc near
    push si
    push dx
    push bp
arteLinha:
    call EscreverTexto
    add si,cx
    inc dh
    dec bp
    jnz arteLinha
    pop bp
    pop dx
    pop si
    ret
MostrarArte endp

; Funcao: descartar teclas antigas ao entrar em uma nova tela.
; Entrada: buffer BIOS. Saida: buffer vazio. Altera: AX,flags.
LimparTeclado proc near
limparTecla:
    mov ah,01h
    int 16h
    jz limparFim
    mov ah,00h
    int 16h
    jmp limparTecla
limparFim:
    ret
LimparTeclado endp

; Funcao: reiniciar menu, selecao, posicoes e relogio da animacao.
; Entrada: DS=dados, ES=video. Saida: estado MENU, Jogar selecionado.
; Altera: AX,BX,CX,DX,SI,DI,BP,flags, dados e video.
EntrarMenu proc near
    call LimparTeclado
    mov estado,ESTADO_MENU
    mov opcao,OPCAO_JOGAR
    mov scoreFinal,0
    xor di,di
menuReiniciar:
    mov ax,menuXInicial[di]
    mov menuX[di],ax
    add di,2
    cmp di,MENU_QUANT*2
    jb menuReiniciar
    call LimparTela
    lea si,arteTitulo
    mov cx,TITULO_LARG
    mov bp,TITULO_ALT
    mov dx,TITULO_LINHA*256+(TEXTO_COLUNAS-TITULO_LARG)/2
    mov bl,COR_TITULO
    call MostrarArte
    lea si,avisoArtes
    mov cx,AVISO_TAM
    mov dx,AVISO_LINHA*256+(TEXTO_COLUNAS-AVISO_TAM)/2
    mov bl,COR_AVISO
    call EscreverTexto
    lea si,ajudaMenu
    mov cx,AJUDA_TAM
    mov dx,AJUDA_LINHA*256+(TEXTO_COLUNAS-AJUDA_TAM)/2
    mov bl,COR_BRANCO
    call EscreverTexto
    call DesenharOpcoes
    call CapturarEDesenharMenu
    mov ah,00h
    int 1Ah
    mov ultimoTick,dx
    ret
EntrarMenu endp

; Funcao: redesenhar so as caixas, sem tocar na faixa da animacao.
; Entrada: opcao. Saida: selecionada 0Ch, outra 0Fh.
; Altera: BX,CX,DX,SI,BP,flags e video.
DesenharOpcoes proc near
    mov cx,CAIXA_LARG
    mov bp,CAIXA_ALT
    lea si,caixaJogar
    mov dx,CAIXA_JOGAR*256+CAIXA_COL
    mov bl,COR_BRANCO
    cmp opcao,OPCAO_JOGAR
    jne opcaoDesenharJogar
    mov bl,COR_SELECAO
opcaoDesenharJogar:
    call MostrarArte
    lea si,caixaSair
    mov dx,CAIXA_SAIR*256+CAIXA_COL
    mov bl,COR_BRANCO
    cmp opcao,OPCAO_SAIR
    jne opcaoDesenharSair
    mov bl,COR_SELECAO
opcaoDesenharSair:
    call MostrarArte
    ret
DesenharOpcoes endp

; Funcao: apresentar o unico setor, proposta tecnica D04 ainda provisoria.
; Entrada: nenhuma. Saida: estado SETOR e tela de demonstracao.
; Altera: AX,BX,CX,DX,SI,DI,flags, estado e video.
EntrarSetor proc near
    call LimparTeclado
    mov estado,ESTADO_SETOR
    call LimparTela
    lea si,textoSetor
    mov cx,SETOR_TAM
    mov dx,SETOR_LINHA*256+(TEXTO_COLUNAS-SETOR_TAM)/2
    mov bl,COR_TITULO
    call EscreverTexto
    call MostrarAvisoDemo
    lea si,textoAvanco
    mov cx,AVANCO_TAM
    mov dx,AVANCO_LINHA*256+(TEXTO_COLUNAS-AVANCO_TAM)/2
    mov bl,COR_BRANCO
    call EscreverTexto
    ret
EntrarSetor endp

; Funcao: identificar o escopo limitado da E04 enquanto demonstracao=1.
; Entrada: demonstracao. Saida: aviso na tela se habilitado.
; Altera: BX,CX,DX,SI,flags e video.
MostrarAvisoDemo proc near
    cmp demonstracao,0
    je avisoDemoFim
    lea si,textoDemo
    mov cx,DEMO_TAM
    mov dx,DEMO_LINHA*256+(TEXTO_COLUNAS-DEMO_TAM)/2
    mov bl,COR_AVISO
    call EscreverTexto
avisoDemoFim:
    ret
MostrarAvisoDemo endp

; Funcao: tela reutilizavel de encerramento; nao calcula regras da partida.
; Entrada: AX=score final sem sinal (0..65535), ES=video, DS=dados.
; Saida: estado FIM; GAME e OVER vermelhos, score decimal, buffer vazio.
; Altera: AX,BX,CX,DX,SI,DI,BP,flags, scoreFinal/digitosScore e video.
EntrarGameOver proc near
    call RestaurarTecladoJogo   ; preserva AX: score real recebido
    mov scoreFinal,ax
    call LimparTeclado
    call LimparTela
    mov estado,ESTADO_FIM
    lea si,arteGame
    mov cx,GAME_LARG
    mov bp,GAME_ALT
    mov dx,GAME_LINHA*256+(TEXTO_COLUNAS-GAME_LARG)/2
    mov bl,COR_GAMEOVER
    call MostrarArte
    lea si,arteOver
    mov cx,OVER_LARG
    mov bp,OVER_ALT
    mov dx,OVER_LINHA*256+(TEXTO_COLUNAS-OVER_LARG)/2
    call MostrarArte
    mov ax,scoreFinal
    call FormatarScore
    lea si,textoScore
    mov cx,SCORE_TAM
    mov dx,SCORE_LINHA*256+(TEXTO_COLUNAS-SCORE_TAM)/2
    mov bl,COR_BRANCO
    call EscreverTexto
    call MostrarAvisoDemo
    lea si,textoRetorno
    mov cx,RETORNO_TAM
    mov dx,AVANCO_LINHA*256+(TEXTO_COLUNAS-RETORNO_TAM)/2
    mov bl,COR_BRANCO
    call EscreverTexto
    ret
EntrarGameOver endp

; Funcao: converter numero para cinco algarismos, incluindo zeros iniciais.
; Entrada: AX=numero unsigned. Saida: digitosScore. Altera: AX,BX,CX,DX,DI,flags.
FormatarScore proc near
    mov cx,SCORE_DIGITOS
    lea di,digitosScore+SCORE_DIGITOS-1
    call FormatarNumero
    ret
FormatarScore endp

; Funcao: converter inteiro unsigned em campo decimal de largura fixa.
; Entrada: AX=valor, CX=digitos, DS:DI=ultimo caractere (campo suficiente).
; Saida: campo preenchido com zeros iniciais. Altera: AX,BX,CX,DX,DI,flags.
FormatarNumero proc near
    mov bx,10
scoreDigito:
    xor dx,dx
    div bx
    add dl,'0'
    mov [di],dl
    dec di
    loop scoreDigito
    ret
FormatarNumero endp

; Funcao: consultar e consumir no maximo uma tecla, sem bloquear a animacao.
; Entrada: estado, opcao e buffer BIOS. Saida: transicao ou selecao atualizada.
; Altera: AX,BX,CX,DX,SI,DI,BP,flags, dados e video pelas rotinas de tela.
LerTeclado proc near
    mov ah,01h
    int 16h
    jz tecladoFim
    mov ah,00h
    int 16h
    cmp estado,ESTADO_FIM
    jne tecladoNaoFim
    call EntrarMenu
    ret
tecladoNaoFim:
    cmp estado,ESTADO_SETOR
    jne tecladoMenu
    cmp al,TECLA_ENTER
    jne tecladoFim
    call EntrarPartida
    ret
tecladoMenu:
    cmp estado,ESTADO_MENU
    jne tecladoFim
    cmp ah,SCAN_CIMA
    je tecladoAlternar
    cmp ah,SCAN_BAIXO
    je tecladoAlternar
    cmp al,TECLA_ENTER
    jne tecladoFim
    cmp opcao,OPCAO_SAIR
    je tecladoSair
    call EntrarSetor
    ret
tecladoAlternar:
    xor opcao,1
    call DesenharOpcoes
    ret
tecladoSair:
    mov estado,ESTADO_SAIR
tecladoFim:
    ret
LerTeclado endp

; Funcao: mover somente quando decorrer o intervalo BIOS configurado.
; Entrada: ultimoTick, ES=video. Saida: posicoes/quadro atualizados se venceu.
; Altera: AX,BX,CX,DX,SI,DI,flags. Sem espera bloqueante ou cronometro de jogo.
AtualizarAnimacao proc near
    mov ah,00h
    int 1Ah
    mov ax,dx
    sub ax,ultimoTick
    cmp ax,TICKS_MOVIMENTO
    jb animacaoFim
    mov ultimoTick,dx
    call MoverSpritesMenu
animacaoFim:
    ret
AtualizarAnimacao endp

; Funcao: carregar parametros de um dos quatro objetos do menu.
; Entrada: DI=indice em bytes (0,2,4,6). Saida: AX=x,BX=y,CX=larg,DX=alt,
; DS:SI=bitmap. Preserva: DI,BP,ES. Nao valida indice (chamador controla).
CarregarSpriteMenu proc near
    mov ax,menuX[di]
    mov bx,menuY[di]
    mov cx,menuLarg[di]
    mov dx,menuAlt[di]
    mov si,menuBitmap[di]
    ret
CarregarSpriteMenu endp

; Funcao: salvar TODOS os fundos limpos e so depois desenhar os objetos.
; Entrada: tabelas do menu; ES=video sem sprites. Saida: buffers e video.
; Altera: AX,BX,CX,DX,SI,DI,flags. Preserva: BP,DS,ES.
CapturarEDesenharMenu proc near
    xor di,di
capturarMenu:
    call CarregarSpriteMenu
    mov si,menuFundo[di]
    call SalvarFundo
    add di,2
    cmp di,MENU_QUANT*2
    jb capturarMenu
    xor di,di
desenharMenu:
    call CarregarSpriteMenu
    call DesenharSprite
    add di,2
    cmp di,MENU_QUANT*2
    jb desenharMenu
    ret
CapturarEDesenharMenu endp

; Funcao: apagar TODOS os objetos usando fundos capturados antes do desenho.
; Entrada: posicoes anteriores e buffers, ES=video. Saida: fundo restaurado.
; Altera: AX,BX,CX,DX,SI,DI,flags. Preserva: BP,DS,ES.
ApagarSpritesMenu proc near
    xor di,di
apagarMenu:
    call CarregarSpriteMenu
    mov si,menuFundo[di]
    call DesenharBitmap          ; opaco: inclusive os pixels pretos do fundo
    add di,2
    cmp di,MENU_QUANT*2
    jb apagarMenu
    ret
ApagarSpritesMenu endp

; Funcao: restaurar, mover, capturar fundos e desenhar um quadro do menu.
; Entrada: tabelas/buffers, ES=video. Saida: x avanca; volta inteiro a x=0.
; Altera: AX,BX,CX,DX,SI,DI,flags. Fundo estatico obrigatorio entre quadros.
MoverSpritesMenu proc near
    call ApagarSpritesMenu
    xor di,di
moverMenu:
    mov ax,menuX[di]
    add ax,PASSO_MENU
    mov bx,TELA_LARG
    sub bx,menuLarg[di]
    cmp ax,bx
    jbe moverGuardar
    xor ax,ax                   ; sem recorte parcial nesta etapa
moverGuardar:
    mov menuX[di],ax
    add di,2
    cmp di,MENU_QUANT*2
    jb moverMenu
    call CapturarEDesenharMenu
    ret
MoverSpritesMenu endp

; Funcao: iniciar cenario/HUD, jipe no chao e uma duracao completa.
; Entrada: DS=dados, ES=video. Saida: estado PARTIDA, valores reiniciados.
; Altera: AX,BX,CX,DX,SI,DI,BP,flags, dados e video.
EntrarPartida proc near
    call LimparTeclado
    mov estado,ESTADO_PARTIDA
    mov scorePartida,0
    mov vidas,VIDAS_INICIAIS
    mov tempoRestante,DURACAO_SEGUNDOS
    mov fracaoSegundo,0
    mov margemInicial,MARGEM_RELOGIO
    mov rolagem,0
    call ReiniciarJipe
    call LimparTela
    call DesenharCenario
    call CapturarEDesenharJipe
    call DesenharStatus
    call InstalarTecladoJogo
    ; Comecar a contar depois de desenhar a primeira tela.
    call LerCentissegundos
    mov tempoAnteriorLo,ax
    mov tempoAnteriorHi,dx
    mov ah,00h
    int 1Ah
    mov tickCenario,dx
    mov tickJipe,dx
    ret
EntrarPartida endp

; Funcao: atualizar tempo a cada consulta e movimento em sua propria cadencia.
; Entrada: estado PARTIDA, relogios/dados, ES=video. Saida: quadro ou FIM.
; Altera: AX,BX,CX,DX,SI,DI,BP,flags, dados e video. Nunca espera por tecla.
AtualizarPartida proc near
    call AtualizarRelogio
    jnc partidaMovimento
    cmp tempoRestante,0
    je partidaExpirou
    call DesenharStatus
partidaMovimento:
    mov cenarioMudou,0
    mov jipeMudou,0
    mov ah,00h
    int 1Ah
    push dx                    ; mesma amostra para as duas cadencias
    mov ax,dx
    sub ax,tickCenario
    cmp ax,TICKS_CENARIO
    jb partidaJipe
    mov tickCenario,dx
    call AvancarCenario
    inc quadrosAuto
    cmp rolagem,0
    jne autoNaoVoltou
    inc voltasAuto
autoNaoVoltou:
    mov cenarioMudou,1
    mov ax,PASSO_CENARIO
    call ContarTopo             ; so conta se ja estava no topo
partidaJipe:
    pop dx
    mov ax,dx
    sub ax,tickJipe
    cmp ax,TICKS_JIPE
    jb partidaDesenhar
    mov tickJipe,dx
    call AtualizarJipe
partidaDesenhar:
    mov al,cenarioMudou
    or al,jipeMudou
    jz partidaFim
    call DesenharQuadroPartida
    call CapturarJipeTeste
partidaFim:
    ret
partidaExpirou:
    call RegistrarFim
    mov ax,scorePartida          ; valor real, nao o antigo SCORE_DEMO
    call EntrarGameOver
    ret
AtualizarPartida endp

; Funcao: restaurar somente os dados do jipe para uma nova partida.
; Entrada: nenhuma. Saida: posicao inicial, chao, sem teclas/pedido pendente.
; Altera: dados do jipe; preserva registradores. Nao reinicia score/relogio.
ReiniciarJipe proc near
    mov jipeX,JIPE_X_INICIAL
    mov jipeY,JIPE_Y_CHAO
    mov estadoSalto,SALTO_CHAO
    mov pixelsTopo,0
    mov teclasJipe,0
    mov pedidoSalto,0
    mov tickJipe,0
    mov cenarioMudou,0
    mov jipeMudou,0
    ret
ReiniciarJipe endp

; Funcao: registrar make/break das setas, inclusive teclas simultaneas.
; Entrada: AL=scan code set 1 (bit 7=soltou), DS=dados.
; Saida: teclasJipe; pedidoSalto somente numa nova pressao no chao.
; Altera: AX,flags e dados de entrada. Prefixos/outros scans sao ignorados.
RegistrarScanJipe proc near
    mov ah,al
    and al,7Fh
    cmp al,SCAN_ESQUERDA
    je scanEsquerda
    cmp al,SCAN_DIREITA
    je scanDireita
    cmp al,SCAN_CIMA
    jne scanFim
    test ah,80h
    jnz scanSoltarCima
    test teclasJipe,BIT_CIMA
    jnz scanFim                ; repeticao automatica nao e nova pressao
    or teclasJipe,BIT_CIMA
    cmp estadoSalto,SALTO_CHAO
    jne scanFim                ; pressao no ar nao fica guardada para pouso
    mov pedidoSalto,1
    ret
scanSoltarCima:
    and teclasJipe,0FFh-BIT_CIMA
    ret
scanEsquerda:
    mov al,BIT_ESQUERDA
    jmp scanLateral
scanDireita:
    mov al,BIT_DIREITA
scanLateral:
    test ah,80h
    jnz scanSoltarLateral
    or teclasJipe,al
    ret
scanSoltarLateral:
    not al
    and teclasJipe,al
scanFim:
    ret
RegistrarScanJipe endp

; Funcao: IRQ1 curta durante a partida: ler teclado, confirmar e registrar.
; Entrada: hardware porta 60h. Saida: teclas/pedido; IRET retoma interrompido.
; Preserva: registradores/flags. Nao chama DOS/BIOS, nao desenha nem move.
TecladoJogoIRQ proc far
    push ax
    push ds
    mov ax,@data
    mov ds,ax
    in al,60h
    push ax
    in al,61h
    mov ah,al
    or al,80h
    out 61h,al
    mov al,ah
    out 61h,al
    pop ax
    call RegistrarScanJipe
    mov al,20h
    out 20h,al                 ; fim de interrupcao no controlador (PIC)
    pop ds
    pop ax
    iret
TecladoJogoIRQ endp

; Funcao: guardar INT 09h BIOS e instalar leitura de pressao/soltura.
; Entrada: DS=dados, tecladoJogoAtivo=0. Saida: vetor ativo durante partida.
; Preserva: registradores. Altera: flags, vetor DOS e dados de controle.
InstalarTecladoJogo proc near
    cmp tecladoJogoAtivo,0
    jne instalarTecladoFim
    push ax
    push bx
    push dx
    push es
    mov ax,3509h
    int 21h
    mov vetorTeclado,bx
    mov vetorTeclado+2,es
    push ds
    push cs
    pop ds
    mov dx,offset TecladoJogoIRQ
    mov ax,2509h
    int 21h
    pop ds
    mov tecladoJogoAtivo,1
    pop es
    pop dx
    pop bx
    pop ax
instalarTecladoFim:
    ret
InstalarTecladoJogo endp

; Funcao: devolver INT 09h ao BIOS antes do Game Over/saida.
; Entrada: DS=dados, vetor guardado. Saida: teclado BIOS restaurado.
; Preserva: registradores (inclusive AX=score). Altera: flags/vetor/controle.
RestaurarTecladoJogo proc near
    cmp tecladoJogoAtivo,0
    je restaurarTecladoFim
    push ax
    push dx
    push ds
    mov dx,vetorTeclado
    mov ax,vetorTeclado+2
    mov tecladoJogoAtivo,0
    mov ds,ax
    mov ax,2509h
    int 21h
    pop ds
    mov teclasJipe,0
    mov pedidoSalto,0
    pop dx
    pop ax
restaurarTecladoFim:
    ret
RestaurarTecladoJogo endp

; Funcao: executar um frame do jipe, independente da repeticao do teclado.
; Entrada: teclas/pedido, posicao/fase. Saida: X/Y/fase e jipeMudou (0/1).
; Altera: AX,BX,flags e dados do jipe. Sem desenho, pontos ou perda de vida.
AtualizarJipe proc near
    mov jipeMudou,0
    pushf
    cli                        ; copia atomica; IRQ nao perde uma nova pressao
    mov bl,teclasJipe
    mov al,pedidoSalto
    mov pedidoSalto,0
    popf
    cmp al,0
    je jipeHorizontal
    cmp estadoSalto,SALTO_CHAO
    jne jipeHorizontal
    mov estadoSalto,SALTO_SUBINDO
    mov pixelsTopo,0
jipeHorizontal:
    and bl,BIT_ESQUERDA+BIT_DIREITA
    mov ax,jipeX
    cmp bl,BIT_ESQUERDA
    jne jipeDireita
    sub ax,PASSO_JIPE
    jnc jipeGuardarX
    xor ax,ax
    jmp jipeGuardarX
jipeDireita:
    cmp bl,BIT_DIREITA
    jne jipeVertical           ; nenhuma ou ambas: neutro
    add ax,PASSO_JIPE
    cmp ax,JIPE_X_MAX
    jbe jipeGuardarX
    mov ax,JIPE_X_MAX
jipeGuardarX:
    cmp ax,jipeX
    je jipeVertical
    mov jipeX,ax
    mov jipeMudou,1
jipeVertical:
    cmp estadoSalto,SALTO_SUBINDO
    jne jipeDescer
    sub jipeY,SALTO_PASSO
    mov jipeMudou,1
    cmp jipeY,JIPE_Y_CHAO-SALTO_ALTURA
    ja jipeFim
    mov jipeY,JIPE_Y_CHAO-SALTO_ALTURA
    mov estadoSalto,SALTO_TOPO
    ret
jipeDescer:
    cmp estadoSalto,SALTO_DESCENDO
    jne jipeFim
    add jipeY,SALTO_PASSO
    mov jipeMudou,1
    cmp jipeY,JIPE_Y_CHAO
    jb jipeFim
    mov jipeY,JIPE_Y_CHAO
    mov estadoSalto,SALTO_CHAO
jipeFim:
    ret
AtualizarJipe endp

; Funcao: D05, contar distancia do terreno depois de chegar ao topo.
; Entrada: AX=pixels efetivamente avancados; estadoSalto/pixelsTopo.
; Saida: contador satura em 5; muda para descida ao cruzar esse limiar.
; Preserva: registradores. Altera: flags/contador/fase; nao altera X/Y.
; Passos de 2 amostram 2,4,6: o 5o pixel fica entre dois quadros.
; Nao conta teclas, tempo nem frames; esquerda/parado/limites nao bloqueiam.
ContarTopo proc near
    cmp estadoSalto,SALTO_TOPO
    jne topoFim
    push ax
    add ax,pixelsTopo
    cmp ax,SALTO_TOPO_PX
    jb topoGuardar
    mov ax,SALTO_TOPO_PX
    mov estadoSalto,SALTO_DESCENDO
topoGuardar:
    mov pixelsTopo,ax
    pop ax
topoFim:
    ret
ContarTopo endp

; Funcao: capturar o fundo limpo atual e desenhar o jipe sempre 20x10.
; Entrada: jipeX/Y validos, ES=fundo sem jipe. Saida: buffer/posicao e sprite.
; Altera: AX,BX,CX,DX,SI,flags. Nao usa os buffers do menu.
CapturarEDesenharJipe proc near
    mov ax,jipeX
    mov bx,jipeY
    mov jipeDesenhoX,ax
    mov jipeDesenhoY,bx
    mov cx,JIPE_LARG
    mov dx,JIPE_ALT
    lea si,fundoPartida
    call SalvarFundo
    lea si,bitmapJipe
    call DesenharSprite
    ret
CapturarEDesenharJipe endp

; Funcao: apagar/redesenhar com ou sem rolagem sem restaurar fundo velho.
; Entrada: cenarioMudou, posicoes, ES=video. Saida: quadro/fundo atualizado.
; Altera: AX,BX,CX,DX,SI,DI,BP,flags e video (HUD/ceu preservados).
DesenharQuadroPartida proc near
    cmp cenarioMudou,0
    je quadroSoJipe
    call DesenharCenario        ; descarta captura anterior quando terreno muda
    jmp quadroJipe
quadroSoJipe:
    mov ax,jipeDesenhoX
    mov bx,jipeDesenhoY
    mov cx,JIPE_LARG
    mov dx,JIPE_ALT
    lea si,fundoPartida
    call DesenharBitmap
quadroJipe:
    call CapturarEDesenharJipe
    ret
DesenharQuadroPartida endp

; Funcao: obter hora DOS completa em centesimos, incluindo horas e minutos.
; Entrada: nenhuma. Saida: DX:AX=0..8639999. Altera: AX,DX,flags.
; Preserva: BX,CX,SI,DI,BP,DS,ES. Resolucao real depende do relogio DOS.
LerCentissegundos proc near
    push bx
    push cx
    push si
    mov ah,2Ch
    int 21h
    push dx                     ; guardar segundos e centesimos
    xor ax,ax
    mov al,ch
    mov bx,60
    mul bx
    xor ch,ch
    add ax,cx                   ; horas*60 + minutos
    mul bx
    pop cx                      ; CH=segundos, CL=centesimos
    xor bx,bx
    mov bl,ch
    add ax,bx
    adc dx,0                    ; segundos do dia podem ultrapassar 65535
    mov si,dx
    mov bx,CENT_POR_SEG
    mul bx
    ; Parte alta dos segundos vale 0 ou 1; multiplicar tambem por 100.
    or si,si
    jz lerFracao
    add dx,CENT_POR_SEG
lerFracao:
    xor ch,ch
    add ax,cx
    adc dx,0
    pop si
    pop cx
    pop bx
    ret
LerCentissegundos endp

; Funcao: descontar tempo real desde a ultima consulta, com virada de dia.
; Entrada: tempoAnteriorHi/Lo e relogio DOS; consulta em intervalo <24 horas.
; Saida: CF=1 se mudou tempoRestante, CF=0 caso contrario.
; Altera: AX,BX,CX,DX,flags e dados temporais. Preserva: SI,DI,BP,DS,ES.
AtualizarRelogio proc near
    call LerCentissegundos
    mov bx,ax
    mov cx,dx
    sub ax,tempoAnteriorLo
    sbb dx,tempoAnteriorHi
    mov tempoAnteriorLo,bx
    mov tempoAnteriorHi,cx
    jnc relogioDeltaPronto
    add ax,CENT_DIA_BAIXO
    adc dx,CENT_DIA_ALTO
relogioDeltaPronto:
    call ConsumirTempo
    ret
AtualizarRelogio endp

; Funcao: acumular fracoes e descontar somente grupos de 100 centesimos.
; Entrada: DX:AX=intervalo, margemInicial, fracaoSegundo e tempoRestante.
; Saida: CF=1 se mudou tempo; satura em zero, sem underflow.
; Altera: AX,BX,DX,flags, tempoRestante/fracaoSegundo/margemInicial.
ConsumirTempo proc near
    ; A primeira amostra pode cair no fim do quantum de ~55 ms do DOS.
    ; Consumir 6 centesimos antes da contagem cobre essa incerteza uma vez.
    or dx,dx
    jnz tempoRetirarMargem
    cmp ax,margemInicial
    jae tempoRetirarMargem
    sub margemInicial,ax
    clc
    ret
tempoRetirarMargem:
    sub ax,margemInicial
    sbb dx,0
    mov margemInicial,0
    add ax,fracaoSegundo
    adc dx,0
    mov bx,CENT_POR_SEG
    cmp dx,bx                   ; evitar overflow de DIV em pausas longas
    jae tempoEsgotou
    div bx                      ; AX=segundos inteiros; DX=resto 0..99
    mov fracaoSegundo,dx
    or ax,ax
    jz tempoSemMudanca
    cmp ax,tempoRestante
    jae tempoEsgotou
    sub tempoRestante,ax
    stc
    ret
tempoEsgotou:
    mov tempoRestante,0
    mov fracaoSegundo,0
    stc
    ret
tempoSemMudanca:
    clc
    ret
ConsumirTempo endp

; Funcao: avancar a origem circular, revelando novos pixels pela direita.
; Entrada: rolagem 0..319. Saida: rolagem=(rolagem+PASSO_CENARIO) mod 320.
; Altera: AX,flags e rolagem. Sem desenho nem alteracao do relogio.
AvancarCenario proc near
    mov ax,rolagem
    add ax,PASSO_CENARIO
    cmp ax,TELA_LARG
    jb cenarioGuardar
    sub ax,TELA_LARG
cenarioGuardar:
    mov rolagem,ax
    ret
AvancarCenario endp

; Funcao: compor uma linha de 320 pixels da arte com deslocamento circular.
; Entrada: DS:SI=linha de origem, rolagem=0..319; linhaCenario ja preenchida.
; Saida: linhaCenario sobreposta (FFh preserva, 00h opaco).
; Preserva: registradores. Altera: flags (DF=0) e buffer de 320 bytes.
ComporLinhaCircular proc near
    push ax
    push cx
    push si
    push di
    push bp
    cld
    mov bp,si
    add bp,TELA_LARG            ; fim exclusivo da linha de origem
    add si,rolagem
    lea di,linhaCenario
    mov cx,TELA_LARG
comporPixel:
    lodsb
    cmp al,TRANSPARENTE
    je comporTransparente
    mov [di],al
comporTransparente:
    inc di
    cmp si,bp
    jb comporProximo
    sub si,TELA_LARG            ; somente volta na origem, destino continua
comporProximo:
    loop comporPixel
    pop bp
    pop di
    pop si
    pop cx
    pop ax
    ret
ComporLinhaCircular endp

; Funcao: recompor terreno em memoria e copiar linhas prontas para o video.
; Entrada: rolagem, DS=dados, ES=video. Saida: y=100..192 e pista 193..199.
; Altera: AX,BX,CX,DX,SI,DI,BP,flags. HUD/ceu preservados; sem fundos velhos.
; D10: montanhas 100..163, montes 132..163, ultima linha estendida ate 192.
DesenharCenario proc near
    cld
    mov bp,CENARIO_Y
    mov di,CENARIO_Y*TELA_LARG
cenarioLinha:
    cmp bp,CENARIO_Y+MONTANHAS_ALT
    jae cenarioCopiar           ; base pronta: repetir ultima linha composta
    push di
    push es
    push ds
    pop es
    lea di,linhaCenario
    mov cx,TELA_LARG
    mov al,COR_FUNDO
    rep stosb                   ; limpar so o buffer, nunca piscar preto no video
    pop es
    pop di
    mov ax,bp
    sub ax,CENARIO_Y
    mov bx,TELA_LARG
    mul bx
    lea si,bitmapMontanhas
    add si,ax
    call ComporLinhaCircular
    cmp bp,MONTES_Y
    jb cenarioCopiar
    mov ax,bp
    sub ax,MONTES_Y
    mul bx
    lea si,bitmapMontes
    add si,ax
    call ComporLinhaCircular
cenarioCopiar:
    lea si,linhaCenario
    mov cx,TELA_LARG
    rep movsb                   ; linha final ja composta -> A000h
    inc bp
    cmp bp,PISTA_Y
    jb cenarioLinha
    mov al,COR_PISTA             ; pista por ultimo, sem relevo por cima
    mov cx,TELA_LARG*PISTA_ALT
    rep stosb
    ret
DesenharCenario endp

; Funcao: desenhar score esquerdo, vidas centrais e tempo direito (D01).
; Entrada: scorePartida, vidas=0..3, tempoRestante=0..999, ES=video.
; Saida: barra y=0..14, sem digitos/sprites antigos. Zero vidas limpa o icone.
; Altera: AX,BX,CX,DX,SI,DI,flags e buffers decimais; nao muda valores do jogo.
DesenharStatus proc near
    cld
    xor di,di
    mov cx,TELA_LARG*HUD_ALT
    mov al,COR_FUNDO
    rep stosb
    mov ax,scorePartida
    call FormatarScore
    lea si,textoScore
    mov cx,SCORE_TAM
    mov dx,HUD_SCORE_POS
    mov bl,COR_BRANCO
    call EscreverTexto
    cmp vidas,0
    je statusRelogio
    lea si,bitmapVidas3
    cmp vidas,3
    je statusVidas
    lea si,bitmapVidas2
    cmp vidas,2
    je statusVidas
    lea si,bitmapVidas1
statusVidas:
    mov ax,HUD_VIDAS_X
    mov bx,HUD_VIDAS_Y
    mov cx,VIDAS_LARG
    mov dx,VIDAS_ALT
    call DesenharSprite
statusRelogio:
    mov ax,HUD_RELOGIO_X
    mov bx,HUD_RELOGIO_Y
    mov cx,RELOGIO_LARG
    mov dx,RELOGIO_ALT
    lea si,bitmapRelogio
    call DesenharSprite
    mov ax,tempoRestante
    mov cx,TEMPO_DIGITOS
    lea di,digitosTempo+TEMPO_DIGITOS-1
    call FormatarNumero
    lea si,digitosTempo
    mov cx,TEMPO_DIGITOS
    mov dx,HUD_TEMPO_POS
    mov bl,COR_BRANCO
    call EscreverTexto
    ret
DesenharStatus endp

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

; Funcao: desenhar bitmap com transparencia FFh, sem recorte parcial.
; Entrada: como DesenharBitmap; DS:SI contem largura*altura bytes.
; Saida: FFh preserva fundo, 00h desenha preto; invalido nao escreve.
; Preserva: todos os registradores. Altera: flags (DF=0) e video.
DesenharSprite proc near
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp
    cld
    call PrepararRetangulo
    jc spriteFim
spriteLinha:
    push cx
spritePixel:
    lodsb
    cmp al,TRANSPARENTE
    je spriteTransparente
    mov es:[di],al
spriteTransparente:
    inc di
    loop spritePixel
    pop cx
    add di,bx
    dec bp
    jnz spriteLinha
spriteFim:
    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
DesenharSprite endp

; Harness do laco real: injeta teclas BIOS, nunca depende do foco Windows.
; Funcao: conferir fluxo, HUD, duas voltas (variante 45s), tempo e reinicio.
; Entrada: faseAuto/estado. Saida: capturas/teclas ou FAIL. Altera: registradores.
DirigirE04 proc near
    cmp faseAuto,0
    jne autoFase1
    mov cx,1C0Dh
    call TeclaE04
    call TeclaE04
    inc faseAuto
    ret
autoFase1:
    cmp faseAuto,1
    jne autoFase2
    cmp estado,ESTADO_SETOR
    jne autoFalha
    call BufferE04
    mov cx,1C0Dh
    call TeclaE04
    call TeclaE04
    inc faseAuto
    ret
autoFase2:
    cmp faseAuto,2
    jne autoFase3
    cmp estado,ESTADO_PARTIDA
    jne autoFalha
    call BufferE04
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
    call SalvarTelaE04
    mov vidas,2
    mov scorePartida,65535
    mov tempoRestante,100
    call DesenharStatus
    lea dx,nomeVidas2
    call SalvarTelaE04
    mov vidas,1
    mov scorePartida,9
    mov tempoRestante,99
    call DesenharStatus
    lea dx,nomeVidas1
    call SalvarTelaE04
    mov vidas,0
    mov scorePartida,0
    mov tempoRestante,0
    call DesenharStatus
    lea dx,nomeVidas0
    call SalvarTelaE04
    mov vidas,VIDAS_INICIAIS
    mov scorePartida,43210       ; dado de teste, nao pontuacao da E04 normal
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
    call ControlarJipeTeste
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
    call SalvarTelaE04
autoVolta1:
    cmp quadrosAuto,160
    jne autoVolta2
    lea dx,nomeVolta
    call SalvarTelaE04
autoVolta2:
    cmp quadrosAuto,320
    jne autoAguardar
    lea dx,nomeDois
    call SalvarTelaE04
autoAguardar:
    ret
autoExpirou:
    cmp tempoRestante,0
    jne autoFalha
    cmp tecladoJogoAtivo,0
    jne autoFalha
    call ConferirVetorTeste
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
    call SalvarTelaE04
    mov cx,1E61h
    call TeclaE04
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
    call TeclaE04
    call LerTeclado
    cmp estado,ESTADO_SETOR
    jne autoFalha
    mov cx,1C0Dh
    call TeclaE04
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
    call TeclaE04
    inc faseAuto
    ret
autoFase7:
    cmp estado,ESTADO_MENU
    jne autoFalha
    mov cx,5000h
    call TeclaE04
    call LerTeclado
    cmp opcao,OPCAO_SAIR
    jne autoFalha
    mov cx,1C0Dh
    call TeclaE04
    ret
DirigirE04 endp

; Funcao: validar nova sessao. Entrada: dados reais. Saida: retorna/FAIL.
ConferirReset proc near
    call ConferirJipeReset
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
BufferE04 proc near
    mov ah,01h
    int 16h
    jnz autoFalha
    ret
BufferE04 endp

; Funcao: inserir tecla. Entrada: CH=scan, CL=ASCII. Saida: tecla ou FAIL.
TeclaE04 proc near
    mov ah,05h
    int 16h
    cmp al,0
    jne autoFalha
    ret
TeclaE04 endp

; Funcao: exportar A000h real. Entrada: DS:DX=arquivo. Saida: RAW 64000 bytes.
SalvarTelaE04 proc near
    call SalvarMetaTeste
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
SalvarTelaE04 endp

autoFalha:
    call RestaurarTecladoJogo
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

end inicio
