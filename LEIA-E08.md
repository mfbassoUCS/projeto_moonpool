# E08 — disparos completos

**Registro da implementação de 01/11/2026.** A revisão atual e a retomada estão em [LEIA-E09](LEIA-E09.md). O comportamento abaixo foi preservado; botões/execuções novas e pendências atualizadas estão na E09. Para reexecutar os harnesses sobre MOON atual sem sobrescrever relatórios históricos, use os comandos da E09.

O fonte atual acrescenta os dois canhões do jipe, tiros das naves e resistência das rochas ao mínimo da E07. Não acrescenta fases, inimigos, explosões ou outros efeitos. Abra `EXECUTAR-E08.cmd`, confira `MONTAGEM.LOG`/`LINK.LOG` e digite `MOON`. Na GUI Turbo Assembler, recarregue `MOON.ASM` e use Turbo 16-bit. O setor informa também o controle por Espaço.

A versão E07 anterior está preservada byte a byte em `testes/E07BASE.ASM`, hash `FCA3099062C1F4BF34EB1EAADE7E98991587453E6D5A77B83A7025DBCBE10901`. O hash encontrado antes de editar coincidia com os relatórios E07/R07 aprovados. A inspeção não identificou defeito impeditivo do mínimo. Em 01/11, o aluno informou que ainda não fez seus testes manuais: essas pendências continuam abertas.

## Regras e decisões

O professor exige os dois canhões simultâneos, superior amarelo, frontal vermelho 4×2 e alcance percorrido de 50 pixels; inimigo branco 2×4; +100 por nave; resistências 1/2/3/4 e +50 por rocha superada **ou** destruída. As medidas, velocidades e capacidades ausentes foram escolhidas tecnicamente nesta etapa, sob a autorização para executar E08; não são respostas do professor.

| D13: parâmetro | Escolha técnica |
|---|---|
| Capacidade | 8 superiores, 8 frontais, 12 inimigos |
| Superior | 2×4, amarelo 0Eh; origem `(jipeX+6, jipeY−4)` |
| Frontal | 4×2, vermelho 04h; origem `(jipeX+20, jipeY+4)` |
| Inimigo | 2×4, branco 0Fh; origem `(naveX+6, naveY+14)` |
| Movimento | Uma atualização por tick BIOS; superior/frontal 4 px, inimigo 2 px |
| Cadência do jipe | 6 atualizações entre pares; Espaço mantido repete |
| Cadência das naves | 18 atualizações por nave com canhão visível; cerca de 1 s na cadência nominal |
| Lotação | Preservar todos os ativos. Jipe cria o par inteiro somente com vaga nas duas faixas; mantida tenta novamente. Nave aguarda vaga |
| Superfície | Pista em Y=193; montanhas são o fundo do cenário e não bloqueiam tiros |

As velocidades nominais são aproximadamente 73/73/36 px/s, contra 55 px/s do jipe. O tempo real entre quadros também depende do custo do desenho e do emulador; a chance de esquiva e o conforto ainda precisam de avaliação física. Não houve alteração das constantes antigas de movimento ou do relógio.

**D11:** dois impactos na mesma rocha 4, sem prazo de validade. Errar um tiro, acertar outro alvo ou perder uma vida não apaga o primeiro impacto. O contador zera ao reutilizar a vaga para outro obstáculo. O enunciado não define um temporizador nem uma condição de reinício, portanto nenhum foi inventado.

## Como explicar os dados

`tiroAtivo`, `tiroX`, `tiroY` e `tiroDistancia` são quatro vetores de palavras, com 28 entradas cada. O mesmo índice identifica um projétil nas quatro tabelas. Como cada palavra ocupa dois bytes, os índices usados no Assembly são pares: 0, 2, 4 etc. As primeiras oito entradas são superiores, as oito seguintes são frontais e as doze restantes são inimigas. Essa divisão evita que um tipo ocupe a reserva dos outros.

Depois do nascimento, a posição não depende mais do jipe nem da nave que atirou. Por isso mover o jipe não muda o alcance do frontal, destruir a nave não apaga seu tiro e a morte do jipe não limpa seus projéteis. Somente a **nova partida** chama `ReiniciarDisparos` e limpa tudo.

`obstImpactos` acrescenta uma palavra a cada vaga terrestre. `obstPassagem` continua sendo o controle de pontuação do salto: `PASS_PONTO` impede outro +50 ao destruir uma rocha já contabilizada. Destruir uma candidata antes do pouso libera sua vaga e impede que ela volte a pontuar por salto. `SomarPontos` continua saturando em 65535.

## Fluxo e rotinas

1. `RegistrarScanJipe` registra pressionamento e soltura de Espaço, além das setas existentes. Um toque curto gera `pedidoTiro`; manter a tecla permite repetição pela cadência. Repetições do teclado não aceleram os disparos. Pressão durante ausência não guarda um pedido; a tecla mantida pode voltar a disparar depois da reposição. Um toque durante o intervalo de recarga é descartado, sem fila de tiros.
2. `AtualizarPartida` consulta o relógio e usa a mesma amostra BIOS para naves, terreno, jipe e tiros. Depois do movimento dos alvos, chama `AtualizarCadenciaDisparos` e `ConferirDisparos`; então aplica as colisões/travessias terrestres. Tiro inimigo fatal cancela candidatas de salto antes de atribuir seus pontos. Uma rocha destruída nessa atualização deixa de colidir com o jipe.
3. `DispararJipe` usa `ProcurarVagaTiro` nas duas faixas **antes** de gravar qualquer uma. Se uma estiver cheia, nenhuma nasce. `DispararNaves` possui espera por nave, só emite com o canhão dentro de X=0..318 e coloca cada tiro na lista independente.
4. `MoverDisparos` percorre um pixel por vez até completar o passo configurado. Em cada pixel, `ConferirUmDisparo` verifica alvo e limite. Isso impede atravessar alvos e faz o frontal parar exatamente em distância 50, inclusive no último passo parcial. Um impacto no ponto final tem prioridade sobre a remoção sem efeito.
5. `SobrepoeTiroAlvo` reutiliza a comparação de retângulos completos, com X signed e intervalos semiabertos. Para o inimigo, o contato de sua extremidade geométrica `Y+4` com o topo do jipe também conta; bordas laterais apenas encostadas são seguras. A pista encerra o tiro quando `Y+4>=193`.
6. Superior contra nave chama `RemoverNave` e testa **CF imediatamente**. Só CF=1 autoriza `SomarPontos(100)`. Rocha 1 consome o tiro e fica; 2/3 saem no primeiro impacto; 4 no segundo. Crateras não são alvos do frontal. Cada projétil é consumido pelo primeiro impacto.
7. Inimigo contra jipe usa `PerderVida`. O estado inativo evita várias vidas no mesmo evento. `TiroNaReposicao` complementa a área livre de D14: não recriar em X=0 dentro de um branco ainda ativo. Não há invulnerabilidade nem limpeza de inimigos. Tempo, score, terreno, naves e teclas mantidas continuam.

CF é a flag de carry, usada aqui como resultado verdadeiro/falso. `SI` identifica um tiro; `DI` identifica uma nave/obstáculo ou uma vaga livre. `TipoDoTiro` devolve em `BX` o índice das medidas e do bitmap. As rotinas indicam seus registradores e efeitos nos cabeçalhos. O jogo continua em `.8086`, modelo small, pilha 100h e fonte único ASCII.

## Desenho e apagamento

`tirosMudou` marca nascimento, movimento e remoção. Ao mudar um tiro, `DesenharQuadroPartida` recompõe o céu e o terreno atuais. Ao mudar apenas nave, recompõe o céu; ao rolar, recompõe o terreno. Depois desenha obstáculos, projéteis e captura/desenha o jipe, nessa ordem. Assim a limpeza do céu não apaga um tiro ativo, e o buffer do jipe não restaura pixels de um tiro antigo.

`DesenharDisparos` compartilha os bitmaps retangulares e `DesenharSpriteRecortado`. Esta primitiva só recorta horizontalmente. As origens e o avanço por pixel garantem Y válido: superior termina em 15; inimigo termina antes de desenhar sobre a pista; frontal mantém a altura inicial. O HUD fica intacto. Os buffers existentes de 320 bytes para a linha e 200 para o fundo do jipe permanecem; não foi criado um buffer de tela.

## Reprodução e alcance dos testes

Na raiz, sem outras instâncias dos testes:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File testes\executar-e08.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File testes\executar-teclado-e08.ps1
python testes\conferir-e08.py
```

TASM 4.1/TLINK 7.1.30.1 e DOSBox 0.74-3 são os incluídos no GUI Turbo Assembler 5.1. RAM usa cycles=50000; fluxo usa auto. Os auxiliares Python/Pillow e PowerShell não fazem parte do EXE. A execução dos botões da IDE não é inferida dessa montagem por comandos.

- `E08LOG`: 426 verificações T17–T20, no chão e em todas as alturas do salto, pares/vagas/cadência/alcance, bordas, remoção, pontos, resistências, morte, reposição, grupos e reset.
- `E08PIX`: 170 quadros e 11.050.000 bytes comparados com composição independente das grades autorais. Inclui HUD/guardas, todas as vagas ocupadas, recorte, transição céu/terreno, mudança só de nave/tiro/jipe, remoção, rolagem e jipe ausente. PNGs são RAM reconstruída, não filmagem nem prova de fluidez.
- `E08AUTO`: relógios reais, telas/entrada BIOS, scans sintéticos, rocha/nave destruídas (+150), branco persistente após destruição da nave, morte/reposição, expiração controlada de 6 s, última vida, reset, IRQ e Sair. O encontro usa posições controladas e desloca o jipe para a trajetória do branco após destruir a nave. Não é uma partida humana de 90 s.
- `N08/R08`: reaplica os oráculos anteriores ao fonte atual, com nomes novos: cenário/relógio, salto/teclas, sete obstáculos/pontos/vidas, geração de naves, pixels e telas. **Somente R08AUTO desabilita a emissão inimiga**, para isolar o oráculo antigo que espera céu sem tiros. E08AUTO testa o fluxo com todos os disparos habilitados; MOON mantém a emissão normal.
- `E08KEY`: eventos Windows direcionados à janela oculta, SDL windib → DOSBox → IRQ1 real. Setas simultâneas/soltura/salto e Espaço durante salto, dois pares independentes, soltura e retorno BIOS. Não é teclado físico e usa backend de teste.

Os resultados efetivos, hash, memória e tempos medidos ficam em [evidencias/e08/verificacao.txt](evidencias/e08/verificacao.txt), com regressões separadas. O conferidor recusa fonte alterado depois da geração, logs incompletos ou pixels diferentes. As evidências E01–E07 permanecem históricas.

## O que ainda depende de você

1. Usar Assemble/Build/Run na IDE com o fonte atual. Ver menu, setor/Enter, instrução Espaço, Game Over, retorno e Sair.
2. Testar fisicamente setas e Espaço juntos: chão, subida, topo, descida, tecla mantida, soltura e nova pressão, inclusive depois de morrer.
3. Saltar crateras/rochas, destruir os quatro tipos possíveis e conferir pontos/vidas. A rocha 1 exige salto; a 4 exige dois impactos. Observar um tiro branco e tentar esquivar no chão e durante salto.
4. Avaliar conforto dos saltos e da cadência, reação aos brancos, fluidez, cintilação e rasgos. Comparar uma sessão normal de 90 s com cronômetro externo enquanto sobrevive.

Relate a sequência e o resultado; nenhuma dessas pendências foi declarada aprovada. Use a retomada E08 para registrar o teste e corrigir defeitos concretos. A E09 não foi iniciada; seu prompt foi ajustado para ler esta versão completa quando você pedir.
