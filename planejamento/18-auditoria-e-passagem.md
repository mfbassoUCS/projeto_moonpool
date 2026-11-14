# Revisão de completude e passagem para a dupla — 06/11/2026

## Conclusão

**As etapas de implementação estão presentes; o trabalho inteiro ainda não pode ser declarado concluído.** E09 tem revisão técnica e material preparados, mas depende de testes físicos, entendimento pelos integrantes, esclarecimentos relevantes e apresentação/entrega. O aluno informou nesta sessão que ainda não abriu o jogo; não existe aprovação manual implícita.

Nesta revisão foram conferidos o enunciado original, constantes e lógica do fonte atual (telas, entrada, tempo, desenho, jipe, obstáculos, naves e tiros), decisões, guias, scripts de abertura e evidências E09. O hash atual de MOON.ASM é `9DA00E10ECE6CB09B5D33509F8BA71F3257465CA885E1347934BD90C0D2EC11C`, igual ao relatório E09. As 69 rotinas estão catalogadas para estudo. **Não executei novamente a suíte nem fiz teste físico nesta sessão.** Os resultados de execução citados são os registros existentes, com suas datas e limitações.

## Etapas

| Etapa | Conferência atual | O que falta para fechar a aceitação |
|---|---|---|
| E01 | Base, montagem, desenho por memória e ambiente presentes | Executar na máquina usada pela dupla/apresentação |
| E02 | Artes, menu animado, setor e Game Over presentes | Teclado/aparência físicos; adequação das artes autorais à exigência das figuras |
| E03 | Cenário circular, pista, HUD e relógio presentes | Fluidez/emenda visual e 90 s normais com cronômetro externo |
| E04 | Movimento e salto trapezoidal presentes | Conforto/teclas simultâneas e interpretação exata do topo |
| E05 | Crateras, quatro rochas, colisões, pontos e reposição presentes | Testar fisicamente travessias, mortes e pontos; conferir critérios adotados |
| E06 | Grupos homogêneos aleatórios e movimento presentes | Observação real; confirmar interpretação da metade horizontal se exigido |
| E07 | Ciclo mínimo integrado; regressões registradas | Partidas reais e reinícios completos |
| E08 | Dois canhões, tiros inimigos e resistências presentes | Esquiva, resposta/cadência, combinações de teclas e casos de combate reais |
| E09 | Revisão, evidências e guia presentes | Checklist humano, aprendizagem, ensaio, apresentação e submissão posterior |

Não identifiquei um módulo funcional inteiro faltando no escopo completo. Isso não prova ausência de bugs nem resolve ambiguidades por si só. A matriz [17](17-revisao-e09.md) relaciona R01–R28 ao fonte; o [novo checklist](../CHECKLIST-PROFESSOR.md) parte do que foi pedido e não das aprovações antigas.

## Pontos que impedem afirmar conformidade literal irrestrita

| Ponto | Enunciado | Implementação/limite observado | Ação |
|---|---|---|---|
| Artes | Referencia bitmaps/figuras, com medidas e tipos | 17 bitmaps próprios, autorizados pelo aluno; originais não arquivados | Não afirmar identidade visual. Conferir com professor se a aparência própria é aceita |
| Topo do salto, D05 | 5 pixels de deslocamento horizontal | Conta avanço do terreno; passo 2 cruza limiar entre 4 e 6, não amostra exatamente 5 | Explicar a escolha e o arredondamento; rever se professor exigir referência/exatidão diferente |
| Naves, D06 | Posição horizontal “não pode ultrapassar a metade horizontal” | Formação de largura até 160 fora da direita, em [320,480) | Confirmar a interpretação; testes atuais validam a convenção escolhida |
| Pontuação por salto | +50 ao superar sem colisão | Aguarda travessia completa e pouso seguro; morte antes de pousar cancela candidata | Observar diferença entre cruzar e pousar; perguntar se o professor exige prêmio imediato na travessia |
| Reposição, D14 | Novo jipe em coluna zero; partida continua | Aguarda área de reposição livre, sem invulnerabilidade | Documentar espera; não confundir com jipe travado nem com regra expressa do professor |
| Rocha 4, D11 | Dois impactos consecutivos | Dois impactos na mesma instância sem prazo; errar/outro alvo não reinicia | Demonstrar e confirmar se “consecutivos” tiver outro sentido pretendido |
| HUD, D01 | Texto e imagem divergem | Segue texto: score esquerdo/vidas centro | Manter divergência documentada |
| Ferramentas/arte, §7.5 | Auxílio gráfico externo permitido; equipe responsável pela conversão/memória | Grades próprias e gerador Python de DB; runtime Assembly | Dupla deve entender e explicar conversão; não atribuir ao professor aprovação específica do fluxo |

Os demais parâmetros (90 s, 3 vidas, capacidade/cadência, dimensão do tiro superior) estão registrados como escolhas técnicas. Não exigir sons, fases extras ou minas da introdução histórica.

## Cobertura e limites dos testes existentes

Relatório [E09](../evidencias/e09/verificacao.txt) registra 426 verificações de tiros, comparação de 170 quadros e regressões de grupos/obstáculos/salto/telas. A entrada foi automatizada e os cenários controlados usam variantes. Somente a variante R08AUTO desliga emissão inimiga para isolar o mínimo; E08AUTO e jogo normal têm tiros habilitados. Não tratar esses resultados como se os alunos tivessem jogado.

Hash igual vincula o fonte atual ao relatório, mas não comprova que qualquer EXE encontrado foi recém-montado nem que o comportamento será idêntico em outro computador. Por isso o roteiro de abertura manda montar antes de jogar e conferir erros. Não repeti testes longos sem alteração de código ou falha nova que justificasse a repetição.

## Contexto para compartilhar

Os guias LEIA-E01–E09 e o guia de apresentação já guardavam boa parte das decisões e explicações. Faltava uma entrada única para alguém sem os chats, um checklist desmarcado centrado no professor e um percurso de aprendizado por dificuldade. Criados:

- [README da raiz](../README.md): contexto, estado, abertura, controles e compartilhamento/portabilidade.
- [Checklist do professor](../CHECKLIST-PROFESSOR.md): requisitos, método de verificação, casos práticos e registro de resultado.
- [Estudo do código](../ESTUDO-DO-CODIGO.md): leitura progressiva, exemplos reais, exercícios e prompts de tutoria.
- [Mapa do código](../MAPA-DO-CODIGO.md): índice e contratos de todas as 69 rotinas, derivados do fonte atual.

Os documentos históricos foram preservados. As imagens originais da disciplina continuam ausentes; isso não é resolvido por descrições em Markdown. Corrigida a orientação atual sobre setor/artes no README de artes, sem apagar o histórico. Nenhum fonte, executável, regra, teste ou arte do jogo foi alterado nesta sessão.

## Próximo passo

Aluno e colega abrem o jogo pelo README e fazem a primeira sessão do checklist. Registram resultados, incluindo o que não conseguiram testar. Em paralelo começam o encontro 1 do estudo. Retomar E09 para corrigir falhas concretas e fechar a validação; nenhuma nova fase de implementação é necessária só porque a dupla começou a estudar.
