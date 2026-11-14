# E04 — jipe e salto

**Guia histórico da E04 (28/10/2026).** O fonte atual já inclui a E05; consulte [LEIA-E05](LEIA-E05.md). O snapshot `testes/E04BASE.ASM` e os testes E04 preservam o estado descrito abaixo. As pendências físicas de controle continuam válidas no jogo atual.

O fonte atual permite mover e saltar com o jipe sobre o cenário da E03. **Jogar → SETOR 1 → partida de 90 segundos → GAME OVER com o score da partida → menu.** O score continua zero e as vidas continuam três: obstáculos, colisões, naves da partida e tiros pertencem às próximas etapas. As artes autorais foram preservadas.

Abra `EXECUTAR-E04.cmd`, confira `MONTAGEM.LOG` e `LINK.LOG` e digite `MOON`. Na IDE, recarregue `MOON.ASM`, selecione Turbo 16-bit e use Assemble/Build/Run. Os atalhos anteriores também montam o fonte atual. O guia E03 e `testes/E03BASE.ASM` preservam o estado anterior.

## Controles e medidas

- Segure ← ou → para mover; solte para parar. As duas juntas ficam neutras.
- Pressione ↑ para saltar. Continue usando as laterais durante todas as fases.
- Manter ↑ pressionada não produz outro salto depois do pouso. Solte e pressione novamente no chão. Pressões no ar são descartadas, sem salto duplo ou pedido guardado para depois.
- O sprite permanece **20×10**, incluindo sua área transparente. Sua origem é o canto superior esquerdo.

**D08:** a metade esquerda contém as colunas 0..159. Como o último pixel do retângulo é `X+20-1`, a origem fica em **0..140**. O passo final é limitado à borda, sem circular nem desaparecer. A posição inicial é X=0.

**Apoio:** a pista começa em Y=193. Dez linhas imediatamente acima dela são 183..192; portanto `JIPE_Y_CHAO=193-10=183`. No topo, a origem é `183-15=168`; o sprite ocupa 168..177. Em nenhum momento precisa de recorte parcial, que continua ausente em `DesenharSprite`.

| Constante | Configuração | Papel |
|---|---|---|
| `PASSO_JIPE` / `TICKS_JIPE` | 3 / 1 | 3 pixels por atualização a cada tick BIOS; cerca de 54,6 px/s sem atrasos |
| `PASSO_NAVE` / `TICKS_NAVE` | 1 / 2 | Reserva para E06: cerca de 9,1 px/s; não cria naves |
| `SALTO_ALTURA` / `SALTO_PASSO` | 15 / 3 | Valores exigidos pelo professor |
| `SALTO_TOPO_PX` | 5 | Limiar de distância horizontal do topo |
| `PASSO_CENARIO` / `TICKS_CENARIO` | 2 / 2 | Rolagem da E03 preservada |
| `DURACAO_SEGUNDOS` | 90 | Relógio DOS independente dos ticks do movimento |

O montador rejeita velocidades configuradas em que `PASSO_JIPE*TICKS_NAVE <= PASSO_NAVE*TICKS_JIPE`, além de passos/intervalos inválidos. A comparação com naves em execução permanece para E06. Um **frame do jipe** aqui é uma atualização vencida de `TICKS_JIPE`; a frequência do laço de consulta não acelera o movimento. Após atraso, avança um passo, como o cenário existente, sem recuperar vários quadros em rajada.

## D05: como contar o topo

O professor exige cinco **pixels**, mas não identifica a referência dessa distância. Foi solicitada a definição; em 28/10/2026 o aluno autorizou escolher a interpretação que fizesse mais sentido. A escolha técnica implementada foi **contar o avanço do terreno enquanto o jipe está no topo**, coerente com a sensação de avanço contínuo descrita no enunciado. Não é uma confirmação do professor nem a distância líquida entre jipe e terreno.

Assim, o salto termina também parado na tela, indo à esquerda ou bloqueado numa borda. Mover o jipe na tela não aumenta nem diminui esse contador. Se o terreno não avançar, os frames do jipe sozinhos não completam o topo.

`ContarTopo` recebe em AX o número de pixels efetivamente avançados, só acumula na fase TOPO e inicia a descida ao alcançar/cruzar 5. O contador satura em 5. Com a rolagem atual de 2 pixels, as amostras são 2, 4 e 6: o quinto pixel fica entre dois quadros; a decisão ocorre na primeira amostra que o alcança. **Não há promessa de uma imagem renderizada no quinto pixel exato:** existe discretização de até um pixel nesta configuração, e a primeira descida ocorre na próxima atualização do jipe. Não se substituiu a distância por cinco frames, nem se alterou o passo do cenário para esconder esse efeito. Uma orientação diferente do professor exige rever D05.

As origens Y na subida são **180, 177, 174, 171, 168**; no topo, 168; na descida, **171, 174, 177, 180, 183**. Não há gravidade, parábola ou altura variável.

## Fluxo e rotinas para apresentar

1. `EntrarPartida` reinicia score, vidas, duração e rolagem como antes. `ReiniciarJipe` põe o jipe no chão, limpa teclas, pedido e contador do topo. Desenha cenário, jipe e HUD, instala a leitura das setas e só então toma as referências de tempo.
2. `AtualizarPartida` consulta primeiro o relógio DOS. Ao expirar, passa AX=`scorePartida` para `EntrarGameOver`. Separadamente, uma mesma amostra de ticks decide se deve atualizar terreno, jipe ou ambos.
3. Se o terreno avançou, `ContarTopo` recebe o passo em pixels. Só conta se o jipe já estava no topo antes desse avanço; a rolagem durante a subida não é incluída.
4. `AtualizarJipe` copia teclas/pedido, trata esquerda/direita com saturação e atualiza a fase vertical. Ambas as componentes continuam no mesmo frame. A rotina só altera dados, sem desenhar ou conceder pontos.
5. `DesenharQuadroPartida` apaga e redesenha se algum objeto mudou. Ao terminar, o buffer corresponde ao fundo sob a posição nova.
6. `EntrarGameOver` devolve o teclado ao BIOS, preserva AX e mostra o score recebido. Qualquer tecla volta ao menu. A saída também restaura o teclado por precaução e mantém a restauração de modo/página anterior.

`estadoSalto` usa quatro valores: CHAO, SUBINDO, TOPO e DESCENDO. `jipeX/jipeY` são a posição lógica; `jipeDesenhoX/Y` identificam a captura de fundo anterior; `jipeMudou/cenarioMudou` escolhem o desenho necessário. `pixelsTopo` mede distância. Nenhuma dessas variáveis substitui `scorePartida`, `vidas` ou `tempoRestante`.

## Por que a leitura das setas mudou

O buffer BIOS usado no menu fornece eventos de tecla, sem informar sua soltura. Isso não basta para acompanhar duas setas ao mesmo tempo e distinguir uma nova pressão de ↑ da repetição automática. Durante a partida, uma rotina curta de **INT 09h/IRQ1** registra pressionamento e soltura; menu, setor e Game Over continuam usando BIOS.

`InstalarTecladoJogo` guarda o vetor anterior com DOS AH=35h e instala o novo com AH=25h. `TecladoJogoIRQ` preserva registradores, lê o scan da porta 60h, confirma o recebimento e chama `RegistrarScanJipe`. Depois envia o fim da interrupção ao controlador e retorna com `IRET`. Não chama DOS/BIOS nem desenha dentro da interrupção. O registro de make/break pela INT 09h e a porta 60h estão descritos na [referência técnica IBM, seção INT 09h](https://bitsavers.trailing-edge.com/pdf/ibm/pc/ps2/PS2_and_PC_BIOS_Interface_Technical_Reference_Apr87.pdf#page=23).

O bit 7 do scan indica soltura; três bits em `teclasJipe` guardam as setas. Uma nova pressão de ↑ no chão gera `pedidoSalto`; repetição ou pressão no ar não gera. `PUSHF/CLI/POPF` protege apenas a cópia e limpeza desse pedido no laço principal, evitando perder uma entrada entre as duas instruções. `RestaurarTecladoJogo` devolve o vetor original antes de voltar às telas BIOS. Outras teclas não têm ação durante a partida.

## Fundo, memória e preservação da E03

Quando o terreno muda, `DesenharCenario` recompõe o fundo e elimina o jipe antigo. A captura anterior é descartada. Quando só o jipe muda, restaura-se `fundoPartida` em `jipeDesenhoX/Y`, pois esse fundo ainda pertence à rolagem atual. Depois `CapturarEDesenharJipe` guarda os 200 bytes limpos da nova posição com `SalvarFundo` e desenha com `DesenharSprite`.

Os buffers do menu não participam desse processo. Não há buffer de tela inteira, desenho de pixels por BIOS ou mudanças nos 17 bitmaps. Dados finais: **34.969 bytes (08899h)**, acréscimo de 230 sobre a E03; pilha 100h preservada. O buffer de linha do cenário continua com 320 bytes.

HUD y=0..14; montanhas desde 100; montes desde 132; base até 192; pista 193..199; rolagem módulo 320. A regressiva mantém frações DOS, margem inicial única de 6 centésimos e score real ao expirar. SETOR 1/Enter continua proposta D04.

## Reprodução e limites dos testes

Na raiz:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File testes\executar-e04.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File testes\executar-teclado-e04.ps1
python testes\conferir-e04.py
```

Não execute instâncias simultâneas. O primeiro usa TASM/TLINK e o DOSBox do GUI Turbo Assembler; testa regressão da E03, casos explícitos de salto e pixels em RAM, e depois o fluxo com ticks e relógio reais. O segundo testa a entrada por eventos Windows direcionados à janela oculta do emulador, usando SDL `windib` somente nesse processo: o backend DirectInput não aceitou `PostMessage`. Não toma o foco de outro aplicativo. Python/Pillow reconstrói dumps reais e compara com uma composição independente das grades. Esses auxiliares não são dependências do jogo. Resultados e limites efetivamente observados ficam em `testes/README.md`, `evidencias/e04/` e `planejamento/14-andamento.md`.

**Sua ação pendente:** executar Assemble/Build/Run na IDE e testar fisicamente: segurar/soltar cada lateral; ambas juntas; limites X=0 e 140; ↑ sozinho e com cada lateral; inverter direção no ar; manter ↑ até depois do pouso; soltar e saltar novamente. Observar pelo menos duas voltas do terreno e procurar rastros, cintilação ou rasgos. Comparar a contagem com cronômetro, aguardar os 90 segundos normais, conferir Game Over/score zero, reiniciar e usar Sair. A automação não comprova conforto visual nem uso físico das teclas.

A E04 termina aqui. O prompt E04 orienta a retomada desses testes/ajustes; o prompt E05 contém a passagem técnica, mas não autoriza iniciar a próxima etapa automaticamente.

Limite observado do ambiente: numa execução de teste de 45 s, o DOS mediu 45,15 s e o Windows 48,508 s; a repetição final mediu 45,177 s Windows. A causa externa não foi determinada e as rotinas do relógio não foram alteradas. O registro completo distingue essa ocorrência da medição aprovada; mantenha a comparação física com cronômetro entre as pendências.
