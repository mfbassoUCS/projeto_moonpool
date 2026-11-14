# Roteiro para chats separados

Cada etapa deve produzir uma alteração pequena, explicável e verificável. Esta ordem é uma proposta de execução futura. Se uma etapa ficar grande, dividi-la em subchats e registrar o ponto exato no andamento.

| Etapa | Ler além de 01/05/14 | Dependência | Resultado esperado para concluir |
|---|---|---|---|
| E01 — Ambiente e base | 03, 07 | Autorização para iniciar implementação | Montagem/execução no ambiente alvo, vídeo, desenho por memória, teclado e base de tempo verificados |
| E02 — Artes e telas | 03, 04, 08 | E01; referências para reprodução ou artes próprias autorizadas (D18, 25/10) | Bitmaps nas medidas, menu funcional e animado, tela de encerramento reutilizável |
| E03 — Cenário e status | 03, 09 | E01; artes necessárias de E02 | Terreno contínuo, pista, HUD e temporização independentes da entrada |
| E04 — Jipe e salto | 03, 10 | E03 | Implementada em 28/10; testes e pendências em 14/LEIA-E04. Validação física ainda necessária |
| E05 — Obstáculos e vidas | 10 | E04 | Implementada em 29/10; geração, colisões, reposição e pontos testados automaticamente. Validação física/IDE pendente em 14/LEIA-E05 |
| E06 — Grupos de naves | 11 | E03; sprites E02 | Implementada em 29/10; geração, movimento, remoção e composição testados. D06/D07/D09 documentadas; validação física/IDE pendente em 14/LEIA-E06 |
| E07 — Integração do mínimo | 02, 13 | E02–E06 | Integração/verificação automática realizadas em 31/10; D04 e matriz T01–T20 registradas. Validação física para apresentação ainda pendente; ver LEIA-E07 |
| E08 — Disparos completos | 12 | Mínimo estável | Implementada em 01/11: dois canhões, tiros inimigos, colisões e resistência; testes E08/N08/R08. Validação física pendente em LEIA-E08/14 |
| E09 — Revisão e apresentação | 13, 17 | E07 e E08 incluída | Revisão/guia/matriz preparados em 02–06/11; suíte e ciclo sintético IDE registrados. Validação física, inscrição/data, apresentação e submissão posterior pendentes; retomar E09 |

## Regra de conclusão de um chat

1. Conferir critérios da etapa e requisitos R associados.
2. Testar no GUI Turbo Assembler sempre que possível; anotar exatamente o que foi executado e o que falta validar.
3. Explicar dados, fluxo, rotinas e qualquer instrução nova ao aluno.
4. Registrar em 14 os arquivos modificados, decisões e resultado. Atualizar 05 se uma hipótese foi confirmada.
5. Deixar o próximo passo concreto, sem começar automaticamente a próxima etapa.

## Portões de qualidade

Não considerar montagem bem-sucedida como prova de jogabilidade. Não considerar funcionamento em outro emulador como validação da apresentação. Não começar os extras para esconder falhas no mínimo. Não aumentar complexidade antes de demonstrar que a abordagem simples é insuficiente.
