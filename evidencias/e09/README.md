# Evidências da E09

Fonte SHA256 `9DA00E10ECE6CB09B5D33509F8BA71F3257465CA885E1347934BD90C0D2EC11C`. Revisão e execução da suíte em **02/11/2026**; retomada, KEY e conferência final em **06/11/2026**. O fonte permaneceu igual nesse intervalo.

| Arquivo | Natureza e resultado |
|---|---|
| [verificacao.txt](verificacao.txt) | Conferidor completo aprovado; 426 verificações de tiros, 170 quadros/11.050.000 bytes, fluxo e KEY; datas de execução e conferência explícitas |
| [regressao-naves.txt](regressao-naves.txt) | Regressão de grupos/naves/mínimo; execução DOS real e comparação de pixels |
| [regressao-telas.txt](regressao-telas.txt) | Menu/setor/fim, tempo de espera, cores e sprites |
| [regressao/verificacao.txt](regressao/verificacao.txt) | Cenário, salto, obstáculos, pontos, vidas, reposição e fluxo do mínimo |
| [execucao-suite.txt](execucao-suite.txt) | Saída completa da repetição final de 02/11, PASS R08/N08/E08 |
| [logs](logs) | 27 cópias dos logs, hashes de fonte, mapa e medidas; manifesto próprio `sha256.json`. KEY foi renovado em 06/11 |
| [gui-validacao.md](gui-validacao.md) | Botões Assemble/Build/Run e ciclo por entrada sintética na IDE em 02/11; log e capturas de janela |
| [inspecao.txt](inspecao.txt) | Inspeção estática, inventário dos 69 cabeçalhos; sem mudança executável em relação à E08 |
| [alteracoes-fonte.diff](alteracoes-fonte.diff) | Seis alterações de comentários em MOON.ASM |
| [historicos-sha256.json](historicos-sha256.json) | 135 artefatos/snapshots E07/E08 preservados, reconferidos em 06/11 |
| [tentativa-01-E08RESUL.LOG](tentativa-01-E08RESUL.LOG) | **Incompleto, sem aprovação.** Executor abortou por IOException de compartilhamento ao ler E08SINAL.BIN durante escrita do DOSBox; repetição após correção gerou os resultados finais acima |

`gui-inicial.png` mostra a sessão antiga E01 que a IDE restaurou; não comprova o fonte atual. `gui-fechar.png` é uma captura incompleta de popup, não evidência de execução do jogo. `gui-fonte-atual.png`, `gui-montagem.png` e `gui-run-*.png` relacionados no registro da IDE são as capturas válidas. Os demais PNGs produzidos pelos conferidores são reconstruções de RAM, não capturas físicas nem filmagem.

Os auxiliares GUI usam PID/handles transitórios desta sessão; para jogar novamente siga LEIA-E09. Não existe captura de saída após Sair: o processo já havia terminado quando ela foi solicitada, e o encerramento foi registrado pela IDE. Modo/página/IRQ são verificados nos harnesses.

R08AUTO desabilita emissão inimiga somente para isolar seu oráculo; E08AUTO mantém tiros habilitados. E08KEY é PostMessage→SDL windib→DOSBox→IRQ1. **Nada aqui aprova teclado físico, conforto/esquiva/fluidez ou os 90 s normais com cronômetro externo.** Sem apresentação ou submissão realizadas por esta revisão.
