# Auditoria independente — Moon Patrol (Assembly 8086)

Data: 08/11/2026. Escopo: comparação do enunciado fornecido em imagens com os checklists e inspeção de arquivos de `moon_patrol.zip`. **Não foram feitas alterações no código.**

## Identificação e método

- Fonte inspecionado: `moon_patrol/MOON.ASM` (2.862 linhas, 69 procedimentos).
- SHA256 calculado nesta auditoria: `8f9bf3fad3c8684b8326da5ce8f438cfba672a3944624e7bee4730e25928f064`. Coincide com o checklist do Codex.
- EXE incluído: SHA256 `6e1e18d5dbc6517a01e74740ac6da5328ec6d05079d58acc930502969a8ccc64`; coincide com o hash relatado na análise anterior.
- Conferências independentes nesta etapa: leitura do fonte, encadeamento das rotinas, análise de constantes, contagem dos bytes efetivos de 17 bitmaps `DB`/`DUP`, continuidade da borda de ambos os mapas de relevo, consulta às evidências arquivadas e inspeção dos scripts/logs de regressão.
- **Limitação:** não houve nova montagem ou execução do executável 16-bit no GUI Turbo Assembler/Windows nesta sessão. Os resultados dinâmicos citados são evidências existentes no pacote, não uma execução nova minha. Logs de montagem não equivalem a execução normal completa.

## Resumo executivo

**O projeto implementa estruturalmente os subsistemas centrais exigidos para o mínimo entregável:** menu animado, tela de setor, modo gráfico VGA 13h, HUD, terreno com scroll, jipe com deslocamento e salto, obstáculos com vidas/pontuação, grupos de naves, Game Over e retorno ao menu. Os tiros complementares dos dois canhões e dos inimigos também estão implementados.

**Não é possível aprovar incondicionalmente a conformidade:** existe uma divergência concreta no topo do salto (J07); há incertezas sobre a fidelidade das artes (Q07) e as regras ambíguas N06/R09; a colisão de tiros inimigos com o relevo assume interpretação não inequívoca (I04); testes históricos continuam falhando por expectativas antigas e um `PASS E08` isolado não propaga falhas inferiores; testes práticos e apresentação ainda não foram demonstrados.

## Pontos prioritários

| Gravidade | Código/área | Evidência examinada | Conclusão / ação |
|---|---|---|---|
| Alta | J07 — topo do salto | `MOON.ASM` linhas 1097–1157, especialmente 1120–1121; `ContarTopo` linhas 1383–1397; `ANALISE-PROJETO.md` §1.1 | O topo acumula 2px por avanço do cenário até atingir ultrapassar 5; os passos reais são 2+2+2=6px. Enquanto isso, o jipe pode andar 5px por tick; ensaio reporta 25px até a primeira descida. Corrigir após definir referência horizontal e repetir testes de obstáculos. |
| Alta | Q07 — artes exigidas | `MOON.ASM` seção ARTES e `artes/previas/catalogo.png`; figuras originais do professor | Contagem de bytes e dimensões corretas; aparência é autoral, com jipe e naves visivelmente diferentes dos exemplos. Determinar se o professor exige reprodução fiel dos bitmaps. |
| Alta (qualidade) | Regressão / evidência | `testes/R08RESUL.LOG`, `N08RESUL.LOG`, `E08RESUL.LOG`; `testes/{R08,N08,E08}TEST.BAT` | Suíte antiga tem expectativas de passo 3px, mas fonte usa 5px. Alguns casos antigos deixam de ser seguros. BAT superior chama inferior sem checar falha imediatamente; `PASS E08` não prova `PASS R08/N08`. Atualizar e executar o conjunto completo. |
| Média | I04 — tiro inimigo e terreno | `ConferirUmDisparo`, linhas 2613–2710 | Tiro inimigo para na pista Y=193, podendo atravessar montanhas (fundo decorativo). Enunciado diz atingir superfície lunar; interpretação literal pode incluir relevo. Tiros inimigos não são obrigatórios no mínimo entregável. |
| Média | R09 — dois impactos na rocha 4 | `ConferirUmDisparo` linhas 2640–2680; `obstImpactos` | Dois impactos na mesma rocha são acumulados sem reset por erro/morte; termo “consecutivos” pode ter interpretação diferente. |
| Média | N06 — metade horizontal | `GerarGrupoNaves`, linhas 2285–2330 | Formação nasce dentro de janela de 160px à direita; regra textual ambígua quanto ao referencial. |
| Média | GUI/teclado | `InstalarTecladoJogo` / `TecladoJogoIRQ`, linhas 1239–1314; `ABRIR-GUI.cmd` e configurações | Teclado é lido via IRQ1/INT09h durante jogo, e BIOS INT16h no menu/fim. Testar foco, teclas simultâneas e retorno no ambiente exato da apresentação. |
| Média | Relógio / estabilidade | `LerCentissegundos`, `ConsumirTempo`, linhas 1455–1554 | Tempo não depende apenas dos frames e duração é configurável (90s). Há ensaio de 6s; falta validar 90s normais e fluidêz percebida. |
| Informativa | Q08 — duas plataformas | Enunciado e checklist | Compatibilidade com GUI Turbo Assembler/Windows é a exigência explícita; a expressão “ambas as plataformas” permanece sem segundo ambiente especificado. |

## Principais conformidades confirmadas na leitura do fonte

- `.8086`, `.model small`, `VIDEO_MODO equ 13h`, `VIDEO_SEG equ 0A000h`, `TELA_LARG equ 320`, `TELA_ALT equ 200`. `inicio` inicializa vídeo; saída restaura modo/página e encerra com INT 21h AH=4Ch (linhas 660–696).
- `DesenharBitmap`, `SalvarFundo`, `DesenharSprite`, `DesenharSpriteRecortado` realizam acesso por endereçamento indireto e strings (`ES:[DI]`, `REP MOVSB`, `REP STOSB`). BIOS INT 10h AH=13h é usada para texto, não como rotina de plotagem de pixels.
- Menu utiliza código de cantos/linhas 218/191/192/217/196/179; seleção em 0Ch e texto branco 0Fh; título em 0Ah; sprites do menu andam esquerda→direita e retornam à esquerda (`EntrarMenu`, `DesenharOpcoes`, `MoverSpritesMenu`).
- Tela SETOR 1 é apresentada antes da partida (`EntrarSetor`), conforme §6 mínimo. Uma fase apenas.
- HUD ocupa linhas 0–14; pontuação à esquerda, vidas centralizadas, relógio/tempo à direita. Esta disposição obedece ao **texto** do professor, que contradiz a figura que mostra vidas à esquerda e score centralizado.
- Pista y=193–199, cor 0Eh e 7px; céu y=15–99, cenário montanhoso a partir de y=100.
- Jipe 20×10; origem X=0–140, último pixel X=159; movimento +/−5 por tick e maior que velocidade das naves; subida e descida são 3px até a altura de 15px, mas topo J07 diverge.
- Três variantes de crateras 14×7; quatro rochas 12×10; geração de crateras com intervalo livre declarado 150–230px e rocha entre crateras. As rotinas de colisão e passagem são separadas; mortes invalidam travessias; pontos +50 são protegidos contra duplicação (`ConferirObstaculos`, `PerderVida`, `SomarPontos`).
- Naves 14×14, de 1 a 3 por grupo, tipo único sorteado, origem à direita, movimento para esquerda e altura fixa. Novo grupo gerado somente sem naves ativas, incluindo as que ainda não entraram na tela.
- Jipe possui disparos simultâneos superior/amarelo e frontal/vermelho; vários tiros mantidos em listas independentes; alcance frontal de 50px; remoção e +100 por nave, +50 por rocha destrutível. Inimigos atiram branco 2×4.
- Game Over centralizado em duas linhas, score final e retorno ao menu com qualquer tecla; vidas e tempo restaurados ao começar outra partida.
- 69 procedimentos com cabeçalhos de função/entrada/saída em inspeção textual.

## Verificação independente das dimensões dos gráficos

Os dados `DB`/`DUP` foram decompostos e contados diretamente do código, sem depender apenas de `inspecao-estatica.json`:

| Sprite | Quantidade de bytes | Esperado |
|---|---:|---:|
| Jipe 20×10 | 200 | 200 |
| Naves 1–3, 14×14 | 196 cada | 196 cada |
| Vidas 1–3, 18×11 | 198 cada | 198 cada |
| Relógio 7×8 | 56 | 56 |
| Crateras 1–3, 14×7 | 98 cada | 98 cada |
| Rochas 1–4, 12×10 | 120 cada | 120 cada |
| Montanhas 320×64 | 20.480 | 20.480 |
| Montes 320×32 | 10.240 | 10.240 |

A primeira e a última coluna coincidem em cada uma das 64 linhas de montanhas e 32 linhas dos montes; as duas últimas linhas de cada bitmap são uniformes. Isso sustenta a continuação circular sem emenda evidente, sem provar fluidez na tela física.

## Resultados de testes existentes no pacote (não reexecutados aqui)

- `MONTAGEM.LOG`: TASM 4.1, sem erros e avisos; `MOON.EXE` está presente. Não foi executado pelo auditor nesta sessão.
- `evidencias/auditoria-2026-11-07/E08RESUL.LOG`: PASS E08, 426 verificações de combate, comparação de quadros e fluxo sintético de 6s.
- `evidencias/auditoria-2026-11-07/R08RESUL.LOG`: PASS MEM + `FAIL JIPE fase=1 caso=00012`.
- `ANALISE-PROJETO.md`: outro teste N08 falhava por esperar X=6 após dois passos, quando o valor atual correto é X=10; R08LOG falha em salto anteriormente válido mas que agora efetivamente colide devido à alteração da velocidade.
- `evidencias/ajuste-jogabilidade/regressao-final.log`: PASS de ensaios novos, mas não recompõe integralmente a antiga regressão.
- Ensaios arquivados incluem 4.096 sementes e 854 tentativas de salto, mas não comprovam conforto de jogabilidade humana, 90 segundos normais ou comportamento no computador da apresentação.

## Resultado do checklist de 115 IDs

- **Estruturalmente alinhados ao professor:** M01–M10, F01–F04, H01–H03/H05/H07, C01–C05/C07, J01–J06/J08, O01–O07, R01–R08/R10–R11, N01–N05/N07–N12, T01–T10, I01–I02/I05–I07, V02–V05/V07–V10, Q01–Q05.
- **Divergência confirmada:** J07 (topo do salto).
- **Interpretação ou aceite pendente:** N06, R09, Q07, Q08; acrescentar ressalva a I04 (superfície lunar).
- **Validação humana ou operacional pendente:** P01–P04, H04/H06, C06/C08, J09/J10, I03, V01/V06/V11, Q06 e A01–A06. Determinados pontos possuem evidência automatizada parcial, mas não validação física conforme seu próprio critério.
- **Falha de infraestrutura de testes, não ID funcional original:** adequar testes ao passo 5px, corrigir propagação de `FAIL`, executar regressão e verificar validade de mudanças nas expectativas.

## Ações em ordem recomendada

1. **Decidir a interpretação de J07 e corrigir a contagem/cronologia do topo**, com demonstração de distância real. Evitar simplesmente saturar o contador em 5 após percorrer 6px. Reexecutar saltos de crateras e rochas depois de qualquer mudança.
2. **Comparar jipe, naves e HUD com bitmaps exigidos pelo professor**. Manter um registro de quais artes serão reproduzidas fielmente e quais são adaptações autorizadas.
3. **Rever colisão dos tiros com montanhas (I04), impacto consecutivo da rocha 4 (R09) e limites de formação das naves (N06)**, diferenciando regra do enunciado de interpretação do projeto.
4. **Atualizar e rodar suíte completa de regressão**, substituindo expectativas que impõem velocidade antiga por critérios baseados em constantes e comportamento; fazer falhas subirem até o resultado final.
5. **Executar `MOON.ASM` no GUI Turbo Assembler/Windows da apresentação**, verificar uso de teclado físico, múltiplas teclas, fluidez, duração de 90s, mortes e reinícios.
6. Preparar explicações da arquitetura: inicialização DOS/VGA, framebuffer A000h e offset y×320+x, sprites com transparência FFh, rolagem circular, listas de objetos, colisão de retângulos, cronômetros/ticks, IRQ1 teclado, máquina de estados e finalização.

**Síntese:** o código é substancial e o trabalho aparenta atender a arquitetura do mínimo entregável, mas falta corrigir ou negociar J07, resolver ambiguidades artísticas/funcionais e validar a apresentação com teste físico. Não se deve afirmar aprovação integral sem essas etapas.
