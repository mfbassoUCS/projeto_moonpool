# E07 — integração do mínimo

**Histórico da E07.** O fonte atual é E08; leia [LEIA-E08](LEIA-E08.md). Os scripts E07 agora usam `testes/E07BASE.ASM`; seus resultados anteriores permanecem preservados. Atalhos antigos montam MOON atual.

O jogo integra menu, setor, cenário/status, jipe/salto, obstáculos, naves, vidas, pontos e Game Over. A E07 organiza a validação do conjunto e finaliza a apresentação das telas. As regras de jogo da E06 foram preservadas; tiros continuam fora desta versão mínima.

Abra `EXECUTAR-E07.cmd`, confira `MONTAGEM.LOG`/`LINK.LOG` e digite `MOON`. Na GUI Turbo Assembler, recarregue `MOON.ASM`, selecione Turbo 16-bit e use Assemble/Build/Run. Os atalhos antigos também montam o fonte atual. `testes/E06BASE.ASM` guarda exatamente a versão anterior.

## O que mudou

O menu mantém Moon Patrol em verde, as duas opções e os quatro sprites animados. O crédito agora é somente “ARTES AUTORAIS”, sem rótulo de etapa. A apresentação mostra SETOR 1, o objetivo “Salte os obstáculos e sobreviva!” e os controles. O Game Over mostra GAME/OVER vermelho, score e instrução de retorno; o antigo aviso de demonstração e sua flag/rotina foram removidos.

D04 foi adotada como **decisão técnica**: Enter inicia a única fase, sem avanço automático. O professor menciona a apresentação do setor, mas não define conteúdo, duração ou tecla; essa escolha não foi apresentada como confirmação dele. Enquanto o setor aguarda, o relógio não corre. A referência inicial é tomada depois de desenhar o primeiro quadro da partida.

Os testes mantêm a distinção entre uma tecla já enfileirada e uma tecla fisicamente mantida: o buffer antigo é limpo nas transições. Uma repetição futura produzida pelo teclado físico ainda precisa ser observada no teste manual.

## Fluxo para explicar

`inicio` configura modo 13h, chama `EntrarMenu` e consulta teclado sem bloquear. O estado escolhe a rotina de atualização. No menu, `AtualizarAnimacao` usa ticks BIOS para mover os quatro sprites. `LerTeclado` alterna Jogar/Sair e confirma com Enter.

`EntrarSetor` limpa teclas antigas e desenha a apresentação. Enter chama `EntrarPartida`, que reinicia score, três vidas, 90 segundos, jipe, obstáculos, naves, rolagem e entradas; desenha o primeiro quadro; instala IRQ1 e registra as referências de tempo. Setas e letras no setor não iniciam a fase.

`AtualizarPartida` mantém relógio independente das cadências. Atualiza naves, terreno e jipe/reposição, testa colisões antes de pontos e desenha as regiões alteradas. O topo do salto continua contando avanço do terreno até cruzar cinco pixels (D05), sem conversão para frames. Os grupos continuam homogêneos e aguardam a última nave (D06/D07/D09). Morte e reposição preservam tempo, score, geração e teclas mantidas (D14/D15).

Zero vidas ou tempo chama `EntrarGameOver(AX=scorePartida)`. A rotina restaura IRQ1, limpa entrada antiga e apresenta o score real. Uma tecla comum ou estendida volta ao menu; nova partida reinicia os dados. Enter em Sair devolve o controle ao DOS e restaura modo/página de vídeo. Esc não encerra o jogo.

O desenho segue por memória: céu recomposto quando naves mudam; cenário → obstáculos → captura/jipe na rolagem; fundo atual do jipe nos outros quadros. FFh é transparente e 00h é preto opaco. Nenhuma arte foi refeita. As funções de jogo e as constantes de movimento, tempo, geração e colisão ficaram idênticas à E06. Dados atuais: **35.105 bytes (08921h)**, buffers cenário=320 e jipe=200, pilha 100h.

## Testes e evidências

Na raiz, sem execuções simultâneas:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File testes\executar-e07.ps1
python testes\conferir-e07.py
```

O gerador reaproveita os testes E02–E06 sobre o MOON atual com nomes E07/R07, preservando snapshots e resultados históricos. O executor monta com TASM 4.1/TLINK 7.1.30.1 no DOSBox 0.74-3 incluído na GUI Turbo Assembler 5.1. RAM usa cycles=50000; os testes de fluxo e telas usam auto. Python/Pillow são auxiliares de validação, sem dependência do EXE.

`E07MEM` reaplica o teste de sprites/menu da E02: 400 quadros, restauração do fundo, recortes inválidos, FFh/00h e guardas. `E07TELA` acrescenta 320 quadros por ticks reais, navegação/cores, descarte de Enter antigo, espera de dois segundos no setor sem consumir tempo, entrada na partida, Game Over no limite do score, retorno por letra/seta e Sair. Seus seis dumps reais de A000h são conferidos externamente.

`E07LOG/E07PIX` reaplicam as verificações das naves: 4.096 sementes, geração intercalada com obstáculos e 390 quadros com bordas, remoção e recomposição. `R07REG/R07JIPE/R07LOG/R07PIX/R07AUTO` reexecutam cenário, salto, relógio, obstáculos, vidas, score, fim por vidas/tempo, reinício e IRQ. O primeiro choque no teste de fluxo é natural; as mortes posteriores, scores e duração curta são arranjos de teste, não a configuração normal.

Resultados efetivos, hash, medidas e imagens estão em `evidencias/e07/verificacao.txt`, `regressao-naves.txt` e `regressao/verificacao.txt`. A matriz T01–T20 de `planejamento/13-validacao-e-entrega.md` identifica execução automática, inspeção e partes físicas pendentes. T17–T20 são **não aplicáveis ao mínimo**; não foram marcados como aprovados.

Os testes de remoção de naves chamam a interface diretamente; não demonstram tiros. Sementes, poses, vidas/score forçados e tempo curto pertencem somente aos testes. PNGs são memória reconstruída, não filmagem ou prova de fluidez. Não foi feita nova medição externa de 90 segundos.

## Roteiro que depende de você

1. Na IDE, montar e executar o fonte atual pelos botões. Conferir título, cores, caixas, animação e seleção por ↑/↓; entrar em Jogar.
2. No setor, ler objetivo/controles, aguardar e confirmar com Enter. Observar Enter mantido e soltura; o relógio começa em 90 na partida.
3. Testar ←/→ mantidas, simultâneas, inversão durante salto, limites e ↑. Manter ↑ após pouso/morte e depois soltar/pressionar; avaliar o controle real.
4. Saltar crateras/rochas avançando; verificar +50 somente no pouso seguro e sem repetição. Provocar colisões e conferir 3→2→1→Game Over, espera pela área livre e reposição em X=0. Avaliar especialmente a janela estreita das rochas.
5. Observar grupos de naves, alturas fixas, espaçamento, entrada/saída gradual e espera pela última. Tipos repetidos são permitidos. Várias partidas podem ser necessárias para ver todas as combinações na velocidade normal.
6. Observar duas voltas do terreno e várias animações, procurando rastros, cintilação, rasgos e desconforto. Comparar os 90 s normais com cronômetro externo enquanto sobrevive; a expiração curta automatizada não substitui esse teste.
7. Conferir score final, retorno por tecla, nova partida com três vidas/zero pontos/90 s e Enter em Sair.

Informe o comportamento observado e, se houver falha, a sequência que a provoca. A integração pode passar nos testes automáticos e ainda precisar de ajustes de jogabilidade ou apresentação. Não declarar o mínimo totalmente validado para avaliação enquanto essas partes físicas estiverem abertas. Use a retomada E07 para registrar os resultados/corrigir defeitos; E08 depende de novo pedido e não foi iniciada.
