# Medidas, cores, controles e constantes

**Configuração atual, 07/11/2026:** passo horizontal do jipe = 5 px/tick (aproximadamente 91 px/s nominal); subida/descida do salto continuam 3 px/frame e altura 15. Relevo redesenhado nas mesmas dimensões. Lançador E08 usa 50.000 ciclos, com PATH T:+Z:. Os registros de implementação antigos abaixo preservam os valores históricos. Ver [ajustes](../AJUSTES-JOGABILIDADE.md).

Dimensões abaixo usam **largura × altura**. Os nomes futuros das constantes podem mudar; seus valores obrigatórios não.

| Definição | Valor do enunciado |
|---|---|
| Modo / segmento de vídeo | 13h / A000h |
| Tela | 320×200; x=0..319; y=0..199 |
| Memória visível | 64.000 bytes; deslocamentos 0..63.999 |
| Endereço de pixel | A000h:(x + y×320) |
| Exemplo fornecido | (100,10) → deslocamento 3300 = 0CE4h |
| Limite superior da área de jogo | Linha 15 |
| Espaço das naves | Entre linhas 15 e aproximadamente 100; sprite não invade status/terreno |
| Montanhas | Começam na linha 100; altura máxima 95; cenário ≥320 de largura |
| Pista | 320×7, amarela |
| Jipe | 20×10, dimensões mantidas inclusive durante salto |
| Limite horizontal do jipe | Metade esquerda; borda exata depende da convenção registrada |
| Reposição após perder vida | Coluna 0 |
| Naves | 14×14; 3 tipos; grupo de 1 a 3 de um mesmo tipo |
| Distância horizontal entre naves | Mínimo 30 pixels; E06 mede espaço livre entre bordas (D07) |
| Indicador de vidas | 18×11; imagens para 3, 2 e 1 vidas |
| Relógio | 7×8 |
| Crateras | 14×7; 3 tipos; distância mínima 150 pixels |
| Rochas | 12×10; 4 tipos |
| Salto | Altura 15; subida 3 px/frame; topo 5 px de deslocamento horizontal; descida 3 px/frame |
| Tiro inimigo | 2×4, branco, para baixo |
| Tiro superior | Amarelo, para cima; dimensão não especificada |
| Tiro frontal | 4×2, vermelho; alcance percorrido de 50 pixels |
| Pontuação | Nave destruída +100; cratera superada +50; rocha superada ou destruída +50 |
| Tempo exibido | Atualização a cada segundo; duração total não especificada |

## Paleta da imagem enviada

| Código hexadecimal | Cor | Código hexadecimal | Cor |
|---|---|---|---|
| 0h | Preto | 8h | Cinza escuro |
| 1h | Azul | 9h | Azul claro |
| 2h | Verde | Ah | Verde claro |
| 3h | Ciano | Bh | Ciano claro |
| 4h | Vermelho | Ch | Vermelho claro |
| 5h | Magenta | Dh | Magenta claro |
| 6h | Marrom | Eh | Amarelo |
| 7h | Cinza claro | Fh | Branco |

Título: 0Ah. Menu selecionado: 0Ch. Menu não selecionado: 0Fh. Tiros inimigos: 0Fh; superior: 0Eh; frontal: vermelho (4h pela tabela). GAME OVER: vermelho, sem código explícito no texto; a E02 adotou 04h (D17, interpretação técnica). Modo 13h permite 256 índices; a tabela fornecida lista os primeiros 16.

## Controles

| Estado | Tecla | Ação |
|---|---|---|
| Menu | Cima / baixo | Alternar Jogar e Sair |
| Menu | Enter | Executar opção selecionada |
| Partida | Esquerda / direita | Mover jipe dentro do limite |
| Partida | Cima | Iniciar salto |
| Partida completa | Espaço | Disparar canhões superior e frontal juntos |
| Game Over | Qualquer tecla | Retornar ao menu |

Caixas do menu: 218=┌, 191=┐, 192=└, 217=┘, 196=─, 179=│. Preservar os códigos de byte esperados no ambiente, sem supor que salvar esses símbolos como UTF-8 produzirá os mesmos caracteres no DOS.

## Parâmetros a decidir, sem inventar exigência

Vida inicial, duração da partida, posições iniciais não especificadas, velocidades absolutas, intervalos de atualização, cadência de tiro, tamanho do tiro superior, capacidade de projéteis e número máximo de obstáculos simultâneos. Centralizar em constantes/dados de configuração. Velocidade do jipe deve superar a das naves. Valores vistos no exemplo, como “57” e “00100”, não definem duração nem score inicial.

Escolhas técnicas da E02: TAAG Mini para Moon Patrol e Small para GAME/OVER; FFh transparente, 00h preto opaco; menu inicialmente em Jogar; quatro objetos, passo 2 px a cada 2 ticks BIOS; X iniciais 0/80/160/240; Y 100 para jipe e 96 para naves. Retorno inteiro a X=0 após o último retângulo válido. Essas posições e velocidades pertencem ao menu, não à partida. SCORE_DEMO=12345 foi preservado somente no snapshot E02; a E03 usa scorePartida, inicialmente zero.

Artes autorais autorizadas em 25/10/2026: medidas dos sprites pequenos mantidas; montanhas 320×64 e montes 320×32 são escolhas de representação, não medidas impostas pelo professor. As duas camadas têm primeira/última colunas iguais. Dados gráficos totais: 32.932 bytes, preservados na E03.

## Configuração implementada E03 — 26/10/2026

Escolhas técnicas, sem confirmação adicional do professor: D01 segue posições do texto; D02 usa 90 segundos regressivos (`DURACAO_SEGUNDOS`, 1..999); D03 usa 3 vidas (`VIDAS_INICIAIS`, 1..3). Score inicial zero, word unsigned de cinco dígitos; E03 não concede pontos. Rever limite quando forem implementadas fontes de pontuação.

HUD reservado em y=0..14: texto de score na linha/coluna 0; vidas 18×11 em (151,2); relógio 7×8 em (280,3); tempo com três algarismos nas colunas 37..39. Campos são apagados/reimpressos integralmente.

`MARGEM_RELOGIO=6` centésimos é consumida uma única vez ao iniciar cada sessão, cobrindo a resolução DOS aproximada de 55 ms observada nos testes; não é acrescentada a cada segundo. O relógio acumula frações e só desconta grupos completos de 100 centésimos após essa margem.

D10: montanhas em y=100..163, montes em 132..163 e última linha composta repetida em 164..192, sem lacunas. Pista amarela 0Eh em 193..199. Relevo total 93 linhas, largura 320. `rolagem` módulo 320; `PASSO_CENARIO=2`, `TICKS_CENARIO=2`, cerca de 18,2 pixels/s quando a cadência é cumprida. A rolagem foi implementada e testada na E03, não durante a criação das artes. Apoio do jipe validado na E04 abaixo.

## Configuração implementada E04 — 28/10/2026

- Sprite 20×10 preservado. Origem = canto superior esquerdo. D08: X=0..140, último pixel X+19≤159; início X=0. Pista em 193, portanto Y chão=193−10=183; dez linhas 183..192. Topo Y=168, altura de salto=15.
- `PASSO_JIPE=3`, `TICKS_JIPE=1`; reserva para E06 `PASSO_NAVE=1`, `TICKS_NAVE=2`. Montador verifica velocidade do jipe superior por multiplicação cruzada. Naves de partida ainda não implementadas. Ambas as setas laterais pressionadas = neutro; limites saturam sem circular.
- Salto: Y=180/177/174/171/168 na subida e 171/174/177/180/183 na descida, 3 pixels por atualização do jipe. ↑ gera pedido apenas numa nova pressão no chão; repetição e pressão no ar não guardam outro salto.
- D05: aluno delegou a escolha; avanço do terreno como referência do topo. `SALTO_TOPO_PX=5`; cruzamento por distância, não por frames. Passo 2 produz amostras 2/4/6: até 1 pixel de discretização antes da detecção, seguida pela atualização de descida. Parado, esquerda e limites não bloqueiam. Detalhes/autoridade em 05 e LEIA-E04.
- Buffer `fundoPartida`=200 bytes, separado do menu. Dados totais=34.969 bytes (08899h), pilha=100h. Cenário usa os mesmos 320 bytes de composição; HUD/tempo/vidas/score preservados.

## Configuração implementada E05 — 29/10/2026

- Três tipos de crateras 14×7 em Y=193 e quatro rochas 12×10 em Y=183, artes E02 intactas. Tipos internos 0..2/3..6. Oito entradas fixas com X signed, tipo e estado de travessia. Sem tiros/resistência implementados.
- D07: `CRATERA_GAP_MIN=150`, `CRATERA_GAP_VAR=80`, espaço **livre** sorteado 150..230; origens separadas por 164..244. Uma rocha por intervalo planejado, `ROCHA_FOLGA=60` livres de cada lado. Geração pela direita com sobra do passo preservada; todos movem 2 px/2 ticks com o terreno.
- D15: intervalos semiabertos dos retângulos inteiros. Sobreposição horizontal e Y=183 mata sobre cratera; para rocha, `jipeY+10>183`. Transparência não altera colisão. Pouso verificado antes de pontos; bordas apenas encostadas são seguras. Critério técnico conservador; janela de salto estreita, conforto físico pendente.
- Pontuação: `PONTOS_OBST=50`, uma vez após travessia completa em salto e pouso seguro. `SCORE_MAX=65535`: soma saturada sem wrap, cinco dígitos. Morte invalida travessias em curso e o obstáculo fatal. Nenhum ponto automático por saída da tela.
- D14: morte retira uma vida e deixa jipe ausente; tenta reaparecer no próximo tick do jipe quando [0,20) estiver livre. Mantém score/relógio/frações/margem/progresso/geração e teclas físicas. Nenhuma invulnerabilidade; ↑ mantida precisa soltar antes de novo salto.
- Recorte horizontal dos obstáculos em `DesenharSpriteRecortado`; `DesenharSprite` original continua sem recorte. Composição antes da captura do jipe; buffers 320/200 bytes. Dados finais 35.072 bytes (08900h), pilha 100h.
- Para a amostragem discreta da colisão, montagem rejeita `PASSO_CENARIO+PASSO_JIPE>ROCHA_LARG`. Reserva das naves continua 1 px/2 ticks, ainda sem implementação. D05/D08/relógio da E04 preservados.

## Configuração implementada E06 — 29/10/2026

- Três artes 14×14 intactas, `NAVE_MAX=3`, `NAVE_TIPOS=3`, um tipo compartilhado por grupo; quantidade sorteada 1..3. Atividade por vaga, independente da quantidade inicial.
- D06: `NAVE_FAIXA=160`, formação inicial `[320,480)`; `NAVE_X_INICIAL=320`, `NAVE_ENTRADA_VAR=15`, primeira origem 320..335. Demais X consomem a sobra depois de reservar larguras e intervalos, sem tentativas. A faixa externa permite entrada gradual; essa é interpretação técnica da frase ambígua sobre metade horizontal.
- D07: `NAVE_GAP_MIN=30` pixels livres entre bordas; origens distam >=44. D09: `NAVE_Y_MIN=15`, `NAVE_Y_MAX=100-14=86`, pixels limitados a 15..99.
- `PASSO_NAVE=1` / `TICKS_NAVE=2` agora executados na partida, cadência independente de cenário e jipe. Assertiva de velocidade E04 preservada; teste real de duas amostras confirma jipe 6 px/nave 1 px. Y fixo; retirar quando X≤−14. Próximo grupo somente na atualização seguinte à lista vazia. Sem pontos pela saída.
- `Sortear` preservado, CX explicitamente 1..256; todas as faixas utilizadas cabem. Compartilha semente com obstáculos, reiniciada apenas na nova partida. Geração intercalada testou variedade dos sete obstáculos e três naves.
- Céu preto em `[15,100)` recomposto quando `navesMudou`; recorte horizontal E05 reutilizado. Não há fundo de nave salvo. Dados 35.100 bytes (0891Ch); aumento líquido 28, buffers cenário=320/jipe=200 e pilha=100h. E08 precisará incluir tiros na composição dessa faixa.

## Configuração integrada E07 — 31/10/2026

- D04 adota SETOR 1, objetivo e Enter para iniciar, sem tempo correndo no setor nem avanço automático. Uma fase somente. A referência inicial continua após desenho do primeiro quadro; 90 s/3 vidas/score zero preservados.
- Removidos rótulos de etapa e aviso/flag/rotina de demonstração. Game Over recebe score real; menu/setor/fim continuam pelo BIOS e partida por IRQ1. Todas as constantes de jogo e 55 rotinas da E06 ficaram idênticas; ajustes somente em apresentação do setor/fim e remoção do aviso obsoleto.
- Dados 35.105 bytes (08921h), código 3.671 bytes (00E57h), buffers cenário=320/jipe=200 e pilha=100h. Nenhuma arte, regra de salto, velocidade, geração, colisão ou ponto foi refeita.
- Testes atuais E07/R07 e matriz em 13; os registros E03–E06 acima descrevem suas configurações históricas. Validação física/IDE e 90 s externos ainda pendentes.

## Configuração implementada E08 — 01/11/2026

- D11/D13 estão registradas em 05 e explicadas em LEIA-E08. Superior 2×4 é escolha técnica; frontal 4×2 e inimigo 2×4 são exigidos. Cores 0Eh/04h/0Fh.
- `TIRO_SUP_MAX=8`, `TIRO_FRE_MAX=8`, `TIRO_INI_MAX=12`. Quatro vetores word: atividade, X, Y e distância; índices pares 0..14, 16..30 e 32..54. Não sobrescrever ativos.
- `TICKS_TIRO=1`; passos 4/4/2, percorridos pixel a pixel com colisão/limites. `CADENCIA_JIPE=6`, `CADENCIA_NAVE=18` atualizações; canhão da nave visível em X=0..318. Sem vaga, par inteiro recusado ou nave aguarda.
- Origens: superior `(X+6,Y−4)`, frontal `(X+20,Y+4)`, inimigo `(X+6,Y+14)`. Frontal percorre 50 desde o nascimento; superior termina na linha 15; branco na pista 193 ou no jipe. Y sempre válido antes de desenhar.
- Rocha 4: `IMPACTOS_ROCHA4=2`, sem temporizador. Contador zera ao reutilizar vaga. Pontos 100/50 saturados; `PASS_PONTO` impede duplicação por salto. Crateras intactas.
- Dados 35.431 bytes (08A67h), código 4.854 bytes (012F6h), pilha 100h; buffers 320/200. Artes e constantes anteriores intactas; sem buffer de tela nem dependência do EXE.
- Velocidades nominais, quando a cadência é cumprida: superior/frontal ~73 px/s, branco ~36 px/s, jipe ~55 px/s. Conforto/esquiva/fluidez precisam de teste físico.

## Revisão E09 — 02–06/11/2026

Todas as constantes, dados e instruções executáveis da configuração E08 acima foram preservados; alterações em MOON.ASM são somente comentários. A conferência dos 69 cabeçalhos, dimensões e memória está em `evidencias/e09/inspecao.txt`; suíte atual e limites em LEIA-E09. Botões e ciclo sintético da IDE agora têm evidência, mantendo pendentes teclado físico, conforto/esquiva/fluidez e 90 s externos. Não houve confirmação adicional do professor nem mudança das convenções D.
