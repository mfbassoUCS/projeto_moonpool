# E02 — menu, telas e artes próprias

> Guia histórico da E02 (25/10). Desde 26/10, MOON.ASM executa a E03; use [LEIA-E03](LEIA-E03.md) para o fluxo atual. O fonte E02 foi preservado em `testes/E02BASE.ASM`; seu gerador de testes lê esse snapshot. O atalho E02 monta o fonte atual, não restaura o caminho demonstrativo 12345.

O executável atual é uma **demonstração de telas**, não um jogo. A E01 está preservada em `testes/E01BASE.ASM`. Em 25/10/2026, o aluno autorizou artes próprias a partir de consulta visual ao arcade, sem cópia. Foram implementados jipe, três naves, vidas, relógio, crateras, rochas e duas camadas de relevo. Não são reproduções das figuras ausentes do professor. Confira a origem em `artes/referencias/README.md`.

## Executar

Abra `EXECUTAR-E02.cmd`, confira `MONTAGEM.LOG` e `LINK.LOG` e digite `MOON` no DOS. O atalho usa o DOSBox incluído no GUI Turbo Assembler 5.1, TASM 4.1 e TLINK 7.1.30.1, já disponíveis em `ferramentas/guitasm`. A configuração contém o caminho absoluto `C:\ucs\moon_patrol`.

Pela IDE, `ABRIR-GUI.cmd` abre `MOON.ASM`: use **Turbo 16-bit**, Assemble, Build e Run. O fonte é único; não precisa de include, Python, Node, navegador ou imagens externas para montar/executar. O comando DOS permanece `tasm /l MOON.ASM`, seguido de `tlink MOON.OBJ`.

Não execute um EXE antigo após erro de montagem. O atalho da E01 também aponta para o `MOON.ASM` atual; para reproduzir a E01, use o snapshot e os testes históricos, conforme `testes/README.md`.

## Fluxo para apresentar

1. O menu começa em **Jogar**. Título Moon Patrol em ASCII verde-claro, jipe e três naves animados e caixas Jogar/Sair. Cima e baixo alternam seleção; selecionada em 0Ch, outra em 0Fh. Letras, esquerda/direita e Esc são ignorados. O aviso identifica “DEMO E02 - ARTES AUTORAIS”.
2. Enter em Jogar mostra **SETOR 1**. A mensagem e o avanço por Enter são uma proposta técnica para D04, não uma orientação confirmada do professor.
3. Outro Enter abre **GAME** e **OVER**, em duas linhas, vermelho 04h, com **SCORE: 12345**. Esse número é exclusivamente `SCORE_DEMO`; não há pontuação calculada.
4. Qualquer tecla volta ao menu e reinicializa seleção, posições, referência dos ticks e score armazenado. Enter em **Sair** restaura modo/página de vídeo e retorna ao DOS.

As telas de setor e fim dizem “DEMONSTRACAO E02 - SEM PARTIDA”. O ciclo final com vidas, tempo e colisões continua para E07. Não existem cenário rolando, jipe jogável, obstáculos, grupos inimigos ou disparos.

## Como explicar o código

`inicio` prepara DS, guarda modo/página, ativa 13h e aponta ES para A000h. O laço chama `LerTeclado` sem bloquear. Enquanto o estado é MENU, chama `AtualizarAnimacao`; outros estados aguardam suas teclas sem movimentar objetos.

`estado` determina a tela e `opcao` determina a caixa selecionada. São variáveis distintas: mudar seleção não muda a tela nem reinicia a animação. `EntrarMenu`, `EntrarSetor` e `EntrarGameOver` limpam teclas antigas ao entrar, evitando que Enter já enfileirado pule a próxima tela.

`EscreverTexto` recebe DS:SI, tamanho em CX, linha/coluna em DH/DL e cor em BL. Usa INT 10h/AH=13h, permitido para texto. Salva ES, aponta temporariamente ES:BP para o texto e restaura ES de vídeo. `MostrarArte` repete essa impressão para linhas de largura fixa. As caixas usam os bytes DOS 218/191/192/217/196/179, não caracteres UTF-8.

O título vem do [TAAG, fonte Mini](https://patorjk.com/software/taag/#p=display&f=Mini&t=Moon%20Patrol), com 39 colunas e quatro linhas. GAME e OVER usam Small. Os dados e capturas de origem estão em `artes/taag.json` e `artes/taag-*.png`. Só foram acrescentados espaços à direita para igualar a largura das linhas.

`EntrarGameOver` recebe **AX=score final, de 0 a 65535**. Salva o número antes de limpar a tela. `FormatarScore` divide por 10: o resto vira o último algarismo, e a divisão continua para a esquerda. Sempre exibe cinco dígitos, inclusive 00000. A rotina não decide se vidas ou tempo acabaram; o chamador futuro fará isso. `demonstracao=1` controla o aviso da E02 e não deve ser desligado para simular integração pronta.

## Pixels e vários objetos

Cada byte do bitmap contém um índice de cor. `DesenharBitmap`, `SalvarFundo` e `PrepararRetangulo` foram reaproveitadas da E01. A cópia opaca continua necessária para restaurar o fundo, inclusive pixels pretos. A nova `DesenharSprite` ignora somente **FFh**, reservado como transparência; **00h desenha preto**.

As duas rotinas de desenho recebem AX=x, BX=y, CX=largura, DX=altura, DS:SI=bitmap e ES=vídeo. Preservam os registradores e deixam DF=0. Retângulos parcialmente fora da tela são rejeitados inteiros. Não há recorte parcial.

As tabelas `menuX/menuY/menuLarg/menuAlt/menuBitmap/menuFundo` têm quatro posições. DI percorre 0,2,4,6 porque cada entrada é uma word. `CarregarSpriteMenu` transforma uma entrada nos parâmetros das rotinas comuns. Os buffers somam **788 bytes**: 200 do jipe e 196 de cada nave.

Cada quadro segue esta ordem:

1. `ApagarSpritesMenu` restaura os quatro fundos nas posições antigas.
2. `MoverSpritesMenu` soma dois pixels a cada X. Se a próxima posição ultrapassar `320-largura`, volta a X=0. O sprite aparece inteiro na esquerda; não entra gradualmente.
3. `CapturarEDesenharMenu` captura **todos os fundos antes de desenhar qualquer objeto**. Só então desenha os quatro, na ordem jipe/nave1/nave2/nave3.

Essa ordem impede que um buffer guarde outro sprite e depois o deixe como rastro. Funciona também com sobreposição sobre **fundo estático**. A E03 deverá decidir como recompor um fundo que se move; esta solução não demonstra restauração de cenário rolando.

A cadência continua em dois ticks BIOS, aproximadamente 110 ms por passo. Não há espera bloqueante. O contador de segundos da demonstração E01 permanece no snapshot; nesta E02 não há cronômetro de partida. As limitações de pausa longa e reinicialização do contador BIOS à meia-noite não foram removidas.

## Artes e medidas

| Dados | Dimensões | Estado |
|---|---|---|
| bitmapJipe | 20×10 | Carroceria magenta, cabine ciano, três rodas e dois canhões |
| bitmapNave1/2/3 | 14×14 cada | Disco amarelo, nave de asas ciano e nave em losango magenta |
| bitmapVidas3/2/1 | 18×11 cada | Corações ativos vermelhos; perdidos em cinza |
| bitmapRelogio | 7×8 | Contorno/ponteiros amarelos e interior preto |
| bitmapCratera1/2/3 | 14×7 cada | Aberturas distintas, borda marrom/cinza e interior preto |
| bitmapRocha1/2/3/4 | 12×10 cada | Pedra cinza, arredondada marrom, pontas ciano e pedra vermelha com fissura |
| bitmapMontanhas | 320×64 | Relevo azul/ciano, dado estático |
| bitmapMontes | 320×32 | Camada complementar verde, dado estático |

As grades autorais estão em `artes/desenhos.json`, e o desenho/conversão em `artes/gerar-artes.py`. A conversão associa `.` a FFh e dígitos hexadecimais às cores; cada linha vira DB. O programa usa apenas os bytes já incorporados em MOON.ASM. Os bitmaps somam 32.932 bytes, sem alterar as rotinas de desenho da versão anterior. A prancha ampliada está em `artes/previas/catalogo.png`.

Somente jipe e naves aparecem no menu. Os outros sprites e o relevo são preparados e exercitados numa galeria estática de testes (`testes/E02ART.INC`), não em uma partida. As primeiras/últimas colunas do relevo são iguais; rolagem, posição definitiva, pista e HUD ficam para E03.

## Testes e pendências

Veja `testes/README.md`, `testes/E02RESUL.LOG` e `evidencias/e02/verificacao.txt` para execução reproduzível e resultados. Teclas automatizadas entram no buffer BIOS: não são teste de teclado físico. Os PNGs em `evidencias/e02/` reconstruídos de arquivos RAW representam a memória real do emulador, com paleta VGA padrão.

Falta ação do aluno: revisar a aparência das artes próprias e testar fisicamente setas/Enter/qualquer tecla/Sair e Assemble/Build/Run na IDE. Fornecer as figuras ausentes deixou de ser pré-condição após a autorização de 25/10. D04 permanece proposta para confirmação antes da integração final. O prompt E02 serve para retomar a validação; E03 continua dependendo de novo pedido explícito.
