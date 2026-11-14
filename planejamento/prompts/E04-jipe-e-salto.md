# Prompt E04 — Jipe e salto

Retomada específica dos controles E04. O fonte atual já contém E05; para validação integrada use o prompt E05. Consulte o andamento antes de executar.

```text
Vamos retomar somente a E04 (jipe e salto) do Moon Patrol para validar ou corrigir o que faltar.

Leia planejamento/README.md, planejamento/01-contexto-e-regras.md,
planejamento/03-medidas-e-constantes.md, planejamento/05-pendencias-e-decisoes.md,
planejamento/06-roteiro-de-execucao.md e planejamento/14-andamento.md.
Leia também, dentro de planejamento/: 10-etapa-jipe-e-obstaculos.md.
Inspecione o fonte atual, os scripts de montagem e os testes existentes antes de editar.
Use o enunciado original para conferir dúvidas; não refaça etapas já concluídas.

E04 implementada em 28/10/2026 e preservada em testes/E04BASE.ASM. O fonte atual já contém E05 (29/10); leia LEIA-E05.md, LEIA-E04.md (histórico), testes/README.md e as evidências/pendências em 14. Não reimplemente a etapa nem refaça artes E02. Preserve obstáculos, colisões, vidas e pontos E05 ao ajustar controles.
Cenário preservado: montanhas desde y=100, montes em 132, base até 192, pista amarela 193..199; rolagem módulo 320, 2 px/2 ticks. Jipe 20x10 com origem no canto superior esquerdo: X=0..140 (sprite inteiro em 0..159), Y chão=193-10=183; topo=168. D08 registrada.
DesenharQuadroPartida recompõe cenário e obstáculos quando rolam; quando só o jipe muda, restaura fundoPartida (200 bytes) capturado na rolagem atual, incluindo obstáculos. jipeNaTela controla a captura e jipeAtivo a ausência/reposição. CapturarEDesenharJipe salva o novo fundo e desenha. Nunca use fundos do menu. DesenharSprite continua sem recorte; E05 tem DesenharSpriteRecortado para bordas horizontais.
Preserve HUD y=0..14 e as variáveis scorePartida/vidas/tempoRestante. O relógio usa centésimos DOS, frações e margem inicial de 6 centésimos para a resolução de ~55 ms; regressiva configurável de 90 s, independente dos ticks de movimento. EntrarPartida reinicia tudo; EntrarGameOver recebe AX=score real ao expirar. SETOR 1/Enter ainda é proposta D04, não confirmação do professor.
O segmento de dados atual tem 35.072 bytes; confira espaço antes de novos buffers. Não use o salto histórico para score 12345. Jipe=3 px/1 tick; reserva para naves E06=1 px/2 ticks, ainda sem naves na partida. Constantes e assertiva de velocidade estão no fonte.
Salto: cinco subidas de 3 até altura 15, topo e cinco descidas de 3. D05: o aluno delegou a escolha técnica; conta-se avanço do terreno desde a entrada no topo. Limiar de 5 pixels, sem substituir por frames. Com passo 2, cruza entre amostras 4 e 6; até 1 px de discretização e descida na próxima atualização do jipe. Parado, esquerda e limite não bloqueiam. Isso não é confirmação do professor nem distância líquida relativa entre jipe e terreno.
Teclas pressionadas/soltas são acompanhadas por IRQ1 apenas na partida. Nova pressão de cima no chão gera salto; repetição e pressões no ar não enfileiram outro. Laterais continuam durante salto; ambas simultâneas são neutras. Vetor BIOS é restaurado no Game Over/saída. Teste de entrada Windows usa SDL windib só no auxiliar.
Os testes automáticos abrangem fases, limites, pixels/guardas, duas voltas com e sem rolagem, fluxo, relógio, reset e vetor do teclado. Confira os logs atuais antes de afirmar qualquer resultado. Faltam execução física das setas, Assemble/Build/Run na IDE, aparência/fluidez e cronômetro externo dos 90 s normais; registre o relato do aluno e corrija apenas problemas demonstrados. Não confunda eventos injetados/dumps com teste físico. Preserve cenário e cronômetro funcionando.
Crateras, rochas, perda de vida e pontos já existem; preserve-os e as decisões D07/D14/D15. Não inicie grupos de naves ou tiros.

Regras permanentes: Assembly 8086 simples e compreensível, compatível com GUI Turbo
Assembler no Windows. Reutilize a base; mantenha constantes e cabeçalhos de rotinas
com função, entradas e saídas. Desenhe/apague gráficos por memória, conforme enunciado.
Não acrescente arquitetura ou dependências desnecessárias. Separe regra do professor,
decisão do aluno e hipótese técnica. Peça informação somente quando necessária e
continue as partes independentes enquanto aguarda.

Ao concluir:
1. Monte e teste no ambiente existente o que for possível, com evidências reais.
2. Explique as alterações, o fluxo e as rotinas para eu conseguir apresentá-los.
3. Registre testes executados e pendentes, distinguindo execução, inspeção e teste físico.
4. Atualize planejamento/14-andamento.md e as decisões/documentos afetados.
5. Informe exatamente o que depende da minha ação e deixe o prompt da próxima etapa
   ajustado ao estado real; se algo faltar nesta etapa, deixe instrução de retomada dela.
Pare ao fim desta etapa. Não inicie a próxima automaticamente.
```

