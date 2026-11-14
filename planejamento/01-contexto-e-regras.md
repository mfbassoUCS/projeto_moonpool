# Contexto e regras permanentes

## Objetivo

Trabalho acadêmico: programa em **Assembly 8086**, inspirado em Moon Patrol, com **uma única fase**, pista plana para o jipe e trajetórias fixas para as naves. A introdução histórica fala de cinco fases, minas e outros ataques; isso não adiciona requisitos à adaptação descrita nas seções de implementação.

O aluno quer dividir o desenvolvimento entre chats e entender todo o código para a apresentação. No pedido inicial, autorizou somente a criação da documentação de planejamento.

## Regra do aluno: simplicidade e compreensão

- Escolher a solução mais simples que cumpra integralmente o comportamento solicitado.
- Preferir rotinas pequenas, nomes claros, fluxo explícito, constantes nomeadas e estruturas de tamanho fixo quando suficientes.
- Explicar o motivo das escolhas, os registradores usados e o fluxo dos dados em linguagem acessível.
- Evitar truques de otimização, macros complexas, dependências, engines e abstrações que o aluno não consiga explicar.
- Não confundir simplicidade com copiar rotinas para cada sprite. O professor exige evitar duplicação e reutilizar o que for comum.
- Não remover requisitos obrigatórios para tornar o código menor. Se a opção simples não cumprir a regra, explicar o problema e escolher a alternativa mais simples que cumpra.
- Antes de avançar uma etapa, fornecer uma explicação curta de como ela funciona e como reproduzir os testes.

## Restrições do professor

1. Programa compatível com Assembly 8086 e GUI Turbo Assembler no Windows; a apresentação ocorre exclusivamente nesse ambiente. Testar nele frequentemente.
2. Vídeo 13h, 320 × 200 pixels, um byte por pixel, segmento A000h.
3. Impressão e ocultação de elementos gráficos exclusivamente por endereçamento indireto ou instruções de strings. Não desenhar sprites ou terreno com interrupção BIOS pixel a pixel.
4. Interrupções de vídeo podem ser usadas para texto e operações não gráficas, conforme a orientação do enunciado. Mudança de modo de vídeo não é desenho de pixels.
5. Evitar redundância; utilizar rotinas reutilizáveis quando adequado.
6. Intervalos de movimento e duração da partida parametrizáveis.
7. Constantes para todas as definições do trabalho, incluindo posições iniciais e quantidade máxima de naves.
8. Código comentado. Toda rotina/procedimento deve ter cabeçalho com **função, parâmetros de entrada e parâmetros de saída**, inclusive quando não houver parâmetros.
9. Ferramentas externas permitidas exclusivamente como auxílio à criação de elementos gráficos. A equipe deve fazer a conversão para o bitmap do programa, seu armazenamento e sua manipulação em memória.

Como recomendação de clareza, acrescentar aos cabeçalhos os registradores alterados/preservados e efeitos sobre memória. Isso complementa, mas não substitui, os três campos obrigatórios.

## Regras acadêmicas

- Grupo de até dois integrantes, inscrito previamente em um dos 15 grupos da tarefa.
- Apresentação no último dia de aula do semestre. A data concreta não foi fornecida.
- Submeter o código-fonte somente depois da apresentação.
- Sem apresentação, o projeto não será avaliado.
- Todos os itens mínimos devem estar operacionais para avaliação; extras podem render pontuação complementar.

## Disciplina entre chats

Consultar o estado real dos arquivos antes de alterar o projeto. Executar só a etapa pedida; registrar dependências e decisões. Não declarar compatibilidade ou teste em GUI Turbo Assembler se isso não foi observado. Toda hipótese deve continuar identificada como hipótese até confirmação. Não adicionar níveis, som, ranking, inimigos terrestres extras ou mecânicas do jogo original sem solicitação.
