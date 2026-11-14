# Cenário continua no limite do jipe — 07/11/2026

Pedido do aluno: manter a especificação e garantir rolagem à esquerda quando o jipe atinge seu limite lateral. O código já implementa esse comportamento: `AtualizarPartida` avança cenário/obstáculos em sua própria cadência antes de atualizar o jipe. `AtualizarJipe` limita X sem interromper o laço nem limpar a indicação de mudança do cenário.

**Nenhuma alteração em MOON.ASM foi necessária.** Fonte normal, executável e configuração do jogo foram preservados. Acrescentados ensaio direcionado e esclarecimento nos guias/checklist.

## Ensaio

`testes/verificar-limite-cenario.py` cria uma variante com as rotinas reais do fonte. Executa `AtualizarPartida` por aproximadamente três segundos em cada condição: jipe X=140 com direita mantida; jipe X=140 sem tecla. Um obstáculo nasce controladamente em X=280. Verifica a cada consulta que o jipe permanece em X=140; no final exige rolagem positiva, obstáculo deslocado pela mesma distância, tempo consumido e três vidas preservadas.

Os arquivos RAW contêm vídeo A000h real antes/depois. O conferidor compara 64 linhas inteiras de relevo por captura com os pixels esperados das grades, incluindo deslocamento circular, para verificar desenho e não só variáveis. A cadência de tiro das naves é adiada **somente nessa variante**, pois projéteis sobre o relevo não fazem parte da imagem esperada desse ensaio isolado. Naves continuam movendo; o jogo normal não é alterado.

## Evidências

- `LIMITE.LOG`: montagem/link/execução; deve conter PASS e não FAIL.
- `LIMITE.BIN`: dois registros de seis words: fase, X do jipe, rolagem, X da rocha, tempo restante, Y do jipe.
- `LIM0A/B.RAW`, `LIM1A/B.RAW`: capturas de 64.000 bytes antes/depois.
- `resultado.txt`: resultado conferido, valores efetivos e hash do fonte.
- `fonte.sha256`: identidade do fonte usado para gerar a variante.

Para reproduzir: gerar com `python testes/verificar-limite-cenario.py`, executar o emulador incluído com `-conf evidencias/limite-cenario/limite.conf` e então `python testes/verificar-limite-cenario.py --conferir`. O ensaio monta LIMITE.ASM, não substitui MOON.EXE. Usa 50.000 ciclos e teclas representadas por estado controlado; não comprova percepção humana de fluidez.

A conferência inicial de pixels detectou tiros sobre a região comparada; o isolamento descrito acima corrige o arranjo de teste, sem mudar renderização nem regras do jogo. Só considerar o `resultado.txt` junto do log PASS como evidência final.
