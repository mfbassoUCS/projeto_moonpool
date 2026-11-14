# Como entender o MOON.ASM comentado

O [MOON.ASM](../MOON.ASM) recebeu comentários em português simples em todas as 2.512 linhas que contêm instruções, declarações, diretivas ou rótulos. As linhas vazias e os cabeçalhos anteriores foram preservados: o arquivo continua com **2.868 linhas**, e o `push es` do seu exemplo continua na **linha 726**. Os comentários do ASM ficam sem acentos para manter o formato ASCII usado pelo projeto e pelo TASM.

Leia primeiro o cabeçalho de uma rotina: ele diz o que ela recebe, o que devolve e quais registradores pode alterar. Na linha `proc`, o novo comentário **“Por que”** relaciona a rotina ao problema da etapa. Depois acompanhe as instruções e os comentários ao lado delas. Uma instrução simples pode depender do que foi preparado várias linhas antes.

As justificativas foram reconstruídas a partir do código e dos documentos. Elas explicam a necessidade técnica de cada passo; não presumem conhecer pensamentos que o autor não registrou. Quando o enunciado permitia interpretações, os comentários identificam as decisões do projeto, sem apresentá-las como confirmações do professor.

## Por que existe `push es` na linha 726?

Pense nos registradores como pequenas posições de trabalho do processador. `ES` é um registrador de **segmento**: ele ajuda a indicar qual região da memória será acessada.

No jogo, normalmente `ES=A000h`, o segmento da memória de vídeo. Por exemplo, `mov es:[di],al` coloca a cor de `AL` no pixel indicado por `DI`. Mas a função BIOS escolhida para escrever texto exige o endereço da **mensagem** em `ES:BP`. Nesse momento, `ES` precisa apontar para os dados do jogo, onde a mensagem está guardada.

O raciocínio é: **“Preciso usar ES para outra coisa por um instante. Vou guardar seu valor, escrever o texto e depois devolver o valor anterior.”**

| Linha | Código | Motivo naquele ponto |
|---|---|---|
| 726 | `push es` | Guarda o segmento de vídeo na pilha antes de substituí-lo. Não guarda uma imagem da tela; guarda um valor de 16 bits. |
| 727 | `push ds` | Coloca o segmento de dados no topo da pilha para copiá-lo para ES. |
| 728 | `pop es` | ES recebe a cópia de DS. O valor antigo de ES continua guardado embaixo dela. |
| 729 | `mov bp,si` | SI já aponta para o texto; BP recebe esse deslocamento porque a BIOS espera ES:BP. |
| 730 | `xor bh,bh` | Seleciona a página de vídeo zero. BL mantém a cor do texto. |
| 731 | `mov ax,1300h` | AH=13h seleciona escrever uma string. AL=00h escolhe o modo dessa escrita. |
| 732 | `int 10h` | Pede à BIOS que escreva a mensagem com os parâmetros preparados. |
| 733 | `pop es` | Recupera o segmento de vídeo salvo na linha 726. Os desenhos seguintes continuam acessando o lugar correto. |

A pilha devolve primeiro o último valor guardado, como uma pilha de pratos. Por isso o primeiro `pop es` recebe o DS recém-empilhado; o segundo recebe o ES original. O par `push ds` / `pop es` também resolve uma limitação do 8086: não existe a instrução direta `mov es,ds`.

Sem preservar e restaurar ES, uma rotina de desenho posterior poderia escrever na memória dos dados em vez de desenhar na tela. Esse é o motivo concreto do `push es` aqui.

Os outros `push` dessa rotina protegem os valores de quem a chamou. Um exemplo importante é `push bp`: `MostrarArte` usa BP como contador de linhas, mas a BIOS precisa de BP como endereço da mensagem. Depois, `pop bp` devolve o contador para que a impressão da arte continue corretamente.

## O que cada etapa precisava resolver

| Etapa | O que precisava funcionar | Por que essas peças entraram nessa etapa | Onde reconhecer no fonte atual |
|---|---|---|---|
| **E01 — base** | Montar no ambiente exigido, entrar/sair do vídeo, desenhar e apagar por memória, ler teclado e controlar tempo. | Antes de construir um jogo, era necessário provar que o programa conseguia conversar com vídeo, teclado e relógio. Desenho por memória também atende uma restrição do trabalho. | `inicio`, `LimparTela`, `PrepararRetangulo`, `DesenharBitmap`, `SalvarFundo`. |
| **E02 — artes e telas** | Bitmaps nas medidas, menu animado, seleção e Game Over. | Reutilizar a base para apresentar objetos reais. Transparência dá forma aos sprites; capturar fundos permite movê-los sem rastros; tabelas permitem tratar quatro objetos com as mesmas rotinas. | Dados `bitmap*`, `EscreverTexto`, `MostrarArte`, rotinas do menu e `DesenharSprite`. |
| **E03 — cenário e status** | Terreno contínuo, pista, score/vidas/tempo no HUD e fim por tempo. | O cenário precisa avançar sem depender de teclas. O relógio precisa medir segundos, mesmo quando muda a velocidade do desenho. Um buffer de linha permite compor o relevo usando pouca memória. | `EntrarPartida`, `AtualizarPartida`, `DesenharCenario`, `ComporLinhaCircular`, `DesenharStatus`, rotinas do relógio. |
| **E04 — jipe e salto** | Movimento lateral limitado, salto trapezoidal e teclas simultâneas. | Consultar caracteres da BIOS não basta para acompanhar bem uma seta segurada e outra solta. A IRQ registra essas mudanças; os estados do salto permitem subir, permanecer no topo e descer enquanto o mundo continua. | `RegistrarScanJipe`, `TecladoJogoIRQ`, instalação/restauração do teclado, `AtualizarJipe`, `ContarTopo`. |
| **E05 — obstáculos e vidas** | Gerar crateras/rochas com distâncias válidas, detectar colisões, perder vida, repor e pontuar. | Agora há um jipe que se move e salta. É possível definir quando ele realmente superou um obstáculo. O progresso de travessia evita pontos repetidos; esperar a área inicial livre evita uma morte imediata ao reaparecer. | Tabelas `obst*`, `Sortear`, `AvancarObstaculos`, `ConferirObstaculos`, `PerderVida`, `TentarReporJipe`. |
| **E06 — naves** | Grupos de 1..3 naves do mesmo tipo, posições válidas, movimento e espera pela última nave. | Reutiliza artes, sorteio e recorte. Um contador de atividade real distingue “nasceu no grupo” de “ainda está no jogo”. Reservar espaço antes de sortear mantém os intervalos sem tentativas infinitas. | Tabelas `nave*`, `GerarGrupoNaves`, `ContarNavesAtivas`, `RemoverNave`, `AtualizarNaves`. |
| **E07 — integração do mínimo** | Conferir o ciclo completo do menu ao jogo, Game Over e retorno. | O mínimo exigido já estava reunido. Esta etapa integrou e verificou o conjunto e retirou mensagens de demonstração; não precisava acrescentar outra grande mecânica. | Fluxo de `LerTeclado`, `EntrarSetor`, `EntrarPartida` e `EntrarGameOver`. |
| **E08 — disparos** | Dois canhões simultâneos, tiros inimigos, colisões e resistência das rochas. | Os alvos e as regras de vida/pontos já existiam. Tiros ganham listas próprias para continuar após a morte da nave; reservar duas vagas garante o par de canhões; testar cada pixel evita atravessar um alvo. | Tabelas `tiro*`, `DispararJipe`, `DispararNaves`, `MoverDisparos`, `ConferirUmDisparo`. |
| **E09 — revisão** | Revisar requisitos, documentação, testes e apresentação. | Implementar as mecânicas não prova que elas atendem ao enunciado nem que o aluno consegue explicá-las. A revisão reúne essas conferências e suas pendências. | Cabeçalhos, guias, checklists e registros de evidências. |

Os guias `LEIA-E01.md` a `LEIA-E09.md` são registros de momentos diferentes. Por exemplo, a E02 tinha placar demonstrativo e ainda não tinha partida; isso não descreve o programa atual. Da mesma forma, a indicação histórica “sem tiros” na E05 não significa que os tiros faltem hoje.

Depois dessas etapas, houve ajustes registrados em **07 e 08/11/2026**: o passo lateral do jipe passou de 3 para 5 e o terreno passou a avançar **1 pixel por tick**. A segunda mudança permite contar exatamente cinco pixels no topo do salto. A altura máxima continua 15, e subida/descida continuam 3 pixels por atualização. Os comentários explicam essa versão atual.

## Como ler os detalhes que mais confundem

**Valor e endereço são coisas diferentes.** `mov ax,jipeX` lê a coluna guardada na variável. `lea si,bitmapJipe` obtém o deslocamento onde começa o desenho; não copia o desenho inteiro para SI. Segmento mais deslocamento formam o endereço usado para acessar a memória.

**O nome do registrador não fixa sua função para sempre.** CX pode contar pixels numa rotina, conter o limite de um sorteio em outra ou receber parte da hora. Procure o comentário da última instrução que preparou o valor e o contrato da rotina chamada.

**Índice das tabelas é contado em bytes.** Uma entrada `dw` ocupa dois bytes. Por isso aparecem `add di,2` e `shl bx,1`: o segundo objeto começa no offset 2, não no 1. As tabelas de posição, tipo e atividade usam o mesmo offset para falar do mesmo objeto.

**Comparar não é alterar.** `cmp` atualiza as flags, pequenos sinais de resultado do processador. O salto seguinte toma a decisão. `JB/JAE` fazem comparação sem sinal; `JL/JGE` consideram sinal, necessário quando uma nave ou obstáculo tem X negativo ao sair pela esquerda.

**CF nem sempre significa um erro.** `PrepararRetangulo` devolve CF=1 para retângulo inválido. `RemoverNave` devolve CF=1 quando removeu uma nave de verdade. Esse segundo resultado permite conceder 100 pontos uma única vez. O significado depende do contrato de cada rotina.

**DB, DW, EQU e IF não são ações repetidas durante o jogo.** São orientações ao montador para preparar dados, constantes e verificações. Nos bitmaps, cada linha de `db` descreve uma linha de pixels: `6 dup(0FFh)` significa seis pixels que a rotina tratará como transparentes. A explicação é sobre a posição e a função dessas cores no desenho; as formas são artes próprias autorizadas, não regras novas de jogabilidade.

**Perder vida é diferente de começar outra partida.** `PerderVida` conserva score, relógio e mundo, cancela travessias interrompidas e torna o jipe ausente. `EntrarPartida` reinicia a sessão inteira. Essa separação é o motivo de existirem rotinas diferentes para situações que, visualmente, podem parecer apenas “colocar o jipe de volta”.

## Fontes e conferência

A análise usa o [README](../README.md), os nove guias `LEIA-E*`, o [enunciado](../planejamento/fontes/enunciado-original.md), o [roteiro de execução](../planejamento/06-roteiro-de-execucao.md), as [decisões D01–D18](../planejamento/05-pendencias-e-decisoes.md), o [mapa das rotinas](../MAPA-DO-CODIGO.md), o [estudo do código](../ESTUDO-DO-CODIGO.md) e os registros de [jogabilidade](../AJUSTES-JOGABILIDADE.md) e [correções da auditoria](../CORRECOES-AUDITORIA.md). Os snapshots ajudam a distinguir a origem das rotinas de seu uso nas etapas seguintes.

A conferência desta edição compara instruções e dados antes/depois, incluindo as strings, e verifica a numeração das linhas. Ambas as versões foram montadas e vinculadas com TASM/TLINK sem erros ou avisos: os executáveis de **40.807 bytes são idênticos byte por byte**, inclusive ao EXE que já estava no projeto. Isso comprova que a edição dos comentários preservou o programa compilado.

Três auxiliares em `testes/` receberam ajustes de leitura para aceitar comentários após os rótulos de instrumentação e após os bytes dos bitmaps. A geração isolada confirmou instruções idênticas nas 12 variantes E08/N08/R08; o conferidor aprovou as 17 artes e continuou rejeitando uma alteração proposital de pixel. Essas adaptações mantêm as verificações disponíveis para o fonte comentado; não mudam as regras do jogo. Os relatórios antigos continuam vinculados aos hashes das versões que verificaram, e esta edição documental não representa uma nova rodada de testes físicos de jogabilidade.
