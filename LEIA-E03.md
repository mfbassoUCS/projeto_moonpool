# E03 — cenário, status e relógio

**Histórico da E03.** O fonte atual está na E05; veja [LEIA-E05](LEIA-E05.md). O estado descrito abaixo foi preservado em `testes/E03BASE.ASM`, usado pelo gerador E03 desde 28/10/2026. Os atalhos montam o MOON atual; para verificar a integração atual use os testes E05. As pendências físicas da E03 continuam aplicáveis ao cenário atual.

O fonte atual implementa somente a E03 sobre a base existente. **Jogar → SETOR 1 → cenário/HUD por 90 segundos → GAME OVER → menu.** O score normal permanece 00000: não existem ações que concedam pontos nesta etapa. Não há jipe jogável, obstáculos, grupos de naves nem tiros. As 17 artes autorais da E02 foram preservadas byte a byte; SETOR 1/Enter continua sendo a proposta D04.

## Executar e configurar

Abra `EXECUTAR-E03.cmd`, confira `MONTAGEM.LOG` e `LINK.LOG` e digite `MOON`. Pela IDE: `ABRIR-GUI.cmd`, Turbo 16-bit, Assemble, Build e Run. Recarregue o fonte se estava aberto na E02. Os atalhos E01/E02 também montam o fonte atual; os snapshots históricos estão em `testes/E01BASE.ASM` e `testes/E02BASE.ASM`.

O EXE exige apenas TASM/TLINK e o emulador do GUI Turbo Assembler. Python/Pillow e PowerShell são auxiliares de verificação, não dependências do jogo. O fonte continua único, ASCII, `.8086`, `.model small`, pilha 100h. `BUILD.BAT` agora também pede o mapa com `tlink /m`, para conferir memória a cada montagem.

| Constante | Valor atual | Significado |
|---|---|---|
| `DURACAO_SEGUNDOS` | 90 | Contagem regressiva; aceita 1..999; remonte após alterar |
| `VIDAS_INICIAIS` | 3 | Aceita 1..3; não há perda de vida implementada |
| `TICKS_CENARIO` | 2 | Intervalo mínimo entre movimentos, aproximadamente 110 ms |
| `PASSO_CENARIO` | 2 | Pixels para a esquerda por movimento; aceita 1..319 |
| `CENARIO_Y` / `MONTES_Y` | 100 / 132 | Origens das artes 320×64 e 320×32 |
| `PISTA_Y` / `PISTA_ALT` | 193 / 7 | Pista amarela 0Eh, até y=199 |

Esses valores de configuração são **escolhas técnicas desta implementação**, autorizada pelo pedido de E03; não são respostas do professor nem novas preferências atribuídas ao aluno. D01 prioriza o texto: score à esquerda, vidas centrais e tempo à direita. D02 adota regressiva porque o mínimo exige terminar quando acabar o tempo. D03 usa as três vidas ilustradas. D10 resolve a base conforme abaixo. Ver registro completo em `planejamento/05-pendencias-e-decisoes.md`.

## Como apresentar o fluxo

1. `inicio` mantém a inicialização da E01/E02. O laço consulta `LerTeclado` sem esperar; MENU atualiza sua animação, PARTIDA chama `AtualizarPartida`.
2. Enter no setor chama `EntrarPartida`. Ela limpa teclas antigas, zera score/rolagem/fração, restaura vidas e duração, desenha a primeira tela e só então toma a referência do relógio.
3. `AtualizarPartida` consulta o tempo em toda passagem pelo laço. Se passou pelo menos um segundo completo, atualiza o HUD. Separadamente, verifica os ticks para mover e redesenhar o cenário.
4. Ao chegar a zero, passa **AX=scorePartida** para a `EntrarGameOver` já existente. O antigo salto para 12345 foi removido do fonte atual. O aviso identifica o escopo E03; isso ainda não é a integração completa E07.
5. Qualquer tecla retorna ao menu; outra entrada reinicia todos os valores. Sair restaura modo/página anteriores. Na E03, as teclas de jogo são consumidas sem ação; não existe Esc para sair durante o cenário.

## Rolagem e camadas

`rolagem` guarda qual coluna da arte aparece em x=0. Para cada pixel, a origem corresponde a **(x + rolagem) módulo 320**. Somar dois à origem faz a imagem andar dois para a esquerda. Depois de 318 vem 0: são os mesmos dois pixels de avanço, não um salto do retângulo. Ambas as camadas usam o mesmo deslocamento; não foi acrescentada paralaxe.

`ComporLinhaCircular` recebe DS:SI apontando para uma linha de 320 bytes. Soma a rolagem a SI, percorre a linha e volta ao começo quando chega ao fim; DI continua avançando no buffer. FFh preserva o conteúdo já composto e 00h escreve preto. A rotina preserva registradores e deixa DF=0.

`DesenharCenario` compõe cada linha em `linhaCenario`, com apenas **320 bytes**. Primeiro limpa esse buffer, sobrepõe montanhas e montes e copia a linha pronta para ES:A000h com `REP MOVSB`. Não limpa o terreno inteiro no vídeo antes de desenhá-lo, nem restaura fundos de quadros anteriores.

As montanhas ocupam y=100..163 e os montes y=132..163. A última linha composta, inteiramente preenchida, é repetida em y=164..192. Isso prolonga a base até a pista sem modificar ou redimensionar os bitmaps. O relevo ocupa no máximo **93 linhas**, abaixo do máximo 95. A pista é escrita por último em y=193..199, 320×7. O céu acima de y=100 e o HUD permanecem intocados pelo cenário.

O segmento de dados passou de **34.399 para 34.739 bytes (087B3h)**. O aumento líquido é 340 bytes, incluindo o buffer e os novos dados/textos. Restam 30.797 bytes até 64 KiB do segmento de dados, antes de considerar pilha/alinhamento do grupo. Não foi criado buffer de tela inteira. Consulte `MOON.MAP` para a disposição efetiva.

## HUD e segundos completos

`DesenharStatus` limpa somente y=0..14 por memória e desenha os valores atuais. Os corações medem 18×11, em (151,2); o relógio mede 7×8, em (280,3). Score ocupa cinco dígitos, à esquerda; tempo ocupa três, nas colunas de texto 37..39. `FormatarNumero` divide AX por 10 e escreve os restos da direita para a esquerda, sempre preenchendo o campo inteiro: 100→099 não deixa dígito antigo. A BIOS é usada somente para texto/modo/teclado/tempo, nunca para pixels gráficos.

`LerCentissegundos` consulta INT 21h/AH=2Ch e converte horas, minutos, segundos e centésimos para **DX:AX**, um inteiro de 32 bits formado por dois registradores 8086. Cada segundo tem 100 unidades; um dia tem 8.640.000. Horas e minutos também entram na conta: uma pausa de 70 segundos não vira uma pausa de 10 segundos.

`AtualizarRelogio` subtrai o instante anterior com SUB/SBB. Na virada de meia-noite soma um dia à diferença. `ConsumirTempo` soma a fração guardada e divide por 100: o quociente desconta segundos inteiros, o resto fica para a próxima consulta. Exemplo: 99 centésimos não descontam nada; mais 1 desconta um segundo; mais 350 descontam três e guardam 50. Ao exceder o tempo restante, satura em zero. DIV é protegido contra overflow em intervalos grandes.

Isso elimina o primeiro incremento antecipado da E01 causado pela mera mudança do campo de segundos. Não se arredonda 18 ticks BIOS para um segundo; os ticks só controlam o movimento. A resolução do relógio DOS no ambiente é da ordem de 55 ms, e o desenho pode atrasar a próxima consulta. Não é um relógio de precisão: os testes comparam também tempo do Windows. Consultas precisam ocorrer em menos de 24 horas, sem ajustar manualmente o relógio durante a sessão; suspensão do host e múltiplos dias não foram validados. Após atraso, o relógio desconta o tempo transcorrido, mas o movimento avança no máximo um passo por consulta, sem rajada para recuperar quadros.

A primeira medição externa detectou fim até 26 ms antecipado pela quantização do DOS. Por isso, `margemInicial` consome **6 centésimos uma única vez**, antes de acumular os segundos. Essa margem de 60 ms cobre o quantum aproximado de 55 ms do ambiente testado e reinicia com cada sessão. Não é somada a cada segundo; a duração nominal só recebe esse pequeno acréscimo inicial. O teste verifica também 3+102+1 centésimos: os primeiros 6 cobrem a margem, e somente ao completar os outros 100 ocorre o desconto.

## Verificação e sua participação

Execute, na raiz, `powershell -NoProfile -ExecutionPolicy Bypass -File testes\executar-e03.ps1` e depois `python testes\conferir-e03.py`. O primeiro monta e executa no emulador incluído no GUI Turbo Assembler 5.1; o segundo confere dumps reais e gera imagens/relatório em `evidencias/e03`. Detalhes e resultados em `testes/README.md` e `planejamento/14-andamento.md`.

Os testes cobrem todos os pixels por duas voltas em RAM, duas voltas por ticks em vídeo, guardas, HUD, frações, pausa, meia-noite, segundos reais, cadências 2/4, expiração, score transmitido ao fim, reinicialização e saída. As teclas são inseridas no buffer BIOS. As capturas são dumps A000h reconstruídos, não fotografias de uso do teclado.

**Pendente de ação do aluno:** abrir o fonte na IDE, usar Assemble/Build/Run, testar fisicamente setas/Enter/qualquer tecla/Sair e observar pelo menos duas voltas (cerca de 36 s), sem costura, cintilação incômoda ou rasgo perceptível. Comparar o contador com um cronômetro, esperar a expiração normal de 90 s e iniciar novamente. Revisar também a aparência das artes autorais. Não é necessário recuperar as figuras ausentes. D04 continua pendente de orientação antes da E07.

## Passagem à E04, sem implementá-la

A pista começa em y=193; um jipe 20×10 apoiado acima dela teria origem y=183 (derivação técnica a registrar na E04). O terreno anda 2 px/2 ticks para a esquerda. O HUD já recebe `scorePartida`, `vidas` e `tempoRestante`.

`DesenharCenario` recompõe o fundo móvel: **não usar os buffers estáticos do menu para apagar o jipe após rolar o terreno**. Na E04, recompor o fundo antes de desenhar o jipe e validar seu apagamento, inclusive nos quadros em que só o jipe muda. O recorte parcial continua ausente nas rotinas genéricas. D05/D08 ainda precisam de tratamento; limites de pontuação devem ser revistos quando E05/E06 começarem a conceder pontos. O próximo prompt está em `planejamento/prompts/E04-jipe-e-salto.md`.
