# E01 — Ambiente e base técnica

Ler 01, 03, 05. Requisitos R01, R02 e R26. **Base implementada em `../MOON.ASM`; validação registrada em [andamento](14-andamento.md).** Passos e explicação em [LEIA-E01](../LEIA-E01.md).

## Preparação

- Identificar a versão e o modo de uso do GUI Turbo Assembler no Windows.
- Registrar como montar, executar e encerrar, os arquivos esperados e as mensagens de erro relevantes.
- Verificar instruções e modos de endereçamento compatíveis com 8086; não introduzir registradores de 32 bits ou instruções de processadores posteriores.
- Escolher a organização mínima do fonte. Começar com poucos arquivos é uma sugestão; não impor arquitetura grande a um trabalho didático.

## Escopo da base

1. Entrada/saída do programa e troca para modo 13h, restaurando o ambiente ao sair.
2. Constantes de tela, cores, limites e temporização centralizadas.
3. Rotina simples de desenho de bitmap reutilizável, com destino, largura, altura e origem claramente documentados.
4. Escrita/ocultação por memória de vídeo, cuidando para não ultrapassar os 64.000 bytes visíveis.
5. Leitura não bloqueante de teclado para a animação continuar sem teclas.
6. Base temporal separando atualização dos movimentos de atualização do relógio em segundos.
7. Estados claros para menu, apresentação do setor, partida e fim. Este fluxo é uma proposta organizacional compatível com o enunciado.

Apagar um sprite pintando sempre de preto destrói o terreno atrás dele. Escolher restauração do fundo ou redesenho da área/cena e validar visualmente. Usar a solução mais simples que preserve fundo e desempenho. Não adotar automaticamente um buffer de tela inteiro: ele consome 64.000 bytes e exige planejamento da memória junto aos demais dados.

## Dicas do professor que devem ser preservadas

- Texto colorido: INT 10h, AH=13h. AL bit 0 controla atualização de cursor e bit 1 indica caracteres com atributos; BL fornece atributo se bit 1=0; BH página; DH/DL linha/coluna; CX número de caracteres; ES:BP aponta para texto. Reconhece CR, LF e backspace. Coordenadas de texto não devem ser confundidas com pixels.
- Espera: INT 15h, AH=86h, intervalo em microssegundos em CX:DX. Exemplo fornecido: 2 segundos = 1E8480h, CX=001Eh e DX=8480h. É dica, não obrigação de pausar o jogo por dois segundos. Verificar suporte no ambiente alvo e não supor que espera sozinha mede o tempo real com precisão.
- Teclado: INT 16h, AH=01h consulta buffer; ZF indica vazio. Somente quando houver tecla usar AH=00h para consumi-la, evitando bloquear a animação.
- Tamanhos de dados: o professor sugere cálculo em montagem por diferença entre `$` e o rótulo inicial.
- Escrita sequencial: MOVSB, STOSB e REP aparecem como sugestões. Documentar segmentos e registradores envolvidos se utilizados.

Preservar/restaurar corretamente os registradores e segmentos que cada rotina promete manter; texto via ES:BP e vídeo em A000h não devem interferir um no outro.

## Aceitação e explicação

- Montar e executar no ambiente exigido; registrar comandos ou passos efetivos.
- Conferir pixels nos limites e o exemplo (100,10) → 0CE4h.
- Confirmar que desenho/ocultação gráficos não usam BIOS por pixel.
- Confirmar que a animação avança sem entrada e que o relógio não conta teclas/frames como segundos.
- Explicar segmento, deslocamento, um byte por pixel, chamada de rotina e contrato de registradores.

Entregar ao próximo chat a base funcionando, passos de execução, constantes existentes e interfaces das rotinas. Se não houver acesso ao emulador, registrar validação pendente em vez de declarar E01 validada.
