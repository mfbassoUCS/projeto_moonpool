# Checklist do professor — cópia com resultados técnicos

Atualizado em **08/11/2026**, após corrigir o jogo e executar novamente a suíte completa. Resultados atuais em [CORRECOES-AUDITORIA.md](CORRECOES-AUDITORIA.md); a [análise de 07/11](ANALISE-PROJETO.md) é histórica. Preserva os **115 IDs e requisitos originais**, com métodos e observações atualizados. A [versão anterior intacta](evidencias/auditoria-2026-11-07/CHECKLIST-PROFESSOR-ANTES-REVISAO.md) também está arquivada.

**89 itens concluídos na conferência técnica; 26 permanecem abertos.** Isso não é aprovação geral do projeto nem significa que o aluno já jogou os testes. Para jogar e registrar sua experiência, use [CHECKLIST-PROFESSOR.md](CHECKLIST-PROFESSOR.md).

## Significado das caixas

- **[x] C:** conferido diretamente no código/dados, sem alegar execução física daquele caso.
- **[x] E:** comprovado em ensaio automático, memória ou captura.
- **[x] C + E:** há inspeção e execução controlada.
- **[ ] PARCIAL:** falta parte do item; não está concluído.
- **[ ] F / D:** há divergência e/ou interpretação pendente; **[ ] D:** depende do professor.
- **[ ] NT:** não testado nesta auditoria.

As etiquetas acima substituem os métodos previstos no checklist antigo pelos métodos efetivamente usados. **Uma caixa marcada fecha a conferência técnica descrita na observação, não a rodada de teclado físico.** Os passos de jogador ficam no outro arquivo. Você não precisa medir pixels enquanto joga.

**Correções concluídas:** J07 agora mede exatamente 5 pixels reais do terreno, e a suíte completa passou com as expectativas atuais. **Continuam pendentes:** rodada física, fluidez, facilidade de esquiva, partida normal de 90 segundos, três ciclos físicos, requisitos acadêmicos e esclarecimentos I04/N06/R09/Q07/Q08. A referência do topo continua sendo o terreno (D05), sem confirmação do professor. O total permanece 89/26 porque J07 foi marcado tecnicamente e I04 foi reaberto como interpretação pendente.

Fonte: `MOON.ASM`, SHA256 `13176BC9F5EF6A9123945CAC44732BB933D8511214ECD100F7EA081703025E6D`. Se o código mudar, revalidar os itens afetados. A [cópia anterior desta conferência](evidencias/correcao-auditoria-2026-11-08/antes/CHECKLIST-PROFESSOR-VERIFICADO.md) foi preservada.

## Evidências

| Código | Registro de 08/11/2026 | Alcance |
|---|---|---|
| E1 | [Resumo](evidencias/correcao-auditoria-2026-11-08/resumo.json), [montagem](evidencias/correcao-auditoria-2026-11-08/execucao/MONTAGEM.LOG), [link](evidencias/correcao-auditoria-2026-11-08/execucao/LINK.LOG) | 17 desenhos preservados, 69 rotinas e montagem sem erros/avisos. |
| E2 | [Memória/menu](evidencias/correcao-auditoria-2026-11-08/execucao/testes/N08MEM.LOG), [telas](evidencias/correcao-auditoria-2026-11-08/execucao/testes/N08TELA.LOG), [conferência](evidencias/correcao-auditoria-2026-11-08/regressao/regressao-telas.txt) | Cores, caixas, navegação sintética, setor e retorno. |
| E3 | [Combate/fluxo](evidencias/correcao-auditoria-2026-11-08/execucao/testes/E08RESUL.LOG), [conferência e quadros](evidencias/correcao-auditoria-2026-11-08/regressao) | 426 verificações, 170 quadros, teclado automatizado e fluxo de 6 s. R08/N08 também passaram. |
| E4 | [Naves](evidencias/correcao-auditoria-2026-11-08/execucao/testes/N08LOG.LOG), [resultados](evidencias/correcao-auditoria-2026-11-08/regressao/regressao-naves.txt) | 48 verificações, 4.096 sementes, 96 grupos e 40.000 pixels de terreno. |
| E5 | [Topo e trajetória](evidencias/correcao-auditoria-2026-11-08/topo/resultado.json), [regressão terrestre](evidencias/correcao-auditoria-2026-11-08/execucao/testes/R08RESUL.LOG) | 12 trajetórias com topo exato; 362 verificações terrestres e sete saltos seguros. |
| E6 | [Limite do cenário](evidencias/correcao-auditoria-2026-11-08/limite/resultado.txt) | Rolagem com/sem direita; disparos adiados só no ensaio. |
| E7 | [Falha injetada](evidencias/correcao-auditoria-2026-11-08/propagacao/resultado.json), [manifesto da suíte](evidencias/correcao-auditoria-2026-11-08/execucao/testes/execucao-suite.json) | Falha da filha interrompe as demais; fonte e saídas identificados por hash. |

As notas por ID abaixo descrevem o estado atual. A análise de 07/11 e os registros das etapas anteriores permanecem históricos. Observação baseada somente em código está marcada C. Ensaio automático não marca uma rodada humana como realizada.

## Preparação da rodada

- [ ] P01 — **PARCIAL:** registrar data, nomes dos testadores, computador, versão/configuração do GUI Turbo Assembler e identificação do fonte. Usar o fonte normal, não uma variante de testes.
  - **Registro da auditoria:** Data, fonte e ferramentas registrados; nomes dos testadores físicos, computador e configuração final da IDE ainda precisam de registro.
- [ ] P02 — **PARCIAL:** montar/linkar sem erro e executar no GUI Turbo Assembler/Windows, conforme §1/§5. Para passos de abertura, ler [README](README.md).
  - **Registro da auditoria:** TASM/TLINK distribuídos com GUI Turbo Assembler executados no Windows; não houve operação nova dos botões da IDE.
- [ ] P03 — **NT:** confirmar foco na janela do jogo. Usar teclado físico nesta rodada; automação de teclas não valida esta condição.
  - **Registro da auditoria:** Não usei teclado físico nem comprovei foco na rodada humana.
- [ ] P04 — **PARCIAL:** preparar cronômetro externo e forma de registrar foto/vídeo se surgir falha. Não alterar velocidade/duração no meio de uma medição.
  - **Registro da auditoria:** Houve Stopwatch Windows no ensaio de 6 s; preparação de cronômetro/vídeo para a partida normal segue pendente.

## Menu inicial — §3.2

- [x] M01 — **C + E:** título **Moon Patrol**, no alto, em arte ASCII e verde-claro.
  - **Registro da auditoria:** ASCII no alto e cor 0Ah; bytes coincidem com TAAG local. `EntrarMenu`.
- [x] M02 — **C + E:** comprovar origem do título no TAAG e índice de cor 0Ah.
  - **Registro da auditoria:** ASCII coincide com taag.json local e cor 0Ah foi conferida no código/captura. E1/E2; sem nova consulta externa ao TAAG.
- [x] M03 — **C + E:** entre título e menu aparecem jipe e os três tipos de naves.
  - **Registro da auditoria:** Jipe e três naves entre título e opções; +2 pixels e retorno à esquerda. 400 quadros em RAM e 320 atualizações de menu real.
- [x] M04 — **C + E:** os quatro elementos se movem da esquerda para a direita e reaparecem à esquerda ao atingir o limite direito. Observar pelo menos duas voltas de cada um.
  - **Registro da auditoria:** Jipe e três naves entre título e opções; +2 pixels e retorno à esquerda. 400 quadros em RAM e 320 atualizações de menu real.
- [x] M05 — **C + E:** opções Jogar e Sair existem, cada uma dentro de uma caixa.
  - **Registro da auditoria:** Jogar/Sair, caixas com 218/191/192/217/196/179; geometria e memória exercitadas. Aparência no monitor final requer inspeção física.
- [x] M06 — **C + E:** caixas usam bytes 218/191/192/217/196/179; cantos e lados não aparecem corrompidos.
  - **Registro da auditoria:** Jogar/Sair, caixas com 218/191/192/217/196/179; geometria e memória exercitadas. Aparência no monitor final requer inspeção física.
- [x] M07 — **C + E:** ↑ e ↓ permitem selecionar as duas opções, sem interromper a animação.
  - **Registro da auditoria:** Leitura não bloqueante, alternância por cima/baixo, seleção 0Ch e outra opção 0Fh; cores verificadas nos dumps.
- [x] M08 — **C + E:** selecionada vermelho-claro 0Ch; outra branca 0Fh; trocar a seleção atualiza ambas.
  - **Registro da auditoria:** Leitura não bloqueante, alternância por cima/baixo, seleção 0Ch e outra opção 0Fh; cores verificadas nos dumps.
- [x] M09 — **C + E:** Enter em Jogar inicia o fluxo de jogo.
  - **Registro da auditoria:** Enter inicia setor; Sair encerra, inclusive depois de retorno. Fluxos sintéticos passaram.
- [x] M10 — **C + E:** Enter em Sair encerra o programa. Executar também depois de retornar de uma partida.
  - **Registro da auditoria:** Enter inicia setor; Sair encerra, inclusive depois de retorno. Fluxos sintéticos passaram.

## Entrada na fase e organização da tela — §3 e §6 mínimo

- [x] F01 — **C + E:** há apresentação do setor antes da partida. O professor não especifica a aparência nem a tecla dessa tela; avaliar existência separadamente da convenção escolhida.
  - **Registro da auditoria:** `EntrarSetor`: SETOR 1 e Enter. Existência confirmada; aparência/tecla são escolha do projeto.
- [x] F02 — **C + E:** existe uma única fase, pista plana para o jipe e trajetórias fixas das naves.
  - **Registro da auditoria:** Uma fase, pista plana, nave com Y fixo durante a trajetória.
- [x] F03 — **C + E:** status no topo, espaço lunar central e superfície na parte inferior são reconhecíveis.
  - **Registro da auditoria:** HUD 0–14, céu 15–99, cenário desde 100 e pista 193–199; modo/memória corretos.
- [x] F04 — **C + E:** resolução lógica 320×200, modo 13h, memória em A000h, um byte por pixel. Não confundir tamanho da janela Windows com resolução do jogo.
  - **Registro da auditoria:** HUD 0–14, céu 15–99, cenário desde 100 e pista 193–199; modo/memória corretos.

## Vidas, score e tempo — §3.4.1 e §6 mínimo

- [x] H01 — **C + E:** score à esquerda, vidas ao centro, tempo à direita, seguindo o texto; registrar que a imagem do enunciado troca score/vidas.
  - **Registro da auditoria:** Score à esquerda, vidas no centro e relógio/tempo à direita. Segue o texto; a divergência com a figura permanece identificada.
- [x] H02 — **C:** ícone de vidas reflete as vidas restantes após cada morte, sem permanecer no desenho anterior.
  - **Registro da auditoria:** DesenharStatus limpa a barra e seleciona a arte de 3, 2 ou 1 vida pelo valor atual. Troca visual após cada morte ainda no roteiro do jogador.
- [x] H03 — **C + E:** indicador de vidas 18×11 e relógio 7×8; conferir variantes 3/2/1 quando disponíveis.
  - **Registro da auditoria:** `DesenharStatus`, seleciona 3/2/1 e limpa HUD; dimensões 18×11 e 7×8 verificadas.
- [ ] H04 — **PARCIAL:** tempo atualiza em intervalos de um segundo; acompanhar uma sequência contínua com cronômetro e registrar atraso observado, sem inventar tolerância do professor.
  - **Registro da auditoria:** `ConsumirTempo` acumula centésimos e retira segundos, com margem inicial de 60 ms. Ensaio de 6 s: 6,09 s DOS e 6,102 s Windows. Medição contínua normal ainda NT.
- [x] H05 — **C + E:** score acompanha as ações pontuáveis, permanece legível e não deixa dígitos antigos.
  - **Registro da auditoria:** Pontos e campos decimais de cinco dígitos; HUD é limpo antes de reimprimir. Saturação em 65.535 evita wrap.
- [ ] H06 — **PARCIAL:** uma partida completa termina quando a duração configurada se esgota, mesmo havendo vidas. Medir do primeiro quadro jogável ao encerramento. Se morrer antes, este teste continua NT.
  - **Registro da auditoria:** Encerramento por tempo passou com 6 s controlados (6,09 s DOS / 6,102 s Windows); partida normal completa de 90 s com vidas restantes não foi realizada.
- [x] H07 — **C:** duração e intervalos de movimento são parametrizáveis. Se testar outra configuração, usar cópia identificada e depois retornar à versão normal.
  - **Registro da auditoria:** Duração, passos e ticks são constantes, com diversas verificações de montagem.

O texto não fixa 90 segundos nem declara explicitamente “começar com três vidas”. Anote os valores configurados; não transforme esses valores do projeto em regras do professor. O texto alterna “decorrido” e “restante”, mas exige fim quando o tempo acaba.

## Terreno — §3.4.2 Superfície Lunar

- [x] C01 — **C + E:** relevo varia ao longo do percurso, sem se resumir a uma superfície uniforme.
  - **Registro da auditoria:** Relevo varia horizontalmente, bitmaps 320×64/320×32 e desenho desde Y=100; fica dentro da altura máxima permitida.
- [x] C02 — **C + E:** montanhas a partir da linha 100, altura máxima 95; cenário com largura mínima 320.
  - **Registro da auditoria:** Relevo varia horizontalmente, bitmaps 320×64/320×32 e desenho desde Y=100; fica dentro da altura máxima permitida.
- [x] C03 — **C + E:** pista amarela plana, com 7 pixels de altura, de margem a margem.
  - **Registro da auditoria:** Pista amarela 0Eh, sete linhas, de margem a margem, descontados os obstáculos desenhados sobre ela.
- [x] C04 — **C + E:** terreno se desloca continuamente da direita para a esquerda.
  - **Registro da auditoria:** `AvancarCenario` é independente do limite do jipe. Ensaio no limite confirmou avanço de 55 pixels com direita e 56 sem direita, em intervalos controlados próximos. E6.
  Testar também segurando → até o jipe alcançar o limite: ele fica na metade esquerda, mas o terreno continua passando. Soltar → deve manter a rolagem. Esse subcaso não libera o jipe para atravessar a tela inteira.
- [x] C05 — **C + E:** entram trechos pela direita, saem/reutilizam-se pela esquerda.
  - **Registro da auditoria:** Composição circular conferida por pixel durante duas voltas completas (640 avanços de um pixel). Ausência de interrupção perceptível na máquina final é teste físico.
- [ ] C06 — **PARCIAL:** observar pelo menos duas voltas do cenário: conexão final/início sem salto, lacuna ou interrupção perceptível.
  - **Registro da auditoria:** Composição circular conferida por pixel durante duas voltas completas (640 avanços de um pixel). Ausência de interrupção perceptível na máquina final é teste físico.
- [x] C07 — **C + E:** crateras e rochas acompanham o terreno, sem deslizar de forma independente dele.
  - **Registro da auditoria:** Obstáculos e terreno usam o mesmo `PASSO_CENARIO`; posições relativas preservadas.
- [ ] C08 — **PARCIAL:** jipe, naves e tiros não deixam rastros, retângulos apagados ou corrupção do status. Avaliar fluidez/cintilação na máquina de apresentação.
  - **Registro da auditoria:** 170 quadros de combate comparados com composição esperada, HUD e guarda íntegros; cintilação/rasgos durante a escrita e fluidez humana não são provados por dumps finais.

## Jipe e salto — §Jipe e §Crateras

- [x] J01 — **C + E:** jipe 20×10, inclusive durante movimento e salto; apoiado na pista quando no chão.
  - **Registro da auditoria:** Sprite 20×10 em todos os estados; chão em Y=183, junto da pista em 193.
- [x] J02 — **C:** ← e → movem o jipe nas direções corretas.
  - **Registro da auditoria:** AtualizarJipe aplica -5 para esquerda e +5 para direita; duas laterais juntas resultam em neutro. Teclado físico ainda no roteiro.
- [x] J03 — **C + E:** não sai pela esquerda nem ultrapassa a metade horizontal permitida. Registrar se se mede origem ou sprite inteiro; não esconder essa convenção.
  - **Registro da auditoria:** Setas corretas; origem X=0–140, último pixel até 159. Limite considera o sprite inteiro, explicitamente.
- [x] J04 — **C + E:** velocidade horizontal do jipe superior à das naves. Comparar deslocamento em um mesmo intervalo, longe dos limites.
  - **Registro da auditoria:** Jipe 5 px por tick contra nave 1 px por dois ticks. Teste de dois movimentos passou com expectativa atualizada para X=10.
- [x] J05 — **C + E:** ↑ inicia salto e o movimento lateral continua funcionando no ar.
  - **Registro da auditoria:** Salto por borda de pressão; deslocamento lateral é processado antes da etapa vertical, inclusive no ar.
- [x] J06 — **C + E:** subida de 3 pixels por frame até altura máxima de 15 acima da posição normal; medir a sequência, não só a altura final.
  - **Registro da auditoria:** Sequências Y=180,177,174,171,168 e 171,174,177,180,183 medidas nas rotinas reais.
- [x] J07 — **C + E:** topo mantido por **5 pixels de deslocamento horizontal**. Identificar a referência usada e eventual discretização. Não aprovar cinco frames como equivalente.
  - **Registro da auditoria:** Corrigido e medido no laço real: entre atingir o topo e iniciar a descida, o terreno avança exatamente 5 pixels. Doze casos em X=0/70/140 e quatro combinações laterais passaram. Referência é o terreno, conforme D05; não é deslocamento do jipe na tela nem confirmação da interpretação pelo professor. E5.
- [x] J08 — **C + E:** descida de 3 pixels por frame até a posição normal; trajetória trapezoidal.
  - **Registro da auditoria:** Sequências Y=180,177,174,171,168 e 171,174,177,180,183 medidas nas rotinas reais.
- [ ] J09 — **PARCIAL:** experimentar salto parado, para a direita, para a esquerda e junto aos limites; não travar no topo.
  - **Registro da auditoria:** Doze trajetórias automatizadas passaram, incluindo parado, esquerda, direita, duas setas e limites. Topo não trava. Conforto e modalidades com teclado físico ainda pendentes. E5.
- [ ] J10 — **PARCIAL:** testar pressionar/soltar, duas setas, seta+salto e seta+salto+Espaço. Registrar teclas presas, falhas de resposta ou repetição inesperada.
  - **Registro da auditoria:** KEY passou com nove etapas de pressão/soltura e combinações via eventos Windows/SDL/IRQ1; expectativas atualizadas para passo 5. Entrada sintética não prova resposta do teclado físico.

## Crateras — §Crateras

- [x] O01 — **C + E:** observar três tipos visualmente diferentes, gerados aleatoriamente pela direita.
  - **Registro da auditoria:** Três tipos diferentes, sorteados pela direita; bytes 14×7 conferidos.
- [x] O02 — **C + E:** cada cratera mede 14×7.
  - **Registro da auditoria:** Três tipos diferentes, sorteados pela direita; bytes 14×7 conferidos.
- [x] O03 — **C + E:** distância horizontal mínima de 150 pixels entre consecutivas; registrar pontos de medição e testar o menor intervalo observado/controlado.
  - **Registro da auditoria:** 150–230 pixels livres entre bordas; menor intervalo 150 observado no ensaio. Convenção explícita, não distância entre origens.
- [x] O04 — **C + E:** atravessar por salto adequado sem perder vida.
  - **Registro da auditoria:** Três tipos de cratera atravessados com salto seguro no R08 atual, sem perder vida; parte dos sete saltos reais conferidos. E5.
- [x] O05 — **C:** atravessar sem saltar ou pousar antes de vencer o buraco provoca perda de vida.
  - **Registro da auditoria:** ConferirObstaculos detecta sobreposição horizontal no chão, inclusive ao pousar no buraco, e chama PerderVida.
- [x] O06 — **C + E:** superar sem colisão concede exatamente +50, uma única vez por cratera; comparar score antes/depois sem outros ganhos no intervalo.
  - **Registro da auditoria:** Três tipos atravessados com +50 e sem perder vida no R08 atual. Estados de passagem impedem repetição; prêmio após pouso seguro. E5.
- [x] O07 — **C:** cratera que sai da tela sem travessia segura ou que causou morte não gera pontuação indevida.
  - **Registro da auditoria:** RetirarObstaculos não concede pontos; estados de travessia exigem cruzamento/pouso e invalidam morte. Conferência por código; a regressão terrestre também passou nesta revisão.

## Rochas — §Rochas

- [x] R01 — **C + E:** observar quatro tipos distintos, colocados aleatoriamente entre crateras consecutivas.
  - **Registro da auditoria:** Quatro tipos de 12×10, alternados com crateras e sorteados; folga mínima de 60 px em ambos os lados, verificada em geração mista.
- [x] R02 — **C + E:** cada tipo mede 12×10.
  - **Registro da auditoria:** Quatro tipos de 12×10, alternados com crateras e sorteados; folga mínima de 60 px em ambos os lados, verificada em geração mista.
- [x] R03 — **C + E:** rochas acompanham o terreno e não são posicionadas dentro das crateras.
  - **Registro da auditoria:** Quatro tipos de 12×10, alternados com crateras e sorteados; folga mínima de 60 px em ambos os lados, verificada em geração mista.
- [x] R04 — **C + E:** testar salto seguro sobre cada um dos quatro tipos; cada superação concede +50.
  - **Registro da auditoria:** Quatro tipos atravessados com salto seguro e +50 no R08 atual. Posição inicial do caso positivo ajustada à velocidade atual do jipe, sem alterar colisão do jogo. E5.
- [x] R05 — **C + E:** colisão com área da rocha, inclusive no pouso, destrói o jipe e custa uma vida.
  - **Registro da auditoria:** Colisão por retângulos, incluindo descida, mantida no jogo; verificações de colisão e perda de vida passaram na regressão atual. E5.
- [x] R06 — **C + E:** rocha 1 permanece após tiro; deve ser saltada.
  - **Registro da auditoria:** Tipo 1 consome tiro sem destruir; tipos 2/3 desaparecem com um impacto. Testes E08 passaram.
- [x] R07 — **C + E:** rocha 2 desaparece imediatamente com um impacto frontal.
  - **Registro da auditoria:** Tipo 1 consome tiro sem destruir; tipos 2/3 desaparecem com um impacto. Testes E08 passaram.
- [x] R08 — **C + E:** rocha 3 desaparece imediatamente com um impacto frontal.
  - **Registro da auditoria:** Tipo 1 consome tiro sem destruir; tipos 2/3 desaparecem com um impacto. Testes E08 passaram.
- [ ] R09 — **PARCIAL / D:** rocha 4 permanece no primeiro impacto e é destruída no segundo consecutivo. Separar dois impactos de dois apertos da tecla; registrar interpretação de “consecutivos”.
  - **Registro da auditoria:** Dois impactos na mesma rocha foram testados, mas acumulam sem prazo ou reinício por erro/morte. Falta esclarecer o sentido de consecutivos. E3.
- [x] R10 — **C + E:** destruir uma rocha concede +50; um impacto que não a destrói não concede esse prêmio.
  - **Registro da auditoria:** +50 só na destruição; primeiro impacto da rocha 4 não paga; objeto já pontuado pelo salto não paga novamente.
- [x] R11 — **C + E:** uma rocha não concede +50 repetidamente por múltiplos frames nem soma prêmio de salto e destruição para a mesma superação.
  - **Registro da auditoria:** +50 só na destruição; primeiro impacto da rocha 4 não paga; objeto já pontuado pelo salto não paga novamente.

Para reconhecer os tipos na versão atual, usar [catálogo das artes](artes/previas/catalogo.png) e nomes em [artes](artes/README.md). Isso identifica o alvo do teste; não atesta fidelidade às figuras do professor.

## Naves e grupos — §3.4.2 Espaço Lunar

- [x] N01 — **C + E:** três tipos de naves, 14×14 cada.
  - **Registro da auditoria:** Três bitmaps diferentes de 14×14.
- [x] N02 — **C + E:** aparecem pela direita e seguem para a esquerda com trajetória fixa.
  - **Registro da auditoria:** Nascimento X≥320, movimento para esquerda e Y constante.
- [x] N03 — **C + E:** quantidade aleatória de 1 a 3 por grupo. Observar grupos dos três tamanhos ao longo de várias partidas; sorteio pode repetir.
  - **Registro da auditoria:** 1–3 naves, um tipo por grupo; todas as nove combinações quantidade/tipo apareceram nas 4.096 sementes.
- [x] N04 — **C + E:** todas de um grupo são do mesmo tipo; os três tipos podem aparecer entre grupos, sem exigir alternância.
  - **Registro da auditoria:** 1–3 naves, um tipo por grupo; todas as nove combinações quantidade/tipo apareceram nas 4.096 sementes.
- [x] N05 — **C + E:** posições vertical e horizontal variam entre grupos/sementes, respeitando os limites.
  - **Registro da auditoria:** X/Y variam entre sementes e grupos; limites verificados nos arquivos binários.
- [ ] N06 — **D:** conferir a restrição de “metade horizontal” de acordo com esclarecimento do professor; a frase é ambígua e deve ficar identificada.
  - **Registro da auditoria:** Formação inteira cabe em 160 px em [320,480); não resolve a ambiguidade do enunciado.
- [x] N07 — **C + E:** sprites inteiros entre status e relevo, no espaço de linhas 15 a aproximadamente 100; não invadem nenhuma das duas regiões.
  - **Registro da auditoria:** Y=15–86, sprite até 99, pelo menos 30 pixels livres entre bordas; sem sobreposição. Convenção documentada.
- [x] N08 — **C + E:** sem sobreposição e distância horizontal mínima 30 pixels entre consecutivas; registrar convenção de medição.
  - **Registro da auditoria:** Y=15–86, sprite até 99, pelo menos 30 pixels livres entre bordas; sem sobreposição. Convenção documentada.
- [x] N09 — **C + E:** saem pela esquerda e deixam de participar do jogo.
  - **Registro da auditoria:** Remove quando X+14≤0; conta todas as ativas, inclusive fora da direita; 96 grupos mistos conferidos, sem renovação antecipada.
- [x] N10 — **C + E:** não surge outro grupo enquanto restar nave anterior, inclusive as ainda entrando pela direita.
  - **Registro da auditoria:** Remove quando X+14≤0; conta todas as ativas, inclusive fora da direita; 96 grupos mistos conferidos, sem renovação antecipada.
- [x] N11 — **C + E:** depois que todas saem, novo grupo é gerado; repetir por vários ciclos.
  - **Registro da auditoria:** Remove quando X+14≤0; conta todas as ativas, inclusive fora da direita; 96 grupos mistos conferidos, sem renovação antecipada.
- [x] N12 — **C + E:** destruir parte do grupo não libera outro; destruir a última libera nova geração. Testar também mistura de saída natural e destruição.
  - **Registro da auditoria:** Remoção de nave e contagem ativa governam o próximo grupo; destruição parcial não libera geração.

## Tiros do jipe — §Espaço Lunar, §Jipe e §4; complementares ao mínimo

- [x] T01 — **C + E:** pressionar Espaço aciona os dois canhões simultaneamente, a partir da parte superior e frontal do jipe.
  - **Registro da auditoria:** Reserva espaço nas duas listas antes de emitir o par; ambos nascem ou nenhum.
- [x] T02 — **C + E:** tiro superior é amarelo e sobe verticalmente.
  - **Registro da auditoria:** Superior amarelo sobe; nave e tiro removidos no impacto, +100 único; sem alvo, termina em Y=15.
- [x] T03 — **C + E:** superior atinge nave: ambos desaparecem, nave deixa de se mover/colidir/contar no grupo, score aumenta exatamente 100.
  - **Registro da auditoria:** Superior amarelo sobe; nave e tiro removidos no impacto, +100 único; sem alvo, termina em Y=15.
- [x] T04 — **C + E:** superior sem alvo termina na linha 15, sem invadir status e sem pontuar.
  - **Registro da auditoria:** Superior amarelo sobe; nave e tiro removidos no impacto, +100 único; sem alvo, termina em Y=15.
- [x] T05 — **C + E:** projéteis mantêm controle independente; atirar novamente não teletransporta/apaga o anterior sem motivo.
  - **Registro da auditoria:** Listas independentes e vagas fixas; disparos anteriores não são sobrescritos.
- [x] T06 — **C + E:** frontal vermelho, 4 pixels de comprimento × 2 de altura, para a direita.
  - **Registro da auditoria:** Frontal vermelho 4×2; distância própria, removido aos 50 px independentemente do X posterior do jipe.
- [x] T07 — **C + E:** frontal sem alvo desaparece depois de percorrer 50 pixels desde o disparo. Conferir parado e andando: não é x=50 na tela nem distância atual ao jipe.
  - **Registro da auditoria:** Frontal vermelho 4×2; distância própria, removido aos 50 px independentemente do X posterior do jipe.
- [x] T08 — **C + E:** frontal atinge rocha, aplica resistência correspondente e é removido. Nenhum tiro atravessa o alvo sem aplicar a interação.
  - **Registro da auditoria:** Movimento dos tiros é subdividido em passos de um pixel, verificando impactos a cada passo.
- [x] T09 — **C + E:** testar disparos no chão, no topo/subida/descida e em movimento lateral; origem acompanha a posição do jipe no disparo.
  - **Registro da auditoria:** Origem calculada com X/Y atual; ensaios de posição e de alturas passaram. Experiência com teclado físico ainda não.
- [x] T10 — **C + E:** testar tecla mantida, toques e limite de tiros. Registrar cadência/capacidade e recusa por recarga; são decisões do projeto, não valores fixados pelo professor.
  - **Registro da auditoria:** Oito superiores, oito frontais, cadência de seis ticks; tecla mantida repete, toque durante recarga pode ser descartado. Escolha do projeto.

## Tiros inimigos — §Espaço Lunar e §4; complementares ao mínimo

- [x] I01 — **C + E:** naves fazem disparos verticais contínuos em direção à superfície.
  - **Registro da auditoria:** Naves visíveis disparam continuamente na cadência; brancos de 2×4. Lista inimiga de 12 vagas.
- [x] I02 — **C + E:** tiro branco de 2×4.
  - **Registro da auditoria:** Naves visíveis disparam continuamente na cadência; brancos de 2×4. Lista inimiga de 12 vagas.
- [ ] I03 — **PARCIAL:** velocidade permite reação e esquiva real com o jipe. Registrar se os testes forem consistentemente impraticáveis, mesmo com a lógica automática aprovada.
  - **Registro da auditoria:** Inimigo nominalmente mais lento que o jipe; possibilidade confortável de reação exige jogador real.
- [ ] I04 — **PARCIAL / D:** desaparece ao atingir superfície ou jipe; registrar como o projeto define superfície (pista versus relevo decorativo).
  - **Registro da auditoria:** Código e teste consideram superfície a pista Y=193; montanhas são fundo e não bloqueiam tiros. Comportamento confirmado, mas a conformidade dessa interpretação permanece aberta. Não transformar esse limite em regra expressa do professor. E3.
- [x] I05 — **C + E:** extremidade inferior alcança/sobrepõe retângulo do jipe com sobreposição horizontal: ocorre colisão.
  - **Registro da auditoria:** Testa contato inferior e sobreposição horizontal, inclusive no salto; tiros laterais não tiram vida.
- [x] I06 — **C + E:** um tiro que passa ao lado sem contato não tira vida; salto não concede invulnerabilidade automática.
  - **Registro da auditoria:** Testa contato inferior e sobreposição horizontal, inclusive no salto; tiros laterais não tiram vida.
- [x] I07 — **C + E:** tiro já lançado mantém seu ciclo quando a nave emissora é destruída ou sai; nenhuma troca de grupo corrompe projéteis ativos.
  - **Registro da auditoria:** Tiro tem dados próprios; permanece após morte/saída da nave e mudança de grupo. Fluxo controlado confirmou tiro órfão atingindo jipe.

## Morte, Game Over e nova partida — §3.5, §4 e §6 mínimo

- [ ] V01 — **PARCIAL:** testar separadamente morte por cratera, rocha e tiro inimigo; jipe desaparece e desconta uma vida em cada evento.
  - **Registro da auditoria:** Uma rotina de morte serve para crateras, rochas e tiros. Tiro e rocha observados nesta execução; três causas em rodada física ainda pendentes.
- [x] V02 — **C + E:** restando vidas, novo jipe aparece na coluna zero; conferir tempo de espera e motivo se a área estiver ocupada.
  - **Registro da auditoria:** Reposição em X=0 apenas se livre; inatividade impede desconto repetido; morte preserva score/tempo/cenário.
- [x] V03 — **C + E:** partida continua enquanto houver vidas; morte não reinicia indevidamente score, tempo ou cenário.
  - **Registro da auditoria:** Reposição em X=0 apenas se livre; inatividade impede desconto repetido; morte preserva score/tempo/cenário.
- [x] V04 — **C + E:** uma mesma colisão não consome todas as vidas no mesmo instante.
  - **Registro da auditoria:** Reposição em X=0 apenas se livre; inatividade impede desconto repetido; morte preserva score/tempo/cenário.
- [x] V05 — **C + E:** ao acabar a última vida, jogo encerra e mostra GAME OVER.
  - **Registro da auditoria:** Game Over por última vida e por tempo exercitados em arranjos controlados. Os 90 s normais não foram medidos.
- [ ] V06 — **PARCIAL:** ao acabar o tempo com vidas restantes, encerra também. Esse caso precisa ser testado independentemente de V05.
  - **Registro da auditoria:** Game Over por última vida e por tempo exercitados em arranjos controlados. Os 90 s normais não foram medidos.
- [x] V07 — **C + E:** GAME e OVER centralizados em duas linhas, vermelhos, em arte ASCII; score final abaixo.
  - **Registro da auditoria:** GAME/OVER em duas linhas, centrados na grade de texto, cor 04h e score recebido da partida.
- [x] V08 — **C + E:** score final corresponde ao valor alcançado naquela partida.
  - **Registro da auditoria:** GAME/OVER em duas linhas, centrados na grade de texto, cor 04h e score recebido da partida.
- [x] V09 — **C + E:** qualquer tecla retorna à tela inicial; testar uma letra e uma seta em encerramentos diferentes.
  - **Registro da auditoria:** Letra e seta inseridas pelo BIOS retornaram ao menu; teste físico ainda pendente.
- [x] V10 — **C + E:** nova partida reinicializa score, vidas, tempo, jipe, objetos e tiros; menu segue funcional e Sair encerra.
  - **Registro da auditoria:** Nova partida zera score, restaura vidas/tempo, reinicia listas, jipe e cadências; Sair funcional nos fluxos exercitados.
- [ ] V11 — **NT:** repetir o ciclo completo três vezes, conferindo teclado, cores, telas e ausência de restos de partidas anteriores.
  - **Registro da auditoria:** Não houve três ciclos completos com teclado físico; os ciclos automatizados não substituem esse item.

## Código, artes e restrições — §3.1, §5, §6 e §7.5

- [x] Q01 — **C + E:** Assembly 8086 compatível com GUI Turbo Assembler; montagem sem dependência de instruções posteriores.
  - **Registro da auditoria:** Montagem 8086 e gráficos por memória confirmados.
- [x] Q02 — **C + E:** impressão e ocultação de gráficos exclusivamente por endereçamento indireto/strings. BIOS usada para texto/modo não é a mesma coisa que BIOS para pixels.
  - **Registro da auditoria:** Montagem 8086 e gráficos por memória confirmados.
- [x] Q03 — **C:** rotinas comuns reutilizadas; não há cópias por cada variante de sprite sem justificativa.
  - **Registro da auditoria:** Desenho, tabelas, colisão e pontuação reutilizados entre variantes.
- [x] Q04 — **C:** constantes cobrem dimensões, posições, limites, capacidades e demais definições; tempos ajustáveis sem reescrever lógica principal.
  - **Registro da auditoria:** Constantes abrangem medidas, limites, capacidades e tempos. Nem todo valor fora da configuração atual é garantido pelas validações; testes precisam acompanhar configurações aceitas.
- [x] Q05 — **C:** cada rotina/procedimento tem cabeçalho de função, parâmetros de entrada e saída; comentários permitem entender as principais partes.
  - **Registro da auditoria:** 69 de 69 procedimentos com função, entrada e saída.
- [ ] Q06 — **PARCIAL:** equipe consegue explicar conversão dos desenhos em bytes, armazenamento e manipulação na memória; ferramentas externas não substituem essa responsabilidade.
  - **Registro da auditoria:** Conversão grade→cores→DB/DUP e renderização verificáveis; capacidade da equipe de explicar só pode ser demonstrada.
- [ ] Q07 — **D:** conferir adequação das artes às figuras exigidas. As atuais são autorais, autorizadas pelo aluno; sem originais/aceite do professor, não marcar reprodução fiel como comprovada.
  - **Registro da auditoria:** Medidas certas não comprovam reprodução das figuras nem aceite das artes autorais.
- [ ] Q08 — **D:** verificar “ambas as plataformas” se o professor esclarecer outro ambiente além do GUI Turbo Assembler citado.
  - **Registro da auditoria:** Outra plataforma não definida/verificada.

## Apresentação e entrega — §1 e §6 entrega

- [ ] A01 — **NT:** grupo de até dois integrantes, inscrito em um dos 15 grupos da tarefa.
  - **Registro da auditoria:** Inscrição, quantidade de integrantes e data final não são demonstradas pelo código.
- [ ] A02 — **NT:** data concreta do último dia de aula confirmada.
  - **Registro da auditoria:** Inscrição, quantidade de integrantes e data final não são demonstradas pelo código.
- [ ] A03 — **NT:** ambos conseguem explicar as partes do código, decisões, entradas/saídas e testes sem depender do histórico de chat.
  - **Registro da auditoria:** Explicação oral de ambos depende da equipe.
- [ ] A04 — **PARCIAL:** todos os itens mínimos operacionais; pendências do completo e ambiguidades claramente registradas.
  - **Registro da auditoria:** Funcionalidades mínimas implementadas, topo corrigido e suíte completa aprovada tecnicamente. Restam aceitação física, artes e ambiguidades explicitadas; não é aprovação geral do trabalho.
- [ ] A05 — **NT:** apresentação realizada exclusivamente no GUI Turbo Assembler/Windows.
  - **Registro da auditoria:** Apresentação no ambiente exigido e submissão posterior não ocorreram nesta auditoria.
- [ ] A06 — **NT:** código-fonte submetido **após** apresentação, no canal/formato pedido. Sem apresentação, não há avaliação.
  - **Registro da auditoria:** Apresentação no ambiente exigido e submissão posterior não ocorreram nesta auditoria.

## Como resolver o que ficou aberto

Use o roteiro do jogador para aparência, teclas, fluidez, saltos, pontuação visível e encerramento. Dúvidas D vão para o professor. A medida exata do topo e a atualização da suíte já foram resolvidas nesta revisão. Não há tarefa de contar pixels enquanto joga. A referência D05 permanece explícita para eventual esclarecimento do professor.

Os tiros são complementares ao mínimo, mas foram incluídos porque estão implementados. Não foram acrescentadas exigências de som, ranking, cinco fases, minas ou vitória por distância.
