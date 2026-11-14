# Contexto portátil — Moon Patrol

Data: 08/11/2026. Objetivo: ensinar ao aluno e ao colega o programa existente, em português simples, até conseguirem explicar cada rotina na apresentação. Preferência do aluno: código e explicações tão simples e compreensíveis quanto possível. Nesta tutoria, não reescrever nem acrescentar funcionalidades.

## Arquivos e versão

- Fonte oficial de desenvolvimento: `MOON.ASM`, na raiz do projeto Windows `C:\ucs\moon_patrol`.
- `MOON-PARA-LEITURA.txt` é uma cópia integral para anexar em chats, sem alteração de bytes.
- SHA256 desta cópia/fonte: `13176BC9F5EF6A9123945CAC44732BB933D8511214ECD100F7EA081703025E6D`.
- São 69 procedimentos em um único fonte, com dados gráficos embutidos. Não há módulos externos de jogo a carregar. Python, PNG e JSON auxiliam a produção/testes; não são dependências da execução do jogo.
- Montagem: TASM gera OBJ; TLINK gera EXE DOS de 16 bits. A apresentação deve ocorrer no GUI Turbo Assembler/Windows. O professor exige envio do fonte após apresentar; não foi fornecida exigência de enviar toda a pasta.
- O tutor só tem os arquivos anexados. Não presumir acesso a chats anteriores, ao repositório, aos links locais ou a execuções novas.

## O que o programa faz

Uma fase: menu com animação e Jogar/Sair → apresentação do setor → partida → Game Over → menu. Setas esquerda/direita movem o jipe; cima pede salto; Espaço aciona os dois canhões. A partida termina por vidas ou tempo. Configuração atual: três vidas e 90 segundos, escolhas do projeto.

VGA 13h: 320×200, um byte por pixel, segmento A000h, deslocamento `y*320+x`. Desenhos por memória; BIOS para texto/modo. Transparência de sprites: FFh, enquanto 00h continua preto opaco. Fonte usa `.8086`, `.model small`, `.stack 100h`.

Jipe 20×10, X=0..140 para permanecer inteiro na metade esquerda. Pista amarela em Y=193..199; jipe no chão começa em Y=183; no topo em Y=168. Cenário e obstáculos seguem à esquerda mesmo se o jogador parar ou alcançar o limite. Naves 14×14, origem Y=15..86, grupos homogêneos de uma a três, gerados novamente quando não resta nave ativa do grupo anterior.

Crateras 14×7, rochas 12×10. Obstáculo superado sem colisão vale +50, com confirmação de pouso seguro na implementação. Nave destruída vale +100. Rocha 1 é indestrutível; 2/3 recebem um impacto; 4 recebe dois. Tiros superior amarelo, frontal vermelho e inimigo branco. Projéteis permanecem independentes do emissor. O mínimo do professor dispensa disparos, mas o projeto os implementa e a dupla precisa compreendê-los.

## Arquitetura a acompanhar

- `inicio` inicializa segmentos/vídeo, entra no menu e repete leitura de entrada/atualização conforme `estado`; restaura ambiente na saída.
- `AtualizarPartida` coordena relógio, naves, cenário/obstáculos, salto/jipe/reposição, tiros, colisões/pontos, fim e desenho.
- `LerTeclado` usa BIOS nas telas. Na partida, `TecladoJogoIRQ` registra pressões/solturas; a lógica usa bits/pedidos. O tratador não desenha.
- Ticks BIOS controlam cadências; hora DOS em centésimos controla a duração. Não confundir passagem do tempo com quantidade de quadros desenhados.
- Listas de capacidade fixa armazenam objetos. Vetores `DW` usam deslocamentos 0,2,4… em bytes, não índices 0,1,2 como se fossem elementos.
- Rotinas de desenho reutilizam bitmaps e composição de linhas. Não há necessidade de decorar todas as cores.
- Colisões, remoção e marcadores evitam pontuar várias vezes pelo mesmo objeto. Acompanhar flags de retorno e variáveis de atividade no corpo das rotinas.

## Diferenças de versão e pendências

Nesta leitura, `PASSO_JIPE=5`, `TICKS_JIPE=1`, `PASSO_CENARIO=1`, `TICKS_CENARIO=1`, `PASSO_NAVE=1`, `TICKS_NAVE=2`. Salto: subida/descida de 3, altura de 15. `ContarTopo` recebe avanço do terreno; com a configuração atual conta 1,2,3,4,5 e passa à descida. A interpretação do referencial horizontal continua sendo decisão do projeto, não confirmação do professor.

Relatórios antigos descrevem passo do terreno 2 a cada 2 ticks e topo amostrado em 2,4,6; não usar essa descrição para o fonte anexado. O roteiro e o mapa foram atualizados por inspeção nesta sessão. **Não houve nova execução de testes nesta organização de estudo**, e resultados antigos não aprovam automaticamente a versão atual.

O checklist manual não foi concluído. Há registros anteriores de testes desatualizados e dúvidas de interpretação (formação de naves, impactos consecutivos, fidelidade das artes, superfície que encerra tiros e expressão “ambas as plataformas”). As figuras originais do professor não estão incluídas neste pacote; o enunciado transcrito não substitui essas imagens. Não declarar conformidade total nem prometer que eventuais correções serão pequenas.

## Método de ensino

Seguir os 12 encontros do guia. Começar pelo comportamento visível e chegar às instruções. Explicar termos antes de usá-los. Analisar trechos pequenos; simular valores; fazer uma pergunta por vez e aguardar a resposta. Separar sempre regra do professor, escolha da implementação e pendência. Quando o aluno errar, explicar o raciocínio e propor outro exemplo. Ao final, registrar o que ele conseguiu explicar sozinho, dúvidas, versão e próximo trecho.
