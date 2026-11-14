; Moon Patrol - E02: menu, telas e artes proprias autorizadas (D18).
; TASM 4.1 / TLINK, Turbo 16-bit. Fonte ASCII, instrucoes 8086.
; Jogar abre SOMENTE demonstracao: SETOR 1 -> GAME OVER (12345).
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
SCORE_DEMO       equ 12345
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
MONTES_ALT       equ 32           ; camada complementar; sem rolagem E02

.data
modoAnterior    db 3
paginaAnterior  db 0
estado          db ESTADO_MENU
opcao           db OPCAO_JOGAR
demonstracao    db 1             ; retirar ao integrar partida, nao antes
ultimoTick      dw 0
scoreFinal      dw 0
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
avisoArtes db 'DEMO E02 - ARTES AUTORAIS'
AVISO_TAM equ $-avisoArtes
ajudaMenu db 'Setas: selecionar   Enter: confirmar'
AJUDA_TAM equ $-ajudaMenu
textoSetor db 'SETOR 1'
SETOR_TAM equ $-textoSetor
textoDemo db 'DEMONSTRACAO E02 - SEM PARTIDA'
DEMO_TAM equ $-textoDemo
textoAvanco db 'Enter: demonstrar GAME OVER'
AVANCO_TAM equ $-textoAvanco
textoRetorno db 'Qualquer tecla: voltar ao menu'
RETORNO_TAM equ $-textoRetorno
textoScore db 'SCORE: '
digitosScore db SCORE_DIGITOS dup('0')
SCORE_TAM equ $-textoScore

faseTeste db 0
quadroTeste dw 0
nomeInicial db 'MENU0.RAW',0
nomeCiclo db 'MENU2.RAW',0
nomeSelecao db 'SELECAO.RAW',0
nomeSetor db 'SETOR.RAW',0
nomeFim db 'FIM.RAW',0
nomeRetorno db 'RETORNO.RAW',0
scoreEsperado db '12345'
scoreZero db '00000'
scoreMaximo db '65535'
autoOk db 'PASS AUTO: 320 quadros por ticks; cima/baixo/Enter; setor/fim/menu;',13,10
       db 'buffer antigo limpo; 2 demos; score 0/12345/65535; Sair pelo laco real.',13,10,'$'
autoErro db 'FAIL AUTO',13,10,'$'
.code
; Funcao: iniciar video, executar telas e devolver controle ao DOS.
; Entrada: nenhuma. Saida: codigo DOS 0, modo/pagina anteriores restaurados.
; Altera: registradores, segmentos e video. Nao existe partida nesta etapa.
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
    call TestarGaleria
    call EntrarMenu
    lea dx,nomeInicial
    call SalvarTelaTeste
ciclo:
    call DirigirTeste
    call LerTeclado
    cmp estado,ESTADO_SAIR
    je sair
    cmp estado,ESTADO_MENU
    jne ciclo
    call AtualizarAnimacao
    jmp ciclo
sair:
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

; Funcao: identificar o caminho sem partida enquanto demonstracao=1.
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
    mov bx,10
    mov cx,SCORE_DIGITOS
    lea di,digitosScore+SCORE_DIGITOS-1
scoreDigito:
    xor dx,dx
    div bx
    add dl,'0'
    mov [di],dl
    dec di
    loop scoreDigito
    ret
FormatarScore endp

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
    mov ax,SCORE_DEMO
    call EntrarGameOver
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
    inc quadroTeste
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

; Auxilio de teste: dirige o laco REAL por teclas no buffer BIOS.
; Funcao: testar menu -> setor -> fim -> menu -> Sair apos 320 quadros.
; Entrada: faseTeste/quadroTeste/estado. Saida: teclas, capturas ou DOS FAIL.
; Altera: registradores, buffer BIOS e arquivos de evidencia.
DirigirTeste proc near
    cmp faseTeste,0
    jne autoFase1
    cmp quadroTeste,320
    jb autoAguardar
    lea dx,nomeCiclo
    call SalvarTelaTeste
    mov cx,5000h
    call InjetarE02
    inc faseTeste
autoAguardar:
    ret
autoFase1:
    cmp faseTeste,1
    jne autoFase2
    cmp opcao,OPCAO_SAIR
    je autoSairSelecionado
    jmp autoFalha
autoSairSelecionado:
    lea dx,nomeSelecao
    call SalvarTelaTeste
    mov cx,4800h
    call InjetarE02
    inc faseTeste
    ret
autoFase2:
    cmp faseTeste,2
    jne autoFase3
    cmp opcao,OPCAO_JOGAR
    je autoJogarSelecionado
    jmp autoFalha
autoJogarSelecionado:
    mov cx,1C0Dh
    call InjetarE02
    ; Enter antigo adicional deve ser descartado ao entrar no setor.
    mov cx,1C0Dh
    call InjetarE02
    inc faseTeste
    ret
autoFase3:
    cmp faseTeste,3
    jne autoFase4
    cmp estado,ESTADO_SETOR
    je autoSetorOk
    jmp autoFalha
autoSetorOk:
    call ConferirBufferVazio
    lea dx,nomeSetor
    call SalvarTelaTeste
    mov cx,1C0Dh
    call InjetarE02
    mov cx,1C0Dh
    call InjetarE02
    inc faseTeste
    ret
autoFase4:
    cmp faseTeste,4
    jne autoFase5
    cmp estado,ESTADO_FIM
    je autoFimOk
    jmp autoFalha
autoFimOk:
    call ConferirBufferVazio
    cmp scoreFinal,SCORE_DEMO
    je autoScoreOk
    jmp autoFalha
autoScoreOk:
    lea si,digitosScore
    lea di,scoreEsperado
    call ConferirDigitos
    lea dx,nomeFim
    call SalvarTelaTeste
    mov cx,1E61h
    call InjetarE02
    inc faseTeste
    ret
autoFase5:
    cmp faseTeste,5
    je autoTestarRetorno
    jmp autoFase6
autoTestarRetorno:
    cmp estado,ESTADO_MENU
    je autoRetornoOk
    jmp autoFalha
autoRetornoOk:
    cmp scoreFinal,0
    je autoResetScoreOk
    jmp autoFalha
autoResetScoreOk:
    cmp opcao,OPCAO_JOGAR
    je autoResetOpcaoOk
    jmp autoFalha
autoResetOpcaoOk:
    lea dx,nomeRetorno
    call SalvarTelaTeste
    ; Letra/Esq/Esc nao alteram selecao nem encerram o menu.
    mov cx,1E61h
    call InjetarE02
    call LerTeclado
    mov cx,4B00h
    call InjetarE02
    call LerTeclado
    mov cx,011Bh
    call InjetarE02
    call LerTeclado
    cmp estado,ESTADO_MENU
    je autoIgnoradasOk
    jmp autoFalha
autoIgnoradasOk:
    cmp opcao,OPCAO_JOGAR
    je autoIgnoradasOpcaoOk
    jmp autoFalha
autoIgnoradasOpcaoOk:
    ; Segunda demonstracao: seta (ASCII zero) tambem retorna do fim.
    mov cx,1C0Dh
    call InjetarE02
    call LerTeclado
    mov cx,1C0Dh
    call InjetarE02
    call LerTeclado
    cmp scoreFinal,SCORE_DEMO
    je autoSegundaOk
    jmp autoFalha
autoSegundaOk:
    mov cx,4800h
    call InjetarE02
    call LerTeclado
    cmp estado,ESTADO_MENU
    je autoSetaRetornoOk
    jmp autoFalha
autoSetaRetornoOk:
    ; Extremos da conversao unsigned, sem alterar o fluxo normal.
    xor ax,ax
    call FormatarScore
    lea si,digitosScore
    lea di,scoreZero
    call ConferirDigitos
    mov ax,65535
    call FormatarScore
    lea si,digitosScore
    lea di,scoreMaximo
    call ConferirDigitos
    mov cx,5000h
    call InjetarE02
    inc faseTeste
    ret
autoFase6:
    cmp opcao,OPCAO_SAIR
    je autoFinalizar
    jmp autoFalha
autoFinalizar:
    mov cx,1C0Dh
    call InjetarE02
    ret
DirigirTeste endp

; Funcao: comparar cinco caracteres. Entrada: DS:SI e DS:DI.
; Saida: retorna ou DOS FAIL. Altera: AX,CX,SI,DI,flags.
ConferirDigitos proc near
    mov cx,5
autoDigito:
    mov al,[si]
    cmp al,[di]
    jne autoFalha
    inc si
    inc di
    loop autoDigito
    ret
ConferirDigitos endp

; Funcao: confirmar descarte das teclas antigas.
; Entrada: buffer BIOS. Saida: retorna ou FAIL. Altera: AX,flags.
ConferirBufferVazio proc near
    mov ah,01h
    int 16h
    jnz autoFalha
    ret
ConferirBufferVazio endp

; Funcao: inserir tecla BIOS. Entrada: CH=scan, CL=ASCII.
; Saida: tecla inserida ou FAIL. Altera: AX,flags.
InjetarE02 proc near
    mov ah,05h
    int 16h
    cmp al,0
    jne autoFalha
    ret
InjetarE02 endp

; Funcao: guardar os 64000 bytes REAIS de A000h para analise externa.
; Entrada: DS:DX=nome ASCIIZ, ES=A000h. Saida: arquivo RAW.
; Altera: AX,BX,CX,DX,flags; preserva DS,ES.
SalvarTelaTeste proc near
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
SalvarTelaTeste endp

autoFalha:
    mov ax,3
    int 10h
    lea dx,autoErro
    mov ah,09h
    int 21h
    mov ax,4C01h
    int 21h

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

end inicio
