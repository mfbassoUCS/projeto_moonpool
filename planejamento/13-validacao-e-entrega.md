# E07/E08/E09 — Validação, compreensão e entrega

**Matriz E09 — fechada tecnicamente em 06/11/2026.** Versão completa revalidada pela suíte E08/N08/R08 executada em 02/11; KEY e conferência final em 06/11. A execução automática e a inspeção não encerram a validação física. [Relatório atual](../evidencias/e09/verificacao.txt), [naves](../evidencias/e09/regressao-naves.txt), [mínimo](../evidencias/e09/regressao/verificacao.txt), [telas](../evidencias/e09/regressao-telas.txt), [botões/ciclo IDE](../evidencias/e09/gui-validacao.md), [R×T×fonte](17-revisao-e09.md) e [roteiro físico](../LEIA-E09.md). Aluno informou em 01/11 que não fez testes manuais E07; solicitado relato posterior, sem resultado físico novo recebido.

## Registro de testes

Para cada teste: data, versão/arquivos, ambiente e configuração, ação executada, resultado esperado, observado e situação (passou/falhou/pendente). Montagem, inspeção do código e execução interativa são evidências diferentes; identificar qual foi feita.

| Teste | Procedimento / resultado esperado | Requisitos | Evidência executada/inspecionada e limite |
|---|---|---|---|
| T01 | Montar e executar no GUI Turbo Assembler/Windows, sem instruções incompatíveis | R01 | TASM 4.1/TLINK 7.1.30.1, MOON e 13 variantes E08/N08/R08 sem erros/avisos; executados no DOSBox 0.74-3 do pacote GUI Turbo Assembler 5.1. `.8086` conferido. **Assemble/Build/Run atuais executados em 02/11 via acessibilidade**, após reabrir o fonte do disco; ciclo menu/setor/partida/fim/retorno/Sair por PostMessage, log e capturas reais. A apresentação humana no ambiente de avaliação permanece pendente. |
| T02 | Conferir 320×200, endereço de exemplo e limites; revisar desenho/ocultação por memória | R02 | N08MEM/R08REG/R08JIPE/N08PIX/R08PIX: pixels, limites, transparência, DF e guardas. Inspeção: A000h, 64.000 bytes, `100+10×320=3300=0CE4h`; gráficos/limpeza por memória, BIOS para texto/modo. **Aprovado automaticamente e por inspeção.** |
| T03 | Ver título correto, cores, caixas, animação de quatro elementos; navegar e sair | R03–R05 | N08TELA: 320 quadros por ticks, ↑/↓/Enter, teclas ignoradas, Sair; N08MEM: 400 quadros/duas voltas de cada objeto. Seis RAW e conferidor de cores/sprites/fundo; ASCII comparado ao TAAG arquivado. **Pendente:** teclado físico e percepção visual. |
| T04 | Jogar passa pela apresentação do setor conforme decisão documentada | R27 | N08TELA: SETOR 1, espera de ≥2 s sem consumir tempo; setas/letra não iniciam, Enter antigo é descartado, Enter novo inicia com 90 s. Objetivo/controle visíveis no RAW. **D04 adotada tecnicamente, sem confirmação do professor; repetição física pendente.** |
| T05 | Conferir posições, dimensões do HUD, score, vidas e segundos reais | R06–R07 | R08AUTO/R08REG: HUD/vida/score real e relógio; dumps de morte/reposição/fim e regressão de frações, margem, pausa e meia-noite. Na E09, E08AUTO mediu 6,21 s DOS / 6,223 s Windows em expiração controlada de 6 s. Rotinas HUD/tempo e limites gráficos históricos preservados. **Pendente:** sessão normal de 90 s com cronômetro externo. |
| T06 | Observar duas voltas do fundo, relevo variável e emenda contínua; pista 320×7 | R13–R15 | R08REG: 320 quadros/duas voltas e offsets 1/319; R08JIPE e conferidores verificam fundo com objetos, emenda e pista. **Aprovado em memória; fluidez/rasgos perceptíveis pendentes.** |
| T07 | Mover até os dois limites; comparar velocidade do jipe e naves | R16 | R08JIPE: X=0/140 e passos residuais; N08LOG: duas amostras movem jipe 6 px/nave 1 px e testam cadência. Assertiva de velocidade preservada. **Pendente:** controle físico/simultâneas. |
| T08 | Saltar parado e em movimento; conferir 3/15/5 pixels horizontais/3 | R19 | R08JIPE: 80 estados, subida/topo/descida, limites, teclas mantidas e D05 por distância; R08LOG: sete travessias reais nas rotinas. **Pendente:** conforto físico; limiar 5 amostrado em 2/4/6 continua documentado. |
| T09 | Observar tipos, posições, dimensões e espaçamento de crateras/rochas | R18, R21 | R08LOG: 199 nascimentos/20.000 px; N08LOG misto: 394/40.000 px, todos os tipos; conferidores validam geometria, distâncias e folgas. R08PIX verifica sete artes/bordas. **Aprovado automaticamente; aparência física pendente.** |
| T10 | Saltar obstáculos, conferir +50 único, sem pontos indevidos após colisão | R20, R23 | R08LOG: sete saltos completos, pontos somente no pouso seguro, recuo, morte, candidato fora da tela, repetição e saturação 65535. **Aprovado automaticamente; executar com teclado físico.** |
| T11 | Colidir, conferir uma vida a menos, desaparecimento e reposição x=0 | R24 | R08LOG e R08AUTO: primeira morte natural por obstáculo gerado, outras controladas; uma vida por evento, espera por área livre, reposição, teclas mantidas, tempo/progresso/naves preservados. **Aprovado automaticamente; caso ↑ mantida fisicamente pendente.** |
| T12 | Ver grupos aleatórios 1–3, mesmo tipo, três tipos possíveis, limites e distâncias | R08–R10 | N08LOG: 4.096 sementes/nove combinações/extremos, 48 grupos mistos, repetições permitidas; N08PIX: 390 quadros e bordas. **Aprovado automaticamente; D06/D07/D09 são convenções técnicas; observação física pendente.** |
| T13 | Remover parcialmente grupo: não gerar outro; remover última nave: liberar | R10 | N08LOG mantém testes de contagem/saída, incluindo ativa fora da direita. E08LOG/E08AUTO destroem naves por tiro, conferem +100 único, próximo grupo e projéteis remanescentes. **Aprovado automaticamente; observação física pendente.** |
| T14 | Esgotar vidas e, separadamente, tempo; GAME OVER em duas linhas, score final, qualquer tecla | R25 | R08AUTO: última vida/score 150 e expiração curta/score 250, IRQ restaurada; N08TELA: score 65535, GAME/OVER vermelhos, retorno por seta/letra. MODO confirma 03h/página 0 após saída. **Pendente:** término da duração normal de 90 s por uso físico. |
| T15 | Jogar de novo: reinicializar vida/score/tempo/objetos; menu continua animado | R05, R25 | R08AUTO/N08TELA: duas sessões, dados/teclas/rolagem/grupo/cadência reiniciados; imagem do menu de retorno idêntica à inicial; animação por ticks e Sair. **Aprovado automaticamente; ciclo físico pendente.** |
| T16 | Revisar constantes, tempos ajustáveis, reutilização e cabeçalhos de todas as rotinas | R26 | `.8086`, ASCII, constantes, artes e reutilização conferidos. Inventário dos **69 procedimentos** com função/entrada/saída em inspecao.txt; corpo sem comentários idêntico à E08BASE; 46 rotinas E07 preservadas pela regressão. 35.431 bytes de dados, código 4.854, buffers 320/200 e pilha 100h. **Aprovado por inspeção/montagem; explicação em GUIA-APRESENTACAO.** |
| T17 | Completo: Espaço aciona canhões juntos; tiros independentes; limites/cores/dimensões | R12, R17 | E08LOG: chão e todas as alturas, dois canhões atômicos, 8+8 vagas, toque/mantida/soltura, cadência e wrap; E08PIX: cores 0Eh/04h/0Fh, medidas 2×4/4×2/2×4, 28 vagas e recorte. E08KEY: Espaço real via IRQ durante salto e dois pares. **Aprovado automaticamente; teclado físico pendente.** |
| T18 | Completo: superior remove nave e +100 uma vez; frontal some aos 50 ou impacto | R12, R17 | E08LOG: nave/remover ambos/+100 uma vez, signed/bordas/linha15, saturação, última nave; frontal 50 exatos desde origem com jipe mudando, impacto no ponto final. E08AUTO: nave destruída no fluxo real. **Aprovado automaticamente.** |
| T19 | Completo: testar rocha 1, 2, 3, 4; segundo impacto e score sem duplicação | R22–R23 | E08LOG: rocha1 fica, 2/3 somem em um impacto, 4 em dois; erro/morte não reiniciam dano, reuso zera; crateras intactas e salto OU destruição sem duplicar +50. E08AUTO destrói rocha real. **Aprovado automaticamente; D11 técnica registrada, execução física pendente.** |
| T20 | Completo: tiros inimigos contínuos, limite na superfície/jipe, chance de esquiva | R11, R24 | E08LOG: branco contínuo, grupos, canhão visível, 12 vagas sem substituição, bordas/meio/fora/salto, pista, morte única e reposição livre. E08AUTO: branco continua após morte da nave e retira vida. **Aprovado automaticamente; chance de reação/conforto e fluidez dependem de avaliação física.** |

T17–T20 agora se aplicam à versão completa. A aprovação automática não equivale a aceitação física de conforto/esquiva/fluidez.

E08LOG executa 426 verificações; E08PIX confere 170 quadros/11.050.000 bytes. N08/R08 reaplicam os testes do mínimo com nomes próprios. **R08AUTO desabilita somente a emissão inimiga na variante**, para reutilizar o oráculo antigo sem tiros; E08AUTO testa o fluxo com todos os disparos habilitados. MOON mantém tiros normais. Os demais arranjos de poses/sementes/scores/tempo curto pertencem aos testes. E08KEY usa PostMessage→SDL windib→DOSBox→IRQ1, sem substituir o teclado físico/backend normal.

T01–T16 mantêm suas pendências físicas. Os botões atuais e o ciclo sintético na IDE têm evidência E09; a sessão normal de 90 s com cronômetro externo continua pendente. O E08KEY de 06/11 mantém sua natureza sintética/windib. A aceitação das artes próprias e orientações do professor permanecem separadas das verificações técnicas. A primeira tentativa da suíte E09 abortou no auxiliar por arquivo de sinal ocupado; está registrada como incompleta. Após corrigir a leitura concorrente, a repetição final passou, sem mudar regras ou relaxar oráculos.

## Revisão do código

- Todos os procedimentos com função, entradas e saídas; comentários explicam intenção e lógica.
- Definições em constantes, sem números arbitrários espalhados.
- Nenhuma rotina gráfica de pixel via BIOS; texto conforme exceção permitida.
- Sem cópias desnecessárias de rotinas para cada variante visual.
- Sem escrita fora da tela, objetos inativos participando de colisão ou score repetido.
- Tempos e contadores não dependem de apertar teclas; valores não transbordam na duração prevista.
- Ajustes finais mantêm a solução compreensível para o aluno.

## Preparação para explicar

O aluno deve conseguir explicar: fluxo entre telas; segmento A000h e cálculo de endereço; representação dos bitmaps; leitura de teclado sem espera; frame versus segundo; rolagem e emenda; estados do salto; sorteio e ciclo de grupos; colisão e perda de vida; pontuação única; e, se incluídos, projéteis e resistência das rochas.

Material preparado: [GUIA-APRESENTACAO](../GUIA-APRESENTACAO.md), com sequência curta, mapa de rotinas, exemplos e 20 perguntas. Estudar/ensaiar e apresentar são ações humanas ainda necessárias; a existência do arquivo não as comprova.

Para cada rotina importante, responder em palavras próprias: o que faz, o que recebe, o que devolve, que memória altera e por que existe. Revisar trechos que não consiga explicar antes da apresentação.

## Checklist acadêmico

- [ ] Grupo com no máximo dois integrantes inscrito em um dos 15 grupos.
- [ ] Confirmar data concreta do último dia de aula.
- [ ] Fonte final monta e executa no GUI Turbo Assembler/Windows usado para apresentar.
- [ ] Todos os itens mínimos operacionais e dúvidas relevantes registradas/resolvidas.
- [ ] Demonstrar menu, jogo, salto, obstáculos, naves, vidas, tempo e fim.
- [ ] Demonstrar tiros se incluídos na versão entregue.
- [ ] Apresentação realizada antes de submeter.
- [ ] Código-fonte enviado na tarefa após apresentação, no formato solicitado pelo professor.

O enunciado não especifica nome do arquivo final ou formato de pacote; não inventar uma exigência de ZIP, relatório ou vídeo. Sem apresentação, não há avaliação.
