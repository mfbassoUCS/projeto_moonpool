; Moon Patrol - E09: revisao da versao completa implementada na E08.
; TASM 4.1 / TLINK, Turbo 16-bit. Fonte ASCII, instrucoes 8086.
; Menu -> SETOR 1 -> partida -> fim por tempo ou vidas. Uma unica fase.
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
SCAN_ESPACO     equ 39h
BIT_ESPACO      equ 8
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
OBJETIVO_LINHA   equ 19
AVANCO_LINHA     equ 21
TIROS_LINHA      equ 23
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
PASSO_JIPE      equ 5            ; margem horizontal no salto; altura segue 15
; Cadencia independente das naves da partida (E06).
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
; E06: interpretacoes tecnicas D06/D07/D09, nao respostas do professor.
NAVE_MAX         equ 3
NAVE_TIPOS       equ 3
NAVE_Y_MIN       equ HUD_ALT
NAVE_Y_MAX       equ CENARIO_Y-NAVE_ALT ; origem 15..86, pixels ate 99
NAVE_GAP_MIN     equ 30          ; espaco LIVRE entre bordas
NAVE_FAIXA       equ TELA_LARG/2 ; formacao inteira cabe em 160 pixels
NAVE_X_INICIAL   equ TELA_LARG   ; faixa de espera [320,480), entrada gradual
NAVE_ENTRADA_VAR equ 15          ; primeira origem 320..335, evita espera longa
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
IF (NAVE_MAX*NAVE_LARG+(NAVE_MAX-1)*NAVE_GAP_MIN+NAVE_ENTRADA_VAR GT NAVE_FAIXA)
 .ERR
ENDIF
IF (NAVE_Y_MAX LT NAVE_Y_MIN) OR (NAVE_Y_MAX-NAVE_Y_MIN+1 GT 256)
 .ERR
ENDIF
IF (NAVE_FAIXA GT 256) OR (NAVE_ENTRADA_VAR LT 0)
 .ERR                         ; todos os sorteios cabem no byte alto do LCG
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

; E08 / D11 e D13: escolhas tecnicas, nao valores dados pelo professor.
TIRO_SUP_MAX    equ 8
TIRO_FRE_MAX    equ 8
TIRO_INI_MAX    equ 12
TIRO_FRE_INICIO equ TIRO_SUP_MAX*2
TIRO_INI_INICIO equ (TIRO_SUP_MAX+TIRO_FRE_MAX)*2
TIRO_MAX        equ TIRO_SUP_MAX+TIRO_FRE_MAX+TIRO_INI_MAX
TIRO_SUP_LARG   equ 2
TIRO_SUP_ALT    equ 4
TIRO_FRE_LARG   equ 4
TIRO_FRE_ALT    equ 2
TIRO_INI_LARG   equ 2
TIRO_INI_ALT    equ 4
COR_TIRO_SUP    equ 0Eh
COR_TIRO_FRE    equ 04h
COR_TIRO_INI    equ 0Fh
CANHAO_SUP_X    equ 6             ; coluna do canhao no bitmap autoral
CANHAO_FRE_X    equ JIPE_LARG
CANHAO_FRE_Y    equ 4
CANHAO_NAVE_X   equ (NAVE_LARG-TIRO_INI_LARG)/2
TICKS_TIRO      equ 1
PASSO_TIRO_SUP  equ 4
PASSO_TIRO_FRE  equ 4
PASSO_TIRO_INI  equ 2             ; ~36 px/s, jipe ~55 px/s
CADENCIA_JIPE   equ 6             ; atualizacoes de TICKS_TIRO (~330 ms)
CADENCIA_NAVE   equ 18            ; ~1 s, contador por nave visivel
ALCANCE_FRONTAL equ 50            ; distancia desde a origem, nao X absoluto
PONTOS_NAVE     equ 100
ROCHA_1        equ CRATERA_TIPOS
ROCHA_4        equ CRATERA_TIPOS+3
IMPACTOS_ROCHA4 equ 2             ; mesma rocha, sem prazo ou reinicio por erro
IF (TICKS_TIRO LT 1) OR (CADENCIA_JIPE LT 1) OR (CADENCIA_NAVE LT 1)
 .ERR
ENDIF
IF (PASSO_TIRO_SUP LT 1) OR (PASSO_TIRO_FRE LT 1) OR (PASSO_TIRO_INI LT 1)
 .ERR
ENDIF
IF (TIRO_SUP_MAX LT 1) OR (TIRO_FRE_MAX LT 1) OR (TIRO_INI_MAX LT NAVE_MAX)
 .ERR
ENDIF

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
teclasJipe     db 0             ; bits: esquerda, direita, cima e Espaco
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
obstImpactos    dw OBST_MAX dup(0) ; reinicia quando a vaga recebe outro objeto
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
; E06: DI=0,2,4 seleciona a mesma nave; tipo compartilhado pelo grupo.
naveX           dw NAVE_MAX dup(0) ; signed, inclusive fora da tela
naveY           dw NAVE_MAX dup(0)
naveAtiva       dw NAVE_MAX dup(0)
naveQuantidade  dw 0              ; quantidade sorteada, nao contagem ativa
naveTipo        dw 0
naveBitmap      dw offset bitmapNave1,offset bitmapNave2,offset bitmapNave3
tickNave        dw 0
navesMudou      db 0              ; consumido pelo desenho, inclusive remocao
; Uma lista, tres faixas fixas. SI=offset par; cada tiro tem vida propria.
tiroAtivo       dw TIRO_MAX dup(0)
tiroX           dw TIRO_MAX dup(0)
tiroY           dw TIRO_MAX dup(0)
tiroDistancia   dw TIRO_MAX dup(0)
tiroLarg        dw TIRO_SUP_LARG,TIRO_FRE_LARG,TIRO_INI_LARG
tiroAlt         dw TIRO_SUP_ALT,TIRO_FRE_ALT,TIRO_INI_ALT
tiroBitmap      dw offset bitmapTiroSup,offset bitmapTiroFre,offset bitmapTiroIni
bitmapTiroSup   db TIRO_SUP_LARG*TIRO_SUP_ALT dup(COR_TIRO_SUP)
bitmapTiroFre   db TIRO_FRE_LARG*TIRO_FRE_ALT dup(COR_TIRO_FRE)
bitmapTiroIni   db TIRO_INI_LARG*TIRO_INI_ALT dup(COR_TIRO_INI)
esperaNave      dw NAVE_MAX dup(0)
esperaJipe      dw 0
tickTiro        dw 0
tirosMudou      db 0
pedidoTiro      db 0              ; captura toque curto; mantida repete na cadencia
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
bitmapMontanhas db 149 dup(0FFh),5 dup(09h),166 dup(0FFh)
                db 148 dup(0FFh),7 dup(09h),165 dup(0FFh)
                db 147 dup(0FFh),5 dup(09h),01h,3 dup(09h),164 dup(0FFh)
                db 146 dup(0FFh),5 dup(09h),01h,09h,01h,3 dup(09h),163 dup(0FFh)
                db 145 dup(0FFh),7 dup(09h),01h,09h,01h,3 dup(09h),162 dup(0FFh)
                db 42 dup(0FFh),3 dup(09h),99 dup(0FFh),9 dup(09h),01h,5 dup(09h),161 dup(0FFh)
                db 41 dup(0FFh),6 dup(09h),97 dup(0FFh),10 dup(09h),01h,5 dup(09h),160 dup(0FFh)
                db 40 dup(0FFh),3 dup(09h),01h,4 dup(09h),95 dup(0FFh),10 dup(09h),01h,09h,01h,5 dup(09h),159 dup(0FFh)
                db 39 dup(0FFh),5 dup(09h),01h,4 dup(09h),93 dup(0FFh),12 dup(09h),01h,09h,01h,4 dup(09h),159 dup(0FFh)
                db 38 dup(0FFh),7 dup(09h),01h,4 dup(09h),92 dup(0FFh),13 dup(09h),01h,6 dup(09h),104 dup(0FFh),5 dup(09h),49 dup(0FFh)
                db 38 dup(0FFh),6 dup(09h),01h,09h,01h,4 dup(09h),90 dup(0FFh),13 dup(09h),01h,09h,01h,6 dup(09h),101 dup(0FFh),9 dup(09h),47 dup(0FFh)
                db 37 dup(0FFh),8 dup(09h),01h,09h,01h,3 dup(09h),90 dup(0FFh),13 dup(09h),2 dup(01h),09h,01h,5 dup(09h),100 dup(0FFh),6 dup(09h),01h,4 dup(09h),46 dup(0FFh)
                db 37 dup(0FFh),9 dup(09h),01h,5 dup(09h),88 dup(0FFh),15 dup(09h),2 dup(01h),09h,01h,5 dup(09h),98 dup(0FFh),6 dup(09h),01h,09h,01h,4 dup(09h),45 dup(0FFh)
                db 36 dup(0FFh),11 dup(09h),01h,5 dup(09h),87 dup(0FFh),15 dup(09h),01h,09h,01h,6 dup(09h),97 dup(0FFh),8 dup(09h),01h,09h,01h,4 dup(09h),44 dup(0FFh)
                db 36 dup(0FFh),10 dup(09h),01h,09h,01h,4 dup(09h),86 dup(0FFh),17 dup(09h),01h,09h,01h,6 dup(09h),95 dup(0FFh),10 dup(09h),01h,6 dup(09h),43 dup(0FFh)
                db 35 dup(0FFh),11 dup(09h),2 dup(01h),09h,01h,4 dup(09h),85 dup(0FFh),16 dup(09h),3 dup(01h),09h,01h,6 dup(09h),38 dup(0FFh),5 dup(09h),50 dup(0FFh),12 dup(09h),01h,6 dup(09h),42 dup(0FFh)
                db 35 dup(0FFh),11 dup(09h),01h,09h,01h,5 dup(09h),84 dup(0FFh),18 dup(09h),3 dup(01h),09h,01h,5 dup(09h),36 dup(0FFh),9 dup(09h),48 dup(0FFh),11 dup(09h),01h,09h,01h,6 dup(09h),41 dup(0FFh)
                db 34 dup(0FFh),13 dup(09h),01h,09h,01h,5 dup(09h),83 dup(0FFh),18 dup(09h),2 dup(01h),09h,01h,7 dup(09h),33 dup(0FFh),7 dup(09h),01h,5 dup(09h),45 dup(0FFh),13 dup(09h),01h,09h,01h,5 dup(09h),41 dup(0FFh)
                db 33 dup(0FFh),14 dup(09h),2 dup(01h),09h,01h,5 dup(09h),37 dup(0FFh),4 dup(09h),40 dup(0FFh),20 dup(09h),2 dup(01h),09h,01h,7 dup(09h),31 dup(0FFh),7 dup(09h),01h,09h,01h,5 dup(09h),43 dup(0FFh),15 dup(09h),01h,7 dup(09h),40 dup(0FFh)
                db 33 dup(0FFh),15 dup(09h),2 dup(01h),09h,01h,4 dup(09h),35 dup(0FFh),8 dup(09h),38 dup(0FFh),20 dup(09h),3 dup(01h),09h,01h,6 dup(09h),30 dup(0FFh),9 dup(09h),01h,09h,01h,5 dup(09h),41 dup(0FFh),15 dup(09h),01h,09h,01h,7 dup(09h),39 dup(0FFh)
                db 32 dup(0FFh),15 dup(09h),2 dup(01h),09h,01h,6 dup(09h),33 dup(0FFh),6 dup(09h),01h,3 dup(09h),36 dup(0FFh),21 dup(09h),4 dup(01h),09h,01h,6 dup(09h),28 dup(0FFh),11 dup(09h),01h,7 dup(09h),40 dup(0FFh),15 dup(09h),2 dup(01h),09h,01h,7 dup(09h),38 dup(0FFh)
                db 32 dup(0FFh),16 dup(09h),2 dup(01h),09h,01h,5 dup(09h),32 dup(0FFh),6 dup(09h),01h,09h,01h,3 dup(09h),35 dup(0FFh),21 dup(09h),3 dup(01h),09h,01h,7 dup(09h),27 dup(0FFh),13 dup(09h),01h,7 dup(09h),38 dup(0FFh),17 dup(09h),2 dup(01h),09h,01h,7 dup(09h),37 dup(0FFh)
                db 31 dup(0FFh),17 dup(09h),3 dup(01h),09h,01h,5 dup(09h),30 dup(0FFh),8 dup(09h),01h,09h,01h,3 dup(09h),33 dup(0FFh),23 dup(09h),3 dup(01h),09h,01h,7 dup(09h),25 dup(0FFh),13 dup(09h),01h,09h,01h,7 dup(09h),36 dup(0FFh),18 dup(09h),01h,09h,01h,8 dup(09h),37 dup(0FFh)
                db 31 dup(0FFh),18 dup(09h),3 dup(01h),09h,01h,4 dup(09h),29 dup(0FFh),10 dup(09h),01h,5 dup(09h),32 dup(0FFh),23 dup(09h),4 dup(01h),09h,01h,7 dup(09h),23 dup(0FFh),15 dup(09h),01h,09h,01h,7 dup(09h),35 dup(0FFh),19 dup(09h),01h,09h,01h,8 dup(09h),36 dup(0FFh)
                db 30 dup(0FFh),19 dup(09h),2 dup(01h),09h,01h,6 dup(09h),27 dup(0FFh),12 dup(09h),01h,4 dup(09h),31 dup(0FFh),25 dup(09h),4 dup(01h),09h,01h,6 dup(09h),21 dup(0FFh),18 dup(09h),01h,8 dup(09h),34 dup(0FFh),19 dup(09h),3 dup(01h),09h,01h,8 dup(09h),35 dup(0FFh)
                db 30 dup(0FFh),19 dup(09h),3 dup(01h),09h,01h,6 dup(09h),25 dup(0FFh),12 dup(09h),01h,09h,01h,4 dup(09h),30 dup(0FFh),24 dup(09h),4 dup(01h),09h,01h,8 dup(09h),19 dup(0FFh),18 dup(09h),01h,09h,01h,8 dup(09h),32 dup(0FFh),21 dup(09h),3 dup(01h),09h,01h,8 dup(09h),34 dup(0FFh)
                db 29 dup(0FFh),20 dup(09h),4 dup(01h),09h,01h,5 dup(09h),24 dup(0FFh),14 dup(09h),01h,09h,01h,4 dup(09h),28 dup(0FFh),26 dup(09h),4 dup(01h),09h,01h,8 dup(09h),17 dup(0FFh),19 dup(09h),2 dup(01h),09h,01h,8 dup(09h),31 dup(0FFh),21 dup(09h),2 dup(01h),09h,01h,10 dup(09h),33 dup(0FFh)
                db 28 dup(0FFh),22 dup(09h),4 dup(01h),09h,01h,5 dup(09h),22 dup(0FFh),16 dup(09h),01h,5 dup(09h),28 dup(0FFh),26 dup(09h),5 dup(01h),09h,01h,8 dup(09h),15 dup(0FFh),21 dup(09h),2 dup(01h),09h,01h,8 dup(09h),29 dup(0FFh),23 dup(09h),2 dup(01h),09h,01h,10 dup(09h),32 dup(0FFh)
                db 27 dup(0FFh),23 dup(09h),3 dup(01h),09h,01h,6 dup(09h),21 dup(0FFh),16 dup(09h),01h,09h,01h,5 dup(09h),26 dup(0FFh),28 dup(09h),5 dup(01h),09h,01h,8 dup(09h),13 dup(0FFh),22 dup(09h),01h,09h,01h,10 dup(09h),27 dup(0FFh),24 dup(09h),3 dup(01h),09h,01h,10 dup(09h),31 dup(0FFh)
                db 26 dup(0FFh),25 dup(09h),3 dup(01h),09h,01h,6 dup(09h),19 dup(0FFh),17 dup(09h),2 dup(01h),09h,01h,5 dup(09h),25 dup(0FFh),28 dup(09h),4 dup(01h),09h,01h,10 dup(09h),11 dup(0FFh),24 dup(09h),01h,09h,01h,10 dup(09h),26 dup(0FFh),24 dup(09h),4 dup(01h),09h,01h,11 dup(09h),29 dup(0FFh)
                db 22 dup(0FFh),28 dup(09h),5 dup(01h),09h,01h,6 dup(09h),17 dup(0FFh),19 dup(09h),2 dup(01h),09h,01h,4 dup(09h),24 dup(0FFh),29 dup(09h),5 dup(01h),09h,01h,10 dup(09h),8 dup(0FFh),25 dup(09h),3 dup(01h),09h,01h,10 dup(09h),24 dup(0FFh),25 dup(09h),3 dup(01h),09h,01h,18 dup(09h),23 dup(0FFh)
                db 19 dup(0FFh),32 dup(09h),5 dup(01h),09h,01h,5 dup(09h),16 dup(0FFh),20 dup(09h),01h,09h,01h,6 dup(09h),23 dup(0FFh),29 dup(09h),6 dup(01h),09h,01h,10 dup(09h),5 dup(0FFh),28 dup(09h),3 dup(01h),09h,01h,9 dup(09h),23 dup(0FFh),27 dup(09h),3 dup(01h),09h,01h,19 dup(09h),21 dup(0FFh)
                db 17 dup(0FFh),34 dup(09h),4 dup(01h),09h,01h,7 dup(09h),14 dup(0FFh),22 dup(09h),01h,09h,01h,5 dup(09h),22 dup(0FFh),31 dup(09h),6 dup(01h),09h,01h,42 dup(09h),2 dup(01h),09h,01h,11 dup(09h),21 dup(0FFh),28 dup(09h),4 dup(01h),09h,01h,20 dup(09h),19 dup(0FFh)
                db 16 dup(0FFh),36 dup(09h),4 dup(01h),09h,01h,7 dup(09h),12 dup(0FFh),22 dup(09h),3 dup(01h),09h,01h,5 dup(09h),21 dup(0FFh),31 dup(09h),5 dup(01h),09h,01h,44 dup(09h),2 dup(01h),09h,01h,11 dup(09h),20 dup(0FFh),29 dup(09h),4 dup(01h),09h,01h,21 dup(09h),17 dup(0FFh)
                db 15 dup(0FFh),37 dup(09h),5 dup(01h),09h,01h,7 dup(09h),10 dup(0FFh),24 dup(09h),3 dup(01h),09h,01h,5 dup(09h),19 dup(0FFh),33 dup(09h),5 dup(01h),09h,01h,43 dup(09h),3 dup(01h),09h,01h,11 dup(09h),18 dup(0FFh),29 dup(09h),4 dup(01h),09h,01h,23 dup(09h),16 dup(0FFh)
                db 13 dup(0FFh),39 dup(09h),6 dup(01h),09h,01h,7 dup(09h),8 dup(0FFh),25 dup(09h),2 dup(01h),09h,01h,6 dup(09h),19 dup(0FFh),32 dup(09h),7 dup(01h),09h,01h,42 dup(09h),4 dup(01h),09h,01h,11 dup(09h),16 dup(0FFh),31 dup(09h),4 dup(01h),09h,01h,24 dup(09h),14 dup(0FFh)
                db 12 dup(0FFh),40 dup(09h),5 dup(01h),09h,01h,10 dup(09h),4 dup(0FFh),28 dup(09h),2 dup(01h),09h,01h,6 dup(09h),17 dup(0FFh),34 dup(09h),7 dup(01h),09h,01h,41 dup(09h),3 dup(01h),09h,01h,13 dup(09h),14 dup(0FFh),32 dup(09h),5 dup(01h),09h,01h,24 dup(09h),13 dup(0FFh)
                db 10 dup(0FFh),43 dup(09h),5 dup(01h),09h,01h,41 dup(09h),3 dup(01h),09h,01h,6 dup(09h),15 dup(0FFh),35 dup(09h),6 dup(01h),09h,01h,43 dup(09h),3 dup(01h),09h,01h,13 dup(09h),12 dup(0FFh),34 dup(09h),5 dup(01h),09h,01h,25 dup(09h),11 dup(0FFh)
                db 9 dup(0FFh),44 dup(09h),6 dup(01h),09h,01h,40 dup(09h),4 dup(01h),09h,01h,5 dup(09h),15 dup(0FFh),36 dup(09h),6 dup(01h),09h,01h,42 dup(09h),4 dup(01h),09h,01h,14 dup(09h),9 dup(0FFh),35 dup(09h),4 dup(01h),09h,01h,27 dup(09h),10 dup(0FFh)
                db 8 dup(0FFh),46 dup(09h),6 dup(01h),09h,01h,39 dup(09h),3 dup(01h),09h,01h,7 dup(09h),13 dup(0FFh),37 dup(09h),7 dup(01h),09h,01h,42 dup(09h),4 dup(01h),09h,01h,15 dup(09h),5 dup(0FFh),37 dup(09h),5 dup(01h),09h,01h,28 dup(09h),8 dup(0FFh)
                db 6 dup(0FFh),47 dup(09h),6 dup(01h),09h,01h,41 dup(09h),3 dup(01h),09h,01h,7 dup(09h),11 dup(0FFh),38 dup(09h),8 dup(01h),09h,01h,40 dup(09h),4 dup(01h),09h,01h,58 dup(09h),6 dup(01h),09h,01h,29 dup(09h),6 dup(0FFh)
                db 3 dup(0FFh),51 dup(09h),6 dup(01h),09h,01h,40 dup(09h),4 dup(01h),09h,01h,7 dup(09h),9 dup(0FFh),39 dup(09h),7 dup(01h),09h,01h,42 dup(09h),4 dup(01h),09h,01h,58 dup(09h),6 dup(01h),09h,01h,30 dup(09h),4 dup(0FFh)
                db 54 dup(09h),7 dup(01h),09h,01h,40 dup(09h),4 dup(01h),09h,01h,7 dup(09h),7 dup(0FFh),41 dup(09h),7 dup(01h),09h,01h,41 dup(09h),5 dup(01h),09h,01h,57 dup(09h),5 dup(01h),09h,01h,35 dup(09h)
                db 55 dup(09h),7 dup(01h),09h,01h,38 dup(09h),4 dup(01h),09h,01h,10 dup(09h),4 dup(0FFh),42 dup(09h),8 dup(01h),09h,01h,41 dup(09h),5 dup(01h),09h,01h,57 dup(09h),5 dup(01h),09h,01h,34 dup(09h)
                db 55 dup(09h),6 dup(01h),09h,01h,40 dup(09h),4 dup(01h),09h,01h,56 dup(09h),8 dup(01h),09h,01h,40 dup(09h),4 dup(01h),09h,01h,57 dup(09h),7 dup(01h),09h,01h,33 dup(09h)
                db 55 dup(09h),7 dup(01h),09h,01h,39 dup(09h),5 dup(01h),09h,01h,54 dup(09h),8 dup(01h),09h,01h,41 dup(09h),5 dup(01h),09h,01h,57 dup(09h),7 dup(01h),09h,01h,32 dup(09h)
                db 55 dup(09h),8 dup(01h),09h,01h,39 dup(09h),5 dup(01h),09h,01h,54 dup(09h),8 dup(01h),09h,01h,40 dup(09h),6 dup(01h),09h,01h,56 dup(09h),6 dup(01h),09h,01h,33 dup(09h)
                db 56 dup(09h),8 dup(01h),09h,01h,38 dup(09h),4 dup(01h),09h,01h,55 dup(09h),9 dup(01h),09h,01h,40 dup(09h),6 dup(01h),09h,01h,56 dup(09h),6 dup(01h),09h,01h,32 dup(09h)
                db 56 dup(09h),7 dup(01h),09h,01h,39 dup(09h),5 dup(01h),09h,01h,55 dup(09h),9 dup(01h),09h,01h,39 dup(09h),5 dup(01h),09h,01h,57 dup(09h),7 dup(01h),09h,01h,31 dup(09h)
                db 57 dup(09h),7 dup(01h),09h,01h,38 dup(09h),6 dup(01h),09h,01h,54 dup(09h),8 dup(01h),09h,01h,41 dup(09h),5 dup(01h),09h,01h,56 dup(09h),8 dup(01h),09h,01h,30 dup(09h)
                db 56 dup(09h),9 dup(01h),09h,01h,38 dup(09h),6 dup(01h),09h,01h,53 dup(09h),9 dup(01h),09h,01h,39 dup(09h),7 dup(01h),09h,01h,55 dup(09h),7 dup(01h),09h,01h,31 dup(09h)
                db 57 dup(09h),9 dup(01h),09h,01h,37 dup(09h),5 dup(01h),09h,01h,54 dup(09h),10 dup(01h),09h,01h,39 dup(09h),7 dup(01h),09h,01h,55 dup(09h),7 dup(01h),09h,01h,30 dup(09h)
                db 57 dup(09h),8 dup(01h),09h,01h,39 dup(09h),5 dup(01h),09h,01h,54 dup(09h),10 dup(01h),09h,01h,38 dup(09h),6 dup(01h),09h,01h,56 dup(09h),8 dup(01h),09h,01h,29 dup(09h)
                db 58 dup(09h),8 dup(01h),09h,01h,37 dup(09h),7 dup(01h),09h,01h,53 dup(09h),9 dup(01h),09h,01h,40 dup(09h),6 dup(01h),09h,01h,56 dup(09h),8 dup(01h),09h,01h,28 dup(09h)
                db 58 dup(09h),9 dup(01h),09h,01h,37 dup(09h),7 dup(01h),09h,01h,53 dup(09h),9 dup(01h),09h,01h,39 dup(09h),7 dup(01h),09h,01h,54 dup(09h),8 dup(01h),09h,01h,29 dup(09h)
                db 58 dup(09h),10 dup(01h),09h,01h,36 dup(09h),6 dup(01h),09h,01h,53 dup(09h),11 dup(01h),09h,01h,38 dup(09h),8 dup(01h),09h,01h,54 dup(09h),8 dup(01h),09h,01h,28 dup(09h)
                db 58 dup(09h),9 dup(01h),09h,01h,38 dup(09h),6 dup(01h),09h,01h,53 dup(09h),11 dup(01h),09h,01h,37 dup(09h),7 dup(01h),09h,01h,55 dup(09h),9 dup(01h),09h,01h,27 dup(09h)
                db 59 dup(09h),9 dup(01h),09h,01h,37 dup(09h),7 dup(01h),09h,01h,52 dup(09h),10 dup(01h),09h,01h,39 dup(09h),7 dup(01h),09h,01h,55 dup(09h),9 dup(01h),09h,01h,26 dup(09h)
                db 59 dup(09h),10 dup(01h),09h,01h,36 dup(09h),8 dup(01h),09h,01h,52 dup(09h),10 dup(01h),09h,01h,38 dup(09h),8 dup(01h),09h,01h,54 dup(09h),8 dup(01h),09h,01h,27 dup(09h)
                db 60 dup(09h),10 dup(01h),09h,01h,35 dup(09h),7 dup(01h),09h,01h,53 dup(09h),11 dup(01h),09h,01h,38 dup(09h),8 dup(01h),09h,01h,53 dup(09h),9 dup(01h),09h,01h,26 dup(09h)
                db 59 dup(09h),10 dup(01h),09h,01h,37 dup(09h),7 dup(01h),09h,01h,52 dup(09h),12 dup(01h),09h,01h,36 dup(09h),8 dup(01h),09h,01h,54 dup(09h),10 dup(01h),09h,01h,25 dup(09h)
                db 60 dup(09h),10 dup(01h),09h,01h,36 dup(09h),8 dup(01h),09h,01h,51 dup(09h),11 dup(01h),09h,01h,38 dup(09h),8 dup(01h),09h,01h,54 dup(09h),10 dup(01h),09h,01h,24 dup(09h)
                db 320 dup(09h)
                db 320 dup(09h)
bitmapMontanhasFim label byte
; Montes - 320 x 32
bitmapMontes db 173 dup(0FFh),7 dup(0Ah),140 dup(0FFh)
             db 171 dup(0FFh),12 dup(0Ah),137 dup(0FFh)
             db 169 dup(0FFh),7 dup(0Ah),02h,0Ah,02h,6 dup(0Ah),135 dup(0FFh)
             db 167 dup(0FFh),10 dup(0Ah),02h,8 dup(0Ah),134 dup(0FFh)
             db 53 dup(0FFh),8 dup(0Ah),104 dup(0FFh),13 dup(0Ah),02h,9 dup(0Ah),132 dup(0FFh)
             db 50 dup(0FFh),14 dup(0Ah),100 dup(0FFh),13 dup(0Ah),02h,0Ah,02h,10 dup(0Ah),130 dup(0FFh)
             db 48 dup(0FFh),8 dup(0Ah),02h,0Ah,02h,8 dup(0Ah),95 dup(0FFh),16 dup(0Ah),02h,0Ah,02h,10 dup(0Ah),129 dup(0FFh)
             db 46 dup(0FFh),11 dup(0Ah),02h,11 dup(0Ah),92 dup(0FFh),18 dup(0Ah),02h,12 dup(0Ah),128 dup(0FFh)
             db 44 dup(0FFh),14 dup(0Ah),02h,12 dup(0Ah),88 dup(0FFh),21 dup(0Ah),02h,13 dup(0Ah),126 dup(0FFh)
             db 43 dup(0FFh),14 dup(0Ah),02h,0Ah,02h,13 dup(0Ah),84 dup(0FFh),22 dup(0Ah),02h,0Ah,02h,14 dup(0Ah),70 dup(0FFh),8 dup(0Ah),46 dup(0FFh)
             db 41 dup(0FFh),17 dup(0Ah),02h,0Ah,02h,14 dup(0Ah),80 dup(0FFh),24 dup(0Ah),2 dup(02h),0Ah,02h,14 dup(0Ah),67 dup(0FFh),13 dup(0Ah),43 dup(0FFh)
             db 39 dup(0FFh),20 dup(0Ah),02h,17 dup(0Ah),76 dup(0FFh),26 dup(0Ah),02h,0Ah,02h,17 dup(0Ah),63 dup(0FFh),7 dup(0Ah),02h,0Ah,02h,8 dup(0Ah),40 dup(0FFh)
             db 38 dup(0FFh),22 dup(0Ah),02h,18 dup(0Ah),67 dup(0FFh),34 dup(0Ah),02h,0Ah,02h,19 dup(0Ah),58 dup(0FFh),10 dup(0Ah),02h,12 dup(0Ah),37 dup(0FFh)
             db 36 dup(0FFh),23 dup(0Ah),02h,0Ah,02h,20 dup(0Ah),61 dup(0FFh),37 dup(0Ah),2 dup(02h),0Ah,02h,26 dup(0Ah),49 dup(0FFh),12 dup(0Ah),02h,13 dup(0Ah),35 dup(0FFh)
             db 34 dup(0FFh),25 dup(0Ah),2 dup(02h),0Ah,02h,22 dup(0Ah),56 dup(0FFh),40 dup(0Ah),2 dup(02h),0Ah,02h,29 dup(0Ah),44 dup(0FFh),12 dup(0Ah),02h,0Ah,02h,15 dup(0Ah),32 dup(0FFh)
             db 32 dup(0FFh),27 dup(0Ah),02h,0Ah,02h,31 dup(0Ah),46 dup(0FFh),41 dup(0Ah),2 dup(02h),0Ah,02h,32 dup(0Ah),40 dup(0FFh),15 dup(0Ah),02h,0Ah,02h,17 dup(0Ah),29 dup(0FFh)
             db 29 dup(0FFh),31 dup(0Ah),02h,0Ah,02h,33 dup(0Ah),41 dup(0FFh),44 dup(0Ah),2 dup(02h),0Ah,02h,34 dup(0Ah),36 dup(0FFh),17 dup(0Ah),02h,26 dup(0Ah),21 dup(0FFh)
             db 21 dup(0FFh),39 dup(0Ah),2 dup(02h),0Ah,02h,34 dup(0Ah),37 dup(0FFh),46 dup(0Ah),3 dup(02h),0Ah,02h,35 dup(0Ah),33 dup(0FFh),19 dup(0Ah),02h,29 dup(0Ah),17 dup(0FFh)
             db 17 dup(0FFh),44 dup(0Ah),2 dup(02h),0Ah,02h,35 dup(0Ah),34 dup(0FFh),48 dup(0Ah),3 dup(02h),0Ah,02h,36 dup(0Ah),29 dup(0FFh),20 dup(0Ah),02h,0Ah,02h,30 dup(0Ah),15 dup(0FFh)
             db 14 dup(0FFh),46 dup(0Ah),2 dup(02h),0Ah,02h,37 dup(0Ah),31 dup(0FFh),50 dup(0Ah),2 dup(02h),0Ah,02h,39 dup(0Ah),26 dup(0FFh),21 dup(0Ah),2 dup(02h),0Ah,02h,31 dup(0Ah),13 dup(0FFh)
             db 12 dup(0FFh),49 dup(0Ah),2 dup(02h),0Ah,02h,38 dup(0Ah),28 dup(0FFh),51 dup(0Ah),3 dup(02h),0Ah,02h,40 dup(0Ah),23 dup(0FFh),22 dup(0Ah),02h,0Ah,02h,35 dup(0Ah),10 dup(0FFh)
             db 9 dup(0FFh),52 dup(0Ah),3 dup(02h),0Ah,02h,39 dup(0Ah),24 dup(0FFh),53 dup(0Ah),4 dup(02h),0Ah,02h,42 dup(0Ah),18 dup(0FFh),25 dup(0Ah),02h,0Ah,02h,36 dup(0Ah),8 dup(0FFh)
             db 5 dup(0FFh),57 dup(0Ah),3 dup(02h),0Ah,02h,39 dup(0Ah),21 dup(0FFh),56 dup(0Ah),4 dup(02h),0Ah,02h,43 dup(0Ah),14 dup(0FFh),27 dup(0Ah),2 dup(02h),0Ah,02h,39 dup(0Ah),4 dup(0FFh)
             db 62 dup(0Ah),2 dup(02h),0Ah,02h,42 dup(0Ah),17 dup(0FFh),58 dup(0Ah),3 dup(02h),0Ah,02h,48 dup(0Ah),8 dup(0FFh),30 dup(0Ah),2 dup(02h),0Ah,02h,42 dup(0Ah)
             db 62 dup(0Ah),3 dup(02h),0Ah,02h,43 dup(0Ah),13 dup(0FFh),61 dup(0Ah),3 dup(02h),0Ah,02h,84 dup(0Ah),2 dup(02h),0Ah,02h,43 dup(0Ah)
             db 62 dup(0Ah),4 dup(02h),0Ah,02h,45 dup(0Ah),7 dup(0FFh),63 dup(0Ah),5 dup(02h),0Ah,02h,84 dup(0Ah),2 dup(02h),0Ah,02h,42 dup(0Ah)
             db 63 dup(0Ah),4 dup(02h),0Ah,02h,115 dup(0Ah),5 dup(02h),0Ah,02h,83 dup(0Ah),3 dup(02h),0Ah,02h,41 dup(0Ah)
             db 63 dup(0Ah),3 dup(02h),0Ah,02h,116 dup(0Ah),4 dup(02h),0Ah,02h,85 dup(0Ah),3 dup(02h),0Ah,02h,40 dup(0Ah)
             db 64 dup(0Ah),3 dup(02h),0Ah,02h,116 dup(0Ah),4 dup(02h),0Ah,02h,84 dup(0Ah),2 dup(02h),0Ah,02h,41 dup(0Ah)
             db 63 dup(0Ah),5 dup(02h),0Ah,02h,115 dup(0Ah),5 dup(02h),0Ah,02h,83 dup(0Ah),3 dup(02h),0Ah,02h,40 dup(0Ah)
             db 320 dup(0Ah)
             db 320 dup(0Ah)
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
avisoArtes db 'ARTES AUTORAIS'
AVISO_TAM equ $-avisoArtes
ajudaMenu db 'Setas: selecionar   Enter: confirmar'
AJUDA_TAM equ $-ajudaMenu
textoSetor db 'SETOR 1'
SETOR_TAM equ $-textoSetor
textoObjetivo db 'Salte os obstaculos e sobreviva!'
OBJETIVO_TAM equ $-textoObjetivo
textoAvanco db 'Enter: iniciar   Setas: mover/saltar'
AVANCO_TAM equ $-textoAvanco
textoTiros db 'Espaco: disparar os dois canhoes'
TIROS_TAM equ $-textoTiros
textoRetorno db 'Qualquer tecla: voltar ao menu'
RETORNO_TAM equ $-textoRetorno
textoScore db 'SCORE: '
digitosScore db SCORE_DIGITOS dup('0')
SCORE_TAM equ $-textoScore

IF (bitmapJipeFim-bitmapJipe) NE 200
 .ERR
ENDIF
IF (bitmapNave1Fim-bitmapNave1) NE 196
 .ERR
ENDIF
IF (bitmapNave2Fim-bitmapNave2) NE 196
 .ERR
ENDIF
IF (bitmapNave3Fim-bitmapNave3) NE 196
 .ERR
ENDIF
IF (bitmapVidas2-bitmapVidas3) NE 198
 .ERR
ENDIF
IF (bitmapVidas1-bitmapVidas2) NE 198
 .ERR
ENDIF
IF (bitmapRelogio-bitmapVidas1) NE 198
 .ERR
ENDIF
IF (bitmapCratera1-bitmapRelogio) NE 56
 .ERR
ENDIF
IF (bitmapCratera2-bitmapCratera1) NE 98
 .ERR
ENDIF
IF (bitmapCratera3-bitmapCratera2) NE 98
 .ERR
ENDIF
IF (bitmapRocha1-bitmapCratera3) NE 98
 .ERR
ENDIF
IF (bitmapRocha2-bitmapRocha1) NE 120
 .ERR
ENDIF
IF (bitmapRocha3-bitmapRocha2) NE 120
 .ERR
ENDIF
IF (bitmapRocha4-bitmapRocha3) NE 120
 .ERR
ENDIF
IF (bitmapsFim-bitmapRocha4) NE 120
 .ERR
ENDIF
IF (bitmapMontanhasFim-bitmapMontanhas) NE (320*64)
 .ERR
ENDIF
IF (bitmapMontesFim-bitmapMontes) NE (320*32)
 .ERR
ENDIF
pixelsTeste db 0FFh,0
indiceCaso dw 0
casos dw 319,199,2,1, 0,200,1,1, 0,0,0,1, 0,0,1,0
      dw 0,0,321,1, 0,0,1,201, 65535,0,1,1, 0,65535,1,1
quadrosRestantes dw 400
voltas dw 4 dup(0)
memOk db 'PASS MEM: dimensoes; FF transparente/00 opaco; DF; 8 invalidos;',13,10
      db 'sobreposicao; 400 quadros/2 voltas cada; fundo inteiro; guarda 1000.',13,10,'$'
memErro db 'FAIL MEM',13,10,'$'
.fardata videoTeste
    db 65000 dup(?)

.code
jumps                          ; TASM expande saltos longos em instrucoes 8086
; Funcao: iniciar video, executar telas e devolver controle ao DOS.
; Entrada: nenhuma. Saida: codigo DOS 0, modo/pagina anteriores restaurados.
; Altera: registradores, segmentos e video. Partida completa com tiros.
; Teste auxiliar: substitui somente inicio; executa rotinas reais da E02.
; Funcao: conferir sprites, limites, fundos sobrepostos e varios ciclos.
; Entrada: nenhuma. Saida: DOS 0 PASS ou DOS 1 FAIL. Altera: registradores.
inicio proc
    mov ax,@data
    mov ds,ax
    mov ax,videoTeste
    mov es,ax
    cld
    xor di,di
preencherPadrao:
    mov ax,di
    and al,0Fh
    stosb
    cmp di,64000
    jb preencherPadrao
    mov al,55h
    mov cx,1000
    rep stosb

    ; Preto opaco e transparente FFh no ultimo pixel; guarda apos 63999.
    mov ax,318
    mov bx,199
    mov cx,2
    mov dx,1
    lea si,pixelsTeste
    std
    call DesenharSprite
    pushf
    pop ax
    test ax,0400h
    jz memDFok
    jmp memFalha
memDFok:
    mov di,63998
    cmp byte ptr es:[di],0Eh
    je memTransOk
    jmp memFalha
memTransOk:
    inc di
    cmp byte ptr es:[di],0
    je memPretoOk
    jmp memFalha
memPretoOk:
    mov byte ptr es:[di],0Fh
    call ConferirPadrao
    ; Invalidos: direita, baixo, zero, dimensao excessiva e -1.
    mov indiceCaso,0
memInvalido:
    mov di,indiceCaso
    mov ax,casos[di]
    mov bx,casos[di+2]
    mov cx,casos[di+4]
    mov dx,casos[di+6]
    lea si,pixelsTeste
    std
    call DesenharSprite
    pushf
    pop ax
    test ax,0400h
    jz memInvalidoDFok
    jmp memFalha
memInvalidoDFok:
    call ConferirPadrao
    add indiceCaso,8
    cmp indiceCaso,64
    jb memInvalido

    ; Sobrepor os quatro objetos (mesmo x e y) e restaurar fundo listrado.
    mov menuY[0],100
    mov menuY[2],100
    mov menuY[4],100
    mov menuY[6],100
    call CapturarEDesenharMenu
    call ApagarSpritesMenu
    call ConferirPadrao
    ; Posicoes normais, 400 quadros: todos devem completar >=2 voltas.
    xor di,di
memPosicoes:
    mov ax,menuXInicial[di]
    mov menuX[di],ax
    add di,2
    cmp di,8
    jb memPosicoes
    mov menuY[0],100
    mov menuY[2],96
    mov menuY[4],96
    mov menuY[6],96
    call CapturarEDesenharMenu
    ; Pixels reconheciveis das artes proprias; tamanhos conferidos no TASM.
    mov di,320*100+6
    cmp byte ptr es:[di],0Fh
    jne memFalha
    mov di,320*97+80+5
    cmp byte ptr es:[di],0Bh
    jne memFalha
    mov di,320*96+160+3
    cmp byte ptr es:[di],0Bh
    jne memFalha
    mov di,320*96+240+6
    cmp byte ptr es:[di],0Dh
    jne memFalha
memQuadro:
    call MoverSpritesMenu
    xor di,di
memContarVoltas:
    mov ax,320
    sub ax,menuLarg[di]
    cmp menuX[di],ax
    ja memFalha
    cmp menuX[di],0
    jne memProximo
    inc voltas[di]
memProximo:
    add di,2
    cmp di,8
    jb memContarVoltas
    call ApagarSpritesMenu
    call ConferirPadrao
    call CapturarEDesenharMenu
    dec quadrosRestantes
    jnz memQuadro
    xor di,di
memVerVoltas:
    cmp voltas[di],2
    jb memFalha
    add di,2
    cmp di,8
    jb memVerVoltas
    call ApagarSpritesMenu
    call ConferirPadrao
    lea dx,memOk
    mov ah,09h
    int 21h
    mov ax,4C00h
    int 21h
memFalha:
    cld
    lea dx,memErro
    mov ah,09h
    int 21h
    mov ax,4C01h
    int 21h
inicio endp

; Funcao: conferir todos os pixels e os 1000 bytes de guarda.
; Entrada: ES=RAM de teste. Saida: retorna ou DOS FAIL. Altera: AX,CX,DI,flags.
ConferirPadrao proc near
    xor di,di
padraoPixel:
    mov ax,di
    and al,0Fh
    cmp es:[di],al
    jne memFalha
    inc di
    cmp di,64000
    jb padraoPixel
    mov al,55h
    mov cx,1000
    cld
    repe scasb
    jne memFalha
    ret
ConferirPadrao endp


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

; Funcao: apresentar o unico setor e aguardar Enter, escolha tecnica D04.
; Entrada: nenhuma. Saida: estado SETOR; o relogio da partida ainda nao corre.
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
    lea si,textoObjetivo
    mov cx,OBJETIVO_TAM
    mov dx,OBJETIVO_LINHA*256+(TEXTO_COLUNAS-OBJETIVO_TAM)/2
    mov bl,COR_AVISO
    call EscreverTexto
    lea si,textoAvanco
    mov cx,AVANCO_TAM
    mov dx,AVANCO_LINHA*256+(TEXTO_COLUNAS-AVANCO_TAM)/2
    mov bl,COR_BRANCO
    call EscreverTexto
    lea si,textoTiros
    mov cx,TIROS_TAM
    mov dx,TIROS_LINHA*256+(TEXTO_COLUNAS-TIROS_TAM)/2
    mov bl,COR_BRANCO
    call EscreverTexto
    ret
EntrarSetor endp

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

; Funcao: reiniciar cenario/HUD, jipe, obstaculos, naves, tiros e relogio.
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
    call ReiniciarNaves
    call ReiniciarDisparos
    call GerarGrupoNaves
    call LimparTela
    call DesenharCenario
    call DesenharObstaculos
    call DesenharNaves
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
    mov tickNave,dx
    mov tickTiro,dx
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
    push dx                    ; mesma amostra para naves, terreno, jipe e tiros
    call AtualizarCadenciaNaves ; preserva DX; nao depende da rolagem/jipe
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
    call AtualizarCadenciaDisparos ; DX preservado pelo jipe/reposicao
    call ConferirDisparos       ; alvos podem ter movido sem tick do tiro
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
    or al,navesMudou
    or al,tirosMudou
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

; Funcao: registrar make/break das setas e Espaco, inclusive simultaneas.
; Entrada: AL=scan code set 1 (bit 7=soltou), DS=dados.
; Saida: teclasJipe, pedidoTiro e pedidoSalto (nova pressao no chao).
; Altera: AX,flags e dados de entrada. Prefixos/outros scans sao ignorados.
RegistrarScanJipe proc near
    mov ah,al
    and al,7Fh
    cmp al,SCAN_ESQUERDA
    je scanEsquerda
    cmp al,SCAN_DIREITA
    je scanDireita
    cmp al,SCAN_ESPACO
    je scanEspaco
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
    jmp scanLateral
scanEspaco:
    test ah,80h
    jnz scanSoltarEspaco
    test teclasJipe,BIT_ESPACO
    jnz scanFim
    or teclasJipe,BIT_ESPACO
    cmp jipeAtivo,0
    je scanFim
    mov pedidoTiro,1
    ret
scanSoltarEspaco:
    mov al,BIT_ESPACO
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
    mov pedidoTiro,0
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
; Entrada: flags de mudanca, posicoes, ES=video. Saida: quadro atualizado.
; Altera: AX,BX,CX,DX,SI,DI,BP,flags e video. HUD preservado.
DesenharQuadroPartida proc near
    mov al,navesMudou
    or al,tirosMudou
    cmp al,0
    je quadroTerreno
    call DesenharNaves          ; recompor ceu atual, inclusive quando so nave muda
quadroTerreno:
    mov al,cenarioMudou
    or al,tirosMudou             ; movimento/remocao tambem apaga tiros no relevo
    cmp al,0
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
    call DesenharDisparos       ; depois de ceu/terreno; antes da captura do jipe
    mov tirosMudou,0
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
    mov obstImpactos[di],0
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
; Entrada: CX=limite exclusivo 1..256. Saida: AX=0..CX-1; nova semente.
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
    mov obstImpactos[di],0
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

; Funcao: somar pontos de obstaculos/naves sem wrap de word.
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
    mov pedidoTiro,0
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
    call TiroNaReposicao        ; D14: nao recriar dentro de um tiro ainda ativo
    jc reporFim
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

; Funcao: limpar as tres vagas somente ao iniciar uma nova partida.
; Entrada: nenhuma. Saida: lista vazia, sem alterar a semente compartilhada.
; Altera: DI,flags e dados das naves. Nao chamar na perda de vida.
ReiniciarNaves proc near
    xor di,di
reiniciarNaveLoop:
    mov naveAtiva[di],0
    mov naveX[di],0
    mov naveY[di],0
    add di,2
    cmp di,NAVE_MAX*2
    jb reiniciarNaveLoop
    mov naveQuantidade,0
    mov naveTipo,0
    mov tickNave,0
    mov navesMudou,1
    ret
ReiniciarNaves endp

; Funcao: contar atividade real, incluindo naves ainda entrando pela direita.
; Entrada: naveAtiva. Saida: AX=0..NAVE_MAX; preserva demais registradores.
; Altera: AX,flags. Nao usa a quantidade originalmente sorteada como contador.
ContarNavesAtivas proc near
    push di
    xor ax,ax
    xor di,di
contarNaveLoop:
    cmp naveAtiva[di],0
    je contarNaveProxima
    inc ax
contarNaveProxima:
    add di,2
    cmp di,NAVE_MAX*2
    jb contarNaveLoop
    pop di
    ret
ContarNavesAtivas endp

; Funcao: gerar um grupo homogeneo, apenas se nenhuma vaga estiver ativa.
; Entrada: lista/semente. Saida: 1..3 naves; tipo 0..2, X/Y sorteados validos.
; Altera: AX,BX,CX,DX,DI,BP,flags e dados. Sem tentativas/rejeicoes.
; D06: faixa de formacao [320,480), largura maxima de meia tela.
; BP guarda a sobra depois de reservar larguras e gaps minimos. Cada sorteio
; consome somente essa sobra; as naves restantes sempre cabem na faixa.
GerarGrupoNaves proc near
    call ContarNavesAtivas
    or ax,ax
    jnz gerarNavesFim
    mov cx,NAVE_MAX
    call Sortear
    inc ax
    mov naveQuantidade,ax
    mov bx,NAVE_LARG+NAVE_GAP_MIN
    mul bx
    mov bp,NAVE_FAIXA+NAVE_GAP_MIN
    sub bp,ax                 ; sobra = 160 - quantidade*14 - (quantidade-1)*30
    mov cx,NAVE_TIPOS
    call Sortear
    mov naveTipo,ax
    mov cx,NAVE_ENTRADA_VAR+1
    call Sortear
    sub bp,ax
    add ax,NAVE_X_INICIAL
    mov bx,ax                 ; primeira origem 320..335
    xor di,di
gerarNaveLoop:
    mov naveX[di],bx
    mov naveAtiva[di],1
    mov esperaNave[di],CADENCIA_NAVE
    mov cx,NAVE_Y_MAX-NAVE_Y_MIN+1
    call Sortear
    add ax,NAVE_Y_MIN
    mov naveY[di],ax
    add di,2
    mov ax,naveQuantidade
    shl ax,1
    cmp di,ax
    jae gerarNavesProntas
    mov cx,bp
    inc cx
    call Sortear              ; extra no gap: 0..sobra, inclusive
    sub bp,ax
    add bx,NAVE_LARG+NAVE_GAP_MIN
    add bx,ax
    jmp gerarNaveLoop
gerarNavesProntas:
    mov navesMudou,1
gerarNavesFim:
    ret
GerarGrupoNaves endp

; Funcao: remover uma nave uma unica vez (saida ou impacto de tiro).
; Entrada: DI=offset de vaga (0,2,4). Saida: CF=1 se removeu, CF=0 se nao.
; Preserva: todos os registradores. Altera: flags, atividade e navesMudou.
; Nao pontua. ConferirUmDisparo soma 100 somente se CF=1 por impacto.
RemoverNave proc near
    cmp di,NAVE_MAX*2
    jae removerNaveNao
    test di,1
    jnz removerNaveNao
    cmp naveAtiva[di],0
    je removerNaveNao
    mov naveAtiva[di],0
    mov navesMudou,1
    stc
    ret
removerNaveNao:
    clc
    ret
RemoverNave endp

; Funcao: executar um passo de todas as naves ou gerar se grupo ja vazio.
; Entrada: lista. Saida: X -= PASSO_NAVE; Y fixo; remover quando X+14<=0.
; Altera: AX,BX,CX,DX,DI,BP,flags e dados; nao altera score/vidas/relogio.
; A ultima saida permite nova geracao na proxima cadencia, nunca antes.
AtualizarNaves proc near
    call ContarNavesAtivas
    or ax,ax
    jnz moverNaves
    call GerarGrupoNaves
    ret
moverNaves:
    xor di,di
moverNaveLoop:
    cmp naveAtiva[di],0
    je moverNaveProxima
    sub naveX[di],PASSO_NAVE
    mov navesMudou,1
    cmp naveX[di],-NAVE_LARG
    jg moverNaveProxima
    call RemoverNave
moverNaveProxima:
    add di,2
    cmp di,NAVE_MAX*2
    jb moverNaveLoop
    ret
AtualizarNaves endp

; Funcao: manter cadencia independente usando a mesma amostra BIOS do laco.
; Entrada: DX=tick atual (word). Saida: passo apenas apos TICKS_NAVE.
; Altera: AX,BX,CX,DI,BP,flags e dados. Preserva DX para as outras cadencias.
AtualizarCadenciaNaves proc near
    push dx
    mov ax,dx
    sub ax,tickNave
    cmp ax,TICKS_NAVE
    jb cadenciaNaveFim
    mov tickNave,dx
    call AtualizarNaves
cadenciaNaveFim:
    pop dx
    ret
AtualizarCadenciaNaves endp

; Funcao: recompor o ceu preto atual e desenhar somente as naves ativas.
; Entrada: lista/X signed/Y inteiro em 15..86, ES=video. Saida: ceu 15..99.
; Altera: AX,BX,CX,DX,SI,DI,flags (DF=0), video; consome navesMudou.
; Sem captura antiga: fundo uniforme da E03, fora de HUD/relevo/jipe.
; DesenharQuadroPartida recompoe tiros depois deste ceu e do terreno.
DesenharNaves proc near
    cld
    mov di,HUD_ALT*TELA_LARG
    mov cx,(CENARIO_Y-HUD_ALT)*TELA_LARG
    mov al,COR_FUNDO
    rep stosb
    xor di,di
desenharNaveLoop:
    cmp naveAtiva[di],0
    je desenharNaveProxima
    mov bx,naveTipo
    shl bx,1
    mov si,naveBitmap[bx]
    mov ax,naveX[di]
    mov bx,naveY[di]
    mov cx,NAVE_LARG
    mov dx,NAVE_ALT
    call DesenharSpriteRecortado
desenharNaveProxima:
    add di,2
    cmp di,NAVE_MAX*2
    jb desenharNaveLoop
    mov navesMudou,0
    ret
DesenharNaves endp

; Funcao: limpar todos os projeteis somente na nova partida.
; Entrada: nenhuma. Saida: listas/cadencias vazias, sem alterar sorteio.
; Altera: DI,flags/dados. Morte e troca de grupo NAO chamam esta rotina.
ReiniciarDisparos proc near
    xor di,di
reiniciarTiroLoop:
    mov tiroAtivo[di],0
    mov tiroX[di],0
    mov tiroY[di],0
    mov tiroDistancia[di],0
    add di,2
    cmp di,TIRO_MAX*2
    jb reiniciarTiroLoop
    xor di,di
reiniciarEsperaNave:
    mov esperaNave[di],CADENCIA_NAVE
    add di,2
    cmp di,NAVE_MAX*2
    jb reiniciarEsperaNave
    mov esperaJipe,0
    mov tickTiro,0
    mov tirosMudou,0
    mov pedidoTiro,0
    ret
ReiniciarDisparos endp

; Funcao: procurar uma vaga livre numa faixa sem sobrescrever tiros ativos.
; Entrada: AX=offset inicial, BX=fim exclusivo (pares). Saida: DI=vaga,
; CF=1 se encontrou, CF=0 se lotado. Preserva os demais registradores.
ProcurarVagaTiro proc near
    mov di,ax
vagaTiroLoop:
    cmp tiroAtivo[di],0
    je vagaTiroAchou
    add di,2
    cmp di,bx
    jb vagaTiroLoop
    clc
    ret
vagaTiroAchou:
    stc
    ret
ProcurarVagaTiro endp

; Funcao: criar o par superior/frontal na posicao atual, inclusive no salto.
; Entrada: jipeAtivo/X/Y, listas. Saida: ambos nascem ou nenhum (CF=1/0).
; Altera: AX,BX,DI,BP,flags/dados. SI preservado. Nao altera tiros existentes.
DispararJipe proc near
    cmp jipeAtivo,0
    je dispararJipeNao
    xor ax,ax
    mov bx,TIRO_FRE_INICIO
    call ProcurarVagaTiro
    jnc dispararJipeNao
    mov bp,di
    mov ax,TIRO_FRE_INICIO
    mov bx,TIRO_INI_INICIO
    call ProcurarVagaTiro
    jnc dispararJipeNao
    mov ax,jipeX
    add ax,CANHAO_FRE_X
    mov tiroX[di],ax
    mov ax,jipeY
    add ax,CANHAO_FRE_Y
    mov tiroY[di],ax
    mov tiroDistancia[di],0
    mov tiroAtivo[di],1
    mov di,bp                  ; BP sem uso como endereco: manter DS, nao SS
    mov ax,jipeX
    add ax,CANHAO_SUP_X
    mov tiroX[di],ax
    mov ax,jipeY
    sub ax,TIRO_SUP_ALT
    mov tiroY[di],ax
    mov tiroDistancia[di],0
    mov tiroAtivo[di],1
    mov tirosMudou,1
    stc
    ret
dispararJipeNao:
    clc
    ret
DispararJipe endp

; Funcao: emitir continuamente de cada nave com canhao dentro da tela.
; Entrada: listas/esperaNave; uma chamada por atualizacao dos tiros.
; Saida: brancos independentes das naves; cheio aguarda vaga sem substituir.
; Altera: AX,BX,CX,DX,DI,BP,flags/dados. Preserva SI.
DispararNaves proc near
    push si
    xor si,si
dispararNaveLoop:
    cmp naveAtiva[si],0
    je dispararNaveProxima
    mov dx,naveX[si]
    add dx,CANHAO_NAVE_X
    cmp dx,0
    jl dispararNaveProxima
    cmp dx,TELA_LARG-TIRO_INI_LARG
    jg dispararNaveProxima
    cmp esperaNave[si],0
    je dispararNaveVaga
    dec esperaNave[si]
    jnz dispararNaveProxima
dispararNaveVaga:
    mov ax,TIRO_INI_INICIO
    mov bx,TIRO_MAX*2
    call ProcurarVagaTiro
    jnc dispararNaveProxima
    mov tiroX[di],dx
    mov ax,naveY[si]
    add ax,NAVE_ALT
    mov tiroY[di],ax
    mov tiroDistancia[di],0
    mov tiroAtivo[di],1
    mov tirosMudou,1
    mov esperaNave[si],CADENCIA_NAVE
dispararNaveProxima:
    add si,2
    cmp si,NAVE_MAX*2
    jb dispararNaveLoop
    pop si
    ret
DispararNaves endp

; Funcao: selecionar medidas/bitmap pela faixa fixa do tiro.
; Entrada: SI=offset par valido. Saida: BX=indice 0/2/4 nas tabelas.
; Preserva: demais registradores. Altera: BX,flags.
TipoDoTiro proc near
    xor bx,bx
    cmp si,TIRO_FRE_INICIO
    jb tipoTiroFim
    mov bx,2
    cmp si,TIRO_INI_INICIO
    jb tipoTiroFim
    mov bx,4
tipoTiroFim:
    ret
TipoDoTiro endp

; Funcao: sobrepor retangulos inteiros [inicio,fim), com X signed.
; Entrada: SI=tiro; AX/BX=origem alvo, CX/DX=largura/altura do alvo.
; Saida: CF=1 sobreposicao, CF=0 fora/bordas. Preserva registradores.
SobrepoeTiroAlvo proc near
    push ax
    push bx
    push cx
    push dx
    push di
    push bp
    mov di,bx                 ; Y alvo
    mov bp,ax
    add bp,cx                 ; fim X alvo
    cmp tiroX[si],bp
    jge tiroAlvoNao
    call TipoDoTiro
    mov bp,tiroX[si]
    add bp,tiroLarg[bx]
    cmp bp,ax
    jle tiroAlvoNao
    mov bp,di
    add bp,dx
    cmp tiroY[si],bp
    jge tiroAlvoNao
    mov bp,tiroY[si]
    add bp,tiroAlt[bx]
    cmp bp,di
    jle tiroAlvoNao
    stc
    jmp tiroAlvoFim
tiroAlvoNao:
    clc
tiroAlvoFim:
    pop bp
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret
SobrepoeTiroAlvo endp

; Funcao: resolver um tiro, consumindo-o no primeiro impacto ou limite.
; Entrada: SI=offset par valido, alvos atuais. Saida: atividade/vida/pontos.
; Preserva: registradores. Altera flags/dados; CF de RemoverNave lido imediato.
; Inimigo: extremidade Y+4 alcanca topo do jipe (contato incluido).
; Superficie = pista Y=193; montanhas sao fundo, nao bloqueiam disparos.
ConferirUmDisparo proc near
    cmp tiroAtivo[si],0
    je conferirTiroRet
    push ax
    push bx
    push cx
    push dx
    push di
    cmp si,TIRO_FRE_INICIO
    jae conferirTiroFrontal
    xor di,di
tiroContraNave:
    cmp naveAtiva[di],0
    je tiroNaveProxima
    mov ax,naveX[di]
    mov bx,naveY[di]
    mov cx,NAVE_LARG
    mov dx,NAVE_ALT
    call SobrepoeTiroAlvo
    jnc tiroNaveProxima
    call RemoverNave
    jnc tiroNaveProxima        ; CF antes de qualquer outra instrucao que o altere
    mov ax,PONTOS_NAVE
    call SomarPontos
    jmp consumirTiro
tiroNaveProxima:
    add di,2
    cmp di,NAVE_MAX*2
    jb tiroContraNave
    cmp tiroY[si],HUD_ALT
    jle consumirTiro
    jmp conferirTiroFim
conferirTiroFrontal:
    cmp si,TIRO_INI_INICIO
    jae conferirTiroInimigo
    xor di,di
tiroContraRocha:
    cmp obstTipo[di],OBST_LIVRE
    je tiroRochaProxima
    cmp obstTipo[di],CRATERA_TIPOS
    jb tiroRochaProxima        ; crateras nao sao alvos solidos
    mov ax,obstX[di]
    mov bx,PISTA_Y-ROCHA_ALT
    mov cx,ROCHA_LARG
    mov dx,ROCHA_ALT
    call SobrepoeTiroAlvo
    jnc tiroRochaProxima
    cmp obstTipo[di],ROCHA_1
    je consumirTiro
    inc obstImpactos[di]
    cmp obstTipo[di],ROCHA_4
    jne tiroDestruirRocha
    cmp obstImpactos[di],IMPACTOS_ROCHA4
    jb consumirTiro
tiroDestruirRocha:
    mov obstTipo[di],OBST_LIVRE
    mov cenarioMudou,1         ; recompor mesmo se nao houve rolagem
    cmp obstPassagem[di],PASS_PONTO
    je consumirTiro            ; salto OU destruicao: nunca os dois ganhos
    mov obstPassagem[di],PASS_PONTO
    mov ax,PONTOS_OBST
    call SomarPontos
    jmp consumirTiro
tiroRochaProxima:
    add di,2
    cmp di,OBST_MAX*2
    jb tiroContraRocha
    cmp tiroDistancia[si],ALCANCE_FRONTAL
    jae consumirTiro
    jmp conferirTiroFim
conferirTiroInimigo:
    cmp jipeAtivo,0
    je tiroConferirPista
    mov ax,jipeX
    mov bx,jipeY
    dec bx                    ; inclui contato da extremidade, sem folga lateral
    mov cx,JIPE_LARG
    mov dx,JIPE_ALT+1
    call SobrepoeTiroAlvo
    jnc tiroConferirPista
    call PerderVida            ; inativo impede duas vidas no mesmo evento
    jmp consumirTiro
tiroConferirPista:
    cmp tiroY[si],PISTA_Y-TIRO_INI_ALT
    jge consumirTiro
    jmp conferirTiroFim
consumirTiro:
    mov tiroAtivo[si],0
    mov tirosMudou,1
conferirTiroFim:
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
conferirTiroRet:
    ret
ConferirUmDisparo endp

; Funcao: testar tiros tambem quando apenas alvos se moveram/nasceram.
; Entrada: listas atuais. Saida: impactos/limites resolvidos antes dos saltos.
; Preserva: registradores. Altera flags/dados.
ConferirDisparos proc near
    push si
    xor si,si
conferirDisparosLoop:
    call ConferirUmDisparo
    add si,2
    cmp si,TIRO_MAX*2
    jb conferirDisparosLoop
    pop si
    ret
ConferirDisparos endp

; Funcao: mover cada tiro por passos de UM pixel, testando todo o trajeto.
; Entrada: listas ativas. Saida: posicoes/distancia/impactos, sem atravessar alvo.
; Altera: AX,BX,CX,SI,flags/dados. Nascimentos ocorrem depois deste movimento.
MoverDisparos proc near
    xor si,si
moverTiroLoop:
    call ConferirUmDisparo
    mov cx,PASSO_TIRO_SUP
    cmp si,TIRO_FRE_INICIO
    jb moverTiroPixel
    mov cx,PASSO_TIRO_FRE
    cmp si,TIRO_INI_INICIO
    jb moverTiroPixel
    mov cx,PASSO_TIRO_INI
moverTiroPixel:
    cmp tiroAtivo[si],0
    je moverTiroProximo
    mov tirosMudou,1
    cmp si,TIRO_FRE_INICIO
    jae moverTiroDireita
    dec tiroY[si]
    jmp moverTiroConferir
moverTiroDireita:
    cmp si,TIRO_INI_INICIO
    jae moverTiroBaixo
    inc tiroX[si]
    inc tiroDistancia[si]
    jmp moverTiroConferir
moverTiroBaixo:
    inc tiroY[si]
moverTiroConferir:
    call ConferirUmDisparo
    loop moverTiroPixel
moverTiroProximo:
    add si,2
    cmp si,TIRO_MAX*2
    jb moverTiroLoop
    ret
MoverDisparos endp

; Funcao: cadencia propria; mover ativos, depois emitir pares e tiros de naves.
; Entrada: DX=tick BIOS. Saida: uma atualizacao se intervalo venceu.
; Altera: AX,BX,CX,SI,DI,BP,flags/dados; preserva DX. Sem nova semente.
AtualizarCadenciaDisparos proc near
    push dx
    mov ax,dx
    sub ax,tickTiro
    cmp ax,TICKS_TIRO
    jb cadenciaTiroFim
    mov tickTiro,dx
    call MoverDisparos
    cmp esperaJipe,0
    je cadenciaTiroEntrada
    dec esperaJipe
cadenciaTiroEntrada:
    pushf
    cli
    mov al,pedidoTiro
    mov pedidoTiro,0
    mov bl,teclasJipe
    popf
    test bl,BIT_ESPACO
    jnz cadenciaTiroJipe
    or al,al
    jz cadenciaTiroNaves
cadenciaTiroJipe:
    cmp esperaJipe,0
    jne cadenciaTiroNaves
    call DispararJipe
    jnc cadenciaTiroNaves
    mov esperaJipe,CADENCIA_JIPE
cadenciaTiroNaves:
    call DispararNaves
cadenciaTiroFim:
    pop dx
    ret
AtualizarCadenciaDisparos endp

; Funcao: impedir reposicao sobre tiro inimigo, conservando D14 (area livre).
; Entrada: tiros atuais. Saida: CF=1 se X=0/Y=chao esta ocupado; CF=0 livre.
; Preserva: registradores. Nao remove tiros nem concede invulnerabilidade.
TiroNaReposicao proc near
    push ax
    push bx
    push cx
    push dx
    push si
    mov si,TIRO_INI_INICIO
tiroReposicaoLoop:
    cmp tiroAtivo[si],0
    je tiroReposicaoProximo
    mov ax,JIPE_X_INICIAL
    mov bx,JIPE_Y_CHAO-1
    mov cx,JIPE_LARG
    mov dx,JIPE_ALT+1
    call SobrepoeTiroAlvo
    jc tiroReposicaoFim
tiroReposicaoProximo:
    add si,2
    cmp si,TIRO_MAX*2
    jb tiroReposicaoLoop
    clc
tiroReposicaoFim:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
TiroNaReposicao endp

; Funcao: desenhar os tres tipos por memoria sobre fundo atual recomposto.
; Entrada: listas, ES=video; Y valido garantido por criacao/movimento/limites.
; Saida: tiros ativos, com recorte horizontal; DF=0. Altera AX,BX,CX,DX,SI,DI.
DesenharDisparos proc near
    cld
    xor di,di
desenharTiroLoop:
    cmp tiroAtivo[di],0
    je desenharTiroProximo
    mov si,di
    call TipoDoTiro
    mov cx,tiroLarg[bx]
    mov dx,tiroAlt[bx]
    mov si,tiroBitmap[bx]
    mov ax,tiroX[di]
    mov bx,tiroY[di]
    call DesenharSpriteRecortado
desenharTiroProximo:
    add di,2
    cmp di,TIRO_MAX*2
    jb desenharTiroLoop
    ret
DesenharDisparos endp

end inicio
