# E05 — obstáculos, vidas e pontuação

**Guia histórico da E05, preservada em `testes/E05BASE.ASM`.** O fonte atual está na E06, com naves implementadas; consulte [LEIA-E06](LEIA-E06.md). Os testes E05 leem o snapshot por padrão. A regressão dessas regras sobre MOON atual usa prefixo R06 e está registrada em `evidencias/e06/`.

O fonte atual acrescenta crateras, rochas, colisões, perda de vidas e pontos à E04. O ciclo é **Jogar → SETOR 1 → partida → Game Over por tempo ou vidas → menu**. O jogo começa com três vidas, score zero e 90 segundos. Não há naves na partida nem disparos. As artes da E02, a trajetória do salto e o relógio foram preservados.

Abra `EXECUTAR-E05.cmd`, confira `MONTAGEM.LOG` e `LINK.LOG` e digite `MOON`. Na GUI Turbo Assembler, recarregue `MOON.ASM`, selecione Turbo 16-bit e use Assemble/Build/Run. Os atalhos anteriores também montam o fonte atual. `testes/E04BASE.ASM` preserva a E04 anterior.

## Como jogar nesta etapa

Segure ←/→ para mover e pressione ↑ para saltar; as laterais continuam disponíveis no ar. Manter ↑ não repete o salto: solte e pressione novamente no chão. O jipe continua 20×10, X=0..140, Y chão=183, topo=168. O salto não foi alongado para facilitar os obstáculos. Para atravessar, deixe espaço à direita e avance durante o salto. Um salto parado ou junto à borda direita pode terminar sobre o obstáculo.

Cada obstáculo atravessado por salto rende **50 pontos depois do pouso seguro**. Bater custa uma vida. O jipe desaparece e retorna na coluna zero; se houver obstáculo nesse local, aguarda a área liberar. Durante a ausência, o terreno e o relógio continuam. Com zero vidas, o score real aparece no Game Over. Qualquer tecla volta ao menu; Enter em Sair encerra.

## Regras e escolhas técnicas

O professor exige três crateras 14×7, quatro rochas 12×10, geração pela direita, distância mínima de 150 entre crateras, rochas entre crateras, movimento com o terreno, +50 por superação, perda de uma vida e reposição em X=0. A E05 reutiliza os sete bitmaps autorais existentes. A resistência a tiros continua para E08; todas as rochas podem ser saltadas nesta etapa.

As convenções abaixo são **escolhas técnicas desta implementação**, autorizadas pelo pedido de tratar D07/D14/D15; não são respostas do professor. D05 continua a escolha técnica delegada pelo aluno na E04: topo contado pelo avanço do terreno, limiar 5 pixels, amostras 2/4/6, até 1 pixel de discretização, descida na atualização seguinte do jipe. D04 permanece SETOR 1/Enter provisório.

| ID | Convenção implementada |
|---|---|
| D07, crateras | Medir o espaço livre entre bordas. Para origens A e B, `B − (A+14) >= 150`. Sorteio de 150..230 pixels livres; distância entre origens de 164..244. Convenção de naves ainda pendente para E06. |
| D07, rochas | Exatamente uma rocha por intervalo planejado entre duas crateras, com posição e tipo sorteados. Pelo menos 60 pixels livres de cada lado. A cratera seguinte pode ainda estar fora da tela, mas sua posição já está definida pelo gerador. |
| D15, horizontal | Intervalos semiabertos: jipe `[X,X+20)`, cratera `[X,X+14)`, rocha `[X,X+12)`. Há contato perigoso quando compartilham ao menos uma coluna; bordas apenas encostadas não se sobrepõem. |
| D15, cratera | É um buraco em Y=193..199. Sobreposição horizontal com o jipe no chão, Y=183, mata. Em Y<183, não há apoio sobre o vazio. Pousar ainda sobre a cratera mata. |
| D15, rocha | É sólida em `[183,193)`. Com sobreposição horizontal, mata quando `jipeY+10 > 183`. Y=173 é seguro; Y=174 já sobrepõe uma linha. Usa retângulos inteiros, inclusive margens transparentes, sem colisão por cor/pixel. |
| D14 | Um evento torna o jipe inativo e desconta uma vida. Tenta repor no próximo tick do jipe, somente se `[0,20)` estiver livre. Não remove obstáculos nem concede invulnerabilidade; todos continuam colidindo, inclusive os já pontuados. |

Essa colisão geométrica é conservadora. A janela de salto da rocha é estreita com a altura/cadência obrigatórias preservadas: os testes demonstram uma travessia possível com avanço, mas o conforto do controle precisa de avaliação física. Uma orientação diferente do professor sobre área de contato exige rever D15 explicitamente.

## Dados e geração, para apresentar

Há três vetores de oito palavras: `obstX`, `obstTipo` e `obstPassagem`. O mesmo índice DI=0,2,...14 seleciona posição, tipo e progresso do mesmo obstáculo. `OBST_LIVRE=FFFFh` identifica uma vaga; tipos 0..2 são crateras e 3..6 são rochas. X tem sinal, permitindo entradas e saídas parciais. Tabelas pequenas associam o tipo à largura, altura, Y e endereço do bitmap.

`ReiniciarObstaculos` limpa a lista somente numa nova partida e usa ticks BIOS como semente. `Sortear(CX=limite)` faz `semente = (semente*25173+13849) mod 65536`, usa o byte alto e devolve o resto da divisão pelo limite. É pseudoaleatório simples, sem tentativas infinitas. Usar o byte alto evita que a sequência alternada de chamadas faça os tipos de rocha repetirem os bits baixos do gerador. Não é necessário nenhum arquivo externo no EXE.

`AvancarObstaculos` subtrai exatamente `PASSO_CENARIO` de todas as posições quando o terreno avança. Um contador em pixels determina o próximo nascimento. Ao gerar uma cratera, sorteia o espaço até a próxima e a posição da rocha intermediária. Depois alterna rocha/cratera. A sobra negativa do contador entra na posição inicial: evita alterar o espaçamento quando um nascimento cai entre amostras de dois pixels. O primeiro objeto começa na coordenada de mundo 320.

`RetirarObstaculos` libera uma vaga quando o retângulo inteiro saiu pela esquerda. Isso não dá pontos. Se uma travessia completa ainda espera o pouso, o registro é conservado fora da tela até a confirmação ou morte. A capacidade de oito entradas tem folga para essa configuração; nenhuma entrada ativa é sobrescrita. Passos cuja soma `PASSO_CENARIO+PASSO_JIPE` exceda 12 são rejeitados pelo montador, para evitar atravessar obstáculos entre consultas sem testar contato. Alterações amplas das constantes exigem repetir os testes de geração e colisão.

## Colisões, travessias e vidas

`ConferirObstaculos` primeiro percorre **todas as colisões**. Na primeira, marca o obstáculo como inválido para pontuação e chama `PerderVida`, encerrando a consulta. Mesmo dois obstáculos sobrepostos num arranjo de teste custam só uma vida. Somente se nenhum contato fatal existir percorre a pontuação.

Cada obstáculo acompanha esta sequência:

1. `PASS_NOVO`: ainda sem prova de aproximação.
2. `PASS_FRENTE`: esteve inteiramente à frente do jipe.
3. `PASS_SOBRE`: houve sobreposição horizontal durante o salto.
4. `PASS_CRUZOU`: o jipe ficou inteiramente à direita; espera pousar.
5. `PASS_PONTO`: pousou sem colisão, recebeu +50 uma vez.

Recuar para antes do obstáculo volta à aproximação. Reentrar sobre ele durante o mesmo salto exige completar a travessia de novo. `PASS_INVALIDO` impede pontos para o obstáculo fatal e para travessias interrompidas por uma morte. Surgir sobre um obstáculo, passar por baixo de um salto incompleto, sair da tela ou atravessar no sentido inverso não bastam para pontuar. Todos os marcadores continuam sujeitos a colisão: pontuação não desativa o obstáculo.

`SomarPontos(AX=ganho)` centraliza a soma, marca o HUD para atualização e satura em **65535**, evitando voltar a zero por overflow. O formato de cinco dígitos e a interface word foram mantidos. A configuração normal fica muito abaixo desse teto; a proteção também serve para futuras fontes de pontos. E08 deve reutilizar essa rotina e impedir pontuar uma rocha duas vezes.

`PerderVida` não chama `EntrarPartida` nem `ReiniciarJipe`. Preserva score, tempo restante, frações, margem do relógio, rolagem, posições e estado do gerador. Cancela o pedido de salto e as travessias em curso. `TentarReporJipe` muda apenas posição, fase e contador do topo quando o local está livre. Mantém os bits físicos das teclas: lateral ainda segurada volta a mover no tick seguinte; ↑ ainda segurada não vira um novo salto. Uma pressão durante a ausência também não fica enfileirada.

## Fluxo e desenho

`EntrarPartida` reinicia a sessão inteira, o jipe e os obstáculos, desenha cenário/obstáculos/jipe/HUD, instala IRQ1 e toma a referência do relógio. `AtualizarPartida` mantém a ordem: relógio → terreno e obstáculos → jipe ou tentativa de reposição → colisões/pontos → retirada de objetos → HUD → desenho. Tempo zero ou vidas zero chamam `EntrarGameOver(AX=scorePartida)`, que restaura o vetor do teclado.

Ao rolar, `DesenharQuadroPartida` recompõe cenário e obstáculos antes de capturar/desenhar o jipe. Isso também apaga as áreas anteriores dos obstáculos. Sem rolagem, restaura apenas o fundo atual de 200 bytes sob o jipe. `jipeNaTela` indica se existe uma captura a restaurar; `jipeAtivo` decide se deve desenhá-lo novamente. Não se usam fundos antigos ou do menu.

`DesenharSpriteRecortado` acrescenta recorte **horizontal**: descarta as colunas fora da tela na origem e mantém o passo original entre linhas do bitmap. Somente a região visível é escrita por memória em ES. O Y precisa caber inteiro. `DesenharSprite` original mantém seu contrato sem recorte, usado pelo jipe/menu/HUD. Preto 00h continua opaco; FFh continua transparente.

Dados finais: **35.072 bytes (08900h)**, aumento de 103 sobre a E04. Permanecem o buffer de cenário de 320 bytes, fundo do jipe de 200 e pilha 100h. Não há buffer de tela inteira no jogo. Os buffers grandes existem somente nos testes.

## Reprodução e alcance da validação

Na raiz, execute sequencialmente:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File testes\executar-e05.ps1
python testes\conferir-e05.py
```

O executor monta MOON e variantes com TASM/TLINK no DOSBox incluído na GUI Turbo Assembler. Os testes de RAM usam cycles=50000 e o fluxo real usa cycles=auto. O conferidor lê dados produzidos pela execução e compara os pixels com as grades autorais, independentemente das rotinas de desenho. Python/Pillow são auxiliares de teste, sem dependência do EXE. Logs, hashes e resultados efetivos estão em `testes/README.md`, `evidencias/e05/verificacao.txt` e `planejamento/14-andamento.md`.

Os testes incluem regressão E03/E04, trajetórias reais para os sete tipos, contatos/pousos, pontuação única e saturação, reposição e teclas mantidas, geração por 20.000 pixels, recorte e recomposição, morte natural pelo laço real, última vida, expiração, reinício e saída. Teclas das telas são inseridas pelo BIOS e as de movimento nos testes lógicos são scans sintéticos. Isso não equivale ao teclado físico.

## Sua ação pendente

Na IDE, montar e executar o fonte atual pelos botões. Testar fisicamente segurar/soltar laterais, ambas juntas, ↑ e laterais simultâneas, inversão no ar, bordas, ↑ mantida depois de pousar/morrer e novo salto após soltura. Atravessar os sete tipos com avanço, observar +50 somente no pouso e nenhuma repetição; provocar colisão no chão e no pouso, conferir 3→2→1→Game Over, reaparecimento em X=0, espera se ocupado e continuidade do tempo/score/terreno. Conferir menu, reinício e Sair.

Observar aparência, rastros, cintilação/rasgos e fluidez durante várias gerações e duas voltas. Avaliar especialmente a janela de salto das rochas. Comparar o relógio com cronômetro externo; tentar sobreviver à duração normal de 90 segundos para conferir o encerramento por tempo. A regressão automática comprova a rotina do relógio e uma expiração curta, não a experiência física de uma sessão normal. A diferença DOS/Windows ocasional observada na E04 continua registrada, sem causa externa determinada.

A E05 para aqui. Para validação ou correções, use o prompt de retomada E05. O prompt E06 foi ajustado ao estado atual, mas naves só começam mediante novo pedido.
