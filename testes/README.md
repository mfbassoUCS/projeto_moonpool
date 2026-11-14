# Verificação da E01 à E09

## Conferência atual — 08/11/2026

A suíte foi adaptada às constantes atuais do jipe/terreno e passou sobre o fonte identificado em [CORRECOES-AUDITORIA.md](../CORRECOES-AUDITORIA.md). Na raiz, executar nesta ordem:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File testes/executar-teclado-e08.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File testes/executar-e08.ps1
python testes/conferir-e08.py --saida evidencias/nova-conferencia --data DATA-DA-RODADA --e09
```

`registro_execucao.py` remove saídas antigas antes da rodada e registra hashes do fonte e das saídas; o conferidor rejeita resultados ausentes, alterados ou de outro fonte. Os BATs limpam os marcadores antigos e propagam falhas de R08 para N08 e E08.

Ensaios adicionais: `verificar-topo.py` cobre 12 trajetórias no laço real; `verificar-propagacao.py` injeta falha numa suíte filha com marcadores antigos presentes. Gerar com Python, executar o DOSBox com o `.conf` gerado e conferir com `--conferir`, conforme o relatório. Teclado automatizado não substitui a rodada física.

As seções seguintes registram a evolução e as execuções históricas; números antigos não são resultados do fonte atual.

**Fonte atual: revisão E09 da versão completa E08.** Use [LEIA-E09](../LEIA-E09.md) para os comandos atuais. E01–E07 leem snapshots próprios; E08BASE preserva a implementação de 01/11. Os harnesses E08/N08/R08 continuam lendo MOON atual e são reutilizados na E09. Relatórios históricos E07/E08 não foram sobrescritos; os arquivos gerados E08/N08/R08 em testes correspondem à execução mais recente, identificada por hash. Atalhos EXECUTAR sempre montam MOON atual.

Estes arquivos não fazem parte do jogo. **E01 histórica:** `gerar-testes.ps1` agora lê `E01BASE.ASM`, snapshot idêntico ao fonte aprovado ao fim da E01, e gera suas variantes. Não executa os testes da E01 sobre a interface nova da E02. O fonte principal não é modificado.

1. No PowerShell, na raiz do projeto:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File testes\gerar-testes.ps1
```

2. Abra `EXECUTAR-E01.cmd`. No prompt DOS, execute:

```bat
cd testes
TESTAR.BAT
```

3. Confira `RESULT.LOG`, os logs de montagem e `TEMPO2.TXT`/`TEMPO4.TXT`.

## O que é verificado

- `BASE.ASM`: usa 65000 bytes de RAM, incluindo 1000 de guarda após a área visível. Desenha 8×8 em (312,192), conta 64 pixels e confere o último pixel em 63999. Restaura o fundo e percorre toda a região para conferir integridade. Oito retângulos inválidos devem deixar a memória intacta. Confere DF=0 no retorno e teclado vazio/letra/seta/Esc. Teclas são inseridas por INT 16h/AH=05h, sem depender do foco do Windows.
- `ESC.ASM`: variante do programa completo que insere Esc no buffer antes de entrar no fluxo normal. Deve terminar pelo próprio caminho de saída do programa. `MODO.ASM`, executado em seguida, confirma modo 03h e página 0.
- `TEMPO2.ASM` e `TEMPO4.ASM`: variantes que encerram quando o contador chega a 5, imprimindo posição X e contador. A primeira deve percorrer aproximadamente o dobro da distância da segunda; ambas devem imprimir 5 segundos. Não são o EXE normal do jogo.

Resultado em 24/10/2026: todos passaram no emulador do GUI Turbo Assembler 5.1, com TASM 4.1/TLINK 7.1.30.1. Logs finais sem erros nem avisos. Valores de temporização: `00084 00005` e `00044 00005`.

Não se trata de teste de jogabilidade nem de precisão do cronômetro de uma partida. A conferência visual e a montagem pelos botões da IDE estão registradas em `../planejamento/14-andamento.md`.

## E02 — snapshot histórico

1. Na raiz, execute `powershell -NoProfile -ExecutionPolicy Bypass -File testes\gerar-e02.ps1`. Desde a E03, o script lê E02BASE.ASM, snapshot da E02 autoral, injeta os auxiliares E02MEM.INC/E02AUTO.INC/E02ART.INC e registra o hash em E02-FONTE.txt. Não altera MOON.ASM. A comparação TAAG/artes do conferidor continua válida enquanto esses dados forem preservados no fonte atual.
2. Abra EXECUTAR-E02.cmd. No DOS: `cd testes`, depois `E02TEST.BAT`.
3. Confira **E02RESUL.LOG** (nome DOS de oito caracteres), E02MEM.LOG e E02AUTO.LOG. Sucesso exige PASS MEM, PASS AUTO, restauração de modo/página e PASS E02 final, sem FAIL.
4. Opcionalmente, com Python/Pillow, execute `python testes/conferir-e02.py`. Esse auxiliar verifica os arquivos RAW reais e gera PNGs e verificacao.txt em evidencias/e02. Não faz parte da montagem do jogo.

O teste de memória usa 50.000 ciclos do emulador para acelerar a varredura exaustiva; o batch restaura **cycles=auto antes do teste do menu**. A sequência pode levar cerca de dois minutos. Não interromper antes da mensagem final.

| Verificação | Tipo e alcance |
|---|---|
| Dimensões | TASM calcula diferenças entre rótulos; rejeita tamanhos errados dos 17 bitmaps (15 sprites e duas faixas de relevo) |
| E02MEM | Execução das rotinas reais sobre 65.000 bytes de RAM: 00h opaco/FFh transparente, DF=0, oito retângulos inválidos, objetos sobrepostos, 400 quadros, duas voltas por objeto e guarda de 1.000 bytes |
| E02AUTO | Programa completo com auxiliar que insere teclas no buffer BIOS; 320 quadros com ticks reais, cima/baixo/Enter, duas demonstrações, retorno por letra e seta, letras/Esq/Esc ignorados no menu, score 00000/12345/65535, descarte de Enter antigo e saída pelo laço normal |
| MODO | Programa independente confirma modo 03h/página 0 depois da saída |
| E02ART | Galeria estática com as 17 artes desenhadas pelas rotinas reais. Exporta ARTES.BIN com os 32.932 bytes montados, incluindo transparência/preto |
| Capturas RAW | Dump dos 64.000 bytes reais de A000h: MENU0, MENU2, SELECAO, SETOR, FIM, RETORNO e GALERIA |
| conferir-e02.py | Compara ARTES.BIN com as grades de desenhos.json e todos os sprites/camadas da galeria com uma composição independente; cores, posições após 320 quadros, faixa sem rastros, fundo estático preservado, menu reiniciado e TAAG |

**Não coberto:** teclado físico, fidelidade aos bitmaps ausentes, recorte parcial, fundo rolando, partida real, modos de entrada diferentes de 03h/página 0 e pausas longas. O teste de 400 quadros confere restauração sobre fundo estático listrado; não deve ser apresentado como validação da E03.

**Resultado atual em 25/10/2026:** sequência PASS MEM / PASS AUTO / modo 03h e página 0 / PASS E02; montagens sem erros e sem avisos. Conferência Python dos sete dumps e ARTES.BIN passou; 17 bitmaps válidos e relevo com bordas iguais. Fonte identificado em E02-FONTE.txt; registro detalhado em planejamento/14-andamento.md. As capturas menu-normal-windows.png e printwindow-parcial.png pertencem à versão histórica de molduras de 24/10; os PNGs menu0/menu2/galeria correspondem às artes próprias atuais.

## Roteiro físico pendente da E02

Na IDE, abrir o fonte atual (recarregar se estava aberto na E01), montar e executar. Deixar animar por duas voltas; usar cima/baixo durante o movimento; conferir as cores e caixas. Entrar em Jogar, verificar SETOR 1, Enter para GAME OVER/12345, qualquer tecla para voltar; repetir; selecionar Sair e Enter. Testar tecla mantida pressionada para observar repetição do teclado. Revisar a aparência das artes próprias na prancha artes/previas/catalogo.png e na galeria real evidencias/e02/galeria.png. Não é necessário recuperar os PNGs ausentes para validar essa solução autoral autorizada.

Esse roteiro descreve o snapshot E02. No fonte atual, Enter após SETOR 1 inicia cenário/HUD; espere o tempo acabar. O score normal é zero, não 12345.

## E03 — snapshot histórico desde 28/10/2026

Na raiz, execute:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File testes\executar-e03.ps1
python testes\conferir-e03.py
```

O primeiro comando gera variantes de **E03BASE.ASM**, monta MOON atual e os testes históricos e executa o batch no DOSBox 0.74-3 incluído no GUI Turbo Assembler 5.1, TASM 4.1/TLINK 7.1.30.1. Usa `cycles=50000` apenas para varredura de RAM e restaura `cycles=auto` para os testes de relógio/fluxo. Leva aproximadamente dois minutos. Registra o hash do snapshot em E03-FONTE.txt. `executar-e03.ps1` observa escritas de arquivos com Stopwatch/FileSystemWatcher do Windows para medir duração independentemente do relógio DOS. O relatório original de 26/10 está preservado em `evidencias/e03/verificacao-2026-10-26.txt`; o snapshot foi reexecutado em 28/10 para renovar evidências após corrigir nomes de arquivos no auxiliar E04.

Também é possível gerar com `gerar-e03.ps1`, abrir EXECUTAR-E03.cmd e executar `cd testes` / `E03TEST.BAT` no DOS. Esse caminho não renova a medição Windows E03HOST.LOG; para evidência externa atual, prefira o comando completo acima. Não execute instâncias dos testes simultaneamente: elas compartilham nomes de arquivos.

| Teste | Evidência executada |
|---|---|
| E03MEM | 320 quadros de 2 px, duas voltas; compara todos os 32.000 pixels inferiores com rotação da tela inicial; preserva os 32.000 bytes superiores e 1.000 de guarda; também offsets 1/319 |
| E03MEM, composição | FFh preserva, 00h opaco, DF=0; nenhum bitmap permanente é alterado |
| E03MEM, tempo | 99+1/350 centésimos; margem inicial 3+102+1; pausa de 70 s; saturação sem DIV overflow; meia-noite com 125 centésimos; mesma amostra não desconta novamente |
| E03T2/E03T4 | Duração 4 s com cadências 2/4 ticks, relógio real, medição externa, quantidade diferente de movimentos e duração equivalente |
| E03AUTO | Duração 45 s; exige pelo menos 320 quadros/duas voltas por ticks, fluxo real com teclas BIOS, limpeza de Enter antigo, HUD 3/2/1/0 e score 65535/9/0 |
| Expiração/reinício | Score de teste 43210 chega a EntrarGameOver; volta ao menu e reinicia duração/vidas/score/rolagem/fração; segunda sessão encurtada para 1 s somente após conferir reset; Sair pelo laço real |
| MODO | Programa independente confirma modo 03h/página 0 após saída |
| conferir-e03.py | Artes idênticas à E02; oito dumps reais A000h comparados com composição independente das grades; pista, base, emenda, HUD e glifos sem restos; valida medidas DOS/Windows e gera PNGs/relatório |

Sucesso exige `PASS MEM`, três `PASS AUTO`, confirmação do modo/página e `PASS E03`, sem FAIL; montagens sem erros/avisos. Resultados finais em `E03RESUL.LOG`, logs dos montadores, `E03HOST.LOG`, `TEMPOE32.BIN`/`TEMPOE34.BIN`/`E03TEMPO.BIN` e `../evidencias/e03/verificacao.txt`. Os valores dos testes (45/4/1 s, scores e vidas forçados) não são a configuração normal de 90 s/3 vidas/score zero.

**Não coberto:** teclado físico, botões Assemble/Build/Run da E03, avaliação humana de fluidez/rasgo de imagem, ajustes manuais da hora, suspensão do host ou intervalo de 24 h sem consulta. As rotinas de sprites continuam sem recorte parcial; não há objetos de jogo sobre o fundo rolando para validar apagamento. Os PNGs são memória real do emulador reconstruída com paleta VGA, não captura física da IDE.

## E04 — snapshot histórico desde 29/10/2026

Na raiz, sequencialmente:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File testes\executar-e04.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File testes\executar-teclado-e04.ps1
python testes\conferir-e04.py
```

O primeiro gera variantes **do E04BASE.ASM**, registra SHA256 em E04-FONTE.txt, monta o EXE normal atual e os testes históricos e executa no emulador incluído no GUI Turbo Assembler 5.1. Aproximadamente três minutos neste ambiente. `cycles=50000` apenas para RAM; volta a `auto` para fluxo/relógio. O segundo monta E04KEY a partir do mesmo snapshot e envia eventos Windows à janela oculta do emulador, com SDL `windib` somente nesse processo. Nenhum evento é enviado ao aplicativo em foco. O conferidor E04 também lê E04BASE; as evidências de 28/10 não foram sobrescritas pela E05. Python/Pillow só conferem/exportam evidências; não são dependências do jogo.

O snapshot E04 tem SHA256 `F87A21DE534FF647A45825FA7A223939F116F10DDE8D10E87FDFE94C2D7225B1`, idêntico ao fonte aprovado em 28/10. A E05 reexecuta os oráculos de RAM E03/E04 no fonte atual em variantes com nomes E05REG/E05JIPE.

| Teste | Execução e alcance |
|---|---|
| E04REG | Harness E03MEM sobre o fonte atual: duas voltas em RAM, offsets 1/319, composição, transparência/preto, DF, guardas, frações, margem, pausa de 70 s, meia-noite e saturação |
| E04MEM / E04CASOS | 80 resultados explícitos X/Y/fase/distância: limites 0/140, passo residual, ambas laterais, soltura, repetição, pressão no ar descartada, reset, cinco subidas/descidas, altura 15, parado/esquerda/direita/borda |
| Topo D05 | Frames sem avanço não contam; 0 e 1+2+1+1 chegam exatamente ao limiar; 2+2+2 cruza 5 entre amostras e satura contador, sem trocar pixels por frames |
| E04MEM / pixels | 640 quadros: 320 com terreno rolando (duas voltas) e 320 intercalados só do jipe; oráculo independente rotaciona fundo limpo e sobrepõe bitmap; compara 65.000 bytes por quadro, incluindo HUD/céu/guarda; testa DF=1 na entrada |
| E04T2/E04T4/E04AUTO | Fluxo completo real, duração de teste 4/4/45 s; teclas BIOS nas telas e scans na lógica do jipe; cadências de cenário 2/4, 387 movimentos na variante longa; movimento/salto, HUD, expiração, score 43210 transmitido, reinício e Sair |
| Vetor e modo | IRQ instalada durante partida; vetor original conferido depois de expirar; dados do jipe e entrada reiniciados; modo 03h/página 0 confirmados por MODO.EXE |
| E04KEY | Windows PostMessage→SDL windib→DOSBox→IRQ1 real: direita, direita+cima, esquerda+cima, soltura, novo salto, Game Over durante salto e retorno ao menu pelo BIOS |
| conferir-e04.py | 12 dumps A000h reais + POS com X/Y/rolagem/contador; composição independente das grades, 20×10, apoio/topo, rastros, emenda/voltas, pista, HUD/glifos; artes idênticas, tempo DOS/Windows, logs sem erros/avisos |

**Resultado em 28/10/2026:** PASS MEM, PASS JIPE, três PASS AUTO, modo/página, PASS E04; PASS KEY. MOON e todas as variantes montaram sem erros/avisos. Conferidor Python passou. Tempo final: 4 s/2 ticks=34 avanços/4,06 s DOS; 4 s/4 ticks=18/4,06 s; 45 s/2 ticks=387/45,15 s. Windows=4,071/4,077/45,177 s. Esses scores/durações forçados pertencem ao teste, não à configuração normal 90 s/3 vidas/score zero.

**Limite observado:** numa execução anterior, 45,15 s DOS levaram 48,508 s Windows; não ocorreu na repetição final. Causa externa não determinada, sem alteração das rotinas do relógio. Não apresentar uma medição aprovada como garantia de precisão sob qualquer carga do host. Duas tentativas de eventos Windows no backend padrão não entregaram PostMessage; o teste passou ao usar windib. Isso não comprova o teclado físico com o backend normal.

Arquivos atuais: E04RESUL.LOG, E04KRES.LOG, E04*.LOG, E04HOST.LOG, TEMPOE42.BIN/TEMPOE44.BIN/E04TEMPO.BIN, RAW/POS e `evidencias/e04/verificacao.txt`/`inspecao.txt`. Os nomes 42/44 evitam sobrescrever tempos históricos E03. Não executar instâncias simultaneamente. Para teste DOS manual, gerar com gerar-e04.ps1 e executar `cd testes` / `E04TEST.BAT`; esse caminho não atualiza Stopwatch Windows nem realiza o teste de eventos Windows.

**Pendente de teste físico:** Assemble/Build/Run na IDE; pressionar/manter/soltar setas, simultâneas, inverter no ar, bordas e manter ↑ após pouso; observar duas voltas/ausência de rastros/cintilação/rasgos; comparar os 90 s normais com cronômetro, reiniciar e Sair. Revisar aparência autoral. Detalhes em LEIA-E04. Não testados ajuste manual da hora, suspensão do host, 24 h sem consulta, recorte parcial ou naves/colisões futuras.

## E05 — snapshot histórico desde a E06

Na raiz, sem instâncias simultâneas:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File testes\executar-e05.ps1
python testes\conferir-e05.py
```

O gerador `gerar-e05.py` e o conferidor leem **E05BASE.ASM** por padrão, registram/conferem SHA256 em E05-FONTE.txt e preservam as evidências E05. TASM 4.1/TLINK 7.1.30.1 e DOSBox 0.74-3 do pacote GUI Turbo Assembler 5.1 são os mesmos da E04. RAM usa cycles=50000; E05AUTO usa auto. Python/Pillow só geram/conferem testes. Também se pode gerar e executar `cd testes` / `E05TEST.BAT` pelo DOS; o conferidor continua necessário para validar pixels/geração. A E06 reutiliza esses auxiliares com `--fonte MOON.ASM --prefixo R06`; o conferidor recebe também `--naves`, pois o céu atual é validado em detalhe pelo conferidor E06. O roteiro completo abaixo faz isso automaticamente.

| Teste | Executado e aprovado |
|---|---|
| E05REG | Oráculo E03 no fonte atual: 320 quadros/duas voltas, composição/guardas/DF, frações/margem, pausa de 70 s e meia-noite |
| E05JIPE | Oráculo E04: 80 estados explícitos de movimento/entrada/salto e 640 quadros com/sem rolagem, comparando 65.000 bytes por quadro; D05 preservada |
| E05LOG | 362 verificações: sete saltos com AtualizarJipe/AvancarCenario/ContarTopo reais, pontuação só depois de pousar; todos os tipos colidem; uma vida por evento; tempo/score/rolagem preservados; reposição bloqueada/livre; ↑ mantida e nova pressão; recuo, obstáculo fatal, múltiplos contatos, saída sem pontos, candidato fora da tela esperando pouso, última vida e saturação |
| E05GER.BIN | 20.000 pixels executados: 199 nascimentos. Tipos 0..6 apareceram 28/35/37/28/26/19/26 vezes; espaço livre entre crateras 150..230, ambos extremos observados; folgas mínimas 60 dos dois lados da rocha |
| E05PIX | 336 quadros em RAM exportados com metadados e 1.000 bytes de guarda: sete tipos, 12 posições nas bordas/interior, movimento só do jipe, desaparecimento e recomposição com rolagem |
| Conferidor de pixels | 21.840.000 bytes comparados com composição independente das grades; recorte esquerdo/direito, FFh/00h, áreas antigas, céu/HUD/guarda. PNGs reconstruídos e prancha dos sete tipos em evidencias/e05 |
| E05AUTO | Laço real e clocks reais, sem entrada física: primeira morte natural aos 17,80 s DOS; tempo 73→71 e rolagem 302→14 durante espera/reposição. Duas mortes seguintes controladas testam última vida e score 150. Nova sessão confere reset, depois expiração de teste em 4,06 s com score 250 |
| Vetor/saída | IRQ restaurada após vidas/tempo, retorno pelo BIOS e Sair pelo fluxo normal. MODO confirma modo 03h/página 0 |
| Inspeção | Fonte ASCII/.8086, cabeçalhos de rotinas, artes E02 idênticas, 13 rotinas de salto/cenário/HUD/relógio/Game Over idênticas à E04; dados 35.072 bytes |

**Resultado real:** MOON, E05REG, E05JIPE, E05LOG, E05PIX e E05AUTO montaram sem erros/avisos; E05RESUL.LOG termina em PASS E05; conferidor aprovado. Evidências: E05*.LOG/BIN, E05MORT/E05REPO/E05FIM.RAW, E05-FONTE.txt e `evidencias/e05/verificacao.txt`. As imagens mostram morte/reposição e sete tipos, mas são dumps reconstruídos, não filmagem/teclado físico. Fonte SHA256 `F5BA545D4B333C3D5F25397251E83386F2D20AFBBB5AD0103E9940BC888CB91F`.

Na revisão do gerador, removida a dependência de arquivos ASM previamente gerados pela E04: ele usa diretamente os harnesses INC e seus dados de teste. E05REG/E05JIPE foram montados e executados novamente, aprovados em `E05RRES.LOG` (`E05REGR.BAT`). Os ASM de lógica/pixels/fluxo permaneceram idênticos por hash, assim como MOON; suas evidências anteriores continuam válidas. O conferidor final também passou e exige os extremos 150/230 e folgas 60 observados.

**Pendente no encerramento histórico E05:** botões da IDE no fonte E05; teclado físico e combinação/soltura de setas, inclusive morte com ↑ mantida; avaliação da janela de salto conservadora das rochas, aparência/fluidez/cintilação; sessão normal de 90 s e comparação externa. Os scores 150/250, poses, vidas e duração curta usados nos testes não mudam 90 s/3 vidas/score zero do EXE normal. E05 não repetiu o teste de eventos Windows da E04; manteve suas evidências históricas e executou regressão lógica do handler, incluindo estado ausente. Naves/tiros não existiam naquele snapshot; naves agora estão na E06 abaixo.

## E06 — snapshot histórico desde a E07

Implementação e execução registradas em 29/10/2026; documentação finalizada em 31/10, mantendo o mesmo hash testado. Na raiz, sem instâncias simultâneas:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File testes\executar-e06.ps1
python testes\conferir-e06.py
```

Desde a E07, `gerar-e06.py`/`conferir-e06.py` leem **E06BASE.ASM** por padrão. O gerador registra E06-FONTE.txt e gera E06LOG/E06PIX, reutilizando `gerar-e05.py` com esse snapshot e prefixo R06; estende R06AUTO com verificações das naves no laço real. Na sessão histórica E07, o gerador passava `--fonte MOON.ASM --prefixo E07 --regressao R07` e usa seu próprio conferidor. Nenhuma variante muda MOON ou resultados históricos. O executor usa TASM 4.1/TLINK 7.1.30.1 no DOSBox 0.74-3 da GUI Turbo Assembler 5.1. `cycles=50000` para RAM; `auto` para fluxo real. Python/Pillow só geram/conferem evidências. O conferidor também chama a regressão com `--naves`; o céu é conferido separadamente, pixel a pixel.

| Teste | Execução e alcance |
|---|---|
| E06LOG | 48 verificações explícitas: contagem/remoção única, repetição e índices inválidos; última nave bloqueia mesmo fora da direita ou parcialmente à esquerda; saída X=-14; ausência de pontos; cadência/tick repetido/wrap; jipe 6 px versus nave 1 em duas amostras; morte preserva grupo/semente/cadência |
| E06GER.BIN | 4.096 sementes executadas no ASM. Nove combinações quantidade/tipo, 449..464 ocorrências cada; X inicial 320/335, Y 15/86, fim da faixa 480 e gap livre 30 observados; geometria, atividade e ausência de sobreposição conferidas externamente |
| E06GRP/E06MIX | 20.000 passos intercalados: 48 grupos, 20 repetições consecutivas de tipo e 394 obstáculos em 40.000 pixels. Instantes de nascimento conferem exatamente o passo posterior à última saída; sete tipos terrestres presentes, crateras 150..230 e folgas >=60 preservadas |
| E06PIX | 390 quadros, todos os tipos, Y=15/86 e 13 posições nas bordas/interior/fora da tela; fases de movimento só das naves, só do jipe, remoção e rolagem com jipe ausente. Exporta metadados + 65.000 bytes por quadro, incluindo guarda e verificação DF |
| conferir-e06.py, pixels | 25.350.000 bytes comparados com composição independente das grades autorais; transparência/recorte, áreas anteriores, HUD/terreno e guarda. Não usa a saída anterior como imagem esperada |
| R06REG/R06JIPE | Oráculos E03/E04 no fonte atual: cenário/duas voltas, guardas, relógio, 80 estados de jipe e 640 quadros com/sem rolagem; D05 preservada |
| R06LOG/R06PIX | 362 verificações terrestres, sete saltos, colisões/vida/reposição/pontos/saturação, 199 nascimentos em 20.000 pixels e 336 quadros/21.840.000 bytes. Conferidor E05 reutilizado com nomes separados |
| R06AUTO/E06AUT.BIN | Programa inteiro, BIOS nas telas, relógios reais: 167 passos de naves antes de concluir primeira reposição; Y/grupo persistem na morte, nova partida reinicia lista/cadência. Primeira morte natural 19,28 s DOS; tempo 71→69; última vida, expiração separada 4,12 s, score e IRQ/restauração/modo aprovados |
| R06MORT/R06REPO.RAW | Dois dumps reais de A000h: céu comparado com quatro registros de estado em E06AUT.BIN; tipos/posições e remoção do jipe coerentes. PNGs em evidencias/e06 |
| Inspeção | Fonte ASCII/.8086 e cabeçalhos; 17 artes e 48 rotinas antigas idênticas, integração em três existentes e sete novas. Dados 35.100 bytes; buffers 320/200 |

**Resultado:** MOON e sete variantes sem erros/avisos; `R06RESUL.LOG` termina PASS R06 e `E06RESUL.LOG` termina PASS E06; ambos sem FAIL. Conferidor E06 e regressão aprovados. Fonte SHA256 `E87893D6D70B330A3843C4739FD2AAB69000EF8EDF98775E0C02C18D517F2158`. Relatórios em `evidencias/e06/verificacao.txt` e `evidencias/e06/regressao/verificacao.txt`. Os 394 nascimentos intercalados incluem todos os tipos terrestres, contagens 57/65/75/53/48/43/53. Sementes fixas, poses, scores e tempo curto são somente dos testes.

Também se pode gerar com `python testes/gerar-e06.py` e executar `cd testes` / `E06TEST.BAT` no DOS; o conferidor externo continua necessário. Se qualquer compilação/teste falhar, não interpretar a montagem antiga ou um PASS de outra variante como aprovação do conjunto. O executor e o conferidor exigem os dois logs de resultado.

**Pendente:** teclado físico, botões Assemble/Build/Run no fonte atual, percepção de fluidez/cintilação/rasgos e conforto dos saltos, 90 s normais com cronômetro externo. Não repetidos os eventos Windows E04, nem medida externa Windows da duração nesta etapa. Não testados suspensão/ajuste manual de hora/24 h sem consulta. RemoverNave foi testada por chamada direta para preparar E08; não há tiro funcional. As imagens são dumps reconstruídos, não filmagem/teste físico. Roteiro em LEIA-E06 e prompt de retomada E06; E07 não iniciada.

O parágrafo anterior registra o encerramento histórico da E06. A E07 vigente está abaixo; o roteiro físico atual está em LEIA-E07.

## E07 — snapshot histórico desde a E08; integração em 31/10/2026

Na raiz, sequencialmente e sem outras instâncias dos testes:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File testes\executar-e07.ps1
python testes\conferir-e07.py
```

`gerar-e07.py` usa E07BASE por padrão e chama o gerador E06 com esse snapshot e nomes E07/R07; aceita `--fonte/--prefixo/--regressao` para reutilização, acrescentando E07MEM e E07TELA. Os geradores reutilizados continuam lendo snapshots por padrão e aceitam a fonte/prefixos explícitos, preservando evidências E05/E06. O conferidor E07 reaplica os oráculos e verifica as diferenças de apresentação separadamente: 55 rotinas e constantes de jogo idênticas à E06; EntrarSetor/EntrarGameOver ajustadas e MostrarAvisoDemo removida. Não há alteração de regra para fazer os testes passarem.

| Execução | Resultado e alcance |
|---|---|
| Montagem | MOON e nove variantes (cinco R07 e E07LOG/PIX/MEM/TELA) sem erros/avisos; TASM 4.1/TLINK 7.1.30.1, DOSBox 0.74-3 do GUI Turbo Assembler 5.1. RAM com cycles=50000; fluxo/telas com auto |
| E07MEM | Harness E02 sobre o fonte atual: 400 quadros/duas voltas por objeto, restauração de fundo sobreposto/listrado, dimensões, 8 retângulos inválidos, FFh/00h, DF e guarda de 1.000 bytes |
| E07TELA | 320 quadros por ticks em 35,15 s DOS; navegação real pelas rotinas BIOS, seleção/teclas ignoradas; SETOR aguardou 2,03 s sem consumir tempo; Enter antigo descartado, nova partida com 90 s; Game Over 65535, retorno por letra/seta e Sair |
| Seis RAW | E07INI/MOV/SEL/SET/FIM/RET: 64.000 bytes cada, cores, sprites/área animada, área estática, aviso removido no fim e retorno idêntico ao menu inicial. ASCII/TAAG preservado; PNGs reconstruídos e menu/setor/fim inspecionados visualmente |
| E07LOG/E07PIX | Mesma cobertura de naves da E06 no fonte atual: 48 verificações, 4.096 sementes, nove combinações, 48 grupos e 394 obstáculos intercalados, 390 quadros/25.350.000 bytes, bordas/remoção/DF/guardas |
| R07REG/R07JIPE | Cenário, relógio, duas voltas e guardas; 80 estados do jipe e 640 quadros, limites/teclas/salto D05; lógica e desenho preservados |
| R07LOG/R07PIX | 362 verificações terrestres, sete saltos, pontos/vida/reposição/saturação, 199 nascimentos e 336 quadros/21.840.000 bytes; tipos e distâncias mantidos |
| R07AUTO | Laço real: morte natural em 19,22 s DOS, tempo 71→69 durante reposição, grupo preservado com 167 passos, última vida/score, nova sessão/reset e expiração curta separada 4,12 s/score 250; IRQ e modo/página restaurados |
| Inspeção | `.8086`, ASCII, cabeçalhos, constantes e gráficos por memória; 17 artes e 55 rotinas E06 intactas. Dados 35.105 bytes (08921h), buffers 320/200, pilha 100h |

**Resultado real:** R07RESUL.LOG termina PASS R07 e E07RESUL.LOG termina PASS E07, sem FAIL; todos os conferidores aprovados. SHA256 MOON `FCA3099062C1F4BF34EB1EAADE7E98991587453E6D5A77B83A7025DBCBE10901`. Evidências em `evidencias/e07/verificacao.txt`, `regressao-naves.txt` e `regressao/verificacao.txt`. Snapshot E06BASE tem hash `E87893D6D70B330A3843C4739FD2AAB69000EF8EDF98775E0C02C18D517F2158` e não foi modificado pelos testes.

Matriz T01–T16 com evidências/limites em `planejamento/13-validacao-e-entrega.md`. T17–T20 são **não aplicáveis ao mínimo**, não aprovados como versão completa. E07MEM/E07TELA testam rotinas reais; R07AUTO exercita o laço completo. BIOS nas telas, scans sintéticos e poses/sementes/scores/tempo curto controlados são distintos do teclado físico e da configuração normal do jogo.

**Pendentes:** teclado físico, botões da IDE no fonte atual, conforto dos saltos, fluidez/cintilação/rasgos, 90 s normais com cronômetro externo. Sem nova medição externa Windows, sem repetição dos eventos Windows E04, sem relato físico novo registrado. A integração está verificada automaticamente; a validação física para apresentação não está concluída. Esse era o encerramento histórico E07. A versão atual E08 e suas pendências estão abaixo.

## E08 — registro histórico de 01/11/2026; harnesses reutilizados na E09

Na raiz, sequencialmente, sem outras instâncias:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File testes\executar-e08.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File testes\executar-teclado-e08.ps1
python testes\conferir-e08.py
```

- **Montagem:** MOON e 13 variantes sem erros/avisos em TASM 4.1/TLINK 7.1.30.1/DOSBox 0.74-3 do GUI Turbo Assembler 5.1. RAM cycles=50000, fluxo auto.
- **E08LOG:** 426 verificações T17–T20: dois canhões no chão/salto, independência, capacidade, cadência, scan de Espaço, alcance 50, linha15, naves/100, resistências, pontos únicos, inimigos/pista/jipe, reposição, grupos e reset.
- **E08PIX:** 170 quadros/11.050.000 bytes, oráculo independente por grades. Céu/terreno/jipe/tiros, transições em Y=100, 8/8/12 vagas, recorte, remoção, captura e 1.000 bytes de guarda. HUD sentinela preservado; HUD real é coberto pela regressão.
- **E08AUTO:** rotinas do fluxo completo e clocks reais; encontro controlado de rocha+nave (+150), jipe colocado na trajetória do branco após destruir a nave, uma morte/reposição; expiração de 6 s (6,21 DOS / 6,178 Windows), última vida, reset, IRQ e Sair. Poses/tempo forçados apenas no teste.
- **E08KEY:** nove estágios Windows→SDL windib→DOSBox→IRQ1: setas/salto/soltura e Espaço no salto, pares independentes, nova pressão e retorno BIOS. Janela oculta, sem eventos em outros aplicativos. Não é teclado físico/backend normal.
- **N08/R08:** mesmos oráculos do mínimo, sobre o fonte E08 e com nomes novos. 4.096 sementes, 48 grupos/394 obstáculos, 362 verificações terrestres/sete saltos, 80 estados/640 quadros do jipe, 390 quadros de naves/336 terrestres, cenário/relógio/telas/menu. **Somente R08AUTO desabilita emissão inimiga na variante** para isolar seu oráculo antigo; E08AUTO inclui todos os disparos. MOON não é alterado por esse isolamento.

Logs principais E08RESUL/N08RESUL/R08RESUL/E08KRES; hashes E08-FONTE/E08K-FONTE/N08-FONTE/R08-FONTE; E08HOST.json contém Stopwatch entre sinais DOS (polling 10 ms). Relatórios em `evidencias/e08/`: verificacao, regressao-naves, regressao-telas e regressao/verificacao. O conferidor exige os logs e hashes, monta a imagem esperada sem usar a captura anterior e rejeita divergências.

E07BASE preserva exatamente o fonte anterior (FCA30990…10901); gerador/conferidor E07 agora o usam por padrão, e E05/E06 continuam em seus snapshots. Os parâmetros adicionais de saída dos conferidores evitam sobrescrever evidências históricas. E08RAP é um ensaio intermediário de desenvolvimento; a aprovação final vem da suíte completa acima.

**Pendentes no encerramento histórico E08:** botões Assemble/Build/Run atuais, teclado físico, conforto/esquiva/fluidez/rasgos e 90 s normais com cronômetro externo. Aluno informou que ainda não fez os testes manuais E07. PNGs são memória reconstruída, sem comprovar percepção humana. E09 ainda não havia sido iniciada naquele registro.

## E09 — revisão em 02/11 e conferência final em 06/11/2026

**Posterior, 07/11:** passo lateral e artes mudaram. Usar os [ensaios específicos dos ajustes](../evidencias/ajuste-jogabilidade/README.md) para o fonte atual. Os testes históricos de passo 3 e igualdade integral de artes deixam de ser expectativas válidas para esta revisão. Descoberto PATH T: sem Z:, que ocultava CONFIG.COM; a medição nova exige comando por caminho absoluto e conferência da CPU efetiva. Não atribuir automaticamente a alternância de ciclos declarada no histórico às execuções antigas.

MOON atual só corrige comentários da E08; E08BASE conserva o fonte anterior, hash 27B2C491…DCB1A. E07BASE e 135 artefatos históricos/snapshots conferidos por hash. Os 69 procedimentos mantêm função/entrada/saída; jogo sem alteração de dados, instruções ou constantes.

Suíte executada em 02/11: PASS R08/N08/E08, sem erros/avisos. A primeira tentativa abortou quando o PowerShell leu um sinal ainda aberto pelo DOSBox; tratada IOException transitória nos executores E08/KEY, mantendo timeout e exigência dos sinais. Repetição completa aprovada. KEY executado em 06/11: nove etapas aprovadas e hash do fonte atual. Conferidor completo aprovado em 06/11, expiração de 6 s = 6,21 s DOS / 6,223 s Windows.

Reprodução dos testes e comando de conferência com datas separadas em [LEIA-E09](../LEIA-E09.md). Use `--saida` para preservar relatórios históricos; os arquivos gerados E08/N08/R08 em testes representam a execução mais recente. [Evidências E09](../evidencias/e09/README.md) guardam relatórios, logs, medidas e inventário.

Assemble/Build/Run atuais e ciclo do EXE normal foram executados por acessibilidade/PostMessage na IDE em 02/11, com [registro próprio](../evidencias/e09/gui-validacao.md). Isso elimina a falta de evidência dos botões atuais, mas não equivale a teste físico. R08AUTO continua isolando somente a emissão inimiga; E08AUTO inclui os tiros. Permanecem teclado físico, conforto/esquiva/fluidez e 90 s normais externos. Apresentação e submissão são obrigações separadas.
