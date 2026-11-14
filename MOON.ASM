; Moon Patrol - E09: revisao da versao completa implementada na E08.
; TASM 4.1 / TLINK, Turbo 16-bit. Fonte ASCII, instrucoes 8086.
; Menu -> SETOR 1 -> partida -> fim por tempo ou vidas. Uma unica fase.
.8086 ; Restringe instrucoes ao 8086, mantendo a compatibilidade exigida.
.model small ; Separa codigo e dados em segmentos de ate 64 KiB cada; DS e ES precisam ser preparados.
.stack 100h ; Reserva 256 bytes para retornos de CALL, PUSH e interrupcoes; 100h e hexadecimal.

VIDEO_MODO       equ 13h ; Modo VGA 13h: 320x200 pixels e 256 indices de cor; simplifica o desenho por bytes.
VIDEO_SEG        equ 0A000h ; Segmento A000h da memoria de video; ES usa esse valor para escrever pixels.
TELA_LARG        equ 320 ; 320 pixels por linha; usado tambem na conta do endereco y*320+x.
TELA_ALT         equ 200 ; 200 linhas; limita o desenho para nao escrever fora da tela.
TELA_BYTES       equ TELA_LARG * TELA_ALT ; 320*200=64000 bytes: um byte por pixel, cabendo em um segmento de 64 KiB.
TEXTO_COLUNAS    equ 40 ; 40 caracteres por linha no modo escolhido; permite centralizar os textos.
COR_FUNDO        equ 00h ; Indice preto para limpar a tela e o ceu.
COR_TITULO       equ 0Ah ; Verde-claro do titulo pedido no enunciado.
COR_SELECAO      equ 0Ch ; Vermelho-claro distingue a opcao selecionada no menu.
COR_BRANCO       equ 0Fh ; Branco usado nas instrucoes e na opcao nao selecionada.
COR_GAMEOVER     equ 04h ; Vermelho 04h escolhido para GAME OVER, conforme decisao D17.
COR_AVISO        equ 0Eh ; Amarelo destaca avisos e o objetivo do setor.
TRANSPARENTE     equ 0FFh         ; preto 00h continua sendo pixel opaco | FFh e uma convencao do desenhador: pular o pixel e preservar o fundo.
TECLA_ENTER      equ 13 ; Codigo ASCII 13 (decimal), usado para confirmar as telas.
SCAN_CIMA        equ 48h ; Codigo fisico da seta para cima; seleciona no menu e pede salto no jogo.
SCAN_BAIXO       equ 50h ; Codigo fisico da seta para baixo; alterna a opcao do menu.
SCAN_ESQUERDA    equ 4Bh ; Codigo fisico da seta esquerda; permite reconhecer pressao e soltura.
SCAN_DIREITA     equ 4Dh ; Codigo fisico da seta direita; permite reconhecer pressao e soltura.
BIT_ESQUERDA    equ 1 ; Bit 0 da mascara de teclas: esquerda mantida, sem apagar as outras teclas.
BIT_DIREITA     equ 2 ; Bit 1 da mascara: direita mantida; pode coexistir com salto e tiro.
BIT_CIMA        equ 4 ; Bit 2 da mascara: impede interpretar a repeticao de cima como novo salto.
SCAN_ESPACO     equ 39h ; Codigo fisico do Espaco; aciona os dois canhoes na E08.
BIT_ESPACO      equ 8 ; Bit 3 da mascara: permite repetir tiros enquanto Espaco fica pressionado.
TICKS_MOVIMENTO  equ 2            ; mesma cadencia da E01 (~110 ms) | Intervalo da animacao do menu em pulsos BIOS; nao controla a duracao da partida.
PASSO_MENU       equ 2 ; Distancia horizontal dos desenhos a cada atualizacao do menu.
MENU_QUANT       equ 4 ; Quatro desenhos animados: um jipe e tres naves; usam a mesma rotina.
MENU_Y          equ 96 ; Altura da faixa de animacao do menu, separada dos textos e opcoes.
MENU_X_JIPE      equ 0 ; Posicao inicial do jipe na animacao do menu.
MENU_X_NAVE1     equ 80 ; Posicao inicial da primeira nave do menu, separada do jipe.
MENU_X_NAVE2     equ 160 ; Posicao inicial da segunda nave do menu.
MENU_X_NAVE3     equ 240 ; Posicao inicial da terceira nave do menu.
OPCAO_JOGAR      equ 0 ; Codigo da opcao Jogar; um numero permite decidir a acao do Enter.
OPCAO_SAIR       equ 1 ; Codigo da opcao Sair; alternar o bit 0 troca entre as duas opcoes.
ESTADO_MENU      equ 0 ; Identifica a tela inicial; o laco executa somente sua animacao.
ESTADO_SETOR     equ 1 ; Identifica a apresentacao do setor; aguarda Enter antes de contar tempo.
ESTADO_FIM       equ 2 ; Identifica Game Over; qualquer tecla retorna ao menu.
ESTADO_SAIR      equ 3 ; Pedido de encerramento que o laco principal reconhece.
ESTADO_PARTIDA   equ 4 ; Identifica o jogo ativo; habilita atualizacoes de movimento, tempo e combate.
; Escolhas tecnicas E03 (D01/D02/D03/D10), nao confirmacoes do professor.
DURACAO_SEGUNDOS equ 90           ; configuravel: 1..999 | 90 s e escolha configuravel D02, nao valor imposto pelo professor.
VIDAS_INICIAIS   equ 3            ; configuravel: 1..3 | Tres vidas por escolha D03; as artes disponiveis representam de uma a tres.
TICKS_CENARIO    equ 1 ; Atualiza o terreno a cada tick; ajuste de 08/11 permite medir exatamente 5 pixels no topo.
PASSO_CENARIO    equ 1            ; mesma velocidade media: 1 px/tick, antes 2/2 | Avanca 1 pixel por tick; junto com a cadencia preserva a velocidade media anterior.
CENARIO_Y       equ 100 ; O relevo comeca na linha 100; o ceu das naves fica acima.
MONTES_Y        equ 132           ; bases das artes alinhadas em y=163 | Alinha a base dos montes com a das montanhas, na linha 163.
PISTA_ALT       equ 7 ; Sete linhas de pista amarela, medida do enunciado.
PISTA_Y         equ TELA_ALT-PISTA_ALT ; 193: primeira linha da pista; 193..199 sao as sete linhas finais.
COR_PISTA       equ 0Eh ; Amarelo diferencia o chao onde o jipe anda.
HUD_ALT         equ 15 ; Reserva as primeiras 15 linhas para score, vidas e tempo.
HUD_VIDAS_X     equ (TELA_LARG-VIDAS_LARG)/2 ; Centraliza o bitmap de vidas pela largura dele, conforme D01.
HUD_VIDAS_Y     equ 2 ; Posiciona os coracoes dentro da barra superior.
HUD_RELOGIO_X   equ 280 ; Coloca o icone do relogio a direita, antes dos digitos.
HUD_RELOGIO_Y   equ 3 ; Mantem o relogio inteiro dentro dos 15 pixels do HUD.
HUD_SCORE_POS   equ 0             ; linha 0, coluna 0 | Posicao de texto BIOS: linha 0, coluna 0, score a esquerda.
TEMPO_DIGITOS   equ 3 ; Tres caracteres permitem exibir de 000 a 999 segundos.
HUD_TEMPO_POS   equ TEXTO_COLUNAS-TEMPO_DIGITOS ; Coluna 37: os tres digitos terminam na ultima coluna de texto.
CENT_POR_SEG    equ 100 ; 100 centesimos formam um segundo; converte a hora DOS para a contagem do jogo.
MARGEM_RELOGIO  equ 6            ; 60 ms uma vez: cobre quantum DOS (~55 ms) | Folga inicial de 6 centesimos, uma unica vez, para a resolucao do relogio DOS.
CENT_DIA_BAIXO  equ 0D600h        ; 8640000 = 0083:D600h centesimos/dia | Parte baixa de 8640000 centesimos; corrige a passagem pela meia-noite.
CENT_DIA_ALTO   equ 0083h ; Parte alta do mesmo total; o valor inteiro nao cabe em uma word.
SCORE_DIGITOS    equ 5 ; Cinco caracteres mostram todo o intervalo de uma word sem sinal (0..65535).
TITULO_LINHA     equ 2 ; Linha de caracteres do titulo; nao e uma coordenada em pixels.
AVISO_LINHA      equ 8 ; Linha de texto do credito das artes no menu.
CAIXA_COL        equ 14 ; Coluna onde comecam as molduras das opcoes.
CAIXA_JOGAR      equ 16 ; Linha de texto da moldura Jogar.
CAIXA_SAIR       equ 20 ; Linha de texto da moldura Sair, abaixo de Jogar.
CAIXA_LARG       equ 11 ; Largura em caracteres das duas molduras reutilizadas pelo desenhador ASCII.
CAIXA_ALT        equ 3 ; Tres linhas de caracteres: borda, nome da opcao e borda.
AJUDA_LINHA      equ 24 ; Ultima linha de texto do menu; mostra as teclas de controle.
SETOR_LINHA      equ 7 ; Linha de texto que apresenta o unico setor.
OBJETIVO_LINHA   equ 19 ; Linha da mensagem que explica o objetivo antes de jogar.
AVANCO_LINHA     equ 21 ; Linha da instrucao de avancar/retornar nas telas de apresentacao e fim.
TIROS_LINHA      equ 23 ; Linha da ajuda do Espaco, acrescentada com os disparos da E08.
GAME_LINHA       equ 3 ; Posicao vertical do bloco ASCII GAME.
OVER_LINHA       equ 10 ; Posicao vertical do bloco ASCII OVER, abaixo de GAME.
SCORE_LINHA      equ 17 ; Linha onde aparece a pontuacao final na tela de encerramento.
JIPE_LARG        equ 20 ; 20 pixels de largura exigidos; usados no desenho, limite lateral e colisoes.
JIPE_ALT         equ 10 ; 10 pixels de altura exigidos; nao muda durante o salto.
JIPE_BYTES       equ JIPE_LARG * JIPE_ALT ; 200 bytes: tamanho do desenho e da captura do fundo sob o jipe.
; D08: x e a borda esquerda; ultimo pixel x+19 <= 159.
JIPE_X_INICIAL  equ 0 ; Coluna zero: nascimento e reposicao exigidos para o jipe.
JIPE_X_MAX      equ TELA_LARG/2-JIPE_LARG ; 140=160-20: mantem o retangulo inteiro na metade esquerda (D08).
JIPE_Y_CHAO     equ PISTA_Y-JIPE_ALT ; 193-10=183; ocupa 183..192 | 183=193-10: o jipe fica imediatamente acima da pista, sem entrar nela.
TICKS_JIPE      equ 1 ; Atualiza o jipe a cada tick, independentemente do teclado e das naves.
PASSO_JIPE      equ 5            ; margem horizontal no salto; altura segue 15 | 5 pixels por atualizacao; ajuste de 07/11 para facilitar o avanco durante o salto.
; Cadencia independente das naves da partida (E06).
TICKS_NAVE      equ 2 ; Move as naves a cada dois ticks; elas ficam mais lentas que o jipe.
PASSO_NAVE      equ 1 ; Um pixel para a esquerda por atualizacao das naves; preserva os intervalos do grupo.
SALTO_ALTURA    equ 15 ; Altura maxima de 15 pixels, exigida pelo professor.
SALTO_PASSO     equ 3 ; Subida/descida de 3 pixels por atualizacao, compondo o salto trapezoidal.
SALTO_TOPO_PX   equ 5 ; Topo dura 5 pixels de avanco do terreno, referencia adotada em D05.
SALTO_CHAO      equ 0 ; Fase apoiada; somente nela uma nova pressao de cima pode iniciar salto.
SALTO_SUBINDO   equ 1 ; Fase em que Y diminui: na tela, subir significa ir para uma linha menor.
SALTO_TOPO      equ 2 ; Fase em que Y fica fixo enquanto se mede o avanco do terreno.
SALTO_DESCENDO  equ 3 ; Fase em que Y aumenta ate reencontrar o chao.
NAVE_LARG        equ 14 ; 14 pixels de largura por nave, usados tambem para espacamento e recorte.
NAVE_ALT         equ 14 ; 14 pixels de altura; limita a origem para o desenho caber no ceu.
NAVE_BYTES       equ NAVE_LARG * NAVE_ALT ; 196 bytes por desenho de nave e por captura do menu.
; E06: interpretacoes tecnicas D06/D07/D09, nao respostas do professor.
NAVE_MAX         equ 3 ; Tres vagas: capacidade suficiente para os grupos de 1 a 3 exigidos.
NAVE_TIPOS       equ 3 ; Tres aparencias; cada grupo sorteia um unico tipo para todas as suas naves.
NAVE_Y_MIN       equ HUD_ALT ; Origem minima 15, logo abaixo do HUD.
NAVE_Y_MAX       equ CENARIO_Y-NAVE_ALT ; origem 15..86, pixels ate 99 | Origem maxima 86: 14 linhas terminam em 99, antes do relevo (D09).
NAVE_GAP_MIN     equ 30          ; espaco LIVRE entre bordas | 30 pixels livres entre bordas, convencao D07 para a distancia minima.
NAVE_FAIXA       equ TELA_LARG/2 ; formacao inteira cabe em 160 pixels | Formacao ocupa no maximo 160 pixels; interpretacao D06 de meia tela.
NAVE_X_INICIAL   equ TELA_LARG   ; faixa de espera [320,480), entrada gradual | 320 fica logo fora da direita; o recorte mostra a entrada aos poucos.
NAVE_ENTRADA_VAR equ 15          ; primeira origem 320..335, evita espera longa | Variacao inicial de 0..15 pixels evita esperar demais pela primeira nave.
VIDAS_LARG       equ 18 ; Largura do bitmap de coracoes, conforme as medidas do projeto.
VIDAS_ALT        equ 11 ; Altura dos coracoes; deve caber dentro do HUD.
VIDAS_BYTES      equ VIDAS_LARG * VIDAS_ALT ; Numero de bytes de cada uma das tres imagens de vidas.
RELOGIO_LARG     equ 7 ; Largura do icone do relogio usado no HUD.
RELOGIO_ALT      equ 8 ; Altura do icone do relogio usado no HUD.
RELOGIO_BYTES    equ RELOGIO_LARG * RELOGIO_ALT ; Tamanho do bitmap do relogio, um byte por pixel.
CRATERA_LARG     equ 14 ; 14 pixels por cratera, medida usada tambem no espacamento entre origens.
CRATERA_ALT      equ 7 ; Sete pixels por cratera; ocupa a altura da pista.
CRATERA_BYTES    equ CRATERA_LARG * CRATERA_ALT ; 98 bytes por desenho de cratera.
ROCHA_LARG       equ 12 ; 12 pixels por rocha; seu retangulo inteiro participa da colisao.
ROCHA_ALT        equ 10 ; 10 pixels por rocha; fica apoiada sobre a pista.
ROCHA_BYTES      equ ROCHA_LARG * ROCHA_ALT ; 120 bytes por desenho de rocha.
MONTANHAS_LARG   equ 320 ; Uma linha de montanhas cobre a largura da tela e pode circular.
MONTANHAS_ALT    equ 64           ; escolha de arte: abaixo do maximo 95 | 64 linhas de arte, escolha que respeita a altura maxima do enunciado.
MONTES_LARG      equ 320 ; Uma linha dos montes cobre a mesma largura da camada de montanhas.
MONTES_ALT       equ 32           ; arte autoral E02 preservada | 32 linhas de arte sobrepostas pela base das montanhas.

IF (DURACAO_SEGUNDOS LT 1) OR (DURACAO_SEGUNDOS GT 999) ; Na montagem: Exige duracao de 1..999 s, pois o HUD reservou tres digitos para o tempo.
 .ERR ; Interrompe a montagem desta configuracao invalida; nao e uma instrucao executada pelo jogo.
ENDIF ; Encerra a verificacao condicional de constantes feita pelo montador.
IF (VIDAS_INICIAIS LT 1) OR (VIDAS_INICIAIS GT 3) ; Na montagem: Aceita de uma a tres vidas, pois existem somente essas tres artes de coracoes.
 .ERR ; Interrompe a montagem desta configuracao invalida; nao e uma instrucao executada pelo jogo.
ENDIF ; Encerra a verificacao condicional de constantes feita pelo montador.
IF (PASSO_CENARIO LT 1) OR (PASSO_CENARIO GE TELA_LARG) ; Na montagem: Exige passo positivo menor que uma largura de tela, permitindo corrigir a volta com uma subtracao.
 .ERR ; Interrompe a montagem desta configuracao invalida; nao e uma instrucao executada pelo jogo.
ENDIF ; Encerra a verificacao condicional de constantes feita pelo montador.
IF (TICKS_JIPE LT 1) OR (TICKS_NAVE LT 1) OR (TICKS_CENARIO LT 1) ; Na montagem: Rejeita cadencia zero; cada grupo deve aguardar pelo menos um tick entre atualizacoes.
 .ERR ; Interrompe a montagem desta configuracao invalida; nao e uma instrucao executada pelo jogo.
ENDIF ; Encerra a verificacao condicional de constantes feita pelo montador.
IF (SALTO_TOPO_PX MOD PASSO_CENARIO) NE 0 ; Na montagem: Exige que os passos do terreno atinjam exatamente cinco pixels, sem ultrapassar o topo.
 .ERR                         ; atingir 5 pixels reais, sem ultrapassar o topo | Interrompe a montagem desta configuracao invalida; nao e uma instrucao executada pelo jogo.
ENDIF ; Encerra a verificacao condicional de constantes feita pelo montador.
IF (TICKS_CENARIO MOD TICKS_JIPE) NE 0 ; Na montagem: Alinha atualizacoes do jipe e terreno, permitindo iniciar a descida no tick do quinto pixel.
 .ERR                         ; descida pode iniciar no mesmo tick do 5o pixel | Interrompe a montagem desta configuracao invalida; nao e uma instrucao executada pelo jogo.
ENDIF ; Encerra a verificacao condicional de constantes feita pelo montador.
IF (PASSO_JIPE LT 1) OR (PASSO_JIPE GT JIPE_X_MAX) OR (PASSO_NAVE LT 1) ; Na montagem: Exige movimento positivo e passo do jipe compativel com sua faixa horizontal.
 .ERR ; Interrompe a montagem desta configuracao invalida; nao e uma instrucao executada pelo jogo.
ENDIF ; Encerra a verificacao condicional de constantes feita pelo montador.
IF (PASSO_JIPE*TICKS_NAVE LE PASSO_NAVE*TICKS_JIPE) ; Na montagem: Compara velocidades passo/intervalo sem dividir; rejeita jipe tao lento quanto as naves ou mais lento.
 .ERR                         ; velocidade do jipe deve superar a das naves | Interrompe a montagem desta configuracao invalida; nao e uma instrucao executada pelo jogo.
ENDIF ; Encerra a verificacao condicional de constantes feita pelo montador.
IF (JIPE_X_INICIAL LT 0) OR (JIPE_X_INICIAL GT JIPE_X_MAX) ; Na montagem: Garante que o jipe nasca dentro da metade esquerda permitida.
 .ERR ; Interrompe a montagem desta configuracao invalida; nao e uma instrucao executada pelo jogo.
ENDIF ; Encerra a verificacao condicional de constantes feita pelo montador.
IF (NAVE_MAX*NAVE_LARG+(NAVE_MAX-1)*NAVE_GAP_MIN+NAVE_ENTRADA_VAR GT NAVE_FAIXA) ; Na montagem: Verifica se larguras, gaps minimos e variacao inicial cabem na faixa da formacao.
 .ERR ; Interrompe a montagem desta configuracao invalida; nao e uma instrucao executada pelo jogo.
ENDIF ; Encerra a verificacao condicional de constantes feita pelo montador.
IF (NAVE_Y_MAX LT NAVE_Y_MIN) OR (NAVE_Y_MAX-NAVE_Y_MIN+1 GT 256) ; Na montagem: Garante altura valida e no maximo 256 resultados, limite do sorteio baseado em um byte.
 .ERR ; Interrompe a montagem desta configuracao invalida; nao e uma instrucao executada pelo jogo.
ENDIF ; Encerra a verificacao condicional de constantes feita pelo montador.
IF (NAVE_FAIXA GT 256) OR (NAVE_ENTRADA_VAR LT 0) ; Na montagem: Mantem as faixas de sorteio dentro da capacidade de 256 valores e a variacao inicial nao negativa.
 .ERR                         ; todos os sorteios cabem no byte alto do LCG | Interrompe a montagem desta configuracao invalida; nao e uma instrucao executada pelo jogo.
ENDIF ; Encerra a verificacao condicional de constantes feita pelo montador.

; E05: escolhas tecnicas D07/D14/D15; intervalos [inicio,fim).
OBST_MAX        equ 8            ; 4 pares cabem com folga na faixa de 320 | Oito vagas fixas evitam alocacao dinamica; ha folga para os espacamentos atuais.
OBST_LIVRE      equ 0FFFFh ; FFFFh marca vaga vazia, separado dos tipos validos 0..6.
CRATERA_TIPOS   equ 3            ; indices 0..2; rochas 3..6 | Tipos 0..2: tres aparencias de buraco.
ROCHA_TIPOS     equ 4 ; Quatro aparencias; na tabela conjunta recebem os tipos 3..6.
CRATERA_GAP_MIN equ 150          ; pixels LIVRES entre bordas, nao origens | Minimo de 150 pixels livres entre as bordas das crateras (D07).
CRATERA_GAP_VAR equ 80           ; gap sorteado 150..230 inclusivo | Sorteia mais 0..80 pixels para variar a distancia sem violar o minimo.
ROCHA_FOLGA     equ 60           ; minimo livre de cada lado da rocha | Reserva 60 pixels livres de cada lado da rocha intermediaria, escolha tecnica.
PONTOS_OBST     equ 50 ; 50 pontos por salto completo ou destruicao de rocha, uma unica vez.
SCORE_MAX       equ 65535        ; cinco digitos; nunca volta a zero | Maior word sem sinal: impede que a soma excedente volte a um valor pequeno.
PASS_NOVO      equ 0 ; Ainda nao ha prova de que o jipe se aproximou e saltou o obstaculo.
PASS_FRENTE    equ 1            ; visto inteiro a frente do jipe | Obstaculo ja foi visto inteiro a frente; permite reconhecer uma travessia real.
PASS_SOBRE     equ 2            ; sobreposicao horizontal durante salto | Jipe esteve sobre o intervalo horizontal do obstaculo durante o salto.
PASS_CRUZOU    equ 3            ; saiu pela direita; aguarda pouso seguro | Travessia horizontal completa; pontos ainda dependem de pouso seguro.
PASS_PONTO     equ 4            ; ja recebeu +50 | Premio ja concedido; impede repetir +50 por salto ou tiro no mesmo objeto.
PASS_INVALIDO  equ 5            ; matou ou travessia interrompida por morte | Morte interrompeu a travessia; esse objeto nao rende pontos por ela.

; E08 / D11 e D13: escolhas tecnicas, nao valores dados pelo professor.
TIRO_SUP_MAX    equ 8 ; Oito vagas reservadas para tiros superiores, capacidade escolhida em D13.
TIRO_FRE_MAX    equ 8 ; Oito vagas separadas para tiros frontais; um canhao nao ocupa vagas do outro.
TIRO_INI_MAX    equ 12 ; Doze vagas para tiros inimigos, que sobrevivem a remocao da nave.
TIRO_FRE_INICIO equ TIRO_SUP_MAX*2 ; Offset em bytes onde comeca a faixa frontal; cada entrada word ocupa dois bytes.
TIRO_INI_INICIO equ (TIRO_SUP_MAX+TIRO_FRE_MAX)*2 ; Offset em bytes onde comeca a faixa inimiga, depois das duas faixas do jipe.
TIRO_MAX        equ TIRO_SUP_MAX+TIRO_FRE_MAX+TIRO_INI_MAX ; 28 vagas no total, percorridas pelas mesmas rotinas de movimento e desenho.
TIRO_SUP_LARG   equ 2 ; Largura 2 do tiro superior, escolha D13 porque faltava medida explicita.
TIRO_SUP_ALT    equ 4 ; Altura 4 do tiro superior, escolha D13.
TIRO_FRE_LARG   equ 4 ; Comprimento 4 do disparo frontal vermelho, exigido no enunciado.
TIRO_FRE_ALT    equ 2 ; Altura 2 do disparo frontal vermelho, exigida no enunciado.
TIRO_INI_LARG   equ 2 ; Largura 2 do tiro inimigo branco, exigida no enunciado.
TIRO_INI_ALT    equ 4 ; Altura 4 do tiro inimigo branco; tambem determina contato com jipe/pista.
COR_TIRO_SUP    equ 0Eh ; Amarelo distingue o disparo vertical do jipe.
COR_TIRO_FRE    equ 04h ; Vermelho identifica o disparo frontal contra rochas.
COR_TIRO_INI    equ 0Fh ; Branco identifica o disparo inimigo que desce.
CANHAO_SUP_X    equ 6             ; coluna do canhao no bitmap autoral | Deslocamento de 6 pixels dentro da arte do jipe, alinhado ao canhao superior.
CANHAO_FRE_X    equ JIPE_LARG ; O tiro frontal nasce imediatamente depois da borda direita do jipe.
CANHAO_FRE_Y    equ 4 ; Deslocamento vertical de 4 pixels alinha o tiro com o canhao frontal desenhado.
CANHAO_NAVE_X   equ (NAVE_LARG-TIRO_INI_LARG)/2 ; Centraliza o tiro de 2 pixels na nave de 14 pixels.
TICKS_TIRO      equ 1 ; Cadencia dos projeteis independente do movimento das naves e do terreno.
PASSO_TIRO_SUP  equ 4 ; Quatro pixels para cima por atualizacao, verificados um a um para nao pular alvos.
PASSO_TIRO_FRE  equ 4 ; Quatro pixels para a direita; o ultimo passo pode parar exatamente no alcance 50.
PASSO_TIRO_INI  equ 2             ; ~36 px/s, jipe ~91 px/s | Dois pixels para baixo por atualizacao; escolha tecnica da dificuldade.
CADENCIA_JIPE   equ 6             ; atualizacoes de TICKS_TIRO (~330 ms) | Intervalo de seis atualizacoes entre pares de tiros; segurar Espaco nao elimina a espera.
CADENCIA_NAVE   equ 18            ; ~1 s, contador por nave visivel | Cada nave espera 18 atualizacoes dos tiros entre emissoes visiveis.
ALCANCE_FRONTAL equ 50            ; distancia desde a origem, nao X absoluto | 50 pixels percorridos desde o nascimento, nao a coluna absoluta 50 da tela.
PONTOS_NAVE     equ 100 ; 100 pontos somente quando um tiro realmente remove uma nave ativa.
ROCHA_1        equ CRATERA_TIPOS ; Primeiro tipo de rocha na tabela conjunta; indestrutivel por tiros.
ROCHA_4        equ CRATERA_TIPOS+3 ; Ultimo tipo da tabela; exige dois impactos na mesma rocha.
IMPACTOS_ROCHA4 equ 2             ; mesma rocha, sem prazo ou reinicio por erro | Dois impactos acumulados; D11 nao define prazo nem zera ao errar outro tiro.
IF (TICKS_TIRO LT 1) OR (CADENCIA_JIPE LT 1) OR (CADENCIA_NAVE LT 1) ; Na montagem: Impede cadencias de tiros nulas; recargas e movimento precisam de intervalos positivos.
 .ERR ; Interrompe a montagem desta configuracao invalida; nao e uma instrucao executada pelo jogo.
ENDIF ; Encerra a verificacao condicional de constantes feita pelo montador.
IF (PASSO_TIRO_SUP LT 1) OR (PASSO_TIRO_FRE LT 1) OR (PASSO_TIRO_INI LT 1) ; Na montagem: Impede projeteis sem movimento ou com passo negativo.
 .ERR ; Interrompe a montagem desta configuracao invalida; nao e uma instrucao executada pelo jogo.
ENDIF ; Encerra a verificacao condicional de constantes feita pelo montador.
IF (TIRO_SUP_MAX LT 1) OR (TIRO_FRE_MAX LT 1) OR (TIRO_INI_MAX LT NAVE_MAX) ; Na montagem: Exige vagas para os dois canhoes e capacidade inimiga de pelo menos um tiro por nave.
 .ERR ; Interrompe a montagem desta configuracao invalida; nao e uma instrucao executada pelo jogo.
ENDIF ; Encerra a verificacao condicional de constantes feita pelo montador.

; Limite para nao atravessar um obstaculo inteiro entre amostras.
IF (PASSO_CENARIO+PASSO_JIPE GT ROCHA_LARG) ; Na montagem: Limita o avanco relativo para nao atravessar uma rocha inteira entre testes de colisao.
 .ERR ; Interrompe a montagem desta configuracao invalida; nao e uma instrucao executada pelo jogo.
ENDIF ; Encerra a verificacao condicional de constantes feita pelo montador.
IF (CRATERA_GAP_MIN LT 2*ROCHA_FOLGA+ROCHA_LARG) ; Na montagem: Garante espaco para a rocha de 12 pixels e duas folgas de 60 entre crateras.
 .ERR ; Interrompe a montagem desta configuracao invalida; nao e uma instrucao executada pelo jogo.
ENDIF ; Encerra a verificacao condicional de constantes feita pelo montador.

.data ; Comeca a area de variaveis, tabelas, textos e bitmaps que DS vai acessar.
modoAnterior    db 3 ; Declara bytes (8 bits): modo de video que estava ativo antes do jogo, para restaurar ao sair.
paginaAnterior  db 0 ; Declara bytes (8 bits): pagina de video anterior, tambem restaurada na saida.
estado          db ESTADO_MENU ; Declara bytes (8 bits): tela/fase atual do programa, que decide o caminho do laco principal.
opcao           db OPCAO_JOGAR ; Declara bytes (8 bits): opcao selecionada no menu, Jogar ou Sair.
ultimoTick      dw 0 ; Declara words (16 bits, dois bytes cada): tick da ultima animacao do menu, usado para controlar sua velocidade.
scoreFinal      dw 0 ; Declara words (16 bits, dois bytes cada): copia da pontuacao que sera apresentada no Game Over.
scorePartida    dw 0             ; word unsigned; SomarPontos satura em SCORE_MAX | Declara words (16 bits, dois bytes cada): pontuacao acumulada da sessao; nao reinicia ao perder uma vida.
vidas           db VIDAS_INICIAIS ; Declara bytes (8 bits): vidas restantes; chegar a zero encerra a partida.
tempoRestante   dw DURACAO_SEGUNDOS ; Declara words (16 bits, dois bytes cada): segundos restantes; a duracao nao depende do numero de quadros.
rolagem         dw 0             ; coluna da arte exibida na esquerda | Declara words (16 bits, dois bytes cada): coluna da arte que aparece a esquerda; mudar isso desloca o terreno.
tickCenario     dw 0 ; Declara words (16 bits, dois bytes cada): tick do ultimo avanco do terreno.
tempoAnteriorLo dw 0             ; instante DOS em centesimos desde meia-noite | Declara words (16 bits, dois bytes cada): parte baixa da hora da consulta anterior, em centesimos.
tempoAnteriorHi dw 0 ; Declara words (16 bits, dois bytes cada): parte alta da hora anterior, para contar mais que 65535 centesimos.
fracaoSegundo   dw 0             ; resto 0..99, preservado entre consultas | Declara words (16 bits, dois bytes cada): centesimos ainda insuficientes para descontar um segundo inteiro.
margemInicial   dw 0             ; evita fim antecipado pela quantizacao DOS | Declara words (16 bits, dois bytes cada): folga inicial ainda nao consumida, aplicada apenas no inicio da partida.
digitosTempo    db TEMPO_DIGITOS dup('0') ; Declara bytes (8 bits): caracteres decimais que representam o tempo no HUD.
linhaCenario    db TELA_LARG dup(?) ; unica linha de composicao, nao tela inteira | Declara bytes (8 bits): buffer de 320 pixels para compor uma linha antes de envia-la ao video. ? reserva espaco; preencher antes de ler.
jipeX          dw JIPE_X_INICIAL ; Declara words (16 bits, dois bytes cada): coluna atual da borda esquerda do jipe.
jipeY          dw JIPE_Y_CHAO ; Declara words (16 bits, dois bytes cada): linha atual do topo do jipe; diminuir Y faz subir.
jipeDesenhoX    dw 0             ; posicao do fundo capturado no quadro anterior | Declara words (16 bits, dois bytes cada): coluna onde o jipe foi desenhado e onde o fundo salvo deve ser restaurado.
jipeDesenhoY    dw 0 ; Declara words (16 bits, dois bytes cada): linha da captura anterior do fundo, que pode diferir do novo Y do jipe.
tickJipe       dw 0 ; Declara words (16 bits, dois bytes cada): tick da ultima atualizacao do jipe.
estadoSalto    db SALTO_CHAO ; Declara bytes (8 bits): fase do salto: chao, subida, topo ou descida.
pixelsTopo     dw 0             ; D05: avanco do terreno, nao frames/teclas | Declara words (16 bits, dois bytes cada): distancia de terreno acumulada desde que o jipe chegou ao topo.
teclasJipe     db 0             ; bits: esquerda, direita, cima e Espaco | Declara bytes (8 bits): mascara das teclas mantidas; cada bit registra uma tecla separadamente.
pedidoSalto    db 0             ; borda de pressionamento; nunca fila de saltos | Declara bytes (8 bits): pedido de uma nova pressao de cima, consumido uma vez pelo movimento.
tecladoJogoAtivo db 0 ; Declara bytes (8 bits): indica se a interrupcao de teclado do jogo esta instalada.
vetorTeclado   dw 0,0           ; INT 09h anterior: offset, segmento | Declara words (16 bits, dois bytes cada): endereco antigo da INT 09h: offset e segmento, para restaurar o teclado.
cenarioMudou   db 0 ; Declara bytes (8 bits): aviso de que o terreno/obstaculos precisam ser redesenhados.
jipeMudou      db 0 ; Declara bytes (8 bits): aviso de que o jipe mudou ou desapareceu e requer novo desenho.
fundoPartida   db JIPE_BYTES dup(?) ; so o fundo ATUAL sob o jipe, 200 bytes | Declara bytes (8 bits): 200 pixels sob o jipe; permitem apaga-lo sem apagar o terreno. ? reserva espaco; preencher antes de ler.
; Listas fixas: DI=0,2,..14 seleciona a mesma entrada em cada tabela.
obstX           dw OBST_MAX dup(0) ; signed: entrada/saida parcial | Declara words (16 bits, dois bytes cada): coluna de cada obstaculo; admite negativo na saida parcial pela esquerda.
obstTipo        dw OBST_MAX dup(OBST_LIVRE) ; Declara words (16 bits, dois bytes cada): tipo de cada obstaculo, ou OBST_LIVRE para uma vaga disponivel.
obstPassagem    dw OBST_MAX dup(PASS_NOVO) ; Declara words (16 bits, dois bytes cada): progresso da travessia de cada obstaculo, evitando pontos indevidos ou repetidos.
obstImpactos    dw OBST_MAX dup(0) ; reinicia quando a vaga recebe outro objeto | Declara words (16 bits, dois bytes cada): impactos recebidos por cada rocha; a rocha 4 precisa acumular dois.
tipoLarg        dw 3 dup(CRATERA_LARG),4 dup(ROCHA_LARG) ; Declara words (16 bits, dois bytes cada): largura consultada pelo tipo: 14 para cratera, 12 para rocha.
tipoAlt         dw 3 dup(CRATERA_ALT),4 dup(ROCHA_ALT) ; Declara words (16 bits, dois bytes cada): altura consultada pelo tipo: 7 para cratera, 10 para rocha.
tipoY           dw 3 dup(PISTA_Y),4 dup(PISTA_Y-ROCHA_ALT) ; Declara words (16 bits, dois bytes cada): linha de apoio do tipo: cratera na pista, rocha acima dela.
tipoBitmap      dw offset bitmapCratera1,offset bitmapCratera2,offset bitmapCratera3 ; Declara words (16 bits, dois bytes cada): enderecos dos desenhos por tipo; permite uma unica rotina para sete obstaculos.
                dw offset bitmapRocha1,offset bitmapRocha2,offset bitmapRocha3,offset bitmapRocha4 ; Continua a tabela tipoBitmap; cada endereco/valor ocupa dois bytes.
semente         dw 1 ; Declara words (16 bits, dois bytes cada): estado do gerador pseudoaleatorio compartilhado por obstaculos e naves.
proximoEm       dw 0              ; distancia ate o proximo nascimento | Declara words (16 bits, dois bytes cada): pixels de terreno que faltam para nascer o proximo obstaculo.
proximaRocha    db 0              ; sequencia cratera, rocha, cratera... | Declara bytes (8 bits): alterna o nascimento entre cratera e rocha intermediaria.
ateCratera      dw 0              ; restante do intervalo ja sorteado | Declara words (16 bits, dois bytes cada): distancia ja planejada entre a rocha e a proxima cratera.
jipeAtivo       db 1              ; zero: aguarda reposicao em area livre | Declara bytes (8 bits): indica se o jipe esta vivo/presente; zero impede descontar outra vida no mesmo evento.
jipeNaTela      db 0              ; existe captura valida a restaurar? | Declara bytes (8 bits): indica se existe uma captura valida do fundo sob o jipe desenhado.
statusMudou     db 0 ; Declara bytes (8 bits): aviso para atualizar score/vidas no HUD depois de um evento.
; E06: DI=0,2,4 seleciona a mesma nave; tipo compartilhado pelo grupo.
naveX           dw NAVE_MAX dup(0) ; signed, inclusive fora da tela | Declara words (16 bits, dois bytes cada): coluna de cada nave, inclusive enquanto entra ou sai da tela.
naveY           dw NAVE_MAX dup(0) ; Declara words (16 bits, dois bytes cada): altura sorteada de cada nave, que fica fixa durante o percurso.
naveAtiva       dw NAVE_MAX dup(0) ; Declara words (16 bits, dois bytes cada): atividade real de cada vaga de nave, inclusive fora da borda direita.
naveQuantidade  dw 0              ; quantidade sorteada, nao contagem ativa | Declara words (16 bits, dois bytes cada): quantidade originalmente sorteada para o grupo, nao o total ainda vivo.
naveTipo        dw 0 ; Declara words (16 bits, dois bytes cada): aparencia unica compartilhada por todas as naves do grupo.
naveBitmap      dw offset bitmapNave1,offset bitmapNave2,offset bitmapNave3 ; Declara words (16 bits, dois bytes cada): enderecos dos tres desenhos de nave, escolhidos pelo tipo do grupo.
tickNave        dw 0 ; Declara words (16 bits, dois bytes cada): tick do ultimo movimento do grupo de naves.
navesMudou      db 0              ; consumido pelo desenho, inclusive remocao | Declara bytes (8 bits): aviso para recompor o ceu e apagar posicoes antigas de naves.
; Uma lista, tres faixas fixas. SI=offset par; cada tiro tem vida propria.
tiroAtivo       dw TIRO_MAX dup(0) ; Declara words (16 bits, dois bytes cada): atividade de cada projetil; a vaga pode ser reutilizada depois de zero.
tiroX           dw TIRO_MAX dup(0) ; Declara words (16 bits, dois bytes cada): coluna de cada tiro, independente da posicao posterior de quem disparou.
tiroY           dw TIRO_MAX dup(0) ; Declara words (16 bits, dois bytes cada): linha de cada tiro; sobe ou desce conforme sua faixa na lista.
tiroDistancia   dw TIRO_MAX dup(0) ; Declara words (16 bits, dois bytes cada): percurso acumulado do tiro frontal para limita-lo a 50 pixels.
tiroLarg        dw TIRO_SUP_LARG,TIRO_FRE_LARG,TIRO_INI_LARG ; Declara words (16 bits, dois bytes cada): larguras dos tres tipos de tiro, usadas no desenho e na colisao.
tiroAlt         dw TIRO_SUP_ALT,TIRO_FRE_ALT,TIRO_INI_ALT ; Declara words (16 bits, dois bytes cada): alturas dos tres tipos de tiro, usadas no desenho e na colisao.
tiroBitmap      dw offset bitmapTiroSup,offset bitmapTiroFre,offset bitmapTiroIni ; Declara words (16 bits, dois bytes cada): enderecos dos retangulos coloridos dos tres tipos de tiro.
bitmapTiroSup   db TIRO_SUP_LARG*TIRO_SUP_ALT dup(COR_TIRO_SUP) ; Declara bytes (8 bits): pixels amarelos do tiro superior; cada byte representa uma cor.
bitmapTiroFre   db TIRO_FRE_LARG*TIRO_FRE_ALT dup(COR_TIRO_FRE) ; Declara bytes (8 bits): pixels vermelhos do tiro frontal; cada byte representa uma cor.
bitmapTiroIni   db TIRO_INI_LARG*TIRO_INI_ALT dup(COR_TIRO_INI) ; Declara bytes (8 bits): pixels brancos do tiro inimigo; cada byte representa uma cor.
esperaNave      dw NAVE_MAX dup(0) ; Declara words (16 bits, dois bytes cada): contador de recarga individual de cada nave.
esperaJipe      dw 0 ; Declara words (16 bits, dois bytes cada): contador que impede disparar um novo par antes da cadencia escolhida.
tickTiro        dw 0 ; Declara words (16 bits, dois bytes cada): tick da ultima atualizacao dos projeteis.
tirosMudou      db 0 ; Declara bytes (8 bits): aviso para apagar posicoes antigas e desenhar os tiros atuais.
pedidoTiro      db 0              ; captura toque curto; mantida repete na cadencia | Declara bytes (8 bits): guarda um toque curto de Espaco ate a proxima leitura do jogo.
menuXInicial    dw MENU_X_JIPE,MENU_X_NAVE1,MENU_X_NAVE2,MENU_X_NAVE3 ; Declara words (16 bits, dois bytes cada): colunas iniciais dos quatro desenhos, restauradas ao entrar no menu.
menuX           dw MENU_QUANT dup(0) ; Declara words (16 bits, dois bytes cada): coluna atual de cada desenho animado do menu.
menuY           dw MENU_Y+NAVE_ALT-JIPE_ALT,MENU_Y,MENU_Y,MENU_Y ; Declara words (16 bits, dois bytes cada): linhas dos quatro desenhos, alinhando as bases de jipe e naves.
menuLarg        dw JIPE_LARG,NAVE_LARG,NAVE_LARG,NAVE_LARG ; Declara words (16 bits, dois bytes cada): largura de cada objeto do menu, para a rotina generica e o limite direito.
menuAlt         dw JIPE_ALT,NAVE_ALT,NAVE_ALT,NAVE_ALT ; Declara words (16 bits, dois bytes cada): altura de cada objeto do menu.
menuBitmap      dw offset bitmapJipe,offset bitmapNave1,offset bitmapNave2,offset bitmapNave3 ; Declara words (16 bits, dois bytes cada): enderecos das imagens dos quatro objetos do menu.
menuFundo       dw offset fundoJipe,offset fundoNave1,offset fundoNave2,offset fundoNave3 ; Declara words (16 bits, dois bytes cada): enderecos das capturas de fundo dos quatro objetos do menu.
fundoJipe       db JIPE_BYTES dup(?) ; Declara bytes (8 bits): captura de 200 pixels sob o jipe do menu, separada da captura da partida. ? reserva espaco; preencher antes de ler.
fundoNave1      db NAVE_BYTES dup(?) ; Declara bytes (8 bits): captura de 196 pixels sob a primeira nave do menu. ? reserva espaco; preencher antes de ler.
fundoNave2      db NAVE_BYTES dup(?) ; Declara bytes (8 bits): captura de 196 pixels sob a segunda nave do menu. ? reserva espaco; preencher antes de ler.
fundoNave3      db NAVE_BYTES dup(?) ; Declara bytes (8 bits): captura de 196 pixels sob a terceira nave do menu. ? reserva espaco; preencher antes de ler.

; ARTES_INICIO
; Desenhos proprios E02, autorizados em 25/10/2026.
; Grade editavel/origem: artes/gerar-artes.py e desenhos.json.
; Cada DB e uma linha. DUP repete bytes na montagem, nao no jogo.
; FFh transparente; 00h preto opaco. Nao sao copias do arcade.
; Jipe - 20 x 10
bitmapJipe db 6 dup(0FFh),0Fh,13 dup(0FFh) ; Linha 1 de bitmapJipe: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
           db 6 dup(0FFh),07h,4 dup(0FFh),3 dup(0Bh),6 dup(0FFh) ; Linha 2 de bitmapJipe: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
           db 6 dup(0FFh),07h,3 dup(0FFh),0Bh,2 dup(09h),2 dup(0Bh),5 dup(0FFh) ; Linha 3 de bitmapJipe: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
           db 6 dup(0FFh),07h,2 dup(0FFh),0Bh,3 dup(09h),3 dup(0Bh),4 dup(0FFh) ; Linha 4 de bitmapJipe: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
           db 3 dup(0FFh),13 dup(0Dh),3 dup(07h),0Fh ; Linha 5 de bitmapJipe: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
           db 2 dup(0FFh),3 dup(05h),2 dup(0Dh),7 dup(0Fh),4 dup(0Dh),2 dup(0FFh) ; Linha 6 de bitmapJipe: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
           db 18 dup(05h),2 dup(0FFh) ; Linha 7 de bitmapJipe: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
           db 3 dup(0FFh),08h,5 dup(0FFh),08h,5 dup(0FFh),08h,4 dup(0FFh) ; Linha 8 de bitmapJipe: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
           db 2 dup(0FFh),08h,0Fh,08h,3 dup(0FFh),08h,0Fh,08h,3 dup(0FFh),08h,0Fh,08h,3 dup(0FFh) ; Linha 9 de bitmapJipe: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
           db 3 dup(0FFh),08h,5 dup(0FFh),08h,5 dup(0FFh),08h,4 dup(0FFh) ; Linha 10 de bitmapJipe: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
bitmapJipeFim label byte ; Marca esta posicao sem reservar bytes; permite delimitar e medir o bloco de dados.
; Nave 1 - disco - 14 x 14
bitmapNave1 db 14 dup(0FFh) ; Linha 1 de bitmapNave1: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
            db 5 dup(0FFh),4 dup(0Bh),5 dup(0FFh) ; Linha 2 de bitmapNave1: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
            db 4 dup(0FFh),0Bh,4 dup(09h),0Bh,4 dup(0FFh) ; Linha 3 de bitmapNave1: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
            db 3 dup(0FFh),0Bh,6 dup(09h),0Bh,3 dup(0FFh) ; Linha 4 de bitmapNave1: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
            db 3 dup(0FFh),8 dup(07h),3 dup(0FFh) ; Linha 5 de bitmapNave1: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
            db 2 dup(0FFh),10 dup(0Eh),2 dup(0FFh) ; Linha 6 de bitmapNave1: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
            db 0FFh,2 dup(0Eh),06h,6 dup(0Eh),06h,2 dup(0Eh),0FFh ; Linha 7 de bitmapNave1: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
            db 14 dup(0Eh) ; Linha 8 de bitmapNave1: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
            db 2 dup(0FFh),10 dup(06h),2 dup(0FFh) ; Linha 9 de bitmapNave1: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
            db 3 dup(0FFh),0Eh,6 dup(0FFh),0Eh,3 dup(0FFh) ; Linha 10 de bitmapNave1: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
            db 2 dup(0FFh),0Ch,8 dup(0FFh),0Ch,2 dup(0FFh) ; Linha 11 de bitmapNave1: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
            db 3 dup(0FFh),04h,6 dup(0FFh),04h,3 dup(0FFh) ; Linha 12 de bitmapNave1: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
            db 14 dup(0FFh) ; Linha 13 de bitmapNave1: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
            db 14 dup(0FFh) ; Linha 14 de bitmapNave1: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
bitmapNave1Fim label byte ; Marca esta posicao sem reservar bytes; permite delimitar e medir o bloco de dados.
; Nave 2 - asas - 14 x 14
bitmapNave2 db 3 dup(0FFh),0Bh,6 dup(0FFh),0Bh,3 dup(0FFh) ; Linha 1 de bitmapNave2: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
            db 3 dup(0FFh),2 dup(0Bh),4 dup(0FFh),2 dup(0Bh),3 dup(0FFh) ; Linha 2 de bitmapNave2: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
            db 2 dup(0FFh),03h,2 dup(0Bh),03h,2 dup(0FFh),03h,2 dup(0Bh),03h,2 dup(0FFh) ; Linha 3 de bitmapNave2: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
            db 2 dup(0FFh),03h,3 dup(0Bh),2 dup(03h),3 dup(0Bh),03h,2 dup(0FFh) ; Linha 4 de bitmapNave2: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
            db 3 dup(0FFh),03h,6 dup(0Bh),03h,3 dup(0FFh) ; Linha 5 de bitmapNave2: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
            db 4 dup(0FFh),0Bh,4 dup(0Fh),0Bh,4 dup(0FFh) ; Linha 6 de bitmapNave2: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
            db 3 dup(0FFh),2 dup(0Bh),09h,2 dup(00h),09h,2 dup(0Bh),3 dup(0FFh) ; Linha 7 de bitmapNave2: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
            db 2 dup(0FFh),10 dup(0Bh),2 dup(0FFh) ; Linha 8 de bitmapNave2: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
            db 0FFh,03h,2 dup(0Bh),03h,4 dup(0Bh),03h,2 dup(0Bh),03h,0FFh ; Linha 9 de bitmapNave2: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
            db 03h,2 dup(0Bh),03h,2 dup(0FFh),2 dup(03h),2 dup(0FFh),03h,2 dup(0Bh),03h ; Linha 10 de bitmapNave2: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
            db 0FFh,03h,4 dup(0FFh),2 dup(0Ch),4 dup(0FFh),03h,0FFh ; Linha 11 de bitmapNave2: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
            db 6 dup(0FFh),2 dup(04h),6 dup(0FFh) ; Linha 12 de bitmapNave2: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
            db 14 dup(0FFh) ; Linha 13 de bitmapNave2: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
            db 14 dup(0FFh) ; Linha 14 de bitmapNave2: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
bitmapNave2Fim label byte ; Marca esta posicao sem reservar bytes; permite delimitar e medir o bloco de dados.
; Nave 3 - losango - 14 x 14
bitmapNave3 db 6 dup(0FFh),2 dup(0Dh),6 dup(0FFh) ; Linha 1 de bitmapNave3: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
            db 5 dup(0FFh),0Dh,2 dup(05h),0Dh,5 dup(0FFh) ; Linha 2 de bitmapNave3: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
            db 4 dup(0FFh),0Dh,4 dup(05h),0Dh,4 dup(0FFh) ; Linha 3 de bitmapNave3: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
            db 3 dup(0FFh),0Dh,6 dup(05h),0Dh,3 dup(0FFh) ; Linha 4 de bitmapNave3: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
            db 2 dup(0FFh),0Dh,2 dup(05h),0Fh,2 dup(05h),0Fh,2 dup(05h),0Dh,2 dup(0FFh) ; Linha 5 de bitmapNave3: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
            db 0FFh,0Dh,3 dup(05h),00h,2 dup(05h),00h,3 dup(05h),0Dh,0FFh ; Linha 6 de bitmapNave3: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
            db 0FFh,0Dh,10 dup(05h),0Dh,0FFh ; Linha 7 de bitmapNave3: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
            db 2 dup(0FFh),10 dup(0Dh),2 dup(0FFh) ; Linha 8 de bitmapNave3: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
            db 3 dup(0FFh),05h,6 dup(0Dh),05h,3 dup(0FFh) ; Linha 9 de bitmapNave3: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
            db 2 dup(0FFh),05h,2 dup(0FFh),0Dh,2 dup(05h),0Dh,2 dup(0FFh),05h,2 dup(0FFh) ; Linha 10 de bitmapNave3: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
            db 0FFh,05h,4 dup(0FFh),2 dup(0Ch),4 dup(0FFh),05h,0FFh ; Linha 11 de bitmapNave3: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
            db 6 dup(0FFh),2 dup(04h),6 dup(0FFh) ; Linha 12 de bitmapNave3: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
            db 14 dup(0FFh) ; Linha 13 de bitmapNave3: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
            db 14 dup(0FFh) ; Linha 14 de bitmapNave3: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
bitmapNave3Fim label byte ; Marca esta posicao sem reservar bytes; permite delimitar e medir o bloco de dados.
; Vidas 3 - 18 x 11
bitmapVidas3 db 18 dup(0FFh) ; Linha 1 de bitmapVidas3: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 18 dup(0FFh) ; Linha 2 de bitmapVidas3: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 18 dup(0FFh) ; Linha 3 de bitmapVidas3: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 0FFh,0Ch,0FFh,0Ch,3 dup(0FFh),0Ch,0FFh,0Ch,3 dup(0FFh),0Ch,0FFh,0Ch,2 dup(0FFh) ; Linha 4 de bitmapVidas3: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 0Ch,0Fh,3 dup(0Ch),0FFh,0Ch,0Fh,3 dup(0Ch),0FFh,0Ch,0Fh,3 dup(0Ch),0FFh ; Linha 5 de bitmapVidas3: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 5 dup(0Ch),0FFh,5 dup(0Ch),0FFh,5 dup(0Ch),0FFh ; Linha 6 de bitmapVidas3: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 0FFh,3 dup(0Ch),3 dup(0FFh),3 dup(0Ch),3 dup(0FFh),3 dup(0Ch),2 dup(0FFh) ; Linha 7 de bitmapVidas3: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 2 dup(0FFh),0Ch,5 dup(0FFh),0Ch,5 dup(0FFh),0Ch,3 dup(0FFh) ; Linha 8 de bitmapVidas3: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 18 dup(0FFh) ; Linha 9 de bitmapVidas3: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 18 dup(0FFh) ; Linha 10 de bitmapVidas3: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 18 dup(0FFh) ; Linha 11 de bitmapVidas3: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
bitmapVidas3Fim label byte ; Marca esta posicao sem reservar bytes; permite delimitar e medir o bloco de dados.
; Vidas 2 - 18 x 11
bitmapVidas2 db 18 dup(0FFh) ; Linha 1 de bitmapVidas2: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 18 dup(0FFh) ; Linha 2 de bitmapVidas2: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 18 dup(0FFh) ; Linha 3 de bitmapVidas2: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 0FFh,0Ch,0FFh,0Ch,3 dup(0FFh),0Ch,0FFh,0Ch,3 dup(0FFh),08h,0FFh,08h,2 dup(0FFh) ; Linha 4 de bitmapVidas2: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 0Ch,0Fh,3 dup(0Ch),0FFh,0Ch,0Fh,3 dup(0Ch),0FFh,5 dup(08h),0FFh ; Linha 5 de bitmapVidas2: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 5 dup(0Ch),0FFh,5 dup(0Ch),0FFh,5 dup(08h),0FFh ; Linha 6 de bitmapVidas2: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 0FFh,3 dup(0Ch),3 dup(0FFh),3 dup(0Ch),3 dup(0FFh),3 dup(08h),2 dup(0FFh) ; Linha 7 de bitmapVidas2: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 2 dup(0FFh),0Ch,5 dup(0FFh),0Ch,5 dup(0FFh),08h,3 dup(0FFh) ; Linha 8 de bitmapVidas2: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 18 dup(0FFh) ; Linha 9 de bitmapVidas2: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 18 dup(0FFh) ; Linha 10 de bitmapVidas2: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 18 dup(0FFh) ; Linha 11 de bitmapVidas2: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
bitmapVidas2Fim label byte ; Marca esta posicao sem reservar bytes; permite delimitar e medir o bloco de dados.
; Vidas 1 - 18 x 11
bitmapVidas1 db 18 dup(0FFh) ; Linha 1 de bitmapVidas1: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 18 dup(0FFh) ; Linha 2 de bitmapVidas1: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 18 dup(0FFh) ; Linha 3 de bitmapVidas1: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 0FFh,0Ch,0FFh,0Ch,3 dup(0FFh),08h,0FFh,08h,3 dup(0FFh),08h,0FFh,08h,2 dup(0FFh) ; Linha 4 de bitmapVidas1: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 0Ch,0Fh,3 dup(0Ch),0FFh,5 dup(08h),0FFh,5 dup(08h),0FFh ; Linha 5 de bitmapVidas1: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 5 dup(0Ch),0FFh,5 dup(08h),0FFh,5 dup(08h),0FFh ; Linha 6 de bitmapVidas1: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 0FFh,3 dup(0Ch),3 dup(0FFh),3 dup(08h),3 dup(0FFh),3 dup(08h),2 dup(0FFh) ; Linha 7 de bitmapVidas1: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 2 dup(0FFh),0Ch,5 dup(0FFh),08h,5 dup(0FFh),08h,3 dup(0FFh) ; Linha 8 de bitmapVidas1: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 18 dup(0FFh) ; Linha 9 de bitmapVidas1: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 18 dup(0FFh) ; Linha 10 de bitmapVidas1: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 18 dup(0FFh) ; Linha 11 de bitmapVidas1: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
bitmapVidas1Fim label byte ; Marca esta posicao sem reservar bytes; permite delimitar e medir o bloco de dados.
; Relogio - 7 x 8
bitmapRelogio db 2 dup(0FFh),3 dup(0Eh),2 dup(0FFh) ; Linha 1 de bitmapRelogio: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
              db 0FFh,0Eh,3 dup(00h),0Eh,0FFh ; Linha 2 de bitmapRelogio: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
              db 0Eh,2 dup(00h),0Eh,2 dup(00h),0Eh ; Linha 3 de bitmapRelogio: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
              db 0Eh,2 dup(00h),0Eh,2 dup(00h),0Eh ; Linha 4 de bitmapRelogio: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
              db 0Eh,2 dup(00h),2 dup(0Eh),00h,0Eh ; Linha 5 de bitmapRelogio: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
              db 0Eh,5 dup(00h),0Eh ; Linha 6 de bitmapRelogio: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
              db 0FFh,0Eh,3 dup(00h),0Eh,0FFh ; Linha 7 de bitmapRelogio: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
              db 2 dup(0FFh),3 dup(0Eh),2 dup(0FFh) ; Linha 8 de bitmapRelogio: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
bitmapRelogioFim label byte ; Marca esta posicao sem reservar bytes; permite delimitar e medir o bloco de dados.
; Cratera 1 - 14 x 7
bitmapCratera1 db 3 dup(0FFh),8 dup(06h),3 dup(0FFh) ; Linha 1 de bitmapCratera1: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
               db 0FFh,2 dup(06h),8 dup(08h),2 dup(06h),0FFh ; Linha 2 de bitmapCratera1: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
               db 06h,08h,10 dup(00h),08h,06h ; Linha 3 de bitmapCratera1: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
               db 06h,12 dup(00h),06h ; Linha 4 de bitmapCratera1: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
               db 0FFh,06h,08h,8 dup(00h),08h,06h,0FFh ; Linha 5 de bitmapCratera1: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
               db 2 dup(0FFh),2 dup(06h),6 dup(08h),2 dup(06h),2 dup(0FFh) ; Linha 6 de bitmapCratera1: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
               db 4 dup(0FFh),6 dup(06h),4 dup(0FFh) ; Linha 7 de bitmapCratera1: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
bitmapCratera1Fim label byte ; Marca esta posicao sem reservar bytes; permite delimitar e medir o bloco de dados.
; Cratera 2 - 14 x 7
bitmapCratera2 db 0FFh,3 dup(06h),4 dup(0FFh),3 dup(06h),3 dup(0FFh) ; Linha 1 de bitmapCratera2: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
               db 06h,08h,2 dup(00h),4 dup(06h),08h,00h,08h,2 dup(06h),0FFh ; Linha 2 de bitmapCratera2: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
               db 06h,11 dup(00h),08h,06h ; Linha 3 de bitmapCratera2: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
               db 06h,08h,11 dup(00h),06h ; Linha 4 de bitmapCratera2: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
               db 0FFh,06h,08h,8 dup(00h),08h,06h,0FFh ; Linha 5 de bitmapCratera2: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
               db 2 dup(0FFh),2 dup(06h),08h,3 dup(00h),08h,3 dup(06h),2 dup(0FFh) ; Linha 6 de bitmapCratera2: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
               db 4 dup(0FFh),5 dup(06h),5 dup(0FFh) ; Linha 7 de bitmapCratera2: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
bitmapCratera2Fim label byte ; Marca esta posicao sem reservar bytes; permite delimitar e medir o bloco de dados.
; Cratera 3 - 14 x 7
bitmapCratera3 db 6 dup(0FFh),4 dup(06h),4 dup(0FFh) ; Linha 1 de bitmapCratera3: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
               db 3 dup(0FFh),3 dup(06h),08h,2 dup(00h),08h,2 dup(06h),2 dup(0FFh) ; Linha 2 de bitmapCratera3: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
               db 0FFh,2 dup(06h),08h,7 dup(00h),08h,06h,0FFh ; Linha 3 de bitmapCratera3: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
               db 06h,08h,10 dup(00h),08h,06h ; Linha 4 de bitmapCratera3: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
               db 06h,10 dup(00h),08h,06h,0FFh ; Linha 5 de bitmapCratera3: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
               db 0FFh,2 dup(06h),08h,4 dup(00h),08h,3 dup(06h),2 dup(0FFh) ; Linha 6 de bitmapCratera3: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
               db 3 dup(0FFh),6 dup(06h),5 dup(0FFh) ; Linha 7 de bitmapCratera3: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
bitmapCratera3Fim label byte ; Marca esta posicao sem reservar bytes; permite delimitar e medir o bloco de dados.
; Rocha 1 - 12 x 10
bitmapRocha1 db 4 dup(0FFh),3 dup(07h),5 dup(0FFh) ; Linha 1 de bitmapRocha1: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 3 dup(0FFh),07h,2 dup(0Fh),2 dup(07h),4 dup(0FFh) ; Linha 2 de bitmapRocha1: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 2 dup(0FFh),07h,2 dup(0Fh),2 dup(07h),08h,07h,3 dup(0FFh) ; Linha 3 de bitmapRocha1: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 2 dup(0FFh),07h,0Fh,2 dup(07h),2 dup(08h),07h,3 dup(0FFh) ; Linha 4 de bitmapRocha1: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 0FFh,07h,0Fh,2 dup(07h),4 dup(08h),07h,2 dup(0FFh) ; Linha 5 de bitmapRocha1: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 0FFh,3 dup(07h),5 dup(08h),07h,2 dup(0FFh) ; Linha 6 de bitmapRocha1: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 2 dup(07h),8 dup(08h),07h,0FFh ; Linha 7 de bitmapRocha1: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 07h,3 dup(08h),07h,6 dup(08h),07h ; Linha 8 de bitmapRocha1: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 07h,10 dup(08h),07h ; Linha 9 de bitmapRocha1: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 12 dup(08h) ; Linha 10 de bitmapRocha1: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
bitmapRocha1Fim label byte ; Marca esta posicao sem reservar bytes; permite delimitar e medir o bloco de dados.
; Rocha 2 - 12 x 10
bitmapRocha2 db 5 dup(0FFh),2 dup(06h),5 dup(0FFh) ; Linha 1 de bitmapRocha2: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 4 dup(0FFh),06h,2 dup(0Eh),06h,4 dup(0FFh) ; Linha 2 de bitmapRocha2: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 3 dup(0FFh),06h,2 dup(0Eh),3 dup(06h),3 dup(0FFh) ; Linha 3 de bitmapRocha2: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 2 dup(0FFh),06h,2 dup(0Eh),5 dup(06h),2 dup(0FFh) ; Linha 4 de bitmapRocha2: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 0FFh,06h,2 dup(0Eh),7 dup(06h),0FFh ; Linha 5 de bitmapRocha2: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 06h,2 dup(0Eh),9 dup(06h) ; Linha 6 de bitmapRocha2: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 06h,0Eh,10 dup(06h) ; Linha 7 de bitmapRocha2: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 0FFh,10 dup(06h),0FFh ; Linha 8 de bitmapRocha2: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 2 dup(0FFh),8 dup(06h),2 dup(0FFh) ; Linha 9 de bitmapRocha2: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 3 dup(0FFh),6 dup(06h),3 dup(0FFh) ; Linha 10 de bitmapRocha2: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
bitmapRocha2Fim label byte ; Marca esta posicao sem reservar bytes; permite delimitar e medir o bloco de dados.
; Rocha 3 - 12 x 10
bitmapRocha3 db 2 dup(0FFh),03h,6 dup(0FFh),03h,2 dup(0FFh) ; Linha 1 de bitmapRocha3: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 2 dup(0FFh),0Bh,03h,4 dup(0FFh),0Bh,03h,2 dup(0FFh) ; Linha 2 de bitmapRocha3: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 0FFh,2 dup(0Bh),2 dup(03h),2 dup(0FFh),2 dup(0Bh),2 dup(03h),0FFh ; Linha 3 de bitmapRocha3: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 0FFh,2 dup(0Bh),2 dup(03h),0FFh,3 dup(0Bh),2 dup(03h),0FFh ; Linha 4 de bitmapRocha3: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 3 dup(0Bh),2 dup(03h),0FFh,2 dup(0Bh),3 dup(03h),0FFh ; Linha 5 de bitmapRocha3: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 2 dup(0Bh),3 dup(03h),3 dup(0Bh),3 dup(03h),0FFh ; Linha 6 de bitmapRocha3: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 2 dup(0Bh),3 dup(03h),2 dup(0Bh),5 dup(03h) ; Linha 7 de bitmapRocha3: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 0Bh,4 dup(03h),0Bh,6 dup(03h) ; Linha 8 de bitmapRocha3: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 12 dup(03h) ; Linha 9 de bitmapRocha3: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 12 dup(03h) ; Linha 10 de bitmapRocha3: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
bitmapRocha3Fim label byte ; Marca esta posicao sem reservar bytes; permite delimitar e medir o bloco de dados.
; Rocha 4 - 12 x 10
bitmapRocha4 db 3 dup(0FFh),6 dup(04h),3 dup(0FFh) ; Linha 1 de bitmapRocha4: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 2 dup(0FFh),04h,2 dup(0Ch),5 dup(04h),2 dup(0FFh) ; Linha 2 de bitmapRocha4: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 0FFh,04h,2 dup(0Ch),7 dup(04h),0FFh ; Linha 3 de bitmapRocha4: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 0FFh,04h,0Ch,3 dup(04h),0Ch,4 dup(04h),0FFh ; Linha 4 de bitmapRocha4: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 04h,2 dup(0Ch),2 dup(04h),0Ch,6 dup(04h) ; Linha 5 de bitmapRocha4: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 04h,0Ch,3 dup(04h),2 dup(0Ch),5 dup(04h) ; Linha 6 de bitmapRocha4: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 6 dup(04h),0Ch,5 dup(04h) ; Linha 7 de bitmapRocha4: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 5 dup(04h),0Ch,6 dup(04h) ; Linha 8 de bitmapRocha4: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 0FFh,4 dup(04h),2 dup(0Ch),4 dup(04h),0FFh ; Linha 9 de bitmapRocha4: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 2 dup(0FFh),8 dup(04h),2 dup(0FFh) ; Linha 10 de bitmapRocha4: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
bitmapRocha4Fim label byte ; Marca esta posicao sem reservar bytes; permite delimitar e medir o bloco de dados.
bitmapsFim label byte ; Marca esta posicao sem reservar bytes; permite delimitar e medir o bloco de dados.
; Montanhas - 320 x 64
bitmapMontanhas db 149 dup(0FFh),5 dup(09h),166 dup(0FFh) ; Linha 1 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 148 dup(0FFh),7 dup(09h),165 dup(0FFh) ; Linha 2 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 147 dup(0FFh),5 dup(09h),01h,3 dup(09h),164 dup(0FFh) ; Linha 3 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 146 dup(0FFh),5 dup(09h),01h,09h,01h,3 dup(09h),163 dup(0FFh) ; Linha 4 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 145 dup(0FFh),7 dup(09h),01h,09h,01h,3 dup(09h),162 dup(0FFh) ; Linha 5 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 42 dup(0FFh),3 dup(09h),99 dup(0FFh),9 dup(09h),01h,5 dup(09h),161 dup(0FFh) ; Linha 6 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 41 dup(0FFh),6 dup(09h),97 dup(0FFh),10 dup(09h),01h,5 dup(09h),160 dup(0FFh) ; Linha 7 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 40 dup(0FFh),3 dup(09h),01h,4 dup(09h),95 dup(0FFh),10 dup(09h),01h,09h,01h,5 dup(09h),159 dup(0FFh) ; Linha 8 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 39 dup(0FFh),5 dup(09h),01h,4 dup(09h),93 dup(0FFh),12 dup(09h),01h,09h,01h,4 dup(09h),159 dup(0FFh) ; Linha 9 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 38 dup(0FFh),7 dup(09h),01h,4 dup(09h),92 dup(0FFh),13 dup(09h),01h,6 dup(09h),104 dup(0FFh),5 dup(09h),49 dup(0FFh) ; Linha 10 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 38 dup(0FFh),6 dup(09h),01h,09h,01h,4 dup(09h),90 dup(0FFh),13 dup(09h),01h,09h,01h,6 dup(09h),101 dup(0FFh),9 dup(09h),47 dup(0FFh) ; Linha 11 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 37 dup(0FFh),8 dup(09h),01h,09h,01h,3 dup(09h),90 dup(0FFh),13 dup(09h),2 dup(01h),09h,01h,5 dup(09h),100 dup(0FFh),6 dup(09h),01h,4 dup(09h),46 dup(0FFh) ; Linha 12 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 37 dup(0FFh),9 dup(09h),01h,5 dup(09h),88 dup(0FFh),15 dup(09h),2 dup(01h),09h,01h,5 dup(09h),98 dup(0FFh),6 dup(09h),01h,09h,01h,4 dup(09h),45 dup(0FFh) ; Linha 13 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 36 dup(0FFh),11 dup(09h),01h,5 dup(09h),87 dup(0FFh),15 dup(09h),01h,09h,01h,6 dup(09h),97 dup(0FFh),8 dup(09h),01h,09h,01h,4 dup(09h),44 dup(0FFh) ; Linha 14 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 36 dup(0FFh),10 dup(09h),01h,09h,01h,4 dup(09h),86 dup(0FFh),17 dup(09h),01h,09h,01h,6 dup(09h),95 dup(0FFh),10 dup(09h),01h,6 dup(09h),43 dup(0FFh) ; Linha 15 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 35 dup(0FFh),11 dup(09h),2 dup(01h),09h,01h,4 dup(09h),85 dup(0FFh),16 dup(09h),3 dup(01h),09h,01h,6 dup(09h),38 dup(0FFh),5 dup(09h),50 dup(0FFh),12 dup(09h),01h,6 dup(09h),42 dup(0FFh) ; Linha 16 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 35 dup(0FFh),11 dup(09h),01h,09h,01h,5 dup(09h),84 dup(0FFh),18 dup(09h),3 dup(01h),09h,01h,5 dup(09h),36 dup(0FFh),9 dup(09h),48 dup(0FFh),11 dup(09h),01h,09h,01h,6 dup(09h),41 dup(0FFh) ; Linha 17 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 34 dup(0FFh),13 dup(09h),01h,09h,01h,5 dup(09h),83 dup(0FFh),18 dup(09h),2 dup(01h),09h,01h,7 dup(09h),33 dup(0FFh),7 dup(09h),01h,5 dup(09h),45 dup(0FFh),13 dup(09h),01h,09h,01h,5 dup(09h),41 dup(0FFh) ; Linha 18 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 33 dup(0FFh),14 dup(09h),2 dup(01h),09h,01h,5 dup(09h),37 dup(0FFh),4 dup(09h),40 dup(0FFh),20 dup(09h),2 dup(01h),09h,01h,7 dup(09h),31 dup(0FFh),7 dup(09h),01h,09h,01h,5 dup(09h),43 dup(0FFh),15 dup(09h),01h,7 dup(09h),40 dup(0FFh) ; Linha 19 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 33 dup(0FFh),15 dup(09h),2 dup(01h),09h,01h,4 dup(09h),35 dup(0FFh),8 dup(09h),38 dup(0FFh),20 dup(09h),3 dup(01h),09h,01h,6 dup(09h),30 dup(0FFh),9 dup(09h),01h,09h,01h,5 dup(09h),41 dup(0FFh),15 dup(09h),01h,09h,01h,7 dup(09h),39 dup(0FFh) ; Linha 20 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 32 dup(0FFh),15 dup(09h),2 dup(01h),09h,01h,6 dup(09h),33 dup(0FFh),6 dup(09h),01h,3 dup(09h),36 dup(0FFh),21 dup(09h),4 dup(01h),09h,01h,6 dup(09h),28 dup(0FFh),11 dup(09h),01h,7 dup(09h),40 dup(0FFh),15 dup(09h),2 dup(01h),09h,01h,7 dup(09h),38 dup(0FFh) ; Linha 21 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 32 dup(0FFh),16 dup(09h),2 dup(01h),09h,01h,5 dup(09h),32 dup(0FFh),6 dup(09h),01h,09h,01h,3 dup(09h),35 dup(0FFh),21 dup(09h),3 dup(01h),09h,01h,7 dup(09h),27 dup(0FFh),13 dup(09h),01h,7 dup(09h),38 dup(0FFh),17 dup(09h),2 dup(01h),09h,01h,7 dup(09h),37 dup(0FFh) ; Linha 22 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 31 dup(0FFh),17 dup(09h),3 dup(01h),09h,01h,5 dup(09h),30 dup(0FFh),8 dup(09h),01h,09h,01h,3 dup(09h),33 dup(0FFh),23 dup(09h),3 dup(01h),09h,01h,7 dup(09h),25 dup(0FFh),13 dup(09h),01h,09h,01h,7 dup(09h),36 dup(0FFh),18 dup(09h),01h,09h,01h,8 dup(09h),37 dup(0FFh) ; Linha 23 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 31 dup(0FFh),18 dup(09h),3 dup(01h),09h,01h,4 dup(09h),29 dup(0FFh),10 dup(09h),01h,5 dup(09h),32 dup(0FFh),23 dup(09h),4 dup(01h),09h,01h,7 dup(09h),23 dup(0FFh),15 dup(09h),01h,09h,01h,7 dup(09h),35 dup(0FFh),19 dup(09h),01h,09h,01h,8 dup(09h),36 dup(0FFh) ; Linha 24 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 30 dup(0FFh),19 dup(09h),2 dup(01h),09h,01h,6 dup(09h),27 dup(0FFh),12 dup(09h),01h,4 dup(09h),31 dup(0FFh),25 dup(09h),4 dup(01h),09h,01h,6 dup(09h),21 dup(0FFh),18 dup(09h),01h,8 dup(09h),34 dup(0FFh),19 dup(09h),3 dup(01h),09h,01h,8 dup(09h),35 dup(0FFh) ; Linha 25 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 30 dup(0FFh),19 dup(09h),3 dup(01h),09h,01h,6 dup(09h),25 dup(0FFh),12 dup(09h),01h,09h,01h,4 dup(09h),30 dup(0FFh),24 dup(09h),4 dup(01h),09h,01h,8 dup(09h),19 dup(0FFh),18 dup(09h),01h,09h,01h,8 dup(09h),32 dup(0FFh),21 dup(09h),3 dup(01h),09h,01h,8 dup(09h),34 dup(0FFh) ; Linha 26 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 29 dup(0FFh),20 dup(09h),4 dup(01h),09h,01h,5 dup(09h),24 dup(0FFh),14 dup(09h),01h,09h,01h,4 dup(09h),28 dup(0FFh),26 dup(09h),4 dup(01h),09h,01h,8 dup(09h),17 dup(0FFh),19 dup(09h),2 dup(01h),09h,01h,8 dup(09h),31 dup(0FFh),21 dup(09h),2 dup(01h),09h,01h,10 dup(09h),33 dup(0FFh) ; Linha 27 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 28 dup(0FFh),22 dup(09h),4 dup(01h),09h,01h,5 dup(09h),22 dup(0FFh),16 dup(09h),01h,5 dup(09h),28 dup(0FFh),26 dup(09h),5 dup(01h),09h,01h,8 dup(09h),15 dup(0FFh),21 dup(09h),2 dup(01h),09h,01h,8 dup(09h),29 dup(0FFh),23 dup(09h),2 dup(01h),09h,01h,10 dup(09h),32 dup(0FFh) ; Linha 28 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 27 dup(0FFh),23 dup(09h),3 dup(01h),09h,01h,6 dup(09h),21 dup(0FFh),16 dup(09h),01h,09h,01h,5 dup(09h),26 dup(0FFh),28 dup(09h),5 dup(01h),09h,01h,8 dup(09h),13 dup(0FFh),22 dup(09h),01h,09h,01h,10 dup(09h),27 dup(0FFh),24 dup(09h),3 dup(01h),09h,01h,10 dup(09h),31 dup(0FFh) ; Linha 29 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 26 dup(0FFh),25 dup(09h),3 dup(01h),09h,01h,6 dup(09h),19 dup(0FFh),17 dup(09h),2 dup(01h),09h,01h,5 dup(09h),25 dup(0FFh),28 dup(09h),4 dup(01h),09h,01h,10 dup(09h),11 dup(0FFh),24 dup(09h),01h,09h,01h,10 dup(09h),26 dup(0FFh),24 dup(09h),4 dup(01h),09h,01h,11 dup(09h),29 dup(0FFh) ; Linha 30 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 22 dup(0FFh),28 dup(09h),5 dup(01h),09h,01h,6 dup(09h),17 dup(0FFh),19 dup(09h),2 dup(01h),09h,01h,4 dup(09h),24 dup(0FFh),29 dup(09h),5 dup(01h),09h,01h,10 dup(09h),8 dup(0FFh),25 dup(09h),3 dup(01h),09h,01h,10 dup(09h),24 dup(0FFh),25 dup(09h),3 dup(01h),09h,01h,18 dup(09h),23 dup(0FFh) ; Linha 31 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 19 dup(0FFh),32 dup(09h),5 dup(01h),09h,01h,5 dup(09h),16 dup(0FFh),20 dup(09h),01h,09h,01h,6 dup(09h),23 dup(0FFh),29 dup(09h),6 dup(01h),09h,01h,10 dup(09h),5 dup(0FFh),28 dup(09h),3 dup(01h),09h,01h,9 dup(09h),23 dup(0FFh),27 dup(09h),3 dup(01h),09h,01h,19 dup(09h),21 dup(0FFh) ; Linha 32 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 17 dup(0FFh),34 dup(09h),4 dup(01h),09h,01h,7 dup(09h),14 dup(0FFh),22 dup(09h),01h,09h,01h,5 dup(09h),22 dup(0FFh),31 dup(09h),6 dup(01h),09h,01h,42 dup(09h),2 dup(01h),09h,01h,11 dup(09h),21 dup(0FFh),28 dup(09h),4 dup(01h),09h,01h,20 dup(09h),19 dup(0FFh) ; Linha 33 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 16 dup(0FFh),36 dup(09h),4 dup(01h),09h,01h,7 dup(09h),12 dup(0FFh),22 dup(09h),3 dup(01h),09h,01h,5 dup(09h),21 dup(0FFh),31 dup(09h),5 dup(01h),09h,01h,44 dup(09h),2 dup(01h),09h,01h,11 dup(09h),20 dup(0FFh),29 dup(09h),4 dup(01h),09h,01h,21 dup(09h),17 dup(0FFh) ; Linha 34 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 15 dup(0FFh),37 dup(09h),5 dup(01h),09h,01h,7 dup(09h),10 dup(0FFh),24 dup(09h),3 dup(01h),09h,01h,5 dup(09h),19 dup(0FFh),33 dup(09h),5 dup(01h),09h,01h,43 dup(09h),3 dup(01h),09h,01h,11 dup(09h),18 dup(0FFh),29 dup(09h),4 dup(01h),09h,01h,23 dup(09h),16 dup(0FFh) ; Linha 35 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 13 dup(0FFh),39 dup(09h),6 dup(01h),09h,01h,7 dup(09h),8 dup(0FFh),25 dup(09h),2 dup(01h),09h,01h,6 dup(09h),19 dup(0FFh),32 dup(09h),7 dup(01h),09h,01h,42 dup(09h),4 dup(01h),09h,01h,11 dup(09h),16 dup(0FFh),31 dup(09h),4 dup(01h),09h,01h,24 dup(09h),14 dup(0FFh) ; Linha 36 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 12 dup(0FFh),40 dup(09h),5 dup(01h),09h,01h,10 dup(09h),4 dup(0FFh),28 dup(09h),2 dup(01h),09h,01h,6 dup(09h),17 dup(0FFh),34 dup(09h),7 dup(01h),09h,01h,41 dup(09h),3 dup(01h),09h,01h,13 dup(09h),14 dup(0FFh),32 dup(09h),5 dup(01h),09h,01h,24 dup(09h),13 dup(0FFh) ; Linha 37 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 10 dup(0FFh),43 dup(09h),5 dup(01h),09h,01h,41 dup(09h),3 dup(01h),09h,01h,6 dup(09h),15 dup(0FFh),35 dup(09h),6 dup(01h),09h,01h,43 dup(09h),3 dup(01h),09h,01h,13 dup(09h),12 dup(0FFh),34 dup(09h),5 dup(01h),09h,01h,25 dup(09h),11 dup(0FFh) ; Linha 38 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 9 dup(0FFh),44 dup(09h),6 dup(01h),09h,01h,40 dup(09h),4 dup(01h),09h,01h,5 dup(09h),15 dup(0FFh),36 dup(09h),6 dup(01h),09h,01h,42 dup(09h),4 dup(01h),09h,01h,14 dup(09h),9 dup(0FFh),35 dup(09h),4 dup(01h),09h,01h,27 dup(09h),10 dup(0FFh) ; Linha 39 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 8 dup(0FFh),46 dup(09h),6 dup(01h),09h,01h,39 dup(09h),3 dup(01h),09h,01h,7 dup(09h),13 dup(0FFh),37 dup(09h),7 dup(01h),09h,01h,42 dup(09h),4 dup(01h),09h,01h,15 dup(09h),5 dup(0FFh),37 dup(09h),5 dup(01h),09h,01h,28 dup(09h),8 dup(0FFh) ; Linha 40 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 6 dup(0FFh),47 dup(09h),6 dup(01h),09h,01h,41 dup(09h),3 dup(01h),09h,01h,7 dup(09h),11 dup(0FFh),38 dup(09h),8 dup(01h),09h,01h,40 dup(09h),4 dup(01h),09h,01h,58 dup(09h),6 dup(01h),09h,01h,29 dup(09h),6 dup(0FFh) ; Linha 41 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 3 dup(0FFh),51 dup(09h),6 dup(01h),09h,01h,40 dup(09h),4 dup(01h),09h,01h,7 dup(09h),9 dup(0FFh),39 dup(09h),7 dup(01h),09h,01h,42 dup(09h),4 dup(01h),09h,01h,58 dup(09h),6 dup(01h),09h,01h,30 dup(09h),4 dup(0FFh) ; Linha 42 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 54 dup(09h),7 dup(01h),09h,01h,40 dup(09h),4 dup(01h),09h,01h,7 dup(09h),7 dup(0FFh),41 dup(09h),7 dup(01h),09h,01h,41 dup(09h),5 dup(01h),09h,01h,57 dup(09h),5 dup(01h),09h,01h,35 dup(09h) ; Linha 43 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 55 dup(09h),7 dup(01h),09h,01h,38 dup(09h),4 dup(01h),09h,01h,10 dup(09h),4 dup(0FFh),42 dup(09h),8 dup(01h),09h,01h,41 dup(09h),5 dup(01h),09h,01h,57 dup(09h),5 dup(01h),09h,01h,34 dup(09h) ; Linha 44 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 55 dup(09h),6 dup(01h),09h,01h,40 dup(09h),4 dup(01h),09h,01h,56 dup(09h),8 dup(01h),09h,01h,40 dup(09h),4 dup(01h),09h,01h,57 dup(09h),7 dup(01h),09h,01h,33 dup(09h) ; Linha 45 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 55 dup(09h),7 dup(01h),09h,01h,39 dup(09h),5 dup(01h),09h,01h,54 dup(09h),8 dup(01h),09h,01h,41 dup(09h),5 dup(01h),09h,01h,57 dup(09h),7 dup(01h),09h,01h,32 dup(09h) ; Linha 46 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 55 dup(09h),8 dup(01h),09h,01h,39 dup(09h),5 dup(01h),09h,01h,54 dup(09h),8 dup(01h),09h,01h,40 dup(09h),6 dup(01h),09h,01h,56 dup(09h),6 dup(01h),09h,01h,33 dup(09h) ; Linha 47 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 56 dup(09h),8 dup(01h),09h,01h,38 dup(09h),4 dup(01h),09h,01h,55 dup(09h),9 dup(01h),09h,01h,40 dup(09h),6 dup(01h),09h,01h,56 dup(09h),6 dup(01h),09h,01h,32 dup(09h) ; Linha 48 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 56 dup(09h),7 dup(01h),09h,01h,39 dup(09h),5 dup(01h),09h,01h,55 dup(09h),9 dup(01h),09h,01h,39 dup(09h),5 dup(01h),09h,01h,57 dup(09h),7 dup(01h),09h,01h,31 dup(09h) ; Linha 49 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 57 dup(09h),7 dup(01h),09h,01h,38 dup(09h),6 dup(01h),09h,01h,54 dup(09h),8 dup(01h),09h,01h,41 dup(09h),5 dup(01h),09h,01h,56 dup(09h),8 dup(01h),09h,01h,30 dup(09h) ; Linha 50 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 56 dup(09h),9 dup(01h),09h,01h,38 dup(09h),6 dup(01h),09h,01h,53 dup(09h),9 dup(01h),09h,01h,39 dup(09h),7 dup(01h),09h,01h,55 dup(09h),7 dup(01h),09h,01h,31 dup(09h) ; Linha 51 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 57 dup(09h),9 dup(01h),09h,01h,37 dup(09h),5 dup(01h),09h,01h,54 dup(09h),10 dup(01h),09h,01h,39 dup(09h),7 dup(01h),09h,01h,55 dup(09h),7 dup(01h),09h,01h,30 dup(09h) ; Linha 52 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 57 dup(09h),8 dup(01h),09h,01h,39 dup(09h),5 dup(01h),09h,01h,54 dup(09h),10 dup(01h),09h,01h,38 dup(09h),6 dup(01h),09h,01h,56 dup(09h),8 dup(01h),09h,01h,29 dup(09h) ; Linha 53 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 58 dup(09h),8 dup(01h),09h,01h,37 dup(09h),7 dup(01h),09h,01h,53 dup(09h),9 dup(01h),09h,01h,40 dup(09h),6 dup(01h),09h,01h,56 dup(09h),8 dup(01h),09h,01h,28 dup(09h) ; Linha 54 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 58 dup(09h),9 dup(01h),09h,01h,37 dup(09h),7 dup(01h),09h,01h,53 dup(09h),9 dup(01h),09h,01h,39 dup(09h),7 dup(01h),09h,01h,54 dup(09h),8 dup(01h),09h,01h,29 dup(09h) ; Linha 55 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 58 dup(09h),10 dup(01h),09h,01h,36 dup(09h),6 dup(01h),09h,01h,53 dup(09h),11 dup(01h),09h,01h,38 dup(09h),8 dup(01h),09h,01h,54 dup(09h),8 dup(01h),09h,01h,28 dup(09h) ; Linha 56 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 58 dup(09h),9 dup(01h),09h,01h,38 dup(09h),6 dup(01h),09h,01h,53 dup(09h),11 dup(01h),09h,01h,37 dup(09h),7 dup(01h),09h,01h,55 dup(09h),9 dup(01h),09h,01h,27 dup(09h) ; Linha 57 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 59 dup(09h),9 dup(01h),09h,01h,37 dup(09h),7 dup(01h),09h,01h,52 dup(09h),10 dup(01h),09h,01h,39 dup(09h),7 dup(01h),09h,01h,55 dup(09h),9 dup(01h),09h,01h,26 dup(09h) ; Linha 58 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 59 dup(09h),10 dup(01h),09h,01h,36 dup(09h),8 dup(01h),09h,01h,52 dup(09h),10 dup(01h),09h,01h,38 dup(09h),8 dup(01h),09h,01h,54 dup(09h),8 dup(01h),09h,01h,27 dup(09h) ; Linha 59 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 60 dup(09h),10 dup(01h),09h,01h,35 dup(09h),7 dup(01h),09h,01h,53 dup(09h),11 dup(01h),09h,01h,38 dup(09h),8 dup(01h),09h,01h,53 dup(09h),9 dup(01h),09h,01h,26 dup(09h) ; Linha 60 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 59 dup(09h),10 dup(01h),09h,01h,37 dup(09h),7 dup(01h),09h,01h,52 dup(09h),12 dup(01h),09h,01h,36 dup(09h),8 dup(01h),09h,01h,54 dup(09h),10 dup(01h),09h,01h,25 dup(09h) ; Linha 61 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 60 dup(09h),10 dup(01h),09h,01h,36 dup(09h),8 dup(01h),09h,01h,51 dup(09h),11 dup(01h),09h,01h,38 dup(09h),8 dup(01h),09h,01h,54 dup(09h),10 dup(01h),09h,01h,24 dup(09h) ; Linha 62 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 320 dup(09h) ; Linha 63 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
                db 320 dup(09h) ; Linha 64 de bitmapMontanhas: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
bitmapMontanhasFim label byte ; Marca esta posicao sem reservar bytes; permite delimitar e medir o bloco de dados.
; Montes - 320 x 32
bitmapMontes db 173 dup(0FFh),7 dup(0Ah),140 dup(0FFh) ; Linha 1 de bitmapMontes: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 171 dup(0FFh),12 dup(0Ah),137 dup(0FFh) ; Linha 2 de bitmapMontes: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 169 dup(0FFh),7 dup(0Ah),02h,0Ah,02h,6 dup(0Ah),135 dup(0FFh) ; Linha 3 de bitmapMontes: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 167 dup(0FFh),10 dup(0Ah),02h,8 dup(0Ah),134 dup(0FFh) ; Linha 4 de bitmapMontes: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 53 dup(0FFh),8 dup(0Ah),104 dup(0FFh),13 dup(0Ah),02h,9 dup(0Ah),132 dup(0FFh) ; Linha 5 de bitmapMontes: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 50 dup(0FFh),14 dup(0Ah),100 dup(0FFh),13 dup(0Ah),02h,0Ah,02h,10 dup(0Ah),130 dup(0FFh) ; Linha 6 de bitmapMontes: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 48 dup(0FFh),8 dup(0Ah),02h,0Ah,02h,8 dup(0Ah),95 dup(0FFh),16 dup(0Ah),02h,0Ah,02h,10 dup(0Ah),129 dup(0FFh) ; Linha 7 de bitmapMontes: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 46 dup(0FFh),11 dup(0Ah),02h,11 dup(0Ah),92 dup(0FFh),18 dup(0Ah),02h,12 dup(0Ah),128 dup(0FFh) ; Linha 8 de bitmapMontes: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 44 dup(0FFh),14 dup(0Ah),02h,12 dup(0Ah),88 dup(0FFh),21 dup(0Ah),02h,13 dup(0Ah),126 dup(0FFh) ; Linha 9 de bitmapMontes: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 43 dup(0FFh),14 dup(0Ah),02h,0Ah,02h,13 dup(0Ah),84 dup(0FFh),22 dup(0Ah),02h,0Ah,02h,14 dup(0Ah),70 dup(0FFh),8 dup(0Ah),46 dup(0FFh) ; Linha 10 de bitmapMontes: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 41 dup(0FFh),17 dup(0Ah),02h,0Ah,02h,14 dup(0Ah),80 dup(0FFh),24 dup(0Ah),2 dup(02h),0Ah,02h,14 dup(0Ah),67 dup(0FFh),13 dup(0Ah),43 dup(0FFh) ; Linha 11 de bitmapMontes: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 39 dup(0FFh),20 dup(0Ah),02h,17 dup(0Ah),76 dup(0FFh),26 dup(0Ah),02h,0Ah,02h,17 dup(0Ah),63 dup(0FFh),7 dup(0Ah),02h,0Ah,02h,8 dup(0Ah),40 dup(0FFh) ; Linha 12 de bitmapMontes: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 38 dup(0FFh),22 dup(0Ah),02h,18 dup(0Ah),67 dup(0FFh),34 dup(0Ah),02h,0Ah,02h,19 dup(0Ah),58 dup(0FFh),10 dup(0Ah),02h,12 dup(0Ah),37 dup(0FFh) ; Linha 13 de bitmapMontes: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 36 dup(0FFh),23 dup(0Ah),02h,0Ah,02h,20 dup(0Ah),61 dup(0FFh),37 dup(0Ah),2 dup(02h),0Ah,02h,26 dup(0Ah),49 dup(0FFh),12 dup(0Ah),02h,13 dup(0Ah),35 dup(0FFh) ; Linha 14 de bitmapMontes: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 34 dup(0FFh),25 dup(0Ah),2 dup(02h),0Ah,02h,22 dup(0Ah),56 dup(0FFh),40 dup(0Ah),2 dup(02h),0Ah,02h,29 dup(0Ah),44 dup(0FFh),12 dup(0Ah),02h,0Ah,02h,15 dup(0Ah),32 dup(0FFh) ; Linha 15 de bitmapMontes: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 32 dup(0FFh),27 dup(0Ah),02h,0Ah,02h,31 dup(0Ah),46 dup(0FFh),41 dup(0Ah),2 dup(02h),0Ah,02h,32 dup(0Ah),40 dup(0FFh),15 dup(0Ah),02h,0Ah,02h,17 dup(0Ah),29 dup(0FFh) ; Linha 16 de bitmapMontes: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 29 dup(0FFh),31 dup(0Ah),02h,0Ah,02h,33 dup(0Ah),41 dup(0FFh),44 dup(0Ah),2 dup(02h),0Ah,02h,34 dup(0Ah),36 dup(0FFh),17 dup(0Ah),02h,26 dup(0Ah),21 dup(0FFh) ; Linha 17 de bitmapMontes: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 21 dup(0FFh),39 dup(0Ah),2 dup(02h),0Ah,02h,34 dup(0Ah),37 dup(0FFh),46 dup(0Ah),3 dup(02h),0Ah,02h,35 dup(0Ah),33 dup(0FFh),19 dup(0Ah),02h,29 dup(0Ah),17 dup(0FFh) ; Linha 18 de bitmapMontes: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 17 dup(0FFh),44 dup(0Ah),2 dup(02h),0Ah,02h,35 dup(0Ah),34 dup(0FFh),48 dup(0Ah),3 dup(02h),0Ah,02h,36 dup(0Ah),29 dup(0FFh),20 dup(0Ah),02h,0Ah,02h,30 dup(0Ah),15 dup(0FFh) ; Linha 19 de bitmapMontes: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 14 dup(0FFh),46 dup(0Ah),2 dup(02h),0Ah,02h,37 dup(0Ah),31 dup(0FFh),50 dup(0Ah),2 dup(02h),0Ah,02h,39 dup(0Ah),26 dup(0FFh),21 dup(0Ah),2 dup(02h),0Ah,02h,31 dup(0Ah),13 dup(0FFh) ; Linha 20 de bitmapMontes: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 12 dup(0FFh),49 dup(0Ah),2 dup(02h),0Ah,02h,38 dup(0Ah),28 dup(0FFh),51 dup(0Ah),3 dup(02h),0Ah,02h,40 dup(0Ah),23 dup(0FFh),22 dup(0Ah),02h,0Ah,02h,35 dup(0Ah),10 dup(0FFh) ; Linha 21 de bitmapMontes: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 9 dup(0FFh),52 dup(0Ah),3 dup(02h),0Ah,02h,39 dup(0Ah),24 dup(0FFh),53 dup(0Ah),4 dup(02h),0Ah,02h,42 dup(0Ah),18 dup(0FFh),25 dup(0Ah),02h,0Ah,02h,36 dup(0Ah),8 dup(0FFh) ; Linha 22 de bitmapMontes: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 5 dup(0FFh),57 dup(0Ah),3 dup(02h),0Ah,02h,39 dup(0Ah),21 dup(0FFh),56 dup(0Ah),4 dup(02h),0Ah,02h,43 dup(0Ah),14 dup(0FFh),27 dup(0Ah),2 dup(02h),0Ah,02h,39 dup(0Ah),4 dup(0FFh) ; Linha 23 de bitmapMontes: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 62 dup(0Ah),2 dup(02h),0Ah,02h,42 dup(0Ah),17 dup(0FFh),58 dup(0Ah),3 dup(02h),0Ah,02h,48 dup(0Ah),8 dup(0FFh),30 dup(0Ah),2 dup(02h),0Ah,02h,42 dup(0Ah) ; Linha 24 de bitmapMontes: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 62 dup(0Ah),3 dup(02h),0Ah,02h,43 dup(0Ah),13 dup(0FFh),61 dup(0Ah),3 dup(02h),0Ah,02h,84 dup(0Ah),2 dup(02h),0Ah,02h,43 dup(0Ah) ; Linha 25 de bitmapMontes: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 62 dup(0Ah),4 dup(02h),0Ah,02h,45 dup(0Ah),7 dup(0FFh),63 dup(0Ah),5 dup(02h),0Ah,02h,84 dup(0Ah),2 dup(02h),0Ah,02h,42 dup(0Ah) ; Linha 26 de bitmapMontes: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 63 dup(0Ah),4 dup(02h),0Ah,02h,115 dup(0Ah),5 dup(02h),0Ah,02h,83 dup(0Ah),3 dup(02h),0Ah,02h,41 dup(0Ah) ; Linha 27 de bitmapMontes: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 63 dup(0Ah),3 dup(02h),0Ah,02h,116 dup(0Ah),4 dup(02h),0Ah,02h,85 dup(0Ah),3 dup(02h),0Ah,02h,40 dup(0Ah) ; Linha 28 de bitmapMontes: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 64 dup(0Ah),3 dup(02h),0Ah,02h,116 dup(0Ah),4 dup(02h),0Ah,02h,84 dup(0Ah),2 dup(02h),0Ah,02h,41 dup(0Ah) ; Linha 29 de bitmapMontes: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 63 dup(0Ah),5 dup(02h),0Ah,02h,115 dup(0Ah),5 dup(02h),0Ah,02h,83 dup(0Ah),3 dup(02h),0Ah,02h,40 dup(0Ah) ; Linha 30 de bitmapMontes: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 320 dup(0Ah) ; Linha 31 de bitmapMontes: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
             db 320 dup(0Ah) ; Linha 32 de bitmapMontes: cores da esquerda para a direita; DUP repete pixels, FFh preserva o fundo.
bitmapMontesFim label byte ; Marca esta posicao sem reservar bytes; permite delimitar e medir o bloco de dados.
; ARTES_FIM

; TAAG: Mini / Moon Patrol
arteTitulo db '                     _                 ' ; Guarda caracteres de arteTitulo; sao dados para a BIOS imprimir, nao instrucoes do processador.
           db ' |\/|  _   _  ._    |_) _. _|_ ._ _  | ' ; Guarda caracteres de arteTitulo; sao dados para a BIOS imprimir, nao instrucoes do processador.
           db ' |  | (_) (_) | |   |  (_|  |_ | (_) | ' ; Guarda caracteres de arteTitulo; sao dados para a BIOS imprimir, nao instrucoes do processador.
           db '                                       ' ; Guarda caracteres de arteTitulo; sao dados para a BIOS imprimir, nao instrucoes do processador.
TITULO_LARG equ 39 ; Largura em caracteres do bloco ASCII; usada para centralizar e avancar entre linhas.
TITULO_ALT equ 4 ; Numero de linhas do bloco ASCII; orienta quantas chamadas de texto serao feitas.
; TAAG: Small / GAME
arteGame db '   ___   _   __  __ ___ ' ; Guarda caracteres de arteGame; sao dados para a BIOS imprimir, nao instrucoes do processador.
           db '  / __| /_\ |  \/  | __|' ; Guarda caracteres de arteGame; sao dados para a BIOS imprimir, nao instrucoes do processador.
           db ' | (_ |/ _ \| |\/| | _| ' ; Guarda caracteres de arteGame; sao dados para a BIOS imprimir, nao instrucoes do processador.
           db '  \___/_/ \_\_|  |_|___|' ; Guarda caracteres de arteGame; sao dados para a BIOS imprimir, nao instrucoes do processador.
           db '                        ' ; Guarda caracteres de arteGame; sao dados para a BIOS imprimir, nao instrucoes do processador.
GAME_LARG equ 24 ; Largura em caracteres do bloco ASCII; usada para centralizar e avancar entre linhas.
GAME_ALT equ 5 ; Numero de linhas do bloco ASCII; orienta quantas chamadas de texto serao feitas.
; TAAG: Small / OVER
arteOver db '   _____   _____ ___ ' ; Guarda caracteres de arteOver; sao dados para a BIOS imprimir, nao instrucoes do processador.
           db '  / _ \ \ / / __| _ \' ; Guarda caracteres de arteOver; sao dados para a BIOS imprimir, nao instrucoes do processador.
           db ' | (_) \ V /| _||   /' ; Guarda caracteres de arteOver; sao dados para a BIOS imprimir, nao instrucoes do processador.
           db '  \___/ \_/ |___|_|_\' ; Guarda caracteres de arteOver; sao dados para a BIOS imprimir, nao instrucoes do processador.
           db '                     ' ; Guarda caracteres de arteOver; sao dados para a BIOS imprimir, nao instrucoes do processador.
OVER_LARG equ 21 ; Largura em caracteres do bloco ASCII; usada para centralizar e avancar entre linhas.
OVER_ALT equ 5 ; Numero de linhas do bloco ASCII; orienta quantas chamadas de texto serao feitas.

caixaJogar db 218,9 dup(196),191 ; Codigos de caracteres de borda formam a moldura de caixaJogar; DUP repete os tracos horizontais.
           db 179,'  Jogar  ',179 ; Guarda caracteres de caixaJogar; sao dados para a BIOS imprimir, nao instrucoes do processador.
           db 192,9 dup(196),217 ; Codigos de caracteres de borda formam a moldura de caixaJogar; DUP repete os tracos horizontais.
caixaSair  db 218,9 dup(196),191 ; Codigos de caracteres de borda formam a moldura de caixaSair; DUP repete os tracos horizontais.
           db 179,'  Sair   ',179 ; Guarda caracteres de caixaSair; sao dados para a BIOS imprimir, nao instrucoes do processador.
           db 192,9 dup(196),217 ; Codigos de caracteres de borda formam a moldura de caixaSair; DUP repete os tracos horizontais.
avisoArtes db 'ARTES AUTORAIS' ; Guarda caracteres de avisoArtes; sao dados para a BIOS imprimir, nao instrucoes do processador.
AVISO_TAM equ $-avisoArtes ; Calcula o tamanho pelos bytes ja declarados; mudar o texto atualiza o comprimento automaticamente.
ajudaMenu db 'Setas: selecionar   Enter: confirmar' ; Guarda caracteres de ajudaMenu; sao dados para a BIOS imprimir, nao instrucoes do processador.
AJUDA_TAM equ $-ajudaMenu ; Calcula o tamanho pelos bytes ja declarados; mudar o texto atualiza o comprimento automaticamente.
textoSetor db 'SETOR 1' ; Guarda caracteres de textoSetor; sao dados para a BIOS imprimir, nao instrucoes do processador.
SETOR_TAM equ $-textoSetor ; Calcula o tamanho pelos bytes ja declarados; mudar o texto atualiza o comprimento automaticamente.
textoObjetivo db 'Salte os obstaculos e sobreviva!' ; Guarda caracteres de textoObjetivo; sao dados para a BIOS imprimir, nao instrucoes do processador.
OBJETIVO_TAM equ $-textoObjetivo ; Calcula o tamanho pelos bytes ja declarados; mudar o texto atualiza o comprimento automaticamente.
textoAvanco db 'Enter: iniciar   Setas: mover/saltar' ; Guarda caracteres de textoAvanco; sao dados para a BIOS imprimir, nao instrucoes do processador.
AVANCO_TAM equ $-textoAvanco ; Calcula o tamanho pelos bytes ja declarados; mudar o texto atualiza o comprimento automaticamente.
textoTiros db 'Espaco: disparar os dois canhoes' ; Guarda caracteres de textoTiros; sao dados para a BIOS imprimir, nao instrucoes do processador.
TIROS_TAM equ $-textoTiros ; Calcula o tamanho pelos bytes ja declarados; mudar o texto atualiza o comprimento automaticamente.
textoRetorno db 'Qualquer tecla: voltar ao menu' ; Guarda caracteres de textoRetorno; sao dados para a BIOS imprimir, nao instrucoes do processador.
RETORNO_TAM equ $-textoRetorno ; Calcula o tamanho pelos bytes ja declarados; mudar o texto atualiza o comprimento automaticamente.
textoScore db 'SCORE: ' ; Guarda caracteres de textoScore; sao dados para a BIOS imprimir, nao instrucoes do processador.
digitosScore db SCORE_DIGITOS dup('0') ; Declara bytes (8 bits): cinco caracteres numericos anexados ao texto SCORE para imprimir juntos.
SCORE_TAM equ $-textoScore ; Calcula o tamanho pelos bytes ja declarados; mudar o texto atualiza o comprimento automaticamente.

.code ; Comeca a area das instrucoes; o DOS iniciara no procedimento indicado por END.
jumps                          ; TASM expande saltos longos em instrucoes 8086 | Permite ao TASM expandir saltos condicionais distantes sem exigir instrucoes posteriores ao 8086.
; Funcao: iniciar video, executar telas e devolver controle ao DOS.
; Entrada: nenhuma. Saida: codigo DOS 0, modo/pagina anteriores restaurados.
; Altera: registradores, segmentos e video. Partida completa com tiros.
inicio proc ; Por que: E01/E02: preparar o ambiente uma vez e escolher a acao de cada tela no laco principal.
    mov ax,@data ; Carrega em AX o segmento dos dados; o 8086 nao permite MOV DS com uma constante direta.
    mov ds,ax ; Faz DS apontar para as variaveis e bitmaps antes de qualquer acesso a eles.
    mov ah,0Fh ; Escolhe o servico BIOS que consulta o modo de video atual, antes de troca-lo.
    int 10h ; BIOS devolve o modo em AL e a pagina ativa em BH para restaurar na saida.
    mov modoAnterior,al ; Grava AL em modoAnterior: modo de video que estava ativo antes do jogo, para restaurar ao sair.
    mov paginaAnterior,bh ; Grava BH em paginaAnterior: pagina de video anterior, tambem restaurada na saida.
    mov ax,VIDEO_MODO ; AH=00h escolhe trocar modo; AL=13h escolhe a tela grafica 320x200.
    int 10h ; Solicita ao BIOS a entrada no modo grafico escolhido.
    mov ax,VIDEO_SEG ; Prepara A000h, segmento da memoria de pixels; registrador de segmento nao recebe constante direta.
    mov es,ax ; ES passa a apontar para o video; ES:DI sera usado pelas rotinas de desenho.
    cld ; DF=0: as instrucoes de bytes avancam os enderecos, em vez de andar para tras.
    call EntrarMenu ; Chama EntrarMenu para reiniciar menu, selecao, posicoes e relogio da animacao; CALL guarda onde voltar.
ciclo: ; Rotulo: destino dos saltos dentro de inicio; nao executa acao nem cria uma nova chamada.
    call LerTeclado ; Chama LerTeclado para consultar e consumir no maximo uma tecla, sem bloquear a animacao; CALL guarda onde voltar.
    cmp estado,ESTADO_SAIR ; Compara estado com ESTADO_SAIR sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je sair ; Vai a sair se estado for igual a ESTADO_SAIR.
    cmp estado,ESTADO_MENU ; Compara estado com ESTADO_MENU sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jne cicloPartida ; Vai a cicloPartida se estado for diferente de ESTADO_MENU.
    call AtualizarAnimacao ; Chama AtualizarAnimacao para mover somente quando decorrer o intervalo BIOS configurado; CALL guarda onde voltar.
    jmp ciclo ; Continua em ciclo sem criar retorno; pula o caminho que nao se aplica a este caso.
cicloPartida: ; Rotulo: destino dos saltos dentro de inicio; nao executa acao nem cria uma nova chamada.
    cmp estado,ESTADO_PARTIDA ; Compara estado com ESTADO_PARTIDA sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jne ciclo ; Vai a ciclo se estado for diferente de ESTADO_PARTIDA.
    call AtualizarPartida ; Chama AtualizarPartida para atualizar tempo a cada consulta e movimento em sua propria cadencia; CALL guarda onde voltar.
    jmp ciclo ; Continua em ciclo sem criar retorno; pula o caminho que nao se aplica a este caso.
sair: ; Rotulo: destino dos saltos dentro de inicio; nao executa acao nem cria uma nova chamada.
    call RestaurarTecladoJogo ; Chama RestaurarTecladoJogo para devolver INT 09h ao BIOS antes do Game Over/saida; CALL guarda onde voltar.
    xor ah,ah ; AH=00h seleciona o servico BIOS de definir o modo de video.
    mov al,modoAnterior ; Le modoAnterior em AL: modo de video que estava ativo antes do jogo, para restaurar ao sair.
    int 10h ; Restaura o modo que existia antes do jogo, sem restaurar o conteudo antigo da tela.
    mov ah,05h ; AH=05h seleciona a troca de pagina de video no BIOS.
    mov al,paginaAnterior ; Le paginaAnterior em AL: pagina de video anterior, tambem restaurada na saida.
    int 10h ; Restaura a pagina anteriormente ativa, alem do modo ja restaurado.
    mov ax,4C00h ; AH=4Ch encerra pelo DOS; AL=00h informa terminacao normal.
    int 21h ; Devolve o controle ao DOS; esta chamada nao retorna ao laco do jogo.
inicio endp ; Fecha a definicao de inicio no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: limpar os pixels por memoria, sem mudar o modo de video.
; Entrada: ES=video. Saida: 64000 bytes pretos. Altera: AX,CX,DI,flags.
LimparTela proc near ; Por que: E01: apagar por memoria atende a restricao de desenho do trabalho.
    cld ; DF=0 faz LODSB/MOVSB/STOSB avancarem os enderecos; evita copiar os pixels para tras.
    xor di,di ; DI=0 aponta para o primeiro pixel; ES ja aponta para A000h.
    mov al,COR_FUNDO ; AL recebe COR_FUNDO, cor que sera repetida no preenchimento de pixels.
    mov cx,TELA_BYTES ; Prepara 64000 repeticoes: ha um byte por pixel nos 320*200 pixels da tela.
    rep stosb ; Preenche 64000 bytes em ES:DI com preto; CX vai a zero e DI avanca a cada byte.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
LimparTela endp ; Fecha a definicao de LimparTela no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: imprimir texto BIOS, preservando ES de video para os bitmaps.
; Entrada: DS:SI=texto, CX=tamanho, DH=linha, DL=coluna, BL=cor.
; Saida: texto na pagina 0. Preserva: todos os registradores. Altera: flags.
EscreverTexto proc near ; Por que: E02: centralizar a chamada BIOS evita repetir sua preparacao em todas as telas.
    push ax ; Guarda AX do chamador antes de trocar AH/AL pelo numero do servico BIOS de texto.
    push bx ; Guarda BX: BH sera zerado para pagina 0 e BL contem a cor que o chamador pode reutilizar.
    push cx ; Guarda o comprimento do texto para que MostrarArte possa imprimir outras linhas da mesma largura.
    push dx ; Guarda linha/coluna; MostrarArte precisa recuperar DH para avancar a linha depois da chamada.
    push si ; Preserva o endereco do texto, usado pelo chamador para passar a proxima linha da arte.
    push di ; Preserva DI por contrato da rotina, protegendo os indices do chamador ao usar o BIOS.
    push bp ; Preserva BP: MostrarArte o usa como contador de linhas, mas a BIOS exige aqui o endereco do texto.
    push es ; Guarda ES (A000h, video) na pilha: a BIOS de texto exigira ES apontando para os dados.
    push ds ; Empilha o valor de DS para copia-lo para ES; MOV ES,DS nao existe no 8086.
    pop es ; Retira a copia de DS para ES: agora ES aponta para o segmento onde esta o texto.
    mov bp,si ; BP recebe o offset do texto de SI, porque a BIOS recebe a mensagem em ES:BP.
    xor bh,bh ; BH=0 escolhe a pagina de video zero; BL continua contendo a cor do texto.
    mov ax,1300h ; AH=13h escreve string; AL=00h usa cor em BL e nao atualiza a posicao do cursor.
    int 10h ; BIOS imprime CX caracteres de ES:BP na linha DH, coluna DL, com cor BL.
    pop es ; Recupera o ES salvo na linha 726: os proximos desenhos voltam a escrever no video A000h.
    pop bp ; Devolve BP ao chamador; em MostrarArte ele volta a ser a quantidade de linhas, nao o endereco do texto.
    pop di ; Recupera em DI o valor no topo da pilha, desfazendo o salvamento correspondente.
    pop si ; Recupera em SI o valor no topo da pilha, desfazendo o salvamento correspondente.
    pop dx ; Devolve a posicao original de texto para o chamador continuar a partir dela.
    pop cx ; Devolve o comprimento original, permitindo reutiliza-lo na proxima linha de texto.
    pop bx ; Recupera em BX o valor no topo da pilha, desfazendo o salvamento correspondente.
    pop ax ; Recupera em AX o valor no topo da pilha, desfazendo o salvamento correspondente.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
EscreverTexto endp ; Fecha a definicao de EscreverTexto no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: imprimir bloco ASCII retangular (titulo, GAME/OVER ou caixa).
; Entrada: como EscreverTexto, BP=numero de linhas, CX=largura fixa.
; Saida: bloco no video. Preserva: registradores. Altera: flags.
MostrarArte proc near ; Por que: E02: titulo e caixas sao varias linhas de texto; esta rotina reaproveita EscreverTexto.
    push si ; Guarda SI na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    push dx ; Guarda DX na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    push bp ; Guarda BP na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
arteLinha: ; Rotulo: destino dos saltos dentro de MostrarArte; nao executa acao nem cria uma nova chamada.
    call EscreverTexto ; Chama EscreverTexto para imprimir texto BIOS, preservando ES de video para os bitmaps; CALL guarda onde voltar.
    add si,cx ; Avanca SI pela largura em caracteres para apontar para a proxima linha da arte ASCII.
    inc dh ; Passa para a proxima linha de texto na tela; DH nao e uma coordenada em pixels.
    dec bp ; Consome uma linha da altura do bloco ASCII; BP controla quantas ainda faltam.
    jnz arteLinha ; Vai a arteLinha se o resultado/teste anterior for diferente de zero (ZF=0).
    pop bp ; Recupera em BP o valor no topo da pilha, desfazendo o salvamento correspondente.
    pop dx ; Recupera em DX o valor no topo da pilha, desfazendo o salvamento correspondente.
    pop si ; Recupera em SI o valor no topo da pilha, desfazendo o salvamento correspondente.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
MostrarArte endp ; Fecha a definicao de MostrarArte no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: descartar teclas antigas ao entrar em uma nova tela.
; Entrada: buffer BIOS. Saida: buffer vazio. Altera: AX,flags.
LimparTeclado proc near ; Por que: E01/E02: uma tecla antiga nao deve confirmar automaticamente a tela seguinte.
limparTecla: ; Rotulo: destino dos saltos dentro de LimparTeclado; nao executa acao nem cria uma nova chamada.
    mov ah,01h ; AH=01h consulta se existe tecla; nao espera o usuario apertar uma.
    int 16h ; BIOS atualiza ZF: 1 significa buffer vazio; consultar ainda nao retira a tecla.
    jz limparFim ; Se ZF=1, o buffer esta vazio e a limpeza terminou; nao devemos chamar uma leitura bloqueante.
    mov ah,00h ; AH=00h seleciona leitura/retirada; so chegamos aqui depois de detectar uma tecla.
    int 16h ; Consome a tecla antiga, para ela nao confirmar a proxima tela por acidente.
    jmp limparTecla ; Volta a consultar, pois pode haver varias teclas antigas enfileiradas.
limparFim: ; Rotulo: destino dos saltos dentro de LimparTeclado; nao executa acao nem cria uma nova chamada.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
LimparTeclado endp ; Fecha a definicao de LimparTeclado no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: reiniciar menu, selecao, posicoes e relogio da animacao.
; Entrada: DS=dados, ES=video. Saida: estado MENU, Jogar selecionado.
; Altera: AX,BX,CX,DX,SI,DI,BP,flags, dados e video.
EntrarMenu proc near ; Por que: E02: voltar ao menu deve restaurar a selecao e a animacao iniciais.
    call LimparTeclado ; Chama LimparTeclado para descartar teclas antigas ao entrar em uma nova tela; CALL guarda onde voltar.
    mov estado,ESTADO_MENU ; Grava ESTADO_MENU em estado: tela/fase atual do programa, que decide o caminho do laco principal.
    mov opcao,OPCAO_JOGAR ; Grava OPCAO_JOGAR em opcao: opcao selecionada no menu, Jogar ou Sair.
    mov scoreFinal,0 ; Grava 0 em scoreFinal: copia da pontuacao que sera apresentada no Game Over.
    xor di,di ; Zera DI para comecar pela primeira entrada/posicao percorrida nesta rotina.
menuReiniciar: ; Rotulo: destino dos saltos dentro de EntrarMenu; nao executa acao nem cria uma nova chamada.
    mov ax,menuXInicial[di] ; Le menuXInicial[di] em AX: colunas iniciais dos quatro desenhos, restauradas ao entrar no menu.
    mov menuX[di],ax ; Grava AX em menuX[di]: coluna atual de cada desenho animado do menu.
    add di,2 ; Avanca DI dois bytes para a proxima entrada word da tabela, sem misturar objetos.
    cmp di,MENU_QUANT*2 ; Compara DI com MENU_QUANT*2 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jb menuReiniciar ; Vai a menuReiniciar se DI for menor que (sem sinal) MENU_QUANT*2.
    call LimparTela ; Chama LimparTela para limpar os pixels por memoria, sem mudar o modo de video; CALL guarda onde voltar.
    lea si,arteTitulo ; Coloca em SI o offset de arteTitulo; passa o endereco do bloco, nao seu conteudo.
    mov cx,TITULO_LARG ; CX recebe TITULO_LARG: quantidade de pixels/caracteres a processar nesta chamada.
    mov bp,TITULO_ALT ; BP recebe TITULO_ALT, quantidade de linhas do bloco ASCII a imprimir.
    mov dx,TITULO_LINHA*256+(TEXTO_COLUNAS-TITULO_LARG)/2 ; Empacota a linha em DH e a coluna em DL; a conta com 40 colunas centraliza o texto quando indicada.
    mov bl,COR_TITULO ; BL recebe COR_TITULO; EscreverTexto/MostrarArte usara essa cor para os caracteres.
    call MostrarArte ; Chama MostrarArte para imprimir bloco ASCII retangular (titulo, GAME/OVER ou caixa); CALL guarda onde voltar.
    lea si,avisoArtes ; Coloca em SI o offset de avisoArtes; passa o endereco do bloco, nao seu conteudo.
    mov cx,AVISO_TAM ; Copia AVISO_TAM para CX, preparando esse valor para as instrucoes seguintes sem alterar a origem.
    mov dx,AVISO_LINHA*256+(TEXTO_COLUNAS-AVISO_TAM)/2 ; Empacota a linha em DH e a coluna em DL; a conta com 40 colunas centraliza o texto quando indicada.
    mov bl,COR_AVISO ; BL recebe COR_AVISO; EscreverTexto/MostrarArte usara essa cor para os caracteres.
    call EscreverTexto ; Chama EscreverTexto para imprimir texto BIOS, preservando ES de video para os bitmaps; CALL guarda onde voltar.
    lea si,ajudaMenu ; Coloca em SI o offset de ajudaMenu; passa o endereco do bloco, nao seu conteudo.
    mov cx,AJUDA_TAM ; Copia AJUDA_TAM para CX, preparando esse valor para as instrucoes seguintes sem alterar a origem.
    mov dx,AJUDA_LINHA*256+(TEXTO_COLUNAS-AJUDA_TAM)/2 ; Empacota a linha em DH e a coluna em DL; a conta com 40 colunas centraliza o texto quando indicada.
    mov bl,COR_BRANCO ; BL recebe COR_BRANCO; EscreverTexto/MostrarArte usara essa cor para os caracteres.
    call EscreverTexto ; Chama EscreverTexto para imprimir texto BIOS, preservando ES de video para os bitmaps; CALL guarda onde voltar.
    call DesenharOpcoes ; Chama DesenharOpcoes para redesenhar so as caixas, sem tocar na faixa da animacao; CALL guarda onde voltar.
    call CapturarEDesenharMenu ; Chama CapturarEDesenharMenu para salvar TODOS os fundos limpos e so depois desenhar os objetos; CALL guarda onde voltar.
    mov ah,00h ; Copia 00h para AH, preparando esse valor para as instrucoes seguintes sem alterar a origem.
    int 1Ah ; Consulta os ticks BIOS em CX:DX; DX fornece a amostra usada pela cadencia, sem esperar.
    mov ultimoTick,dx ; Grava DX em ultimoTick: tick da ultima animacao do menu, usado para controlar sua velocidade.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
EntrarMenu endp ; Fecha a definicao de EntrarMenu no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: redesenhar so as caixas, sem tocar na faixa da animacao.
; Entrada: opcao. Saida: selecionada 0Ch, outra 0Fh.
; Altera: BX,CX,DX,SI,BP,flags e video.
DesenharOpcoes proc near ; Por que: E02: trocar a cor da selecao sem apagar os objetos animados.
    mov cx,CAIXA_LARG ; CX recebe CAIXA_LARG: quantidade de pixels/caracteres a processar nesta chamada.
    mov bp,CAIXA_ALT ; BP recebe CAIXA_ALT, quantidade de linhas do bloco ASCII a imprimir.
    lea si,caixaJogar ; Coloca em SI o offset de caixaJogar; passa o endereco do bloco, nao seu conteudo.
    mov dx,CAIXA_JOGAR*256+CAIXA_COL ; Empacota a linha em DH e a coluna em DL; a conta com 40 colunas centraliza o texto quando indicada.
    mov bl,COR_BRANCO ; BL recebe COR_BRANCO; EscreverTexto/MostrarArte usara essa cor para os caracteres.
    cmp opcao,OPCAO_JOGAR ; Compara opcao com OPCAO_JOGAR sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jne opcaoDesenharJogar ; Vai a opcaoDesenharJogar se opcao for diferente de OPCAO_JOGAR.
    mov bl,COR_SELECAO ; BL recebe COR_SELECAO; EscreverTexto/MostrarArte usara essa cor para os caracteres.
opcaoDesenharJogar: ; Rotulo: destino dos saltos dentro de DesenharOpcoes; nao executa acao nem cria uma nova chamada.
    call MostrarArte ; Chama MostrarArte para imprimir bloco ASCII retangular (titulo, GAME/OVER ou caixa); CALL guarda onde voltar.
    lea si,caixaSair ; Coloca em SI o offset de caixaSair; passa o endereco do bloco, nao seu conteudo.
    mov dx,CAIXA_SAIR*256+CAIXA_COL ; Empacota a linha em DH e a coluna em DL; a conta com 40 colunas centraliza o texto quando indicada.
    mov bl,COR_BRANCO ; BL recebe COR_BRANCO; EscreverTexto/MostrarArte usara essa cor para os caracteres.
    cmp opcao,OPCAO_SAIR ; Compara opcao com OPCAO_SAIR sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jne opcaoDesenharSair ; Vai a opcaoDesenharSair se opcao for diferente de OPCAO_SAIR.
    mov bl,COR_SELECAO ; BL recebe COR_SELECAO; EscreverTexto/MostrarArte usara essa cor para os caracteres.
opcaoDesenharSair: ; Rotulo: destino dos saltos dentro de DesenharOpcoes; nao executa acao nem cria uma nova chamada.
    call MostrarArte ; Chama MostrarArte para imprimir bloco ASCII retangular (titulo, GAME/OVER ou caixa); CALL guarda onde voltar.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
DesenharOpcoes endp ; Fecha a definicao de DesenharOpcoes no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: apresentar o unico setor e aguardar Enter, escolha tecnica D04.
; Entrada: nenhuma. Saida: estado SETOR; o relogio da partida ainda nao corre.
; Altera: AX,BX,CX,DX,SI,DI,flags, estado e video.
EntrarSetor proc near ; Por que: E02/E07: apresentar o unico setor antes de iniciar a contagem; Enter e escolha D04.
    call LimparTeclado ; Chama LimparTeclado para descartar teclas antigas ao entrar em uma nova tela; CALL guarda onde voltar.
    mov estado,ESTADO_SETOR ; Grava ESTADO_SETOR em estado: tela/fase atual do programa, que decide o caminho do laco principal.
    call LimparTela ; Chama LimparTela para limpar os pixels por memoria, sem mudar o modo de video; CALL guarda onde voltar.
    lea si,textoSetor ; Coloca em SI o offset de textoSetor; passa o endereco do bloco, nao seu conteudo.
    mov cx,SETOR_TAM ; Copia SETOR_TAM para CX, preparando esse valor para as instrucoes seguintes sem alterar a origem.
    mov dx,SETOR_LINHA*256+(TEXTO_COLUNAS-SETOR_TAM)/2 ; Empacota a linha em DH e a coluna em DL; a conta com 40 colunas centraliza o texto quando indicada.
    mov bl,COR_TITULO ; BL recebe COR_TITULO; EscreverTexto/MostrarArte usara essa cor para os caracteres.
    call EscreverTexto ; Chama EscreverTexto para imprimir texto BIOS, preservando ES de video para os bitmaps; CALL guarda onde voltar.
    lea si,textoObjetivo ; Coloca em SI o offset de textoObjetivo; passa o endereco do bloco, nao seu conteudo.
    mov cx,OBJETIVO_TAM ; Copia OBJETIVO_TAM para CX, preparando esse valor para as instrucoes seguintes sem alterar a origem.
    mov dx,OBJETIVO_LINHA*256+(TEXTO_COLUNAS-OBJETIVO_TAM)/2 ; Empacota a linha em DH e a coluna em DL; a conta com 40 colunas centraliza o texto quando indicada.
    mov bl,COR_AVISO ; BL recebe COR_AVISO; EscreverTexto/MostrarArte usara essa cor para os caracteres.
    call EscreverTexto ; Chama EscreverTexto para imprimir texto BIOS, preservando ES de video para os bitmaps; CALL guarda onde voltar.
    lea si,textoAvanco ; Coloca em SI o offset de textoAvanco; passa o endereco do bloco, nao seu conteudo.
    mov cx,AVANCO_TAM ; Copia AVANCO_TAM para CX, preparando esse valor para as instrucoes seguintes sem alterar a origem.
    mov dx,AVANCO_LINHA*256+(TEXTO_COLUNAS-AVANCO_TAM)/2 ; Empacota a linha em DH e a coluna em DL; a conta com 40 colunas centraliza o texto quando indicada.
    mov bl,COR_BRANCO ; BL recebe COR_BRANCO; EscreverTexto/MostrarArte usara essa cor para os caracteres.
    call EscreverTexto ; Chama EscreverTexto para imprimir texto BIOS, preservando ES de video para os bitmaps; CALL guarda onde voltar.
    lea si,textoTiros ; Coloca em SI o offset de textoTiros; passa o endereco do bloco, nao seu conteudo.
    mov cx,TIROS_TAM ; Copia TIROS_TAM para CX, preparando esse valor para as instrucoes seguintes sem alterar a origem.
    mov dx,TIROS_LINHA*256+(TEXTO_COLUNAS-TIROS_TAM)/2 ; Empacota a linha em DH e a coluna em DL; a conta com 40 colunas centraliza o texto quando indicada.
    mov bl,COR_BRANCO ; BL recebe COR_BRANCO; EscreverTexto/MostrarArte usara essa cor para os caracteres.
    call EscreverTexto ; Chama EscreverTexto para imprimir texto BIOS, preservando ES de video para os bitmaps; CALL guarda onde voltar.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
EntrarSetor endp ; Fecha a definicao de EntrarSetor no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: tela reutilizavel de encerramento; nao calcula regras da partida.
; Entrada: AX=score final sem sinal (0..65535), ES=video, DS=dados.
; Saida: estado FIM; GAME e OVER vermelhos, score decimal, buffer vazio.
; Altera: AX,BX,CX,DX,SI,DI,BP,flags, scoreFinal/digitosScore e video.
EntrarGameOver proc near ; Por que: E02, integrada na E03/E05: tempo e vidas terminam na mesma tela com o score real.
    call RestaurarTecladoJogo   ; preserva AX: score real recebido | Chama RestaurarTecladoJogo para devolver INT 09h ao BIOS antes do Game Over/saida; CALL guarda onde voltar.
    mov scoreFinal,ax ; Grava AX em scoreFinal: copia da pontuacao que sera apresentada no Game Over.
    call LimparTeclado ; Chama LimparTeclado para descartar teclas antigas ao entrar em uma nova tela; CALL guarda onde voltar.
    call LimparTela ; Chama LimparTela para limpar os pixels por memoria, sem mudar o modo de video; CALL guarda onde voltar.
    mov estado,ESTADO_FIM ; Grava ESTADO_FIM em estado: tela/fase atual do programa, que decide o caminho do laco principal.
    lea si,arteGame ; Coloca em SI o offset de arteGame; passa o endereco do bloco, nao seu conteudo.
    mov cx,GAME_LARG ; CX recebe GAME_LARG: quantidade de pixels/caracteres a processar nesta chamada.
    mov bp,GAME_ALT ; BP recebe GAME_ALT, quantidade de linhas do bloco ASCII a imprimir.
    mov dx,GAME_LINHA*256+(TEXTO_COLUNAS-GAME_LARG)/2 ; Empacota a linha em DH e a coluna em DL; a conta com 40 colunas centraliza o texto quando indicada.
    mov bl,COR_GAMEOVER ; BL recebe COR_GAMEOVER; EscreverTexto/MostrarArte usara essa cor para os caracteres.
    call MostrarArte ; Chama MostrarArte para imprimir bloco ASCII retangular (titulo, GAME/OVER ou caixa); CALL guarda onde voltar.
    lea si,arteOver ; Coloca em SI o offset de arteOver; passa o endereco do bloco, nao seu conteudo.
    mov cx,OVER_LARG ; CX recebe OVER_LARG: quantidade de pixels/caracteres a processar nesta chamada.
    mov bp,OVER_ALT ; BP recebe OVER_ALT, quantidade de linhas do bloco ASCII a imprimir.
    mov dx,OVER_LINHA*256+(TEXTO_COLUNAS-OVER_LARG)/2 ; Empacota a linha em DH e a coluna em DL; a conta com 40 colunas centraliza o texto quando indicada.
    call MostrarArte ; Chama MostrarArte para imprimir bloco ASCII retangular (titulo, GAME/OVER ou caixa); CALL guarda onde voltar.
    mov ax,scoreFinal ; Le scoreFinal em AX: copia da pontuacao que sera apresentada no Game Over.
    call FormatarScore ; Chama FormatarScore para converter numero para cinco algarismos, incluindo zeros iniciais; CALL guarda onde voltar.
    lea si,textoScore ; Coloca em SI o offset de textoScore; passa o endereco do bloco, nao seu conteudo.
    mov cx,SCORE_TAM ; CX recebe SCORE_TAM: quantidade de pixels/caracteres a processar nesta chamada.
    mov dx,SCORE_LINHA*256+(TEXTO_COLUNAS-SCORE_TAM)/2 ; Empacota a linha em DH e a coluna em DL; a conta com 40 colunas centraliza o texto quando indicada.
    mov bl,COR_BRANCO ; BL recebe COR_BRANCO; EscreverTexto/MostrarArte usara essa cor para os caracteres.
    call EscreverTexto ; Chama EscreverTexto para imprimir texto BIOS, preservando ES de video para os bitmaps; CALL guarda onde voltar.
    lea si,textoRetorno ; Coloca em SI o offset de textoRetorno; passa o endereco do bloco, nao seu conteudo.
    mov cx,RETORNO_TAM ; Copia RETORNO_TAM para CX, preparando esse valor para as instrucoes seguintes sem alterar a origem.
    mov dx,AVANCO_LINHA*256+(TEXTO_COLUNAS-RETORNO_TAM)/2 ; Empacota a linha em DH e a coluna em DL; a conta com 40 colunas centraliza o texto quando indicada.
    mov bl,COR_BRANCO ; BL recebe COR_BRANCO; EscreverTexto/MostrarArte usara essa cor para os caracteres.
    call EscreverTexto ; Chama EscreverTexto para imprimir texto BIOS, preservando ES de video para os bitmaps; CALL guarda onde voltar.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
EntrarGameOver endp ; Fecha a definicao de EntrarGameOver no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: converter numero para cinco algarismos, incluindo zeros iniciais.
; Entrada: AX=numero unsigned. Saida: digitosScore. Altera: AX,BX,CX,DX,DI,flags.
FormatarScore proc near ; Por que: E02: preparar os cinco digitos do placar usando o conversor comum.
    mov cx,SCORE_DIGITOS ; Copia SCORE_DIGITOS para CX, preparando esse valor para as instrucoes seguintes sem alterar a origem.
    lea di,digitosScore+SCORE_DIGITOS-1 ; Aponta para o ultimo dos cinco caracteres: os restos da divisao saem da direita para a esquerda.
    call FormatarNumero ; Chama FormatarNumero para converter inteiro unsigned em campo decimal de largura fixa; CALL guarda onde voltar.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
FormatarScore endp ; Fecha a definicao de FormatarScore no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: converter inteiro unsigned em campo decimal de largura fixa.
; Entrada: AX=valor, CX=digitos, DS:DI=ultimo caractere (campo suficiente).
; Saida: campo preenchido com zeros iniciais. Altera: AX,BX,CX,DX,DI,flags.
FormatarNumero proc near ; Por que: E03: generaliza a conversao do score da E02 para tambem imprimir os tres digitos do tempo.
    mov bx,10 ; Base decimal 10: dividir por ela separa o ultimo algarismo do restante do numero.
scoreDigito: ; Rotulo: destino dos saltos dentro de FormatarNumero; nao executa acao nem cria uma nova chamada.
    xor dx,dx ; Zera a metade alta do dividendo DX:AX; sem isso a divisao usaria lixo como parte do numero.
    div bx ; Divide DX:AX por 10: AX fica com o restante do numero e DX com o ultimo algarismo (0..9).
    add dl,'0' ; Transforma algarismo 0..9 em caractere ASCII '0'..'9', que a BIOS sabe imprimir.
    mov [di],dl ; Grava o caractere no campo de texto, nao na memoria de video.
    dec di ; Anda uma posicao para a esquerda no texto, preparando o proximo algarismo.
    loop scoreDigito ; Diminui CX e repete ate preencher todos os digitos, inclusive zeros a esquerda.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
FormatarNumero endp ; Fecha a definicao de FormatarNumero no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: consultar e consumir no maximo uma tecla, sem bloquear a animacao.
; Entrada: estado, opcao e buffer BIOS. Saida: transicao ou selecao atualizada.
; Altera: AX,BX,CX,DX,SI,DI,BP,flags, dados e video pelas rotinas de tela.
LerTeclado proc near ; Por que: E01/E02: consultar sem bloquear permite que animacao e tempo continuem sem teclas.
    mov ah,01h ; Seleciona consulta de teclado sem esperar; o laco de animacao precisa continuar se nao houver tecla.
    int 16h ; Usa o servico de teclado BIOS escolhido em AH: consultar (01h) ou consumir (00h) a tecla.
    jz tecladoFim ; Vai a tecladoFim se o resultado/teste anterior for zero (ZF=1).
    mov ah,00h ; Seleciona retirar uma tecla, depois de confirmar que o buffer nao esta vazio.
    int 16h ; Usa o servico de teclado BIOS escolhido em AH: consultar (01h) ou consumir (00h) a tecla.
    cmp estado,ESTADO_FIM ; Compara estado com ESTADO_FIM sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jne tecladoNaoFim ; Vai a tecladoNaoFim se estado for diferente de ESTADO_FIM.
    call EntrarMenu ; Chama EntrarMenu para reiniciar menu, selecao, posicoes e relogio da animacao; CALL guarda onde voltar.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
tecladoNaoFim: ; Rotulo: destino dos saltos dentro de LerTeclado; nao executa acao nem cria uma nova chamada.
    cmp estado,ESTADO_SETOR ; Compara estado com ESTADO_SETOR sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jne tecladoMenu ; Vai a tecladoMenu se estado for diferente de ESTADO_SETOR.
    cmp al,TECLA_ENTER ; Confere o caractere ASCII: somente Enter confirma a opcao ou inicia a partida.
    jne tecladoFim ; Vai a tecladoFim se AL for diferente de TECLA_ENTER.
    call EntrarPartida ; Chama EntrarPartida para reiniciar cenario/HUD, jipe, obstaculos, naves, tiros e relogio; CALL guarda onde voltar.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
tecladoMenu: ; Rotulo: destino dos saltos dentro de LerTeclado; nao executa acao nem cria uma nova chamada.
    cmp estado,ESTADO_MENU ; Compara estado com ESTADO_MENU sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jne tecladoFim ; Vai a tecladoFim se estado for diferente de ESTADO_MENU.
    cmp ah,SCAN_CIMA ; Setas sao identificadas pelo scan em AH, nao pelo caractere ASCII em AL.
    je tecladoAlternar ; Vai a tecladoAlternar se AH for igual a SCAN_CIMA.
    cmp ah,SCAN_BAIXO ; Reconhece a outra seta de selecao; com duas opcoes, cima e baixo alternam da mesma forma.
    je tecladoAlternar ; Vai a tecladoAlternar se AH for igual a SCAN_BAIXO.
    cmp al,TECLA_ENTER ; Confere o caractere ASCII: somente Enter confirma a opcao ou inicia a partida.
    jne tecladoFim ; Vai a tecladoFim se AL for diferente de TECLA_ENTER.
    cmp opcao,OPCAO_SAIR ; Compara opcao com OPCAO_SAIR sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je tecladoSair ; Vai a tecladoSair se opcao for igual a OPCAO_SAIR.
    call EntrarSetor ; Chama EntrarSetor para apresentar o unico setor e aguardar Enter, escolha tecnica D04; CALL guarda onde voltar.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
tecladoAlternar: ; Rotulo: destino dos saltos dentro de LerTeclado; nao executa acao nem cria uma nova chamada.
    xor opcao,1 ; Alterna somente o bit 0: opcao 0 vira 1, opcao 1 vira 0 (Jogar/Sair).
    call DesenharOpcoes ; Chama DesenharOpcoes para redesenhar so as caixas, sem tocar na faixa da animacao; CALL guarda onde voltar.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
tecladoSair: ; Rotulo: destino dos saltos dentro de LerTeclado; nao executa acao nem cria uma nova chamada.
    mov estado,ESTADO_SAIR ; Grava ESTADO_SAIR em estado: tela/fase atual do programa, que decide o caminho do laco principal.
tecladoFim: ; Rotulo: destino dos saltos dentro de LerTeclado; nao executa acao nem cria uma nova chamada.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
LerTeclado endp ; Fecha a definicao de LerTeclado no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: mover somente quando decorrer o intervalo BIOS configurado.
; Entrada: ultimoTick, ES=video. Saida: posicoes/quadro atualizados se venceu.
; Altera: AX,BX,CX,DX,SI,DI,flags. Sem espera bloqueante ou cronometro de jogo.
AtualizarAnimacao proc near ; Por que: E02: limitar movimento por ticks evita depender da velocidade do computador.
    mov ah,00h ; Copia 00h para AH, preparando esse valor para as instrucoes seguintes sem alterar a origem.
    int 1Ah ; Consulta os ticks BIOS em CX:DX; DX fornece a amostra usada pela cadencia, sem esperar.
    mov ax,dx ; Copia o tick atual para AX; DX conserva o instante completo usado como nova referencia.
    sub ax,ultimoTick ; Calcula quantos ticks passaram desde ultimoTick, usando aritmetica de 16 bits.
    cmp ax,TICKS_MOVIMENTO ; So permite mais um passo quando o intervalo configurado em TICKS_MOVIMENTO foi atingido.
    jb animacaoFim ; Vai a animacaoFim se AX for menor que (sem sinal) TICKS_MOVIMENTO.
    mov ultimoTick,dx ; Grava DX em ultimoTick: tick da ultima animacao do menu, usado para controlar sua velocidade.
    call MoverSpritesMenu ; Chama MoverSpritesMenu para restaurar, mover, capturar fundos e desenhar um quadro do menu; CALL guarda onde voltar.
animacaoFim: ; Rotulo: destino dos saltos dentro de AtualizarAnimacao; nao executa acao nem cria uma nova chamada.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
AtualizarAnimacao endp ; Fecha a definicao de AtualizarAnimacao no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: carregar parametros de um dos quatro objetos do menu.
; Entrada: DI=indice em bytes (0,2,4,6). Saida: AX=x,BX=y,CX=larg,DX=alt,
; DS:SI=bitmap. Preserva: DI,BP,ES. Nao valida indice (chamador controla).
CarregarSpriteMenu proc near ; Por que: E02: tabelas permitem tratar jipe e naves com o mesmo desenhador.
    mov ax,menuX[di] ; Le menuX[di] em AX: coluna atual de cada desenho animado do menu.
    mov bx,menuY[di] ; Le menuY[di] em BX: linhas dos quatro desenhos, alinhando as bases de jipe e naves.
    mov cx,menuLarg[di] ; Le menuLarg[di] em CX: largura de cada objeto do menu, para a rotina generica e o limite direito.
    mov dx,menuAlt[di] ; Le menuAlt[di] em DX: altura de cada objeto do menu.
    mov si,menuBitmap[di] ; Le menuBitmap[di] em SI: enderecos das imagens dos quatro objetos do menu.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
CarregarSpriteMenu endp ; Fecha a definicao de CarregarSpriteMenu no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: salvar TODOS os fundos limpos e so depois desenhar os objetos.
; Entrada: tabelas do menu; ES=video sem sprites. Saida: buffers e video.
; Altera: AX,BX,CX,DX,SI,DI,flags. Preserva: BP,DS,ES.
CapturarEDesenharMenu proc near ; Por que: E02: capturar todos os fundos antes de desenhar evita guardar um sprite no fundo de outro.
    xor di,di ; Zera DI para comecar pela primeira entrada/posicao percorrida nesta rotina.
capturarMenu: ; Rotulo: destino dos saltos dentro de CapturarEDesenharMenu; nao executa acao nem cria uma nova chamada.
    call CarregarSpriteMenu ; Chama CarregarSpriteMenu para carregar parametros de um dos quatro objetos do menu; CALL guarda onde voltar.
    mov si,menuFundo[di] ; Le menuFundo[di] em SI: enderecos das capturas de fundo dos quatro objetos do menu.
    call SalvarFundo ; Captura este fundo ainda sem nenhum sprite novo; evita incluir um objeto na captura de outro.
    add di,2 ; Avanca DI dois bytes para a proxima entrada word da tabela, sem misturar objetos.
    cmp di,MENU_QUANT*2 ; Compara DI com MENU_QUANT*2 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jb capturarMenu ; Vai a capturarMenu se DI for menor que (sem sinal) MENU_QUANT*2.
    xor di,di ; Zera DI para comecar pela primeira entrada/posicao percorrida nesta rotina.
desenharMenu: ; Rotulo: destino dos saltos dentro de CapturarEDesenharMenu; nao executa acao nem cria uma nova chamada.
    call CarregarSpriteMenu ; Chama CarregarSpriteMenu para carregar parametros de um dos quatro objetos do menu; CALL guarda onde voltar.
    call DesenharSprite ; Desenha so depois que todos os quatro fundos ja foram capturados limpos.
    add di,2 ; Avanca DI dois bytes para a proxima entrada word da tabela, sem misturar objetos.
    cmp di,MENU_QUANT*2 ; Compara DI com MENU_QUANT*2 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jb desenharMenu ; Vai a desenharMenu se DI for menor que (sem sinal) MENU_QUANT*2.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
CapturarEDesenharMenu endp ; Fecha a definicao de CapturarEDesenharMenu no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: apagar TODOS os objetos usando fundos capturados antes do desenho.
; Entrada: posicoes anteriores e buffers, ES=video. Saida: fundo restaurado.
; Altera: AX,BX,CX,DX,SI,DI,flags. Preserva: BP,DS,ES.
ApagarSpritesMenu proc near ; Por que: E02: restaurar o fundo real apaga os objetos sem deixar rastros.
    xor di,di ; Zera DI para comecar pela primeira entrada/posicao percorrida nesta rotina.
apagarMenu: ; Rotulo: destino dos saltos dentro de ApagarSpritesMenu; nao executa acao nem cria uma nova chamada.
    call CarregarSpriteMenu ; Chama CarregarSpriteMenu para carregar parametros de um dos quatro objetos do menu; CALL guarda onde voltar.
    mov si,menuFundo[di] ; Le menuFundo[di] em SI: enderecos das capturas de fundo dos quatro objetos do menu.
    call DesenharBitmap          ; opaco: inclusive os pixels pretos do fundo | Chama DesenharBitmap para copiar bitmap opaco linha a linha para o video; CALL guarda onde voltar.
    add di,2 ; Avanca DI dois bytes para a proxima entrada word da tabela, sem misturar objetos.
    cmp di,MENU_QUANT*2 ; Compara DI com MENU_QUANT*2 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jb apagarMenu ; Vai a apagarMenu se DI for menor que (sem sinal) MENU_QUANT*2.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
ApagarSpritesMenu endp ; Fecha a definicao de ApagarSpritesMenu no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: restaurar, mover, capturar fundos e desenhar um quadro do menu.
; Entrada: tabelas/buffers, ES=video. Saida: x avanca; volta inteiro a x=0.
; Altera: AX,BX,CX,DX,SI,DI,flags. Fundo estatico obrigatorio entre quadros.
MoverSpritesMenu proc near ; Por que: E02: separar apagar, mover e desenhar mantem fundo e posicao coerentes.
    call ApagarSpritesMenu ; Chama ApagarSpritesMenu para apagar TODOS os objetos usando fundos capturados antes do desenho; CALL guarda onde voltar.
    xor di,di ; Zera DI para comecar pela primeira entrada/posicao percorrida nesta rotina.
moverMenu: ; Rotulo: destino dos saltos dentro de MoverSpritesMenu; nao executa acao nem cria uma nova chamada.
    mov ax,menuX[di] ; Le menuX[di] em AX: coluna atual de cada desenho animado do menu.
    add ax,PASSO_MENU ; Soma PASSO_MENU a AX, atualizando o valor usado neste calculo.
    mov bx,TELA_LARG ; Prepara o limite direito da tela para calcular ate onde cabe este desenho inteiro.
    sub bx,menuLarg[di] ; BX vira 320-largura: ultima coluna inicial que mantem o objeto todo visivel.
    cmp ax,bx ; Confere se a nova coluna ultrapassaria esse limite; nesse caso o objeto volta para zero.
    jbe moverGuardar ; Vai a moverGuardar se AX for menor ou igual a (sem sinal) BX.
    xor ax,ax                   ; sem recorte parcial nesta etapa | Recomeca em X=0 quando o sprite nao cabe mais inteiro a direita; o menu nao usa recorte parcial.
moverGuardar: ; Rotulo: destino dos saltos dentro de MoverSpritesMenu; nao executa acao nem cria uma nova chamada.
    mov menuX[di],ax ; Grava AX em menuX[di]: coluna atual de cada desenho animado do menu.
    add di,2 ; Avanca DI dois bytes para a proxima entrada word da tabela, sem misturar objetos.
    cmp di,MENU_QUANT*2 ; Compara DI com MENU_QUANT*2 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jb moverMenu ; Vai a moverMenu se DI for menor que (sem sinal) MENU_QUANT*2.
    call CapturarEDesenharMenu ; Chama CapturarEDesenharMenu para salvar TODOS os fundos limpos e so depois desenhar os objetos; CALL guarda onde voltar.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
MoverSpritesMenu endp ; Fecha a definicao de MoverSpritesMenu no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: reiniciar cenario/HUD, jipe, obstaculos, naves, tiros e relogio.
; Entrada: DS=dados, ES=video. Saida: estado PARTIDA, valores reiniciados.
; Altera: AX,BX,CX,DX,SI,DI,BP,flags, dados e video.
EntrarPartida proc near ; Por que: E03, ampliada E04-E08: reiniciar a sessao inteira aqui evita carregar dados da partida anterior.
    call LimparTeclado ; Chama LimparTeclado para descartar teclas antigas ao entrar em uma nova tela; CALL guarda onde voltar.
    mov estado,ESTADO_PARTIDA ; Grava ESTADO_PARTIDA em estado: tela/fase atual do programa, que decide o caminho do laco principal.
    mov scorePartida,0 ; Grava 0 em scorePartida: pontuacao acumulada da sessao; nao reinicia ao perder uma vida.
    mov vidas,VIDAS_INICIAIS ; Grava VIDAS_INICIAIS em vidas: vidas restantes; chegar a zero encerra a partida.
    mov tempoRestante,DURACAO_SEGUNDOS ; Grava DURACAO_SEGUNDOS em tempoRestante: segundos restantes; a duracao nao depende do numero de quadros.
    mov fracaoSegundo,0 ; Grava 0 em fracaoSegundo: centesimos ainda insuficientes para descontar um segundo inteiro.
    mov margemInicial,MARGEM_RELOGIO ; Grava MARGEM_RELOGIO em margemInicial: folga inicial ainda nao consumida, aplicada apenas no inicio da partida.
    mov rolagem,0 ; Grava 0 em rolagem: coluna da arte que aparece a esquerda; mudar isso desloca o terreno.
    call ReiniciarJipe ; Chama ReiniciarJipe para restaurar somente os dados do jipe para uma nova partida; CALL guarda onde voltar.
    call ReiniciarObstaculos ; Zera a lista e inicializa a semente uma vez na nova sessao; perder vida nao passa por aqui.
    call ReiniciarNaves ; Limpa as vagas das naves; reutilizara a semente ja preparada pelos obstaculos.
    call ReiniciarDisparos ; Remove projeteis da sessao anterior; morte isolada ou novo grupo nao chama esse reset.
    call GerarGrupoNaves ; Chama GerarGrupoNaves para gerar um grupo homogeneo, apenas se nenhuma vaga estiver ativa; CALL guarda onde voltar.
    call LimparTela ; Chama LimparTela para limpar os pixels por memoria, sem mudar o modo de video; CALL guarda onde voltar.
    call DesenharCenario ; Chama DesenharCenario para recompor terreno em memoria e copiar linhas prontas para o video; CALL guarda onde voltar.
    call DesenharObstaculos ; Chama DesenharObstaculos para compor os sete tipos sobre o cenario limpo, antes do jipe; CALL guarda onde voltar.
    call DesenharNaves ; Chama DesenharNaves para recompor o ceu preto atual e desenhar somente as naves ativas; CALL guarda onde voltar.
    call CapturarEDesenharJipe ; Chama CapturarEDesenharJipe para capturar o fundo limpo atual e desenhar o jipe sempre 20x10; CALL guarda onde voltar.
    call DesenharStatus ; Chama DesenharStatus para desenhar score esquerdo, vidas centrais e tempo direito (D01); CALL guarda onde voltar.
    call InstalarTecladoJogo ; Chama InstalarTecladoJogo para guardar INT 09h BIOS e instalar leitura de pressao/soltura; CALL guarda onde voltar.
    ; Comecar a contar depois de desenhar a primeira tela.
    call LerCentissegundos ; Toma a referencia depois do primeiro desenho, para o tempo de preparar a tela nao consumir a partida.
    mov tempoAnteriorLo,ax ; Grava AX em tempoAnteriorLo: parte baixa da hora da consulta anterior, em centesimos.
    mov tempoAnteriorHi,dx ; Grava DX em tempoAnteriorHi: parte alta da hora anterior, para contar mais que 65535 centesimos.
    mov ah,00h ; Copia 00h para AH, preparando esse valor para as instrucoes seguintes sem alterar a origem.
    int 1Ah ; Consulta os ticks BIOS em CX:DX; DX fornece a amostra usada pela cadencia, sem esperar.
    mov tickCenario,dx ; Grava DX em tickCenario: tick do ultimo avanco do terreno.
    mov tickJipe,dx ; Grava DX em tickJipe: tick da ultima atualizacao do jipe.
    mov tickNave,dx ; Grava DX em tickNave: tick do ultimo movimento do grupo de naves.
    mov tickTiro,dx ; Grava DX em tickTiro: tick da ultima atualizacao dos projeteis.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
EntrarPartida endp ; Fecha a definicao de EntrarPartida no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: atualizar tempo a cada consulta e movimento em sua propria cadencia.
; Entrada: estado PARTIDA, relogios/dados, ES=video. Saida: quadro ou FIM.
; Altera: AX,BX,CX,DX,SI,DI,BP,flags, dados e video. Nunca espera por tecla.
AtualizarPartida proc near ; Por que: E03-E08: coordenar relogio, movimento, colisoes e desenho na ordem correta.
    call AtualizarRelogio ; Chama AtualizarRelogio para descontar tempo real desde a ultima consulta, com virada de dia; CALL guarda onde voltar.
    jnc partidaMovimento ; Vai a partidaMovimento se nenhum segundo foi descontado.
    cmp tempoRestante,0 ; Compara tempoRestante com 0 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je partidaExpirou ; Vai a partidaExpirou se tempoRestante for igual a 0.
    call DesenharStatus ; Chama DesenharStatus para desenhar score esquerdo, vidas centrais e tempo direito (D01); CALL guarda onde voltar.
partidaMovimento: ; Rotulo: destino dos saltos dentro de AtualizarPartida; nao executa acao nem cria uma nova chamada.
    mov cenarioMudou,0 ; Grava 0 em cenarioMudou: aviso de que o terreno/obstaculos precisam ser redesenhados.
    mov jipeMudou,0 ; Grava 0 em jipeMudou: aviso de que o jipe mudou ou desapareceu e requer novo desenho.
    mov ah,00h ; Copia 00h para AH, preparando esse valor para as instrucoes seguintes sem alterar a origem.
    int 1Ah ; Consulta os ticks BIOS em CX:DX; DX fornece a amostra usada pela cadencia, sem esperar.
    push dx                    ; mesma amostra para naves, terreno, jipe e tiros | Guarda o tick atual: outras rotinas usam DX, mas jipe e terreno precisam da mesma amostra.
    call AtualizarCadenciaNaves ; preserva DX; nao depende da rolagem/jipe | Chama AtualizarCadenciaNaves para manter cadencia independente usando a mesma amostra BIOS do laco; CALL guarda onde voltar.
    mov ax,dx ; Copia a amostra de tick para calcular o intervalo sem perder DX, usado pelas outras cadencias.
    sub ax,tickCenario ; Mede ticks desde o ultimo passo do terreno; nao depende de o jipe estar andando.
    cmp ax,TICKS_CENARIO ; Compara AX com TICKS_CENARIO sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jb partidaJipe ; Vai a partidaJipe se AX for menor que (sem sinal) TICKS_CENARIO.
    mov tickCenario,dx ; Grava DX em tickCenario: tick do ultimo avanco do terreno.
    call AvancarCenario ; Chama AvancarCenario para avancar a origem circular, revelando novos pixels pela direita; CALL guarda onde voltar.
    call AvancarObstaculos ; Move crateras e rochas no mesmo passo do terreno, mantendo-as presas a superficie lunar.
    mov cenarioMudou,1 ; Grava 1 em cenarioMudou: aviso de que o terreno/obstaculos precisam ser redesenhados.
    mov ax,PASSO_CENARIO ; Copia PASSO_CENARIO para AX, preparando esse valor para as instrucoes seguintes sem alterar a origem.
    call ContarTopo             ; so conta se ja estava no topo | Conta so o terreno que andou enquanto o jipe ja estava no topo; subida nao entra nessa duracao.
partidaJipe: ; Rotulo: destino dos saltos dentro de AtualizarPartida; nao executa acao nem cria uma nova chamada.
    pop dx ; Recupera o tick salvo para medir o jipe com a mesma referencia usada no terreno.
    mov ax,dx ; Copia a amostra de tick para calcular o intervalo sem perder DX, usado pelas outras cadencias.
    sub ax,tickJipe ; Mede ticks desde o ultimo passo do jipe; permite cadencia diferente da do terreno.
    cmp ax,TICKS_JIPE ; Compara AX com TICKS_JIPE sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jb partidaDesenhar ; Vai a partidaDesenhar se AX for menor que (sem sinal) TICKS_JIPE.
    mov tickJipe,dx ; Grava DX em tickJipe: tick da ultima atualizacao do jipe.
    cmp jipeAtivo,0 ; Compara jipeAtivo com 0 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je partidaRepor ; Vai a partidaRepor se jipeAtivo for igual a 0.
    call AtualizarJipe ; Chama AtualizarJipe para executar um frame do jipe, independente da repeticao do teclado; CALL guarda onde voltar.
    jmp partidaDesenhar ; Continua em partidaDesenhar sem criar retorno; pula o caminho que nao se aplica a este caso.
partidaRepor: ; Rotulo: destino dos saltos dentro de AtualizarPartida; nao executa acao nem cria uma nova chamada.
    call TentarReporJipe ; Chama TentarReporJipe para D14, reaparecer no proximo tick do jipe com x=0 LIVRE; CALL guarda onde voltar.
partidaDesenhar: ; Rotulo: destino dos saltos dentro de AtualizarPartida; nao executa acao nem cria uma nova chamada.
    call AtualizarCadenciaDisparos ; DX preservado pelo jipe/reposicao | Chama AtualizarCadenciaDisparos para cadencia propria; mover ativos, depois emitir pares e tiros de naves; CALL guarda onde voltar.
    call ConferirDisparos       ; alvos podem ter movido sem tick do tiro | Detecta impactos mesmo se so o alvo se moveu; tiros fatais devem cancelar saltos antes dos pontos.
    call ConferirObstaculos     ; primeiro todas as colisoes, depois pontos | Primeiro testa todas as colisoes terrestres, depois concede pontos por pousos seguros.
    cmp vidas,0 ; Compara vidas com 0 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je partidaExpirou ; Vai a partidaExpirou se vidas for igual a 0.
    call RetirarObstaculos ; Chama RetirarObstaculos para liberar apenas objetos inteiros fora da esquerda, sem dar pontos; CALL guarda onde voltar.
    cmp statusMudou,0 ; Compara statusMudou com 0 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je partidaQuadro ; Vai a partidaQuadro se statusMudou for igual a 0.
    call DesenharStatus ; Chama DesenharStatus para desenhar score esquerdo, vidas centrais e tempo direito (D01); CALL guarda onde voltar.
    mov statusMudou,0 ; Grava 0 em statusMudou: aviso para atualizar score/vidas no HUD depois de um evento.
partidaQuadro: ; Rotulo: destino dos saltos dentro de AtualizarPartida; nao executa acao nem cria uma nova chamada.
    mov al,cenarioMudou ; Le cenarioMudou em AL: aviso de que o terreno/obstaculos precisam ser redesenhados.
    or al,jipeMudou ; Acumula o aviso do jipe: basta um elemento ter mudado para precisar desenhar.
    or al,navesMudou ; Inclui mudanca nas naves no pedido de redesenho, mesmo sem avanco do terreno.
    or al,tirosMudou ; Inclui movimento/criacao/remocao de tiros; nao deixar residuos do quadro anterior.
    jz partidaFim ; Se nenhum aviso esta ligado, o quadro continua correto e nao precisa ser redesenhado.
    call DesenharQuadroPartida ; Chama DesenharQuadroPartida para apagar/redesenhar com ou sem rolagem sem restaurar fundo velho; CALL guarda onde voltar.
partidaFim: ; Rotulo: destino dos saltos dentro de AtualizarPartida; nao executa acao nem cria uma nova chamada.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
partidaExpirou: ; Rotulo: destino dos saltos dentro de AtualizarPartida; nao executa acao nem cria uma nova chamada.
    mov ax,scorePartida          ; valor real, nao o antigo SCORE_DEMO | Le scorePartida em AX: pontuacao acumulada da sessao; nao reinicia ao perder uma vida.
    call EntrarGameOver ; Chama EntrarGameOver para tela reutilizavel de encerramento; nao calcula regras da partida; CALL guarda onde voltar.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
AtualizarPartida endp ; Fecha a definicao de AtualizarPartida no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: restaurar somente os dados do jipe para uma nova partida.
; Entrada: nenhuma. Saida: posicao inicial, chao, sem teclas/pedido pendente.
; Altera: dados do jipe; preserva registradores. Nao reinicia score/relogio.
ReiniciarJipe proc near ; Por que: E04: preparar o jipe de uma nova sessao, sem misturar isso com perder uma vida.
    mov jipeAtivo,1 ; Grava 1 em jipeAtivo: indica se o jipe esta vivo/presente; zero impede descontar outra vida no mesmo evento.
    mov jipeNaTela,0 ; Grava 0 em jipeNaTela: indica se existe uma captura valida do fundo sob o jipe desenhado.
    mov jipeX,JIPE_X_INICIAL ; Grava JIPE_X_INICIAL em jipeX: coluna atual da borda esquerda do jipe.
    mov jipeY,JIPE_Y_CHAO ; Grava JIPE_Y_CHAO em jipeY: linha atual do topo do jipe; diminuir Y faz subir.
    mov estadoSalto,SALTO_CHAO ; Grava SALTO_CHAO em estadoSalto: fase do salto: chao, subida, topo ou descida.
    mov pixelsTopo,0 ; Grava 0 em pixelsTopo: distancia de terreno acumulada desde que o jipe chegou ao topo.
    mov teclasJipe,0 ; Grava 0 em teclasJipe: mascara das teclas mantidas; cada bit registra uma tecla separadamente.
    mov pedidoSalto,0 ; Grava 0 em pedidoSalto: pedido de uma nova pressao de cima, consumido uma vez pelo movimento.
    mov tickJipe,0 ; Grava 0 em tickJipe: tick da ultima atualizacao do jipe.
    mov cenarioMudou,0 ; Grava 0 em cenarioMudou: aviso de que o terreno/obstaculos precisam ser redesenhados.
    mov jipeMudou,0 ; Grava 0 em jipeMudou: aviso de que o jipe mudou ou desapareceu e requer novo desenho.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
ReiniciarJipe endp ; Fecha a definicao de ReiniciarJipe no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: registrar make/break das setas e Espaco, inclusive simultaneas.
; Entrada: AL=scan code set 1 (bit 7=soltou), DS=dados.
; Saida: teclasJipe, pedidoTiro e pedidoSalto (nova pressao no chao).
; Altera: AX,flags e dados de entrada. Prefixos/outros scans sao ignorados.
RegistrarScanJipe proc near ; Por que: E04/E08: pressao/soltura permitem teclas simultaneas e salto por nova pressao.
    mov ah,al ; Conserva o scan completo em AH, pois o bit de soltura sera retirado de AL para identificar a tecla.
    and al,7Fh ; Apaga o bit 7 so em AL: pressao e soltura passam a ter o mesmo codigo basico de tecla.
    cmp al,SCAN_ESQUERDA ; Compara AL com SCAN_ESQUERDA sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je scanEsquerda ; Vai a scanEsquerda se AL for igual a SCAN_ESQUERDA.
    cmp al,SCAN_DIREITA ; Compara AL com SCAN_DIREITA sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je scanDireita ; Vai a scanDireita se AL for igual a SCAN_DIREITA.
    cmp al,SCAN_ESPACO ; Compara AL com SCAN_ESPACO sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je scanEspaco ; Vai a scanEspaco se AL for igual a SCAN_ESPACO.
    cmp al,SCAN_CIMA ; Compara AL com SCAN_CIMA sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jne scanFim ; Vai a scanFim se AL for diferente de SCAN_CIMA.
    test ah,80h ; Testa o bit 7 do codigo original: ligado indica soltura, desligado indica pressao.
    jnz scanSoltarCima ; Vai a scanSoltarCima se o resultado/teste anterior for diferente de zero (ZF=0).
    test teclasJipe,BIT_CIMA ; Consulta se cima ja estava mantida; repeticao automatica nao deve criar outro salto.
    jnz scanFim                ; repeticao automatica nao e nova pressao | Vai a scanFim se o resultado/teste anterior for diferente de zero (ZF=0).
    or teclasJipe,BIT_CIMA ; Marca cima como mantida, preservando os bits de esquerda/direita/Espaco.
    cmp jipeAtivo,0 ; Compara jipeAtivo com 0 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je scanFim                 ; ausente nao guarda salto para a reposicao | Vai a scanFim se jipeAtivo for igual a 0.
    cmp estadoSalto,SALTO_CHAO ; Compara estadoSalto com SALTO_CHAO sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jne scanFim                ; pressao no ar nao fica guardada para pouso | Vai a scanFim se estadoSalto for diferente de SALTO_CHAO.
    mov pedidoSalto,1 ; Grava 1 em pedidoSalto: pedido de uma nova pressao de cima, consumido uma vez pelo movimento.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
scanSoltarCima: ; Rotulo: destino dos saltos dentro de RegistrarScanJipe; nao executa acao nem cria uma nova chamada.
    and teclasJipe,0FFh-BIT_CIMA ; Apaga apenas o bit de cima; as outras teclas continuam registradas.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
scanEsquerda: ; Rotulo: destino dos saltos dentro de RegistrarScanJipe; nao executa acao nem cria uma nova chamada.
    mov al,BIT_ESQUERDA ; Escolhe a mascara da tecla esquerda; o mesmo trecho vai tratar pressao e soltura lateral.
    jmp scanLateral ; Continua em scanLateral sem criar retorno; pula o caminho que nao se aplica a este caso.
scanDireita: ; Rotulo: destino dos saltos dentro de RegistrarScanJipe; nao executa acao nem cria uma nova chamada.
    mov al,BIT_DIREITA ; Escolhe a mascara da direita para reutilizar o tratamento comum das teclas.
    jmp scanLateral ; Continua em scanLateral sem criar retorno; pula o caminho que nao se aplica a este caso.
scanEspaco: ; Rotulo: destino dos saltos dentro de RegistrarScanJipe; nao executa acao nem cria uma nova chamada.
    test ah,80h ; Testa o bit de soltura no scan original guardado em AH; AL ja pode conter so a mascara da tecla.
    jnz scanSoltarEspaco ; Vai a scanSoltarEspaco se o resultado/teste anterior for diferente de zero (ZF=0).
    test teclasJipe,BIT_ESPACO ; Testa os bits de teclasJipe selecionados por BIT_ESPACO, sem modificar teclasJipe; zero significa nenhum deles ligado.
    jnz scanFim ; Vai a scanFim se o resultado/teste anterior for diferente de zero (ZF=0).
    or teclasJipe,BIT_ESPACO ; Liga em teclasJipe os bits presentes em BIT_ESPACO, preservando os outros; permite combinar teclas/avisos.
    cmp jipeAtivo,0 ; Compara jipeAtivo com 0 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je scanFim ; Vai a scanFim se jipeAtivo for igual a 0.
    mov pedidoTiro,1 ; Grava 1 em pedidoTiro: guarda um toque curto de Espaco ate a proxima leitura do jogo.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
scanSoltarEspaco: ; Rotulo: destino dos saltos dentro de RegistrarScanJipe; nao executa acao nem cria uma nova chamada.
    mov al,BIT_ESPACO ; Escolhe a mascara de Espaco para limpar apenas esse bit no trecho comum de soltura.
scanLateral: ; Rotulo: destino dos saltos dentro de RegistrarScanJipe; nao executa acao nem cria uma nova chamada.
    test ah,80h ; Testa o bit de soltura no scan original guardado em AH; AL ja pode conter so a mascara da tecla.
    jnz scanSoltarLateral ; Vai a scanSoltarLateral se o resultado/teste anterior for diferente de zero (ZF=0).
    or teclasJipe,al ; Liga em teclasJipe os bits presentes em AL, preservando os outros; permite combinar teclas/avisos.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
scanSoltarLateral: ; Rotulo: destino dos saltos dentro de RegistrarScanJipe; nao executa acao nem cria uma nova chamada.
    not al ; Inverte a mascara de uma tecla: prepara AND para zerar so esse bit.
    and teclasJipe,al ; Remove apenas a tecla solta da mascara; as demais podem continuar pressionadas.
scanFim: ; Rotulo: destino dos saltos dentro de RegistrarScanJipe; nao executa acao nem cria uma nova chamada.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
RegistrarScanJipe endp ; Fecha a definicao de RegistrarScanJipe no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: IRQ1 curta durante a partida: ler teclado, confirmar e registrar.
; Entrada: hardware porta 60h. Saida: teclas/pedido; IRET retoma interrompido.
; Preserva: registradores/flags. Nao chama DOS/BIOS, nao desenha nem move.
TecladoJogoIRQ proc far ; Por que: E04: capturar eventos do hardware; o movimento continua no laco, fora da interrupcao.
    push ax ; Guarda AX na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    push ds ; Guarda DS do codigo interrompido: uma IRQ pode ocorrer enquanto DS aponta para outro segmento.
    mov ax,@data ; Prepara o segmento das variaveis do jogo para a rotina de interrupcao.
    mov ds,ax ; Permite acessar teclasJipe e pedidos com DS correto, seja qual for o ponto interrompido.
    in al,60h ; Le o scan code recebido do teclado pela porta 60h.
    push ax ; Guarda o scan enquanto AL sera reutilizado na confirmacao do hardware.
    in al,61h ; Le o estado da porta 61h para alterar so o bit de confirmacao.
    mov ah,al ; Conserva o valor original da porta em AH para restaura-lo depois do pulso.
    or al,80h ; Ativa o bit 7 para produzir o pulso de confirmacao usado por este controlador.
    out 61h,al ; Envia a primeira parte do pulso sem alterar permanentemente os demais bits.
    mov al,ah ; Recupera o valor original da porta, encerrando o pulso no passo seguinte.
    out 61h,al ; Restaura a porta 61h apos confirmar a leitura.
    pop ax ; Recupera o scan salvo, que RegistrarScanJipe recebe em AL.
    call RegistrarScanJipe ; Chama RegistrarScanJipe para registrar make/break das setas e Espaco, inclusive simultaneas; CALL guarda onde voltar.
    mov al,20h ; 20h e o comando de fim de interrupcao (EOI) para o controlador PIC.
    out 20h,al                 ; fim de interrupcao no controlador (PIC) | Avisa ao PIC que IRQ1 foi atendida, permitindo novas interrupcoes de teclado.
    pop ds ; Recupera em DS o valor no topo da pilha, desfazendo o salvamento correspondente.
    pop ax ; Recupera em AX o valor no topo da pilha, desfazendo o salvamento correspondente.
    iret ; IRET recupera IP, CS e FLAGS empilhados pela interrupcao; RET comum nao faria isso.
TecladoJogoIRQ endp ; Fecha a definicao de TecladoJogoIRQ no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: guardar INT 09h BIOS e instalar leitura de pressao/soltura.
; Entrada: DS=dados, tecladoJogoAtivo=0. Saida: vetor ativo durante partida.
; Preserva: registradores. Altera: flags, vetor DOS e dados de controle.
InstalarTecladoJogo proc near ; Por que: E04: trocar temporariamente a leitura BIOS pela que reconhece teclas mantidas.
    cmp tecladoJogoAtivo,0 ; Compara tecladoJogoAtivo com 0 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jne instalarTecladoFim ; Vai a instalarTecladoFim se tecladoJogoAtivo for diferente de 0.
    push ax ; Guarda AX na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    push bx ; Guarda BX na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    push dx ; Guarda DX na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    push es ; Guarda o segmento de video porque a consulta do vetor vai devolver o segmento antigo em ES.
    mov ax,3509h ; AH=35h consulta um vetor; AL=09h escolhe a interrupcao do teclado.
    int 21h ; DOS devolve o tratador anterior em ES:BX; ES deixa temporariamente de apontar ao video.
    mov vetorTeclado,bx ; Guarda o offset anterior para poder devolver o teclado depois.
    mov vetorTeclado+2,es ; Guarda o segmento anterior na segunda word do vetor, dois bytes depois do offset.
    push ds ; Guarda o segmento de dados antes de usar DS como segmento do novo tratador.
    push cs ; Copia CS pela pilha, pois a rotina de interrupcao esta no segmento de codigo.
    pop ds ; DS recebe CS temporariamente: o DOS precisa do novo tratador em DS:DX.
    mov dx,offset TecladoJogoIRQ ; DX recebe o offset do tratador; junto de DS forma o endereco completo.
    mov ax,2509h ; AH=25h instala vetor; AL=09h seleciona a interrupcao do teclado.
    int 21h ; DOS instala TecladoJogoIRQ como tratador; as setas da partida passam por ele.
    pop ds ; Restaura DS=dados apos instalar o vetor; as variaveis do jogo precisam voltar a ser acessiveis.
    mov tecladoJogoAtivo,1 ; Grava 1 em tecladoJogoAtivo: indica se a interrupcao de teclado do jogo esta instalada.
    pop es ; Recupera em ES o valor no topo da pilha, desfazendo o salvamento correspondente.
    pop dx ; Recupera em DX o valor no topo da pilha, desfazendo o salvamento correspondente.
    pop bx ; Recupera em BX o valor no topo da pilha, desfazendo o salvamento correspondente.
    pop ax ; Recupera em AX o valor no topo da pilha, desfazendo o salvamento correspondente.
instalarTecladoFim: ; Rotulo: destino dos saltos dentro de InstalarTecladoJogo; nao executa acao nem cria uma nova chamada.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
InstalarTecladoJogo endp ; Fecha a definicao de InstalarTecladoJogo no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: devolver INT 09h ao BIOS antes do Game Over/saida.
; Entrada: DS=dados, vetor guardado. Saida: teclado BIOS restaurado.
; Preserva: registradores (inclusive AX=score). Altera: flags/vetor/controle.
RestaurarTecladoJogo proc near ; Por que: E04: devolver o teclado ao BIOS para as telas e para o DOS funcionarem normalmente.
    cmp tecladoJogoAtivo,0 ; Compara tecladoJogoAtivo com 0 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je restaurarTecladoFim ; Vai a restaurarTecladoFim se tecladoJogoAtivo for igual a 0.
    push ax ; Preserva AX, inclusive o score recebido por EntrarGameOver; trocar o vetor nao pode perder esse numero.
    push dx ; Guarda DX na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    push ds ; Guarda DS na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    mov dx,vetorTeclado ; Le somente a primeira word, o offset do tratador antigo, para formar DS:DX.
    mov ax,vetorTeclado+2 ; Le a segunda word, o segmento do tratador antigo; cada word ocupa dois bytes.
    mov tecladoJogoAtivo,0 ; Desmarca antes de trocar DS, enquanto ainda conseguimos acessar as variaveis do jogo.
    mov ds,ax ; DS recebe o segmento do tratador antigo; DX ja contem o offset correspondente.
    mov ax,2509h ; Seleciona instalar o vetor 09h novamente, desta vez com o endereco original.
    int 21h ; Restaura o tratador antigo usando DS:DX; menus voltam a usar o teclado BIOS.
    pop ds ; Recupera em DS o valor no topo da pilha, desfazendo o salvamento correspondente.
    mov teclasJipe,0 ; Grava 0 em teclasJipe: mascara das teclas mantidas; cada bit registra uma tecla separadamente.
    mov pedidoSalto,0 ; Grava 0 em pedidoSalto: pedido de uma nova pressao de cima, consumido uma vez pelo movimento.
    mov pedidoTiro,0 ; Grava 0 em pedidoTiro: guarda um toque curto de Espaco ate a proxima leitura do jogo.
    pop dx ; Recupera em DX o valor no topo da pilha, desfazendo o salvamento correspondente.
    pop ax ; Recupera em AX o valor no topo da pilha, desfazendo o salvamento correspondente.
restaurarTecladoFim: ; Rotulo: destino dos saltos dentro de RestaurarTecladoJogo; nao executa acao nem cria uma nova chamada.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
RestaurarTecladoJogo endp ; Fecha a definicao de RestaurarTecladoJogo no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: executar um frame do jipe, independente da repeticao do teclado.
; Entrada: teclas/pedido, posicao/fase. Saida: X/Y/fase e jipeMudou (0/1).
; Altera: AX,BX,flags e dados do jipe. Sem desenho, pontos ou perda de vida.
AtualizarJipe proc near ; Por que: E04: mover e saltar pelos estados do jogo, sem depender da repeticao automatica da tecla.
    mov jipeMudou,0 ; Grava 0 em jipeMudou: aviso de que o jipe mudou ou desapareceu e requer novo desenho.
    pushf ; Guarda FLAGS, incluindo se interrupcoes estavam habilitadas; sera restaurado por POPF.
    cli                        ; copia atomica; IRQ nao perde uma nova pressao | Bloqueia IRQs mascaraveis por poucas instrucoes, evitando perder um pedido entre copiar e zerar.
    mov bl,teclasJipe ; Le teclasJipe em BL: mascara das teclas mantidas; cada bit registra uma tecla separadamente.
    mov al,pedidoSalto ; Le pedidoSalto em AL: pedido de uma nova pressao de cima, consumido uma vez pelo movimento.
    mov pedidoSalto,0 ; Consome o pedido copiado para AL; manter a tecla nao cria uma fila de saltos.
    popf ; Restaura FLAGS anteriores, inclusive a habilitacao de interrupcoes, sem forcar STI.
    cmp al,0 ; Compara AL com 0 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je jipeHorizontal ; Vai a jipeHorizontal se AL for igual a 0.
    cmp estadoSalto,SALTO_CHAO ; Compara estadoSalto com SALTO_CHAO sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jne jipeHorizontal ; Vai a jipeHorizontal se estadoSalto for diferente de SALTO_CHAO.
    mov estadoSalto,SALTO_SUBINDO ; Grava SALTO_SUBINDO em estadoSalto: fase do salto: chao, subida, topo ou descida.
    mov pixelsTopo,0 ; Grava 0 em pixelsTopo: distancia de terreno acumulada desde que o jipe chegou ao topo.
jipeHorizontal: ; Rotulo: destino dos saltos dentro de AtualizarJipe; nao executa acao nem cria uma nova chamada.
    and bl,BIT_ESQUERDA+BIT_DIREITA ; Isola esquerda/direita; cima e Espaco nao devem interferir na decisao horizontal.
    mov ax,jipeX ; Le jipeX em AX: coluna atual da borda esquerda do jipe.
    cmp bl,BIT_ESQUERDA ; Compara BL com BIT_ESQUERDA sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jne jipeDireita ; Vai a jipeDireita se BL for diferente de BIT_ESQUERDA.
    sub ax,PASSO_JIPE ; Tenta mover 5 pixels para a esquerda; CF indicara se cruzou zero e precisa limitar a posicao.
    jnc jipeGuardarX ; Se a subtracao nao pediu emprestimo, X ainda e valido; caso contrario deve ficar em zero.
    xor ax,ax ; Limita a borda esquerda a zero quando o passo seria maior que o espaco disponivel.
    jmp jipeGuardarX ; Continua em jipeGuardarX sem criar retorno; pula o caminho que nao se aplica a este caso.
jipeDireita: ; Rotulo: destino dos saltos dentro de AtualizarJipe; nao executa acao nem cria uma nova chamada.
    cmp bl,BIT_DIREITA ; So direita sozinha move para a direita; nenhuma tecla ou as duas juntas deixam X parado.
    jne jipeVertical           ; nenhuma ou ambas: neutro | Vai a jipeVertical se BL for diferente de BIT_DIREITA.
    add ax,PASSO_JIPE ; Soma PASSO_JIPE a AX, atualizando o valor usado neste calculo.
    cmp ax,JIPE_X_MAX ; Confere se o passo cabe na metade esquerda; a borda esquerda maxima e 140.
    jbe jipeGuardarX ; Vai a jipeGuardarX se AX for menor ou igual a (sem sinal) JIPE_X_MAX.
    mov ax,JIPE_X_MAX ; Limita X a 140: o jipe de 20 pixels continua inteiro na metade esquerda.
jipeGuardarX: ; Rotulo: destino dos saltos dentro de AtualizarJipe; nao executa acao nem cria uma nova chamada.
    cmp ax,jipeX ; Evita marcar mudanca se o jipe ja estava no limite e sua coluna permaneceu igual.
    je jipeVertical ; Vai a jipeVertical se AX for igual a jipeX.
    mov jipeX,ax ; Grava AX em jipeX: coluna atual da borda esquerda do jipe.
    mov jipeMudou,1 ; Grava 1 em jipeMudou: aviso de que o jipe mudou ou desapareceu e requer novo desenho.
jipeVertical: ; Rotulo: destino dos saltos dentro de AtualizarJipe; nao executa acao nem cria uma nova chamada.
    cmp estadoSalto,SALTO_SUBINDO ; Compara estadoSalto com SALTO_SUBINDO sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jne jipeDescer ; Vai a jipeDescer se estadoSalto for diferente de SALTO_SUBINDO.
    sub jipeY,SALTO_PASSO ; Subtrair 3 de Y faz subir 3 pixels, porque as linhas crescem de cima para baixo.
    mov jipeMudou,1 ; Grava 1 em jipeMudou: aviso de que o jipe mudou ou desapareceu e requer novo desenho.
    cmp jipeY,JIPE_Y_CHAO-SALTO_ALTURA ; Confere se chegou a Y=168, quinze pixels acima do chao Y=183.
    ja jipeFim ; Vai a jipeFim se jipeY for maior que (sem sinal) JIPE_Y_CHAO-SALTO_ALTURA.
    mov jipeY,JIPE_Y_CHAO-SALTO_ALTURA ; Fixa exatamente a altura maxima, impedindo ultrapassar o topo por um passo excedente.
    mov estadoSalto,SALTO_TOPO ; Para a mudanca vertical; ContarTopo vai liberar a descida apos o avanco combinado do terreno.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
jipeDescer: ; Rotulo: destino dos saltos dentro de AtualizarJipe; nao executa acao nem cria uma nova chamada.
    cmp estadoSalto,SALTO_DESCENDO ; Compara estadoSalto com SALTO_DESCENDO sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jne jipeFim ; Vai a jipeFim se estadoSalto for diferente de SALTO_DESCENDO.
    add jipeY,SALTO_PASSO ; Somar 3 a Y faz descer; ao chegar ao chao a fase volta a SALTO_CHAO.
    mov jipeMudou,1 ; Grava 1 em jipeMudou: aviso de que o jipe mudou ou desapareceu e requer novo desenho.
    cmp jipeY,JIPE_Y_CHAO ; Compara jipeY com JIPE_Y_CHAO sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jb jipeFim ; Vai a jipeFim se jipeY for menor que (sem sinal) JIPE_Y_CHAO.
    mov jipeY,JIPE_Y_CHAO ; Grava JIPE_Y_CHAO em jipeY: linha atual do topo do jipe; diminuir Y faz subir.
    mov estadoSalto,SALTO_CHAO ; Grava SALTO_CHAO em estadoSalto: fase do salto: chao, subida, topo ou descida.
jipeFim: ; Rotulo: destino dos saltos dentro de AtualizarJipe; nao executa acao nem cria uma nova chamada.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
AtualizarJipe endp ; Fecha a definicao de AtualizarJipe no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: D05, contar distancia do terreno depois de chegar ao topo.
; Entrada: AX=pixels efetivamente avancados; estadoSalto/pixelsTopo.
; Saida: inicia descida ao atingir 5 pixels; saturacao defensiva para chamadas.
; Preserva: registradores. Altera: flags/contador/fase; nao altera X/Y.
; O laco usa 1 px/tick: amostras reais 1,2,3,4,5, sem sexto pixel no topo.
; Nao conta teclas, tempo nem frames; esquerda/parado/limites nao bloqueiam.
ContarTopo proc near ; Por que: E04/D05, corrigida 08/11: medir 5 pixels de terreno funciona mesmo com jipe parado no limite.
    cmp estadoSalto,SALTO_TOPO ; Compara estadoSalto com SALTO_TOPO sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jne topoFim ; Vai a topoFim se estadoSalto for diferente de SALTO_TOPO.
    push ax ; Guarda AX na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    add ax,pixelsTopo ; Acrescenta o avanco real do terreno ao que ja foi contado desde o inicio do topo.
    cmp ax,SALTO_TOPO_PX ; Compara AX com SALTO_TOPO_PX sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jb topoGuardar ; Vai a topoGuardar se AX for menor que (sem sinal) SALTO_TOPO_PX.
    mov ax,SALTO_TOPO_PX ; Limita defensivamente a contagem a 5; no laco atual o terreno realmente avanca 1 por tick.
    mov estadoSalto,SALTO_DESCENDO ; Libera a descida no tick do quinto pixel; a atualizacao do jipe altera Y em seguida.
topoGuardar: ; Rotulo: destino dos saltos dentro de ContarTopo; nao executa acao nem cria uma nova chamada.
    mov pixelsTopo,ax ; Grava AX em pixelsTopo: distancia de terreno acumulada desde que o jipe chegou ao topo.
    pop ax ; Recupera em AX o valor no topo da pilha, desfazendo o salvamento correspondente.
topoFim: ; Rotulo: destino dos saltos dentro de ContarTopo; nao executa acao nem cria uma nova chamada.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
ContarTopo endp ; Fecha a definicao de ContarTopo no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: capturar o fundo limpo atual e desenhar o jipe sempre 20x10.
; Entrada: jipeX/Y validos, ES=fundo sem jipe. Saida: buffer/posicao e sprite.
; Altera: AX,BX,CX,DX,SI,flags. Nao usa os buffers do menu.
CapturarEDesenharJipe proc near ; Por que: E04: salvar o fundo atual antes de colocar o jipe permite apaga-lo depois.
    mov jipeNaTela,1 ; Grava 1 em jipeNaTela: indica se existe uma captura valida do fundo sob o jipe desenhado.
    mov ax,jipeX ; Le jipeX em AX: coluna atual da borda esquerda do jipe.
    mov bx,jipeY ; Le jipeY em BX: linha atual do topo do jipe; diminuir Y faz subir.
    mov jipeDesenhoX,ax ; Guarda onde a captura foi feita; no proximo quadro jipeX pode ja ter mudado.
    mov jipeDesenhoY,bx ; Guarda a linha da captura atual para apagar o sprite na posicao antiga, nao na nova.
    mov cx,JIPE_LARG ; CX recebe JIPE_LARG: quantidade de pixels/caracteres a processar nesta chamada.
    mov dx,JIPE_ALT ; DX recebe JIPE_ALT, altura em pixels que o desenhador precisa percorrer.
    lea si,fundoPartida ; Coloca em SI o offset de fundoPartida; passa o endereco do bloco, nao seu conteudo.
    call SalvarFundo ; Chama SalvarFundo para guardar fundo antes de colocar um bitmap sobre ele; CALL guarda onde voltar.
    lea si,bitmapJipe ; Coloca em SI o offset de bitmapJipe; passa o endereco do bloco, nao seu conteudo.
    call DesenharSprite ; Chama DesenharSprite para desenhar bitmap com transparencia FFh, sem recorte parcial; CALL guarda onde voltar.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
CapturarEDesenharJipe endp ; Fecha a definicao de CapturarEDesenharJipe no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: apagar/redesenhar com ou sem rolagem sem restaurar fundo velho.
; Entrada: flags de mudanca, posicoes, ES=video. Saida: quadro atualizado.
; Altera: AX,BX,CX,DX,SI,DI,BP,flags e video. HUD preservado.
DesenharQuadroPartida proc near ; Por que: E04-E08: fundo muda com terreno e tiros; restaurar uma captura velha causaria rastros.
    mov al,navesMudou ; Le navesMudou em AL: aviso para recompor o ceu e apagar posicoes antigas de naves.
    or al,tirosMudou ; Tiros tambem alteram o fundo: movimento/remocao exige apagar pixels antigos desta regiao.
    cmp al,0 ; Compara AL com 0 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je quadroTerreno ; Vai a quadroTerreno se AL for igual a 0.
    call DesenharNaves          ; recompor ceu atual, inclusive quando so nave muda | Chama DesenharNaves para recompor o ceu preto atual e desenhar somente as naves ativas; CALL guarda onde voltar.
quadroTerreno: ; Rotulo: destino dos saltos dentro de DesenharQuadroPartida; nao executa acao nem cria uma nova chamada.
    mov al,cenarioMudou ; Le cenarioMudou em AL: aviso de que o terreno/obstaculos precisam ser redesenhados.
    or al,tirosMudou             ; movimento/remocao tambem apaga tiros no relevo | Tiros tambem alteram o fundo: movimento/remocao exige apagar pixels antigos desta regiao.
    cmp al,0 ; Compara AL com 0 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je quadroSoJipe ; Vai a quadroSoJipe se AL for igual a 0.
    call DesenharCenario        ; apaga tambem todas as areas antigas dos obstaculos | Recompoe o terreno atual, apagando os obstaculos/tiros/jipe que estavam no quadro anterior.
    call DesenharObstaculos     ; antes da captura do jipe: fundo da rolagem atual | Coloca os obstaculos antes de capturar o fundo do jipe; depois eles reaparecem corretamente ao apaga-lo.
    mov jipeNaTela,0 ; Descarta a captura anterior porque o terreno foi recomposto e ela ficou desatualizada.
    jmp quadroJipe ; Continua em quadroJipe sem criar retorno; pula o caminho que nao se aplica a este caso.
quadroSoJipe: ; Rotulo: destino dos saltos dentro de DesenharQuadroPartida; nao executa acao nem cria uma nova chamada.
    cmp jipeNaTela,0 ; Compara jipeNaTela com 0 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je quadroJipe ; Vai a quadroJipe se jipeNaTela for igual a 0.
    mov jipeNaTela,0 ; Grava 0 em jipeNaTela: indica se existe uma captura valida do fundo sob o jipe desenhado.
    mov ax,jipeDesenhoX ; Le jipeDesenhoX em AX: coluna onde o jipe foi desenhado e onde o fundo salvo deve ser restaurado.
    mov bx,jipeDesenhoY ; Le jipeDesenhoY em BX: linha da captura anterior do fundo, que pode diferir do novo Y do jipe.
    mov cx,JIPE_LARG ; CX recebe JIPE_LARG: quantidade de pixels/caracteres a processar nesta chamada.
    mov dx,JIPE_ALT ; DX recebe JIPE_ALT, altura em pixels que o desenhador precisa percorrer.
    lea si,fundoPartida ; Coloca em SI o offset de fundoPartida; passa o endereco do bloco, nao seu conteudo.
    call DesenharBitmap ; Restaura a captura opaca sob a posicao antiga do jipe; este caminho so vale com terreno atual compativel.
quadroJipe: ; Rotulo: destino dos saltos dentro de DesenharQuadroPartida; nao executa acao nem cria uma nova chamada.
    call DesenharDisparos       ; depois de ceu/terreno; antes da captura do jipe | Desenha tiros sobre ceu e terreno prontos, antes de capturar e desenhar o jipe.
    mov tirosMudou,0 ; Grava 0 em tirosMudou: aviso para apagar posicoes antigas e desenhar os tiros atuais.
    cmp jipeAtivo,0 ; Compara jipeAtivo com 0 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je quadroFim ; Vai a quadroFim se jipeAtivo for igual a 0.
    call CapturarEDesenharJipe ; Chama CapturarEDesenharJipe para capturar o fundo limpo atual e desenhar o jipe sempre 20x10; CALL guarda onde voltar.
quadroFim: ; Rotulo: destino dos saltos dentro de DesenharQuadroPartida; nao executa acao nem cria uma nova chamada.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
DesenharQuadroPartida endp ; Fecha a definicao de DesenharQuadroPartida no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: obter hora DOS completa em centesimos, incluindo horas e minutos.
; Entrada: nenhuma. Saida: DX:AX=0..8639999. Altera: AX,DX,flags.
; Preserva: BX,CX,SI,DI,BP,DS,ES. Resolucao real depende do relogio DOS.
LerCentissegundos proc near ; Por que: E03: converter horas/minutos/segundos evita erros quando o relogio muda de minuto.
    push bx ; Guarda BX na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    push cx ; Guarda CX na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    push si ; Guarda SI na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    mov ah,2Ch ; AH=2Ch pede a hora do DOS em horas, minutos, segundos e centesimos.
    int 21h ; Recebe CH=horas, CL=minutos, DH=segundos, DL=centesimos.
    push dx                     ; guardar segundos e centesimos | Guarda segundos/centesimos enquanto converte primeiro horas e minutos.
    xor ax,ax ; Zera AX para carregar as horas em AL sem deixar bits altos de um calculo anterior.
    mov al,ch ; Coloca as horas em AX, cuja parte alta foi zerada; agora podemos multiplica-las por 60.
    mov bx,60 ; Fator 60: horas viram minutos e, na segunda multiplicacao, minutos viram segundos.
    mul bx ; Multiplica AX por BX sem sinal; DX:AX recebe o produto, com DX na metade alta.
    xor ch,ch ; Retira as horas de CH: CX passa a conter somente os minutos recebidos em CL.
    add ax,cx                   ; horas*60 + minutos | Soma os centesimos da amostra ao total de segundos ja convertido.
    mul bx ; Multiplica AX por BX sem sinal; DX:AX recebe o produto, com DX na metade alta.
    pop cx                      ; CH=segundos, CL=centesimos | Recupera o DX salvo em CX: agora CH contem segundos e CL contem centesimos.
    xor bx,bx ; Zera BX; XOR de um valor com ele mesmo produz zero.
    mov bl,ch ; Recupera os segundos da amostra guardada; BX foi zerado para receber so esse byte.
    add ax,bx ; Soma os segundos ao total de minutos*60; o ADC seguinte conserva eventual transporte.
    adc dx,0                    ; segundos do dia podem ultrapassar 65535 | Propaga o transporte da parte baixa; segundos do dia podem ultrapassar 65535.
    mov si,dx ; Guarda a parte alta antes de MUL sobrescrever DX no proximo produto.
    mov bx,CENT_POR_SEG ; Prepara a conversao de segundos para centesimos multiplicando por 100.
    mul bx ; Multiplica AX por BX sem sinal; DX:AX recebe o produto, com DX na metade alta.
    ; Parte alta dos segundos vale 0 ou 1; multiplicar tambem por 100.
    or si,si ; Testa se havia uma parcela de 65536 segundos que tambem precisa ser convertida.
    jz lerFracao ; Vai a lerFracao se o resultado/teste anterior for zero (ZF=1).
    add dx,CENT_POR_SEG ; Acrescenta 100 a parte alta: equivale a converter aquela parcela de 65536 segundos para centesimos.
lerFracao: ; Rotulo: destino dos saltos dentro de LerCentissegundos; nao executa acao nem cria uma nova chamada.
    xor ch,ch ; Deixa CX somente com os centesimos; os segundos de CH ja foram somados.
    add ax,cx ; Soma os centesimos da amostra ao total de segundos ja convertido.
    adc dx,0 ; Propaga para DX um eventual transporte ao adicionar os centesimos na parte baixa.
    pop si ; Recupera em SI o valor no topo da pilha, desfazendo o salvamento correspondente.
    pop cx ; Recupera em CX o valor no topo da pilha, desfazendo o salvamento correspondente.
    pop bx ; Recupera em BX o valor no topo da pilha, desfazendo o salvamento correspondente.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
LerCentissegundos endp ; Fecha a definicao de LerCentissegundos no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: descontar tempo real desde a ultima consulta, com virada de dia.
; Entrada: tempoAnteriorHi/Lo e relogio DOS; consulta em intervalo <24 horas.
; Saida: CF=1 se mudou tempoRestante, CF=0 caso contrario.
; Altera: AX,BX,CX,DX,flags e dados temporais. Preserva: SI,DI,BP,DS,ES.
AtualizarRelogio proc near ; Por que: E03: medir diferenca de hora real separa duracao da partida da cadencia de movimento.
    call LerCentissegundos ; Chama LerCentissegundos para obter hora DOS completa em centesimos, incluindo horas e minutos; CALL guarda onde voltar.
    mov bx,ax ; Guarda a parte baixa da hora atual antes de transformar AX na diferenca de tempo.
    mov cx,dx ; Guarda a parte alta da hora atual; ela sera a referencia da proxima consulta.
    sub ax,tempoAnteriorLo ; Calcula a parte baixa do intervalo; SBB usara seu emprestimo na parte alta.
    sbb dx,tempoAnteriorHi ; Subtrai a parte alta incluindo emprestimo da parte baixa: diferenca completa de 32 bits.
    mov tempoAnteriorLo,bx ; Grava BX em tempoAnteriorLo: parte baixa da hora da consulta anterior, em centesimos.
    mov tempoAnteriorHi,cx ; Grava CX em tempoAnteriorHi: parte alta da hora anterior, para contar mais que 65535 centesimos.
    jnc relogioDeltaPronto ; MOV nao alterou CF: sem emprestimo final, a hora atual nao passou pela meia-noite.
    add ax,CENT_DIA_BAIXO ; Se virou o dia, soma a parte baixa de 8640000 para obter o intervalo correto.
    adc dx,CENT_DIA_ALTO ; Completa a correcao de um dia somando a parte alta e o transporte da soma anterior.
relogioDeltaPronto: ; Rotulo: destino dos saltos dentro de AtualizarRelogio; nao executa acao nem cria uma nova chamada.
    call ConsumirTempo ; Chama ConsumirTempo para acumular fracoes e descontar somente grupos de 100 centesimos; CALL guarda onde voltar.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
AtualizarRelogio endp ; Fecha a definicao de AtualizarRelogio no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: acumular fracoes e descontar somente grupos de 100 centesimos.
; Entrada: DX:AX=intervalo, margemInicial, fracaoSegundo e tempoRestante.
; Saida: CF=1 se mudou tempo; satura em zero, sem underflow.
; Altera: AX,BX,DX,flags, tempoRestante/fracaoSegundo/margemInicial.
ConsumirTempo proc near ; Por que: E03: acumular fracoes evita perder tempo a cada consulta que dura menos de um segundo.
    ; A primeira amostra pode cair no fim do quantum de ~55 ms do DOS.
    ; Consumir 6 centesimos antes da contagem cobre essa incerteza uma vez.
    or dx,dx ; Testa se DX vale zero sem mudar seu valor; ZF permite decidir se ha algo a processar.
    jnz tempoRetirarMargem ; Vai a tempoRetirarMargem se o resultado/teste anterior for diferente de zero (ZF=0).
    cmp ax,margemInicial ; Compara AX com margemInicial sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jae tempoRetirarMargem ; Vai a tempoRetirarMargem se AX for maior ou igual a (sem sinal) margemInicial.
    sub margemInicial,ax ; Ainda nao consumiu toda a folga inicial; desconta apenas dela, sem diminuir os segundos do jogo.
    clc ; Devolve CF=0: tempo restante nao mudou.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
tempoRetirarMargem: ; Rotulo: destino dos saltos dentro de ConsumirTempo; nao executa acao nem cria uma nova chamada.
    sub ax,margemInicial ; Subtrai margemInicial de AX, obtendo a diferenca usada no passo seguinte.
    sbb dx,0 ; Inclui na parte alta o emprestimo da retirada da margem inicial.
    mov margemInicial,0 ; A margem acabou e nao sera reaplicada em cada segundo.
    add ax,fracaoSegundo ; Recupera a fracao da consulta anterior para nao perder centesimos entre atualizacoes.
    adc dx,0 ; Soma 0 e o transporte CF a DX; completa a parte alta de uma conta maior que 16 bits.
    mov bx,CENT_POR_SEG ; Copia CENT_POR_SEG para BX, preparando esse valor para as instrucoes seguintes sem alterar a origem.
    cmp dx,bx                   ; evitar overflow de DIV em pausas longas | Se DX>=100, o quociente de DX:AX/100 nao cabe em AX; encerrar evita erro de divisao.
    jae tempoEsgotou ; Vai a tempoEsgotou se DX for maior ou igual a (sem sinal) BX.
    div bx                      ; AX=segundos inteiros; DX=resto 0..99 | AX recebe segundos completos; DX recebe os centesimos que sobraram, de 0 a 99.
    mov fracaoSegundo,dx ; Guarda a sobra para a proxima consulta, em vez de descarta-la.
    or ax,ax ; Testa se AX vale zero sem mudar seu valor; ZF permite decidir se ha algo a processar.
    jz tempoSemMudanca ; Vai a tempoSemMudanca se o resultado/teste anterior for zero (ZF=1).
    cmp ax,tempoRestante ; Compara AX com tempoRestante sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jae tempoEsgotou ; Vai a tempoEsgotou se AX for maior ou igual a (sem sinal) tempoRestante.
    sub tempoRestante,ax ; Subtrai AX de tempoRestante, obtendo segundos restantes; a duracao nao depende do numero de quadros.
    stc ; Devolve CF=1: tempo restante mudou.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
tempoEsgotou: ; Rotulo: destino dos saltos dentro de ConsumirTempo; nao executa acao nem cria uma nova chamada.
    mov tempoRestante,0 ; Grava 0 em tempoRestante: segundos restantes; a duracao nao depende do numero de quadros.
    mov fracaoSegundo,0 ; Grava 0 em fracaoSegundo: centesimos ainda insuficientes para descontar um segundo inteiro.
    stc ; Devolve CF=1: tempo restante mudou.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
tempoSemMudanca: ; Rotulo: destino dos saltos dentro de ConsumirTempo; nao executa acao nem cria uma nova chamada.
    clc ; Devolve CF=0: tempo restante nao mudou.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
ConsumirTempo endp ; Fecha a definicao de ConsumirTempo no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: avancar a origem circular, revelando novos pixels pela direita.
; Entrada: rolagem 0..319. Saida: rolagem=(rolagem+PASSO_CENARIO) mod 320.
; Altera: AX,flags e rolagem. Sem desenho nem alteracao do relogio.
AvancarCenario proc near ; Por que: E03: origem circular faz o terreno reaparecer pela direita sem mover o bitmap original.
    mov ax,rolagem ; Le rolagem em AX: coluna da arte que aparece a esquerda; mudar isso desloca o terreno.
    add ax,PASSO_CENARIO ; Avanca a coluna inicial de leitura; a imagem parece andar para a esquerda sem alterar seus bytes.
    cmp ax,TELA_LARG ; Compara AX com TELA_LARG sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jb cenarioGuardar ; Vai a cenarioGuardar se AX for menor que (sem sinal) TELA_LARG.
    sub ax,TELA_LARG ; Volta ao inicio da arte depois da coluna 319, preservando a continuidade da rolagem.
cenarioGuardar: ; Rotulo: destino dos saltos dentro de AvancarCenario; nao executa acao nem cria uma nova chamada.
    mov rolagem,ax ; Grava AX em rolagem: coluna da arte que aparece a esquerda; mudar isso desloca o terreno.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
AvancarCenario endp ; Fecha a definicao de AvancarCenario no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: compor uma linha de 320 pixels da arte com deslocamento circular.
; Entrada: DS:SI=linha de origem, rolagem=0..319; linhaCenario ja preenchida.
; Saida: linhaCenario sobreposta (FFh preserva, 00h opaco).
; Preserva: registradores. Altera: flags (DF=0) e buffer de 320 bytes.
ComporLinhaCircular proc near ; Por que: E03: combinar camadas numa linha de RAM evita mostrar a composicao incompleta no video.
    push ax ; Guarda AX na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    push cx ; Guarda CX na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    push si ; Guarda SI na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    push di ; Guarda DI na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    push bp ; Guarda BP na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    cld ; DF=0 faz LODSB/MOVSB/STOSB avancarem os enderecos; evita copiar os pixels para tras.
    mov bp,si ; Guarda o inicio da linha da arte para calcular seu limite e saber quando circular.
    add bp,TELA_LARG            ; fim exclusivo da linha de origem | BP marca o fim exclusivo da linha original: quando SI chega aqui, volta ao inicio da arte.
    add si,rolagem ; Comeca a ler a arte na coluna deslocada; e isso que produz a rolagem para a esquerda.
    lea di,linhaCenario ; Coloca em DI o offset de linhaCenario; passa o endereco do bloco, nao seu conteudo.
    mov cx,TELA_LARG ; CX recebe TELA_LARG: quantidade de pixels/caracteres a processar nesta chamada.
comporPixel: ; Rotulo: destino dos saltos dentro de ComporLinhaCircular; nao executa acao nem cria uma nova chamada.
    lodsb ; Le o proximo byte em DS:SI para AL e avanca SI; cada byte da arte representa um pixel.
    cmp al,TRANSPARENTE ; Compara AL com TRANSPARENTE sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je comporTransparente ; Vai a comporTransparente se AL for igual a TRANSPARENTE.
    mov [di],al ; Grava no buffer em DS, ainda nao no video; FFh pula esta escrita.
comporTransparente: ; Rotulo: destino dos saltos dentro de ComporLinhaCircular; nao executa acao nem cria uma nova chamada.
    inc di ; Avanca uma coluna no buffer mesmo se o pixel for transparente; a transparencia tambem ocupa espaco.
    cmp si,bp ; Compara SI com BP sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jb comporProximo ; Vai a comporProximo se SI for menor que (sem sinal) BP.
    sub si,TELA_LARG            ; somente volta na origem, destino continua | Ao chegar ao fim da arte, volta 320 bytes; o destino continua avancando normalmente.
comporProximo: ; Rotulo: destino dos saltos dentro de ComporLinhaCircular; nao executa acao nem cria uma nova chamada.
    loop comporPixel ; Diminui CX e volta a comporPixel se ainda restam itens; zero encerra esta repeticao.
    pop bp ; Recupera em BP o valor no topo da pilha, desfazendo o salvamento correspondente.
    pop di ; Recupera em DI o valor no topo da pilha, desfazendo o salvamento correspondente.
    pop si ; Recupera em SI o valor no topo da pilha, desfazendo o salvamento correspondente.
    pop cx ; Recupera em CX o valor no topo da pilha, desfazendo o salvamento correspondente.
    pop ax ; Recupera em AX o valor no topo da pilha, desfazendo o salvamento correspondente.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
ComporLinhaCircular endp ; Fecha a definicao de ComporLinhaCircular no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: recompor terreno em memoria e copiar linhas prontas para o video.
; Entrada: rolagem, DS=dados, ES=video. Saida: y=100..192 e pista 193..199.
; Altera: AX,BX,CX,DX,SI,DI,BP,flags. HUD/ceu preservados; sem fundos velhos.
; D10: montanhas 100..163, montes 132..163, ultima linha estendida ate 192.
DesenharCenario proc near ; Por que: E03: um buffer de linha economiza memoria e permite repetir o relevo continuamente.
    cld ; DF=0 faz LODSB/MOVSB/STOSB avancarem os enderecos; evita copiar os pixels para tras.
    mov bp,CENARIO_Y ; BP acompanha a linha da tela que esta sendo composta; comeca em Y=100.
    mov di,CENARIO_Y*TELA_LARG ; DI=100*320: endereco do primeiro pixel do relevo dentro do segmento de video.
cenarioLinha: ; Rotulo: destino dos saltos dentro de DesenharCenario; nao executa acao nem cria uma nova chamada.
    cmp bp,CENARIO_Y+MONTANHAS_ALT ; Compara BP com CENARIO_Y+MONTANHAS_ALT sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jae cenarioCopiar           ; base pronta: repetir ultima linha composta | Vai a cenarioCopiar se BP for maior ou igual a (sem sinal) CENARIO_Y+MONTANHAS_ALT.
    push di ; Guarda o destino na tela antes de reutilizar DI como destino do buffer em RAM.
    push es ; Guarda o segmento de video antes de trocar ES para limpar o buffer de dados.
    push ds ; Copia o segmento de dados pela pilha para ES.
    pop es ; ES agora aponta para RAM do jogo: STOSB deve limpar linhaCenario, nao a tela.
    lea di,linhaCenario ; Coloca em DI o offset de linhaCenario; passa o endereco do bloco, nao seu conteudo.
    mov cx,TELA_LARG ; CX recebe TELA_LARG: quantidade de pixels/caracteres a processar nesta chamada.
    mov al,COR_FUNDO ; AL recebe COR_FUNDO, cor que sera repetida no preenchimento de pixels.
    rep stosb                   ; limpar so o buffer, nunca piscar preto no video | Preenche apenas a linha de RAM com preto; depois as camadas serao compostas sobre ela.
    pop es ; Recupera A000h em ES antes de enviar a linha pronta para a tela.
    pop di ; Recupera o offset da linha na tela, preservado enquanto DI apontava para o buffer.
    mov ax,bp ; Copia a linha atual da tela para calcular qual linha da arte deve ser lida.
    sub ax,CENARIO_Y ; Converte a linha da tela em numero de linha dentro da arte das montanhas.
    mov bx,TELA_LARG ; Uma linha da arte ocupa 320 bytes; multiplicar por 320 encontra seu inicio.
    mul bx ; Multiplica AX por BX sem sinal; DX:AX recebe o produto, com DX na metade alta.
    lea si,bitmapMontanhas ; Coloca em SI o offset de bitmapMontanhas; passa o endereco do bloco, nao seu conteudo.
    add si,ax ; Soma o deslocamento da linha ao inicio do bitmap, selecionando apenas os pixels dessa linha.
    call ComporLinhaCircular ; Chama ComporLinhaCircular para compor uma linha de 320 pixels da arte com deslocamento circular; CALL guarda onde voltar.
    cmp bp,MONTES_Y ; Compara BP com MONTES_Y sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jb cenarioCopiar ; Vai a cenarioCopiar se BP for menor que (sem sinal) MONTES_Y.
    mov ax,bp ; Copia a linha atual da tela para calcular qual linha da arte deve ser lida.
    sub ax,MONTES_Y ; Converte a linha da tela em numero de linha dentro da arte dos montes.
    mul bx ; Multiplica AX por BX sem sinal; DX:AX recebe o produto, com DX na metade alta.
    lea si,bitmapMontes ; Coloca em SI o offset de bitmapMontes; passa o endereco do bloco, nao seu conteudo.
    add si,ax ; Soma o deslocamento da linha ao inicio do bitmap, selecionando apenas os pixels dessa linha.
    call ComporLinhaCircular ; Chama ComporLinhaCircular para compor uma linha de 320 pixels da arte com deslocamento circular; CALL guarda onde voltar.
cenarioCopiar: ; Rotulo: destino dos saltos dentro de DesenharCenario; nao executa acao nem cria uma nova chamada.
    lea si,linhaCenario ; Coloca em SI o offset de linhaCenario; passa o endereco do bloco, nao seu conteudo.
    mov cx,TELA_LARG ; CX recebe TELA_LARG: quantidade de pixels/caracteres a processar nesta chamada.
    rep movsb                   ; linha final ja composta -> A000h | Copia 320 pixels ja compostos de DS:SI para ES:DI; evita exibir uma camada incompleta.
    inc bp ; Avanca uma linha da tela; DI ja avancou 320 pixels pela copia anterior.
    cmp bp,PISTA_Y ; Compara BP com PISTA_Y sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jb cenarioLinha ; Vai a cenarioLinha se BP for menor que (sem sinal) PISTA_Y.
    mov al,COR_PISTA             ; pista por ultimo, sem relevo por cima | AL recebe COR_PISTA, cor que sera repetida no preenchimento de pixels.
    mov cx,TELA_LARG*PISTA_ALT ; Prepara 320*7=2240 pixels amarelos, cobrindo toda a pista inferior.
    rep stosb ; Preenche a pista inteira de amarelo depois do relevo, garantindo suas sete linhas.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
DesenharCenario endp ; Fecha a definicao de DesenharCenario no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: desenhar score esquerdo, vidas centrais e tempo direito (D01).
; Entrada: scorePartida, vidas=0..3, tempoRestante=0..999, ES=video.
; Saida: barra y=0..14, sem digitos/sprites antigos. Zero vidas limpa o icone.
; Altera: AX,BX,CX,DX,SI,DI,flags e buffers decimais; nao muda valores do jogo.
DesenharStatus proc near ; Por que: E03/D01: mostrar valores atuais em uma barra separada preserva a area de jogo.
    cld ; DF=0 faz LODSB/MOVSB/STOSB avancarem os enderecos; evita copiar os pixels para tras.
    xor di,di ; Zera DI para comecar pela primeira entrada/posicao percorrida nesta rotina.
    mov cx,TELA_LARG*HUD_ALT ; Limpa somente 320*15 pixels do HUD para apagar digitos/coracoes antigos sem tocar no jogo.
    mov al,COR_FUNDO ; AL recebe COR_FUNDO, cor que sera repetida no preenchimento de pixels.
    rep stosb ; Repete a cor AL em CX bytes de ES:DI; avanca o destino e termina com CX=0.
    mov ax,scorePartida ; Le scorePartida em AX: pontuacao acumulada da sessao; nao reinicia ao perder uma vida.
    call FormatarScore ; Chama FormatarScore para converter numero para cinco algarismos, incluindo zeros iniciais; CALL guarda onde voltar.
    lea si,textoScore ; Coloca em SI o offset de textoScore; passa o endereco do bloco, nao seu conteudo.
    mov cx,SCORE_TAM ; CX recebe SCORE_TAM: quantidade de pixels/caracteres a processar nesta chamada.
    mov dx,HUD_SCORE_POS ; Copia HUD_SCORE_POS para DX, preparando esse valor para as instrucoes seguintes sem alterar a origem.
    mov bl,COR_BRANCO ; BL recebe COR_BRANCO; EscreverTexto/MostrarArte usara essa cor para os caracteres.
    call EscreverTexto ; Chama EscreverTexto para imprimir texto BIOS, preservando ES de video para os bitmaps; CALL guarda onde voltar.
    cmp vidas,0 ; Compara vidas com 0 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je statusRelogio ; Vai a statusRelogio se vidas for igual a 0.
    lea si,bitmapVidas3 ; Comeca pela imagem de tres vidas; as comparacoes seguintes escolhem dois ou um se necessario.
    cmp vidas,3 ; Compara vidas com 3 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je statusVidas ; Vai a statusVidas se vidas for igual a 3.
    lea si,bitmapVidas2 ; Troca para a imagem de duas vidas se nao havia tres.
    cmp vidas,2 ; Compara vidas com 2 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je statusVidas ; Vai a statusVidas se vidas for igual a 2.
    lea si,bitmapVidas1 ; Com vidas validas restantes, se nao eram tres nem duas, usa a imagem de uma vida.
statusVidas: ; Rotulo: destino dos saltos dentro de DesenharStatus; nao executa acao nem cria uma nova chamada.
    mov ax,HUD_VIDAS_X ; Copia HUD_VIDAS_X para AX, preparando esse valor para as instrucoes seguintes sem alterar a origem.
    mov bx,HUD_VIDAS_Y ; Copia HUD_VIDAS_Y para BX, preparando esse valor para as instrucoes seguintes sem alterar a origem.
    mov cx,VIDAS_LARG ; CX recebe VIDAS_LARG: quantidade de pixels/caracteres a processar nesta chamada.
    mov dx,VIDAS_ALT ; DX recebe VIDAS_ALT, altura em pixels que o desenhador precisa percorrer.
    call DesenharSprite ; Chama DesenharSprite para desenhar bitmap com transparencia FFh, sem recorte parcial; CALL guarda onde voltar.
statusRelogio: ; Rotulo: destino dos saltos dentro de DesenharStatus; nao executa acao nem cria uma nova chamada.
    mov ax,HUD_RELOGIO_X ; Copia HUD_RELOGIO_X para AX, preparando esse valor para as instrucoes seguintes sem alterar a origem.
    mov bx,HUD_RELOGIO_Y ; Copia HUD_RELOGIO_Y para BX, preparando esse valor para as instrucoes seguintes sem alterar a origem.
    mov cx,RELOGIO_LARG ; CX recebe RELOGIO_LARG: quantidade de pixels/caracteres a processar nesta chamada.
    mov dx,RELOGIO_ALT ; DX recebe RELOGIO_ALT, altura em pixels que o desenhador precisa percorrer.
    lea si,bitmapRelogio ; Coloca em SI o offset de bitmapRelogio; passa o endereco do bloco, nao seu conteudo.
    call DesenharSprite ; Chama DesenharSprite para desenhar bitmap com transparencia FFh, sem recorte parcial; CALL guarda onde voltar.
    mov ax,tempoRestante ; Le tempoRestante em AX: segundos restantes; a duracao nao depende do numero de quadros.
    mov cx,TEMPO_DIGITOS ; CX recebe TEMPO_DIGITOS: quantidade de pixels/caracteres a processar nesta chamada.
    lea di,digitosTempo+TEMPO_DIGITOS-1 ; Coloca em DI o offset de digitosTempo+TEMPO_DIGITOS-1; passa o endereco do bloco, nao seu conteudo.
    call FormatarNumero ; Chama FormatarNumero para converter inteiro unsigned em campo decimal de largura fixa; CALL guarda onde voltar.
    lea si,digitosTempo ; Coloca em SI o offset de digitosTempo; passa o endereco do bloco, nao seu conteudo.
    mov cx,TEMPO_DIGITOS ; CX recebe TEMPO_DIGITOS: quantidade de pixels/caracteres a processar nesta chamada.
    mov dx,HUD_TEMPO_POS ; Copia HUD_TEMPO_POS para DX, preparando esse valor para as instrucoes seguintes sem alterar a origem.
    mov bl,COR_BRANCO ; BL recebe COR_BRANCO; EscreverTexto/MostrarArte usara essa cor para os caracteres.
    call EscreverTexto ; Chama EscreverTexto para imprimir texto BIOS, preservando ES de video para os bitmaps; CALL guarda onde voltar.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
DesenharStatus endp ; Fecha a definicao de DesenharStatus no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: validar retangulo inteiro e calcular endereco inicial.
; Entrada: AX=x, BX=y, CX=largura, DX=altura (valores sem sinal).
; Saida: CF=0 valido: DI=y*320+x, BP=altura, BX=salto entre linhas.
;        CF=1 invalido, nao acessar video. Nao ha recorte parcial.
; Altera: AX,BX,DX,DI,BP,flags. Preserva: CX,SI,DS,ES.
PrepararRetangulo proc near ; Por que: E01: validar uma vez e calcular y*320+x serve a varias rotinas de desenho.
    cmp cx, 1 ; Rejeita largura zero: um laco de pixels precisa de pelo menos uma coluna.
    jb retanguloInvalido ; Vai a retanguloInvalido se CX for menor que (sem sinal) 1.
    cmp cx, TELA_LARG ; Rejeita largura maior que a tela antes de calcular a ultima origem permitida.
    ja retanguloInvalido ; Vai a retanguloInvalido se CX for maior que (sem sinal) TELA_LARG.
    cmp dx, 1 ; Rejeita altura zero: nao existe retangulo desenhavel sem linhas.
    jb retanguloInvalido ; Vai a retanguloInvalido se DX for menor que (sem sinal) 1.
    cmp dx, TELA_ALT ; Rejeita altura maior que 200, impedindo escrita alem da memoria da tela.
    ja retanguloInvalido ; Vai a retanguloInvalido se DX for maior que (sem sinal) TELA_ALT.
    mov di, TELA_LARG ; Copia TELA_LARG para DI, preparando esse valor para as instrucoes seguintes sem alterar a origem.
    sub di, cx ; Calcula 320-largura: maior X inicial que permite o retangulo inteiro.
    cmp ax, di ; Confere X contra a ultima coluna inicial permitida para essa largura.
    ja retanguloInvalido ; Vai a retanguloInvalido se AX for maior que (sem sinal) DI.
    mov di, TELA_ALT ; Copia TELA_ALT para DI, preparando esse valor para as instrucoes seguintes sem alterar a origem.
    sub di, dx ; Calcula 200-altura: maior Y inicial que permite o retangulo inteiro.
    cmp bx, di ; Confere Y contra a ultima linha inicial permitida para essa altura.
    ja retanguloInvalido ; Vai a retanguloInvalido se BX for maior que (sem sinal) DI.
    mov bp, dx ; Guarda a altura em BP porque a multiplicacao vai usar e alterar DX.
    mov di, ax ; Guarda X em DI antes de usar AX para calcular Y*320.
    mov ax, bx ; Coloca Y em AX para a multiplicacao pelo comprimento de uma linha.
    mov bx, TELA_LARG ; Copia TELA_LARG para BX, preparando esse valor para as instrucoes seguintes sem alterar a origem.
    mul bx                       ; DX:AX=y*320; sempre cabe em AX | Calcula Y*320 em DX:AX; com o retangulo validado o resultado cabe nos 16 bits de AX.
    add di, ax ; Soma X ao inicio da linha: DI passa a ser o offset do primeiro pixel.
    sub bx, cx ; BX=320-largura: salto do fim de uma linha desenhada ao inicio da seguinte.
    clc ; Devolve CF=0: retangulo valido; endereco calculado.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
retanguloInvalido: ; Rotulo: destino dos saltos dentro de PrepararRetangulo; nao executa acao nem cria uma nova chamada.
    stc ; Devolve CF=1: retangulo invalido; nao acessar video.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
PrepararRetangulo endp ; Fecha a definicao de PrepararRetangulo no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: copiar bitmap opaco linha a linha para o video.
; Entrada: DS:SI=bitmap, ES=VIDEO_SEG, AX=x,BX=y,CX=largura,DX=altura.
;          Origem deve conter largura*altura bytes no segmento DS.
; Saida: retangulo desenhado; coordenadas invalidas nao escrevem nada.
; Preserva: todos os registradores. Altera: flags (DF fica zero), video.
DesenharBitmap proc near ; Por que: E01: copiar todos os pixels serve tanto a imagens opacas quanto a restauracao de fundos.
    push ax ; Guarda AX na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    push bx ; Guarda BX na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    push cx ; Guarda CX do chamador; a rotina o usara como contador de pixels e o devolvera ao terminar.
    push dx ; Guarda DX na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    push si ; Guarda SI na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    push di ; Guarda DI na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    push bp ; Guarda BP na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    cld                          ; garante DF=0 inclusive se a area for invalida | DF=0 faz LODSB/MOVSB/STOSB avancarem os enderecos; evita copiar os pixels para tras.
    call PrepararRetangulo ; Chama PrepararRetangulo para validar retangulo inteiro e calcular endereco inicial; CALL guarda onde voltar.
    jc desenhoFim ; Vai a desenhoFim se retangulo invalido; nao acessar video.
desenhoLinha: ; Rotulo: destino dos saltos dentro de DesenharBitmap; nao executa acao nem cria uma nova chamada.
    push cx ; Guarda a largura porque REP MOVSB consome CX e o deixa em zero.
    rep movsb                    ; DS:SI -> ES:DI; avanca SI e DI | Copia CX bytes de DS:SI para ES:DI; avanca ambos os enderecos e termina com CX=0.
    pop cx ; Recupera a largura para copiar a proxima linha com a mesma quantidade de pixels.
    add di, bx                   ; pula pixels fora do retangulo | Pula as colunas da tela fora do retangulo: DI chega ao mesmo X na proxima linha de 320 pixels.
    dec bp ; Uma linha terminou; reduz a altura restante para saber se ainda deve processar outra.
    jnz desenhoLinha ; Vai a desenhoLinha se o resultado/teste anterior for diferente de zero (ZF=0).
desenhoFim: ; Rotulo: destino dos saltos dentro de DesenharBitmap; nao executa acao nem cria uma nova chamada.
    pop bp ; Recupera em BP o valor no topo da pilha, desfazendo o salvamento correspondente.
    pop di ; Recupera em DI o valor no topo da pilha, desfazendo o salvamento correspondente.
    pop si ; Recupera em SI o valor no topo da pilha, desfazendo o salvamento correspondente.
    pop dx ; Recupera em DX o valor no topo da pilha, desfazendo o salvamento correspondente.
    pop cx ; Restaura CX do chamador depois que todas as linhas foram processadas (ou o desenho foi rejeitado).
    pop bx ; Recupera em BX o valor no topo da pilha, desfazendo o salvamento correspondente.
    pop ax ; Recupera em AX o valor no topo da pilha, desfazendo o salvamento correspondente.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
DesenharBitmap endp ; Fecha a definicao de DesenharBitmap no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: guardar fundo antes de colocar um bitmap sobre ele.
; Entrada: DS:SI=buffer de largura*altura bytes; demais como DesenharBitmap.
; Saida: fundo salvo no buffer; coordenadas invalidas nao copiam nada.
; Preserva: todos os registradores. Altera: flags e buffer em DS.
SalvarFundo proc near ; Por que: E01: guardar o que existia sob o objeto permite apaga-lo sem destruir o cenario.
    push ax ; Guarda AX na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    push bx ; Guarda BX na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    push cx ; Guarda CX do chamador; a rotina o usara como contador de pixels e o devolvera ao terminar.
    push dx ; Guarda DX na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    push si ; Guarda SI na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    push di ; Guarda DI na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    push bp ; Guarda BP na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    call PrepararRetangulo ; Chama PrepararRetangulo para validar retangulo inteiro e calcular endereco inicial; CALL guarda onde voltar.
    jc salvarFim ; Vai a salvarFim se retangulo invalido; nao acessar video.
salvarLinha: ; Rotulo: destino dos saltos dentro de SalvarFundo; nao executa acao nem cria uma nova chamada.
    push cx ; Guarda a largura da linha antes de o laco de pixels consumir CX; POP permite reutiliza-la na linha seguinte.
salvarPixel: ; Rotulo: destino dos saltos dentro de SalvarFundo; nao executa acao nem cria uma nova chamada.
    mov al, es:[di] ; Le um pixel do video ES:DI; estamos capturando o fundo, nao desenhando.
    mov [si], al ; Guarda esse pixel no buffer DS:SI, para restaura-lo quando o objeto se mover.
    inc di ; Avanca para o proximo pixel do video que precisa ser guardado.
    inc si ; Avanca para o proximo byte livre do buffer que recebe a captura.
    loop salvarPixel ; Diminui CX e volta a salvarPixel se ainda restam itens; zero encerra esta repeticao.
    pop cx ; Recupera a largura original para processar a proxima linha do mesmo retangulo.
    add di, bx ; Pula as colunas da tela fora do retangulo: DI chega ao mesmo X na proxima linha de 320 pixels.
    dec bp ; Uma linha terminou; reduz a altura restante para saber se ainda deve processar outra.
    jnz salvarLinha ; Vai a salvarLinha se o resultado/teste anterior for diferente de zero (ZF=0).
salvarFim: ; Rotulo: destino dos saltos dentro de SalvarFundo; nao executa acao nem cria uma nova chamada.
    pop bp ; Recupera em BP o valor no topo da pilha, desfazendo o salvamento correspondente.
    pop di ; Recupera em DI o valor no topo da pilha, desfazendo o salvamento correspondente.
    pop si ; Recupera em SI o valor no topo da pilha, desfazendo o salvamento correspondente.
    pop dx ; Recupera em DX o valor no topo da pilha, desfazendo o salvamento correspondente.
    pop cx ; Restaura CX do chamador depois que todas as linhas foram processadas (ou o desenho foi rejeitado).
    pop bx ; Recupera em BX o valor no topo da pilha, desfazendo o salvamento correspondente.
    pop ax ; Recupera em AX o valor no topo da pilha, desfazendo o salvamento correspondente.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
SalvarFundo endp ; Fecha a definicao de SalvarFundo no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: desenhar bitmap com transparencia FFh, sem recorte parcial.
; Entrada: como DesenharBitmap; DS:SI contem largura*altura bytes.
; Saida: FFh preserva fundo, 00h desenha preto; invalido nao escreve.
; Preserva: todos os registradores. Altera: flags (DF=0) e video.
DesenharSprite proc near ; Por que: E02: ignorar FFh permite desenhar formas irregulares sem um retangulo opaco em volta.
    push ax ; Guarda AX na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    push bx ; Guarda BX na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    push cx ; Guarda CX do chamador; a rotina o usara como contador de pixels e o devolvera ao terminar.
    push dx ; Guarda DX na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    push si ; Guarda SI na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    push di ; Guarda DI na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    push bp ; Guarda BP na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    cld ; DF=0 faz LODSB/MOVSB/STOSB avancarem os enderecos; evita copiar os pixels para tras.
    call PrepararRetangulo ; Chama PrepararRetangulo para validar retangulo inteiro e calcular endereco inicial; CALL guarda onde voltar.
    jc spriteFim ; Vai a spriteFim se retangulo invalido; nao acessar video.
spriteLinha: ; Rotulo: destino dos saltos dentro de DesenharSprite; nao executa acao nem cria uma nova chamada.
    push cx ; Guarda a largura da linha antes de o laco de pixels consumir CX; POP permite reutiliza-la na linha seguinte.
spritePixel: ; Rotulo: destino dos saltos dentro de DesenharSprite; nao executa acao nem cria uma nova chamada.
    lodsb ; Le um pixel da arte DS:SI em AL e avanca SI, pois DF esta zerado.
    cmp al,TRANSPARENTE ; Compara AL com TRANSPARENTE sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je spriteTransparente ; Vai a spriteTransparente se AL for igual a TRANSPARENTE.
    mov es:[di],al ; So escreve pixels opacos no video; FFh deixa aparecer o fundo que ja estava ali.
spriteTransparente: ; Rotulo: destino dos saltos dentro de DesenharSprite; nao executa acao nem cria uma nova chamada.
    inc di ; Avanca no video mesmo quando AL=FFh; pixel transparente ocupa uma coluna, mas nao substitui a cor.
    loop spritePixel ; Diminui CX e volta a spritePixel se ainda restam itens; zero encerra esta repeticao.
    pop cx ; Recupera a largura original para processar a proxima linha do mesmo retangulo.
    add di,bx ; Pula as colunas da tela fora do retangulo: DI chega ao mesmo X na proxima linha de 320 pixels.
    dec bp ; Uma linha terminou; reduz a altura restante para saber se ainda deve processar outra.
    jnz spriteLinha ; Vai a spriteLinha se o resultado/teste anterior for diferente de zero (ZF=0).
spriteFim: ; Rotulo: destino dos saltos dentro de DesenharSprite; nao executa acao nem cria uma nova chamada.
    pop bp ; Recupera em BP o valor no topo da pilha, desfazendo o salvamento correspondente.
    pop di ; Recupera em DI o valor no topo da pilha, desfazendo o salvamento correspondente.
    pop si ; Recupera em SI o valor no topo da pilha, desfazendo o salvamento correspondente.
    pop dx ; Recupera em DX o valor no topo da pilha, desfazendo o salvamento correspondente.
    pop cx ; Restaura CX do chamador depois que todas as linhas foram processadas (ou o desenho foi rejeitado).
    pop bx ; Recupera em BX o valor no topo da pilha, desfazendo o salvamento correspondente.
    pop ax ; Recupera em AX o valor no topo da pilha, desfazendo o salvamento correspondente.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
DesenharSprite endp ; Fecha a definicao de DesenharSprite no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: reiniciar somente geracao/obstaculos para uma NOVA sessao.
; Entrada: nenhuma. Saida: lista vazia, semente dos ticks, primeira cratera.
; Altera: AX,CX,DX,DI,flags e dados; nao deve ser chamada na perda de vida.
ReiniciarObstaculos proc near ; Por que: E05: limpar geracao so na nova sessao preserva o mundo quando o jogador perde vida.
    xor di,di ; Zera DI para comecar pela primeira entrada/posicao percorrida nesta rotina.
reiniciarObstLoop: ; Rotulo: destino dos saltos dentro de ReiniciarObstaculos; nao executa acao nem cria uma nova chamada.
    mov obstTipo[di],OBST_LIVRE ; Grava OBST_LIVRE em obstTipo[di]: tipo de cada obstaculo, ou OBST_LIVRE para uma vaga disponivel.
    mov obstPassagem[di],PASS_NOVO ; Grava PASS_NOVO em obstPassagem[di]: progresso da travessia de cada obstaculo, evitando pontos indevidos ou repetidos.
    mov obstImpactos[di],0 ; Grava 0 em obstImpactos[di]: impactos recebidos por cada rocha; a rocha 4 precisa acumular dois.
    mov obstX[di],0 ; Grava 0 em obstX[di]: coluna de cada obstaculo; admite negativo na saida parcial pela esquerda.
    add di,2 ; Avanca DI dois bytes para a proxima entrada word da tabela, sem misturar objetos.
    cmp di,OBST_MAX*2 ; Compara DI com OBST_MAX*2 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jb reiniciarObstLoop ; Vai a reiniciarObstLoop se DI for menor que (sem sinal) OBST_MAX*2.
    mov proximoEm,0 ; Grava 0 em proximoEm: pixels de terreno que faltam para nascer o proximo obstaculo.
    mov proximaRocha,0 ; Grava 0 em proximaRocha: alterna o nascimento entre cratera e rocha intermediaria.
    mov ateCratera,0 ; Grava 0 em ateCratera: distancia ja planejada entre a rocha e a proxima cratera.
    mov statusMudou,0 ; Grava 0 em statusMudou: aviso para atualizar score/vidas no HUD depois de um evento.
    mov ah,0 ; Copia 0 para AH, preparando esse valor para as instrucoes seguintes sem alterar a origem.
    int 1Ah ; Consulta os ticks BIOS em CX:DX; DX fornece a amostra usada pela cadencia, sem esperar.
    xor dx,cx ; Mistura as metades alta e baixa do contador BIOS para variar a semente conforme o instante de inicio.
    mov semente,dx ; Grava DX em semente: estado do gerador pseudoaleatorio compartilhado por obstaculos e naves.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
ReiniciarObstaculos endp ; Fecha a definicao de ReiniciarObstaculos no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: pseudoaleatorio simples de 16 bits, com resto em faixa finita.
; Entrada: CX=limite exclusivo 1..256. Saida: AX=0..CX-1; nova semente.
; Altera: AX,DX,flags. Preserva: demais. Nao ha tentativas/rejeicoes.
Sortear proc near ; Por que: E05, reutilizada E06: uma sequencia simples escolhe tipos/posicoes sem biblioteca externa.
    push bx ; Guarda BX na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    mov ax,semente ; Le semente em AX: estado do gerador pseudoaleatorio compartilhado por obstaculos e naves.
    mov bx,25173 ; Multiplicador da sequencia pseudoaleatoria de 16 bits; nao e uma regra de jogo.
    mul bx ; Multiplica AX por BX sem sinal; DX:AX recebe o produto, com DX na metade alta.
    add ax,13849               ; overflow intencional: modulo 65536 | Soma o incremento; manter so AX implementa o resto modulo 65536 da semente.
    mov semente,ax ; Grava AX em semente: estado do gerador pseudoaleatorio compartilhado por obstaculos e naves.
    mov al,ah                 ; byte alto: evita ciclo curto dos bits baixos | Usa o byte alto da semente, evitando o ciclo curto observado nos bits baixos.
    xor ah,ah ; Zera AH: AX passa a conter apenas o byte sorteado, de 0 a 255.
    xor dx,dx ; DX=0 prepara a divisao sem sinal do valor de AX pelo limite recebido.
    div cx ; O resto da divisao por CX fica em DX e esta entre 0 e CX-1; nao garante sorteio perfeitamente uniforme.
    mov ax,dx ; Devolve esse resto em AX, que e o resultado combinado com os chamadores.
    pop bx ; Recupera em BX o valor no topo da pilha, desfazendo o salvamento correspondente.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
Sortear endp ; Fecha a definicao de Sortear no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: mover todos com o terreno e gerar C,R,C em distancias sorteadas.
; Entrada: lista/proximoEm. Saida: X -= PASSO_CENARIO; novos pela direita.
; Altera: AX,BX,CX,DX,DI,flags. Distancia negativa preserva sobra do passo.
AvancarObstaculos proc near ; Por que: E05: planejar cratera-rocha-cratera garante folgas sem tentativas aleatorias infinitas.
    xor di,di ; Zera DI para comecar pela primeira entrada/posicao percorrida nesta rotina.
obstMover: ; Rotulo: destino dos saltos dentro de AvancarObstaculos; nao executa acao nem cria uma nova chamada.
    cmp obstTipo[di],OBST_LIVRE ; Compara obstTipo[DI] (entrada selecionada pelo offset em bytes) com OBST_LIVRE sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je obstMoverProximo ; Vai a obstMoverProximo se obstTipo[DI] (entrada selecionada pelo offset em bytes) for igual a OBST_LIVRE.
    sub obstX[di],PASSO_CENARIO ; Subtrai PASSO_CENARIO de obstX[DI] (entrada selecionada pelo offset em bytes), obtendo coluna de cada obstaculo; admite negativo na saida parcial pela esquerda.
obstMoverProximo: ; Rotulo: destino dos saltos dentro de AvancarObstaculos; nao executa acao nem cria uma nova chamada.
    add di,2 ; Avanca DI dois bytes para a proxima entrada word da tabela, sem misturar objetos.
    cmp di,OBST_MAX*2 ; Compara DI com OBST_MAX*2 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jb obstMover ; Vai a obstMover se DI for menor que (sem sinal) OBST_MAX*2.
    sub proximoEm,PASSO_CENARIO ; O terreno andou: falta essa quantidade a menos para aparecer o proximo obstaculo.
    cmp proximoEm,0 ; Compara proximoEm com 0 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jg obstAvancoFim ; Vai a obstAvancoFim se proximoEm for maior que (com sinal) 0.
    xor di,di ; Zera DI para comecar pela primeira entrada/posicao percorrida nesta rotina.
obstVaga: ; Rotulo: destino dos saltos dentro de AvancarObstaculos; nao executa acao nem cria uma nova chamada.
    cmp obstTipo[di],OBST_LIVRE ; Compara obstTipo[DI] (entrada selecionada pelo offset em bytes) com OBST_LIVRE sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je obstNascer ; Vai a obstNascer se obstTipo[DI] (entrada selecionada pelo offset em bytes) for igual a OBST_LIVRE.
    add di,2 ; Avanca DI dois bytes para a proxima entrada word da tabela, sem misturar objetos.
    cmp di,OBST_MAX*2 ; Compara DI com OBST_MAX*2 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jb obstVaga ; Vai a obstVaga se DI for menor que (sem sinal) OBST_MAX*2.
    ; Capacidade folgada na configuracao validada; nunca sobrescrever ativo.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
obstNascer: ; Rotulo: destino dos saltos dentro de AvancarObstaculos; nao executa acao nem cria uma nova chamada.
    mov ax,TELA_LARG ; Prepara o nascimento na borda direita, X=320, ajustado em seguida pela sobra do passo.
    add ax,proximoEm ; Soma a sobra negativa de movimento a 320, preservando o espacamento entre nascimentos.
    mov obstX[di],ax ; Grava AX em obstX[di]: coluna de cada obstaculo; admite negativo na saida parcial pela esquerda.
    mov obstPassagem[di],PASS_NOVO ; Grava PASS_NOVO em obstPassagem[di]: progresso da travessia de cada obstaculo, evitando pontos indevidos ou repetidos.
    mov obstImpactos[di],0 ; Grava 0 em obstImpactos[di]: impactos recebidos por cada rocha; a rocha 4 precisa acumular dois.
    cmp proximaRocha,0 ; Compara proximaRocha com 0 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jne obstNascerRocha ; Vai a obstNascerRocha se proximaRocha for diferente de 0.
    mov cx,CRATERA_TIPOS ; Prepara CX=CRATERA_TIPOS; o proximo sorteio usa esse limite exclusivo para escolher um valor valido.
    call Sortear ; Chama Sortear para pseudoaleatorio simples de 16 bits, com resto em faixa finita; CALL guarda onde voltar.
    mov obstTipo[di],ax ; Grava AX em obstTipo[di]: tipo de cada obstaculo, ou OBST_LIVRE para uma vaga disponivel.
    mov cx,CRATERA_GAP_VAR+1 ; Prepara CX=CRATERA_GAP_VAR+1; o proximo sorteio usa esse limite exclusivo para escolher um valor valido.
    call Sortear ; Chama Sortear para pseudoaleatorio simples de 16 bits, com resto em faixa finita; CALL guarda onde voltar.
    add ax,CRATERA_GAP_MIN      ; gap livre 150..230 | Soma 150 ao extra 0..80: o espaco livre entre crateras fica entre 150 e 230 pixels.
    mov bx,ax ; Guarda o gap inteiro para planejar a proxima cratera antes de sortear a rocha intermediaria.
    add bx,CRATERA_LARG        ; distancia entre origens das crateras | Converte gap livre em distancia entre origens: inclui os 14 pixels da primeira cratera.
    sub ax,2*ROCHA_FOLGA+ROCHA_LARG ; Reserva a largura da rocha e as duas folgas de 60 antes de sortear a posicao dela.
    inc ax ; Acrescenta 1 porque Sortear exclui o limite superior, mas queremos incluir a ultima posicao valida.
    mov cx,ax ; Passa ao sorteio a quantidade de posicoes permitidas para a rocha depois de reservar suas folgas.
    call Sortear ; Chama Sortear para pseudoaleatorio simples de 16 bits, com resto em faixa finita; CALL guarda onde voltar.
    add ax,CRATERA_LARG+ROCHA_FOLGA ; Transforma o extra sorteado na distancia da origem da cratera ate a origem da rocha.
    sub bx,ax ; Separa a parte restante da distancia: da rocha planejada ate a proxima cratera.
    mov ateCratera,bx          ; distancia rocha -> proxima cratera | Grava BX em ateCratera: distancia ja planejada entre a rocha e a proxima cratera.
    add proximoEm,ax ; Soma AX a proximoEm, atualizando pixels de terreno que faltam para nascer o proximo obstaculo.
    mov proximaRocha,1 ; Grava 1 em proximaRocha: alterna o nascimento entre cratera e rocha intermediaria.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
obstNascerRocha: ; Rotulo: destino dos saltos dentro de AvancarObstaculos; nao executa acao nem cria uma nova chamada.
    mov cx,ROCHA_TIPOS ; Prepara CX=ROCHA_TIPOS; o proximo sorteio usa esse limite exclusivo para escolher um valor valido.
    call Sortear ; Chama Sortear para pseudoaleatorio simples de 16 bits, com resto em faixa finita; CALL guarda onde voltar.
    add ax,CRATERA_TIPOS ; Converte tipo local de rocha 0..3 em tipo global 3..6, depois dos tres tipos de cratera.
    mov obstTipo[di],ax ; Grava AX em obstTipo[di]: tipo de cada obstaculo, ou OBST_LIVRE para uma vaga disponivel.
    mov ax,ateCratera ; Le ateCratera em AX: distancia ja planejada entre a rocha e a proxima cratera.
    add proximoEm,ax ; Soma AX a proximoEm, atualizando pixels de terreno que faltam para nascer o proximo obstaculo.
    mov proximaRocha,0 ; Grava 0 em proximaRocha: alterna o nascimento entre cratera e rocha intermediaria.
obstAvancoFim: ; Rotulo: destino dos saltos dentro de AvancarObstaculos; nao executa acao nem cria uma nova chamada.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
AvancarObstaculos endp ; Fecha a definicao de AvancarObstaculos no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: detectar intervalo horizontal do jipe sobre um obstaculo.
; Entrada: DI=entrada ativa, jipeX. Saida: CF=1 sobrepoe; BX=tipo*2,
; AX=fim exclusivo do obstaculo. Altera: AX,BX,DX,flags; signed para bordas.
SobrepoeObstaculo proc near ; Por que: E05/D15: testar intervalos horizontais reutiliza a mesma geometria para buracos e rochas.
    mov bx,obstTipo[di] ; Le obstTipo[di] em BX: tipo de cada obstaculo, ou OBST_LIVRE para uma vaga disponivel.
    shl bx,1 ; Multiplica o tipo por 2 porque cada medida das tabelas ocupa uma word (dois bytes).
    mov ax,obstX[di] ; Le obstX[di] em AX: coluna de cada obstaculo; admite negativo na saida parcial pela esquerda.
    add ax,tipoLarg[bx] ; Calcula a borda direita exclusiva do obstaculo: sua origem mais a largura do tipo.
    cmp ax,jipeX ; Compara AX com jipeX sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jle sobrepoeNao ; Com sinal: se o fim do obstaculo nao passa do inicio do jipe, nao ha coluna compartilhada.
    mov dx,jipeX ; Le jipeX em DX: coluna atual da borda esquerda do jipe.
    add dx,JIPE_LARG ; Calcula a borda direita exclusiva do jipe, para conferir a separacao pelo outro lado.
    cmp dx,obstX[di] ; Compara DX com obstX[DI] (entrada selecionada pelo offset em bytes) sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jle sobrepoeNao ; Com sinal: se o fim do jipe nao passa do inicio do obstaculo, tambem nao ha sobreposicao.
    stc ; Devolve CF=1: ha sobreposicao horizontal com o obstaculo.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
sobrepoeNao: ; Rotulo: destino dos saltos dentro de SobrepoeObstaculo; nao executa acao nem cria uma nova chamada.
    clc ; Devolve CF=0: nao ha sobreposicao horizontal.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
SobrepoeObstaculo endp ; Fecha a definicao de SobrepoeObstaculo no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: D15: colisao tem prioridade; depois acompanhar travessias por salto.
; Entrada: posicoes apos movimento (ou pouso). Saida: vida/pontos/marcadores.
; Altera: AX,BX,CX,DX,DI,flags. Sem desenho; no maximo uma morte por chamada.
ConferirObstaculos proc near ; Por que: E05: conferir todas as mortes antes dos pontos impede premiar um salto fatal.
    cmp jipeAtivo,0 ; Compara jipeAtivo com 0 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je conferirObstFim ; Vai a conferirObstFim se jipeAtivo for igual a 0.
    xor di,di ; Zera DI para comecar pela primeira entrada/posicao percorrida nesta rotina.
conferirColisao: ; Rotulo: destino dos saltos dentro de ConferirObstaculos; nao executa acao nem cria uma nova chamada.
    cmp obstTipo[di],OBST_LIVRE ; Compara obstTipo[DI] (entrada selecionada pelo offset em bytes) com OBST_LIVRE sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je conferirColProximo ; Vai a conferirColProximo se obstTipo[DI] (entrada selecionada pelo offset em bytes) for igual a OBST_LIVRE.
    call SobrepoeObstaculo ; Chama SobrepoeObstaculo para detectar intervalo horizontal do jipe sobre um obstaculo; CALL guarda onde voltar.
    jnc conferirColProximo ; Vai a conferirColProximo se nao ha sobreposicao horizontal.
    cmp obstTipo[di],CRATERA_TIPOS ; Tipos 0..2 sao buracos; tipos a partir de 3 sao rochas e precisam do teste vertical.
    jae conferirRocha ; Vai a conferirRocha se obstTipo[DI] (entrada selecionada pelo offset em bytes) for maior ou igual a (sem sinal) CRATERA_TIPOS.
    cmp jipeY,JIPE_Y_CHAO       ; buraco: apoio no chao sobre o intervalo vazio | Cratera mata quando o jipe esta apoiado no chao sobre ela; no ar nao ha apoio no buraco.
    jb conferirColProximo ; Vai a conferirColProximo se jipeY for menor que (sem sinal) JIPE_Y_CHAO.
    jmp conferirMorte ; Continua em conferirMorte sem criar retorno; pula o caminho que nao se aplica a este caso.
conferirRocha: ; Rotulo: destino dos saltos dentro de ConferirObstaculos; nao executa acao nem cria uma nova chamada.
    mov ax,jipeY ; Le jipeY em AX: linha atual do topo do jipe; diminuir Y faz subir.
    add ax,JIPE_ALT ; Calcula a borda inferior do jipe para verificar se ela entra na altura da rocha.
    cmp ax,PISTA_Y-ROCHA_ALT    ; bloco solido [x,x+12) x [183,193) | Compara o fundo do jipe ao topo da rocha; apenas encostar a borda e seguro.
    jbe conferirColProximo     ; tocar a borda sem sobrepor pixels e seguro | Vai a conferirColProximo se AX for menor ou igual a (sem sinal) PISTA_Y-ROCHA_ALT.
conferirMorte: ; Rotulo: destino dos saltos dentro de ConferirObstaculos; nao executa acao nem cria uma nova chamada.
    mov obstPassagem[di],PASS_INVALIDO ; Grava PASS_INVALIDO em obstPassagem[di]: progresso da travessia de cada obstaculo, evitando pontos indevidos ou repetidos.
    call PerderVida ; Chama PerderVida para consumir uma vida e tornar jipe ausente, sem reiniciar a sessao; CALL guarda onde voltar.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
conferirColProximo: ; Rotulo: destino dos saltos dentro de ConferirObstaculos; nao executa acao nem cria uma nova chamada.
    add di,2 ; Avanca DI dois bytes para a proxima entrada word da tabela, sem misturar objetos.
    cmp di,OBST_MAX*2 ; Compara DI com OBST_MAX*2 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jb conferirColisao ; Vai a conferirColisao se DI for menor que (sem sinal) OBST_MAX*2.
    xor di,di ; Zera DI para comecar pela primeira entrada/posicao percorrida nesta rotina.
conferirPassagem: ; Rotulo: destino dos saltos dentro de ConferirObstaculos; nao executa acao nem cria uma nova chamada.
    cmp obstTipo[di],OBST_LIVRE ; Compara obstTipo[DI] (entrada selecionada pelo offset em bytes) com OBST_LIVRE sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je conferirPassProximo ; Vai a conferirPassProximo se obstTipo[DI] (entrada selecionada pelo offset em bytes) for igual a OBST_LIVRE.
    cmp obstPassagem[di],PASS_PONTO ; Compara obstPassagem[DI] (entrada selecionada pelo offset em bytes) com PASS_PONTO sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jae conferirPassProximo ; Ignora objetos ja premiados ou invalidados; ainda foram testados quanto a colisao no primeiro laco.
    call SobrepoeObstaculo ; Chama SobrepoeObstaculo para detectar intervalo horizontal do jipe sobre um obstaculo; CALL guarda onde voltar.
    jc passagemSobre ; Vai a passagemSobre se ha sobreposicao horizontal com o obstaculo.
    cmp ax,jipeX ; Compara AX com jipeX sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jle passagemAtras ; Vai a passagemAtras se AX for menor ou igual a (com sinal) jipeX.
    mov obstPassagem[di],PASS_FRENTE ; inclusive recuo antes de completar | Registra aproximacao real; recuar para antes do objeto tambem reinicia essa prova de travessia.
    jmp conferirPassProximo ; Continua em conferirPassProximo sem criar retorno; pula o caminho que nao se aplica a este caso.
passagemSobre: ; Rotulo: destino dos saltos dentro de ConferirObstaculos; nao executa acao nem cria uma nova chamada.
    cmp estadoSalto,SALTO_CHAO ; Compara estadoSalto com SALTO_CHAO sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je conferirPassProximo ; Vai a conferirPassProximo se estadoSalto for igual a SALTO_CHAO.
    cmp obstPassagem[di],PASS_FRENTE ; Compara obstPassagem[DI] (entrada selecionada pelo offset em bytes) com PASS_FRENTE sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jb conferirPassProximo     ; nao pontuar aparecimento/recriacao sobre objeto | Vai a conferirPassProximo se obstPassagem[DI] (entrada selecionada pelo offset em bytes) for menor que (sem sinal) PASS_FRENTE.
    mov obstPassagem[di],PASS_SOBRE ; Registra que o jipe realmente passou sobre o intervalo do obstaculo enquanto saltava.
    jmp conferirPassProximo ; Continua em conferirPassProximo sem criar retorno; pula o caminho que nao se aplica a este caso.
passagemAtras: ; Rotulo: destino dos saltos dentro de ConferirObstaculos; nao executa acao nem cria uma nova chamada.
    cmp obstPassagem[di],PASS_SOBRE ; Compara obstPassagem[DI] (entrada selecionada pelo offset em bytes) com PASS_SOBRE sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jne passagemPouso ; Vai a passagemPouso se obstPassagem[DI] (entrada selecionada pelo offset em bytes) for diferente de PASS_SOBRE.
    mov obstPassagem[di],PASS_CRUZOU ; Confirma que a travessia horizontal acabou, mas aguarda o pouso antes de dar pontos.
passagemPouso: ; Rotulo: destino dos saltos dentro de ConferirObstaculos; nao executa acao nem cria uma nova chamada.
    cmp obstPassagem[di],PASS_CRUZOU ; Compara obstPassagem[DI] (entrada selecionada pelo offset em bytes) com PASS_CRUZOU sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jne conferirPassProximo ; Vai a conferirPassProximo se obstPassagem[DI] (entrada selecionada pelo offset em bytes) for diferente de PASS_CRUZOU.
    cmp estadoSalto,SALTO_CHAO ; Compara estadoSalto com SALTO_CHAO sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jne conferirPassProximo ; Vai a conferirPassProximo se estadoSalto for diferente de SALTO_CHAO.
    mov obstPassagem[di],PASS_PONTO ; Marca premio ja pago antes de somar, impedindo repetir os 50 pontos em futuras consultas.
    mov ax,PONTOS_OBST ; Copia PONTOS_OBST para AX, preparando esse valor para as instrucoes seguintes sem alterar a origem.
    call SomarPontos ; Chama SomarPontos para somar pontos de obstaculos/naves sem wrap de word; CALL guarda onde voltar.
conferirPassProximo: ; Rotulo: destino dos saltos dentro de ConferirObstaculos; nao executa acao nem cria uma nova chamada.
    add di,2 ; Avanca DI dois bytes para a proxima entrada word da tabela, sem misturar objetos.
    cmp di,OBST_MAX*2 ; Compara DI com OBST_MAX*2 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jb conferirPassagem ; Vai a conferirPassagem se DI for menor que (sem sinal) OBST_MAX*2.
conferirObstFim: ; Rotulo: destino dos saltos dentro de ConferirObstaculos; nao executa acao nem cria uma nova chamada.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
ConferirObstaculos endp ; Fecha a definicao de ConferirObstaculos no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: somar pontos de obstaculos/naves sem wrap de word.
; Entrada: AX=ganho unsigned. Saida: scorePartida <=65535, statusMudou=1.
; Altera: AX,flags. Saturacao explicita protege tambem configuracoes futuras.
SomarPontos proc near ; Por que: E05, reutilizada E08: centralizar a soma impede estouro e atualiza o HUD de todas as fontes de pontos.
    add ax,scorePartida ; Soma ganho ao score; CF registra se o total ultrapassou o limite de 16 bits sem sinal.
    jnc pontosGuardar ; Vai a pontosGuardar se CF=0 (sem transporte/emprestimo ou sinal da rotina).
    mov ax,SCORE_MAX ; Se houve estouro, mantem 65535; a pontuacao nao volta para um numero pequeno.
pontosGuardar: ; Rotulo: destino dos saltos dentro de SomarPontos; nao executa acao nem cria uma nova chamada.
    mov scorePartida,ax ; Grava AX em scorePartida: pontuacao acumulada da sessao; nao reinicia ao perder uma vida.
    mov statusMudou,1 ; Grava 1 em statusMudou: aviso para atualizar score/vidas no HUD depois de um evento.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
SomarPontos endp ; Fecha a definicao de SomarPontos no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: consumir uma vida e tornar jipe ausente, sem reiniciar a sessao.
; Entrada: jipeAtivo/vidas. Saida: uma vida a menos, travessias canceladas.
; Altera: DI,flags/dados. Tempo, score, geracao, rolagem e teclas preservados.
PerderVida proc near ; Por que: E05: tornar o jipe inativo primeiro garante uma vida por evento e preserva a sessao.
    cmp jipeAtivo,0 ; Compara jipeAtivo com 0 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je perderFim ; Vai a perderFim se jipeAtivo for igual a 0.
    mov jipeAtivo,0 ; Inativa antes de outras colisoes: um jipe ja ausente nao perde outra vida no mesmo evento.
    mov pedidoSalto,0 ; Grava 0 em pedidoSalto: pedido de uma nova pressao de cima, consumido uma vez pelo movimento.
    mov pedidoTiro,0 ; Grava 0 em pedidoTiro: guarda um toque curto de Espaco ate a proxima leitura do jogo.
    mov jipeMudou,1 ; Grava 1 em jipeMudou: aviso de que o jipe mudou ou desapareceu e requer novo desenho.
    cmp vidas,0 ; Compara vidas com 0 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je perderFim ; Vai a perderFim se vidas for igual a 0.
    dec vidas ; Reduz vidas em uma unidade: vidas restantes; chegar a zero encerra a partida.
    mov statusMudou,1 ; Grava 1 em statusMudou: aviso para atualizar score/vidas no HUD depois de um evento.
    xor di,di ; Zera DI para comecar pela primeira entrada/posicao percorrida nesta rotina.
perderTravessia: ; Rotulo: destino dos saltos dentro de PerderVida; nao executa acao nem cria uma nova chamada.
    cmp obstPassagem[di],PASS_SOBRE ; Compara obstPassagem[DI] (entrada selecionada pelo offset em bytes) com PASS_SOBRE sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je perderInvalidar ; Vai a perderInvalidar se obstPassagem[DI] (entrada selecionada pelo offset em bytes) for igual a PASS_SOBRE.
    cmp obstPassagem[di],PASS_CRUZOU ; Compara obstPassagem[DI] (entrada selecionada pelo offset em bytes) com PASS_CRUZOU sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jne perderProxima ; Vai a perderProxima se obstPassagem[DI] (entrada selecionada pelo offset em bytes) for diferente de PASS_CRUZOU.
perderInvalidar: ; Rotulo: destino dos saltos dentro de PerderVida; nao executa acao nem cria uma nova chamada.
    mov obstPassagem[di],PASS_INVALIDO ; Cancela salto interrompido pela morte, impedindo receber pontos no reaparecimento.
perderProxima: ; Rotulo: destino dos saltos dentro de PerderVida; nao executa acao nem cria uma nova chamada.
    add di,2 ; Avanca DI dois bytes para a proxima entrada word da tabela, sem misturar objetos.
    cmp di,OBST_MAX*2 ; Compara DI com OBST_MAX*2 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jb perderTravessia ; Vai a perderTravessia se DI for menor que (sem sinal) OBST_MAX*2.
perderFim: ; Rotulo: destino dos saltos dentro de PerderVida; nao executa acao nem cria uma nova chamada.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
PerderVida endp ; Fecha a definicao de PerderVida no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: D14, reaparecer no proximo tick do jipe com x=0 LIVRE.
; Entrada: jipe ausente/vidas/lista. Saida: posicao/fase reiniciadas se seguro.
; Altera: AX,BX,DI,flags. Sem invulnerabilidade/remocao de obstaculo.
; Mantem teclas fisicas: laterais voltam no proximo tick; cima exige soltura.
TentarReporJipe proc near ; Por que: E05/D14, ampliada E08: esperar area inicial livre evita uma segunda morte inevitavel.
    cmp vidas,0 ; Compara vidas com 0 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je reporFim ; Vai a reporFim se vidas for igual a 0.
    call TiroNaReposicao        ; D14: nao recriar dentro de um tiro ainda ativo | Chama TiroNaReposicao para impedir reposicao sobre tiro inimigo, conservando D14 (area livre); CALL guarda onde voltar.
    jc reporFim ; Vai a reporFim se um tiro inimigo ocupa a area inicial.
    xor di,di ; Zera DI para comecar pela primeira entrada/posicao percorrida nesta rotina.
reporConferir: ; Rotulo: destino dos saltos dentro de TentarReporJipe; nao executa acao nem cria uma nova chamada.
    cmp obstTipo[di],OBST_LIVRE ; Compara obstTipo[DI] (entrada selecionada pelo offset em bytes) com OBST_LIVRE sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je reporProximo ; Vai a reporProximo se obstTipo[DI] (entrada selecionada pelo offset em bytes) for igual a OBST_LIVRE.
    cmp obstX[di],JIPE_X_INICIAL+JIPE_LARG ; Compara obstX[DI] (entrada selecionada pelo offset em bytes) com JIPE_X_INICIAL+JIPE_LARG sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jge reporProximo ; Vai a reporProximo se obstX[DI] (entrada selecionada pelo offset em bytes) for maior ou igual a (com sinal) JIPE_X_INICIAL+JIPE_LARG.
    mov bx,obstTipo[di] ; Le obstTipo[di] em BX: tipo de cada obstaculo, ou OBST_LIVRE para uma vaga disponivel.
    shl bx,1 ; Multiplica BX por 2: converte numero do item/tipo em offset de uma tabela de words.
    mov ax,obstX[di] ; Le obstX[di] em AX: coluna de cada obstaculo; admite negativo na saida parcial pela esquerda.
    add ax,tipoLarg[bx] ; Soma tipoLarg[BX] (entrada selecionada pelo offset em bytes) a AX, atualizando o valor usado neste calculo.
    cmp ax,JIPE_X_INICIAL ; Compara AX com JIPE_X_INICIAL sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jg reporFim ; Vai a reporFim se AX for maior que (com sinal) JIPE_X_INICIAL.
reporProximo: ; Rotulo: destino dos saltos dentro de TentarReporJipe; nao executa acao nem cria uma nova chamada.
    add di,2 ; Avanca DI dois bytes para a proxima entrada word da tabela, sem misturar objetos.
    cmp di,OBST_MAX*2 ; Compara DI com OBST_MAX*2 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jb reporConferir ; Vai a reporConferir se DI for menor que (sem sinal) OBST_MAX*2.
    pushf ; Guarda FLAGS na pilha para depois restaurar inclusive o estado anterior das interrupcoes.
    cli ; Suspende IRQs mascaraveis durante a atualizacao compartilhada com o teclado, ate restaurar FLAGS.
    mov jipeX,JIPE_X_INICIAL ; Grava JIPE_X_INICIAL em jipeX: coluna atual da borda esquerda do jipe.
    mov jipeY,JIPE_Y_CHAO ; Grava JIPE_Y_CHAO em jipeY: linha atual do topo do jipe; diminuir Y faz subir.
    mov estadoSalto,SALTO_CHAO ; Grava SALTO_CHAO em estadoSalto: fase do salto: chao, subida, topo ou descida.
    mov pixelsTopo,0 ; Grava 0 em pixelsTopo: distancia de terreno acumulada desde que o jipe chegou ao topo.
    mov pedidoSalto,0 ; Grava 0 em pedidoSalto: pedido de uma nova pressao de cima, consumido uma vez pelo movimento.
    mov jipeAtivo,1 ; Grava 1 em jipeAtivo: indica se o jipe esta vivo/presente; zero impede descontar outra vida no mesmo evento.
    popf ; Recupera FLAGS, inclusive IF; a protecao contra IRQ termina com o estado que existia antes.
    mov jipeMudou,1 ; Grava 1 em jipeMudou: aviso de que o jipe mudou ou desapareceu e requer novo desenho.
reporFim: ; Rotulo: destino dos saltos dentro de TentarReporJipe; nao executa acao nem cria uma nova chamada.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
TentarReporJipe endp ; Fecha a definicao de TentarReporJipe no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: liberar apenas objetos inteiros fora da esquerda, sem dar pontos.
; Entrada: lista e marcadores. Saida: vagas livres; travessia espera pouso.
; Altera: AX,BX,DI,flags. Preserva candidato que saiu da tela durante salto.
RetirarObstaculos proc near ; Por que: E05: liberar vagas fora da tela sem confundir saida com salto bem-sucedido.
    xor di,di ; Zera DI para comecar pela primeira entrada/posicao percorrida nesta rotina.
retirarLoop: ; Rotulo: destino dos saltos dentro de RetirarObstaculos; nao executa acao nem cria uma nova chamada.
    cmp obstTipo[di],OBST_LIVRE ; Compara obstTipo[DI] (entrada selecionada pelo offset em bytes) com OBST_LIVRE sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je retirarProximo ; Vai a retirarProximo se obstTipo[DI] (entrada selecionada pelo offset em bytes) for igual a OBST_LIVRE.
    mov bx,obstTipo[di] ; Le obstTipo[di] em BX: tipo de cada obstaculo, ou OBST_LIVRE para uma vaga disponivel.
    shl bx,1 ; Multiplica BX por 2: converte numero do item/tipo em offset de uma tabela de words.
    mov ax,obstX[di] ; Le obstX[di] em AX: coluna de cada obstaculo; admite negativo na saida parcial pela esquerda.
    add ax,tipoLarg[bx] ; Soma tipoLarg[BX] (entrada selecionada pelo offset em bytes) a AX, atualizando o valor usado neste calculo.
    cmp ax,0 ; Compara AX com 0 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jg retirarProximo ; Vai a retirarProximo se AX for maior que (com sinal) 0.
    cmp obstPassagem[di],PASS_CRUZOU ; Compara obstPassagem[DI] (entrada selecionada pelo offset em bytes) com PASS_CRUZOU sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je retirarProximo ; Nao descarta ainda uma travessia completa: seu premio depende do pouso, mesmo fora da tela.
    mov obstTipo[di],OBST_LIVRE ; Grava OBST_LIVRE em obstTipo[di]: tipo de cada obstaculo, ou OBST_LIVRE para uma vaga disponivel.
retirarProximo: ; Rotulo: destino dos saltos dentro de RetirarObstaculos; nao executa acao nem cria uma nova chamada.
    add di,2 ; Avanca DI dois bytes para a proxima entrada word da tabela, sem misturar objetos.
    cmp di,OBST_MAX*2 ; Compara DI com OBST_MAX*2 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jb retirarLoop ; Vai a retirarLoop se DI for menor que (sem sinal) OBST_MAX*2.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
RetirarObstaculos endp ; Fecha a definicao de RetirarObstaculos no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: compor os sete tipos sobre o cenario limpo, antes do jipe.
; Entrada: tabelas, ES=video. Saida: obstaculos visiveis; sem fundos antigos.
; Altera: AX,BX,CX,DX,SI,DI,flags. Artes E02 intactas.
DesenharObstaculos proc near ; Por que: E05: tabelas por tipo reutilizam um desenhador para as sete aparencias.
    xor di,di ; Zera DI para comecar pela primeira entrada/posicao percorrida nesta rotina.
desenharObstLoop: ; Rotulo: destino dos saltos dentro de DesenharObstaculos; nao executa acao nem cria uma nova chamada.
    cmp obstTipo[di],OBST_LIVRE ; Compara obstTipo[DI] (entrada selecionada pelo offset em bytes) com OBST_LIVRE sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je desenharObstProximo ; Vai a desenharObstProximo se obstTipo[DI] (entrada selecionada pelo offset em bytes) for igual a OBST_LIVRE.
    mov bx,obstTipo[di] ; Le obstTipo[di] em BX: tipo de cada obstaculo, ou OBST_LIVRE para uma vaga disponivel.
    shl bx,1 ; Multiplica BX por 2: converte numero do item/tipo em offset de uma tabela de words.
    mov ax,obstX[di] ; Le obstX[di] em AX: coluna de cada obstaculo; admite negativo na saida parcial pela esquerda.
    mov cx,tipoLarg[bx] ; Le tipoLarg[bx] em CX: largura consultada pelo tipo: 14 para cratera, 12 para rocha.
    mov dx,tipoAlt[bx] ; Le tipoAlt[bx] em DX: altura consultada pelo tipo: 7 para cratera, 10 para rocha.
    mov si,tipoBitmap[bx] ; Le tipoBitmap[bx] em SI: enderecos dos desenhos por tipo; permite uma unica rotina para sete obstaculos.
    mov bx,tipoY[bx] ; Le tipoY[bx] em BX: linha de apoio do tipo: cratera na pista, rocha acima dela.
    call DesenharSpriteRecortado ; Chama DesenharSpriteRecortado para sprite FFh com recorte HORIZONTAL para entrada/saida gradual; CALL guarda onde voltar.
desenharObstProximo: ; Rotulo: destino dos saltos dentro de DesenharObstaculos; nao executa acao nem cria uma nova chamada.
    add di,2 ; Avanca DI dois bytes para a proxima entrada word da tabela, sem misturar objetos.
    cmp di,OBST_MAX*2 ; Compara DI com OBST_MAX*2 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jb desenharObstLoop ; Vai a desenharObstLoop se DI for menor que (sem sinal) OBST_MAX*2.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
DesenharObstaculos endp ; Fecha a definicao de DesenharObstaculos no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: sprite FFh com recorte HORIZONTAL para entrada/saida gradual.
; Entrada: AX=x signed, BX=y, CX=largura, DX=altura, DS:SI=bitmap, ES=video.
; Saida: somente pixels dentro de 0..319; y deve caber inteiro em 0..199.
; Preserva: registradores. Altera: flags (DF=0), video por memoria.
; DesenharSprite original e menu continuam com contrato sem recorte.
DesenharSpriteRecortado proc near ; Por que: E05, reutilizada E06/E08: mostrar so as colunas visiveis permite entrada e saida graduais.
    push ax ; Guarda AX na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    push bx ; Guarda BX na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    push cx ; Guarda CX do chamador; a rotina o usara como contador de pixels e o devolvera ao terminar.
    push dx ; Guarda DX na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    push si ; Guarda SI na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    push di ; Guarda DI na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    push bp ; Guarda BP na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    cld ; DF=0 faz LODSB/MOVSB/STOSB avancarem os enderecos; evita copiar os pixels para tras.
    mov bp,cx                 ; largura original determina o passo da fonte | Guarda a largura completa da arte; recortar a tela nao muda a distancia entre linhas no bitmap original.
    cmp ax,0 ; Compara AX com 0 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jge recorteDireita ; Vai a recorteDireita se AX for maior ou igual a (com sinal) 0.
    neg ax ; Converte X negativo em quantidade de colunas que ficaram fora da borda esquerda.
    cmp ax,cx ; Compara AX com CX sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jae recorteFim ; Vai a recorteFim se AX for maior ou igual a (sem sinal) CX.
    add si,ax                 ; descartar colunas a esquerda na fonte | Pula na arte as colunas invisiveis da esquerda, sem mover os dados originais.
    sub cx,ax ; Reduz a largura desenhada as colunas que ainda podem aparecer.
    xor ax,ax ; O destino visivel passa a comecar em X=0 depois do recorte esquerdo.
recorteDireita: ; Rotulo: destino dos saltos dentro de DesenharSpriteRecortado; nao executa acao nem cria uma nova chamada.
    cmp ax,TELA_LARG ; Compara AX com TELA_LARG sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jge recorteFim ; Vai a recorteFim se AX for maior ou igual a (com sinal) TELA_LARG.
    mov di,TELA_LARG ; Copia TELA_LARG para DI, preparando esse valor para as instrucoes seguintes sem alterar a origem.
    sub di,ax ; Calcula quantas colunas ainda cabem de X ate a borda direita da tela.
    cmp cx,di ; Compara CX com DI sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jbe recorteArea ; Vai a recorteArea se CX for menor ou igual a (sem sinal) DI.
    mov cx,di ; Encurta a largura quando parte da imagem ultrapassa a direita da tela.
recorteArea: ; Rotulo: destino dos saltos dentro de DesenharSpriteRecortado; nao executa acao nem cria uma nova chamada.
    sub bp,cx                 ; salto na fonte depois da parte visivel | Largura original menos largura visivel: bytes a pular na arte ao fim de cada linha.
    push bp ; Guarda o salto da fonte antes de PrepararRetangulo reutilizar BP como altura.
    call PrepararRetangulo ; Chama PrepararRetangulo para validar retangulo inteiro e calcular endereco inicial; CALL guarda onde voltar.
    pop dx                    ; BX=salto no destino, BP=altura, DX=salto fonte | Recupera em DX o salto da fonte guardado em BP; POP nao altera CF da validacao.
    jc recorteFim ; Vai a recorteFim se retangulo invalido; nao acessar video.
recorteLinha: ; Rotulo: destino dos saltos dentro de DesenharSpriteRecortado; nao executa acao nem cria uma nova chamada.
    push cx ; Guarda a largura da linha antes de o laco de pixels consumir CX; POP permite reutiliza-la na linha seguinte.
recortePixel: ; Rotulo: destino dos saltos dentro de DesenharSpriteRecortado; nao executa acao nem cria uma nova chamada.
    lodsb ; Le o proximo byte em DS:SI para AL e avanca SI; cada byte da arte representa um pixel.
    cmp al,TRANSPARENTE ; Compara AL com TRANSPARENTE sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je recorteTransparente ; Vai a recorteTransparente se AL for igual a TRANSPARENTE.
    mov es:[di],al ; Escreve a cor AL no pixel ES:DI; ES aponta para a memoria de video.
recorteTransparente: ; Rotulo: destino dos saltos dentro de DesenharSpriteRecortado; nao executa acao nem cria uma nova chamada.
    inc di ; Avanca uma coluna visivel no video, mesmo se o pixel da arte for transparente.
    loop recortePixel ; Diminui CX e volta a recortePixel se ainda restam itens; zero encerra esta repeticao.
    pop cx ; Recupera a largura original para processar a proxima linha do mesmo retangulo.
    add si,dx ; Pula na arte as colunas recortadas para chegar a proxima linha original.
    add di,bx ; Pula as colunas da tela fora do retangulo: DI chega ao mesmo X na proxima linha de 320 pixels.
    dec bp ; Uma linha terminou; reduz a altura restante para saber se ainda deve processar outra.
    jnz recorteLinha ; Vai a recorteLinha se o resultado/teste anterior for diferente de zero (ZF=0).
recorteFim: ; Rotulo: destino dos saltos dentro de DesenharSpriteRecortado; nao executa acao nem cria uma nova chamada.
    pop bp ; Recupera em BP o valor no topo da pilha, desfazendo o salvamento correspondente.
    pop di ; Recupera em DI o valor no topo da pilha, desfazendo o salvamento correspondente.
    pop si ; Recupera em SI o valor no topo da pilha, desfazendo o salvamento correspondente.
    pop dx ; Recupera em DX o valor no topo da pilha, desfazendo o salvamento correspondente.
    pop cx ; Restaura CX do chamador depois que todas as linhas foram processadas (ou o desenho foi rejeitado).
    pop bx ; Recupera em BX o valor no topo da pilha, desfazendo o salvamento correspondente.
    pop ax ; Recupera em AX o valor no topo da pilha, desfazendo o salvamento correspondente.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
DesenharSpriteRecortado endp ; Fecha a definicao de DesenharSpriteRecortado no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: limpar as tres vagas somente ao iniciar uma nova partida.
; Entrada: nenhuma. Saida: lista vazia, sem alterar a semente compartilhada.
; Altera: DI,flags e dados das naves. Nao chamar na perda de vida.
ReiniciarNaves proc near ; Por que: E06: limpar o grupo na nova sessao sem reiniciar o sorteio compartilhado.
    xor di,di ; Zera DI para comecar pela primeira entrada/posicao percorrida nesta rotina.
reiniciarNaveLoop: ; Rotulo: destino dos saltos dentro de ReiniciarNaves; nao executa acao nem cria uma nova chamada.
    mov naveAtiva[di],0 ; Grava 0 em naveAtiva[di]: atividade real de cada vaga de nave, inclusive fora da borda direita.
    mov naveX[di],0 ; Grava 0 em naveX[di]: coluna de cada nave, inclusive enquanto entra ou sai da tela.
    mov naveY[di],0 ; Grava 0 em naveY[di]: altura sorteada de cada nave, que fica fixa durante o percurso.
    add di,2 ; Avanca DI dois bytes para a proxima entrada word da tabela, sem misturar objetos.
    cmp di,NAVE_MAX*2 ; Compara DI com NAVE_MAX*2 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jb reiniciarNaveLoop ; Vai a reiniciarNaveLoop se DI for menor que (sem sinal) NAVE_MAX*2.
    mov naveQuantidade,0 ; Grava 0 em naveQuantidade: quantidade originalmente sorteada para o grupo, nao o total ainda vivo.
    mov naveTipo,0 ; Grava 0 em naveTipo: aparencia unica compartilhada por todas as naves do grupo.
    mov tickNave,0 ; Grava 0 em tickNave: tick do ultimo movimento do grupo de naves.
    mov navesMudou,1 ; Grava 1 em navesMudou: aviso para recompor o ceu e apagar posicoes antigas de naves.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
ReiniciarNaves endp ; Fecha a definicao de ReiniciarNaves no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: contar atividade real, incluindo naves ainda entrando pela direita.
; Entrada: naveAtiva. Saida: AX=0..NAVE_MAX; preserva demais registradores.
; Altera: AX,flags. Nao usa a quantidade originalmente sorteada como contador.
ContarNavesAtivas proc near ; Por que: E06: o proximo grupo depende das naves ainda ativas, nao da quantidade sorteada antes.
    push di ; Guarda DI na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    xor ax,ax ; Zera AX para iniciar a contagem/calculo sem aproveitar um valor anterior.
    xor di,di ; Zera DI para comecar pela primeira entrada/posicao percorrida nesta rotina.
contarNaveLoop: ; Rotulo: destino dos saltos dentro de ContarNavesAtivas; nao executa acao nem cria uma nova chamada.
    cmp naveAtiva[di],0 ; Compara naveAtiva[DI] (entrada selecionada pelo offset em bytes) com 0 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je contarNaveProxima ; Vai a contarNaveProxima se naveAtiva[DI] (entrada selecionada pelo offset em bytes) for igual a 0.
    inc ax ; Avanca AX em uma unidade.
contarNaveProxima: ; Rotulo: destino dos saltos dentro de ContarNavesAtivas; nao executa acao nem cria uma nova chamada.
    add di,2 ; Avanca DI dois bytes para a proxima entrada word da tabela, sem misturar objetos.
    cmp di,NAVE_MAX*2 ; Compara DI com NAVE_MAX*2 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jb contarNaveLoop ; Vai a contarNaveLoop se DI for menor que (sem sinal) NAVE_MAX*2.
    pop di ; Recupera em DI o valor no topo da pilha, desfazendo o salvamento correspondente.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
ContarNavesAtivas endp ; Fecha a definicao de ContarNavesAtivas no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: gerar um grupo homogeneo, apenas se nenhuma vaga estiver ativa.
; Entrada: lista/semente. Saida: 1..3 naves; tipo 0..2, X/Y sorteados validos.
; Altera: AX,BX,CX,DX,DI,BP,flags e dados. Sem tentativas/rejeicoes.
; D06: faixa de formacao [320,480), largura maxima de meia tela.
; BP guarda a sobra depois de reservar larguras e gaps minimos. Cada sorteio
; consome somente essa sobra; as naves restantes sempre cabem na faixa.
GerarGrupoNaves proc near ; Por que: E06/D06/D07/D09: reservar larguras e gaps antes do sorteio garante que a formacao caiba.
    call ContarNavesAtivas ; Chama ContarNavesAtivas para contar atividade real, incluindo naves ainda entrando pela direita; CALL guarda onde voltar.
    or ax,ax ; Testa se AX vale zero sem mudar seu valor; ZF permite decidir se ha algo a processar.
    jnz gerarNavesFim ; Vai a gerarNavesFim se o resultado/teste anterior for diferente de zero (ZF=0).
    mov cx,NAVE_MAX ; Prepara CX=NAVE_MAX; o proximo sorteio usa esse limite exclusivo para escolher um valor valido.
    call Sortear ; Chama Sortear para pseudoaleatorio simples de 16 bits, com resto em faixa finita; CALL guarda onde voltar.
    inc ax ; Sortear deu 0..2; somar 1 transforma isso no grupo permitido de 1..3 naves.
    mov naveQuantidade,ax ; Grava AX em naveQuantidade: quantidade originalmente sorteada para o grupo, nao o total ainda vivo.
    mov bx,NAVE_LARG+NAVE_GAP_MIN ; Reserva 14 pixels de nave mais 30 de gap por elemento; a conta seguinte devolve o gap excedente.
    mul bx ; Multiplica AX por BX sem sinal; DX:AX recebe o produto, com DX na metade alta.
    mov bp,NAVE_FAIXA+NAVE_GAP_MIN ; Prepara 160+30: nao deve haver gap obrigatorio depois da ultima nave.
    sub bp,ax                 ; sobra = 160 - quantidade*14 - (quantidade-1)*30 | Reserva primeiro todas as larguras e gaps; so o espaco restante pode ser sorteado.
    mov cx,NAVE_TIPOS ; Prepara CX=NAVE_TIPOS; o proximo sorteio usa esse limite exclusivo para escolher um valor valido.
    call Sortear ; Chama Sortear para pseudoaleatorio simples de 16 bits, com resto em faixa finita; CALL guarda onde voltar.
    mov naveTipo,ax ; Grava AX em naveTipo: aparencia unica compartilhada por todas as naves do grupo.
    mov cx,NAVE_ENTRADA_VAR+1 ; Prepara CX=NAVE_ENTRADA_VAR+1; o proximo sorteio usa esse limite exclusivo para escolher um valor valido.
    call Sortear ; Chama Sortear para pseudoaleatorio simples de 16 bits, com resto em faixa finita; CALL guarda onde voltar.
    sub bp,ax ; Desconta da sobra o deslocamento inicial para a formacao nao exceder os 160 pixels.
    add ax,NAVE_X_INICIAL ; Transforma o deslocamento 0..15 em origem externa X=320..335 para entrada gradual.
    mov bx,ax                 ; primeira origem 320..335 | BX guarda a origem X da nave atual; Sortear preserva BX ao escolher as alturas e gaps.
    xor di,di ; Zera DI para comecar pela primeira entrada/posicao percorrida nesta rotina.
gerarNaveLoop: ; Rotulo: destino dos saltos dentro de GerarGrupoNaves; nao executa acao nem cria uma nova chamada.
    mov naveX[di],bx ; Grava BX em naveX[di]: coluna de cada nave, inclusive enquanto entra ou sai da tela.
    mov naveAtiva[di],1 ; Grava 1 em naveAtiva[di]: atividade real de cada vaga de nave, inclusive fora da borda direita.
    mov esperaNave[di],CADENCIA_NAVE ; Grava CADENCIA_NAVE em esperaNave[di]: contador de recarga individual de cada nave.
    mov cx,NAVE_Y_MAX-NAVE_Y_MIN+1 ; Prepara CX=NAVE_Y_MAX-NAVE_Y_MIN+1; o proximo sorteio usa esse limite exclusivo para escolher um valor valido.
    call Sortear ; Chama Sortear para pseudoaleatorio simples de 16 bits, com resto em faixa finita; CALL guarda onde voltar.
    add ax,NAVE_Y_MIN ; Transforma o resultado 0..71 em Y=15..86, mantendo o sprite inteiro entre HUD e terreno.
    mov naveY[di],ax ; Grava AX em naveY[di]: altura sorteada de cada nave, que fica fixa durante o percurso.
    add di,2 ; Avanca DI dois bytes para a proxima entrada word da tabela, sem misturar objetos.
    mov ax,naveQuantidade ; Le naveQuantidade em AX: quantidade originalmente sorteada para o grupo, nao o total ainda vivo.
    shl ax,1 ; Multiplica AX por 2: converte numero do item/tipo em offset de uma tabela de words.
    cmp di,ax ; Compara DI com AX sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jae gerarNavesProntas ; Vai a gerarNavesProntas se DI for maior ou igual a (sem sinal) AX.
    mov cx,bp ; Usa somente a sobra da faixa como limite para o proximo gap adicional.
    inc cx ; Inclui a propria sobra como resultado permitido; Sortear retorna valores menores que CX.
    call Sortear              ; extra no gap: 0..sobra, inclusive | Chama Sortear para pseudoaleatorio simples de 16 bits, com resto em faixa finita; CALL guarda onde voltar.
    sub bp,ax ; Consome apenas o extra sorteado; o espaco minimo das naves restantes ja esta reservado.
    add bx,NAVE_LARG+NAVE_GAP_MIN ; Avanca X pela largura da nave e pelo gap minimo de 30 pixels livres.
    add bx,ax ; Soma o extra sorteado ao gap, sem consumir o espaco minimo reservado para as naves restantes.
    jmp gerarNaveLoop ; Continua em gerarNaveLoop sem criar retorno; pula o caminho que nao se aplica a este caso.
gerarNavesProntas: ; Rotulo: destino dos saltos dentro de GerarGrupoNaves; nao executa acao nem cria uma nova chamada.
    mov navesMudou,1 ; Grava 1 em navesMudou: aviso para recompor o ceu e apagar posicoes antigas de naves.
gerarNavesFim: ; Rotulo: destino dos saltos dentro de GerarGrupoNaves; nao executa acao nem cria uma nova chamada.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
GerarGrupoNaves endp ; Fecha a definicao de GerarGrupoNaves no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: remover uma nave uma unica vez (saida ou impacto de tiro).
; Entrada: DI=offset de vaga (0,2,4). Saida: CF=1 se removeu, CF=0 se nao.
; Preserva: todos os registradores. Altera: flags, atividade e navesMudou.
; Nao pontua. ConferirUmDisparo soma 100 somente se CF=1 por impacto.
RemoverNave proc near ; Por que: E06, usada E08: avisar se houve remocao real permite pontuar o impacto uma unica vez.
    cmp di,NAVE_MAX*2 ; Compara DI com NAVE_MAX*2 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jae removerNaveNao ; Vai a removerNaveNao se DI for maior ou igual a (sem sinal) NAVE_MAX*2.
    test di,1 ; Verifica se o indice e impar; indices word validos sao 0, 2 e 4.
    jnz removerNaveNao ; Vai a removerNaveNao se o resultado/teste anterior for diferente de zero (ZF=0).
    cmp naveAtiva[di],0 ; Compara naveAtiva[DI] (entrada selecionada pelo offset em bytes) com 0 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je removerNaveNao ; Vai a removerNaveNao se naveAtiva[DI] (entrada selecionada pelo offset em bytes) for igual a 0.
    mov naveAtiva[di],0 ; Grava 0 em naveAtiva[di]: atividade real de cada vaga de nave, inclusive fora da borda direita.
    mov navesMudou,1 ; Grava 1 em navesMudou: aviso para recompor o ceu e apagar posicoes antigas de naves.
    stc ; Devolve CF=1: esta chamada removeu uma nave ativa.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
removerNaveNao: ; Rotulo: destino dos saltos dentro de RemoverNave; nao executa acao nem cria uma nova chamada.
    clc ; Devolve CF=0: nenhuma nave foi removida.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
RemoverNave endp ; Fecha a definicao de RemoverNave no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: executar um passo de todas as naves ou gerar se grupo ja vazio.
; Entrada: lista. Saida: X -= PASSO_NAVE; Y fixo; remover quando X+14<=0.
; Altera: AX,BX,CX,DX,DI,BP,flags e dados; nao altera score/vidas/relogio.
; A ultima saida permite nova geracao na proxima cadencia, nunca antes.
AtualizarNaves proc near ; Por que: E06: velocidade igual conserva espacamentos; novo grupo espera a ultima nave sair.
    call ContarNavesAtivas ; Chama ContarNavesAtivas para contar atividade real, incluindo naves ainda entrando pela direita; CALL guarda onde voltar.
    or ax,ax ; Testa se AX vale zero sem mudar seu valor; ZF permite decidir se ha algo a processar.
    jnz moverNaves ; Vai a moverNaves se o resultado/teste anterior for diferente de zero (ZF=0).
    call GerarGrupoNaves ; Chama GerarGrupoNaves para gerar um grupo homogeneo, apenas se nenhuma vaga estiver ativa; CALL guarda onde voltar.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
moverNaves: ; Rotulo: destino dos saltos dentro de AtualizarNaves; nao executa acao nem cria uma nova chamada.
    xor di,di ; Zera DI para comecar pela primeira entrada/posicao percorrida nesta rotina.
moverNaveLoop: ; Rotulo: destino dos saltos dentro de AtualizarNaves; nao executa acao nem cria uma nova chamada.
    cmp naveAtiva[di],0 ; Compara naveAtiva[DI] (entrada selecionada pelo offset em bytes) com 0 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je moverNaveProxima ; Vai a moverNaveProxima se naveAtiva[DI] (entrada selecionada pelo offset em bytes) for igual a 0.
    sub naveX[di],PASSO_NAVE ; Subtrai PASSO_NAVE de naveX[DI] (entrada selecionada pelo offset em bytes), obtendo coluna de cada nave, inclusive enquanto entra ou sai da tela.
    mov navesMudou,1 ; Grava 1 em navesMudou: aviso para recompor o ceu e apagar posicoes antigas de naves.
    cmp naveX[di],-NAVE_LARG ; Compara naveX[DI] (entrada selecionada pelo offset em bytes) com -NAVE_LARG sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jg moverNaveProxima ; Vai a moverNaveProxima se naveX[DI] (entrada selecionada pelo offset em bytes) for maior que (com sinal) -NAVE_LARG.
    call RemoverNave ; Chama RemoverNave para remover uma nave uma unica vez (saida ou impacto de tiro); CALL guarda onde voltar.
moverNaveProxima: ; Rotulo: destino dos saltos dentro de AtualizarNaves; nao executa acao nem cria uma nova chamada.
    add di,2 ; Avanca DI dois bytes para a proxima entrada word da tabela, sem misturar objetos.
    cmp di,NAVE_MAX*2 ; Compara DI com NAVE_MAX*2 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jb moverNaveLoop ; Vai a moverNaveLoop se DI for menor que (sem sinal) NAVE_MAX*2.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
AtualizarNaves endp ; Fecha a definicao de AtualizarNaves no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: manter cadencia independente usando a mesma amostra BIOS do laco.
; Entrada: DX=tick atual (word). Saida: passo apenas apos TICKS_NAVE.
; Altera: AX,BX,CX,DI,BP,flags e dados. Preserva DX para as outras cadencias.
AtualizarCadenciaNaves proc near ; Por que: E06: manter relogio proprio impede que o ritmo das naves dependa do terreno/jipe.
    push dx ; Guarda DX na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    mov ax,dx ; Copia o tick atual para AX; DX conserva o instante completo usado como nova referencia.
    sub ax,tickNave ; Calcula quantos ticks passaram desde tickNave, usando aritmetica de 16 bits.
    cmp ax,TICKS_NAVE ; So permite mais um passo quando o intervalo configurado em TICKS_NAVE foi atingido.
    jb cadenciaNaveFim ; Vai a cadenciaNaveFim se AX for menor que (sem sinal) TICKS_NAVE.
    mov tickNave,dx ; Grava DX em tickNave: tick do ultimo movimento do grupo de naves.
    call AtualizarNaves ; Chama AtualizarNaves para executar um passo de todas as naves ou gerar se grupo ja vazio; CALL guarda onde voltar.
cadenciaNaveFim: ; Rotulo: destino dos saltos dentro de AtualizarCadenciaNaves; nao executa acao nem cria uma nova chamada.
    pop dx ; Recupera em DX o valor no topo da pilha, desfazendo o salvamento correspondente.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
AtualizarCadenciaNaves endp ; Fecha a definicao de AtualizarCadenciaNaves no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: recompor o ceu preto atual e desenhar somente as naves ativas.
; Entrada: lista/X signed/Y inteiro em 15..86, ES=video. Saida: ceu 15..99.
; Altera: AX,BX,CX,DX,SI,DI,flags (DF=0), video; consome navesMudou.
; Sem captura antiga: fundo uniforme da E03, fora de HUD/relevo/jipe.
; DesenharQuadroPartida recompoe tiros depois deste ceu e do terreno.
DesenharNaves proc near ; Por que: E06: recompor o ceu uniforme apaga as naves antigas sem capturas de fundo desatualizadas.
    cld ; DF=0 faz LODSB/MOVSB/STOSB avancarem os enderecos; evita copiar os pixels para tras.
    mov di,HUD_ALT*TELA_LARG ; Comeca a limpeza em Y=15, depois do HUD, para nao apagar score, vidas e tempo.
    mov cx,(CENARIO_Y-HUD_ALT)*TELA_LARG ; Limpa so as 85 linhas do ceu, de 15 a 99; terreno e HUD ficam preservados.
    mov al,COR_FUNDO ; AL recebe COR_FUNDO, cor que sera repetida no preenchimento de pixels.
    rep stosb ; Repete a cor AL em CX bytes de ES:DI; avanca o destino e termina com CX=0.
    xor di,di ; Zera DI para comecar pela primeira entrada/posicao percorrida nesta rotina.
desenharNaveLoop: ; Rotulo: destino dos saltos dentro de DesenharNaves; nao executa acao nem cria uma nova chamada.
    cmp naveAtiva[di],0 ; Compara naveAtiva[DI] (entrada selecionada pelo offset em bytes) com 0 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je desenharNaveProxima ; Vai a desenharNaveProxima se naveAtiva[DI] (entrada selecionada pelo offset em bytes) for igual a 0.
    mov bx,naveTipo ; Le naveTipo em BX: aparencia unica compartilhada por todas as naves do grupo.
    shl bx,1 ; Multiplica BX por 2: converte numero do item/tipo em offset de uma tabela de words.
    mov si,naveBitmap[bx] ; Le naveBitmap[bx] em SI: enderecos dos tres desenhos de nave, escolhidos pelo tipo do grupo.
    mov ax,naveX[di] ; Le naveX[di] em AX: coluna de cada nave, inclusive enquanto entra ou sai da tela.
    mov bx,naveY[di] ; Le naveY[di] em BX: altura sorteada de cada nave, que fica fixa durante o percurso.
    mov cx,NAVE_LARG ; CX recebe NAVE_LARG: quantidade de pixels/caracteres a processar nesta chamada.
    mov dx,NAVE_ALT ; DX recebe NAVE_ALT, altura em pixels que o desenhador precisa percorrer.
    call DesenharSpriteRecortado ; Chama DesenharSpriteRecortado para sprite FFh com recorte HORIZONTAL para entrada/saida gradual; CALL guarda onde voltar.
desenharNaveProxima: ; Rotulo: destino dos saltos dentro de DesenharNaves; nao executa acao nem cria uma nova chamada.
    add di,2 ; Avanca DI dois bytes para a proxima entrada word da tabela, sem misturar objetos.
    cmp di,NAVE_MAX*2 ; Compara DI com NAVE_MAX*2 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jb desenharNaveLoop ; Vai a desenharNaveLoop se DI for menor que (sem sinal) NAVE_MAX*2.
    mov navesMudou,0 ; Grava 0 em navesMudou: aviso para recompor o ceu e apagar posicoes antigas de naves.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
DesenharNaves endp ; Fecha a definicao de DesenharNaves no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: limpar todos os projeteis somente na nova partida.
; Entrada: nenhuma. Saida: listas/cadencias vazias, sem alterar sorteio.
; Altera: DI,flags/dados. Morte e troca de grupo NAO chamam esta rotina.
ReiniciarDisparos proc near ; Por que: E08: tiros pertencem a sessao e nao somem quando a nave morre ou o grupo muda.
    xor di,di ; Zera DI para comecar pela primeira entrada/posicao percorrida nesta rotina.
reiniciarTiroLoop: ; Rotulo: destino dos saltos dentro de ReiniciarDisparos; nao executa acao nem cria uma nova chamada.
    mov tiroAtivo[di],0 ; Grava 0 em tiroAtivo[di]: atividade de cada projetil; a vaga pode ser reutilizada depois de zero.
    mov tiroX[di],0 ; Grava 0 em tiroX[di]: coluna de cada tiro, independente da posicao posterior de quem disparou.
    mov tiroY[di],0 ; Grava 0 em tiroY[di]: linha de cada tiro; sobe ou desce conforme sua faixa na lista.
    mov tiroDistancia[di],0 ; Grava 0 em tiroDistancia[di]: percurso acumulado do tiro frontal para limita-lo a 50 pixels.
    add di,2 ; Avanca DI dois bytes para a proxima entrada word da tabela, sem misturar objetos.
    cmp di,TIRO_MAX*2 ; Compara DI com TIRO_MAX*2 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jb reiniciarTiroLoop ; Vai a reiniciarTiroLoop se DI for menor que (sem sinal) TIRO_MAX*2.
    xor di,di ; Zera DI para comecar pela primeira entrada/posicao percorrida nesta rotina.
reiniciarEsperaNave: ; Rotulo: destino dos saltos dentro de ReiniciarDisparos; nao executa acao nem cria uma nova chamada.
    mov esperaNave[di],CADENCIA_NAVE ; Grava CADENCIA_NAVE em esperaNave[di]: contador de recarga individual de cada nave.
    add di,2 ; Avanca DI dois bytes para a proxima entrada word da tabela, sem misturar objetos.
    cmp di,NAVE_MAX*2 ; Compara DI com NAVE_MAX*2 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jb reiniciarEsperaNave ; Vai a reiniciarEsperaNave se DI for menor que (sem sinal) NAVE_MAX*2.
    mov esperaJipe,0 ; Grava 0 em esperaJipe: contador que impede disparar um novo par antes da cadencia escolhida.
    mov tickTiro,0 ; Grava 0 em tickTiro: tick da ultima atualizacao dos projeteis.
    mov tirosMudou,0 ; Grava 0 em tirosMudou: aviso para apagar posicoes antigas e desenhar os tiros atuais.
    mov pedidoTiro,0 ; Grava 0 em pedidoTiro: guarda um toque curto de Espaco ate a proxima leitura do jogo.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
ReiniciarDisparos endp ; Fecha a definicao de ReiniciarDisparos no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: procurar uma vaga livre numa faixa sem sobrescrever tiros ativos.
; Entrada: AX=offset inicial, BX=fim exclusivo (pares). Saida: DI=vaga,
; CF=1 se encontrou, CF=0 se lotado. Preserva os demais registradores.
ProcurarVagaTiro proc near ; Por que: E08: encontrar espaco antes de criar evita sobrescrever um projetil ainda ativo.
    mov di,ax ; Copia AX para DI, preparando esse valor para as instrucoes seguintes sem alterar a origem.
vagaTiroLoop: ; Rotulo: destino dos saltos dentro de ProcurarVagaTiro; nao executa acao nem cria uma nova chamada.
    cmp tiroAtivo[di],0 ; Compara tiroAtivo[DI] (entrada selecionada pelo offset em bytes) com 0 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je vagaTiroAchou ; Vai a vagaTiroAchou se tiroAtivo[DI] (entrada selecionada pelo offset em bytes) for igual a 0.
    add di,2 ; Avanca DI dois bytes para a proxima entrada word da tabela, sem misturar objetos.
    cmp di,bx ; Compara DI com BX sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jb vagaTiroLoop ; Vai a vagaTiroLoop se DI for menor que (sem sinal) BX.
    clc ; Devolve CF=0: a faixa de tiros esta cheia.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
vagaTiroAchou: ; Rotulo: destino dos saltos dentro de ProcurarVagaTiro; nao executa acao nem cria uma nova chamada.
    stc ; Devolve CF=1: encontrou uma vaga de tiro livre.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
ProcurarVagaTiro endp ; Fecha a definicao de ProcurarVagaTiro no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: criar o par superior/frontal na posicao atual, inclusive no salto.
; Entrada: jipeAtivo/X/Y, listas. Saida: ambos nascem ou nenhum (CF=1/0).
; Altera: AX,BX,DI,BP,flags/dados. SI preservado. Nao altera tiros existentes.
DispararJipe proc near ; Por que: E08: reservar as duas vagas antes de gravar garante dois canhoes simultaneos ou nenhum.
    cmp jipeAtivo,0 ; Compara jipeAtivo com 0 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je dispararJipeNao ; Vai a dispararJipeNao se jipeAtivo for igual a 0.
    xor ax,ax ; A procura do tiro superior comeca no offset zero da lista.
    mov bx,TIRO_FRE_INICIO ; Fim exclusivo da faixa superior: a procura nao pode invadir as vagas do canhao frontal.
    call ProcurarVagaTiro ; Chama ProcurarVagaTiro para procurar uma vaga livre numa faixa sem sobrescrever tiros ativos; CALL guarda onde voltar.
    jnc dispararJipeNao ; Vai a dispararJipeNao se a faixa de tiros esta cheia.
    mov bp,di ; Guarda a vaga superior, mas ainda nao cria tiro: falta garantir a vaga frontal.
    mov ax,TIRO_FRE_INICIO ; Comeca a segunda procura na faixa reservada ao tiro frontal.
    mov bx,TIRO_INI_INICIO ; Fim exclusivo da faixa frontal; as vagas inimigas nao podem ser usadas pelo jipe.
    call ProcurarVagaTiro ; Chama ProcurarVagaTiro para procurar uma vaga livre numa faixa sem sobrescrever tiros ativos; CALL guarda onde voltar.
    jnc dispararJipeNao ; Vai a dispararJipeNao se a faixa de tiros esta cheia.
    mov ax,jipeX ; Le jipeX em AX: coluna atual da borda esquerda do jipe.
    add ax,CANHAO_FRE_X ; Coloca a origem do tiro logo a direita do jipe, acompanhando sua posicao atual.
    mov tiroX[di],ax ; Grava AX em tiroX[di]: coluna de cada tiro, independente da posicao posterior de quem disparou.
    mov ax,jipeY ; Le jipeY em AX: linha atual do topo do jipe; diminuir Y faz subir.
    add ax,CANHAO_FRE_Y ; Alinha a altura do tiro frontal ao canhao, inclusive se o jipe estiver saltando.
    mov tiroY[di],ax ; Grava AX em tiroY[di]: linha de cada tiro; sobe ou desce conforme sua faixa na lista.
    mov tiroDistancia[di],0 ; Grava 0 em tiroDistancia[di]: percurso acumulado do tiro frontal para limita-lo a 50 pixels.
    mov tiroAtivo[di],1 ; Grava 1 em tiroAtivo[di]: atividade de cada projetil; a vaga pode ser reutilizada depois de zero.
    mov di,bp                  ; BP sem uso como endereco: manter DS, nao SS | Recupera o indice em DI; enderecar com BP usaria SS por padrao, nao DS das tabelas.
    mov ax,jipeX ; Le jipeX em AX: coluna atual da borda esquerda do jipe.
    add ax,CANHAO_SUP_X ; Alinha o tiro vertical com a coluna do canhao superior dentro do jipe.
    mov tiroX[di],ax ; Grava AX em tiroX[di]: coluna de cada tiro, independente da posicao posterior de quem disparou.
    mov ax,jipeY ; Le jipeY em AX: linha atual do topo do jipe; diminuir Y faz subir.
    sub ax,TIRO_SUP_ALT ; Coloca o tiro inteiro acima do jipe; sua borda inferior nasce junto ao topo do veiculo.
    mov tiroY[di],ax ; Grava AX em tiroY[di]: linha de cada tiro; sobe ou desce conforme sua faixa na lista.
    mov tiroDistancia[di],0 ; Grava 0 em tiroDistancia[di]: percurso acumulado do tiro frontal para limita-lo a 50 pixels.
    mov tiroAtivo[di],1 ; Grava 1 em tiroAtivo[di]: atividade de cada projetil; a vaga pode ser reutilizada depois de zero.
    mov tirosMudou,1 ; Grava 1 em tirosMudou: aviso para apagar posicoes antigas e desenhar os tiros atuais.
    stc ; Devolve CF=1: os dois tiros foram criados.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
dispararJipeNao: ; Rotulo: destino dos saltos dentro de DispararJipe; nao executa acao nem cria uma nova chamada.
    clc ; Devolve CF=0: nao foi possivel criar o par.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
DispararJipe endp ; Fecha a definicao de DispararJipe no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: emitir continuamente de cada nave com canhao dentro da tela.
; Entrada: listas/esperaNave; uma chamada por atualizacao dos tiros.
; Saida: brancos independentes das naves; cheio aguarda vaga sem substituir.
; Altera: AX,BX,CX,DX,DI,BP,flags/dados. Preserva SI.
DispararNaves proc near ; Por que: E08: recarga por nave produz emissao continua e cada tiro segue independente dela.
    push si ; Guarda SI na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    xor si,si ; Zera SI para comecar pela primeira entrada/posicao percorrida nesta rotina.
dispararNaveLoop: ; Rotulo: destino dos saltos dentro de DispararNaves; nao executa acao nem cria uma nova chamada.
    cmp naveAtiva[si],0 ; Compara naveAtiva[SI] (entrada selecionada pelo offset em bytes) com 0 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je dispararNaveProxima ; Vai a dispararNaveProxima se naveAtiva[SI] (entrada selecionada pelo offset em bytes) for igual a 0.
    mov dx,naveX[si] ; Le naveX[si] em DX: coluna de cada nave, inclusive enquanto entra ou sai da tela.
    add dx,CANHAO_NAVE_X ; Calcula a coluna do canhao, que precisa caber na tela mesmo com a nave parcialmente visivel.
    cmp dx,0 ; Compara DX com 0 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jl dispararNaveProxima ; Vai a dispararNaveProxima se DX for menor que (com sinal) 0.
    cmp dx,TELA_LARG-TIRO_INI_LARG ; Impede criar um tiro cuja largura ultrapasse a borda direita.
    jg dispararNaveProxima ; Vai a dispararNaveProxima se DX for maior que (com sinal) TELA_LARG-TIRO_INI_LARG.
    cmp esperaNave[si],0 ; Compara esperaNave[SI] (entrada selecionada pelo offset em bytes) com 0 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je dispararNaveVaga ; Vai a dispararNaveVaga se esperaNave[SI] (entrada selecionada pelo offset em bytes) for igual a 0.
    dec esperaNave[si] ; Consome uma atualizacao de recarga desta nave visivel, sem afetar as outras.
    jnz dispararNaveProxima ; Vai a dispararNaveProxima se o resultado/teste anterior for diferente de zero (ZF=0).
dispararNaveVaga: ; Rotulo: destino dos saltos dentro de DispararNaves; nao executa acao nem cria uma nova chamada.
    mov ax,TIRO_INI_INICIO ; Copia TIRO_INI_INICIO para AX, preparando esse valor para as instrucoes seguintes sem alterar a origem.
    mov bx,TIRO_MAX*2 ; Copia TIRO_MAX*2 para BX, preparando esse valor para as instrucoes seguintes sem alterar a origem.
    call ProcurarVagaTiro ; Chama ProcurarVagaTiro para procurar uma vaga livre numa faixa sem sobrescrever tiros ativos; CALL guarda onde voltar.
    jnc dispararNaveProxima ; Vai a dispararNaveProxima se a faixa de tiros esta cheia.
    mov tiroX[di],dx ; Grava DX em tiroX[di]: coluna de cada tiro, independente da posicao posterior de quem disparou.
    mov ax,naveY[si] ; Le naveY[si] em AX: altura sorteada de cada nave, que fica fixa durante o percurso.
    add ax,NAVE_ALT ; O tiro nasce logo abaixo da nave; depois segue sozinho, mesmo que ela seja destruida.
    mov tiroY[di],ax ; Grava AX em tiroY[di]: linha de cada tiro; sobe ou desce conforme sua faixa na lista.
    mov tiroDistancia[di],0 ; Grava 0 em tiroDistancia[di]: percurso acumulado do tiro frontal para limita-lo a 50 pixels.
    mov tiroAtivo[di],1 ; Grava 1 em tiroAtivo[di]: atividade de cada projetil; a vaga pode ser reutilizada depois de zero.
    mov tirosMudou,1 ; Grava 1 em tirosMudou: aviso para apagar posicoes antigas e desenhar os tiros atuais.
    mov esperaNave[si],CADENCIA_NAVE ; Grava CADENCIA_NAVE em esperaNave[si]: contador de recarga individual de cada nave.
dispararNaveProxima: ; Rotulo: destino dos saltos dentro de DispararNaves; nao executa acao nem cria uma nova chamada.
    add si,2 ; Avanca SI dois bytes para a proxima entrada word da tabela, sem misturar objetos.
    cmp si,NAVE_MAX*2 ; Compara SI com NAVE_MAX*2 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jb dispararNaveLoop ; Vai a dispararNaveLoop se SI for menor que (sem sinal) NAVE_MAX*2.
    pop si ; Recupera em SI o valor no topo da pilha, desfazendo o salvamento correspondente.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
DispararNaves endp ; Fecha a definicao de DispararNaves no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: selecionar medidas/bitmap pela faixa fixa do tiro.
; Entrada: SI=offset par valido. Saida: BX=indice 0/2/4 nas tabelas.
; Preserva: demais registradores. Altera: BX,flags.
TipoDoTiro proc near ; Por que: E08: a faixa do indice identifica o tipo sem guardar outro campo por projetil.
    xor bx,bx ; Comeca com tipo superior, indice 0 nas tabelas de medidas e bitmaps.
    cmp si,TIRO_FRE_INICIO ; Compara SI com TIRO_FRE_INICIO sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jb tipoTiroFim ; Vai a tipoTiroFim se SI for menor que (sem sinal) TIRO_FRE_INICIO.
    mov bx,2 ; Escolhe o segundo tipo (frontal); cada entrada de tabela tem dois bytes.
    cmp si,TIRO_INI_INICIO ; Compara SI com TIRO_INI_INICIO sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jb tipoTiroFim ; Vai a tipoTiroFim se SI for menor que (sem sinal) TIRO_INI_INICIO.
    mov bx,4 ; Escolhe o terceiro tipo (inimigo), no offset 4 das tabelas.
tipoTiroFim: ; Rotulo: destino dos saltos dentro de TipoDoTiro; nao executa acao nem cria uma nova chamada.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
TipoDoTiro endp ; Fecha a definicao de TipoDoTiro no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: sobrepor retangulos inteiros [inicio,fim), com X signed.
; Entrada: SI=tiro; AX/BX=origem alvo, CX/DX=largura/altura do alvo.
; Saida: CF=1 sobreposicao, CF=0 fora/bordas. Preserva registradores.
SobrepoeTiroAlvo proc near ; Por que: E08: uma comparacao de retangulos serve para nave, rocha e jipe.
    push ax ; Guarda AX na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    push bx ; Guarda BX na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    push cx ; Guarda CX na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    push dx ; Guarda DX na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    push di ; Guarda DI na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    push bp ; Guarda BP na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    mov di,bx                 ; Y alvo | Preserva Y do alvo em DI antes de BX virar indice do tipo do tiro.
    mov bp,ax ; Copia AX para BP, preparando esse valor para as instrucoes seguintes sem alterar a origem.
    add bp,cx                 ; fim X alvo | Calcula a borda direita exclusiva do alvo: X+largura.
    cmp tiroX[si],bp ; Compara tiroX[SI] (entrada selecionada pelo offset em bytes) com BP sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jge tiroAlvoNao ; Vai a tiroAlvoNao se tiroX[SI] (entrada selecionada pelo offset em bytes) for maior ou igual a (com sinal) BP.
    call TipoDoTiro ; Chama TipoDoTiro para selecionar medidas/bitmap pela faixa fixa do tiro; CALL guarda onde voltar.
    mov bp,tiroX[si] ; Le tiroX[si] em BP: coluna de cada tiro, independente da posicao posterior de quem disparou.
    add bp,tiroLarg[bx] ; Calcula a borda direita exclusiva do tiro com a largura correspondente ao seu tipo.
    cmp bp,ax ; Compara BP com AX sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jle tiroAlvoNao ; Vai a tiroAlvoNao se BP for menor ou igual a (com sinal) AX.
    mov bp,di ; Copia DI para BP, preparando esse valor para as instrucoes seguintes sem alterar a origem.
    add bp,dx ; Calcula a borda inferior exclusiva do alvo: Y+altura.
    cmp tiroY[si],bp ; Compara tiroY[SI] (entrada selecionada pelo offset em bytes) com BP sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jge tiroAlvoNao ; Vai a tiroAlvoNao se tiroY[SI] (entrada selecionada pelo offset em bytes) for maior ou igual a (com sinal) BP.
    mov bp,tiroY[si] ; Le tiroY[si] em BP: linha de cada tiro; sobe ou desce conforme sua faixa na lista.
    add bp,tiroAlt[bx] ; Calcula a borda inferior exclusiva do tiro; quatro separacoes descartam a colisao.
    cmp bp,di ; Compara BP com DI sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jle tiroAlvoNao ; Vai a tiroAlvoNao se BP for menor ou igual a (com sinal) DI.
    stc ; Devolve CF=1: tiro e alvo se sobrepoem.
    jmp tiroAlvoFim ; Continua em tiroAlvoFim sem criar retorno; pula o caminho que nao se aplica a este caso.
tiroAlvoNao: ; Rotulo: destino dos saltos dentro de SobrepoeTiroAlvo; nao executa acao nem cria uma nova chamada.
    clc ; Devolve CF=0: tiro e alvo estao separados.
tiroAlvoFim: ; Rotulo: destino dos saltos dentro de SobrepoeTiroAlvo; nao executa acao nem cria uma nova chamada.
    pop bp ; Recupera em BP o valor no topo da pilha, desfazendo o salvamento correspondente.
    pop di ; Recupera em DI o valor no topo da pilha, desfazendo o salvamento correspondente.
    pop dx ; Recupera em DX o valor no topo da pilha, desfazendo o salvamento correspondente.
    pop cx ; Recupera em CX o valor no topo da pilha, desfazendo o salvamento correspondente.
    pop bx ; Recupera em BX o valor no topo da pilha, desfazendo o salvamento correspondente.
    pop ax ; Recupera em AX o valor no topo da pilha, desfazendo o salvamento correspondente.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
SobrepoeTiroAlvo endp ; Fecha a definicao de SobrepoeTiroAlvo no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: resolver um tiro, consumindo-o no primeiro impacto ou limite.
; Entrada: SI=offset par valido, alvos atuais. Saida: atividade/vida/pontos.
; Preserva: registradores. Altera flags/dados; CF de RemoverNave lido imediato.
; Inimigo: extremidade Y+4 alcanca topo do jipe (contato incluido).
; Superficie = pista Y=193; montanhas sao fundo, nao bloqueiam disparos.
ConferirUmDisparo proc near ; Por que: E08: resolver primeiro impacto ou limite consome cada tiro uma unica vez.
    cmp tiroAtivo[si],0 ; Compara tiroAtivo[SI] (entrada selecionada pelo offset em bytes) com 0 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je conferirTiroRet ; Vai a conferirTiroRet se tiroAtivo[SI] (entrada selecionada pelo offset em bytes) for igual a 0.
    push ax ; Guarda AX na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    push bx ; Guarda BX na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    push cx ; Guarda CX na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    push dx ; Guarda DX na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    push di ; Guarda DI na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    cmp si,TIRO_FRE_INICIO ; Indices antes desse offset pertencem aos tiros superiores; so eles testam naves.
    jae conferirTiroFrontal ; Vai a conferirTiroFrontal se SI for maior ou igual a (sem sinal) TIRO_FRE_INICIO.
    xor di,di ; Zera DI para comecar pela primeira entrada/posicao percorrida nesta rotina.
tiroContraNave: ; Rotulo: destino dos saltos dentro de ConferirUmDisparo; nao executa acao nem cria uma nova chamada.
    cmp naveAtiva[di],0 ; Compara naveAtiva[DI] (entrada selecionada pelo offset em bytes) com 0 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je tiroNaveProxima ; Vai a tiroNaveProxima se naveAtiva[DI] (entrada selecionada pelo offset em bytes) for igual a 0.
    mov ax,naveX[di] ; Le naveX[di] em AX: coluna de cada nave, inclusive enquanto entra ou sai da tela.
    mov bx,naveY[di] ; Le naveY[di] em BX: altura sorteada de cada nave, que fica fixa durante o percurso.
    mov cx,NAVE_LARG ; CX recebe NAVE_LARG: quantidade de pixels/caracteres a processar nesta chamada.
    mov dx,NAVE_ALT ; DX recebe NAVE_ALT, altura em pixels que o desenhador precisa percorrer.
    call SobrepoeTiroAlvo ; Chama SobrepoeTiroAlvo para sobrepor retangulos inteiros [inicio,fim), com X signed; CALL guarda onde voltar.
    jnc tiroNaveProxima ; Vai a tiroNaveProxima se tiro e alvo estao separados.
    call RemoverNave ; Chama RemoverNave para remover uma nave uma unica vez (saida ou impacto de tiro); CALL guarda onde voltar.
    jnc tiroNaveProxima        ; CF antes de qualquer outra instrucao que o altere | Testa CF de RemoverNave imediatamente: so remocao efetiva autoriza os 100 pontos.
    mov ax,PONTOS_NAVE ; Copia PONTOS_NAVE para AX, preparando esse valor para as instrucoes seguintes sem alterar a origem.
    call SomarPontos ; Chama SomarPontos para somar pontos de obstaculos/naves sem wrap de word; CALL guarda onde voltar.
    jmp consumirTiro ; Continua em consumirTiro sem criar retorno; pula o caminho que nao se aplica a este caso.
tiroNaveProxima: ; Rotulo: destino dos saltos dentro de ConferirUmDisparo; nao executa acao nem cria uma nova chamada.
    add di,2 ; Avanca DI dois bytes para a proxima entrada word da tabela, sem misturar objetos.
    cmp di,NAVE_MAX*2 ; Compara DI com NAVE_MAX*2 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jb tiroContraNave ; Vai a tiroContraNave se DI for menor que (sem sinal) NAVE_MAX*2.
    cmp tiroY[si],HUD_ALT ; Compara tiroY[SI] (entrada selecionada pelo offset em bytes) com HUD_ALT sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jle consumirTiro ; Vai a consumirTiro se tiroY[SI] (entrada selecionada pelo offset em bytes) for menor ou igual a (com sinal) HUD_ALT.
    jmp conferirTiroFim ; Continua em conferirTiroFim sem criar retorno; pula o caminho que nao se aplica a este caso.
conferirTiroFrontal: ; Rotulo: destino dos saltos dentro de ConferirUmDisparo; nao executa acao nem cria uma nova chamada.
    cmp si,TIRO_INI_INICIO ; Antes desse offset o tiro e frontal; a partir dele e inimigo e testa jipe/pista.
    jae conferirTiroInimigo ; Vai a conferirTiroInimigo se SI for maior ou igual a (sem sinal) TIRO_INI_INICIO.
    xor di,di ; Zera DI para comecar pela primeira entrada/posicao percorrida nesta rotina.
tiroContraRocha: ; Rotulo: destino dos saltos dentro de ConferirUmDisparo; nao executa acao nem cria uma nova chamada.
    cmp obstTipo[di],OBST_LIVRE ; Compara obstTipo[DI] (entrada selecionada pelo offset em bytes) com OBST_LIVRE sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je tiroRochaProxima ; Vai a tiroRochaProxima se obstTipo[DI] (entrada selecionada pelo offset em bytes) for igual a OBST_LIVRE.
    cmp obstTipo[di],CRATERA_TIPOS ; Compara obstTipo[DI] (entrada selecionada pelo offset em bytes) com CRATERA_TIPOS sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jb tiroRochaProxima        ; crateras nao sao alvos solidos | Vai a tiroRochaProxima se obstTipo[DI] (entrada selecionada pelo offset em bytes) for menor que (sem sinal) CRATERA_TIPOS.
    mov ax,obstX[di] ; Le obstX[di] em AX: coluna de cada obstaculo; admite negativo na saida parcial pela esquerda.
    mov bx,PISTA_Y-ROCHA_ALT ; Copia PISTA_Y-ROCHA_ALT para BX, preparando esse valor para as instrucoes seguintes sem alterar a origem.
    mov cx,ROCHA_LARG ; CX recebe ROCHA_LARG: quantidade de pixels/caracteres a processar nesta chamada.
    mov dx,ROCHA_ALT ; DX recebe ROCHA_ALT, altura em pixels que o desenhador precisa percorrer.
    call SobrepoeTiroAlvo ; Chama SobrepoeTiroAlvo para sobrepor retangulos inteiros [inicio,fim), com X signed; CALL guarda onde voltar.
    jnc tiroRochaProxima ; Vai a tiroRochaProxima se tiro e alvo estao separados.
    cmp obstTipo[di],ROCHA_1 ; A rocha 1 consome o tiro mas permanece; as outras podem receber dano.
    je consumirTiro ; Vai a consumirTiro se obstTipo[DI] (entrada selecionada pelo offset em bytes) for igual a ROCHA_1.
    inc obstImpactos[di] ; Registra um impacto na mesma rocha; o primeiro permanece guardado para a rocha 4.
    cmp obstTipo[di],ROCHA_4 ; Somente a rocha 4 precisa esperar o segundo impacto; as rochas 2 e 3 ja podem sumir.
    jne tiroDestruirRocha ; Vai a tiroDestruirRocha se obstTipo[DI] (entrada selecionada pelo offset em bytes) for diferente de ROCHA_4.
    cmp obstImpactos[di],IMPACTOS_ROCHA4 ; Compara obstImpactos[DI] (entrada selecionada pelo offset em bytes) com IMPACTOS_ROCHA4 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jb consumirTiro ; Vai a consumirTiro se obstImpactos[DI] (entrada selecionada pelo offset em bytes) for menor que (sem sinal) IMPACTOS_ROCHA4.
tiroDestruirRocha: ; Rotulo: destino dos saltos dentro de ConferirUmDisparo; nao executa acao nem cria uma nova chamada.
    mov obstTipo[di],OBST_LIVRE ; Grava OBST_LIVRE em obstTipo[di]: tipo de cada obstaculo, ou OBST_LIVRE para uma vaga disponivel.
    mov cenarioMudou,1         ; recompor mesmo se nao houve rolagem | Grava 1 em cenarioMudou: aviso de que o terreno/obstaculos precisam ser redesenhados.
    cmp obstPassagem[di],PASS_PONTO ; Confere se esse objeto ja rendeu premio por salto; destruir depois nao paga de novo.
    je consumirTiro            ; salto OU destruicao: nunca os dois ganhos | Vai a consumirTiro se obstPassagem[DI] (entrada selecionada pelo offset em bytes) for igual a PASS_PONTO.
    mov obstPassagem[di],PASS_PONTO ; Marca premio antes de somar: destruir uma rocha ja saltada nao deve dar outros 50 pontos.
    mov ax,PONTOS_OBST ; Copia PONTOS_OBST para AX, preparando esse valor para as instrucoes seguintes sem alterar a origem.
    call SomarPontos ; Chama SomarPontos para somar pontos de obstaculos/naves sem wrap de word; CALL guarda onde voltar.
    jmp consumirTiro ; Continua em consumirTiro sem criar retorno; pula o caminho que nao se aplica a este caso.
tiroRochaProxima: ; Rotulo: destino dos saltos dentro de ConferirUmDisparo; nao executa acao nem cria uma nova chamada.
    add di,2 ; Avanca DI dois bytes para a proxima entrada word da tabela, sem misturar objetos.
    cmp di,OBST_MAX*2 ; Compara DI com OBST_MAX*2 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jb tiroContraRocha ; Vai a tiroContraRocha se DI for menor que (sem sinal) OBST_MAX*2.
    cmp tiroDistancia[si],ALCANCE_FRONTAL ; Limita o percurso a 50 pixels apos procurar impacto; acertar no ultimo pixel ainda vale.
    jae consumirTiro ; Vai a consumirTiro se tiroDistancia[SI] (entrada selecionada pelo offset em bytes) for maior ou igual a (sem sinal) ALCANCE_FRONTAL.
    jmp conferirTiroFim ; Continua em conferirTiroFim sem criar retorno; pula o caminho que nao se aplica a este caso.
conferirTiroInimigo: ; Rotulo: destino dos saltos dentro de ConferirUmDisparo; nao executa acao nem cria uma nova chamada.
    cmp jipeAtivo,0 ; Compara jipeAtivo com 0 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je tiroConferirPista ; Vai a tiroConferirPista se jipeAtivo for igual a 0.
    mov ax,jipeX ; Le jipeX em AX: coluna atual da borda esquerda do jipe.
    mov bx,jipeY ; Le jipeY em BX: linha atual do topo do jipe; diminuir Y faz subir.
    dec bx                    ; inclui contato da extremidade, sem folga lateral | Expande o alvo uma linha para cima para incluir contato da ponta Y+4 com o topo do jipe.
    mov cx,JIPE_LARG ; CX recebe JIPE_LARG: quantidade de pixels/caracteres a processar nesta chamada.
    mov dx,JIPE_ALT+1 ; Compensa a expansao superior: a borda inferior original do jipe permanece no mesmo lugar.
    call SobrepoeTiroAlvo ; Chama SobrepoeTiroAlvo para sobrepor retangulos inteiros [inicio,fim), com X signed; CALL guarda onde voltar.
    jnc tiroConferirPista ; Vai a tiroConferirPista se tiro e alvo estao separados.
    call PerderVida            ; inativo impede duas vidas no mesmo evento | Chama PerderVida para consumir uma vida e tornar jipe ausente, sem reiniciar a sessao; CALL guarda onde voltar.
    jmp consumirTiro ; Continua em consumirTiro sem criar retorno; pula o caminho que nao se aplica a este caso.
tiroConferirPista: ; Rotulo: destino dos saltos dentro de ConferirUmDisparo; nao executa acao nem cria uma nova chamada.
    cmp tiroY[si],PISTA_Y-TIRO_INI_ALT ; O tiro acaba quando sua ponta Y+4 alcanca a pista em Y=193; montanhas sao fundo decorativo.
    jge consumirTiro ; Vai a consumirTiro se tiroY[SI] (entrada selecionada pelo offset em bytes) for maior ou igual a (com sinal) PISTA_Y-TIRO_INI_ALT.
    jmp conferirTiroFim ; Continua em conferirTiroFim sem criar retorno; pula o caminho que nao se aplica a este caso.
consumirTiro: ; Rotulo: destino dos saltos dentro de ConferirUmDisparo; nao executa acao nem cria uma nova chamada.
    mov tiroAtivo[si],0 ; Grava 0 em tiroAtivo[si]: atividade de cada projetil; a vaga pode ser reutilizada depois de zero.
    mov tirosMudou,1 ; Grava 1 em tirosMudou: aviso para apagar posicoes antigas e desenhar os tiros atuais.
conferirTiroFim: ; Rotulo: destino dos saltos dentro de ConferirUmDisparo; nao executa acao nem cria uma nova chamada.
    pop di ; Recupera em DI o valor no topo da pilha, desfazendo o salvamento correspondente.
    pop dx ; Recupera em DX o valor no topo da pilha, desfazendo o salvamento correspondente.
    pop cx ; Recupera em CX o valor no topo da pilha, desfazendo o salvamento correspondente.
    pop bx ; Recupera em BX o valor no topo da pilha, desfazendo o salvamento correspondente.
    pop ax ; Recupera em AX o valor no topo da pilha, desfazendo o salvamento correspondente.
conferirTiroRet: ; Rotulo: destino dos saltos dentro de ConferirUmDisparo; nao executa acao nem cria uma nova chamada.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
ConferirUmDisparo endp ; Fecha a definicao de ConferirUmDisparo no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: testar tiros tambem quando apenas alvos se moveram/nasceram.
; Entrada: listas atuais. Saida: impactos/limites resolvidos antes dos saltos.
; Preserva: registradores. Altera flags/dados.
ConferirDisparos proc near ; Por que: E08: alvos tambem se movem; conferir so quando o tiro anda deixaria colisoes passar.
    push si ; Guarda SI na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    xor si,si ; Zera SI para comecar pela primeira entrada/posicao percorrida nesta rotina.
conferirDisparosLoop: ; Rotulo: destino dos saltos dentro de ConferirDisparos; nao executa acao nem cria uma nova chamada.
    call ConferirUmDisparo ; Chama ConferirUmDisparo para resolver um tiro, consumindo-o no primeiro impacto ou limite; CALL guarda onde voltar.
    add si,2 ; Avanca SI dois bytes para a proxima entrada word da tabela, sem misturar objetos.
    cmp si,TIRO_MAX*2 ; Compara SI com TIRO_MAX*2 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jb conferirDisparosLoop ; Vai a conferirDisparosLoop se SI for menor que (sem sinal) TIRO_MAX*2.
    pop si ; Recupera em SI o valor no topo da pilha, desfazendo o salvamento correspondente.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
ConferirDisparos endp ; Fecha a definicao de ConferirDisparos no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: mover cada tiro por passos de UM pixel, testando todo o trajeto.
; Entrada: listas ativas. Saida: posicoes/distancia/impactos, sem atravessar alvo.
; Altera: AX,BX,CX,SI,flags/dados. Nascimentos ocorrem depois deste movimento.
MoverDisparos proc near ; Por que: E08: testar pixel a pixel impede saltar por cima de alvos entre duas posicoes.
    xor si,si ; Zera SI para comecar pela primeira entrada/posicao percorrida nesta rotina.
moverTiroLoop: ; Rotulo: destino dos saltos dentro de MoverDisparos; nao executa acao nem cria uma nova chamada.
    call ConferirUmDisparo ; Confere a posicao atual antes de continuar; se houve impacto/limite, o tiro fica inativo.
    mov cx,PASSO_TIRO_SUP ; Prepara quatro passos de um pixel para o tiro superior; cada passo tera teste de colisao.
    cmp si,TIRO_FRE_INICIO ; Compara SI com TIRO_FRE_INICIO sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jb moverTiroPixel ; Vai a moverTiroPixel se SI for menor que (sem sinal) TIRO_FRE_INICIO.
    mov cx,PASSO_TIRO_FRE ; Prepara quatro passos de um pixel para o tiro frontal, sem ultrapassar alvos ou alcance.
    cmp si,TIRO_INI_INICIO ; Compara SI com TIRO_INI_INICIO sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jb moverTiroPixel ; Vai a moverTiroPixel se SI for menor que (sem sinal) TIRO_INI_INICIO.
    mov cx,PASSO_TIRO_INI ; Prepara dois passos de um pixel para o tiro inimigo, que e mais lento.
moverTiroPixel: ; Rotulo: destino dos saltos dentro de MoverDisparos; nao executa acao nem cria uma nova chamada.
    cmp tiroAtivo[si],0 ; Compara tiroAtivo[SI] (entrada selecionada pelo offset em bytes) com 0 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je moverTiroProximo ; Vai a moverTiroProximo se tiroAtivo[SI] (entrada selecionada pelo offset em bytes) for igual a 0.
    mov tirosMudou,1 ; Grava 1 em tirosMudou: aviso para apagar posicoes antigas e desenhar os tiros atuais.
    cmp si,TIRO_FRE_INICIO ; Compara SI com TIRO_FRE_INICIO sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jae moverTiroDireita ; Vai a moverTiroDireita se SI for maior ou igual a (sem sinal) TIRO_FRE_INICIO.
    dec tiroY[si] ; Move um pixel para cima; testar cada pixel evita atravessar uma nave em um salto de quatro.
    jmp moverTiroConferir ; Continua em moverTiroConferir sem criar retorno; pula o caminho que nao se aplica a este caso.
moverTiroDireita: ; Rotulo: destino dos saltos dentro de MoverDisparos; nao executa acao nem cria uma nova chamada.
    cmp si,TIRO_INI_INICIO ; Compara SI com TIRO_INI_INICIO sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jae moverTiroBaixo ; Vai a moverTiroBaixo se SI for maior ou igual a (sem sinal) TIRO_INI_INICIO.
    inc tiroX[si] ; Avanca tiroX[SI] (entrada selecionada pelo offset em bytes) em uma unidade: coluna de cada tiro, independente da posicao posterior de quem disparou.
    inc tiroDistancia[si] ; Acumula distancia percorrida, independente da coluna onde o tiro nasceu ou do movimento do jipe.
    jmp moverTiroConferir ; Continua em moverTiroConferir sem criar retorno; pula o caminho que nao se aplica a este caso.
moverTiroBaixo: ; Rotulo: destino dos saltos dentro de MoverDisparos; nao executa acao nem cria uma nova chamada.
    inc tiroY[si] ; Avanca tiroY[SI] (entrada selecionada pelo offset em bytes) em uma unidade: linha de cada tiro; sobe ou desce conforme sua faixa na lista.
moverTiroConferir: ; Rotulo: destino dos saltos dentro de MoverDisparos; nao executa acao nem cria uma nova chamada.
    call ConferirUmDisparo ; Confere a posicao atual antes de continuar; se houve impacto/limite, o tiro fica inativo.
    loop moverTiroPixel ; Diminui CX e volta a moverTiroPixel se ainda restam itens; zero encerra esta repeticao.
moverTiroProximo: ; Rotulo: destino dos saltos dentro de MoverDisparos; nao executa acao nem cria uma nova chamada.
    add si,2 ; Avanca SI dois bytes para a proxima entrada word da tabela, sem misturar objetos.
    cmp si,TIRO_MAX*2 ; Compara SI com TIRO_MAX*2 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jb moverTiroLoop ; Vai a moverTiroLoop se SI for menor que (sem sinal) TIRO_MAX*2.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
MoverDisparos endp ; Fecha a definicao de MoverDisparos no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: cadencia propria; mover ativos, depois emitir pares e tiros de naves.
; Entrada: DX=tick BIOS. Saida: uma atualizacao se intervalo venceu.
; Altera: AX,BX,CX,SI,DI,BP,flags/dados; preserva DX. Sem nova semente.
AtualizarCadenciaDisparos proc near ; Por que: E08: mover tiros antigos antes de criar novos da a todos um primeiro quadro coerente.
    push dx ; Guarda DX na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    mov ax,dx ; Copia o tick atual para AX; DX conserva o instante completo usado como nova referencia.
    sub ax,tickTiro ; Calcula quantos ticks passaram desde tickTiro, usando aritmetica de 16 bits.
    cmp ax,TICKS_TIRO ; So permite mais um passo quando o intervalo configurado em TICKS_TIRO foi atingido.
    jb cadenciaTiroFim ; Vai a cadenciaTiroFim se AX for menor que (sem sinal) TICKS_TIRO.
    mov tickTiro,dx ; Grava DX em tickTiro: tick da ultima atualizacao dos projeteis.
    call MoverDisparos ; Chama MoverDisparos para mover cada tiro por passos de UM pixel, testando todo o trajeto; CALL guarda onde voltar.
    cmp esperaJipe,0 ; Compara esperaJipe com 0 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je cadenciaTiroEntrada ; Vai a cadenciaTiroEntrada se esperaJipe for igual a 0.
    dec esperaJipe ; Reduz esperaJipe em uma unidade: contador que impede disparar um novo par antes da cadencia escolhida.
cadenciaTiroEntrada: ; Rotulo: destino dos saltos dentro de AtualizarCadenciaDisparos; nao executa acao nem cria uma nova chamada.
    pushf ; Guarda FLAGS na pilha para depois restaurar inclusive o estado anterior das interrupcoes.
    cli ; Protege copiar e consumir pedidoTiro contra uma nova IRQ entre essas operacoes.
    mov al,pedidoTiro ; Le pedidoTiro em AL: guarda um toque curto de Espaco ate a proxima leitura do jogo.
    mov pedidoTiro,0 ; Grava 0 em pedidoTiro: guarda um toque curto de Espaco ate a proxima leitura do jogo.
    mov bl,teclasJipe ; Le teclasJipe em BL: mascara das teclas mantidas; cada bit registra uma tecla separadamente.
    popf ; Recupera FLAGS, inclusive IF; a protecao contra IRQ termina com o estado que existia antes.
    test bl,BIT_ESPACO ; Testa os bits de BL selecionados por BIT_ESPACO, sem modificar BL; zero significa nenhum deles ligado.
    jnz cadenciaTiroJipe ; Vai a cadenciaTiroJipe se o resultado/teste anterior for diferente de zero (ZF=0).
    or al,al ; Testa se AL vale zero sem mudar seu valor; ZF permite decidir se ha algo a processar.
    jz cadenciaTiroNaves ; Vai a cadenciaTiroNaves se o resultado/teste anterior for zero (ZF=1).
cadenciaTiroJipe: ; Rotulo: destino dos saltos dentro de AtualizarCadenciaDisparos; nao executa acao nem cria uma nova chamada.
    cmp esperaJipe,0 ; Compara esperaJipe com 0 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jne cadenciaTiroNaves ; Vai a cadenciaTiroNaves se esperaJipe for diferente de 0.
    call DispararJipe ; Chama DispararJipe para criar o par superior/frontal na posicao atual, inclusive no salto; CALL guarda onde voltar.
    jnc cadenciaTiroNaves ; Vai a cadenciaTiroNaves se nao foi possivel criar o par.
    mov esperaJipe,CADENCIA_JIPE ; Grava CADENCIA_JIPE em esperaJipe: contador que impede disparar um novo par antes da cadencia escolhida.
cadenciaTiroNaves: ; Rotulo: destino dos saltos dentro de AtualizarCadenciaDisparos; nao executa acao nem cria uma nova chamada.
    call DispararNaves ; Chama DispararNaves para emitir continuamente de cada nave com canhao dentro da tela; CALL guarda onde voltar.
cadenciaTiroFim: ; Rotulo: destino dos saltos dentro de AtualizarCadenciaDisparos; nao executa acao nem cria uma nova chamada.
    pop dx ; Recupera em DX o valor no topo da pilha, desfazendo o salvamento correspondente.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
AtualizarCadenciaDisparos endp ; Fecha a definicao de AtualizarCadenciaDisparos no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: impedir reposicao sobre tiro inimigo, conservando D14 (area livre).
; Entrada: tiros atuais. Saida: CF=1 se X=0/Y=chao esta ocupado; CF=0 livre.
; Preserva: registradores. Nao remove tiros nem concede invulnerabilidade.
TiroNaReposicao proc near ; Por que: E08: a area livre de retorno deve considerar tiros inimigos, alem dos obstaculos.
    push ax ; Guarda AX na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    push bx ; Guarda BX na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    push cx ; Guarda CX na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    push dx ; Guarda DX na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    push si ; Guarda SI na pilha para nao perder o valor durante calculos/chamadas; POP recupera em ordem inversa.
    mov si,TIRO_INI_INICIO ; Copia TIRO_INI_INICIO para SI, preparando esse valor para as instrucoes seguintes sem alterar a origem.
tiroReposicaoLoop: ; Rotulo: destino dos saltos dentro de TiroNaReposicao; nao executa acao nem cria uma nova chamada.
    cmp tiroAtivo[si],0 ; Compara tiroAtivo[SI] (entrada selecionada pelo offset em bytes) com 0 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je tiroReposicaoProximo ; Vai a tiroReposicaoProximo se tiroAtivo[SI] (entrada selecionada pelo offset em bytes) for igual a 0.
    mov ax,JIPE_X_INICIAL ; Copia JIPE_X_INICIAL para AX, preparando esse valor para as instrucoes seguintes sem alterar a origem.
    mov bx,JIPE_Y_CHAO-1 ; Usa a mesma expansao superior da colisao inimiga para testar a seguranca da reposicao.
    mov cx,JIPE_LARG ; CX recebe JIPE_LARG: quantidade de pixels/caracteres a processar nesta chamada.
    mov dx,JIPE_ALT+1 ; Copia JIPE_ALT+1 para DX, preparando esse valor para as instrucoes seguintes sem alterar a origem.
    call SobrepoeTiroAlvo ; Chama SobrepoeTiroAlvo para sobrepor retangulos inteiros [inicio,fim), com X signed; CALL guarda onde voltar.
    jc tiroReposicaoFim ; Vai a tiroReposicaoFim se tiro e alvo se sobrepoem.
tiroReposicaoProximo: ; Rotulo: destino dos saltos dentro de TiroNaReposicao; nao executa acao nem cria uma nova chamada.
    add si,2 ; Avanca SI dois bytes para a proxima entrada word da tabela, sem misturar objetos.
    cmp si,TIRO_MAX*2 ; Compara SI com TIRO_MAX*2 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jb tiroReposicaoLoop ; Vai a tiroReposicaoLoop se SI for menor que (sem sinal) TIRO_MAX*2.
    clc ; Devolve CF=0: a area inicial esta livre de tiros inimigos.
tiroReposicaoFim: ; Rotulo: destino dos saltos dentro de TiroNaReposicao; nao executa acao nem cria uma nova chamada.
    pop si ; Recupera em SI o valor no topo da pilha, desfazendo o salvamento correspondente.
    pop dx ; Recupera em DX o valor no topo da pilha, desfazendo o salvamento correspondente.
    pop cx ; Recupera em CX o valor no topo da pilha, desfazendo o salvamento correspondente.
    pop bx ; Recupera em BX o valor no topo da pilha, desfazendo o salvamento correspondente.
    pop ax ; Recupera em AX o valor no topo da pilha, desfazendo o salvamento correspondente.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
TiroNaReposicao endp ; Fecha a definicao de TiroNaReposicao no montador; quem retorna durante a execucao e RET/IRET.

; Funcao: desenhar os tres tipos por memoria sobre fundo atual recomposto.
; Entrada: listas, ES=video; Y valido garantido por criacao/movimento/limites.
; Saida: tiros ativos, com recorte horizontal; DF=0. Altera AX,BX,CX,DX,SI,DI.
DesenharDisparos proc near ; Por que: E08: usar as primitivas de memoria atende a mesma restricao grafica das outras etapas.
    cld ; DF=0 faz LODSB/MOVSB/STOSB avancarem os enderecos; evita copiar os pixels para tras.
    xor di,di ; Zera DI para comecar pela primeira entrada/posicao percorrida nesta rotina.
desenharTiroLoop: ; Rotulo: destino dos saltos dentro de DesenharDisparos; nao executa acao nem cria uma nova chamada.
    cmp tiroAtivo[di],0 ; Compara tiroAtivo[DI] (entrada selecionada pelo offset em bytes) com 0 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    je desenharTiroProximo ; Vai a desenharTiroProximo se tiroAtivo[DI] (entrada selecionada pelo offset em bytes) for igual a 0.
    mov si,di ; Passa o indice do tiro a TipoDoTiro em SI; DI conserva qual entrada sera desenhada.
    call TipoDoTiro ; Chama TipoDoTiro para selecionar medidas/bitmap pela faixa fixa do tiro; CALL guarda onde voltar.
    mov cx,tiroLarg[bx] ; Le tiroLarg[bx] em CX: larguras dos tres tipos de tiro, usadas no desenho e na colisao.
    mov dx,tiroAlt[bx] ; Le tiroAlt[bx] em DX: alturas dos tres tipos de tiro, usadas no desenho e na colisao.
    mov si,tiroBitmap[bx] ; SI deixa de ser indice de tiro e recebe o endereco dos pixels; DI ainda identifica a posicao.
    mov ax,tiroX[di] ; Le tiroX[di] em AX: coluna de cada tiro, independente da posicao posterior de quem disparou.
    mov bx,tiroY[di] ; Le tiroY[di] em BX: linha de cada tiro; sobe ou desce conforme sua faixa na lista.
    call DesenharSpriteRecortado ; Chama DesenharSpriteRecortado para sprite FFh com recorte HORIZONTAL para entrada/saida gradual; CALL guarda onde voltar.
desenharTiroProximo: ; Rotulo: destino dos saltos dentro de DesenharDisparos; nao executa acao nem cria uma nova chamada.
    add di,2 ; Avanca DI dois bytes para a proxima entrada word da tabela, sem misturar objetos.
    cmp di,TIRO_MAX*2 ; Compara DI com TIRO_MAX*2 sem mudar os valores; o salto seguinte usa as flags para decidir o caminho.
    jb desenharTiroLoop ; Vai a desenharTiroLoop se DI for menor que (sem sinal) TIRO_MAX*2.
    ret ; Volta a quem chamou esta rotina, usando o endereco de retorno guardado por CALL.
DesenharDisparos endp ; Fecha a definicao de DesenharDisparos no montador; quem retorna durante a execucao e RET/IRET.

end inicio ; Encerra o fonte e informa que a execucao comeca em inicio, nao na primeira declaracao de dados.
