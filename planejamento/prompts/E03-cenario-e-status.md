# Prompt de retomada E03 — validação e ajustes

Copie para retomar somente as pendências da E03. A implementação já existe; consulte as evidências atuais antes de alterar.

```text
Vamos retomar somente a validação da E03 (cenário e status) do Moon Patrol.

Leia planejamento/README.md, planejamento/01-contexto-e-regras.md,
planejamento/03-medidas-e-constantes.md, planejamento/05-pendencias-e-decisoes.md,
planejamento/06-roteiro-de-execucao.md e planejamento/14-andamento.md.
Leia também, dentro de planejamento/: 09-etapa-cenario-e-status.md.
Inspecione o fonte atual, os scripts de montagem e os testes existentes antes de editar.
Use o enunciado original para conferir dúvidas; não refaça etapas já concluídas.

Leia LEIA-E03.md, artes/README.md, testes/README.md e evidencias/e03/verificacao.txt.
Estado em 26/10/2026: E03 implementada e verificada automaticamente no emulador do GUI Turbo Assembler. As 17 artes autorais da E02 estão preservadas. Não refaça sprites nem exija as figuras ausentes (D18).
Já existem rolagem circular de 320 pixels para a esquerda, buffer de linha de 320 bytes, montanhas em y=100, montes em y=132, base prolongada até 192 e pista amarela em 193..199. Dados atuais: 34.739 bytes. A emenda foi conferida pixel a pixel e por duas voltas reais em vídeo.
HUD segue o texto: score esquerdo, vidas 18x11 centrais e relógio 7x8/tempo à direita, tudo em y=0..14. D01/D02/D03/D10 são escolhas/interpretações técnicas registradas, não confirmações do professor: três vidas e 90 segundos regressivos configuráveis. Score normal zero, sem fontes de pontos nesta etapa.
O relógio usa centésimos DOS completos e frações, com margem inicial única de 6 centésimos para cobrir a resolução aproximada de 55 ms. Tempo e movimento são independentes; pausas menores que um dia e virada de meia-noite têm tratamento. Não reintroduza o contador incompleto da E01.
EntrarPartida reinicia os valores; expiração chama EntrarGameOver com AX=scorePartida. SETOR 1/Enter permanece proposta D04. O salto direto para 12345 existe somente no snapshot histórico E02.
Pendências: montagem/execução pelos botões da IDE, teclado físico, revisão da aparência e observação de fluidez/cintilação/rasgo pelo aluno. Oriente e registre esses testes: duas voltas (~36 s), HUD intacto, comparação com cronômetro, expiração normal em 90 s, retorno, reinício e Sair. Não apresente automação BIOS como teclado físico.
Se houver defeito observado, reproduza e corrija somente a E03, mantendo constantes, memória e simplicidade. Os testes reproduzíveis são testes/executar-e03.ps1 e testes/conferir-e03.py. Não repita verificações já aprovadas sem mudança ou nova suspeita.
DesenharSprite continua sem recorte parcial. O cenário é recomposto; os fundos estáticos do menu não servem para validar futuros objetos sobre fundo rolando.
Não implemente movimento/salto do jipe, geração de obstáculos, naves ou tiros.

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

