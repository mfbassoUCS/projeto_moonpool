# Checklist de aceitação pelo enunciado

**Retorno físico recebido em 06–07/11:** aluno abriu, relatou lentidão/dificuldade de salto e pediu melhoria do relevo; ainda não executou este checklist. Ajustes estão em [AJUSTES-JOGABILIDADE](AJUSTES-JOGABILIDADE.md). Retestar C08 (fluidez), J05/J09/J10, travessias e combate na versão nova. Nenhuma caixa foi automaticamente marcada como aprovada.

Preparado em 06/11/2026 a partir do [texto original do professor](planejamento/fontes/enunciado-original.md), principalmente §§3, 4, 5 e 6. **Não foi preenchido a partir dos resultados do programa.** Nenhuma caixa abaixo significa teste já realizado. Os testes automáticos existentes são evidências complementares, não substituem sua primeira execução.

## Como usar

Para cada ID, anote **P = passou, F = falhou, NT = não testado ou D = depende de esclarecimento**. Só marque a caixa ao passar e registrar evidência. Se um tipo aleatório não aparecer, marque NT; não é falha nem aprovação. Faça várias partidas e, se necessário, use depois um teste controlado identificado como tal.

Métodos: **J** = jogar com teclado físico; **M** = medir pixels/tempo ou consultar captura/memória; **C** = inspecionar fonte/origem dos dados; **D** = esclarecer com professor. Uma imagem ampliada não permite contar pixels nativos sem conhecer a escala. Não concluir dimensão exata ou velocidade numérica apenas “a olho”.

Itens de tiros são **complementares ao mínimo**, mas precisam ser verificados porque a versão completa os inclui. “Robustez” identifica verificações práticas adicionais; não inventa obrigação acadêmica. Não há exigência de cinco fases, minas, som, ranking ou vitória por distância na adaptação.

## Preparação da rodada

- [ ] P01 — **J/C:** registrar data, nomes dos testadores, computador, versão/configuração do GUI Turbo Assembler e identificação do fonte. Usar o fonte normal, não uma variante de testes.
- [ ] P02 — **J:** montar/linkar sem erro e executar no GUI Turbo Assembler/Windows, conforme §1/§5. Para passos de abertura, ler [README](README.md).
- [ ] P03 — **J:** confirmar foco na janela do jogo. Usar teclado físico nesta rodada; automação de teclas não valida esta condição.
- [ ] P04 — **M:** preparar cronômetro externo e forma de registrar foto/vídeo se surgir falha. Não alterar velocidade/duração no meio de uma medição.

## Menu inicial — §3.2

- [ ] M01 — **J:** título **Moon Patrol**, no alto, em arte ASCII e verde-claro.
- [ ] M02 — **C/M:** comprovar origem do título no TAAG e índice de cor 0Ah.
- [ ] M03 — **J:** entre título e menu aparecem jipe e os três tipos de naves.
- [ ] M04 — **J:** os quatro elementos se movem da esquerda para a direita e reaparecem à esquerda ao atingir o limite direito. Observar pelo menos duas voltas de cada um.
- [ ] M05 — **J:** opções Jogar e Sair existem, cada uma dentro de uma caixa.
- [ ] M06 — **C/M:** caixas usam bytes 218/191/192/217/196/179; cantos e lados não aparecem corrompidos.
- [ ] M07 — **J:** ↑ e ↓ permitem selecionar as duas opções, sem interromper a animação.
- [ ] M08 — **J/M:** selecionada vermelho-claro 0Ch; outra branca 0Fh; trocar a seleção atualiza ambas.
- [ ] M09 — **J:** Enter em Jogar inicia o fluxo de jogo.
- [ ] M10 — **J:** Enter em Sair encerra o programa. Executar também depois de retornar de uma partida.

## Entrada na fase e organização da tela — §3 e §6 mínimo

- [ ] F01 — **J/D:** há apresentação do setor antes da partida. O professor não especifica a aparência nem a tecla dessa tela; avaliar existência separadamente da convenção escolhida.
- [ ] F02 — **J:** existe uma única fase, pista plana para o jipe e trajetórias fixas das naves.
- [ ] F03 — **J:** status no topo, espaço lunar central e superfície na parte inferior são reconhecíveis.
- [ ] F04 — **C/M:** resolução lógica 320×200, modo 13h, memória em A000h, um byte por pixel. Não confundir tamanho da janela Windows com resolução do jogo.

## Vidas, score e tempo — §3.4.1 e §6 mínimo

- [ ] H01 — **J/D:** score à esquerda, vidas ao centro, tempo à direita, seguindo o texto; registrar que a imagem do enunciado troca score/vidas.
- [ ] H02 — **J:** ícone de vidas reflete as vidas restantes após cada morte, sem permanecer no desenho anterior.
- [ ] H03 — **M/C:** indicador de vidas 18×11 e relógio 7×8; conferir variantes 3/2/1 quando disponíveis.
- [ ] H04 — **J/M:** tempo atualiza em intervalos de um segundo; acompanhar uma sequência contínua com cronômetro e registrar atraso observado, sem inventar tolerância do professor.
- [ ] H05 — **J:** score acompanha as ações pontuáveis, permanece legível e não deixa dígitos antigos.
- [ ] H06 — **J/M:** uma partida completa termina quando a duração configurada se esgota, mesmo havendo vidas. Medir do primeiro quadro jogável ao encerramento. Se morrer antes, este teste continua NT.
- [ ] H07 — **C:** duração e intervalos de movimento são parametrizáveis. Se testar outra configuração, usar cópia identificada e depois retornar à versão normal.

O texto não fixa 90 segundos nem declara explicitamente “começar com três vidas”. Anote os valores configurados; não transforme esses valores do projeto em regras do professor. O texto alterna “decorrido” e “restante”, mas exige fim quando o tempo acaba.

## Terreno — §3.4.2 Superfície Lunar

- [ ] C01 — **J:** relevo varia ao longo do percurso, sem se resumir a uma superfície uniforme.
- [ ] C02 — **M/C:** montanhas a partir da linha 100, altura máxima 95; cenário com largura mínima 320.
- [ ] C03 — **J/M:** pista amarela plana, com 7 pixels de altura, de margem a margem.
- [ ] C04 — **J:** terreno se desloca continuamente da direita para a esquerda.
  Testar também segurando → até o jipe alcançar o limite: ele fica na metade esquerda, mas o terreno continua passando. Soltar → deve manter a rolagem. Esse subcaso não libera o jipe para atravessar a tela inteira.
- [ ] C05 — **J:** entram trechos pela direita, saem/reutilizam-se pela esquerda.
- [ ] C06 — **J:** observar pelo menos duas voltas do cenário: conexão final/início sem salto, lacuna ou interrupção perceptível.
- [ ] C07 — **J:** crateras e rochas acompanham o terreno, sem deslizar de forma independente dele.
- [ ] C08 — **J, robustez:** jipe, naves e tiros não deixam rastros, retângulos apagados ou corrupção do status. Avaliar fluidez/cintilação na máquina de apresentação.

## Jipe e salto — §Jipe e §Crateras

- [ ] J01 — **J/M:** jipe 20×10, inclusive durante movimento e salto; apoiado na pista quando no chão.
- [ ] J02 — **J:** ← e → movem o jipe nas direções corretas.
- [ ] J03 — **J/M/D:** não sai pela esquerda nem ultrapassa a metade horizontal permitida. Registrar se se mede origem ou sprite inteiro; não esconder essa convenção.
- [ ] J04 — **J/M:** velocidade horizontal do jipe superior à das naves. Comparar deslocamento em um mesmo intervalo, longe dos limites.
- [ ] J05 — **J:** ↑ inicia salto e o movimento lateral continua funcionando no ar.
- [ ] J06 — **M:** subida de 3 pixels por frame até altura máxima de 15 acima da posição normal; medir a sequência, não só a altura final.
- [ ] J07 — **M/D:** topo mantido por **5 pixels de deslocamento horizontal**. Identificar a referência usada e eventual discretização. Não aprovar cinco frames como equivalente.
- [ ] J08 — **M:** descida de 3 pixels por frame até a posição normal; trajetória trapezoidal.
- [ ] J09 — **J, robustez:** experimentar salto parado, para a direita, para a esquerda e junto aos limites; não travar no topo.
- [ ] J10 — **J, robustez:** testar pressionar/soltar, duas setas, seta+salto e seta+salto+Espaço. Registrar teclas presas, falhas de resposta ou repetição inesperada.

## Crateras — §Crateras

- [ ] O01 — **J:** observar três tipos visualmente diferentes, gerados aleatoriamente pela direita.
- [ ] O02 — **M/C:** cada cratera mede 14×7.
- [ ] O03 — **M/D:** distância horizontal mínima de 150 pixels entre consecutivas; registrar pontos de medição e testar o menor intervalo observado/controlado.
- [ ] O04 — **J:** atravessar por salto adequado sem perder vida.
- [ ] O05 — **J:** atravessar sem saltar ou pousar antes de vencer o buraco provoca perda de vida.
- [ ] O06 — **J:** superar sem colisão concede exatamente +50, uma única vez por cratera; comparar score antes/depois sem outros ganhos no intervalo.
- [ ] O07 — **J, robustez:** cratera que sai da tela sem travessia segura ou que causou morte não gera pontuação indevida.

## Rochas — §Rochas

- [ ] R01 — **J:** observar quatro tipos distintos, colocados aleatoriamente entre crateras consecutivas.
- [ ] R02 — **M/C:** cada tipo mede 12×10.
- [ ] R03 — **J:** rochas acompanham o terreno e não são posicionadas dentro das crateras.
- [ ] R04 — **J:** testar salto seguro sobre cada um dos quatro tipos; cada superação concede +50.
- [ ] R05 — **J:** colisão com área da rocha, inclusive no pouso, destrói o jipe e custa uma vida.
- [ ] R06 — **J, completo:** rocha 1 permanece após tiro; deve ser saltada.
- [ ] R07 — **J, completo:** rocha 2 desaparece imediatamente com um impacto frontal.
- [ ] R08 — **J, completo:** rocha 3 desaparece imediatamente com um impacto frontal.
- [ ] R09 — **J/D, completo:** rocha 4 permanece no primeiro impacto e é destruída no segundo consecutivo. Separar dois impactos de dois apertos da tecla; registrar interpretação de “consecutivos”.
- [ ] R10 — **J, completo:** destruir uma rocha concede +50; um impacto que não a destrói não concede esse prêmio.
- [ ] R11 — **J, robustez:** uma rocha não concede +50 repetidamente por múltiplos frames nem soma prêmio de salto e destruição para a mesma superação.

Para reconhecer os tipos na versão atual, usar [catálogo das artes](artes/previas/catalogo.png) e nomes em [artes](artes/README.md). Isso identifica o alvo do teste; não atesta fidelidade às figuras do professor.

## Naves e grupos — §3.4.2 Espaço Lunar

- [ ] N01 — **J/M:** três tipos de naves, 14×14 cada.
- [ ] N02 — **J:** aparecem pela direita e seguem para a esquerda com trajetória fixa.
- [ ] N03 — **J:** quantidade aleatória de 1 a 3 por grupo. Observar grupos dos três tamanhos ao longo de várias partidas; sorteio pode repetir.
- [ ] N04 — **J:** todas de um grupo são do mesmo tipo; os três tipos podem aparecer entre grupos, sem exigir alternância.
- [ ] N05 — **J/M:** posições vertical e horizontal variam entre grupos/sementes, respeitando os limites.
- [ ] N06 — **M/D:** conferir a restrição de “metade horizontal” de acordo com esclarecimento do professor; a frase é ambígua e deve ficar identificada.
- [ ] N07 — **J/M:** sprites inteiros entre status e relevo, no espaço de linhas 15 a aproximadamente 100; não invadem nenhuma das duas regiões.
- [ ] N08 — **M/D:** sem sobreposição e distância horizontal mínima 30 pixels entre consecutivas; registrar convenção de medição.
- [ ] N09 — **J:** saem pela esquerda e deixam de participar do jogo.
- [ ] N10 — **J:** não surge outro grupo enquanto restar nave anterior, inclusive as ainda entrando pela direita.
- [ ] N11 — **J:** depois que todas saem, novo grupo é gerado; repetir por vários ciclos.
- [ ] N12 — **J, completo:** destruir parte do grupo não libera outro; destruir a última libera nova geração. Testar também mistura de saída natural e destruição.

## Tiros do jipe — §Espaço Lunar, §Jipe e §4; complementares ao mínimo

- [ ] T01 — **J:** pressionar Espaço aciona os dois canhões simultaneamente, a partir da parte superior e frontal do jipe.
- [ ] T02 — **J:** tiro superior é amarelo e sobe verticalmente.
- [ ] T03 — **J/M:** superior atinge nave: ambos desaparecem, nave deixa de se mover/colidir/contar no grupo, score aumenta exatamente 100.
- [ ] T04 — **J/M:** superior sem alvo termina na linha 15, sem invadir status e sem pontuar.
- [ ] T05 — **J:** projéteis mantêm controle independente; atirar novamente não teletransporta/apaga o anterior sem motivo.
- [ ] T06 — **J/M:** frontal vermelho, 4 pixels de comprimento × 2 de altura, para a direita.
- [ ] T07 — **M:** frontal sem alvo desaparece depois de percorrer 50 pixels desde o disparo. Conferir parado e andando: não é x=50 na tela nem distância atual ao jipe.
- [ ] T08 — **J:** frontal atinge rocha, aplica resistência correspondente e é removido. Nenhum tiro atravessa o alvo sem aplicar a interação.
- [ ] T09 — **J, robustez:** testar disparos no chão, no topo/subida/descida e em movimento lateral; origem acompanha a posição do jipe no disparo.
- [ ] T10 — **J/C, robustez:** testar tecla mantida, toques e limite de tiros. Registrar cadência/capacidade e recusa por recarga; são decisões do projeto, não valores fixados pelo professor.

## Tiros inimigos — §Espaço Lunar e §4; complementares ao mínimo

- [ ] I01 — **J:** naves fazem disparos verticais contínuos em direção à superfície.
- [ ] I02 — **J/M:** tiro branco de 2×4.
- [ ] I03 — **J:** velocidade permite reação e esquiva real com o jipe. Registrar se os testes forem consistentemente impraticáveis, mesmo com a lógica automática aprovada.
- [ ] I04 — **J/M:** desaparece ao atingir superfície ou jipe; registrar como o projeto define superfície (pista versus relevo decorativo).
- [ ] I05 — **J/M:** extremidade inferior alcança/sobrepõe retângulo do jipe com sobreposição horizontal: ocorre colisão.
- [ ] I06 — **J:** um tiro que passa ao lado sem contato não tira vida; salto não concede invulnerabilidade automática.
- [ ] I07 — **J, robustez:** tiro já lançado mantém seu ciclo quando a nave emissora é destruída ou sai; nenhuma troca de grupo corrompe projéteis ativos.

## Morte, Game Over e nova partida — §3.5, §4 e §6 mínimo

- [ ] V01 — **J:** testar separadamente morte por cratera, rocha e tiro inimigo; jipe desaparece e desconta uma vida em cada evento.
- [ ] V02 — **J:** restando vidas, novo jipe aparece na coluna zero; conferir tempo de espera e motivo se a área estiver ocupada.
- [ ] V03 — **J:** partida continua enquanto houver vidas; morte não reinicia indevidamente score, tempo ou cenário.
- [ ] V04 — **J, robustez:** uma mesma colisão não consome todas as vidas no mesmo instante.
- [ ] V05 — **J:** ao acabar a última vida, jogo encerra e mostra GAME OVER.
- [ ] V06 — **J/M:** ao acabar o tempo com vidas restantes, encerra também. Esse caso precisa ser testado independentemente de V05.
- [ ] V07 — **J/M:** GAME e OVER centralizados em duas linhas, vermelhos, em arte ASCII; score final abaixo.
- [ ] V08 — **J:** score final corresponde ao valor alcançado naquela partida.
- [ ] V09 — **J:** qualquer tecla retorna à tela inicial; testar uma letra e uma seta em encerramentos diferentes.
- [ ] V10 — **J, robustez:** nova partida reinicializa score, vidas, tempo, jipe, objetos e tiros; menu segue funcional e Sair encerra.
- [ ] V11 — **J, robustez:** repetir o ciclo completo três vezes, conferindo teclado, cores, telas e ausência de restos de partidas anteriores.

## Código, artes e restrições — §3.1, §5, §6 e §7.5

- [ ] Q01 — **C:** Assembly 8086 compatível com GUI Turbo Assembler; montagem sem dependência de instruções posteriores.
- [ ] Q02 — **C:** impressão e ocultação de gráficos exclusivamente por endereçamento indireto/strings. BIOS usada para texto/modo não é a mesma coisa que BIOS para pixels.
- [ ] Q03 — **C:** rotinas comuns reutilizadas; não há cópias por cada variante de sprite sem justificativa.
- [ ] Q04 — **C:** constantes cobrem dimensões, posições, limites, capacidades e demais definições; tempos ajustáveis sem reescrever lógica principal.
- [ ] Q05 — **C:** cada rotina/procedimento tem cabeçalho de função, parâmetros de entrada e saída; comentários permitem entender as principais partes.
- [ ] Q06 — **C:** equipe consegue explicar conversão dos desenhos em bytes, armazenamento e manipulação na memória; ferramentas externas não substituem essa responsabilidade.
- [ ] Q07 — **C/D:** conferir adequação das artes às figuras exigidas. As atuais são autorais, autorizadas pelo aluno; sem originais/aceite do professor, não marcar reprodução fiel como comprovada.
- [ ] Q08 — **C/D:** verificar “ambas as plataformas” se o professor esclarecer outro ambiente além do GUI Turbo Assembler citado.

## Apresentação e entrega — §1 e §6 entrega

- [ ] A01 — grupo de até dois integrantes, inscrito em um dos 15 grupos da tarefa.
- [ ] A02 — data concreta do último dia de aula confirmada.
- [ ] A03 — ambos conseguem explicar as partes do código, decisões, entradas/saídas e testes sem depender do histórico de chat.
- [ ] A04 — todos os itens mínimos operacionais; pendências do completo e ambiguidades claramente registradas.
- [ ] A05 — apresentação realizada exclusivamente no GUI Turbo Assembler/Windows.
- [ ] A06 — código-fonte submetido **após** apresentação, no canal/formato pedido. Sem apresentação, não há avaliação.

## Folha de resultados

Duplique esta tabela para cada rodada. Se usar teste automatizado/de memória, identifique-o na coluna método; não substitua silenciosamente um teste físico.

| Data/testador | ID | Método/versão | Ação e condições | Observado | P/F/NT/D | Evidência ou próximo passo |
|---|---|---|---|---|---|---|
| A preencher | — | — | — | — | NT | — |

Falha reproduzível: informar tela inicial, teclas (inclusive mantidas), alvo/tipo, score/vidas/tempo antes e depois, resultado esperado e imagem/vídeo se disponível. Um evento com tiro+nave+rocha no mesmo instante pode somar ganhos; repetir isoladamente antes de concluir duplicação.

## Sugestão de sessões práticas

1. **Primeira abertura:** P, M, F, H inicial e controles J. Aprender a jogar, sem aprovar medidas exatas.
2. **Obstáculos e vidas:** O, R, V; várias partidas para ver os tipos.
3. **Naves e combate:** N, T, I; separar pontuação por evento.
4. **Duração e estabilidade:** H04/H06, V06/V10/V11 e fluidez. Se não sobreviver aos 90 s, anotar e manter essa pendência; uma variante facilitada não comprova a partida normal.
5. **Conferência técnica em dupla:** medidas M, fonte C, dúvidas D e itens acadêmicos A.

Concluir uma sessão não marca as demais como aprovadas. O critério é cobertura por requisito, não número de minutos jogados.
