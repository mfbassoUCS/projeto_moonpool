# Mapa completo do código — E09

Catálogo extraído dos cabeçalhos do fonte em 08/11/2026. Complementa o [estudo progressivo](ESTUDO-DO-CODIGO.md) e o [guia de apresentação](GUIA-APRESENTACAO.md). Os contratos são a documentação da implementação; leia o corpo de cada rotina para entender como os cumpre.

Fonte SHA256: `13176BC9F5EF6A9123945CAC44732BB933D8511214ECD100F7EA081703025E6D`. Total: 69 procedimentos. Linhas são referências desta versão; se o código mudar, procure pelo nome seguido de proc e atualize o catálogo.

## Organização do arquivo

| Região | Conteúdo |
|---|---|
| Início até .data | Diretivas, constantes e verificações de configuração na montagem |
| .data até ARTES_INICIO | Variáveis, vetores, buffers e tabelas |
| ARTES_INICIO até ARTES_FIM | Dados dos 17 bitmaps; não são instruções executadas |
| Após artes até .code | Textos, arte ASCII e caixas |
| .code até end inicio | As 69 rotinas abaixo; execução começa em inicio |

Atualização desta sessão por inspeção do fonte, sem nova execução. Resultados das auditorias anteriores pertencem às versões identificadas nelas.

## Índice de procedimentos

| Procedimento | Linha no MOON.ASM |
|---|---|
| [inicio](#inicio) | 666 |
| [LimparTela](#limpartela) | 706 |
| [EscreverTexto](#escrevertexto) | 718 |
| [MostrarArte](#mostrararte) | 747 |
| [LimparTeclado](#limparteclado) | 765 |
| [EntrarMenu](#entrarmenu) | 780 |
| [DesenharOpcoes](#desenharopcoes) | 820 |
| [EntrarSetor](#entrarsetor) | 845 |
| [EntrarGameOver](#entrargameover) | 876 |
| [FormatarScore](#formatarscore) | 910 |
| [FormatarNumero](#formatarnumero) | 920 |
| [LerTeclado](#lerteclado) | 935 |
| [AtualizarAnimacao](#atualizaranimacao) | 978 |
| [CarregarSpriteMenu](#carregarspritemenu) | 994 |
| [CapturarEDesenharMenu](#capturaredesenharmenu) | 1006 |
| [ApagarSpritesMenu](#apagarspritesmenu) | 1028 |
| [MoverSpritesMenu](#moverspritesmenu) | 1043 |
| [EntrarPartida](#entrarpartida) | 1066 |
| [AtualizarPartida](#atualizarpartida) | 1103 |
| [ReiniciarJipe](#reiniciarjipe) | 1168 |
| [RegistrarScanJipe](#registrarscanjipe) | 1187 |
| [TecladoJogoIRQ](#tecladojogoirq) | 1245 |
| [InstalarTecladoJogo](#instalartecladojogo) | 1270 |
| [RestaurarTecladoJogo](#restaurartecladojogo) | 1300 |
| [AtualizarJipe](#atualizarjipe) | 1325 |
| [ContarTopo](#contartopo) | 1389 |
| [CapturarEDesenharJipe](#capturaredesenharjipe) | 1408 |
| [DesenharQuadroPartida](#desenharquadropartida) | 1426 |
| [LerCentissegundos](#lercentissegundos) | 1464 |
| [AtualizarRelogio](#atualizarrelogio) | 1504 |
| [ConsumirTempo](#consumirtempo) | 1524 |
| [AvancarCenario](#avancarcenario) | 1565 |
| [ComporLinhaCircular](#comporlinhacircular) | 1580 |
| [DesenharCenario](#desenharcenario) | 1616 |
| [DesenharStatus](#desenharstatus) | 1665 |
| [PrepararRetangulo](#prepararretangulo) | 1717 |
| [DesenharBitmap](#desenharbitmap) | 1753 |
| [SalvarFundo](#salvarfundo) | 1786 |
| [DesenharSprite](#desenharsprite) | 1823 |
| [ReiniciarObstaculos](#reiniciarobstaculos) | 1862 |
| [Sortear](#sortear) | 1886 |
| [AvancarObstaculos](#avancarobstaculos) | 1905 |
| [SobrepoeObstaculo](#sobrepoeobstaculo) | 1968 |
| [ConferirObstaculos](#conferirobstaculos) | 1989 |
| [SomarPontos](#somarpontos) | 2058 |
| [PerderVida](#perdervida) | 2071 |
| [TentarReporJipe](#tentarreporjipe) | 2102 |
| [RetirarObstaculos](#retirarobstaculos) | 2140 |
| [DesenharObstaculos](#desenharobstaculos) | 2164 |
| [DesenharSpriteRecortado](#desenharspriterecortado) | 2189 |
| [ReiniciarNaves](#reiniciarnaves) | 2250 |
| [ContarNavesAtivas](#contarnavesativas) | 2269 |
| [GerarGrupoNaves](#gerargruponaves) | 2291 |
| [RemoverNave](#removernave) | 2342 |
| [AtualizarNaves](#atualizarnaves) | 2362 |
| [AtualizarCadenciaNaves](#atualizarcadencianaves) | 2388 |
| [DesenharNaves](#desenharnaves) | 2406 |
| [ReiniciarDisparos](#reiniciardisparos) | 2435 |
| [ProcurarVagaTiro](#procurarvagatiro) | 2461 |
| [DispararJipe](#dispararjipe) | 2479 |
| [DispararNaves](#dispararnaves) | 2520 |
| [TipoDoTiro](#tipodotiro) | 2560 |
| [SobrepoeTiroAlvo](#sobrepoetiroalvo) | 2575 |
| [ConferirUmDisparo](#conferirumdisparo) | 2619 |
| [ConferirDisparos](#conferirdisparos) | 2721 |
| [MoverDisparos](#moverdisparos) | 2736 |
| [AtualizarCadenciaDisparos](#atualizarcadenciadisparos) | 2776 |
| [TiroNaReposicao](#tironareposicao) | 2814 |
| [DesenharDisparos](#desenhardisparos) | 2847 |

## Contratos dos procedimentos

### inicio

Local: MOON.ASM, linha 666.

```text
Funcao: iniciar video, executar telas e devolver controle ao DOS.
Entrada: nenhuma. Saida: codigo DOS 0, modo/pagina anteriores restaurados.
Altera: registradores, segmentos e video. Partida completa com tiros.
```

### LimparTela

Local: MOON.ASM, linha 706.

```text
Funcao: limpar os pixels por memoria, sem mudar o modo de video.
Entrada: ES=video. Saida: 64000 bytes pretos. Altera: AX,CX,DI,flags.
```

### EscreverTexto

Local: MOON.ASM, linha 718.

```text
Funcao: imprimir texto BIOS, preservando ES de video para os bitmaps.
Entrada: DS:SI=texto, CX=tamanho, DH=linha, DL=coluna, BL=cor.
Saida: texto na pagina 0. Preserva: todos os registradores. Altera: flags.
```

### MostrarArte

Local: MOON.ASM, linha 747.

```text
Funcao: imprimir bloco ASCII retangular (titulo, GAME/OVER ou caixa).
Entrada: como EscreverTexto, BP=numero de linhas, CX=largura fixa.
Saida: bloco no video. Preserva: registradores. Altera: flags.
```

### LimparTeclado

Local: MOON.ASM, linha 765.

```text
Funcao: descartar teclas antigas ao entrar em uma nova tela.
Entrada: buffer BIOS. Saida: buffer vazio. Altera: AX,flags.
```

### EntrarMenu

Local: MOON.ASM, linha 780.

```text
Funcao: reiniciar menu, selecao, posicoes e relogio da animacao.
Entrada: DS=dados, ES=video. Saida: estado MENU, Jogar selecionado.
Altera: AX,BX,CX,DX,SI,DI,BP,flags, dados e video.
```

### DesenharOpcoes

Local: MOON.ASM, linha 820.

```text
Funcao: redesenhar so as caixas, sem tocar na faixa da animacao.
Entrada: opcao. Saida: selecionada 0Ch, outra 0Fh.
Altera: BX,CX,DX,SI,BP,flags e video.
```

### EntrarSetor

Local: MOON.ASM, linha 845.

```text
Funcao: apresentar o unico setor e aguardar Enter, escolha tecnica D04.
Entrada: nenhuma. Saida: estado SETOR; o relogio da partida ainda nao corre.
Altera: AX,BX,CX,DX,SI,DI,flags, estado e video.
```

### EntrarGameOver

Local: MOON.ASM, linha 876.

```text
Funcao: tela reutilizavel de encerramento; nao calcula regras da partida.
Entrada: AX=score final sem sinal (0..65535), ES=video, DS=dados.
Saida: estado FIM; GAME e OVER vermelhos, score decimal, buffer vazio.
Altera: AX,BX,CX,DX,SI,DI,BP,flags, scoreFinal/digitosScore e video.
```

### FormatarScore

Local: MOON.ASM, linha 910.

```text
Funcao: converter numero para cinco algarismos, incluindo zeros iniciais.
Entrada: AX=numero unsigned. Saida: digitosScore. Altera: AX,BX,CX,DX,DI,flags.
```

### FormatarNumero

Local: MOON.ASM, linha 920.

```text
Funcao: converter inteiro unsigned em campo decimal de largura fixa.
Entrada: AX=valor, CX=digitos, DS:DI=ultimo caractere (campo suficiente).
Saida: campo preenchido com zeros iniciais. Altera: AX,BX,CX,DX,DI,flags.
```

### LerTeclado

Local: MOON.ASM, linha 935.

```text
Funcao: consultar e consumir no maximo uma tecla, sem bloquear a animacao.
Entrada: estado, opcao e buffer BIOS. Saida: transicao ou selecao atualizada.
Altera: AX,BX,CX,DX,SI,DI,BP,flags, dados e video pelas rotinas de tela.
```

### AtualizarAnimacao

Local: MOON.ASM, linha 978.

```text
Funcao: mover somente quando decorrer o intervalo BIOS configurado.
Entrada: ultimoTick, ES=video. Saida: posicoes/quadro atualizados se venceu.
Altera: AX,BX,CX,DX,SI,DI,flags. Sem espera bloqueante ou cronometro de jogo.
```

### CarregarSpriteMenu

Local: MOON.ASM, linha 994.

```text
Funcao: carregar parametros de um dos quatro objetos do menu.
Entrada: DI=indice em bytes (0,2,4,6). Saida: AX=x,BX=y,CX=larg,DX=alt,
DS:SI=bitmap. Preserva: DI,BP,ES. Nao valida indice (chamador controla).
```

### CapturarEDesenharMenu

Local: MOON.ASM, linha 1006.

```text
Funcao: salvar TODOS os fundos limpos e so depois desenhar os objetos.
Entrada: tabelas do menu; ES=video sem sprites. Saida: buffers e video.
Altera: AX,BX,CX,DX,SI,DI,flags. Preserva: BP,DS,ES.
```

### ApagarSpritesMenu

Local: MOON.ASM, linha 1028.

```text
Funcao: apagar TODOS os objetos usando fundos capturados antes do desenho.
Entrada: posicoes anteriores e buffers, ES=video. Saida: fundo restaurado.
Altera: AX,BX,CX,DX,SI,DI,flags. Preserva: BP,DS,ES.
```

### MoverSpritesMenu

Local: MOON.ASM, linha 1043.

```text
Funcao: restaurar, mover, capturar fundos e desenhar um quadro do menu.
Entrada: tabelas/buffers, ES=video. Saida: x avanca; volta inteiro a x=0.
Altera: AX,BX,CX,DX,SI,DI,flags. Fundo estatico obrigatorio entre quadros.
```

### EntrarPartida

Local: MOON.ASM, linha 1066.

```text
Funcao: reiniciar cenario/HUD, jipe, obstaculos, naves, tiros e relogio.
Entrada: DS=dados, ES=video. Saida: estado PARTIDA, valores reiniciados.
Altera: AX,BX,CX,DX,SI,DI,BP,flags, dados e video.
```

### AtualizarPartida

Local: MOON.ASM, linha 1103.

```text
Funcao: atualizar tempo a cada consulta e movimento em sua propria cadencia.
Entrada: estado PARTIDA, relogios/dados, ES=video. Saida: quadro ou FIM.
Altera: AX,BX,CX,DX,SI,DI,BP,flags, dados e video. Nunca espera por tecla.
```

### ReiniciarJipe

Local: MOON.ASM, linha 1168.

```text
Funcao: restaurar somente os dados do jipe para uma nova partida.
Entrada: nenhuma. Saida: posicao inicial, chao, sem teclas/pedido pendente.
Altera: dados do jipe; preserva registradores. Nao reinicia score/relogio.
```

### RegistrarScanJipe

Local: MOON.ASM, linha 1187.

```text
Funcao: registrar make/break das setas e Espaco, inclusive simultaneas.
Entrada: AL=scan code set 1 (bit 7=soltou), DS=dados.
Saida: teclasJipe, pedidoTiro e pedidoSalto (nova pressao no chao).
Altera: AX,flags e dados de entrada. Prefixos/outros scans sao ignorados.
```

### TecladoJogoIRQ

Local: MOON.ASM, linha 1245.

```text
Funcao: IRQ1 curta durante a partida: ler teclado, confirmar e registrar.
Entrada: hardware porta 60h. Saida: teclas/pedido; IRET retoma interrompido.
Preserva: registradores/flags. Nao chama DOS/BIOS, nao desenha nem move.
```

### InstalarTecladoJogo

Local: MOON.ASM, linha 1270.

```text
Funcao: guardar INT 09h BIOS e instalar leitura de pressao/soltura.
Entrada: DS=dados, tecladoJogoAtivo=0. Saida: vetor ativo durante partida.
Preserva: registradores. Altera: flags, vetor DOS e dados de controle.
```

### RestaurarTecladoJogo

Local: MOON.ASM, linha 1300.

```text
Funcao: devolver INT 09h ao BIOS antes do Game Over/saida.
Entrada: DS=dados, vetor guardado. Saida: teclado BIOS restaurado.
Preserva: registradores (inclusive AX=score). Altera: flags/vetor/controle.
```

### AtualizarJipe

Local: MOON.ASM, linha 1325.

```text
Funcao: executar um frame do jipe, independente da repeticao do teclado.
Entrada: teclas/pedido, posicao/fase. Saida: X/Y/fase e jipeMudou (0/1).
Altera: AX,BX,flags e dados do jipe. Sem desenho, pontos ou perda de vida.
```

### ContarTopo

Local: MOON.ASM, linha 1389.

```text
Funcao: D05, contar distancia do terreno depois de chegar ao topo.
Entrada: AX=pixels efetivamente avancados; estadoSalto/pixelsTopo.
Saida: inicia descida ao atingir 5 pixels; saturacao defensiva para chamadas.
Preserva: registradores. Altera: flags/contador/fase; nao altera X/Y.
O laco usa 1 px/tick: amostras reais 1,2,3,4,5, sem sexto pixel no topo.
Nao conta teclas, tempo nem frames; esquerda/parado/limites nao bloqueiam.
```

### CapturarEDesenharJipe

Local: MOON.ASM, linha 1408.

```text
Funcao: capturar o fundo limpo atual e desenhar o jipe sempre 20x10.
Entrada: jipeX/Y validos, ES=fundo sem jipe. Saida: buffer/posicao e sprite.
Altera: AX,BX,CX,DX,SI,flags. Nao usa os buffers do menu.
```

### DesenharQuadroPartida

Local: MOON.ASM, linha 1426.

```text
Funcao: apagar/redesenhar com ou sem rolagem sem restaurar fundo velho.
Entrada: flags de mudanca, posicoes, ES=video. Saida: quadro atualizado.
Altera: AX,BX,CX,DX,SI,DI,BP,flags e video. HUD preservado.
```

### LerCentissegundos

Local: MOON.ASM, linha 1464.

```text
Funcao: obter hora DOS completa em centesimos, incluindo horas e minutos.
Entrada: nenhuma. Saida: DX:AX=0..8639999. Altera: AX,DX,flags.
Preserva: BX,CX,SI,DI,BP,DS,ES. Resolucao real depende do relogio DOS.
```

### AtualizarRelogio

Local: MOON.ASM, linha 1504.

```text
Funcao: descontar tempo real desde a ultima consulta, com virada de dia.
Entrada: tempoAnteriorHi/Lo e relogio DOS; consulta em intervalo <24 horas.
Saida: CF=1 se mudou tempoRestante, CF=0 caso contrario.
Altera: AX,BX,CX,DX,flags e dados temporais. Preserva: SI,DI,BP,DS,ES.
```

### ConsumirTempo

Local: MOON.ASM, linha 1524.

```text
Funcao: acumular fracoes e descontar somente grupos de 100 centesimos.
Entrada: DX:AX=intervalo, margemInicial, fracaoSegundo e tempoRestante.
Saida: CF=1 se mudou tempo; satura em zero, sem underflow.
Altera: AX,BX,DX,flags, tempoRestante/fracaoSegundo/margemInicial.
```

### AvancarCenario

Local: MOON.ASM, linha 1565.

```text
Funcao: avancar a origem circular, revelando novos pixels pela direita.
Entrada: rolagem 0..319. Saida: rolagem=(rolagem+PASSO_CENARIO) mod 320.
Altera: AX,flags e rolagem. Sem desenho nem alteracao do relogio.
```

### ComporLinhaCircular

Local: MOON.ASM, linha 1580.

```text
Funcao: compor uma linha de 320 pixels da arte com deslocamento circular.
Entrada: DS:SI=linha de origem, rolagem=0..319; linhaCenario ja preenchida.
Saida: linhaCenario sobreposta (FFh preserva, 00h opaco).
Preserva: registradores. Altera: flags (DF=0) e buffer de 320 bytes.
```

### DesenharCenario

Local: MOON.ASM, linha 1616.

```text
Funcao: recompor terreno em memoria e copiar linhas prontas para o video.
Entrada: rolagem, DS=dados, ES=video. Saida: y=100..192 e pista 193..199.
Altera: AX,BX,CX,DX,SI,DI,BP,flags. HUD/ceu preservados; sem fundos velhos.
D10: montanhas 100..163, montes 132..163, ultima linha estendida ate 192.
```

### DesenharStatus

Local: MOON.ASM, linha 1665.

```text
Funcao: desenhar score esquerdo, vidas centrais e tempo direito (D01).
Entrada: scorePartida, vidas=0..3, tempoRestante=0..999, ES=video.
Saida: barra y=0..14, sem digitos/sprites antigos. Zero vidas limpa o icone.
Altera: AX,BX,CX,DX,SI,DI,flags e buffers decimais; nao muda valores do jogo.
```

### PrepararRetangulo

Local: MOON.ASM, linha 1717.

```text
Funcao: validar retangulo inteiro e calcular endereco inicial.
Entrada: AX=x, BX=y, CX=largura, DX=altura (valores sem sinal).
Saida: CF=0 valido: DI=y*320+x, BP=altura, BX=salto entre linhas.
CF=1 invalido, nao acessar video. Nao ha recorte parcial.
Altera: AX,BX,DX,DI,BP,flags. Preserva: CX,SI,DS,ES.
```

### DesenharBitmap

Local: MOON.ASM, linha 1753.

```text
Funcao: copiar bitmap opaco linha a linha para o video.
Entrada: DS:SI=bitmap, ES=VIDEO_SEG, AX=x,BX=y,CX=largura,DX=altura.
Origem deve conter largura*altura bytes no segmento DS.
Saida: retangulo desenhado; coordenadas invalidas nao escrevem nada.
Preserva: todos os registradores. Altera: flags (DF fica zero), video.
```

### SalvarFundo

Local: MOON.ASM, linha 1786.

```text
Funcao: guardar fundo antes de colocar um bitmap sobre ele.
Entrada: DS:SI=buffer de largura*altura bytes; demais como DesenharBitmap.
Saida: fundo salvo no buffer; coordenadas invalidas nao copiam nada.
Preserva: todos os registradores. Altera: flags e buffer em DS.
```

### DesenharSprite

Local: MOON.ASM, linha 1823.

```text
Funcao: desenhar bitmap com transparencia FFh, sem recorte parcial.
Entrada: como DesenharBitmap; DS:SI contem largura*altura bytes.
Saida: FFh preserva fundo, 00h desenha preto; invalido nao escreve.
Preserva: todos os registradores. Altera: flags (DF=0) e video.
```

### ReiniciarObstaculos

Local: MOON.ASM, linha 1862.

```text
Funcao: reiniciar somente geracao/obstaculos para uma NOVA sessao.
Entrada: nenhuma. Saida: lista vazia, semente dos ticks, primeira cratera.
Altera: AX,CX,DX,DI,flags e dados; nao deve ser chamada na perda de vida.
```

### Sortear

Local: MOON.ASM, linha 1886.

```text
Funcao: pseudoaleatorio simples de 16 bits, com resto em faixa finita.
Entrada: CX=limite exclusivo 1..256. Saida: AX=0..CX-1; nova semente.
Altera: AX,DX,flags. Preserva: demais. Nao ha tentativas/rejeicoes.
```

### AvancarObstaculos

Local: MOON.ASM, linha 1905.

```text
Funcao: mover todos com o terreno e gerar C,R,C em distancias sorteadas.
Entrada: lista/proximoEm. Saida: X -= PASSO_CENARIO; novos pela direita.
Altera: AX,BX,CX,DX,DI,flags. Distancia negativa preserva sobra do passo.
```

### SobrepoeObstaculo

Local: MOON.ASM, linha 1968.

```text
Funcao: detectar intervalo horizontal do jipe sobre um obstaculo.
Entrada: DI=entrada ativa, jipeX. Saida: CF=1 sobrepoe; BX=tipo*2,
AX=fim exclusivo do obstaculo. Altera: AX,BX,DX,flags; signed para bordas.
```

### ConferirObstaculos

Local: MOON.ASM, linha 1989.

```text
Funcao: D15: colisao tem prioridade; depois acompanhar travessias por salto.
Entrada: posicoes apos movimento (ou pouso). Saida: vida/pontos/marcadores.
Altera: AX,BX,CX,DX,DI,flags. Sem desenho; no maximo uma morte por chamada.
```

### SomarPontos

Local: MOON.ASM, linha 2058.

```text
Funcao: somar pontos de obstaculos/naves sem wrap de word.
Entrada: AX=ganho unsigned. Saida: scorePartida <=65535, statusMudou=1.
Altera: AX,flags. Saturacao explicita protege tambem configuracoes futuras.
```

### PerderVida

Local: MOON.ASM, linha 2071.

```text
Funcao: consumir uma vida e tornar jipe ausente, sem reiniciar a sessao.
Entrada: jipeAtivo/vidas. Saida: uma vida a menos, travessias canceladas.
Altera: DI,flags/dados. Tempo, score, geracao, rolagem e teclas preservados.
```

### TentarReporJipe

Local: MOON.ASM, linha 2102.

```text
Funcao: D14, reaparecer no proximo tick do jipe com x=0 LIVRE.
Entrada: jipe ausente/vidas/lista. Saida: posicao/fase reiniciadas se seguro.
Altera: AX,BX,DI,flags. Sem invulnerabilidade/remocao de obstaculo.
Mantem teclas fisicas: laterais voltam no proximo tick; cima exige soltura.
```

### RetirarObstaculos

Local: MOON.ASM, linha 2140.

```text
Funcao: liberar apenas objetos inteiros fora da esquerda, sem dar pontos.
Entrada: lista e marcadores. Saida: vagas livres; travessia espera pouso.
Altera: AX,BX,DI,flags. Preserva candidato que saiu da tela durante salto.
```

### DesenharObstaculos

Local: MOON.ASM, linha 2164.

```text
Funcao: compor os sete tipos sobre o cenario limpo, antes do jipe.
Entrada: tabelas, ES=video. Saida: obstaculos visiveis; sem fundos antigos.
Altera: AX,BX,CX,DX,SI,DI,flags. Artes E02 intactas.
```

### DesenharSpriteRecortado

Local: MOON.ASM, linha 2189.

```text
Funcao: sprite FFh com recorte HORIZONTAL para entrada/saida gradual.
Entrada: AX=x signed, BX=y, CX=largura, DX=altura, DS:SI=bitmap, ES=video.
Saida: somente pixels dentro de 0..319; y deve caber inteiro em 0..199.
Preserva: registradores. Altera: flags (DF=0), video por memoria.
DesenharSprite original e menu continuam com contrato sem recorte.
```

### ReiniciarNaves

Local: MOON.ASM, linha 2250.

```text
Funcao: limpar as tres vagas somente ao iniciar uma nova partida.
Entrada: nenhuma. Saida: lista vazia, sem alterar a semente compartilhada.
Altera: DI,flags e dados das naves. Nao chamar na perda de vida.
```

### ContarNavesAtivas

Local: MOON.ASM, linha 2269.

```text
Funcao: contar atividade real, incluindo naves ainda entrando pela direita.
Entrada: naveAtiva. Saida: AX=0..NAVE_MAX; preserva demais registradores.
Altera: AX,flags. Nao usa a quantidade originalmente sorteada como contador.
```

### GerarGrupoNaves

Local: MOON.ASM, linha 2291.

```text
Funcao: gerar um grupo homogeneo, apenas se nenhuma vaga estiver ativa.
Entrada: lista/semente. Saida: 1..3 naves; tipo 0..2, X/Y sorteados validos.
Altera: AX,BX,CX,DX,DI,BP,flags e dados. Sem tentativas/rejeicoes.
D06: faixa de formacao [320,480), largura maxima de meia tela.
BP guarda a sobra depois de reservar larguras e gaps minimos. Cada sorteio
consome somente essa sobra; as naves restantes sempre cabem na faixa.
```

### RemoverNave

Local: MOON.ASM, linha 2342.

```text
Funcao: remover uma nave uma unica vez (saida ou impacto de tiro).
Entrada: DI=offset de vaga (0,2,4). Saida: CF=1 se removeu, CF=0 se nao.
Preserva: todos os registradores. Altera: flags, atividade e navesMudou.
Nao pontua. ConferirUmDisparo soma 100 somente se CF=1 por impacto.
```

### AtualizarNaves

Local: MOON.ASM, linha 2362.

```text
Funcao: executar um passo de todas as naves ou gerar se grupo ja vazio.
Entrada: lista. Saida: X -= PASSO_NAVE; Y fixo; remover quando X+14<=0.
Altera: AX,BX,CX,DX,DI,BP,flags e dados; nao altera score/vidas/relogio.
A ultima saida permite nova geracao na proxima cadencia, nunca antes.
```

### AtualizarCadenciaNaves

Local: MOON.ASM, linha 2388.

```text
Funcao: manter cadencia independente usando a mesma amostra BIOS do laco.
Entrada: DX=tick atual (word). Saida: passo apenas apos TICKS_NAVE.
Altera: AX,BX,CX,DI,BP,flags e dados. Preserva DX para as outras cadencias.
```

### DesenharNaves

Local: MOON.ASM, linha 2406.

```text
Funcao: recompor o ceu preto atual e desenhar somente as naves ativas.
Entrada: lista/X signed/Y inteiro em 15..86, ES=video. Saida: ceu 15..99.
Altera: AX,BX,CX,DX,SI,DI,flags (DF=0), video; consome navesMudou.
Sem captura antiga: fundo uniforme da E03, fora de HUD/relevo/jipe.
DesenharQuadroPartida recompoe tiros depois deste ceu e do terreno.
```

### ReiniciarDisparos

Local: MOON.ASM, linha 2435.

```text
Funcao: limpar todos os projeteis somente na nova partida.
Entrada: nenhuma. Saida: listas/cadencias vazias, sem alterar sorteio.
Altera: DI,flags/dados. Morte e troca de grupo NAO chamam esta rotina.
```

### ProcurarVagaTiro

Local: MOON.ASM, linha 2461.

```text
Funcao: procurar uma vaga livre numa faixa sem sobrescrever tiros ativos.
Entrada: AX=offset inicial, BX=fim exclusivo (pares). Saida: DI=vaga,
CF=1 se encontrou, CF=0 se lotado. Preserva os demais registradores.
```

### DispararJipe

Local: MOON.ASM, linha 2479.

```text
Funcao: criar o par superior/frontal na posicao atual, inclusive no salto.
Entrada: jipeAtivo/X/Y, listas. Saida: ambos nascem ou nenhum (CF=1/0).
Altera: AX,BX,DI,BP,flags/dados. SI preservado. Nao altera tiros existentes.
```

### DispararNaves

Local: MOON.ASM, linha 2520.

```text
Funcao: emitir continuamente de cada nave com canhao dentro da tela.
Entrada: listas/esperaNave; uma chamada por atualizacao dos tiros.
Saida: brancos independentes das naves; cheio aguarda vaga sem substituir.
Altera: AX,BX,CX,DX,DI,BP,flags/dados. Preserva SI.
```

### TipoDoTiro

Local: MOON.ASM, linha 2560.

```text
Funcao: selecionar medidas/bitmap pela faixa fixa do tiro.
Entrada: SI=offset par valido. Saida: BX=indice 0/2/4 nas tabelas.
Preserva: demais registradores. Altera: BX,flags.
```

### SobrepoeTiroAlvo

Local: MOON.ASM, linha 2575.

```text
Funcao: sobrepor retangulos inteiros [inicio,fim), com X signed.
Entrada: SI=tiro; AX/BX=origem alvo, CX/DX=largura/altura do alvo.
Saida: CF=1 sobreposicao, CF=0 fora/bordas. Preserva registradores.
```

### ConferirUmDisparo

Local: MOON.ASM, linha 2619.

```text
Funcao: resolver um tiro, consumindo-o no primeiro impacto ou limite.
Entrada: SI=offset par valido, alvos atuais. Saida: atividade/vida/pontos.
Preserva: registradores. Altera flags/dados; CF de RemoverNave lido imediato.
Inimigo: extremidade Y+4 alcanca topo do jipe (contato incluido).
Superficie = pista Y=193; montanhas sao fundo, nao bloqueiam disparos.
```

### ConferirDisparos

Local: MOON.ASM, linha 2721.

```text
Funcao: testar tiros tambem quando apenas alvos se moveram/nasceram.
Entrada: listas atuais. Saida: impactos/limites resolvidos antes dos saltos.
Preserva: registradores. Altera flags/dados.
```

### MoverDisparos

Local: MOON.ASM, linha 2736.

```text
Funcao: mover cada tiro por passos de UM pixel, testando todo o trajeto.
Entrada: listas ativas. Saida: posicoes/distancia/impactos, sem atravessar alvo.
Altera: AX,BX,CX,SI,flags/dados. Nascimentos ocorrem depois deste movimento.
```

### AtualizarCadenciaDisparos

Local: MOON.ASM, linha 2776.

```text
Funcao: cadencia propria; mover ativos, depois emitir pares e tiros de naves.
Entrada: DX=tick BIOS. Saida: uma atualizacao se intervalo venceu.
Altera: AX,BX,CX,SI,DI,BP,flags/dados; preserva DX. Sem nova semente.
```

### TiroNaReposicao

Local: MOON.ASM, linha 2814.

```text
Funcao: impedir reposicao sobre tiro inimigo, conservando D14 (area livre).
Entrada: tiros atuais. Saida: CF=1 se X=0/Y=chao esta ocupado; CF=0 livre.
Preserva: registradores. Nao remove tiros nem concede invulnerabilidade.
```

### DesenharDisparos

Local: MOON.ASM, linha 2847.

```text
Funcao: desenhar os tres tipos por memoria sobre fundo atual recomposto.
Entrada: listas, ES=video; Y valido garantido por criacao/movimento/limites.
Saida: tiros ativos, com recorte horizontal; DF=0. Altera AX,BX,CX,DX,SI,DI.
```
