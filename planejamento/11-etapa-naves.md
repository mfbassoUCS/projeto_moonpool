# E06 — Naves e grupos aleatórios

Ler 03 e D06/D07/D09. Requisitos R08–R10. Os tiros são tratados em 12, não são necessários para validar esta etapa do mínimo.

**Implementada em 29/10/2026.** Guia e explicação em [LEIA-E06](../LEIA-E06.md); execução/inspeção em [evidências](../evidencias/e06/verificacao.txt). As escolhas técnicas abaixo não são confirmações do professor. Teste físico/IDE, aparência/fluidez e 90 s externos continuam pendentes. E07 foi integrada; tiros E08 agora implementados, ver LEIA-E08.

## Regras

- Três tipos de naves, sprites 14×14.
- Cada grupo contém de 1 a 3 naves; quantidade e tipo escolhidos aleatoriamente.
- Todas as naves de um grupo têm o mesmo tipo. Grupos consecutivos podem repetir tipo.
- Surgem pela direita, com posições horizontal e vertical aleatórias. D06 implementada como formação de até meia tela (160 px), inicialmente em [320,480); primeira origem 320..335 e entrada gradual com recorte. A referência original à metade permanece uma interpretação técnica sujeita a orientação do professor.
- Permanecem inteiramente no espaço lunar, fora do status e relevo, entre linhas 15 e aproximadamente 100.
- Sem sobreposição e com distância horizontal mínima de 30 pixels entre consecutivas.
- Movimento contínuo da direita para a esquerda, trajetória fixa; não perseguem o jipe.
- Um novo grupo só aparece depois que todas as anteriores saíram pela esquerda ou foram destruídas.
- Nave destruída deixa imediatamente de participar de desenho, movimento, colisão e contagem de grupo ativo.

D07 implementada como 30 pixels **livres entre bordas** (origens >=44). D09 usa céu [15,100), origens Y=15..86. Velocidade igual de 1 px/2 ticks conserva os intervalos e Y é fixo. Retirar quando X+14≤0; novo grupo no passo seguinte se a lista estiver vazia. Saída não dá pontos.

## Organização implementada

Três vetores de palavras X/Y/atividade, tipo único compartilhado e quantidade originalmente sorteada. A atividade é contada por `ContarNavesAtivas`, incluindo naves fora da borda direita. O LCG/byte alto da E05 é compartilhado, sem nova semente por grupo e com limites até 256. Reservar larguras/gaps antes de distribuir sobra garante posições válidas, sem rejeição ou laço ilimitado.

`DesenharNaves` recompõe o céu preto 15..99 e desenha somente ativas com `DesenharSpriteRecortado`, sem restaurar fundo antigo. `navesMudou` provoca desenho mesmo sem movimento do terreno/jipe; remoção também marca essa flag. Cenário/obstáculos/captura do jipe continuam independentes. E08 inclui projéteis depois de limpar céu/terreno, inclusive quando apenas tiros mudam.

## Aceitação

- Observar grupos de 1, 2 e 3, com cada um dos três tipos ao longo de várias gerações.
- Confirmar homogeneidade dentro de cada grupo; não exigir alternância de tipos.
- Conferir sorteio das posições, limite do sprite completo, não sobreposição e 30 pixels mínimos.
- Confirmar movimento à esquerda e retirada correta no limite.
- Com duas naves já removidas e uma ativa, não gerar outro grupo.
- No completo, destruir a última nave deve permitir nova geração; misturar saída e destruição também deve funcionar.

Não apresentar uma sequência fixa como geração aleatória. Se uma semente fixa for usada para depuração, distingui-la da configuração final.

Explicar a diferença entre capacidade máxima, quantidade sorteada e quantidade ainda ativa. Registrar como E08 poderá remover uma nave e somar pontos sem duplicação.

Interface pronta: `RemoverNave(DI=0/2/4)` preserva registradores e devolve CF=1 somente quando remove uma ativa; CF=0 para inativa/índice inválido. Não soma pontos. E08 consome CF imediatamente e usa `SomarPontos(AX=100)` por impacto. Sua lista é independente: remover uma nave ou gerar outro grupo não apaga os projéteis existentes.

Aceitação automática executada: 4.096 sementes, todos os pares quantidade/tipo e extremos; 48 grupos naturais no teste misto, bloqueio de geração até a última saída, 394 obstáculos com variedade preservada; 390 quadros completos e guardas; regressão E03–E05 e laço real com persistência/reset das naves. Remoção futura testada por chamada direta, incluindo repetição, índice inválido e última nave; não equivale a teste de tiros. Roteiro físico e reprodução em LEIA-E06.
