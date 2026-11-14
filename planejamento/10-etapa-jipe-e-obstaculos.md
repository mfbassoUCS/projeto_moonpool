# E04/E05 — Jipe, salto, obstáculos e vidas

Ler 03 e D05/D07/D08/D11/D14/D15. Requisitos R16, R18–R24. **E04 implementada em 28/10/2026; E05 implementada em 29/10/2026.** Leia [LEIA-E05](../LEIA-E05.md), [LEIA-E04](../LEIA-E04.md) e 14 para evidências e pendências físicas. As seções abaixo são critérios de aceitação; interação com tiros foi implementada na E08; consulte LEIA-E08 e 12.

## Jipe e deslocamento

- Sprite 20×10 sempre, inclusive no salto, apoiado na pista plana.
- Setas esquerda/direita movem horizontalmente, limitadas à metade esquerda da tela.
- Velocidade superior à das naves, com valores parametrizados.
- Reposição após perder vida na coluna 0; posição inicial da primeira partida deve ser definida em constante.
- Movimento horizontal continua normalmente durante o salto.

## Salto trapezoidal

Implementado: estados chão, subindo, topo e descendo, com deslocamento vertical inteiro. Nova pressão de ↑ no chão inicia salto. Repetição enquanto mantida e novas pressões no ar não geram outro salto; é preciso soltar e pressionar novamente no chão. Laterais continuam ativas; ambas simultâneas são neutras.

1. Subir 3 pixels por frame até 15 pixels acima da posição normal (cinco atualizações de subida).
2. Permanecer no topo pelo limiar de **5 pixels de deslocamento horizontal**, conforme o texto. D05: aluno delegou escolha técnica; conta-se avanço do terreno desde a entrada no topo. Com passo 2, o quinto pixel é cruzado entre amostras 4 e 6 (discretização de até 1 px na configuração atual), então começa a descida na próxima atualização do jipe. Não são cinco frames; sem avanço, o contador não muda. Ver 05 para autoridade e limites da interpretação.
3. Descer 3 pixels por frame até a posição normal (cinco atualizações de descida).

Testar parado, andando em ambos os sentidos e no limite lateral. Não adotar trajetória parabólica, gravidade ou alturas variáveis, que não correspondem à especificação.

E04 usa origem X=0..140, Y chão=183 e topo=168. Jipe 3 px/1 tick; naves implementadas na E06 em 1 px/2 ticks, conforme reserva anterior. Os testes automáticos cobrem esses casos; avaliação física/visual segue pendente. E05 recompõe cenário/obstáculos antes de capturar o fundo do jipe ao rolar; restaura a captura somente se a rolagem não mudou. `ReiniciarJipe` é usado na nova sessão; a morte/reposição usa `PerderVida`/`TentarReporJipe`, preservando tempo/progresso e teclas mantidas, sem salto involuntário. E06 preserva também o grupo de naves durante a morte; ver LEIA-E06 e regressão R06.

## Convenções E05 implementadas

- D07: mínimo 150 **livres entre bordas** das crateras; sorteio 150..230. Uma rocha no intervalo planejado, com pelo menos 60 livres de cada lado. O gerador alterna cratera/rocha e mantém a posição relativa ao terreno, inclusive na emenda.
- D15: intervalos semiabertos dos retângulos completos. Cratera mata se houver sobreposição horizontal e Y do jipe=183. Rocha mata se houver sobreposição horizontal e `jipeY+10>183`. Pouso sobre obstáculo é testado antes de pontos; transparência não reduz colisão.
- +50 somente depois de aproximação, sobreposição no salto, saída completa pela direita e pouso sem colisão. Marcador único; obstáculo fatal e saltos interrompidos por morte não pontuam. Sair da tela sozinho não basta. Score satura em 65535.
- D14: exatamente uma vida por evento. Jipe ausente por pelo menos uma atualização; retorna a X=0 quando [0,20) estiver livre. Tempo e terreno seguem; nenhum obstáculo removido e nenhuma invulnerabilidade. Laterais mantidas voltam no tick seguinte; ↑ mantida exige soltura.
- `DesenharSpriteRecortado` escreve apenas a porção horizontal visível, preservando `DesenharSprite` original. Lista de oito entradas; dados 35.072 bytes, buffers de 320 e 200 preservados.

São escolhas técnicas, sem confirmação do professor. A janela de salto das rochas é estreita com o critério conservador; travessias dos sete tipos foram executadas, mas conforto/fluidez e teclado físico continuam pendentes. E08 usa tipos 3..6, `obstImpactos`, `SomarPontos` e `PASS_PONTO`, sem duplicação por tiro/salto. Reposição também espera por tiro inimigo na área inicial; tempo/teclas/progresso continuam preservados.

## Crateras

- Três tipos visualmente diferentes, todos 14×7.
- Geração aleatória pela margem direita e movimento junto com o cenário.
- Distância horizontal mínima 150 entre consecutivas; registrar convenção de bordas/origens.
- Jipe precisa saltar; colisão sem salto adequado custa uma vida.
- Cada cratera superada sem colisão concede 50 pontos uma única vez.

Manter identificação de obstáculo ativo e informação de pontuação/colisão já tratada. O simples fato de sair da tela não prova que o jogador a saltou. Registrar como se detecta travessia segura e impedir pontos por um obstáculo que matou o jipe.

## Rochas

- Quatro tipos, 12×10 cada, aleatórios entre duas crateras consecutivas.
- Acompanham terreno sem mudar sua posição relativa.
- Podem ser saltadas; +50 quando o jipe passa sem colisão.
- Com tiros: tipo 1 indestrutível, tipos 2/3 um impacto, tipo 4 dois impactos consecutivos. Tipo 4 permanece após o primeiro; tipos 2/3 desaparecem imediatamente no primeiro.
- Destruir por tiro também concede +50. Não pontuar novamente uma rocha já destruída ou já contabilizada por salto.

Não colocar rochas sobre crateras. Definir intervalo disponível e uma estratégia simples de geração entre elas. Quantidade e distância entre rochas não foram fixadas; escolher parâmetros jogáveis sem violar a localização exigida. No mínimo sem tiros, todos os tipos continuam presentes e são superados por salto.

## Colisões e vidas

Planejar colisões com áreas e limites claros. A cratera é um buraco na pista: não basta copiar um teste de dois retângulos sólidos se isso deixar de detectar o jipe apoiado sobre o vazio. Documentar contato horizontal, apoio no chão e altura necessária para escapar.

Um evento de colisão deve retirar exatamente uma vida, fazer o jipe desaparecer e, se restarem vidas, recriá-lo em x=0. Sem vidas, ir para Game Over. Evitar que vários testes no mesmo frame retirem várias vidas pelo mesmo evento. Não reiniciar toda a fase ou o relógio a cada morte, pois o enunciado manda a partida continuar.

## Aceitação

- Medir limites laterais e velocidade relativa às naves.
- Conferir subida, altura máxima, topo e descida, inclusive com teclas repetidas.
- Conferir os três tipos de crateras, quatro de rochas, dimensões e espaçamentos.
- Verificar colisões antes/durante/depois do salto e no pouso.
- Passar por cada obstáculo e observar +50 uma vez; após morte, não receber pontos indevidos.
- Verificar perda de uma vida, desaparecimento, reposição x=0 e Game Over na última vida.
- Observar vários ciclos de geração sem sobreposição indevida nem dessincronização com o terreno.

Explicar estados do salto, sistema de coordenadas, geração, detecção de travessia e controle de evento único. Entregar a E07 a rotina de perda de vida e a E08 os dados de rochas, posições dos canhões e atualização de score.
