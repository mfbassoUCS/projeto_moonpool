# E02 — Artes, menu e encerramento

Ler 03, 04 e pendências D04/D16/D17/D18. Requisitos R03–R07, R25 e R27.

**Estado em 25/10/2026:** menu/telas e 17 artes próprias implementados em MOON.ASM, conforme autorização do aluno para consultar o arcade sem copiar os desenhos. As figuras da disciplina permanecem ausentes, mas D18 não bloqueia essa solução autoral. Guia em LEIA-E02.md; evidências e limites em 14. Teste físico permanece pendente. Não iniciar E03 automaticamente.

**Atualização de 31/10:** este documento preserva os critérios da E02; o fonte atual integra E02–E06 e a apresentação mínima E07. Fonte histórico em testes/E02BASE.ASM; fluxo atual em LEIA-E07.md. Não restaurar o caminho demonstrativo 12345 ou os avisos de etapa ao revisar as telas.

## Artes

Preparados: jipe 20×10; três naves 14×14; indicador de vidas 18×11 nas variantes 3/2/1; relógio 7×8; três crateras 14×7; quatro rochas 12×10; montanhas 320×64 e montes 320×32. São criações próprias, não conversões exatas de figuras ausentes. As camadas de relevo são apenas dados estáticos nesta etapa.

Escolher um formato simples de bitmap e uma rotina comum. Conferir todas as linhas e a contagem de pixels. Documentar transparência sem confundi-la com pixels pretos visíveis. Não usar grade e fundo cinza da imagem como decoração do sprite.

## Menu inicial

1. Exibir **Moon Patrol** no alto, em ASCII gerado pelo TAAG e cor 0Ah.
2. Entre título e opções, animar jipe e os três tipos de naves da esquerda para a direita.
3. Ao sair pela direita, cada elemento reaparece à esquerda; animação cíclica contínua, inclusive enquanto se navega no menu.
4. Exibir Jogar e Sair em caixas com os bytes 218, 191, 192, 217, 196 e 179.
5. Setas cima/baixo alternam seleção; opção selecionada em 0Ch, outra em 0Fh.
6. Enter executa: Jogar inicia fluxo de partida; Sair encerra o programa.

Escolher e documentar a opção inicialmente selecionada; o texto não a fixa. Conferir tamanho da fonte ASCII na resolução real e não copiar “Arcade” do exemplo.

## Apresentação do setor

O mínimo menciona uma tela antes da fase, mas não define conteúdo, duração ou tecla. Na E07, D04 adota tecnicamente SETOR 1, objetivo e instrução Enter/setas. Enter inicia a partida real, sem consumir tempo enquanto espera; não há avanço automático. O Enter já enfileirado é descartado ao mudar de tela. Essa escolha não foi confirmada pelo professor. O jogo continua com uma única fase; Game Over usa o score real e não mostra avisos de etapa/demonstração.

## Tela de Game Over

- Exibir GAME e OVER em duas linhas, centralizados, em arte ASCII vermelha.
- Mostrar o score final abaixo.
- Entrar nesse estado quando acabarem vidas ou tempo.
- Qualquer tecla retorna ao menu. Cuidar para uma tecla antiga no buffer não pular a tela imediatamente.
- Uma nova partida deve reinicializar estado; não carregar score, tiros, obstáculos ou tempo da anterior por acidente.

## Verificação

Comparar medidas e cores; navegar sem travar animação; observar repetição completa dos sprites; testar Jogar e Sair; simular encerramento com score conhecido; conferir retorno e nova partida. O ciclo real com colisões e tempo será validado novamente em E07.

Explicar como o bitmap vira pixels, como um texto ASCII é impresso e como uma variável de estado determina a tela ativa. Registrar artes utilizadas e interfaces das telas para E03/E07.
