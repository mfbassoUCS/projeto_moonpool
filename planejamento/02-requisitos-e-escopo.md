# Requisitos e escopo rastreável

**Mínimo** é o conjunto que o professor exige para avaliar. **Completo** inclui os disparos descritos nas seções funcionais, explicitamente opcionais no mínimo. Planejar ambos e executar primeiro o mínimo é uma proposta de organização, não uma decisão de abandonar os tiros.

**Estado em 06/11/2026:** versão completa E08 revisada na E09; R11/R12/R17 e interação por tiros de R22–R24 implementados. [Revisão R×T×fonte](17-revisao-e09.md), [matriz T01–T20](13-validacao-e-entrega.md) e [LEIA-E09](../LEIA-E09.md) distinguem execução automática/IDE, inspeção e pendências físicas. R28 permanece obrigação acadêmica pendente.

| ID | Regra e referência no enunciado | Escopo | Documento |
|---|---|---|---|
| R01 | Assembly 8086; apresentação exclusivamente GUI Turbo Assembler/Windows (§1, §5) | Mínimo | 07 |
| R02 | Vídeo 13h, 320×200, A000h, desenho/ocultação por memória (§3.1, §5) | Mínimo | 07 |
| R03 | Título Moon Patrol em ASCII do TAAG, verde-claro, na parte superior (§3.2) | Mínimo | 08 |
| R04 | Jipe e três tipos de naves animados ciclicamente da esquerda à direita no menu (§3.2) | Mínimo | 08 |
| R05 | Jogar/Sair, caixas com códigos especificados, setas, seleção vermelho-claro, Enter (§3.2) | Mínimo | 08 |
| R06 | Status com score, vidas e tempo; atualização do tempo a cada segundo (§3.4.1) | Mínimo | 09 |
| R07 | Ícone de vidas 18×11 e relógio 7×8 (§3.4.1) | Mínimo | 08, 09 |
| R08 | Três tipos de naves 14×14; espaço lunar entre linhas 15 e 100 (§3.4.2 Espaço Lunar) | Mínimo | 11 |
| R09 | Grupo aleatório de 1–3 naves do mesmo tipo; posições aleatórias, sem sobreposição, distância horizontal mínima 30 (§3.4.2) | Mínimo | 11 |
| R10 | Naves da direita à esquerda; próximo grupo apenas quando todas saírem ou forem destruídas (§3.4.2) | Mínimo | 11 |
| R11 | Tiros inimigos brancos 2×4, verticais para baixo até superfície/jipe (§3.4.2) | Completo; dispensado no mínimo | 12 |
| R12 | Tiro superior amarelo até nave/linha 15; remoção dos envolvidos e +100 por nave (§3.4.2) | Completo; dispensado no mínimo | 12 |
| R13 | Montanhas variáveis a partir da linha 100, altura máxima 95; cenário largura mínima 320 (§3.4.2 Superfície) | Mínimo | 09 |
| R14 | Rolagem contínua direita→esquerda, retorno ao início sem emenda perceptível (§3.4.2 Superfície) | Mínimo | 09 |
| R15 | Pista amarela, 7 pixels de altura, largura total (§Jipe) | Mínimo | 09 |
| R16 | Jipe 20×10, setas laterais, limitado à metade esquerda, mais rápido que naves (§Jipe) | Mínimo | 10 |
| R17 | Espaço aciona ambos os canhões simultaneamente; frontal vermelho 4×2, alcance 50 (§Jipe) | Completo; dispensado no mínimo | 12 |
| R18 | Três crateras 14×7, aleatórias pela direita, distância mínima 150, acompanham terreno (§Crateras) | Mínimo | 10 |
| R19 | Salto trapezoidal pela seta para cima: 15 de altura, subida/descida 3 px/frame, topo por 5 px horizontais (§Crateras) | Mínimo | 10 |
| R20 | +50 por cratera superada sem colisão, uma única vez (§Crateras) | Mínimo | 10 |
| R21 | Quatro rochas 12×10 entre crateras, aleatórias, acompanham terreno (§Rochas) | Mínimo | 10 |
| R22 | Rocha 1 indestrutível; 2/3 um tiro; 4 dois tiros consecutivos (§Rochas) | Tipos no mínimo; interação com tiro na versão completa | 10, 12 |
| R23 | +50 por rocha saltada ou destruída (§Rochas) | Salto no mínimo; destruição no completo | 10, 12 |
| R24 | Colisão destrói jipe, retira uma vida, recria na coluna 0 enquanto houver vidas (§3.4.2, §4) | Mínimo; tiro inimigo no completo | 10 |
| R25 | Sem vidas ou tempo esgotado encerra; GAME OVER vermelho em duas linhas e score; qualquer tecla retorna (§3.5, §6 mínimo) | Mínimo | 08, 09 |
| R26 | Constantes, tempo parametrizável, reutilização e cabeçalhos de rotinas (§5, §6 mínimo) | Mínimo | 01, 07 |
| R27 | Tela de apresentação do setor mencionada no mínimo, sem especificação visual (§6 mínimo) | Obrigatória; E07 adota SETOR 1/objetivo/Enter como escolha técnica D04 | 05, 08 |
| R28 | Apresentação antes de submissão e inscrição no grupo (§1, §6 entrega) | Obrigação acadêmica | 13 |

## Limites da interpretação

- O mínimo dispensa tiros das naves e ambos os tiros do jipe; não dispensa grupos, tipos, salto, obstáculos, vidas ou pontuação das ações disponíveis.
- Na entrega mínima, as rochas destrutíveis ainda precisam existir e poder ser superadas por salto. Não exigir uma destruição por tiro de uma versão que usa a dispensa expressa do professor.
- A frase “elementos não descritos ou definidos como opcionais” não permite classificar arbitrariamente qualquer requisito como opcional.
- Não há obrigação de cinco fases, vitória por distância, minas ou alturas de salto variáveis na adaptação solicitada.
- Onde houver dúvida, consultar [pendências](05-pendencias-e-decisoes.md) e o texto integral. IDs servem à rastreabilidade interna, não são numeração do professor.
