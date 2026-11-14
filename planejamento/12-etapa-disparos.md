# E08 — Disparos da versão completa

**Implementada em 01/11/2026; validação física pendente.** Guia atual: [LEIA-E08](../LEIA-E08.md); resultados em [evidências E08](../evidencias/e08/verificacao.txt). Ler 03, 10, 11 e D11/D13. Requisitos R11, R12, R17 e interação de R22–R24. **Estes disparos são opcionais no mínimo entregável, mas fazem parte da especificação completa.**

## Canhões do jipe

Barra de espaço aciona superior e frontal simultaneamente. Um tiro não pode substituir um anterior ainda ativo apenas porque o jogador atirou de novo. Planejar capacidade e cadência para preservar projéteis ativos; registrar a política quando a capacidade se esgotar, sem quebrar o disparo conjunto silenciosamente.

### Superior

- Origem no canhão da parte superior do jipe, acompanhando sua posição no instante do disparo, inclusive no salto.
- Amarelo, movimento vertical para cima; dimensões adotadas 2×4 em D13, pois não constam no texto.
- Ao atingir nave: remover ambos e somar 100 uma única vez.
- Ao chegar à linha 15: remover sem pontuação ou outro efeito.
- Vida independente do jipe e de outros tiros depois de criado, até ocorrer condição de remoção definida.

### Frontal

- Origem no canhão frontal, vermelho, 4 pixels de comprimento × 2 de altura.
- Movimento horizontal para a direita.
- Alcance de **50 pixels percorridos**, não coordenada absoluta x=50 e não distância atual ao jipe em movimento.
- Remove-se ao colidir com obstáculo/elemento atingível ou ao completar o alcance.
- Rocha 1 permanece após impacto; tiro é consumido. Tipos 2/3 somem no primeiro impacto. Tipo 4 permanece no primeiro e some após segundo impacto conforme decisão D11.
- +50 somente quando a rocha for destruída, não a cada impacto.
- Crateras não ganham destruição por tiro: isso não está especificado.

## Tiros das naves

- Disparos verticais contínuos para baixo; cadência configurável e origem na nave.
- Branco, 2×4.
- Velocidade compatível com movimento do jipe, dando chance de reação/esquiva.
- Termina na superfície lunar ou no jipe; não deve continuar indefinidamente fora da tela.
- Colisão quando a extremidade inferior atinge/sobrepõe o retângulo do jipe, com sobreposição horizontal.
- Colisão destrói o jipe, retira uma vida e recria em x=0 se ainda houver vidas.

## Organização simples e integração

Passagem da E06 implementada: `RemoverNave(DI=0/2/4)` preserva registradores, retorna CF=1 somente ao remover uma ativa e marca `navesMudou`; CF=0 para inativa/índice inválido. A rotina não pontua. Um impacto futuro deverá consumir CF imediatamente e usar `SomarPontos(AX=100)` uma vez. Consulte `naveAtiva`, inclusive para bloquear geração enquanto houver nave aguardando entrada pela direita.

O compositor E08 recompõe céu e terreno quando tiros mudam, desenhando projéteis depois das limpezas e antes de capturar/desenhar o jipe. Movimento só de nave/tiro/jipe, remoção e rolagem estão cobertos no oráculo de pixels.

Proposta: conjuntos de projéteis com posição, atividade, tipo/direção e distância percorrida quando aplicável. Compartilhar rotinas de desenho e testes geométricos que sejam realmente comuns, mantendo as diferenças de comportamento claras.

Não vincular a existência de um tiro ao slot da nave que o disparou de forma que a criação de outro grupo apague o tiro sem regra. Definir a ordem de movimento, colisão, remoção e score para um impacto não afetar vários objetos por acidente. Se a velocidade saltar por cima de um alvo entre frames, ajustar deslocamento ou teste de trajeto.

## Aceitação

- Espaço cria os dois tiros em posição correta, no chão e no salto.
- Vários tiros mantêm estado independente; cadência/capacidade não sobrescrevem ativos.
- Superior termina na linha 15 ou nave, com +100 exatamente uma vez.
- Frontal percorre no máximo 50 desde o disparo, mesmo com jipe se movendo.
- Testar individualmente as quatro resistências de rocha e +50 apenas na destruição.
- Testar tiro inimigo na borda do jipe, no meio, fora dele e atingindo superfície.
- Última nave destruída libera próximo grupo; tiro remanescente segue a regra de seu próprio ciclo.
- Repetir os testes do mínimo para garantir que a inclusão não alterou salto, relógio, terreno e telas.

Explicar limites dos arrays, duração de um objeto ativo, distância percorrida e atualização da resistência de rochas.

## Decisões implementadas

D11: dois impactos na mesma rocha 4 sem prazo; reuso zera dano. D13: capacidades 8/8/12, superior 2×4, passos 4/4/2 por tick, cadências 6/18 atualizações. Par inteiro ou nenhum se faltar vaga; Espaço mantido tenta novamente. Toque durante recarga não é enfileirado. Canhão inimigo precisa estar visível. Superfície = pista Y=193; montanhas são fundo. Vida dos projéteis independe do emissor.

`MoverDisparos` testa cada pixel; `ConferirUmDisparo` consome o primeiro impacto; `ConferirDisparos` cobre movimento dos alvos sem tick de projétil. Contato inferior do branco inclui a borda superior do jipe; bordas laterais apenas encostadas não colidem. `TiroNaReposicao` espera a área inicial livre também de tiros, preservando D14.

T17–T20 têm execução automática e limites na matriz 13. Teclado físico, botões atuais, conforto/esquiva/fluidez e 90 s normais com cronômetro externo continuam pendentes. Em 01/11 o aluno informou ainda não ter realizado os testes manuais. Retomar E08 para esses resultados/defeitos; E09 somente mediante novo pedido.
