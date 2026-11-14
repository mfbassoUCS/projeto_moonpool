# Planejamento do trabalho — Moon Patrol em Assembly 8086

**Atualização vigente — 07/11/2026:** primeiro teste do aluno revelou problemas de fluidez/salto/aparência. [Ajustes aplicados e testados](../AJUSTES-JOGABILIDADE.md) aguardam reteste físico. Os resumos E09 abaixo descrevem a revisão anterior; veja o topo do andamento para o hash e evidências atuais.

**Para quem recebeu o projeto sem os chats:** comece pelo [README da raiz](../README.md). A [revisão de completude](18-auditoria-e-passagem.md), o [checklist do professor](../CHECKLIST-PROFESSOR.md), o [roteiro de estudo](../ESTUDO-DO-CODIGO.md) e o [mapa das 69 rotinas](../MAPA-DO-CODIGO.md) organizam a validação e o aprendizado em dupla.

Esta pasta organiza o trabalho em chats separados. **E01–E08 implementadas; revisão técnica e preparação da E09 finalizadas em 06/11/2026.** A versão completa mantém tiros, resistências e pontos. Consulte [LEIA-E09](../LEIA-E09.md), o [guia de apresentação](../GUIA-APRESENTACAO.md), a [matriz R×T](17-revisao-e09.md) e o [andamento](14-andamento.md). Suíte executada em 02/11, KEY e conferência final em 06/11; botões atuais e ciclo sintético na IDE executados em 02/11. **Validação física, conforto/fluidez, 90 s externos e obrigações acadêmicas permanecem pendentes.** Snapshots E01–E08 e relatórios históricos preservados.

## Como começar um novo chat

1. Leia [contexto](01-contexto-e-regras.md), [andamento](14-andamento.md) e [pendências](05-pendencias-e-decisoes.md).
2. Escolha somente uma etapa em [roteiro](06-roteiro-de-execucao.md).
   Use a [retomada E09](prompts/E09-revisao-e-apresentacao.md) para resultados físicos, ensaio e defeitos concretos. As etapas anteriores são históricas; não há nova implementação a iniciar automaticamente.
3. Leia o documento dessa etapa e as referências indicadas nele. Consulte o [enunciado original](fontes/enunciado-original.md) se houver dúvida.
4. Só implemente quando o aluno pedir. Este conjunto de arquivos não autoriza, por si só, iniciar o jogo.
5. Ao encerrar o chat, atualize o andamento com arquivos alterados, testes realmente realizados, dúvidas e próximo passo. Não marque uma etapa concluída apenas porque houve geração de código.

## Mapa dos documentos

| Arquivo | Conteúdo |
|---|---|
| [01 — Contexto e regras](01-contexto-e-regras.md) | Objetivo, prioridades, simplicidade e restrições globais |
| [02 — Requisitos e escopo](02-requisitos-e-escopo.md) | Mínimo obrigatório, versão completa e critérios acadêmicos |
| [03 — Medidas e constantes](03-medidas-e-constantes.md) | Cores, dimensões, controles e parâmetros |
| [04 — Referências visuais](04-referencias-visuais.md) | Catálogo das 13 imagens e dos três links |
| [05 — Pendências e decisões](05-pendencias-e-decisoes.md) | Contradições e decisões ainda não confirmadas |
| [06 — Roteiro](06-roteiro-de-execucao.md) | Ordem de execução e dependências |
| [07 — Ambiente e base técnica](07-etapa-ambiente-e-base.md) | Compatibilidade, desenho, teclado e tempo |
| [08 — Artes e telas](08-etapa-artes-e-telas.md) | Bitmaps, menu e Game Over |
| [09 — Cenário e status](09-etapa-cenario-e-status.md) | Rolagem, HUD, duração e pontuação |
| [10 — Jipe e obstáculos](10-etapa-jipe-e-obstaculos.md) | Movimento, salto, crateras, rochas e vidas |
| [11 — Naves](11-etapa-naves.md) | Geração de grupos e movimentação |
| [12 — Disparos](12-etapa-disparos.md) | Complemento da versão completa |
| [13 — Validação e entrega](13-validacao-e-entrega.md) | Roteiro manual, apresentação e submissão |
| [14 — Andamento](14-andamento.md) | Estado persistente entre chats |
| [15 — Prompts](15-prompts-para-novos-chats.md) | Modelos de mensagens para retomar o projeto |
| [16 — Próximo chat](16-prompt-retomada-e01.md) | Prompt específico após a conclusão da E01 |
| [17 — Revisão E09](17-revisao-e09.md) | Requisitos R×T×fonte, achados, correções e limites atuais |
| [Guia de apresentação](../GUIA-APRESENTACAO.md) | Demonstração, explicação e perguntas para praticar |
| [Fonte original](fontes/enunciado-original.md) | Texto integral enviado, preservado sem correções |

## Origem e autoridade

O enunciado e as imagens vieram do aluno em 22/10/2026. As regras acadêmicas derivam desses materiais, não do jogo on-line. As sugestões técnicas destes documentos são planejamento, não exigências adicionais do professor. As imagens podem ilustrar algo diferente do texto: essas divergências estão registradas, sem esconder a dúvida.

O texto original está salvo no repositório. As imagens foram vistas na conversa, mas seus arquivos não estavam disponíveis no diretório do anexo; o catálogo preserva descrições, não os bitmaps originais. Antes de reproduzir a arte exata em outro chat, disponibilize as imagens nesse chat ou salve seus arquivos em `planejamento/fontes/imagens/`.
