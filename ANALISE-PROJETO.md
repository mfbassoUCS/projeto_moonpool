# Análise do código contra o checklist do professor

**Registro histórico de 07/11/2026. Correções posteriores em 08/11:** o avanço excedente do topo (1.1), a regressão desatualizada e a propagação de falhas foram corrigidos; a suíte completa passou. A referência do topo continua sendo o terreno, declarada como interpretação D05. Consulte [CORRECOES-AUDITORIA.md](CORRECOES-AUDITORIA.md) e o [checklist técnico atual](CHECKLIST-PROFESSOR-VERIFICADO.md). As conclusões e medidas abaixo descrevem o fonte antigo; não devem ser lidas como defeitos ainda abertos.

Auditoria realizada em **07/11/2026**, sobre o `MOON.ASM` presente nesta pasta. Foram examinados o código executável, os bytes das artes, os geradores de testes, os conferidores, os lançadores e a configuração de montagem. O checklist foi usado como critério; afirmações de aprovação nos outros documentos não foram tratadas como prova.

**Organização posterior, em 08/11/2026:** o [checklist principal](CHECKLIST-PROFESSOR.md) passou a ser um roteiro de jogador. Os 115 IDs e seus requisitos foram preservados na [cópia técnica preenchida](CHECKLIST-PROFESSOR-VERIFICADO.md), usando os resultados desta auditoria. Essa revisão documental não corrigiu o jogo nem alterou os resultados técnicos abaixo.

**Conclusão: a implementação contém as funcionalidades do mínimo e os disparos complementares, mas não é correto afirmar que está tudo aprovado.** Há uma divergência mensurável no topo do salto, testes desatualizados e condições de aceitação que exigem teclado físico, apresentação ou esclarecimento do professor. Não encontrei ausência de um subsistema obrigatório, nem falha de montagem, nas verificações realizadas.

O código do jogo e as caixas do checklist não foram alterados. A execução da suíte regenerou seus arquivos derivados e recompilou `MOON.EXE`; o executável resultante ficou **idêntico, byte a byte pelo SHA256, ao executável anterior**. Os ensaios adicionais e os resultados desta análise estão em [evidencias/auditoria-2026-11-07](evidencias/auditoria-2026-11-07).

## 1. Pontos que impedem dizer “está tudo certo”

### 1.1. J07: o topo não corresponde literalmente a 5 pixels de deslocamento

**Prioridade alta para esclarecer a conformidade.** Em [MOON.ASM](MOON.ASM), linhas 1120–1121, o programa chama `ContarTopo` com `PASSO_CENARIO`, e não com o deslocamento do jipe. A rotina, nas linhas 1383–1397, acumula passos de 2, compara com 5, grava 5 e libera a descida.

Assim, o terreno realmente percorre **2, 4, 6 pixels**. Gravar 5 no contador não transforma os 6 pixels percorridos em 5. A referência também é o terreno, não a posição horizontal do veículo.

O ensaio `TOPO.ASM`, que chama as rotinas reais sem modificar sua implementação, registrou:

| Tick lógico | X do jipe | Y do jipe | Estado | Rolagem | Contador do topo |
|---|---:|---:|---|---:|---:|
| 5 | 65 | 168 | Topo, recém-alcançado | 4 | 0 |
| 6 | 70 | 168 | Topo | 6 | 2 |
| 7 | 75 | 168 | Topo | 6 | 2 |
| 8 | 80 | 168 | Topo | 8 | 4 |
| 9 | 85 | 168 | Topo | 8 | 4 |
| 10 | 90 | 171 | Primeira descida | 10 | 5 |

O jipe percorre 20 pixels entre o primeiro e o último quadro no topo; até a primeira atualização de descida, percorre 25. O terreno avança 6 nesse intervalo completo.

**Veredito de J07:** não atende literalmente à medida de 5 pixels; permanece uma decisão a esclarecer se o professor aceitar referência no terreno e discretização. Não classifiquei isso como “cinco frames corretos”. A subida e a descida de 3 pixels e a altura de 15 estão corretas.

Evidência: [resultados.json](evidencias/auditoria-2026-11-07/resultados.json), campos `trajeto` e `trajeto_colunas`; [TOPO.ASM](evidencias/auditoria-2026-11-07/TOPO.ASM).

### 1.2. A regressão oficial não passa com a versão atual

**Prioridade alta para confiabilidade da validação.** Executei `testes/executar-e08.ps1` sobre o fonte atual. A montagem passou, mas o executor terminou com erro:

| Verificação | Resultado novo | Causa identificada |
|---|---|---|
| `R08REG` | Passou | Cenário, memória, duas voltas e relógio. |
| `R08JIPE` | `FAIL JIPE fase=1 caso=00012` | `E04CASOS.INC`, linha 17, espera X=137 após sair de X=140 para a esquerda; o passo atual de 5 produz X=135. |
| `N08LOG` | `FAIL N08 caso=00043` | `gerar-e06.py`, linha 78, espera X=6 depois de dois movimentos; o código atual produz X=10. |
| Conferidor Python completo | `AssertionError` | `conferir-e06.py`, linha 26, exige que as artes sejam idênticas às do snapshot antigo. |
| `E08LOG` | Passou | 426 verificações de combate. |
| `E08PIX` + conferidor de pixels | Passou | 170 quadros, incluindo HUD e área de guarda. |
| `E08AUTO` | Passou nesta execução | Fluxo controlado de seis segundos, morte, reposição, reset e retorno. |

Em cópia isolada de `N08LOG`, alterei **somente a expectativa do caso 43, de 6 para 10**. O teste então passou, incluindo as 4.096 sementes e a geração mista. Nenhuma rotina do jogo foi modificada.

Há outras expectativas antigas ainda no código dos testes:

- `testes/E08KEY.INC`, linhas 16, 24 e 57: deslocamentos 3, 6 e subtração de 3. Inspecionado, não reexecutado nesta auditoria.
- `testes/gerar-e05.py`, linha 81: espera X=3 na reposição seguida de movimento.
- `testes/conferir-e05.py`, linhas 25–33: exige artes e procedimentos idênticos aos antigos.
- `testes/conferir-e07.py`, linhas 21–25: exige constantes idênticas às antigas.

Essas falhas não provam, sozinhas, defeito na movimentação atual. Provam que a suíte precisa distinguir requisitos permanentes de decisões ajustáveis e mudanças intencionais. Também não basta ignorar todas elas: a mudança de velocidade alterou travessias, como mostra o próximo ponto.

Evidências: [R08RESUL.LOG](evidencias/auditoria-2026-11-07/R08RESUL.LOG), [N08RESUL.LOG](evidencias/auditoria-2026-11-07/N08RESUL.LOG), [E08RESUL.LOG](evidencias/auditoria-2026-11-07/E08RESUL.LOG), [N08LOG.LOG isolado](evidencias/auditoria-2026-11-07/N08LOG.LOG).

### 1.3. Uma travessia antes segura passou a colidir; ainda existem saltos seguros

**Prioridade média para jogabilidade e atualização dos testes.** Executei separadamente `R08LOG`, que a suíte normal não alcança após a primeira falha. Ele falha no caso 96, durante o salto sobre a rocha 1.

Arranjo: jipe em X=0, rocha em X=31, seta direita e salto juntos. No segundo passo, o jipe está em X=10/Y=177; a rocha foi para X=29. O retângulo do jipe ocupa X=[10,30), Y=[177,187), e a rocha X=[29,41), Y=[183,193). Existe sobreposição real. A colisão é coerente com esses retângulos; o novo avanço lateral chega à rocha antes de obter altura suficiente.

Isso **não significa que a rocha ficou impossível de saltar**. Executei 854 tentativas controladas: sete tipos, duas fases relativas entre cenário e jipe, 61 distâncias de início. Todos os sete tipos tiveram travessias seguras, com +50 e sem perder vida.

No arranjo com jipe em X=20 e direita mantida, as rochas tiveram janelas seguras de **17–33 pixels de espaço livre** numa fase e **19–40** na outra. Crateras tiveram janelas maiores. Esses valores não são tolerâncias do professor nem garantia de conforto humano; descrevem apenas esse ensaio, sem tiros ativos.

A consequência prática é reaprender o momento de saltar e testar próximo ao limite X=140. Atingir o limite reduz o avanço relativo disponível para cruzar o obstáculo. J09 pede ausência de travamento; não garante que qualquer momento de salto será seguro.

Evidências: [R08LOG.LOG](evidencias/auditoria-2026-11-07/R08LOG.LOG), [SALTOS.ASM](evidencias/auditoria-2026-11-07/SALTOS.ASM), [resultados.json](evidencias/auditoria-2026-11-07/resultados.json).

### 1.4. Um `PASS E08` isolado pode esconder falhas das regressões

**Prioridade média para os testes.** `E08TEST.BAT` chama `N08TEST.BAT`, que chama `R08TEST.BAT`, mas não verifica o resultado da chamada imediatamente. Nesta execução, os logs de R08 e N08 contêm `FAIL`, enquanto o log E08 termina com `PASS E08`.

O executor PowerShell fez a coisa correta ao ler os três logs e rejeitar o resultado global. Quem executar só o BAT ou consultar só `E08RESUL.LOG` poderá interpretar aprovação parcial como aprovação completa. Os geradores dos BAT também precisam ser atualizados; editar apenas os arquivos gerados não resolve a origem.

### 1.5. Algumas condições não são decididas pelo código

- **Q07:** os bitmaps têm as dimensões certas e correspondem às grades locais. A fidelidade às figuras do professor continua sem comprovação; autorização do aluno para artes autorais não equivale a aceite do professor.
- **N06:** a implementação interpreta “metade horizontal” como largura máxima de 160 pixels da formação criada na faixa X=[320,480). As naves atravessam a tela. O código não esclarece a intenção do enunciado.
- **R09:** os dois impactos na rocha 4 são acumulados na mesma rocha, sem prazo e sem reiniciar por tiro perdido ou morte do jipe. Isso está implementado consistentemente, mas “consecutivos” pode exigir outro entendimento.
- **Q08:** somente o ambiente local TASM/TLINK/DOSBox foi exercitado. “Ambas as plataformas” continua sem definição verificável.
- **P03, C08, H04/H06, I03, J10, V11 e itens acadêmicos:** teclado físico, fluidez percebida, partida normal de 90 segundos, facilidade de esquiva e apresentação ainda precisam de confirmação apropriada.

## 2. O que foi confirmado diretamente

O programa principal tem **2.862 linhas e 69 procedimentos**. Sua máquina de estados conecta menu, setor, partida, Game Over e saída. O laço não bloqueia aguardando teclado; os movimentos têm cadências próprias e o tempo usa a hora DOS, separadamente dos movimentos.

| Área | Evidência no código | Resultado técnico |
|---|---|---|
| Montagem 8086 | `.8086`, modelo small, TASM 4.1 e TLINK 7.1.30.1 | Montagem e link novos sem erros ou avisos. |
| Vídeo | Linhas 8–12, 660–675 e rotinas a partir de 1711 | Modo 13h, segmento A000h, 320×200 e 64.000 bytes. |
| Escrita de gráficos | `DesenharBitmap`, `SalvarFundo`, `DesenharSprite`, `DesenharSpriteRecortado` | `mov es:[di]`, acesso indireto e operações de strings; BIOS é usada para modo/texto, não para desenhar sprites pixel a pixel. |
| Memória | `MOON.MAP` | Código 4.854 bytes, dados 35.431 bytes, stack 256 bytes. Dados cabem no segmento. Ensaios de guarda passaram nos caminhos exercitados. |
| Documentação | Cabeçalhos dos 69 procedimentos | Todos contêm função, entrada e saída. Isso não comprova o domínio do conteúdo pela equipe. |
| Artes | Decodificação dos `DB`/`DUP` e comparação com `desenhos.json` | Todos os 17 bitmaps coincidem, byte a byte, com as grades atuais. |
| Título/fim | Dados ASCII e `artes/taag.json` | Os três blocos coincidem com a saída TAAG armazenada localmente. Não foi feita nova captura externa. |
| Reutilização | Tabelas por tipo, funções comuns de desenho, colisão e pontuação | Não há cópia de lógica para cada variante de nave/rocha/cratera. As variantes de desenho têm contratos diferentes justificáveis. |

Medidas dos dados, verificadas sem confiar só nas constantes:

| Elemento | Largura × altura | Bytes por variante |
|---|---|---:|
| Jipe | 20×10 | 200 |
| Cada uma das três naves | 14×14 | 196 |
| Cada indicador de vidas 3/2/1 | 18×11 | 198 |
| Relógio | 7×8 | 56 |
| Cada uma das três crateras | 14×7 | 98 |
| Cada uma das quatro rochas | 12×10 | 120 |
| Montanhas | 320×64 | 20.480 |
| Montes | 320×32 | 10.240 |

O terreno é composto de Y=100 até Y=192; a pista ocupa Y=193–199, com sete pixels de altura. A rolagem é circular e independe da capacidade do jipe de continuar avançando. No ensaio novo do limite, **X permaneceu em 140 enquanto cenário e rocha avançaram 56 pixels**, tanto com direita mantida quanto sem tecla; os pixels do relevo também foram conferidos.

As velocidades nominais, se o laço acompanhar os ticks BIOS, são aproximadamente: jipe **91 px/s**, naves **9,1 px/s**, terreno **18,2 px/s** e tiros inimigos **36,4 px/s**. O valor do comentário “jipe ~55 px/s” está antigo; o cálculo correto usa `PASSO_JIPE=5`. Esses números não são FPS medidos nem promessa de fluidez. O código executa um passo quando a cadência vence, sem recuperar todos os passos perdidos se a composição atrasar.

## 3. Comparação com todos os 115 itens do checklist

Legenda: **C** = há implementação coerente identificada no código; **E** = também há evidência de execução controlada nesta auditoria; **D** = interpretação/aceite pendente; **NT** = condição não comprovada aqui. **E não substitui J:** um requisito marcado como teste físico no checklist continua exigindo a rodada física. As classificações abaixo não são caixas de aprovação do professor.

| IDs | Avaliação | Evidência e limite |
|---|---|---|
| P01 | Parcial / NT | Data, fonte e ferramentas registrados; nomes dos testadores físicos, computador e configuração final da IDE ainda precisam de registro. |
| P02 | E parcial | TASM/TLINK distribuídos com GUI Turbo Assembler executados no Windows; não houve operação nova dos botões da IDE. |
| P03 | NT | Não usei teclado físico nem comprovei foco na rodada humana. |
| P04 | Parcial | Houve Stopwatch Windows no ensaio de 6 s; preparação de cronômetro/vídeo para a partida normal segue pendente. |
| M01, M02 | C + E | ASCII no alto e cor 0Ah; bytes coincidem com TAAG local. `EntrarMenu`, linha 774. |
| M03, M04 | C + E | Jipe e três naves entre título e opções; +2 pixels e retorno à esquerda. 400 quadros em RAM e 320 atualizações de menu real. |
| M05, M06 | C + E | Jogar/Sair, caixas com 218/191/192/217/196/179; geometria e memória exercitadas. Aparência no monitor final requer inspeção física. |
| M07, M08 | C + E | Leitura não bloqueante, alternância por cima/baixo, seleção 0Ch e outra opção 0Fh; cores verificadas nos dumps. |
| M09, M10 | C + E | Enter inicia setor; Sair encerra, inclusive depois de retorno. Fluxos sintéticos passaram. |
| F01 | C + E / D | `EntrarSetor`, linha 839: SETOR 1 e Enter. Existência confirmada; aparência/tecla são escolha do projeto. |
| F02 | C + E | Uma fase, pista plana, nave com Y fixo durante a trajetória. |
| F03, F04 | C + E | HUD 0–14, céu 15–99, cenário desde 100 e pista 193–199; modo/memória corretos. |
| H01 | C + E / D | Score à esquerda, vidas no centro e relógio/tempo à direita. Segue o texto; a divergência com a figura permanece identificada. |
| H02, H03 | C + E | `DesenharStatus`, linha 1659, seleciona 3/2/1 e limpa HUD; dimensões 18×11 e 7×8 verificadas. |
| H04 | C + E parcial | `ConsumirTempo`, linha 1518, acumula centésimos e retira segundos. Há margem inicial de 60 ms. Medição contínua normal ainda NT. |
| H05 | C + E | Pontos e campos decimais de cinco dígitos; HUD é limpo antes de reimprimir. Saturação em 65.535 evita wrap. |
| H06 | C + E parcial / NT | Encerramento por tempo passou com 6 s controlados; partida normal completa de 90 s com vidas restantes não foi realizada. |
| H07 | C | Duração, passos e ticks são constantes, com diversas verificações de montagem. |
| C01, C02 | C + E | Relevo varia horizontalmente, bitmaps 320×64/320×32 e desenho desde Y=100; fica dentro da altura máxima permitida. |
| C03 | C + E | Pista amarela 0Eh, sete linhas, de margem a margem, descontados os obstáculos desenhados sobre ela. |
| C04 | C + E | `AvancarCenario` é independente do limite do jipe. Ensaio no limite confirmou avanço de 56 pixels com/sem direita. |
| C05, C06 | C + E | Composição circular e 320 quadros de teste com duas voltas. Ausência de interrupção perceptível na máquina final é teste físico. |
| C07 | C + E | Obstáculos e terreno usam o mesmo `PASSO_CENARIO`; posições relativas preservadas. |
| C08 | E parcial / NT | 170 quadros de combate comparados com composição esperada, HUD e guarda íntegros; cintilação/rasgos durante a escrita e fluidez humana não são provados por dumps finais. |
| J01 | C + E | Sprite 20×10 em todos os estados; chão em Y=183, junto da pista em 193. |
| J02, J03 | C + E / D | Setas corretas; origem X=0–140, último pixel até 159. Limite considera o sprite inteiro, explicitamente. |
| J04 | C + E | Jipe 5 px por tick contra nave 1 px por dois ticks. Teste de dois movimentos passou com expectativa atualizada para X=10. |
| J05 | C + E | Salto por borda de pressão; deslocamento lateral é processado antes da etapa vertical, inclusive no ar. |
| J06, J08 | C + E | Sequências Y=180,177,174,171,168 e 171,174,177,180,183 medidas nas rotinas reais. |
| J07 | Divergência / D | Referência no terreno; limiar 5 cruzado após 6 pixels reais. Ver achado 1.1. |
| J09 | C / E parcial | Topo depende da rolagem, não de conseguir mover X; não trava por estar parado/no limite. Conforto e quatro modalidades físicas ainda pendentes. |
| J10 | C / NT físico | IRQ1 rastreia pressões/solturas e bits simultâneos; duas laterais resultam em neutro. Teste KEY existente tem expectativas antigas. |
| O01, O02 | C + E | Três tipos diferentes, sorteados pela direita; bytes 14×7 conferidos. |
| O03 | C + E / D | 150–230 pixels livres entre bordas; menor intervalo 150 observado no ensaio. Convenção explícita, não distância entre origens. |
| O04 | C + E | Travessias reais seguras para as três crateras no ensaio de 854 tentativas. |
| O05 | C | `ConferirObstaculos`, linha 1983: sobreposição horizontal no chão mata; pousar sobre a cratera também. |
| O06, O07 | C + E parcial | Estados FRENTE/SOBRE/CRUZOU/PONTO e INVALIDO; +50 após cruzar e pousar seguro, uma vez. Saída simples não pontua. A regressão terrestre integral não passou. |
| R01, R02, R03 | C + E | Quatro tipos de 12×10, alternados com crateras e sorteados; folga mínima de 60 px em ambos os lados, verificada em geração mista. |
| R04 | C + E | Saltos seguros com +50 para os quatro tipos, nas duas fases do ensaio. O antigo caso de salto próximo falha; ver 1.3. |
| R05 | C + E | Colisão por retângulos, incluindo descida; caso 96 reproduz colisão durante subida insuficiente. |
| R06, R07, R08 | C + E | Tipo 1 consome tiro sem destruir; tipos 2/3 desaparecem com um impacto. Testes E08 passaram. |
| R09 | C + E / D | Rocha 4 exige dois impactos acumulados; nenhum prazo/reset por erro. Interpretação de consecutivos pendente. |
| R10, R11 | C + E | +50 só na destruição; primeiro impacto da rocha 4 não paga; objeto já pontuado pelo salto não paga novamente. |
| N01 | C + E | Três bitmaps diferentes de 14×14. |
| N02 | C + E | Nascimento X≥320, movimento para esquerda e Y constante. |
| N03, N04 | C + E | 1–3 naves, um tipo por grupo; todas as nove combinações quantidade/tipo apareceram nas 4.096 sementes. |
| N05 | C + E | X/Y variam entre sementes e grupos; limites verificados nos arquivos binários. |
| N06 | D | Formação inteira cabe em 160 px em [320,480); não resolve a ambiguidade do enunciado. |
| N07, N08 | C + E / D | Y=15–86, sprite até 99, pelo menos 30 pixels livres entre bordas; sem sobreposição. Convenção documentada. |
| N09, N10, N11 | C + E | Remove quando X+14≤0; conta todas as ativas, inclusive fora da direita; 48 grupos mistos conferidos, sem renovação antecipada. |
| N12 | C + E | Remoção de nave e contagem ativa governam o próximo grupo; destruição parcial não libera geração. |
| T01 | C + E | Reserva espaço nas duas listas antes de emitir o par; ambos nascem ou nenhum. |
| T02, T03, T04 | C + E | Superior amarelo sobe; nave e tiro removidos no impacto, +100 único; sem alvo, termina em Y=15. |
| T05 | C + E | Listas independentes e vagas fixas; disparos anteriores não são sobrescritos. |
| T06, T07 | C + E | Frontal vermelho 4×2; distância própria, removido aos 50 px independentemente do X posterior do jipe. |
| T08 | C + E | Movimento dos tiros é subdividido em passos de um pixel, verificando impactos a cada passo. |
| T09 | C + E | Origem calculada com X/Y atual; ensaios de posição e de alturas passaram. Experiência com teclado físico ainda não. |
| T10 | C + E | Oito superiores, oito frontais, cadência de seis ticks; tecla mantida repete, toque durante recarga pode ser descartado. Escolha do projeto. |
| I01, I02 | C + E | Naves visíveis disparam continuamente na cadência; brancos de 2×4. Lista inimiga de 12 vagas. |
| I03 | C / NT | Inimigo nominalmente mais lento que o jipe; possibilidade confortável de reação exige jogador real. |
| I04 | C + E / D | Superfície considerada é a pista Y=193; relevo decorativo não bloqueia tiros. |
| I05, I06 | C + E | Testa contato inferior e sobreposição horizontal, inclusive no salto; tiros laterais não tiram vida. |
| I07 | C + E | Tiro tem dados próprios; permanece após morte/saída da nave e mudança de grupo. Fluxo controlado confirmou tiro órfão atingindo jipe. |
| V01 | C + E parcial | Uma rotina de morte serve para crateras, rochas e tiros. Tiro e rocha observados nesta execução; três causas em rodada física ainda pendentes. |
| V02, V03, V04 | C + E | Reposição em X=0 apenas se livre; inatividade impede desconto repetido; morte preserva score/tempo/cenário. |
| V05, V06 | C + E parcial | Game Over por última vida e por tempo exercitados em arranjos controlados. Os 90 s normais não foram medidos. |
| V07, V08 | C + E | GAME/OVER em duas linhas, centrados na grade de texto, cor 04h e score recebido da partida. |
| V09 | C + E | Letra e seta inseridas pelo BIOS retornaram ao menu; teste físico ainda pendente. |
| V10 | C + E | Nova partida zera score, restaura vidas/tempo, reinicia listas, jipe e cadências; Sair funcional nos fluxos exercitados. |
| V11 | NT físico | Não houve três ciclos completos com teclado físico; os ciclos automatizados não substituem esse item. |
| Q01, Q02 | C + E | Montagem 8086 e gráficos por memória confirmados. |
| Q03 | C | Desenho, tabelas, colisão e pontuação reutilizados entre variantes. |
| Q04 | C | Constantes abrangem medidas, limites, capacidades e tempos. Nem todo valor fora da configuração atual é garantido pelas validações; testes precisam acompanhar configurações aceitas. |
| Q05 | C | 69 de 69 procedimentos com função, entrada e saída. |
| Q06 | C / NT | Conversão grade→cores→DB/DUP e renderização verificáveis; capacidade da equipe de explicar só pode ser demonstrada. |
| Q07 | D | Medidas certas não comprovam reprodução das figuras nem aceite das artes autorais. |
| Q08 | D | Outra plataforma não definida/verificada. |
| A01, A02 | NT | Inscrição, quantidade de integrantes e data final não são demonstradas pelo código. |
| A03 | NT | Explicação oral de ambos depende da equipe. |
| A04 | Parcial | Funcionalidades mínimas implementadas, com ressalvas J07, regressão e aceitação física. Não dar aprovação incondicional. |
| A05, A06 | NT | Apresentação no ambiente exigido e submissão posterior não ocorreram nesta auditoria. |

## 4. Alcance dos testes novos

| Ensaio | Resultado | O que não comprova |
|---|---|---|
| Montagem normal | Sem erros/avisos; EXE recompilado idêntico ao anterior | Uso dos botões da IDE em apresentação. |
| Memória/cenário R08REG | 320 quadros e duas voltas, relógio e guarda aprovados | Fluidez percebida. |
| Menu/memória N08MEM | 400 quadros, dimensões, transparência, limites e guarda aprovados | Fidelidade artística às figuras do professor. |
| Menu/setor/fim N08TELA | 320 atualizações em 35,15 s; setor em espera por 2,04 s; navegação e retorno aprovados | Teclado físico. |
| N08LOG isolado | 48 verificações, 4.096 sementes, 48 grupos e 394 obstáculos; conferência externa de posições e gaps | Aprovação da suíte original, que continua falhando. |
| E08LOG | 426 verificações de tiros/colisões/cadências aprovadas | Conforto de combate humano. |
| E08PIX | 170×65.000 = 11.050.000 bytes conferidos, incluindo HUD e guarda | Quadros intermediários durante a escrita da tela, tearing/cintilação. |
| E08AUTO | Duração controlada: 6,21 s DOS / 6,175 s Windows; expiração, morte, reset, IRQ e saída | Duração normal de 90 s. O harness troca a duração, prepara encontros e usa `cycles=auto`. |
| SALTOS | 854 tentativas, todos os sete tipos com soluções seguras | Todas as direções, todos os limites e tiros simultâneos. |
| TOPO | Sequência real de altura e deslocamento registrada | Aceite do professor para referência/discretização. |
| LIMITE | Duas fases com X=140; cenário/rocha avançam 56 px, tempo continua, pixels conferidos | Tecla física; disparos inimigos foram adiados no arranjo. |

Os scripts de conferência desta auditoria validam resultados novos contra o hash atual. A execução de componentes isolados é apresentada como tal; **não foi convertida em “suíte completa aprovada”**.

## 5. Recomendações em ordem de importância

1. **Resolver J07 antes de declarar conformidade exata.** Fixar com o professor a referência horizontal e a aceitação ou não do passo que cruza o limiar. Se a exigência for literal, ajustar a lógica e medir novamente o deslocamento real, não apenas o contador.
2. **Atualizar a regressão à configuração atual.** Rever expectativas de 3 px, selecionar saltos que sejam realmente seguros para 5 px, atualizar as referências das artes e retirar exigências de identidade textual que bloqueiam mudanças válidas. Manter verificações comportamentais independentes.
3. **Propagar falha entre suítes e preservar origem das evidências.** Um PASS de combate não deve representar aprovação de regressões que falharam. Associar resultados à versão/configuração efetivamente executada; o hash escrito durante geração, sozinho, não demonstra que todos os testes posteriores chegaram a rodar.
4. **Executar a rodada física do checklist na máquina e no GUI Turbo Assembler da apresentação.** Priorizar J05/J09/J10, saltos de rochas, C08, I03, H04/H06 e V11. A configuração `EXECUTAR-E08.cmd` usa o executável DOSBox local com `e08.conf`; isso não é a operação dos botões da IDE. `ABRIR-GUI.cmd` abre a IDE.
5. **Registrar as interpretações acadêmicas pendentes.** Artes, metade horizontal das naves, impactos consecutivos e segunda plataforma. As convenções geométricas de jipe/gaps já estão explícitas no código.

Não considerei ausência de som, ranking, cinco fases, minas ou vitória por distância como defeitos: não são exigências da adaptação indicada pelo checklist.

## 6. Identificação e reprodução

- Fonte: `MOON.ASM`.
- SHA256 do fonte: `8F9BF3FAD3C8684B8326DA5CE8F438CFBA672A3944624E7BEE4730E25928F064`.
- SHA256 do EXE anterior e recompilado: `6E1E18D5DBC6517A01E74740AC6DA5328EC6D05079D58ACC930502969A8CCC64`.
- Ferramentas: TASM 4.1, TLINK 7.1.30.1 e `ferramentas/guitasm/BIN/guiTasmX64.exe`, executados no Windows.
- Fonte principal, 69 procedimentos, dados de artes e scripts de apoio foram inspecionados. Os binários de terceiros do compilador/emulador não foram auditados internamente.

Comandos principais usados:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File testes/executar-e08.ps1
python testes/conferir-e08.py --pixels --saida evidencias/auditoria-2026-11-07/pixels
python testes/conferir-e08.py --saida evidencias/auditoria-2026-11-07/conferencia-completa --data 07/11/2026
python evidencias/auditoria-2026-11-07/gerar-auditoria.py
# Executar auditoria.conf no emulador antes da conferencia abaixo.
python evidencias/auditoria-2026-11-07/conferir-auditoria.py
```

O primeiro e o terceiro comandos **falham na versão atual**, pelos motivos registrados. Os ensaios isolados não corrigem nem ocultam essas falhas. O ensaio de limite reutilizou `testes/verificar-limite-cenario.py` com o diretório de saída redirecionado para a pasta desta auditoria.
