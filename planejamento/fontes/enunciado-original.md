1. Introdução
O presente trabalho tem como objetivo desenvolver um programa em Assembly 8086 inspirado no jogo Moon Patrol, conforme as especificações apresentadas neste documento.

O desenvolvimento deverá ser realizado em grupos de até dois integrantes. As duplas devem se inscrever previamente em um dos 15 grupos disponíveis na tarefa abaixo. Para participar desta atividade, você precisa se inscrever em um grupo.

A apresentação do projeto ocorrerá no último dia de aula do semestre e deverá ser realizada exclusivamente por meio do emulador GUI Turbo Assembler (Windows). Recomenda-se que o programa seja testado frequentemente nesse ambiente. Após a apresentação, as equipes estarão autorizadas a submeter a versão final do trabalho. Submissões sem apresentação não serão avaliadas!

2. Moon Patrol
Moon Patrol é um clássico jogo de arcade de tiro com veículo e rolagem horizontal, desenvolvido pela Irem Software Engineering, Inc. e lançado em 1982.

No jogo, o jogador controla um jipe lunar (apelidado "Moon Patrol") que avança automaticamente pela superfície da Lua, enfrentando obstáculos, inimigos terrestres e ataques aéreos. O veículo dispõe de dois tipos de ataque: tiros para a frente e minas de solo para destruir obstáculos no terreno. Um desafio adicional é a necessidade de pular sobre crateras e obstáculos. Para isto, o jipe pode saltar em diferentes alturas, evitando barreiras e projéteis inimigos.

O jogo é composto por cinco fases distintas, cada uma representando uma região diferente da Lua, com obstáculos e inimigos progressivamente mais desafiadores. A cada fase completada, o objetivo é avançar uma determinada distância enquanto neutraliza todas as ameaças. Uma vez atingida a meta, aparece uma mensagem de vitória e o jogo passa para o próximo estágio com dificuldade aumentada.

Moon Patrol foi um dos primeiros jogos a combinar a mecânica de rolagem horizontal com a possibilidade de movimento vertical (saltos), criando uma dimensão adicional de jogabilidade. Sua influência pode ser vista em muitos jogos de ação posteriores, consolidando-se como um dos pilares do design de arcade clássico.

Uma amostra do jogo pode ser encontrada no 
Moon Patrol On-line
.

3. Requisitos do Jogo
Para atender aos objetivos da disciplina e ao tempo disponível para a tarefa, o jogo passou por algumas adaptações em seu funcionamento. Assim, o jogo a ser implementado será uma versão simplificada do Moon Patrol original. As principais adaptações são as seguintes:

As naves inimigas terão uma trajetória fixa;
A região lunar destinada à movimentação do jipe é plana;
O jogo terá uma única fase.
Esta seção descreve os requisitos para o desenvolvimento do jogo.

3.1 Configuração do Vídeo
O programa deve utilizar o modo de vídeo 320 × 200 (código do modo de vídeo = 13h). Nesse modo, a tela é composta por 320 colunas e 200 linhas, conforme ilustrado na Figura 1. Cada pixel ocupa 1 byte na memória de vídeo, o que permite representar 256 cores distintas (2⁸ = 256 combinações possíveis). Assim, a memória total utilizada pelo vídeo é de 320 × 200 = 64.000 bytes.

Figura 1. Estrutura do modo de vídeo 320 x 200
Figura 1. Estrutura do modo de vídeo 320 x 200
O modo 13h utiliza mapeamento de E/S em memória, o que significa que uma região da memória principal é destinada exclusivamente ao vídeo. Esse espaço de memória inicia no segmento A000h, onde cada posição representa um pixel na tela. Para desenhar um pixel, basta escrever o valor da cor correspondente, conforme a Tabela 1, no endereço de memória que representa sua posição (coordenadas x, y).  A posição de memória é calculada pela fórmula:

¸
Fórmula: endere c com ¸ em cima o, igual a, A 000 h, dois pontos,, abre parênteses, x, mais, y, vezes, 320, fecha parênteses.

Por exemplo, para exibir um pixel na posição (100, 10) — ou seja, coluna 100 e linha 10 (ambas iniciando em 0) — o deslocamento é:

Fórmula: 100, mais, 10, vezes, 320, igual a, 0 C E 4 h.

Logo, o endereço completo será A000h:0CE4h.

Tabela 1 - Código de cores
Tabela 1 - Código das cores.
Embora seja possível utilizar a interrupção 10h (serviços de vídeo BIOS) para desenhar pixels, o método de endereçamento direto na memória de vídeo é consideravelmente mais eficiente. Isso ocorre porque o uso de interrupções envolve uma espera pelo processamento da CPU — uma espécie de “fila de atendimento” do sistema. Já o acesso direto à memória permite escrita imediata, sem dependência da BIOS. Além disso, podem ser utilizadas instruções de manipulação de strings (como MOVSB, STOSB ou REP) para acelerar a escrita de múltiplos pixels. Dessa forma, recomenda-se utilizar endereçamento indireto ou instruções de manipulação de strings para a escrita de pixels. O uso de interrupções deve ser reservado apenas para a escrita de texto ou operações não gráficas.

3.2 Tela Inicial
A tela inicial deve conter três elementos principais, conforme ilustrado na Figura 2:

Nome do jogo: o nome “Moon Patrol” deve ser exibido na parte superior da tela, utilizando arte em ASCII gerada pelo site patorjk.com/software/taag. O texto deve ser impresso na cor verde-claro (0Ah), garantindo boa legibilidade e destaque visual.
Elementos do Jogo: entre o título e o menu, deve ocorrer uma animação cíclica dos elementos principais do jogo: jipe e os 3 tipos de naves alienígenas:. Elas devem mover-se da  esquerda para a direita, desaparecendo ao atingir o limite direito da tela e reaparecendo novamente à esquerda.
Menu de opções:  O menu deve conter duas opções: “Jogar” e “Sair”, cada uma delimitada por uma caixa formada pelos seguintes caracteres ASCII:

218 ("┌")  191 ("┐")  
192 ("└")  217 ("┘")  
196 ("─")  179 ("│")

O usuário poderá navegar entre as opções utilizando as setas para cima e para baixo. A opção selecionada deve ser destacada em vermelho-claro (0Ch).As demais opções permanecem na cor branca (0F). Ao pressionar a tecla Enter, a ação correspondente à opção destacada será executada.

Descrição da imagem não disponível
Figura 2 - Exemplo de Tela Inicial.
3.4 Tela do Jogo
A tela do jogo é composta por três áreas principais: o status do jogo na parte superior, o espaço do planeta no centro e a superfície da lua na parte inferior. Cada um desses elementos será detalhado nas seções a seguir.

3.4.1. Status do Jogo
O status do jogo é composto pelo ícone de corações representando as vidas, o score e o tempo decorrido, como ilustrado na Figura 4. Ele deve ser exibido no topo da tela, com o score alinhado à esquerda, corações representando a quantidade de vidas no centro e o tempo restante alinhado à direita. O tempo deve ser atualizado em intervalos de um segundo.

Descrição da imagem não disponível
Figura 4 - Status do Jogo
A dimensão dos corações deve ter 11 pixels de altura e 18 pixels de largura. O bitmap da imagem é mostrado na Figura 5.

Descrição da imagem não disponível
Figura 5 - Bitmap dos números de vida (3, 2 e 1 vida, respectivamente).
O relógio deve ter 8 pixels de altura e 7 pixels de largura. O bitmap da imagem é mostrado na Figura 6.



Descrição da imagem não disponível
Figura 6 - Bitmap do relógio
3.4.2 Espaço  Lunar
O espaço lunar corresponde à região da tela destinada à movimentação das naves alienígenas. Essa área está delimitada verticalmente pela barra de status, localizada a partir da linha 15, e pelo topo da maior montanha da superfície lunar, aproximadamente na linha 100. Assim, as naves alienígenas deverão permanecer dentro do intervalo vertical compreendido entre as linhas 15 e 100, não podendo invadir a barra de status nem a superfície do planeta.

Cada nave alienígena deverá possuir 14 pixels de largura por 14 pixels de altura. A Figura 7 apresenta os bitmaps correspondentes aos três tipos de naves alienígenas que deverão ser implementados.

Descrição da imagem não disponível
Figura 7 - Bitmap das naves alienígenas
As naves deverão se deslocar continuamente da direita para a esquerda da tela. Deverá ser gerada uma quantidade aleatória de 1 a 3 naves de um tipo de nave alienígena, que surgirão a partir da lateral direita da tela. Estas naves, que formam um grupo, deverão ser posicionadas aleatoriamente em sua posição vertical e horizontal (não pode ultrapassar a metade horizontal da tela), respeitando os limites do espaço lunar e sem sobreposição entre si. A distância horizontal entre duas naves consecutivas deverá ser de, no mínimo, 30 pixels.

Os três tipos de naves deverão ser utilizados de forma aleatória, gerando grupos do mesmo tipo de nave. A geração dos grupos deverá ocorrer de forma contínua durante o jogo. Entretanto, um novo grupo somente poderá ser gerado após todas as naves do grupo anterior terem deixado a área de jogo, seja por terem sido destruídas pelo jogador ou por terem atingido o limite esquerdo da tela.

As naves alienígenas deverão realizar disparos verticais em direção à superfície lunar. Cada disparo deverá possuir 2 pixels de largura por 4 pixels de altura e deverá ser representado na cor branca. A velocidade de deslocamento dos disparos deverá ser definida de forma que seja compatível com a dinâmica de movimentação do jipe, permitindo que o jogador possa reagir e evitar os disparos. O limite do tiro é a superfície ou o jipe.

A colisão entre um disparo alienígena e o jipe deverá ser determinada pela sobreposição do disparo com a área ocupada pelo jipe. Considera-se que ocorreu uma colisão quando a extremidade inferior do disparo atingir ou sobrepor o retângulo correspondente ao jipe.

Quando ocorrer uma colisão, o jipe deverá ser destruído, uma vida deverá ser subtraída e um novo jipe deverá ser criado na coluna 0 (margem esquerda da tela), reiniciando sua participação na fase. O jogo deverá continuar normalmente enquanto houver vidas disponíveis.

O jipe poderá realizar disparos contra as naves alienígenas. O disparo deverá ser representado na cor amarela e deverá ser lançado a partir do canhão localizado na parte superior do jipe.

Após o disparo, o projétil deverá se deslocar verticalmente para cima, em direção ao espaço lunar, até que ocorra uma das seguintes situações:

o disparo atingir uma nave alienígena; ou
o disparo atingir o limite superior da área de jogo, correspondente à linha 15.
Quando o disparo atingir uma nave alienígena, deverá ocorrer uma colisão entre os dois objetos. Nesse caso, a nave alienígena e o disparo deverão ser removidos da área de jogo. A nave destruída deverá deixar de ser considerada um objeto ativo para fins de movimentação, colisão e controle do grupo de naves. O jogador recebe 100 pontos a cada nave alienígena destruída. 

Caso o disparo atinja a linha 15, deverá ser removido da área de jogo e não deverá produzir qualquer outro efeito.

Os disparos deverão ser controlados de forma independente, permitindo que o jogo mantenha os projéteis ativos até que atinjam uma nave ou o limite superior da tela.

3.4.2 Superfície Lunar
A superfície lunar será composta por uma região montanhosa e uma região plana destinada à movimentação do jipe. A região plana deverá conter, de forma aleatória, crateras e rochas, que funcionarão como obstáculos ao deslocamento do jogador.

A região montanhosa deverá possuir altura máxima de 95 pixels e deverá ser desenhada a partir da linha 100, estendendo-se verticalmente em direção à parte inferior da tela. A geometria das montanhas deverá variar ao longo do percurso, evitando uma superfície completamente uniforme.

Para transmitir a sensação de movimento do jipe, a superfície lunar deverá apresentar deslocamento contínuo da direita para a esquerda. À medida que o cenário se desloca, novos trechos da superfície deverão entrar pela lateral direita da tela, enquanto os trechos que ultrapassarem o limite esquerdo deverão ser removidos ou reutilizados.

A superfície deverá possuir uma largura mínima de 320 pixels. Quando o final do cenário for alcançado, a exibição deverá retornar ao início de forma contínua, sem apresentar descontinuidade visual, salto ou interrupção perceptível no terreno. Para isso, o início e o final do cenário deverão ser projetados de modo que possam ser conectados continuamente.

A altura da superfície montanhosa poderá variar ao longo do cenário, respeitando o limite máximo de 95 pixels. Essa variação deverá permitir a criação de diferentes configurações do terreno e contribuir para a dinâmica e a dificuldade da navegação do jipe.

A Figura 8 apresenta um exemplo da configuração da tela do jogo, incluindo a região montanhosa, a área plana de deslocamento do jipe e os obstáculos presentes na superfície lunar.

Descrição da imagem não disponível
Figura 8 - Exemplo de tela do jogo.
A Figura 9 apresenta exemplos dos elementos gráficos utilizados para representar as montanhas e os montes do jogo. As duas imagens são utilizadas de forma complementar e foram sobrepostas para compor o fundo da superfície lunar, formando a representação visual do relevo do planeta.

Descrição da imagem não disponível
Descrição da imagem não disponível
Figura 9 - Bitmaps das montanhas do jogo
Jipe

O jipe deverá ser posicionado sobre a região plana da superfície lunar destinada à sua movimentação horizontal. Essa região deverá ser representada na cor amarela, permitindo diferenciá-la visualmente das demais partes do cenário. Ela tem 7 pixels de altura e ocupar da margem esquerda a margem direita.

O jipe poderá se deslocar horizontalmente para a direita e para a esquerda, utilizando as respectivas teclas de seta. A velocidade de deslocamento do jipe deverá ser superior à velocidade de deslocamento das naves alienígenas, permitindo ao jogador realizar manobras para evitar obstáculos e inimigos. O deslocamento horizontal do jipe deverá ser limitado à metade da largura da tela. Dessa forma, o jipe não poderá ultrapassar o ponto correspondente à metade horizontal da área de jogo.

O jipe será equipado com dois canhões: um canhão localizado na parte superior e outro localizado na parte frontal. O funcionamento do canhão superior é descrito na seção referente às naves alienígenas. Ambos os canhões deverão ser acionados simultaneamente quando o jogador pressionar a barra de espaço. O disparo do canhão frontal deverá ser representado na cor vermelha, possuindo 2 pixels de altura e 4 pixels de comprimento. O disparo deverá deslocar-se horizontalmente em direção aos obstáculos e inimigos presentes à frente do jipe. O disparo terá um limite de 50 pixels.

Caso o disparo frontal atinja um obstáculo ou outro elemento que possa ser destruído, deverá produzir o efeito correspondente e, em seguida, ser removido da área de jogo. Caso o disparo não atinja nenhum obstáculo ou inimigo, deverá continuar seu deslocamento até a movimentação de 50 pixels, momento em que deverá ser removido.

O jipe deverá possuir 10 pixels de altura e 20 pixels de largura, conforme o bitmap apresentado na Figura 10. As dimensões especificadas deverão ser mantidas durante todo o jogo, inclusive durante os movimentos de deslocamento e salto.

Figura 10 - Bitmap djipe.
Figura 10 - Bitmap do jipe.
Crateras 

A região plana da superfície lunar poderá conter crateras, que funcionarão como obstáculos ao deslocamento do jipe. As crateras deverão ser geradas aleatoriamente a partir da margem direita da tela e deverão deslocar-se para a esquerda juntamente com a superfície lunar, mantendo sua posição relativa em relação ao terreno durante o deslocamento do cenário. Deverá existir uma distância horizontal mínima de 150 pixels entre crateras consecutivas, de modo a garantir que o jogador tenha espaço suficiente para realizar as manobras necessárias entre os obstáculos. Cada cratera deverá possuir 14 pixels de largura por 7 pixels de altura. A Figura 10 apresenta os três tipos de crateras que deverão ser utilizados no jogo.

O jipe deverá evitar as crateras realizando um salto, acionado pela tecla de seta para cima. Ao iniciar o salto, o jipe deverá atingir uma altura máxima de 15 pixels acima de sua posição normal.

A trajetória do salto deverá possuir formato trapezoidal, sendo composta por três etapas:

Subida: o jipe deverá deslocar-se verticalmente para cima a uma velocidade de 3 pixels por frame;
Permanência no ponto mais alto: após atingir a altura máxima de 15 pixels, o jipe deverá permanecer nessa posição durante 5 pixels de deslocamento horizontal;
Descida: o jipe deverá retornar à posição original, deslocando-se verticalmente para baixo a uma velocidade de 3 pixels por frame.
Durante o salto, o deslocamento horizontal do jipe deverá continuar normalmente, permitindo que o jogador atravesse a região da cratera enquanto permanece acima dela. Quando o jipe superar uma cratera sem ocorrer colisão, o jogador deverá receber 50 pontos. A pontuação deverá ser atribuída uma única vez para cada cratera superada. Caso o jipe colida com uma cratera sem realizar o salto adequadamente, deverá perder uma vida. Após a colisão, o comportamento do jipe deverá seguir as regras estabelecidas para a perda de vida e reposicionamento do jogador.

Os três tipos de crateras deverão apresentar diferenças visuais, podendo também possuir características distintas, desde que respeitadas as dimensões especificadas. Um exemplo de bitmaps de crateras é mostrado na Figura 11.

Descrição da imagem não disponível
Figura 11 - Exemplos de Bitmap de Crateras.
Rochas
Outro tipo de obstáculo presente na superfície lunar serão as rochas. As rochas deverão ser posicionadas aleatoriamente na região plana, entre duas crateras consecutivas, de modo que o jogador possa optar por saltá-las ou destruí-las com os disparos do jipe, conforme as características de cada tipo de rocha.

Deverão ser implementados quatro tipos de rochas, conforme ilustrado na Figura 12. As rochas poderão apresentar diferentes formatos, porém deverão respeitar as dimensões de 12 pixels de largura por 10 pixels de altura.

Cada tipo de rocha deverá possuir um comportamento específico em relação aos disparos do jipe:

Rocha 1: não pode ser destruída por disparos. Deve ser saltada pelo jipe.
Rocha 2: é destruída após ser atingida por 1 disparo.
Rocha 3: é  destruída após ser atingida por 1 disparo.
Rocha 4: é destruída somente após ser atingida por 2 disparos consecutivos.
A Rocha 1 deverá permanecer no cenário mesmo quando atingida por um disparo, não sendo afetada pelo tiro. As Rochas 2 e 3 deverão desaparecer imediatamente após serem atingidas por um disparo. A Rocha 4 deverá permanecer no cenário após o primeiro disparo, sendo destruída somente quando receber um segundo disparo consecutivo.

Caso o jogador opte por saltar sobre uma rocha, deverá evitar a colisão com sua área. Uma rocha será considerada superada quando o jipe passar por sua posição sem ocorrer colisão.

Sempre que uma rocha for destruída por disparo ou superada por meio de um salto, o jogador deverá receber 50 pontos.

As rochas deverão acompanhar o deslocamento horizontal da superfície lunar, mantendo sua posição relativa em relação ao terreno durante o movimento do cenário.

Descrição da imagem não disponível
Figura 12 - Exemplos de Bitmap de Rochas.

3.5 Tela de Fim de Jogo
A tela de fim de jogo deve apresentar a mensagem “GAME OVER”, centralizada em duas linhas, na cor vermelha, gerada por meio de arte em ASCII. Abaixo deve ser mostrado o score final. 

O programa deve voltar a tela inicial após pressionar qualquer tecla. 

4. Resumo
Esta seção descreve os principais elementos do trabalho:

Jipe

Movimentação: desloca-se para a esquerda e para a direita (limitado à metade esquerda da tela) e realiza saltos acionados pela seta para cima.

Mecânica de Salto: trajetória trapezoidal dividida em subida (3 px/frame até atingir 15 px de altura), permanência no topo (por 5 px de deslocamento horizontal) e descida (3 px/frame).

Ataque: barra de espaço dispara simultaneamente o canhão superior e o canhão frontal.

Colisão e Penalidade: colisões com tiros alienígenas, crateras não saltadas ou rochas resultam na destruição do jipe, perda de 1 vida e reposicionamento na coluna 0.

Naves Alienígenas

Aparecimento e Fluxo: surgem no lado direito em grupos de 1 a 3 naves do mesmo tipo (também selecionado aleatoriamente), posicionadas aleatoriamente entre as linhas 15 e 100 (respeitando a distância mínima de 30 px entre si). Por exemplo, o jogo pode gerar um grupo de 2 naves do tipo 2, depois 3 naves do tipo 1 e 1 nave do tipo 1. Um novo grupo só é gerado após todas as naves do grupo anterior saírem da tela ou serem destruídas.

Ataque: efetuam disparos verticais contínuos em direção à superfície lunar ou ao jipe.

Destruição: são eliminadas ao entrar em colisão com o disparo do canhão superior do jipe.

Pontuação: 100 pontos por nave destruída.

Crateras

Comportamento: deslocam-se junto com a superfície lunar da direita para a esquerda. Mantêm uma distância horizontal mínima de 150 px entre crateras consecutivas.

Superação: devem ser evitadas através do salto do jipe. Colidir com a cratera sem saltar resulta na perda de vida.

Pontuação: 50 pontos ao superar/saltar uma cratera sem colidir (concedidos uma única vez por cratera).

Rochas

Comportamento: obstáculos gerados na pista plana entre duas crateras. Deslocam-se com o cenário e variam a resistência conforme o tipo:

Rocha 1: indestrutível por tiros (deve ser saltada obrigatoriamente).

Rocha 2: destruída com 1 disparo frontal.

Rocha 3: destruída com 1 disparo frontal.

Rocha 4: destruída apenas após receber 2 disparos frontais consecutivos.

Pontuação: 50 pontos ao destruir a rocha por tiro OU ao superá-la através do salto.

Disparos (Projéteis)

Disparo Inimigo (Branco, 2x4 px): move-se para baixo até colidir com o jipe ou atingir a superfície lunar.

Disparo Superior do Jipe (Amarelo): move-se para cima até atingir uma nave alienígena ou alcançar a linha 15 (limite superior).

Disparo Frontal do Jipe (Vermelho, 4x2 px): move-se para a direita para destruir rochas, desaparecendo após percorrer 50 px ou colidir com um obstáculo.

5. Restrições do Trabalho
Impressão e Ocultação: devem ser realizadas exclusivamente por meio de endereçamento indireto ou instruções de manipulação de strings, garantindo eficiência e consistência na renderização dos elementos gráficos (naves, terreno e tiros).

Evitar Duplicação de Rotinas: o código deve ser estruturado para evitar redundâncias. Sempre que possível, deve-se implementar rotinas genéricas reutilizáveis. Por exemplo, uma única rotina de movimentação pode atender a diferentes elementos do jogo — como naves alienígenas e nave aliada — eliminando a necessidade de funções separadas para cada tipo.

Configuração de Tempo: os intervalos de movimentação dos elementos e a duração do jogo devem ser parametrizáveis, permitindo ajustes de desempenho e dificuldade sem necessidade de alterar o código principal.

Compatibilidade com o Ambiente de Montagem: o programa deve ser plenamente compatível com os montadores GUI Turbo Assembler, assegurando comportamento idêntico em ambas as plataformas.

6. Mínimo Entregável
Para garantir um padrão mínimo de implementação, cada trabalho deverá atender aos requisitos descritos a seguir. Todos os itens considerados obrigatórios deverão estar implementados e funcionar corretamente durante a execução do jogo.

Tela inicial: deverá apresentar todos os elementos previstos na especificação do trabalho, os quais deverão estar visíveis e funcionais.
Jogo:  após a tela de apresentação do setor, deverá ser iniciada a fase do jogo, contendo todos os elementos essenciais especificados:
A barra de status deverá apresentar todos os elementos definidos na especificação.
No espaço lunar, deverá funcionar a geração aleatória dos grupos de naves, conforme as regras estabelecidas. Elas devem se movimentar horizontalmente da direita para a esquerda e serem removidas ao atingirem o limite esquerdo da tela. Elas não são obrigadas a disparar tiros em direção à superfície lunar.
A superfície lunar deverá apresentar o deslocamento contínuo do cenário para a esquerda, com recomposição do terreno pela lateral direita, de modo a produzir a sensação de movimento contínuo. O jipe deverá realizar o salto por meio da tecla de seta para cima, desaparecer quando atingir uma cratera ou rocha (atualizar o número de vidas). Os disparos do jipe (frontal e superior) são opcionais. 
A pontuação deverá ser atualizada corretamente de acordo com as ações que rendem pontuação.
As crateras e rochas deverão ser geradas e posicionadas de acordo com as regras estabelecidas neste documento, respeitando suas características, dimensões e condições de interação com o jipe.
Fim de jogo: o sistema deverá monitorar a quantidade de vidas do jogador durante toda a partida. Quando o jogador perder todas as vidas ou o tempo terminar, o jogo deverá ser encerrado e deverá ser apresentada uma tela de Game Over, contendo o placar final da partida. Ao pressionar a tecla, deverá retornar para o menu principal.

Constantes: o programa deve ter constantes para todas as definições do trabalho: posição inicial, número de máximo de naves alienigenas a criar, entre outros. 

Código-fonte: o código-fonte deverá estar claramente documentado por meio de comentários explicativos, permitindo compreender a finalidade e o funcionamento das principais partes do programa. Cada rotina ou procedimento implementado deverá ser precedido por um cabeçalho contendo, no mínimo:
Função: breve descrição da finalidade e do comportamento da rotina;
Parâmetros de entrada: identificação dos parâmetros utilizados como entrada e sua finalidade;
Parâmetros de saída: identificação dos valores ou resultados produzidos pela rotina.
Todos os itens acima devem estar implementados e operacionais. Caso contrário, o projeto não poderá ser avaliado. Elementos não descritos ou definidos como opcionais, também serão considerados para pontuação complementar.

6 . Entrega 
O código-fonte do programa deve ser submetido somente após a apresentação do trabalho. Projetos não apresentados não serão avaliados nem considerados para pontuação.

7. Dicas 
Esta seção tem por objetivo passar algumas dicas que visam facilitar a implementação do trabalho. 

7.1. Escrita de Strings com Cor 
Para escrever uma string, pode-se utilizar a função 13H da interrupção 10H:

AH = 13h
AL = modo
      bit 0: 1- atualiza a posição do cursor após a escrita
      bit 1: 1- string contém caracteres e atributos
BL = atributo do caractere se o bit 1 em AL for 0
BH = número da página de vídeo
DH,DL = linha, coluna da posição de impressão
CX = tamanho, em caracteres, da string
ES:BP = endereço do início da string
Nota: esta interrupção reconhece os códigos CR, LF, e backspace.

7.2. Suspensão da Execução por um Determinado Intervalo de Tempo
A interrupção 15h oferece uma variedade de serviços, incluindo a função AH=86H, que permite suspender a execução do programa por um intervalo de tempo especificado. O intervalo é definido em microssegundos (1/1.000.000 de segundo) e é especificado pelos registradores CX e DX, onde CX contém os 16 bits mais significativos e DX contém os 16 bits menos significativos.

Para converter o intervalo de tempo desejado em microssegundos, é necessário configurar CX e DX de acordo. Por exemplo, para um intervalo de 2 segundos (2.000.000 microssegundos), CX deve ser configurado com o valor 1EH e DX com o valor 8480H, pois 1E8480H é a representação hexadecimal de 2.000.000.

7.3. Leitura de Teclado sem Aguardar
A interrupção 16h oferece várias funções relacionadas ao teclado. Para ler uma tecla sem que o programa precise esperar, você pode usar a interrupção 16h para verificar o status do teclado. Especificamente, o serviço AH=01H permite verificar se há teclas no buffer do teclado. Se o buffer estiver vazio, o Zero Flag (ZF) será setado.

Para ler uma tecla do buffer, você deve utilizar o serviço AH=00H da mesma interrupção. Este serviço não apenas retorna o código da tecla pressionada, mas também remove a tecla do buffer.

7.4. Definir constante com o tamanho da memória
No Assembly, o símbolo $ é uma referência ao deslocamento atual (ou posição atual) dentro de um segmento de código ou de dados. Ele é útil principalmente para cálculos que envolvem endereços e offsets durante o tempo de montagem. O valor de $ pode ser usado para calcular comprimentos ou distâncias entre diferentes partes do código ou dados, principalmente em tabelas, blocos de memória ou instruções que requerem referência a endereços relativos.

Imagine que você está criando um buffer de dados e quer armazenar o tamanho do buffer em outro local. Você pode usar $ para calcular o tamanho do buffer diretamente no momento da montagem:

buffer db "Exemplo de texto"
tamanho equ $ - buffer; 
Neste exemplo:

buffer é o rótulo que marca o início dos dados.
O valor de $ - buffer calcula o número de bytes entre o deslocamento atual (posição $) e o início de buffer. Assim, o valor de tamanho armazenará o tamanho de buffer de forma automática.
7.5. Geração de bitmaps a partir de imagens
Para auxiliar na criação dos bitmaps dos elementos gráficos do jogo, pode-se utilizar ferramentas disponíveis na Internet que convertem imagens em representações utilizando caracteres ASCII. Essas ferramentas podem facilitar a identificação da disposição dos pixels e servir como base para a construção dos bitmaps que serão utilizados no programa em Assembly 8086.

Após obter a representação ASCII da imagem, os caracteres podem ser associados às respectivas cores utilizadas no jogo. Dessa forma, cada caractere da representação poderá ser convertido para o código de cor correspondente, resultando em uma sequência de bytes que poderá ser armazenada na memória e posteriormente utilizada pela rotina de exibição do sprite.

Como ferramenta auxiliar para essa etapa, pode-se utilizar o site Ink Me ASCII, disponível em: https://inkmeascii.com/

A utilização de ferramentas externas é permitida exclusivamente como auxílio na criação dos elementos gráficos. A conversão da representação obtida para o formato de bitmap utilizado pelo programa, bem como seu armazenamento e manipulação em memória, deverá ser realizada pela equipe no desenvolvimento do projeto.

Submissão do TDE B