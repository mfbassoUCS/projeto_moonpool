# GUI Turbo Assembler — execução E09 em 02/11/2026

**Executado:** Assemble, Build e Run da interface da IDE, sobre o fonte atual `C:\ucs\moon_patrol\MOON.ASM`, Turbo 16-bit. As ações foram acionadas por acessibilidade MSAA (`accDoDefaultAction`) nos botões identificados pelos nomes. Não foram cliques do aluno. [Log da IDE](gui-fluxo.log) e [fonte reaberto](gui-fonte-atual.png).

Fonte SHA256: `9DA00E10ECE6CB09B5D33509F8BA71F3257465CA885E1347934BD90C0D2EC11C`.
EXE produzido pelos botões, antes da remontagem por BUILD.BAT: `F32EC393E057F69A8CEB2A3A215EFD7C366DAB3345B0A66183F8AB1F25BF8B20`.

- A primeira abertura restaurou um buffer antigo E01. Fechado sem salvar, reaberto do disco e conferido o cabeçalho E09/2863 linhas. Nenhuma versão antiga foi gravada sobre o fonte.
- Assemble: `TASM /ml /z /zi MOON.ASM`, TASM 4.1, sem erros/avisos; sucesso na IDE.
- Build: `TLINK /x /v /3 /k MOON`, TLINK 7.1.30.1; sucesso na IDE. Esses argumentos pertencem à configuração Turbo 16-bit existente; o seletor não foi trocado para TASM32.
- Run: a IDE executou MOON.EXE pelo Assembly Launcher. [Menu](gui-run-menu.png), [setor após Enter](gui-run-apos-enter.png), [partida](gui-run-partida.png), [fim](gui-run-fim.png) e [retorno](gui-run-retorno.png) foram capturados da janela Windows com PrintWindow e inspecionados. Estas imagens são capturas da janela, distintas dos PNGs reconstruídos dos testes de RAM.
- Entradas direcionadas por **PostMessage** ao processo criado pelo Run: Enter, direita, Espaço, ↑, solturas; letra A para voltar; ↓/Enter para Sair. Registro parcial reproduzível em `gui-eventos.log` (os primeiros Enter, enviados antes da criação do auxiliar, estão documentados pelas capturas).
- A captura de partida mostra jipe no ar à direita da posição inicial, superior/frontal, nave, HUD com três vidas e tempo 088. A captura de fim mostra score 00050. Não foi instrumentada a causa desse encerramento, a sequência de mortes, a origem individual do ganho de 50 nem a duração da partida; não atribuir esses detalhes às imagens.
- Após retorno, ↓/Enter selecionou Sair e o processo do emulador terminou. A IDE registrou conclusão da execução. A tentativa de capturar o prompt após Sair encontrou o processo já encerrado; não existe imagem de saída. Restauração de modo/página/IRQ é comprovada separadamente pelos harnesses, não inferida desse fechamento.

**Limites:** sem teclado físico, sem avaliação humana de salto/esquiva/fluidez, sem cronômetro externo dos 90 s. Nesta abertura da IDE não se alterou `SDL_VIDEODRIVER`; isso não certifica o backend nem uma entrada física. A E08KEY continua explicitamente PostMessage→SDL windib→DOSBox→IRQ1. O ciclo observado na IDE e a suíte controlada são evidências complementares.

Os auxiliares `auxiliar-gui.ps1`, `auxiliar-teclas.ps1` e `capturar-ide.ps1` registram a automação desta sessão; contêm PID/handle transitórios e não devem ser reexecutados cegamente em outra sessão. Para reprodução normal, use a IDE conforme o guia. Nenhuma captura de outro aplicativo foi usada como evidência.
