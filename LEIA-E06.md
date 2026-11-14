# E06 — grupos de naves

**Guia histórico da E06, preservada em `testes/E06BASE.ASM`.** O fonte atual está na integração E07; consulte [LEIA-E07](LEIA-E07.md). As regras de naves abaixo permanecem, e a suíte E07/R07 as reexecuta no MOON atual. Os auxiliares E06 leem seu snapshot por padrão.

A E06 acrescenta à partida os três tipos de naves 14×14 já desenhados na E02. Elas entram pela direita em grupos aleatórios de uma, duas ou três do mesmo tipo e seguem para a esquerda, cada uma numa altura fixa. O próximo grupo espera todas as anteriores saírem. Tipos podem se repetir. Não há disparos nem pontos por simplesmente sair da tela.

Abra `EXECUTAR-E06.cmd`, confira `MONTAGEM.LOG`/`LINK.LOG` e digite `MOON`. Na GUI Turbo Assembler, recarregue `MOON.ASM`, selecione Turbo 16-bit e use Assemble/Build/Run. Os atalhos antigos também montam o MOON atual. `testes/E05BASE.ASM` preserva exatamente a E05 anterior.

Continuam três vidas, 90 segundos, score inicial zero, ←/→ e ↑ para o jipe. Mantêm-se salto, obstáculos, +50 no pouso seguro, espera pela área livre ao morrer, relógio e Game Over. SETOR 1/Enter continua a proposta D04. A E07 não foi iniciada.

## Regras e convenções

O professor determina três tipos 14×14, grupos de 1..3 do mesmo tipo, posições aleatórias, movimento fixo para a esquerda, distância mínima 30, respeito ao espaço lunar e bloqueio de outro grupo enquanto restar uma nave. O pedido da E06 autoriza tratar D06/D07/D09. As escolhas abaixo são interpretações técnicas, sem confirmação do professor:

| Decisão | Implementação |
|---|---|
| D06, metade horizontal | A formação inteira cabe numa faixa de **160 pixels** inicialmente fora da direita: `[320,480)`. A referência ambígua à metade foi interpretada como extensão da formação. Não se limita o percurso à metade direita: elas atravessam a tela até sair pela esquerda. |
| D06, entrada | Primeira origem X=320..335. As demais ficam mais à direita, com espaçamento sorteado. O último retângulo termina até X=480, exclusivo. Todas começam ativas, inclusive fora da tela. Depois entram gradualmente, com recorte; não aparecem instantaneamente no centro. |
| D07, naves | Pelo menos **30 colunas livres entre bordas**: `Xseguinte − (Xanterior+14) >= 30`. Logo, origens distam pelo menos 44. Como todas têm a mesma velocidade, a distância se conserva e não há sobreposição, mesmo com Y igual. D07 de crateras/rochas não mudou. |
| D09 | Céu `[15,100)`: origem Y=15..86, último pixel Y+13≤99. HUD ocupa 0..14; relevo começa em 100. Y não muda durante o percurso. |
| Cadência | `PASSO_NAVE=1`, `TICKS_NAVE=2`, conforme reserva da E04. Jipe continua 3 px/1 tick. A assertiva por multiplicação cruzada exige que o jipe seja mais rápido. Valores absolutos são escolhas técnicas. |
| Saída | Remover quando `X+14 <= 0`, portanto X≤−14. Em X=−13 ainda existe uma coluna do retângulo na tela. Saída não pontua. Novo grupo nasce na próxima atualização das naves após a última remoção. |

Se vier orientação diferente do professor sobre D06, ela deve ser registrada antes de alterar a faixa. A decisão atual não é apresentada como interpretação única do texto.

## Dados e sorteio, para apresentar

Três vetores de três palavras guardam `naveX`, `naveY` e `naveAtiva`. O índice DI=0,2,4 seleciona a mesma nave em cada vetor; cada palavra ocupa dois bytes. X tem sinal para representar a saída pela esquerda. `naveTipo` é compartilhado pelo grupo, garantindo homogeneidade sem copiar a lógica para cada arte.

São três conceitos diferentes: `NAVE_MAX=3` é a capacidade; `naveQuantidade` é o número originalmente sorteado; `ContarNavesAtivas` conta quantas continuam ativas agora. A geração consulta a atividade real, inclusive das naves que ainda esperam fora da borda direita. Remover duas de um grupo de três não libera o próximo.

`Sortear(CX=limite)` continua o LCG da E05: `semente=(semente*25173+13849) mod 65536`, seguido do byte alto e do resto por CX. Seu contrato ficou explícito: **1..256**. Todos os limites usados na E06 cabem nessa faixa; não houve ampliação ou troca do gerador. A semente vem dos ticks somente em `ReiniciarObstaculos`, durante a nova partida; `ReiniciarNaves`, remoções e novos grupos não semeiam novamente. Os testes usam sementes conhecidas só nas variantes.

`GerarGrupoNaves` constrói posições válidas, sem tentar até dar certo:

1. Sorteia quantidade e tipo, independentemente do tipo anterior.
2. Reserva a largura das naves e os intervalos mínimos. Sobra `160 − quantidade×14 − (quantidade−1)×30`.
3. Sorteia o deslocamento inicial 0..15, descontando-o da sobra. Assim a primeira nave começa logo perto da entrada.
4. Sorteia o Y de cada nave. Para cada nave seguinte, sorteia um acréscimo entre zero e a sobra restante, desconta-o e avança X por `14+30+acréscimo`.

Exemplo com três naves: larguras e intervalos ocupam 102 pixels, deixando 58. Se a entrada consome 8, sobram 50. Um intervalo usa 20 extras e o outro 10; as origens ficam 328, 392 e 446, todas dentro da faixa. O restante pode ficar vazio à direita. O sorteio por resto é pseudoaleatório simples; não promete distribuição perfeitamente uniforme.

## Fluxo e rotinas

`EntrarPartida` mantém o reset anterior e acrescenta `ReiniciarNaves` → `GerarGrupoNaves` → desenho do céu. Ao terminar o primeiro quadro, toma a mesma referência de tick para cenário, jipe e naves.

`AtualizarPartida` consulta o relógio e os ticks, atualiza as naves na própria cadência e mantém o fluxo anterior de terreno, jipe/reposição, colisões/pontos, HUD e desenho. Morrer não reinicia as naves. O término por tempo/vidas continua restaurando IRQ1 e levando o score real ao Game Over.

| Rotina | Entrada e efeito |
|---|---|
| `ReiniciarNaves` | Limpa as três vagas e a cadência, sem mudar a semente. Somente nova partida. |
| `ContarNavesAtivas` | Devolve AX=0..3; preserva os demais registradores. |
| `GerarGrupoNaves` | Confere lista vazia e constrói quantidade, tipo e posições. Não sobrescreve nenhuma nave ativa. |
| `AtualizarCadenciaNaves` | Recebe DX=tick da consulta; executa um passo após dois ticks e preserva DX para as outras cadências. |
| `AtualizarNaves` | Gera se já estava vazio; senão subtrai o passo de X e retira quem saiu inteiro. Não altera Y, score ou vidas. |
| `RemoverNave` | Recebe DI=0/2/4. CF=1 somente na primeira remoção válida; CF=0 se já inativa ou índice inválido. Preserva registradores, marca o céu para redesenhar e não pontua. |
| `DesenharNaves` | Recompõe o céu e desenha apenas as ativas com `DesenharSpriteRecortado`. Consome `navesMudou`. |

Em E08, um impacto poderá chamar `RemoverNave`, conferir CF imediatamente e chamar `SomarPontos(AX=100)` somente se removeu por tiro. Essa interface foi preparada e testada; os tiros não foram implementados. A futura colisão deve consultar `naveAtiva`.

## Desenho e memória

O céu atual é preto uniforme. Quando uma nave nasce, move ou é removida, `navesMudou=1`. `DesenharQuadroPartida` recompõe **somente a faixa Y=15..99** com `REP STOSB` e desenha as naves ativas por memória. Isso apaga todas as áreas anteriores, inclusive quando cenário e jipe não mudam. Não há captura de fundo de nave nem restauração de céu antigo. HUD e relevo ficam fora dessa faixa.

Na parte inferior permanece a composição da E05: cenário → obstáculos → captura/jipe quando há rolagem; restauração do fundo atual do jipe nos outros quadros. A rotina de recorte continua preservada, com X signed, recorte horizontal, FFh transparente e 00h opaco. Y sempre cabe inteiro. A E08 deverá incluir os projéteis na composição do céu para que essa limpeza não apague tiros ativos.

Dados finais: **35.100 bytes (0891Ch)**, aumento líquido de 28 bytes; sete rotinas novas e integração em três existentes. Os buffers continuam 320 bytes para cenário e 200 para fundo do jipe, pilha 100h. Sem buffer de tela inteira ou dependência nova no EXE. As 17 artes e 48 rotinas anteriores ficaram idênticas, verificação feita pelo conferidor.

## Validação executada

Na raiz, em sequência, sem outra instância dos testes:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File testes\executar-e06.ps1
python testes\conferir-e06.py
```

O executor gera variantes de MOON e monta/executa TASM 4.1/TLINK 7.1.30.1 no DOSBox 0.74-3 incluído na GUI Turbo Assembler 5.1. RAM usa `cycles=50000`; o fluxo real restaura `auto`. Python/Pillow são auxiliares dos testes, não do jogo. O conferidor valida hashes e reconstrói imagens a partir de memória realmente produzida pelo ASM.

- **E06LOG:** 48 verificações explícitas de remoção única/inválida, bloqueio com última nave fora ou parcialmente na tela, saída, ausência de pontos, cadência, retorno do contador de ticks e jipe mais rápido. 4.096 sementes cobriram as nove combinações quantidade/tipo e os extremos de Y, entrada e faixa.
- **Geração intercalada:** 20.000 passos, 48 grupos, 20 repetições consecutivas de tipo; 394 obstáculos em 40.000 pixels, todos os tipos e distâncias válidos. A data de cada nascimento de grupo confirma que esperou a última saída completa. A quantidade de chamadas aleatórias não eliminou a variedade dos obstáculos.
- **E06PIX:** 390 quadros × 65.000 bytes, 25.350.000 comparações independentes. Três artes, Y extremos, entrada/saída parcial e total, movimento só das naves, só do jipe, remoção, rolagem, jipe ausente, HUD e guarda de 1.000 bytes. DF conferido após entradas com `STD`.
- **Regressão R06:** testes E03/E04/E05 sobre o fonte atual, com nomes separados para preservar evidências antigas. Incluem salto D05, 362 verificações terrestres, 336 quadros, vidas/pontos, relógio, IRQ e saída.
- **Laço real R06AUTO:** 167 passos das naves por ticks BIOS; grupo preservado durante morte/reposição e reiniciado na nova partida. Primeira morte natural em 19,28 s DOS; tempo 71→69 durante reposição; expiração curta separada em 4,12 s. Dois dumps reais do céu conferidos com os dados das naves. Teclas das telas entram pelo BIOS, sem teclado físico.

Resultados, contagens e hash em `evidencias/e06/verificacao.txt`; regressão em `evidencias/e06/regressao/verificacao.txt`. As imagens `repo.png`, `mort.png` e `quadro-*.png` são dumps reconstruídos. Algumas usam poses e HUD de teste, não a aparência normal da partida.

## O que depende de você

Na IDE, monte e execute pelos botões. Observe as naves entrando e saindo parcialmente, alturas fixas, espaçamento, homogeneidade e espera pela última. Com a velocidade normal, uma formação pode levar cerca de 37..53 segundos para atravessar quando a cadência é cumprida; observar todas as combinações pode exigir várias partidas. Tipos repetidos são permitidos.

Teste fisicamente setas mantidas/simultâneas, soltura de ↑, saltos com avanço, mortes, reposição, pontos no pouso, reinício e Sair. Avalie conforto, fluidez, cintilação/rasgos e aparência; a recomposição de 27.200 bytes de céu por atualização foi conferida em memória, mas não comprova conforto visual. Compare uma sessão normal de 90 s com cronômetro externo, sobrevivendo aos obstáculos. Não foi repetido o teste de eventos Windows da E04 nem testada a sessão física de 90 s.

Registre problemas usando `planejamento/prompts/E06-grupos-de-naves.md`. A próxima etapa possível é E07, com prompt atualizado, somente mediante novo pedido. Não há pendência de implementação conhecida na E06; a validação física continua pendente.
