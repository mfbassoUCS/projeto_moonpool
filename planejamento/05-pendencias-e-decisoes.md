# Pendências, conflitos e decisões

## Correção após auditoria independente — 08/11/2026

D05 mantém a referência autorizada no avanço do terreno, agora exatamente 5 pixels (1 pixel por tick, em vez de 2 a cada 2). Suíte completa atualizada e aprovada; propagação de falhas testada. Evidências e reteste físico em [CORRECOES-AUDITORIA](../CORRECOES-AUDITORIA.md).

**I04 — interpretação de superfície:** o jogo usa a pista em Y=193 como fim do tiro inimigo; montanhas são fundo. Esta escolha permanece declarada e foi marcada como pendente de esclarecimento no checklist técnico, porque a auditoria aponta possível leitura diferente. Nenhuma confirmação do professor foi recebida. R09/D11, N06/D06 e Q07/D18 também continuam explícitos, sem alterar comportamentos apenas por ambiguidade.

Os registros datados abaixo descrevem suas respectivas versões.

## Ajuste após teste do aluno — 07/11/2026

Relato de lentidão, salto difícil e relevo geométrico motivou passo lateral de 3→5, configuração de CPU e nova arte do relevo. Altura 15/subida-descida 3/topo D05 e colisões intactos. O valor lateral não era fixado pelo professor; a altura continua obrigatória. Evidências e limites em [AJUSTES-JOGABILIDADE](../AJUSTES-JOGABILIDADE.md). Reteste humano ainda necessário; não confundir aumento medido da margem de ↑+→ com garantia de salto parado sobre rochas. Não houve confirmação nova do professor.

Tudo abaixo está **pendente**, salvo o que estiver identificado como regra textual ou decisão registrada. As propostas técnicas não são respostas do professor nem escolhas confirmadas pelo aluno. Resolver cada assunto quando ele bloquear a respectiva etapa.

| ID | Dúvida ou conflito | Encaminhamento proposto para o futuro |
|---|---|---|
| D01 | Texto coloca score à esquerda e vidas ao centro; imagem faz o inverso | E03 implementa o texto: score esquerdo, vidas centrais, tempo direito. Interpretação técnica; não houve confirmação do professor |
| D02 | Texto menciona tempo “decorrido” e “restante”; mínimo encerra ao acabar o tempo | E03: regressiva de 90 s, configurável 1..999, frações acumuladas. Escolha técnica baseada no encerramento exigido |
| D03 | Quantidade inicial de vidas não fixada em frase explícita; figuras mostram 3/2/1 | E03: 3 vidas configuráveis 1..3, por interpretação da ilustração; E05 implementa perda/reposição e fim por vidas |
| D04 | Mínimo cita apresentação do setor sem detalhar conteúdo/duração | E07 adota SETOR 1, objetivo e Enter para iniciar; sem avanço automático ou consumo de tempo nessa tela. Decisão técnica para o mínimo, sem confirmação do professor |
| D05 | Topo do salto dura “5 pixels de deslocamento horizontal” | E04, 28/10: aluno autorizou escolha técnica; contar avanço do terreno. Parado/esquerda/limite não bloqueiam. Em 08/11, corrigido para 5 px reais com terreno de 1 px/tick, sem excedente. Doze trajetórias conferidas. A referência não foi confirmada pelo professor |
| D06 | Naves surgem pela direita, posição horizontal aleatória “não pode ultrapassar a metade horizontal” | E06: interpretar como extensão máxima da formação, 160 px; faixa inicial externa [320,480), primeira origem 320..335, entrada gradual. Escolha técnica, sem confirmação do professor |
| D07 | Distância mínima de 30 entre naves e 150 entre crateras não define pontos de medição | E05: crateras 150..230 livres e rocha intermediária com folgas >=60. E06: naves com >=30 livres entre bordas (origens >=44), preservados durante movimento |
| D08 | Jipe limitado à metade da tela | E04: retângulo inteiro em x=0..159; origem/borda esquerda limitada a 0..140. Escolha técnica que respeita a metade esquerda, sem recorte parcial |
| D09 | Naves entre linhas 15 e 100 | E06: céu [15,100), origem Y=15..86; sprite inteiro termina até 99, fora do HUD/relevo. Escolha técnica |
| D10 | Montanhas desde y=100 com até 95 de altura e pista de 7 no fundo | E03: montanhas 100..163, montes 132..163, última linha composta prolongada até 192; pista 193..199 por último. Relevo de 93 linhas, sem lacunas; escolha técnica |
| D11 | “Dois disparos consecutivos” para rocha 4 | E08: dois impactos na mesma rocha, sem prazo; erro/outro alvo/morte não zera dano. Reuso da vaga zera. Interpretação técnica, sem confirmação do professor |
| D12 | “Ambas as plataformas” na compatibilidade, mas só GUI Turbo Assembler identificado | Validar no ambiente explicitamente exigido; perguntar se há outro montador pretendido quando necessário |
| D13 | Dimensão do tiro superior, cadências, velocidades e limites de projéteis ausentes | E08: superior 2×4; 8 superiores/8 frontais/12 inimigos; passos 4/4/2 por tick; intervalos 6/18 atualizações; par inteiro ou nenhum, preservando ativos. Conforto físico pendente |
| D14 | Reaparecimento x=0 pode provocar nova colisão com obstáculo ainda presente | E05: uma vida por evento, ausência até próximo tick e área [0,20) livre; terreno/tempo continuam. Sem invulnerabilidade nem remoção do obstáculo |
| D15 | Não há regra exata de contato com cratera nem de colisão por pixel | E05: intervalos semiabertos dos retângulos inteiros; cratera mata por apoio no chão, rocha por sobreposição com bloco [183,193). Pontos após travessia e pouso seguro |
| D16 | Menu ilustrado usa Arcade; texto exige Moon Patrol | Atendido na E02: Moon Patrol, TAAG Mini; baseado no texto do professor |
| D17 | ASCII de GAME OVER vermelho sem código numérico | E02 adota 04h, vermelho da tabela; interpretação técnica, distinta da seleção 0Ch |
| D18 | Figuras da disciplina continuam ausentes | Em 25/10/2026 o aluno autorizou referências do arcade e desenhos próprios, sem cópia. Artes implementadas; ausência das figuras deixa de bloquear E02. Não há confirmação do professor nem alegação de fidelidade |

## Registro de decisões futuras

Para cada decisão, acrescentar: ID, data, decisão, origem (professor/aluno/interpretação técnica), justificativa, arquivos afetados e teste de aceitação. Atualizar os documentos impactados para não manter regras contraditórias.

Nenhuma confirmação do professor foi recebida. Data da apresentação, integrantes, inscrição no grupo permanecem não informados; versão completa com tiros foi solicitada em 01/11. O ambiente local foi preparado e validado na E01.

## Registro E09 — revisão em 02/11; fechamento técnico em 06/11/2026

- **Autoridade:** aluno pediu somente revisão/apresentação, com correção de defeitos no escopo e preservação das decisões. Não houve nova resposta do professor nem novo relato físico recebido. Nenhuma decisão técnica foi promovida a regra do professor.
- **Preservação:** D04/D05/D06/D07/D08/D09/D11/D13/D14/D15, sorteio compartilhado, composição por memória, CF imediato/+100, +50 único e saturação 65535 mantidos. E08BASE preserva o fonte completo de 01/11; E07BASE permanece intacto. MOON recebeu apenas correções de comentários, com corpo executável igual à E08.
- **Verificação:** botões Assemble/Build/Run e ciclo sintético na IDE executados em 02/11; suíte E08/N08/R08 repetida após corrigir leitura concorrente do arquivo de sinal; KEY atual executado em 06/11. Conferência final e evidências em `evidencias/e09`. Ações de botões atuais já comprovadas; não exigir repeti-las como se faltasse evidência automática.
- **Limites:** E08KEY usa PostMessage/SDL windib/IRQ1; ciclo da IDE também usa entrada sintética. Continuam pendentes teclado físico, conforto/esquiva/fluidez e 90 s normais externos. R08AUTO isola emissão inimiga somente no harness; E08AUTO mantém tiros habilitados.
- **Entrega acadêmica:** guia e matriz preparados não equivalem a apresentação. Inscrição, integrantes/data concreta e apresentação sem comprovação recebida; submissão somente depois da apresentação. Nenhum arquivo enviado à faculdade.
- **Arquivos/retomada:** LEIA-E09, GUIA-APRESENTACAO, 17-revisao-e09, matriz13, andamento14 e prompt E09. Próxima ação é a retomada da própria E09 com resultados humanos ou defeito concreto; nenhuma etapa adicional iniciada.

## Registro E08 — 01/11/2026

- **Autoridade:** aluno pediu somente E08 completa. Professor fixa cores, frontal 4×2/50 px, inimigo 2×4, dois canhões simultâneos, pontos e resistências. Valores ausentes abaixo são escolhas técnicas, sem confirmação do professor.
- **D11:** dois impactos na mesma rocha 4 sem prazo. Errar, acertar outra rocha ou perder vida não desfaz o primeiro. `obstImpactos` zera no nascimento. Rocha 1 consome tiro sem dano; 2/3 somem em um. `PASS_PONTO` impede duplicar +50 de salto/destruição.
- **D13:** superior 2×4; origens superior (X+6,Y−4), frontal (X+20,Y+4), inimigo (X+6,Y+14). Capacidades 8/8/12. Passos 4/4/2 por tick, testados pixel a pixel. Par do jipe a cada 6 atualizações; cada nave visível emite a cada 18. Espaço mantido repete; toque durante recarga é descartado, sem fila. Sem vaga em qualquer canhão, recusar o par inteiro; mantida tenta de novo. Nave cheia aguarda vaga. Naves fora da tela continuam ativas, mas só disparam com canhão X=0..318.
- **Superfície/colisão:** término em Y=193, pista plana; montanhas são fundo. Retângulos completos, laterais semiabertas; inimigo mata quando Y+4 alcança o topo do jipe e ainda há sobreposição vertical. Impacto no ponto final tem prioridade sobre limite sem efeito. Superior só atinge nave; frontal só rocha; crateras intactas. Tiros não colidem entre si.
- **Integração:** morte/grupo novo não apagam tiros. Reposição D14 espera também por branco na área inicial, sem invulnerabilidade. Colisões de projéteis precedem travessias/pontos terrestres; morte cancela candidatas. `RemoverNave`/CF imediato/+100 e saturação preservados. `tirosMudou` recompõe céu e terreno; projéteis antes da captura/jipe. D04/D05/D06/D07/D08/D09/D14/D15 e constantes anteriores preservadas.
- **Aceitação:** LEIA-E08, testes E08/N08/R08 e matriz T17–T20. E07BASE preservado. Aluno informou que não realizou testes manuais da E07: botões atuais, teclado físico, conforto/esquiva/fluidez e 90 s externos continuam pendentes.

## Registro E07 — 31/10/2026

- **D04, origem:** o professor menciona apresentação do setor, sem definir aparência, duração ou tecla. O pedido de executar E07 autoriza tratar essa integração. A implementação adota tecnicamente a solução já existente de SETOR 1/Enter, sem atribuir ao professor ou ao aluno uma preferência específica não informada.
- **Decisão:** apresentar somente SETOR 1, objetivo “Salte os obstáculos e sobreviva!” e instrução Enter/setas. Aguardar Enter, sem avanço automático; relógio de 90 s começa depois do primeiro quadro da partida. Letras/setas no setor não iniciam. Limpar teclas já enfileiradas evita pular uma tela com um Enter antigo; isso não promete eliminar toda repetição física futura de uma tecla ainda mantida.
- **Interface mínima:** removidos rótulos de etapa e mecanismo de aviso de demonstração. Game Over mantém GAME/OVER vermelho, score real e retorno por qualquer tecla. Menu mantém título/caixas/animação e crédito às artes autorais. Sem novas fases ou disparos.
- **Aceitação/arquivos:** MOON, LEIA-E07, testes E07TELA e regressões E07/R07, matriz T01–T20, andamento e prompts. Resultados efetivos no relatório `evidencias/e07/verificacao.txt`; o relatório e a matriz distinguem execução automática, inspeção e pendências físicas. D05/D06/D07/D09/D14/D15 preservadas. Orientação futura do professor pode exigir revisão explícita da escolha.

## Registro E06 — 29/10/2026

- **Autoridade:** professor exige 14×14, três tipos, grupos homogêneos de 1..3, posições aleatórias, mínimo 30, trajetória fixa à esquerda e espera pela última nave. O aluno pediu tratar D06/D07/D09. As convenções seguintes são interpretações técnicas da implementação, não respostas do professor nem decisões específicas atribuídas ao aluno.
- **D06:** interpretar “metade horizontal” como largura máxima da formação: 160 pixels, preparada fora da borda direita em `[320,480)`. Primeira origem X=320..335; demais origens sorteadas reservando largura/gaps mínimos e consumindo apenas a sobra. Cada retângulo termina até 480 exclusivo. Entrada gradual com recorte; depois percorre toda a tela. A formulação original permite outras interpretações; se houver orientação do professor, rever explicitamente esta escolha.
- **D07, naves:** espaço livre entre bordas: `B-(A+14)>=30`. Origens distam >=44. Todas movem 1 px/2 ticks; distâncias permanecem constantes, impedindo sobreposição mesmo em Y igual. Crateras/rochas da E05 preservadas.
- **D09:** céu `[15,100)`, origem inteira em 15..86, último pixel ≤99. HUD 0..14 e cenário desde 100. Y é sorteado por nave e permanece fixo.
- **Geração/atividade:** três vagas, quantidade/tipo sorteados, tipos repetidos permitidos. Ativa desde a criação fora da tela até `X+14<=0` ou chamada de remoção. Novo grupo somente no passo seguinte à última remoção. `RemoverNave(DI=0/2/4)` retorna CF=1 uma única vez e não pontua; CF=0 para vaga inativa/índice inválido. Futuros tiros devem somar 100 apenas por impacto efetivo. Nenhum tiro implementado.
- **Sorteio:** LCG da E05 inalterado, byte alto/resto, contrato explicitado CX=1..256. Todos os limites da E06 cabem nessa faixa. Semente inicializada somente na nova partida, pelo reset dos obstáculos, compartilhada com as naves. Posições construídas sem tentativa/rejeição; velocidades preservam a assertiva jipe > nave.
- **Desenho:** céu preto 15..99 recomposto por memória quando naves mudam, incluindo movimento isolado e remoção. Sem fundo salvo antigo. Reutilizado recorte horizontal; cenário/obstáculos/captura do jipe preservados. E08 deverá compor também tiros no céu. Dados 35.100 bytes; buffers 320/200.
- **Aceitação:** 4.096 sementes, nove combinações quantidade/tipo, extremos Y=15/86, primeira origem 320/335, fim da faixa 480 e gap 30. Geração intercalada: 48 grupos, 20 repetições de tipo, 394 obstáculos de todos os tipos em 40.000 pixels; distâncias e bloqueio até última saída conferidos. 390 quadros/25.350.000 bytes, regressão E03–E05 e laço real com morte/reposição/reset passaram. Evidências em LEIA-E06 e `evidencias/e06/`. Teste físico/IDE, fluidez e 90 s externos continuam pendentes. E07/E08 não iniciadas.

## Registro E05 — 29/10/2026

- **Autoridade:** professor define quantidades, dimensões, geração relativa ao terreno, mínimo 150, +50 e perda/reposição. O aluno pediu tratar D07/D14/D15. As convenções abaixo são escolhas técnicas da implementação, não confirmações do professor. D05/D08 da E04 e D04 provisória foram preservadas.
- **D07:** espaço livre entre bordas: `B-(A+14)>=150`. Sorteio 150..230, origens separadas por 164..244. Uma rocha por intervalo já planejado, tipo/posição sorteados e folgas >=60 de cada lado. Sequência C/R/C; lista fixa de oito entradas, sem tentativa infinita. Passo negativo residual mantém a distância exata ao nascer. Teste real de 20.000 pixels: 199 nascimentos, todos os tipos, extremos 150/230 e folgas mínimas 60 observados. A distância entre naves ainda será definida na E06.
- **D15:** retângulos completos e intervalos semiabertos. Cratera 14×7 em Y=193, colisão horizontal somente com jipe apoiado Y=183. Rocha 12×10 em Y=183, colisão horizontal e `jipeY+10>183`. Apenas encostar bordas é seguro. Transparência não reduz a área de colisão. Critério conservador e janela estreita para rochas; sete saltos reais com avanço passaram, conforto físico pendente.
- **Pontos:** exige estar antes, sobrepor em salto, terminar inteiramente depois e pousar sem qualquer colisão. Recuo desfaz travessia; morte cancela candidatas e bloqueia pontos para o obstáculo fatal. Saída da tela isolada nunca pontua. Score word satura em 65535 via `SomarPontos`, sem overflow; testes 65500+50 e teto passaram.
- **D14:** morte torna o jipe ausente e consome uma vida; retorno mais cedo no próximo tick do jipe, somente quando X=0..19 estiver livre. Enquanto ausente, relógio/terreno/geração continuam. Obstáculo fatal não desaparece nem fica inofensivo. Não há invulnerabilidade. Input físico preservado: lateral ainda mantida retoma no tick seguinte; ↑ exige soltura/nova pressão, e pressão durante ausência não fica enfileirada. Última vida envia score real ao Game Over.
- **Desenho:** cenário → obstáculos → captura/jipe. Recorte horizontal em rotina separada, mantendo contrato de `DesenharSprite`. Quadros só do jipe restauram fundo atual com obstáculos. `jipeNaTela` evita restaurar captura inexistente. Dados 35.072 bytes; artes e 13 rotinas E03/E04 preservadas por inspeção comparativa.
- **Aceitação/arquivos:** MOON, LEIA-E05, testes/evidências E05, snapshot E04 e geradores históricos, planejamento e prompts afetados. Montagens sem erros/avisos; lógica/RAM/fluxo/pixels aprovados. Teste físico/IDE, fluidez e 90 s externos pendentes. Naves/tiros não iniciados.

## Registro E04 — 28/10/2026

- **Autoridade:** professor define 20×10, metade esquerda, velocidade superior à das naves, salto 15/3/5/3. Ao ser consultado sobre D05, o aluno respondeu “façaoq achar que faz mais sentido”, autorizando a escolha técnica. Isso não confirma uma interpretação do professor.
- **D05:** contar o avanço horizontal do terreno ocorrido depois de entrar no topo, independentemente de X do jipe. É uma referência de progresso do cenário, não o deslocamento líquido relativo entre jipe e terreno. Resolve salto parado, à esquerda e bloqueado nas bordas. `ContarTopo(AX=pixels)` satura em 5 e sinaliza descida ao alcançar/cruzar o limiar; frames sem avanço não contam. Com passo 2, as amostras são 2/4/6, cruzando o quinto pixel entre quadros: até 1 pixel de discretização na configuração atual; desce na próxima atualização do jipe. Não foi substituído por cinco frames. Testes explícitos 0, 1+2+1+1 e 2+2+2 distinguem pixels de frames. Se o professor exigir referência diferente ou amostragem exatamente no quinto pixel, rever esta decisão.
- **D08:** origem no canto superior esquerdo; sprite inteiro nas colunas 0..159. `JIPE_X_MAX=320/2-20=140`; clamp nos dois limites, inclusive passo residual. X inicial=0. Apoio validado por geometria e pixels: pista começa em 193, jipe ocupa 183..192, origem no topo=168.
- **Cadência:** jipe 3 px/1 tick; reserva das futuras naves 1 px/2 ticks, com assertiva de velocidade na montagem. As naves ainda não existem na partida; comparação em execução será feita na E06. Terreno preservado em 2 px/2 ticks. As escolhas absolutas são técnicas.
- **Entrada:** acompanhar make/break por IRQ1 somente durante PARTIDA, para permitir duas setas e impedir repetição de ↑ após pouso. Pressão no ar não fica enfileirada; esquerda+direita são neutras. Menu/setor/fim mantêm BIOS. Vetor restaurado antes de Game Over/saída; teste de eventos Windows e fluxo verificam retorno.
- **Desenho:** buffer próprio de 200 bytes sob o jipe; quando só ele muda, restaurar captura da rolagem atual. Quando o terreno muda, recompor cenário e descartar captura anterior. Nenhum fundo do menu é usado na partida. Dados 34.969 bytes; artes e relógio E03 preservados.
- **Arquivos:** MOON.ASM, LEIA-E04, testes/evidências E04, snapshot E03BASE, guias/planejamento/prompts afetados. D04 continua proposta SETOR 1/Enter. Não foram iniciados obstáculos, colisões, naves ou tiros.

## Registro E03 — 26/10/2026

- **Origem/autoridade:** o aluno pediu implementar somente cenário/status e tratar D01/D02/D03/D10. As soluções abaixo são interpretações e escolhas técnicas dentro desse escopo; não foram apresentadas como respostas do professor ou confirmações específicas do aluno.
- **D01:** seguir a posição determinada pelo texto original. Score em texto (0,0); vidas 18×11 em (151,2); relógio 7×8 em (280,3); tempo de três dígitos alinhado à direita; tudo em y=0..14. Teste: dumps reais de 3/2/1/0 vidas, score e troca 100→099→000, comparados com grades e glifos BIOS.
- **D02:** regressiva de 90 s, constante de 1..999; score inicial zero. DOS fornece centésimos desde a referência inicial; frações acumuladas, segundos inteiros, minutos/horas e uma virada de dia considerados. Cadência do terreno independente. Teste: 99+1/350 centésimos, pausa de 70 s, meia-noite, execuções reais de 4/45 s, reinício e comparação 2/4 ticks. Resolução do DOS e atraso de consulta permanecem; não aceita ajuste manual do relógio ou intervalo de 24 h sem consulta.
- **D03:** três vidas por padrão, configuráveis 1..3. Reutilizadas as três artes autorais. Testes mudam o valor para conferir desenho; o programa normal não perde vidas na E03.
- **D10:** largura repetível 320; montanhas 320×64 desde y=100, montes 320×32 desde y=132, bases alinhadas em 163; repetir a última linha composta em 164..192. Pista 320×7 em 193..199, desenhada por último. Total do relevo: 93 linhas, dentro do máximo 95. Teste: cada pixel durante duas voltas, composição independente das capturas, bases preenchidas e emenda 318→0 equivalente a 2 px.
- **Memória/renderização:** buffer de uma linha (320 bytes), compor antes de copiar ao vídeo. Mesmo deslocamento em ambas as camadas, 2 px/2 ticks; sem paralaxe, sem restauração de fundo antigo. Dados atuais 34.739 bytes. As artes E02 permanecem idênticas.
- **D02, ajuste medido:** a comparação com Stopwatch Windows detectou antecipação de cerca de 26 ms na primeira versão. Acrescentada margem inicial de 6 centésimos, uma vez por sessão, para cobrir a resolução DOS de aproximadamente 55 ms. Não se soma margem a cada segundo. Essa tolerância é técnica e explícita; segundos/duração foram testados novamente após a correção.
- **D04:** não resolvida; SETOR 1/Enter continua proposta. Removido somente o salto demonstrativo para 12345; agora `EntrarGameOver` recebe o score da sessão ao expirar o tempo. Integração de vidas/obstáculos/naves permanece para suas etapas.
- **Arquivos afetados:** MOON.ASM, BUILD.BAT, LEIA-E03.md, scripts/testes E03, documentos 03/09/14, README e prompts E03/E04. Nenhuma arte foi refeita; os guias E01/E02 continuam históricos.

## Registro E02 — 24/10/2026

Registro histórico; D18 foi encaminhada pela autorização abaixo em 25/10.

- **D04 — proposta técnica:** SETOR 1, sem duração automática; Enter avança. Arquivos: MOON.ASM, LEIA-E02.md e documento 08. Aceitação: tela não pula por Enter antigo, identifica demonstração e só abre GAME OVER com nova tecla. Conteúdo/avanço sujeitos a confirmação antes de E07.
- **D16 — regra do professor atendida:** Moon Patrol verde-claro 0Ah, gerado no TAAG. **Escolha técnica:** fonte Mini, 39×4 caracteres, para caber em 40 colunas. GAME/OVER usam Small. Origem em artes/taag.json e capturas; teste compara a transcrição.
- **D17 — interpretação técnica:** vermelho 04h da tabela. Aceitação: pixels das duas palavras com índice 04h. Não houve confirmação adicional do professor.
- **D18 — bloqueio de arte:** não existem originais na pasta sugerida; o anexo original contém somente texto. Solicitadas referências. Preparados molduras de ensaio e espaços transparentes nas medidas exatas; relevo não convertido. Aceitação final exige comparação com as imagens recebidas, ainda pendentes.
- **Opções técnicas da E02:** Jogar inicialmente selecionado; passo 2 px/2 ticks; fundo preto estático; FFh transparente e 00h opaco; retorno inteiro a X=0 sem recorte parcial. Capturar todos os fundos antes de desenhar evita rastros com vários objetos. São soluções da implementação, não requisitos novos nem decisões atribuídas ao aluno.
- **Demonstração:** score 12345, aviso explícito de ausência de partida. Integração real com tempo/vidas fora da E02. Demais D não foram resolvidas nesta etapa.

## Registro E02 — 25/10/2026, artes autorais

- **Decisão do aluno, D18:** autorizou pesquisar imagens do Moon Patrol original apenas como base para compreensão e iniciar geração/implementação de desenhos próprios, sem copiar. Substitui o encaminhamento anterior que exigia recuperar todas as figuras antes de desenhar. Não altera as medidas do professor.
- **Referência visual:** capturas do arcade disponibilizadas pela HAMSTER na PlayStation Store (Arcade Archives). Links e observações em `../artes/referencias/README.md`. Não usados sprites extraídos, tracing, conversão de screenshots ou dados do jogo original.
- **Escolhas de desenho:** jipe magenta/ciano com três rodas e dois canhões; naves de disco, asas e losango; corações, relógio, três crateras e quatro rochas distinguíveis. Cores/formas são do projeto, não exigências adicionais. Permanecem os tamanhos e quantidades do enunciado.
- **Relevo preparado:** montanhas 320×64 e montes 320×32, ambos com bordas laterais iguais; podem ser sobrepostos pela base. Tamanhos escolhidos tecnicamente, abaixo da altura máxima 95. Não fixa D10 nem implementa rolagem/cenário da partida.
- **Armazenamento:** 17 bitmaps, 32.932 bytes. Dados incorporados em MOON.ASM; auxiliares gráficos produzem grades/DB/prévias. FFh continua transparente e 00h preto opaco. Sem dependência adicional para o EXE.
- **Limite:** figuras do professor permanecem indisponíveis. O projeto usa artes próprias autorizadas pelo aluno; a aceitação dessa aparência pelo professor não foi informada. D04 continua SETOR 1/Enter provisório. D01–D15 não foram resolvidas por esta criação de artes.
