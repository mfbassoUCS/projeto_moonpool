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
TRANSPARENTE     equ 0FFh
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
TICKS_MOVIMENTO  equ 2
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

DURACAO_SEGUNDOS equ 90
VIDAS_INICIAIS   equ 3
TICKS_CENARIO    equ 1
PASSO_CENARIO    equ 1
CENARIO_Y       equ 100
MONTES_Y        equ 132
PISTA_ALT       equ 7
PISTA_Y         equ TELA_ALT-PISTA_ALT
COR_PISTA       equ 0Eh
HUD_ALT         equ 15
HUD_VIDAS_X     equ (TELA_LARG-VIDAS_LARG)/2
HUD_VIDAS_Y     equ 2
HUD_RELOGIO_X   equ 280
HUD_RELOGIO_Y   equ 3
HUD_SCORE_POS   equ 0
TEMPO_DIGITOS   equ 3
HUD_TEMPO_POS   equ TEXTO_COLUNAS-TEMPO_DIGITOS
CENT_POR_SEG    equ 100
MARGEM_RELOGIO  equ 6
CENT_DIA_BAIXO  equ 0D600h
CENT_DIA_ALTO   equ 0083h
SCORE_DIGITOS    equ 5
TITULO_LINHA     equ 2
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

JIPE_X_INICIAL  equ 0
JIPE_X_MAX      equ TELA_LARG/2-JIPE_LARG
JIPE_Y_CHAO     equ PISTA_Y-JIPE_ALT
TICKS_JIPE      equ 1
PASSO_JIPE      equ 5

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

NAVE_MAX         equ 3
NAVE_TIPOS       equ 3
NAVE_Y_MIN       equ HUD_ALT
NAVE_Y_MAX       equ CENARIO_Y-NAVE_ALT
NAVE_GAP_MIN     equ 30
NAVE_FAIXA       equ TELA_LARG/2
NAVE_X_INICIAL   equ TELA_LARG
NAVE_ENTRADA_VAR equ 15
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
MONTANHAS_ALT    equ 64
MONTES_LARG      equ 320
MONTES_ALT       equ 32

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
IF (SALTO_TOPO_PX MOD PASSO_CENARIO) NE 0
 .ERR
ENDIF
IF (TICKS_CENARIO MOD TICKS_JIPE) NE 0
 .ERR
ENDIF
IF (PASSO_JIPE LT 1) OR (PASSO_JIPE GT JIPE_X_MAX) OR (PASSO_NAVE LT 1)
 .ERR
ENDIF
IF (PASSO_JIPE*TICKS_NAVE LE PASSO_NAVE*TICKS_JIPE)
 .ERR
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
 .ERR
ENDIF

OBST_MAX        equ 8
OBST_LIVRE      equ 0FFFFh
CRATERA_TIPOS   equ 3
ROCHA_TIPOS     equ 4
CRATERA_GAP_MIN equ 150
CRATERA_GAP_VAR equ 80
ROCHA_FOLGA     equ 60
PONTOS_OBST     equ 50
SCORE_MAX       equ 65535
PASS_NOVO      equ 0
PASS_FRENTE    equ 1
PASS_SOBRE     equ 2
PASS_CRUZOU    equ 3
PASS_PONTO     equ 4
PASS_INVALIDO  equ 5

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
CANHAO_SUP_X    equ 6
CANHAO_FRE_X    equ JIPE_LARG
CANHAO_FRE_Y    equ 4
CANHAO_NAVE_X   equ (NAVE_LARG-TIRO_INI_LARG)/2
TICKS_TIRO      equ 1
PASSO_TIRO_SUP  equ 4
PASSO_TIRO_FRE  equ 4
PASSO_TIRO_INI  equ 2
CADENCIA_JIPE   equ 6
CADENCIA_NAVE   equ 18
ALCANCE_FRONTAL equ 50
PONTOS_NAVE     equ 100
ROCHA_1        equ CRATERA_TIPOS
ROCHA_4        equ CRATERA_TIPOS+3
IMPACTOS_ROCHA4 equ 2
IF (TICKS_TIRO LT 1) OR (CADENCIA_JIPE LT 1) OR (CADENCIA_NAVE LT 1)
 .ERR
ENDIF
IF (PASSO_TIRO_SUP LT 1) OR (PASSO_TIRO_FRE LT 1) OR (PASSO_TIRO_INI LT 1)
 .ERR
ENDIF
IF (TIRO_SUP_MAX LT 1) OR (TIRO_FRE_MAX LT 1) OR (TIRO_INI_MAX LT NAVE_MAX)
 .ERR
ENDIF

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
scorePartida    dw 0
vidas           db VIDAS_INICIAIS
tempoRestante   dw DURACAO_SEGUNDOS
rolagem         dw 0
tickCenario     dw 0
tempoAnteriorLo dw 0
tempoAnteriorHi dw 0
fracaoSegundo   dw 0
margemInicial   dw 0
digitosTempo    db TEMPO_DIGITOS dup('0')
linhaCenario    db TELA_LARG dup(?)
jipeX          dw JIPE_X_INICIAL
jipeY          dw JIPE_Y_CHAO
jipeDesenhoX    dw 0
jipeDesenhoY    dw 0
tickJipe       dw 0
estadoSalto    db SALTO_CHAO
pixelsTopo     dw 0
teclasJipe     db 0
pedidoSalto    db 0
tecladoJogoAtivo db 0
vetorTeclado   dw 0,0
cenarioMudou   db 0
jipeMudou      db 0
fundoPartida   db JIPE_BYTES dup(?)

obstX           dw OBST_MAX dup(0)
obstTipo        dw OBST_MAX dup(OBST_LIVRE)
obstPassagem    dw OBST_MAX dup(PASS_NOVO)
obstImpactos    dw OBST_MAX dup(0)
tipoLarg        dw 3 dup(CRATERA_LARG),4 dup(ROCHA_LARG)
tipoAlt         dw 3 dup(CRATERA_ALT),4 dup(ROCHA_ALT)
tipoY           dw 3 dup(PISTA_Y),4 dup(PISTA_Y-ROCHA_ALT)
tipoBitmap      dw offset bitmapCratera1,offset bitmapCratera2,offset bitmapCratera3
                dw offset bitmapRocha1,offset bitmapRocha2,offset bitmapRocha3,offset bitmapRocha4
semente         dw 1
proximoEm       dw 0
proximaRocha    db 0
ateCratera      dw 0
jipeAtivo       db 1
jipeNaTela      db 0
statusMudou     db 0

naveX           dw NAVE_MAX dup(0)
naveY           dw NAVE_MAX dup(0)
naveAtiva       dw NAVE_MAX dup(0)
naveQuantidade  dw 0
naveTipo        dw 0
naveBitmap      dw offset bitmapNave1,offset bitmapNave2,offset bitmapNave3
tickNave        dw 0
navesMudou      db 0

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
pedidoTiro      db 0
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

bitmapRelogio db 2 dup(0FFh),3 dup(0Eh),2 dup(0FFh)
              db 0FFh,0Eh,3 dup(00h),0Eh,0FFh
              db 0Eh,2 dup(00h),0Eh,2 dup(00h),0Eh
              db 0Eh,2 dup(00h),0Eh,2 dup(00h),0Eh
              db 0Eh,2 dup(00h),2 dup(0Eh),00h,0Eh
              db 0Eh,5 dup(00h),0Eh
              db 0FFh,0Eh,3 dup(00h),0Eh,0FFh
              db 2 dup(0FFh),3 dup(0Eh),2 dup(0FFh)
bitmapRelogioFim label byte

bitmapCratera1 db 3 dup(0FFh),8 dup(06h),3 dup(0FFh)
               db 0FFh,2 dup(06h),8 dup(08h),2 dup(06h),0FFh
               db 06h,08h,10 dup(00h),08h,06h
               db 06h,12 dup(00h),06h
               db 0FFh,06h,08h,8 dup(00h),08h,06h,0FFh
               db 2 dup(0FFh),2 dup(06h),6 dup(08h),2 dup(06h),2 dup(0FFh)
               db 4 dup(0FFh),6 dup(06h),4 dup(0FFh)
bitmapCratera1Fim label byte

bitmapCratera2 db 0FFh,3 dup(06h),4 dup(0FFh),3 dup(06h),3 dup(0FFh)
               db 06h,08h,2 dup(00h),4 dup(06h),08h,00h,08h,2 dup(06h),0FFh
               db 06h,11 dup(00h),08h,06h
               db 06h,08h,11 dup(00h),06h
               db 0FFh,06h,08h,8 dup(00h),08h,06h,0FFh
               db 2 dup(0FFh),2 dup(06h),08h,3 dup(00h),08h,3 dup(06h),2 dup(0FFh)
               db 4 dup(0FFh),5 dup(06h),5 dup(0FFh)
bitmapCratera2Fim label byte

bitmapCratera3 db 6 dup(0FFh),4 dup(06h),4 dup(0FFh)
               db 3 dup(0FFh),3 dup(06h),08h,2 dup(00h),08h,2 dup(06h),2 dup(0FFh)
               db 0FFh,2 dup(06h),08h,7 dup(00h),08h,06h,0FFh
               db 06h,08h,10 dup(00h),08h,06h
               db 06h,10 dup(00h),08h,06h,0FFh
               db 0FFh,2 dup(06h),08h,4 dup(00h),08h,3 dup(06h),2 dup(0FFh)
               db 3 dup(0FFh),6 dup(06h),5 dup(0FFh)
bitmapCratera3Fim label byte

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

arteTitulo db '                     _                 '
           db ' |\/|  _   _  ._    |_) _. _|_ ._ _  | '
           db ' |  | (_) (_) | |   |  (_|  |_ | (_) | '
           db '                                       '
TITULO_LARG equ 39
TITULO_ALT equ 4

arteGame db '   ___   _   __  __ ___ '
           db '  / __| /_\ |  \/  | __|'
           db ' | (_ |/ _ \| |\/| | _| '
           db '  \___/_/ \_\_|  |_|___|'
           db '                        '
GAME_LARG equ 24
GAME_ALT equ 5

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

.code
jumps

; Funcao: iniciar video, executar telas e devolver controle ao DOS.
; Entrada: nenhuma.
; Saida: codigo DOS 0, modo/pagina anteriores restaurados.
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
; Entrada: ES=video.
; Saida: 64000 bytes pretos.
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
; Saida: texto na pagina 0.
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
; Saida: bloco no video.
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
; Entrada: buffer BIOS.
; Saida: buffer vazio.
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
; Entrada: DS=dados, ES=video.
; Saida: estado MENU, Jogar selecionado.
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
; Entrada: opcao.
; Saida: selecionada 0Ch, outra 0Fh.
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

; Funcao: apresentar o unico setor e aguardar Enter.
; Entrada: nenhuma.
; Saida: estado SETOR; o relogio da partida ainda nao corre.
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
EntrarGameOver proc near
    call RestaurarTecladoJogo
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
; Entrada: AX=numero unsigned.
; Saida: digitosScore.
FormatarScore proc near
    mov cx,SCORE_DIGITOS
    lea di,digitosScore+SCORE_DIGITOS-1
    call FormatarNumero
    ret
FormatarScore endp

; Funcao: converter inteiro unsigned em campo decimal de largura fixa.
; Entrada: AX=valor, CX=digitos, DS:DI=ultimo caractere (campo suficiente).
; Saida: campo preenchido com zeros iniciais.
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
; Entrada: estado, opcao e buffer BIOS.
; Saida: transicao ou selecao atualizada.
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
; Entrada: ultimoTick, ES=video.
; Saida: posicoes/quadro atualizados se venceu.
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
; Entrada: DI=indice em bytes (0,2,4,6).
; Saida: AX=x,BX=y,CX=larg,DX=alt, DS:SI=bitmap.
CarregarSpriteMenu proc near
    mov ax,menuX[di]
    mov bx,menuY[di]
    mov cx,menuLarg[di]
    mov dx,menuAlt[di]
    mov si,menuBitmap[di]
    ret
CarregarSpriteMenu endp

; Funcao: salvar TODOS os fundos limpos e so depois desenhar os objetos.
; Entrada: tabelas do menu; ES=video sem sprites.
; Saida: buffers e video.
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
; Entrada: posicoes anteriores e buffers, ES=video.
; Saida: fundo restaurado.
ApagarSpritesMenu proc near
    xor di,di
apagarMenu:
    call CarregarSpriteMenu
    mov si,menuFundo[di]
    call DesenharBitmap
    add di,2
    cmp di,MENU_QUANT*2
    jb apagarMenu
    ret
ApagarSpritesMenu endp

; Funcao: restaurar, mover, capturar fundos e desenhar um quadro do menu.
; Entrada: tabelas/buffers, ES=video.
; Saida: x avanca; volta inteiro a x=0.
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
    xor ax,ax
moverGuardar:
    mov menuX[di],ax
    add di,2
    cmp di,MENU_QUANT*2
    jb moverMenu
    call CapturarEDesenharMenu
    ret
MoverSpritesMenu endp

; Funcao: reiniciar cenario/HUD, jipe, obstaculos, naves, tiros e relogio.
; Entrada: DS=dados, ES=video.
; Saida: estado PARTIDA, valores reiniciados.
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
; Entrada: estado PARTIDA, relogios/dados, ES=video.
; Saida: quadro ou FIM.
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
    push dx
    call AtualizarCadenciaNaves
    mov ax,dx
    sub ax,tickCenario
    cmp ax,TICKS_CENARIO
    jb partidaJipe
    mov tickCenario,dx
    call AvancarCenario
    call AvancarObstaculos
    mov cenarioMudou,1
    mov ax,PASSO_CENARIO
    call ContarTopo
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
    call AtualizarCadenciaDisparos
    call ConferirDisparos
    call ConferirObstaculos
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
    mov ax,scorePartida
    call EntrarGameOver
    ret
AtualizarPartida endp

; Funcao: restaurar somente os dados do jipe para uma nova partida.
; Entrada: nenhuma.
; Saida: posicao inicial, chao, sem teclas/pedido pendente.
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
    jnz scanFim
    or teclasJipe,BIT_CIMA
    cmp jipeAtivo,0
    je scanFim
    cmp estadoSalto,SALTO_CHAO
    jne scanFim
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
; Entrada: hardware porta 60h.
; Saida: teclas/pedido; IRET retoma interrompido.
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
    out 20h,al
    pop ds
    pop ax
    iret
TecladoJogoIRQ endp

; Funcao: guardar INT 09h BIOS e instalar leitura de pressao/soltura.
; Entrada: DS=dados, tecladoJogoAtivo=0.
; Saida: vetor ativo durante partida.
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
; Entrada: DS=dados, vetor guardado.
; Saida: teclado BIOS restaurado.
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
; Entrada: teclas/pedido, posicao/fase.
; Saida: X/Y/fase e jipeMudou (0/1).
AtualizarJipe proc near
    mov jipeMudou,0
    pushf
    cli
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
    jne jipeVertical
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

; Funcao: contar distancia do terreno depois de chegar ao topo.
; Entrada: AX=pixels efetivamente avancados; estadoSalto/pixelsTopo.
; Saida: inicia descida ao atingir 5 pixels; saturacao defensiva para chamadas.
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
; Entrada: jipeX/Y validos, ES=fundo sem jipe.
; Saida: buffer/posicao e sprite.
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
; Entrada: flags de mudanca, posicoes, ES=video.
; Saida: quadro atualizado.
DesenharQuadroPartida proc near
    mov al,navesMudou
    or al,tirosMudou
    cmp al,0
    je quadroTerreno
    call DesenharNaves
quadroTerreno:
    mov al,cenarioMudou
    or al,tirosMudou
    cmp al,0
    je quadroSoJipe
    call DesenharCenario
    call DesenharObstaculos
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
    call DesenharDisparos
    mov tirosMudou,0
    cmp jipeAtivo,0
    je quadroFim
    call CapturarEDesenharJipe
quadroFim:
    ret
DesenharQuadroPartida endp

; Funcao: obter hora DOS completa em centesimos, incluindo horas e minutos.
; Entrada: nenhuma.
; Saida: DX:AX=0..8639999.
LerCentissegundos proc near
    push bx
    push cx
    push si
    mov ah,2Ch
    int 21h
    push dx
    xor ax,ax
    mov al,ch
    mov bx,60
    mul bx
    xor ch,ch
    add ax,cx
    mul bx
    pop cx
    xor bx,bx
    mov bl,ch
    add ax,bx
    adc dx,0
    mov si,dx
    mov bx,CENT_POR_SEG
    mul bx

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
ConsumirTempo proc near

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
    cmp dx,bx
    jae tempoEsgotou
    div bx
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
; Entrada: rolagem 0..319.
; Saida: rolagem=(rolagem+PASSO_CENARIO) mod 320.
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
ComporLinhaCircular proc near
    push es
    push ds
    pop es
    push ax
    push cx
    push si
    push di
    push bp
    cld
    mov bp,si
    add bp,TELA_LARG
    add si,rolagem
    lea di,linhaCenario
    mov cx,TELA_LARG
comporPixel:
    lodsb
    cmp al,TRANSPARENTE
    je comporTransparente
    stosb
    jmp comporAvancarFonte
comporTransparente:
    inc di
comporAvancarFonte:
    cmp si,bp
    jb comporProximo
    sub si,TELA_LARG
comporProximo:
    loop comporPixel
    pop bp
    pop di
    pop si
    pop cx
    pop ax
    pop es
    ret
ComporLinhaCircular endp

; Funcao: recompor terreno em memoria e copiar linhas prontas para o video.
; Entrada: rolagem, DS=dados, ES=video.
; Saida: y=100..192 e pista 193..199.
DesenharCenario proc near
    cld
    mov bp,CENARIO_Y
    mov di,CENARIO_Y*TELA_LARG
cenarioLinha:
    cmp bp,CENARIO_Y+MONTANHAS_ALT
    jae cenarioCopiar
    push di
    push es
    push ds
    pop es
    lea di,linhaCenario
    mov cx,TELA_LARG
    mov al,COR_FUNDO
    rep stosb
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
    rep movsb
    inc bp
    cmp bp,PISTA_Y
    jb cenarioLinha
    mov al,COR_PISTA
    mov cx,TELA_LARG*PISTA_ALT
    rep stosb
    ret
DesenharCenario endp

; Funcao: desenhar score esquerdo, vidas centrais e tempo direito.
; Entrada: scorePartida, vidas=0..3, tempoRestante=0..999, ES=video.
; Saida: barra y=0..14, sem digitos/sprites antigos. Zero vidas limpa o icone.
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
; Saida: CF=0 valido: DI=y*320+x, BP=altura, BX=salto entre linhas. CF=1 invalido, nao acessar video. Nao ha recorte parcial.
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
    mul bx
    add di, ax
    sub bx, cx
    clc
    ret
retanguloInvalido:
    stc
    ret
PrepararRetangulo endp

; Funcao: copiar bitmap opaco linha a linha para o video.
; Entrada: DS:SI=bitmap, ES=VIDEO_SEG, AX=x,BX=y,CX=largura,DX=altura. Origem deve conter largura*altura bytes no segmento DS.
; Saida: retangulo desenhado; coordenadas invalidas nao escrevem nada.
DesenharBitmap proc near
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp
    cld
    call PrepararRetangulo
    jc desenhoFim
desenhoLinha:
    push cx
    rep movsb
    pop cx
    add di, bx
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

; Funcao: guardar fundo com REP MOVSB antes de colocar um bitmap sobre ele.
; Entrada: DS:SI=buffer de largura*altura bytes; demais como DesenharBitmap.
; Saida: fundo salvo no buffer; coordenadas invalidas nao copiam nada.
SalvarFundo proc near
    push ds
    push es
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp
    call PrepararRetangulo
    jc salvarFim
    cld
    mov ax,ds
    mov dx,es
    mov ds,dx
    mov es,ax
    xchg si,di
salvarLinha:
    push cx
    rep movsb
    pop cx
    add si, bx
    dec bp
    jnz salvarLinha
salvarFim:
    cld
    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop es
    pop ds
    ret
SalvarFundo endp

; Funcao: desenhar bitmap com transparencia FFh, sem recorte parcial.
; Entrada: como DesenharBitmap; DS:SI contem largura*altura bytes.
; Saida: FFh preserva fundo, 00h desenha preto; invalido nao escreve.
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
    stosb
    jmp spriteProximo
spriteTransparente:
    inc di
spriteProximo:
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
; Entrada: nenhuma.
; Saida: lista vazia, semente dos ticks, primeira cratera.
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
; Entrada: CX=limite exclusivo 1..256.
; Saida: AX=0..CX-1; nova semente.
Sortear proc near
    push bx
    mov ax,semente
    mov bx,25173
    mul bx
    add ax,13849
    mov semente,ax
    mov al,ah
    xor ah,ah
    xor dx,dx
    div cx
    mov ax,dx
    pop bx
    ret
Sortear endp

; Funcao: mover todos com o terreno e gerar C,R,C em distancias sorteadas.
; Entrada: lista/proximoEm.
; Saida: X -= PASSO_CENARIO; novos pela direita.
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
    add ax,CRATERA_GAP_MIN
    mov bx,ax
    add bx,CRATERA_LARG
    sub ax,2*ROCHA_FOLGA+ROCHA_LARG
    inc ax
    mov cx,ax
    call Sortear
    add ax,CRATERA_LARG+ROCHA_FOLGA
    sub bx,ax
    mov ateCratera,bx
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
; Entrada: DI=entrada ativa, jipeX.
; Saida: CF=1 sobrepoe; BX=tipo*2, AX=fim exclusivo do obstaculo.
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

; Funcao: colisao tem prioridade; depois acompanhar travessias por salto.
; Entrada: posicoes apos movimento (ou pouso).
; Saida: vida/pontos/marcadores.
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
    cmp jipeY,JIPE_Y_CHAO
    jb conferirColProximo
    jmp conferirMorte
conferirRocha:
    mov ax,jipeY
    add ax,JIPE_ALT
    cmp ax,PISTA_Y-ROCHA_ALT
    jbe conferirColProximo
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
    mov obstPassagem[di],PASS_FRENTE
    jmp conferirPassProximo
passagemSobre:
    cmp estadoSalto,SALTO_CHAO
    je conferirPassProximo
    cmp obstPassagem[di],PASS_FRENTE
    jb conferirPassProximo
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
; Entrada: AX=ganho unsigned.
; Saida: scorePartida <=65535, statusMudou=1.
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
; Entrada: jipeAtivo/vidas.
; Saida: uma vida a menos, travessias canceladas.
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

; Funcao: reaparecer no proximo tick do jipe com x=0 LIVRE.
; Entrada: jipe ausente/vidas/lista.
; Saida: posicao/fase reiniciadas se seguro.
TentarReporJipe proc near
    cmp vidas,0
    je reporFim
    call TiroNaReposicao
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
; Entrada: lista e marcadores.
; Saida: vagas livres; travessia espera pouso.
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
; Entrada: tabelas, ES=video.
; Saida: obstaculos visiveis; sem fundos antigos.
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
DesenharSpriteRecortado proc near
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp
    cld
    mov bp,cx
    cmp ax,0
    jge recorteDireita
    neg ax
    cmp ax,cx
    jae recorteFim
    add si,ax
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
    sub bp,cx
    push bp
    call PrepararRetangulo
    pop dx
    jc recorteFim
recorteLinha:
    push cx
recortePixel:
    lodsb
    cmp al,TRANSPARENTE
    je recorteTransparente
    stosb
    jmp recorteProximo
recorteTransparente:
    inc di
recorteProximo:
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
; Entrada: nenhuma.
; Saida: lista vazia, sem alterar a semente compartilhada.
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
; Entrada: naveAtiva.
; Saida: AX=0..NAVE_MAX; preserva demais registradores.
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
; Entrada: lista/semente.
; Saida: 1..3 naves; tipo 0..2, X/Y sorteados validos.
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
    sub bp,ax
    mov cx,NAVE_TIPOS
    call Sortear
    mov naveTipo,ax
    mov cx,NAVE_ENTRADA_VAR+1
    call Sortear
    sub bp,ax
    add ax,NAVE_X_INICIAL
    mov bx,ax
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
    call Sortear
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
; Entrada: DI=offset de vaga (0,2,4).
; Saida: CF=1 se removeu, CF=0 se nao.
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
; Entrada: lista.
; Saida: X -= PASSO_NAVE; Y fixo; remover quando X+14<=0.
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
; Entrada: DX=tick atual (word).
; Saida: passo apenas apos TICKS_NAVE.
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
; Entrada: lista/X signed/Y inteiro em 15..86, ES=video.
; Saida: ceu 15..99.
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
; Entrada: nenhuma.
; Saida: listas/cadencias vazias, sem alterar sorteio.
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
; Entrada: AX=offset inicial, BX=fim exclusivo (pares).
; Saida: DI=vaga, CF=1 se encontrou, CF=0 se lotado. Preserva os demais registradores.
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
; Entrada: jipeAtivo/X/Y, listas.
; Saida: ambos nascem ou nenhum (CF=1/0).
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
    mov di,bp
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
; Entrada: SI=offset par valido.
; Saida: BX=indice 0/2/4 nas tabelas.
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
    mov di,bx
    mov bp,ax
    add bp,cx
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
; Entrada: SI=offset par valido, alvos atuais.
; Saida: atividade/vida/pontos.
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
    jnc tiroNaveProxima
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
    jb tiroRochaProxima
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
    mov cenarioMudou,1
    cmp obstPassagem[di],PASS_PONTO
    je consumirTiro
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
    dec bx
    mov cx,JIPE_LARG
    mov dx,JIPE_ALT+1
    call SobrepoeTiroAlvo
    jnc tiroConferirPista
    call PerderVida
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
; Entrada: listas atuais.
; Saida: impactos/limites resolvidos antes dos saltos.
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
; Entrada: listas ativas.
; Saida: posicoes/distancia/impactos, sem atravessar alvo.
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
; Entrada: DX=tick BIOS.
; Saida: uma atualizacao se intervalo venceu.
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

; Funcao: impedir reposicao sobre tiro inimigo, conservando (area livre).
; Entrada: tiros atuais.
; Saida: CF=1 se X=0/Y=chao esta ocupado; CF=0 livre.
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
