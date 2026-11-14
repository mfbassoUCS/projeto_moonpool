# E03 — Cenário, status e relógio

Ler 03 e D01–D03/D10. Requisitos R06, R07, R13–R15 e parte de R25.

**Estado em 26/10/2026:** implementada e verificada automaticamente no emulador do GUI Turbo Assembler. Teste físico/IDE e observação de fluidez pelo aluno pendentes. Leia [LEIA-E03](../LEIA-E03.md), [decisões](05-pendencias-e-decisoes.md) e [andamento](14-andamento.md). As seções abaixo são os critérios da etapa, não uma ordem para refazê-la.

Solução adotada: uma origem circular de 320 pixels para ambas as artes; buffer de 320 bytes por linha; montanhas desde y=100, montes desde y=132, base prolongada de 164 até 192 e pista amarela em 193..199. HUD conforme texto, três vidas, score zero, regressiva configurável de 90 s. Temporização em centésimos completos independente de 2 px/2 ticks do terreno. Somente o fim por tempo foi integrado; sem jipe, obstáculos, grupos ou tiros.

## Cenário

- Região montanhosa variável, desenhada a partir da linha 100, altura máxima 95 pixels.
- Largura do cenário de pelo menos 320 pixels.
- Montanhas e montes das referências compõem o fundo por sobreposição. Velocidades diferentes entre camadas não são exigidas; não adicionar paralaxe complexa sem necessidade.
- Pista plana amarela de 7 pixels, de uma margem à outra. Se colocada na base, ocupa y=193..199; essa coordenada é uma derivação a registrar, não um número explicitamente escrito no enunciado.
- Rolagem contínua da direita para a esquerda; novos trechos entram à direita e os que saem são removidos/reutilizados.
- Final e início se conectam sem salto perceptível. Planejar a emenda visual, não apenas reiniciar um contador.
- Crateras e rochas acompanharão o mesmo deslocamento do terreno, preservando posição relativa.

Proposta simples: uma posição de rolagem e um cenário repetível com emenda preparada. Antes de escolher representação, estimar memória do relevo e demais bitmaps em Assembly 8086. A imagem ampliada da referência não define tamanho obrigatório da matriz a armazenar.

## Status

O texto manda score à esquerda, vidas no centro e tempo à direita; a imagem diverge. Registrar solução de D01. Reservar a barra superior para não receber naves nem tiros.

Exibir indicador de vidas 18×11, score numérico, relógio 7×8 e tempo. Atualizar tempo a cada segundo. Separar valor numérico de sua apresentação, apagando dígitos antigos corretamente. Formato e quantidade de dígitos do score não estão fixados pelo exemplo.

Duração total deve ser configurável. A contagem regressiva é a proposta coerente com “tempo terminar”; registrar decisão D02. Evitar que mudança de velocidade de desenho/movimento altere a duração real da partida. Escolher representação de score que não transborde dentro da duração escolhida.

## Aceitação

- Observar pelo menos duas voltas completas do cenário e conferir a emenda.
- Confirmar dimensões da pista, relevo variável e limite superior das montanhas.
- Não deixar rastros nem apagar a barra de status ao redesenhar.
- Comparar a passagem de segundos com um relógio; anotar configuração do emulador.
- Expirar o tempo e entrar em Game Over; começar nova partida com valores reiniciados.
- Confirmar que mudar intervalo de movimento não altera indevidamente o relógio.

Explicar posição de rolagem, repetição do cenário, camadas e diferença entre frame de movimento e segundo. Entregar a E04 coordenada da pista, velocidade do terreno e forma de atualização do status.
