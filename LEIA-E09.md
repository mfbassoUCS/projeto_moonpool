# E09 — revisão e preparação para apresentação

**Revisão posterior de 07/11:** após o primeiro relato físico, foram feitos [ajustes de desempenho, salto e relevo](AJUSTES-JOGABILIDADE.md). O hash e os ensaios desta página descrevem a revisão anterior. Para o fonte atual e seus testes específicos, consultar o relatório de ajustes; não usar os testes com expectativa fixa de passo 3 como se a configuração ainda fosse a mesma.

Para a primeira execução e compartilhamento com o colega, use o [README](README.md). A revisão complementar de 06/11 está em [auditoria de completude](planejamento/18-auditoria-e-passagem.md). Preencha o [checklist baseado no professor](CHECKLIST-PROFESSOR.md) e siga o [estudo progressivo](ESTUDO-DO-CODIGO.md), com [catálogo das rotinas](MAPA-DO-CODIGO.md). Esses materiais não marcam os testes humanos abaixo como concluídos.

Estado em **06/11/2026**: código completo revisado e material de apresentação preparado. Suíte e ciclo sintético na IDE executados em 02/11; KEY e conferência final concluídos em 06/11. **Validação física ainda incompleta; apresentação e submissão não realizadas nesta sessão.** Não há E10 iniciada.

Comece pelo [guia de apresentação e perguntas de compreensão](GUIA-APRESENTACAO.md). A [revisão R01–R28 × T01–T20](planejamento/17-revisao-e09.md) localiza cada requisito no fonte; o [andamento](planejamento/14-andamento.md) guarda a passagem. O fonte único do jogo é [MOON.ASM](MOON.ASM).

## O que mudou

- Corrigidos comentários antigos que diziam “sem tiros”, omitiam Espaço ou tratavam impacto como futuro. **Nenhuma instrução, dado, arte, constante ou regra de jogo mudou em relação à E08.** Os 69 procedimentos têm função, entradas e saídas; inventário e comparação em [inspecao.txt](evidencias/e09/inspecao.txt) e [diff](evidencias/e09/alteracoes-fonte.diff).
- Corrigida uma falha observada no auxiliar PowerShell: a leitura de sinal podia abortar quando o DOSBox ainda estava gravando. Agora IOException transitória é tentada novamente no próximo polling, mantendo timeout e verificações. Aplicado aos executores E08 e KEY. A primeira tentativa incompleta está identificada nas evidências.
- Acrescentadas opções de pasta/data/E09 ao conferidor para registrar a revisão sem sobrescrever relatórios E07/E08. Os oráculos e regras dos harnesses foram mantidos.
- Preparados guia, matriz, limitações e retomada. E08BASE preserva exatamente o fonte de 01/11; E07BASE continua idêntico ao mínimo anterior.

Fonte revisado SHA256: `9DA00E10ECE6CB09B5D33509F8BA71F3257465CA885E1347934BD90C0D2EC11C`. Dados 35.431 bytes; código 4.854; pilha 256. O jogo continua `.8086`, ASCII, modelo small e desenho/apagamento por memória. Não requer Python/Pillow para montar ou jogar.

## Evidências e alcance

| Verificação | Evidência e interpretação |
|---|---|
| Montagem e suíte | [Relatório E09](evidencias/e09/verificacao.txt), [naves](evidencias/e09/regressao-naves.txt), [telas](evidencias/e09/regressao-telas.txt), [mínimo](evidencias/e09/regressao/verificacao.txt); logs/hashes na pasta `evidencias/e09/logs` |
| Tiros | E08LOG: 426 verificações; E08PIX: 170 quadros/11.050.000 bytes; E08AUTO: fluxo com tiros, rocha+nave, branco remanescente, reposição, expiração curta, última vida/reset/IRQ |
| Mínimo preservado | R08/N08: cenário/relógio, 80 estados/640 quadros do jipe, 362 verificações terrestres/sete saltos, 4.096 sementes, 48 grupos/394 obstáculos, 390 quadros de naves/336 terrestres, sprites/menu/setor/fim/reset |
| Entrada automatizada | E08KEY usa PostMessage→SDL **windib**→DOSBox→IRQ1; não aprova teclado físico/backend normal |
| Botões atuais da IDE | [Registro específico](evidencias/e09/gui-validacao.md): Assemble/Build/Run acionados via acessibilidade; fonte reaberto e conferido. Menu→setor→partida→Game Over/score50→menu→Sair com eventos sintéticos; capturas reais da janela |
| Inspeção | 69 cabeçalhos; código sem comentários idêntico à E08; 135 artefatos históricos/snapshots preservados por manifesto SHA256; enunciado/requisitos/constantes e interfaces revisados |

**Somente R08AUTO** desabilita emissão inimiga para isolar o oráculo antigo do mínimo. **E08AUTO** executa o fluxo com tiros habilitados. Poses/sementes/tempo curto/score forçados pertencem aos testes. PNGs gerados pelos conferidores são RAM reconstruída; os `gui-*.png` identificados no registro da IDE são capturas de janela. Nenhum deles prova conforto humano. Os tempos efetivos da expiração curta constam do relatório, sem equivaler aos 90 s normais.

E07 preservada: `FCA3099062C1F4BF34EB1EAADE7E98991587453E6D5A77B83A7025DBCBE10901`. E08BASE: `27B2C4915F13B43CE55E4B0BC79A1F477A0E048B4F6BB94EA479D342D56DCB1A`. As etapas antigas não foram refeitas; os oráculos existentes foram reaplicados ao fonte atual.

## Como executar e repetir a verificação

Para jogar/apresentar, abra `ABRIR-GUI.cmd`, selecione Turbo 16-bit e confirme a primeira linha E09 de MOON.ASM. A IDE **restaurou uma aba E01 nesta sessão**: se ocorrer de novo, feche a aba antiga sem salvar e reabra o arquivo do disco. Use Assemble, Build e Run; leia os logs. O atalho `EXECUTAR-E08.cmd` também monta o fonte atual por BUILD.BAT; depois digite `MOON`, mas esse caminho não aciona os botões da IDE.

Para reproduzir a suíte atual, na raiz e **sequencialmente, sem outras instâncias dos testes**:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File testes\executar-e08.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File testes\executar-teclado-e08.ps1
python testes\conferir-e08.py --saida evidencias/e09 --data 06/11/2026 --e09
```

Em nova execução, use a data real e outra pasta se quiser preservar também esta E09. Para conferir os dados já executados nesta sessão, o comando final usou também `--data-suite 02/11/2026 --data-teclado 06/11/2026`, sem atribuir a execução antiga ao dia da conferência. O primeiro comando pode levar vários minutos: varreduras usam cycles=50000; fluxo real usa auto. São TASM 4.1/TLINK 7.1.30.1/DOSBox 0.74-3 do GUI Turbo Assembler 5.1. Confira os términos PASS R08/N08/E08 e PASS KEY, ausência de FAIL, hashes e o conferidor inteiro; montagem isolada não aprova o conjunto. Os auxiliares de automação GUI em `evidencias/e09` têm handles transitórios desta sessão, não são um lançador portátil.

## Ações humanas ainda necessárias

Não houve relato físico novo recebido nesta sessão após a pergunta sobre testes posteriores a 01/11. Registre **data, fonte/ambiente, ação, observado e passou/falhou**; em caso de falha, inclua a sequência para reproduzir.

1. **Teclado físico e ciclo:** no ambiente de apresentação, testar ↑/↓/Enter nas telas, esquerda/direita/↑/Espaço juntos na partida, mantida/soltura/nova pressão no chão/ar e após morte; voltar ao menu, reiniciar e Sair. Os botões atuais já têm evidência automática; falta o uso físico no ambiente em que você apresentará.
2. **Jogabilidade:** saltar crateras e rochas, conferir +50 único, resistências 1/1/2 e rocha indestrutível, +100 por nave, vidas/reposição; tentar esquivar dos brancos e avaliar conforto, fluidez, cintilação/rasgos. A colisão por retângulos tem janela conservadora para rochas. Use mais de uma partida se necessário para encontrar os tipos.
3. **Tempo normal:** sobreviver até esgotar os 90 s, usando cronômetro externo a partir do primeiro quadro da partida; conferir Game Over e reinício. A montagem não tem tecla de invulnerabilidade. Se perder todas as vidas antes, esse ensaio não valida expiração por tempo.
4. **Esclarecimentos relevantes:** registrar orientações do professor sobre a referência dos cinco pixels do topo (D05), a “metade horizontal” das naves (D06), os dois impactos “consecutivos” (D11), setor/artes se houver exigência adicional (D04/D18) e eventual segundo montador em D12. As escolhas atuais estão explícitas e não são confirmações do professor.
5. **Organização e apresentação:** confirmar integrantes (até dois), inscrição em um dos 15 grupos e data concreta do último dia de aula; praticar o guia e responder às perguntas; realizar a apresentação no GUI Turbo Assembler/Windows.
6. **Submissão:** enviar o código-fonte pelo canal/formato solicitado **somente depois da apresentação**. Não foi enviado arquivo à faculdade e não se presume exigência de ZIP, vídeo ou relatório.

Use o [prompt de retomada E09](planejamento/prompts/E09-revisao-e-apresentacao.md) para registrar esses resultados ou corrigir falha concreta. Código revisado e testes automáticos aprovados não significam validação física completa nem avaliação acadêmica concluída.
