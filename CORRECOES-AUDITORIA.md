# Correções após a auditoria independente — 08/11/2026

Foram aplicadas as correções técnicas justificadas pela [auditoria recebida](evidencias/correcao-auditoria-2026-11-08/AUDITORIA-INDEPENDENTE-MOON-PATROL.md). O jogo foi recompilado e a suíte completa, incluindo os conferidores e o teclado automatizado, passou. Os resultados antigos de 07/11 foram preservados como histórico.

## O que mudou no jogo

**J07 — topo do salto:** o terreno passou de 2 pixels a cada 2 ticks para **1 pixel a cada tick**. A velocidade média nominal continua igual. Agora o terreno percorre 1, 2, 3, 4 e 5 pixels durante o topo, e a descida começa no quinto; não há avanço de 6 disfarçado por um contador limitado a 5.

A referência continua sendo **o avanço do terreno**, decisão D05 já adotada no projeto. Não foi trocada pela distância percorrida pelo jipe na tela. Isso permite terminar o salto também parado, andando à esquerda ou encostado num limite. A interpretação do enunciado continua explícita: não é alegação de que o professor confirmou essa referência.

O montador agora rejeita configurações de passo/cadência que impeçam atingir esse limite exatamente e iniciar a descida na atualização correspondente. Jipe continua com passo lateral 5, altura máxima de salto 15 e subida/descida de 3. Dimensões, pontuação, vidas e duração normal de 90 segundos foram mantidas.

Medição pelo **laço real `AtualizarPartida`**, com ticks controlados:

| Momento | Tick | Rolagem | Y do jipe |
|---|---:|---:|---:|
| Atingiu o topo | 5 | 5 | 168 |
| Última atualização antes de descer | 9 | 9 | 168 |
| Começou a descer | 10 | 10 | 171 |
| Voltou ao chão | 14 | 14 | 183 |

Distância real entre atingir o topo e começar a descer: **10 − 5 = 5 pixels de terreno**. O teste passou nas 12 combinações de X inicial 0/70/140 com nenhuma tecla lateral, esquerda, direita ou ambas. [Dados completos](evidencias/correcao-auditoria-2026-11-08/topo/resultado.json).

## O que mudou nos testes

- Expectativas antigas de deslocamento 3/6 passaram a usar `PASSO_JIPE` e seus múltiplos. A verificação de que o jipe é mais rápido que as naves foi mantida.
- O teste de salto sobre rocha passou a começar com espaço para ganhar altura, em vez de insistir num arranjo que agora realmente colide. Testes de contato/perda de vida continuam presentes; colisões não foram desativadas no jogo.
- A geração percorre a mesma distância total independentemente do passo do cenário. O teste de cenário continua exigindo duas voltas completas.
- Para o fonte atual, comparação textual com versões antigas foi substituída por conferência das medidas obrigatórias, bytes dos desenhos atuais, cabeçalhos e resultados de execução. Os conferidores de pixels e geometria continuam ativos.
- Cada BAT limpa sua confirmação antiga de sucesso. O pai também limpa a confirmação do filho antes de chamá-lo e só continua se uma confirmação nova existir. **Falha em R08 interrompe N08 e E08.**
- Um ensaio com falha injetada e arquivos `PASS` antigos demonstrou a propagação: os três logs terminaram em `FAIL`, sem resultado global de aprovação. Isso ocorreu numa cópia isolada, não na suíte normal. [Evidência](evidencias/correcao-auditoria-2026-11-08/propagacao/resultado.json).
- Os executores removem os resultados conhecidos da rodada anterior e registram o hash do fonte e dos arquivos produzidos. O conferidor rejeita execução incompleta, fonte diferente ou resultado alterado.
- Os fluxos da suíte usam os 50.000 ciclos da configuração atual. O caso de combate que exige exatamente uma morte emite um tiro inimigo real e adia os seguintes apenas naquele arranjo. A emissão repetida permanece testada separadamente.

## Verificações novas

| Parte | Resultado de 08/11 |
|---|---|
| Fonte normal | TASM/TLINK sem erros ou avisos; novo `MOON.EXE` gerado. |
| Cenário/jipe | Duas voltas completas do cenário; 80 estados e 640 quadros do jipe. |
| Obstáculos | 362 verificações, saltos seguros dos sete tipos, colisões, pontos, morte natural, reposição, fim e reinício. |
| Naves | 48 verificações, 4.096 sementes, 96 grupos mistos e 40.000 pixels de geração de terreno. |
| Pixels | 336 quadros terrestres, 390 de naves e 170 de combate comparados com o desenho esperado e guardas de memória. |
| Menu/telas | 400 quadros em memória, 320 atualizações de menu, setor, seleção, Game Over, retorno e Sair. |
| Combate | 426 verificações de tiros, resistência, alcance, pontuação e independência. |
| Teclado automático | Pressão/soltura, direções simultâneas, novo salto, Espaço no ar e retorno ao BIOS passaram por Windows → SDL → IRQ1. Não é teclado físico. |
| Relógio | Ensaio controlado de 6 s: 6,09 s DOS / aproximadamente 6,102 s Windows. Não substitui partida normal completa. |
| Topo | Cinco pixels reais de terreno, em 12 casos usando o laço de partida. |
| Limite direito | Jipe em X=140; terreno/rocha continuam com direita mantida e após soltar. |

[Relatório da suíte completa](evidencias/correcao-auditoria-2026-11-08/regressao/verificacao.txt), [resumo e hashes](evidencias/correcao-auditoria-2026-11-08/resumo.json), [arquivos da execução arquivados](evidencias/correcao-auditoria-2026-11-08/execucao).

## O que a auditoria pede esclarecer, sem fornecer uma correção determinada

| Item | Comportamento atual / encaminhamento |
|---|---|
| Q07 — artes | Os 17 bitmaps foram preservados. Jipe, naves e HUD são autorais, com medidas conferidas. O MD recebido não contém as figuras originais; não há base para reproduzi-las fielmente ou declarar aceite do professor. |
| I04 — superfície | Tiros inimigos param no jipe ou na pista amarela; atravessam o relevo decorativo. A cópia técnica agora deixa **I04 aberto com ressalva de interpretação**. Não foi adicionada colisão com montanhas sem uma regra definida. |
| R09 — consecutivos | Mantidos dois impactos acumulados na mesma rocha, sem prazo ou reinício por erro/morte. A observação dessa regra não equivale a esclarecer a palavra do enunciado. |
| N06 — metade horizontal | Mantida a formação com largura máxima de 160 pixels, nascendo fora da margem direita. Referência continua explícita. |
| Q08 — plataformas | Ferramentas locais do GUI Turbo Assembler no Windows foram usadas; segundo ambiente não foi especificado. |

Esses pontos não foram transformados em novas decisões obrigatórias para o jogador. O projeto mantém suas convenções; a ressalva separa essas escolhas da confirmação do professor.

## O que você precisa retestar no checklist

Feche a janela antiga, monte o fonte atualizado e abra a nova partida. No [checklist do jogador](CHECKLIST-PROFESSOR.md), priorize:

1. **Seção 3 — cenário e salto:** salto parado, para os lados e nos limites; o jipe deve voltar ao chão e o terreno continuar passando. Observe se a rolagem ficou fluida.
2. **Seção 4 — obstáculos:** repita saltos sobre crateras e os quatro tipos de rocha, procurando espaço para avançar. Confira +50 após pousar seguro e uma vida perdida ao colidir. A sequência do cenário mudou; reavalie o momento de saltar.
3. **Seções 3 e 5 — teclas combinadas:** direção + salto + Espaço, soltura das teclas e tiros no ar. O teste automático passou, mas o conforto/foco do seu teclado depende da sua máquina.
4. **Seções 6 e 7 — ciclo e tempo:** uma morte, reposição e reinício; depois, quando possível, os três ciclos completos e a partida normal de 90 segundos. Permanecem testes humanos, não falhas técnicas já constatadas.

Não precisa contar pixels ou executar a suíte para preencher essas observações. Menu, artes e resistência das rochas mantêm o mesmo comportamento; os passos anteriores continuam válidos no roteiro. Se você ainda não realizou a rodada, as caixas físicas continuam vazias.

## Como reproduzir a conferência técnica

Executar sequencialmente na raiz:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File testes/executar-teclado-e08.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File testes/executar-e08.ps1
python testes/conferir-e08.py --saida evidencias/nova-conferencia --data DATA-DA-RODADA --e09
```

Para repetir o ensaio de topo: `python testes/verificar-topo.py`, executar o emulador com `evidencias/correcao-auditoria-2026-11-08/topo/topo.conf`, depois `python testes/verificar-topo.py --conferir`. A propagação tem o mesmo fluxo com `verificar-propagacao.py` e `propagacao/propagacao.conf`.

Fonte desta revisão: `13176BC9F5EF6A9123945CAC44732BB933D8511214ECD100F7EA081703025E6D`.

EXE desta revisão: `820051F556FF1BD7756236F00AEEE9AAC9F815656C619C0EB9587BC8C06ACE58`.
