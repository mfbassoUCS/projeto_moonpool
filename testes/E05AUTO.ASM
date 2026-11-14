; Moon Patrol - E05: obstaculos, colisoes, vidas e pontuacao.
; TASM 4.1 / TLINK, Turbo 16-bit. Fonte ASCII, instrucoes 8086.
; Menu -> SETOR 1 -> partida -> fim por tempo ou vidas. Sem naves/tiros.
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
DURACAO_SEGUNDOS equ 90           ; configuravel: 1..999
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

; E05: escolhas tecnicas D07/D14/D15; intervalos [inicio,fim).
OBST_MAX        equ 8            ; 4 pares cabem com folga na faixa de 320
OBST_LIVRE      equ 0FFFFh
CRATERA_TIPOS   equ 3            ; indices 0..2; rochas 3..6
ROCHA_TIPOS     equ 4
CRATERA_GAP_MIN equ 150          ; pixels LIVRES entre bordas, nao origens
CRATERA_GAP_VAR equ 80           ; gap sorteado 150..230 inclusivo
ROCHA_FOLGA     equ 60           ; minimo livre de cada lado da rocha
PONTOS_OBST     equ 50
SCORE_MAX       equ 65535        ; cinco digitos; nunca volta a zero
PASS_NOVO      equ 0
PASS_FRENTE    equ 1            ; visto inteiro a frente do jipe
PASS_SOBRE     equ 2            ; sobreposicao horizontal durante salto
PASS_CRUZOU    equ 3            ; saiu pela direita; aguarda pouso seguro
PASS_PONTO     equ 4            ; ja recebeu +50
PASS_INVALIDO  equ 5            ; matou ou travessia interrompida por morte

; Limite para nao atravessar um obstaculo inteiro entre amostras.
IF (PASSO_CENARIO+PASSO_JIPE GT ROCHA_LARG)
 .ERR
ENDIF
IF (CRATERA_GAP_MIN LT 2*ROCHA_FOLGA+ROCHA_LARG)
 .ERR
ENDIF

.data
modoAnterior    db 3
paginaAnterior  db 0
estado          db ESTADO_MENU
opcao           db OPCAO_JOGAR
demonstracao    db 1             ; aviso de escopo E05, ainda sem naves/tiros
ultimoTick      dw 0
scoreFinal      dw 0
scorePartida    dw 0             ; word unsigned; SomarPontos satura em SCORE_MAX
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
; Listas fixas: DI=0,2,..14 seleciona a mesma entrada em cada tabela.
obstX           dw OBST_MAX dup(0) ; signed: entrada/saida parcial
obstTipo        dw OBST_MAX dup(OBST_LIVRE)
obstPassagem    dw OBST_MAX dup(PASS_NOVO)
tipoLarg        dw 3 dup(CRATERA_LARG),4 dup(ROCHA_LARG)
tipoAlt         dw 3 dup(CRATERA_ALT),4 dup(ROCHA_ALT)
tipoY           dw 3 dup(PISTA_Y),4 dup(PISTA_Y-ROCHA_ALT)
tipoBitmap      dw offset bitmapCratera1,offset bitmapCratera2,offset bitmapCratera3
                dw offset bitmapRocha1,offset bitmapRocha2,offset bitmapRocha3,offset bitmapRocha4
semente         dw 1
proximoEm       dw 0              ; distancia ate o proximo nascimento
proximaRocha    db 0              ; sequencia cratera, rocha, cratera...
ateCratera      dw 0              ; restante do intervalo ja sorteado
jipeAtivo       db 1              ; zero: aguarda reposicao em area livre
jipeNaTela      db 0              ; existe captura valida a restaurar?
statusMudou     db 0
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
avisoArtes db 'E05 - ARTES AUTORAIS'
AVISO_TAM equ $-avisoArtes
ajudaMenu db 'Setas: selecionar   Enter: confirmar'
AJUDA_TAM equ $-ajudaMenu
textoSetor db 'SETOR 1'
SETOR_TAM equ $-textoSetor
textoDemo db 'E05: OBSTACULOS E VIDAS'
DEMO_TAM equ $-textoDemo
textoAvanco db 'Enter: iniciar   Setas: mover/saltar'
AVANCO_TAM equ $-textoAvanco
textoRetorno db 'Qualquer tecla: voltar ao menu'
RETORNO_TAM equ $-textoRetorno
textoScore db 'SCORE: '
digitosScore db SCORE_DIGITOS dup('0')
SCORE_TAM equ $-textoScore

faseAuto db 0
erroAuto db 'FAIL E05 AUTO fase=$'
autoOk db 'PASS E05 AUTO: geracao/morte natural, reposicao, ultima vida, tempo, reset, Sair.',13,10,'$'
tickInicioTeste dw 0
horaInicioLo dw 0
horaInicioHi dw 0
horaFimLo dw 0
horaFimHi dw 0
tempoAntesMorte dw 0
rolagemAntesMorte dw 0
nomeAuto db 'E05AUTO.BIN',0
nomeMorte db 'E05MORT.RAW',0
nomeRepor db 'E05REPO.RAW',0
nomeFimAuto db 'E05FIM.RAW',0
registroAuto dw 8 dup(0)

.code
jumps                          ; TASM expande saltos longos em instrucoes 8086
; Funcao: iniciar video, executar telas e devolver controle ao DOS.
; Entrada: nenhuma. Saida: codigo DOS 0, modo/pagina anteriores restaurados.
; Altera: registradores, segmentos e video. Partida restrita ao escopo E05.
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
    call DirigirE05
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
    call ReiniciarObstaculos
    call LimparTela
    call DesenharCenario
    call DesenharObstaculos
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
    call AvancarObstaculos
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
    cmp jipeAtivo,0
    je partidaRepor
    call AtualizarJipe
    jmp partidaDesenhar
partidaRepor:
    call TentarReporJipe
partidaDesenhar:
    call ConferirObstaculos     ; primeiro todas as colisoes, depois pontos
    cmp vidas,0
    je partidaExpirou
    call RetirarObstaculos
    cmp statusMudou,0
    je partidaQuadro
    call DesenharStatus
    mov statusMudou,0
partidaQuadro:
    mov al,cenarioMudou
    or al,jipeMudou
    jz partidaFim
    call DesenharQuadroPartida
partidaFim:
    ret
partidaExpirou:
    mov ax,scorePartida          ; valor real, nao o antigo SCORE_DEMO
    call EntrarGameOver
    ret
AtualizarPartida endp

; Funcao: restaurar somente os dados do jipe para uma nova partida.
; Entrada: nenhuma. Saida: posicao inicial, chao, sem teclas/pedido pendente.
; Altera: dados do jipe; preserva registradores. Nao reinicia score/relogio.
ReiniciarJipe proc near
    mov jipeAtivo,1
    mov jipeNaTela,0
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
    cmp jipeAtivo,0
    je scanFim                 ; ausente nao guarda salto para a reposicao
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
    mov jipeNaTela,1
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
    call DesenharCenario        ; apaga tambem todas as areas antigas dos obstaculos
    call DesenharObstaculos     ; antes da captura do jipe: fundo da rolagem atual
    mov jipeNaTela,0
    jmp quadroJipe
quadroSoJipe:
    cmp jipeNaTela,0
    je quadroJipe
    mov jipeNaTela,0
    mov ax,jipeDesenhoX
    mov bx,jipeDesenhoY
    mov cx,JIPE_LARG
    mov dx,JIPE_ALT
    lea si,fundoPartida
    call DesenharBitmap
quadroJipe:
    cmp jipeAtivo,0
    je quadroFim
    call CapturarEDesenharJipe
quadroFim:
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

; Funcao: reiniciar somente geracao/obstaculos para uma NOVA sessao.
; Entrada: nenhuma. Saida: lista vazia, semente dos ticks, primeira cratera.
; Altera: AX,CX,DX,DI,flags e dados; nao deve ser chamada na perda de vida.
ReiniciarObstaculos proc near
    xor di,di
reiniciarObstLoop:
    mov obstTipo[di],OBST_LIVRE
    mov obstPassagem[di],PASS_NOVO
    mov obstX[di],0
    add di,2
    cmp di,OBST_MAX*2
    jb reiniciarObstLoop
    mov proximoEm,0
    mov proximaRocha,0
    mov ateCratera,0
    mov statusMudou,0
    mov ah,0
    int 1Ah
    xor dx,cx
    mov semente,dx
    ret
ReiniciarObstaculos endp

; Funcao: pseudoaleatorio simples de 16 bits, com resto em faixa finita.
; Entrada: CX=limite exclusivo >0. Saida: AX=0..CX-1; nova semente.
; Altera: AX,DX,flags. Preserva: demais. Nao ha tentativas/rejeicoes.
Sortear proc near
    push bx
    mov ax,semente
    mov bx,25173
    mul bx
    add ax,13849               ; overflow intencional: modulo 65536
    mov semente,ax
    mov al,ah                 ; byte alto: evita ciclo curto dos bits baixos
    xor ah,ah
    xor dx,dx
    div cx
    mov ax,dx
    pop bx
    ret
Sortear endp

; Funcao: mover todos com o terreno e gerar C,R,C em distancias sorteadas.
; Entrada: lista/proximoEm. Saida: X -= PASSO_CENARIO; novos pela direita.
; Altera: AX,BX,CX,DX,DI,flags. Distancia negativa preserva sobra do passo.
AvancarObstaculos proc near
    xor di,di
obstMover:
    cmp obstTipo[di],OBST_LIVRE
    je obstMoverProximo
    sub obstX[di],PASSO_CENARIO
obstMoverProximo:
    add di,2
    cmp di,OBST_MAX*2
    jb obstMover
    sub proximoEm,PASSO_CENARIO
    cmp proximoEm,0
    jg obstAvancoFim
    xor di,di
obstVaga:
    cmp obstTipo[di],OBST_LIVRE
    je obstNascer
    add di,2
    cmp di,OBST_MAX*2
    jb obstVaga
    ; Capacidade folgada na configuracao validada; nunca sobrescrever ativo.
    ret
obstNascer:
    mov ax,TELA_LARG
    add ax,proximoEm
    mov obstX[di],ax
    mov obstPassagem[di],PASS_NOVO
    cmp proximaRocha,0
    jne obstNascerRocha
    mov cx,CRATERA_TIPOS
    call Sortear
    mov obstTipo[di],ax
    mov cx,CRATERA_GAP_VAR+1
    call Sortear
    add ax,CRATERA_GAP_MIN      ; gap livre 150..230
    mov bx,ax
    add bx,CRATERA_LARG        ; distancia entre origens das crateras
    sub ax,2*ROCHA_FOLGA+ROCHA_LARG
    inc ax
    mov cx,ax
    call Sortear
    add ax,CRATERA_LARG+ROCHA_FOLGA
    sub bx,ax
    mov ateCratera,bx          ; distancia rocha -> proxima cratera
    add proximoEm,ax
    mov proximaRocha,1
    ret
obstNascerRocha:
    mov cx,ROCHA_TIPOS
    call Sortear
    add ax,CRATERA_TIPOS
    mov obstTipo[di],ax
    mov ax,ateCratera
    add proximoEm,ax
    mov proximaRocha,0
obstAvancoFim:
    ret
AvancarObstaculos endp

; Funcao: detectar intervalo horizontal do jipe sobre um obstaculo.
; Entrada: DI=entrada ativa, jipeX. Saida: CF=1 sobrepoe; BX=tipo*2,
; AX=fim exclusivo do obstaculo. Altera: AX,BX,DX,flags; signed para bordas.
SobrepoeObstaculo proc near
    mov bx,obstTipo[di]
    shl bx,1
    mov ax,obstX[di]
    add ax,tipoLarg[bx]
    cmp ax,jipeX
    jle sobrepoeNao
    mov dx,jipeX
    add dx,JIPE_LARG
    cmp dx,obstX[di]
    jle sobrepoeNao
    stc
    ret
sobrepoeNao:
    clc
    ret
SobrepoeObstaculo endp

; Funcao: D15: colisao tem prioridade; depois acompanhar travessias por salto.
; Entrada: posicoes apos movimento (ou pouso). Saida: vida/pontos/marcadores.
; Altera: AX,BX,CX,DX,DI,flags. Sem desenho; no maximo uma morte por chamada.
ConferirObstaculos proc near
    cmp jipeAtivo,0
    je conferirObstFim
    xor di,di
conferirColisao:
    cmp obstTipo[di],OBST_LIVRE
    je conferirColProximo
    call SobrepoeObstaculo
    jnc conferirColProximo
    cmp obstTipo[di],CRATERA_TIPOS
    jae conferirRocha
    cmp jipeY,JIPE_Y_CHAO       ; buraco: apoio no chao sobre o intervalo vazio
    jb conferirColProximo
    jmp conferirMorte
conferirRocha:
    mov ax,jipeY
    add ax,JIPE_ALT
    cmp ax,PISTA_Y-ROCHA_ALT    ; bloco solido [x,x+12) x [183,193)
    jbe conferirColProximo     ; tocar a borda sem sobrepor pixels e seguro
conferirMorte:
    mov obstPassagem[di],PASS_INVALIDO
    call PerderVida
    ret
conferirColProximo:
    add di,2
    cmp di,OBST_MAX*2
    jb conferirColisao
    xor di,di
conferirPassagem:
    cmp obstTipo[di],OBST_LIVRE
    je conferirPassProximo
    cmp obstPassagem[di],PASS_PONTO
    jae conferirPassProximo
    call SobrepoeObstaculo
    jc passagemSobre
    cmp ax,jipeX
    jle passagemAtras
    mov obstPassagem[di],PASS_FRENTE ; inclusive recuo antes de completar
    jmp conferirPassProximo
passagemSobre:
    cmp estadoSalto,SALTO_CHAO
    je conferirPassProximo
    cmp obstPassagem[di],PASS_FRENTE
    jb conferirPassProximo     ; nao pontuar aparecimento/recriacao sobre objeto
    mov obstPassagem[di],PASS_SOBRE
    jmp conferirPassProximo
passagemAtras:
    cmp obstPassagem[di],PASS_SOBRE
    jne passagemPouso
    mov obstPassagem[di],PASS_CRUZOU
passagemPouso:
    cmp obstPassagem[di],PASS_CRUZOU
    jne conferirPassProximo
    cmp estadoSalto,SALTO_CHAO
    jne conferirPassProximo
    mov obstPassagem[di],PASS_PONTO
    mov ax,PONTOS_OBST
    call SomarPontos
conferirPassProximo:
    add di,2
    cmp di,OBST_MAX*2
    jb conferirPassagem
conferirObstFim:
    ret
ConferirObstaculos endp

; Funcao: somar pontos sem wrap de word; interface reutilizavel na E08.
; Entrada: AX=ganho unsigned. Saida: scorePartida <=65535, statusMudou=1.
; Altera: AX,flags. Saturacao explicita protege tambem configuracoes futuras.
SomarPontos proc near
    add ax,scorePartida
    jnc pontosGuardar
    mov ax,SCORE_MAX
pontosGuardar:
    mov scorePartida,ax
    mov statusMudou,1
    ret
SomarPontos endp

; Funcao: consumir uma vida e tornar jipe ausente, sem reiniciar a sessao.
; Entrada: jipeAtivo/vidas. Saida: uma vida a menos, travessias canceladas.
; Altera: DI,flags/dados. Tempo, score, geracao, rolagem e teclas preservados.
PerderVida proc near
    cmp jipeAtivo,0
    je perderFim
    mov jipeAtivo,0
    mov pedidoSalto,0
    mov jipeMudou,1
    cmp vidas,0
    je perderFim
    dec vidas
    mov statusMudou,1
    xor di,di
perderTravessia:
    cmp obstPassagem[di],PASS_SOBRE
    je perderInvalidar
    cmp obstPassagem[di],PASS_CRUZOU
    jne perderProxima
perderInvalidar:
    mov obstPassagem[di],PASS_INVALIDO
perderProxima:
    add di,2
    cmp di,OBST_MAX*2
    jb perderTravessia
perderFim:
    ret
PerderVida endp

; Funcao: D14, reaparecer no proximo tick do jipe com x=0 LIVRE.
; Entrada: jipe ausente/vidas/lista. Saida: posicao/fase reiniciadas se seguro.
; Altera: AX,BX,DI,flags. Sem invulnerabilidade/remocao de obstaculo.
; Mantem teclas fisicas: laterais voltam no proximo tick; cima exige soltura.
TentarReporJipe proc near
    cmp vidas,0
    je reporFim
    xor di,di
reporConferir:
    cmp obstTipo[di],OBST_LIVRE
    je reporProximo
    cmp obstX[di],JIPE_X_INICIAL+JIPE_LARG
    jge reporProximo
    mov bx,obstTipo[di]
    shl bx,1
    mov ax,obstX[di]
    add ax,tipoLarg[bx]
    cmp ax,JIPE_X_INICIAL
    jg reporFim
reporProximo:
    add di,2
    cmp di,OBST_MAX*2
    jb reporConferir
    pushf
    cli
    mov jipeX,JIPE_X_INICIAL
    mov jipeY,JIPE_Y_CHAO
    mov estadoSalto,SALTO_CHAO
    mov pixelsTopo,0
    mov pedidoSalto,0
    mov jipeAtivo,1
    popf
    mov jipeMudou,1
reporFim:
    ret
TentarReporJipe endp

; Funcao: liberar apenas objetos inteiros fora da esquerda, sem dar pontos.
; Entrada: lista e marcadores. Saida: vagas livres; travessia espera pouso.
; Altera: AX,BX,DI,flags. Preserva candidato que saiu da tela durante salto.
RetirarObstaculos proc near
    xor di,di
retirarLoop:
    cmp obstTipo[di],OBST_LIVRE
    je retirarProximo
    mov bx,obstTipo[di]
    shl bx,1
    mov ax,obstX[di]
    add ax,tipoLarg[bx]
    cmp ax,0
    jg retirarProximo
    cmp obstPassagem[di],PASS_CRUZOU
    je retirarProximo
    mov obstTipo[di],OBST_LIVRE
retirarProximo:
    add di,2
    cmp di,OBST_MAX*2
    jb retirarLoop
    ret
RetirarObstaculos endp

; Funcao: compor os sete tipos sobre o cenario limpo, antes do jipe.
; Entrada: tabelas, ES=video. Saida: obstaculos visiveis; sem fundos antigos.
; Altera: AX,BX,CX,DX,SI,DI,flags. Artes E02 intactas.
DesenharObstaculos proc near
    xor di,di
desenharObstLoop:
    cmp obstTipo[di],OBST_LIVRE
    je desenharObstProximo
    mov bx,obstTipo[di]
    shl bx,1
    mov ax,obstX[di]
    mov cx,tipoLarg[bx]
    mov dx,tipoAlt[bx]
    mov si,tipoBitmap[bx]
    mov bx,tipoY[bx]
    call DesenharSpriteRecortado
desenharObstProximo:
    add di,2
    cmp di,OBST_MAX*2
    jb desenharObstLoop
    ret
DesenharObstaculos endp

; Funcao: sprite FFh com recorte HORIZONTAL para entrada/saida gradual.
; Entrada: AX=x signed, BX=y, CX=largura, DX=altura, DS:SI=bitmap, ES=video.
; Saida: somente pixels dentro de 0..319; y deve caber inteiro em 0..199.
; Preserva: registradores. Altera: flags (DF=0), video por memoria.
; DesenharSprite original e menu continuam com contrato sem recorte.
DesenharSpriteRecortado proc near
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp
    cld
    mov bp,cx                 ; largura original determina o passo da fonte
    cmp ax,0
    jge recorteDireita
    neg ax
    cmp ax,cx
    jae recorteFim
    add si,ax                 ; descartar colunas a esquerda na fonte
    sub cx,ax
    xor ax,ax
recorteDireita:
    cmp ax,TELA_LARG
    jge recorteFim
    mov di,TELA_LARG
    sub di,ax
    cmp cx,di
    jbe recorteArea
    mov cx,di
recorteArea:
    sub bp,cx                 ; salto na fonte depois da parte visivel
    push bp
    call PrepararRetangulo
    pop dx                    ; BX=salto no destino, BP=altura, DX=salto fonte
    jc recorteFim
recorteLinha:
    push cx
recortePixel:
    lodsb
    cmp al,TRANSPARENTE
    je recorteTransparente
    mov es:[di],al
recorteTransparente:
    inc di
    loop recortePixel
    pop cx
    add si,dx
    add di,bx
    dec bp
    jnz recorteLinha
recorteFim:
    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
DesenharSpriteRecortado endp

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

end inicio
