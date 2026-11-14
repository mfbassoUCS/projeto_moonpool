# Referências visuais e fontes externas

## Arquivos disponíveis

**Atualização de 25/10/2026:** o aluno autorizou pesquisar o arcade como referência e criar artes próprias, sem cópia. A implementação atual usa esse caminho; não depende de recuperar os arquivos listados no catálogo histórico abaixo. As figuras da disciplina ainda não estão disponíveis.

O texto enviado foi preservado em [enunciado-original.md](fontes/enunciado-original.md), com inclusive a numeração repetida e falhas de extração da fórmula. O original local era `C:\Users\mateu\.codex\attachments\4455af41-8c15-4500-98bb-1809a5278dfb\Pasted text.txt`.

As 13 imagens foram inspecionadas na conversa. Não estavam como arquivos no diretório desse anexo. **Este catálogo não substitui os pixels das referências.** Não declarar reprodução exata sem acesso às imagens. Os nomes abaixo são nomes sugeridos para arquivamento futuro em `fontes/imagens/`; ainda não são arquivos existentes.

| Ordem enviada | Nome sugerido | O que preservar / conferir |
|---|---|---|
| 1 | 01-grade-video.png | Grade com coordenadas x 0–319, y 0–199; representação do modo 13h |
| 2 | 02-paleta.png | Tabela de cores hexadecimal 0–F, transcrita em 03 |
| 3 | 03-menu.png | Título verde, sprites intermediários, Jogar/Sair em caixas. Mostra “Arcade”, mas texto exige “Moon Patrol” |
| 4 | 04-status.png | Vidas à esquerda, score central e relógio/tempo à direita; diverge da posição descrita no texto |
| 5 | 05-vidas.png | Três variantes do indicador, respectivamente 3, 2 e 1 vidas; grade para desenho 18×11 |
| 6 | 06-relogio.png | Relógio amarelo/preto em grade; dimensão exigida 7×8 |
| 7 | 07-naves.png | Três tipos de naves, cada um em grade 14×14; tipos visualmente distintos |
| 8 | 08-partida.png | Composição: status, espaço preto, naves, relevo azul e verde, pista amarela, jipe e obstáculos |
| 9 | 09-montanhas.png | Faixa de montanhas em tons azul/ciano, com grade; referência de relevo de fundo |
| 10 | 10-montes.png | Faixa complementar de montes verdes com grade; sobreposição com montanhas |
| 11 | 11-jipe.png | Jipe colorido em grade, 20×10 exigidos |
| 12 | 12-crateras.png | Três crateras visualmente diferentes, 14×7 cada |
| 13 | 13-rochas.png | Quatro rochas visualmente diferentes, 12×10 cada |

A numeração aqui segue a ordem do envio, pois a numeração de figuras no texto repete valores. A imagem 10 foi redimensionada na conversa de 2050×511 para 2048×511; não usar seu tamanho exibido para deduzir medidas exatas do bitmap. As grades e os fundos cinza das referências são guias de edição: confirmar como representar transparência/fundo antes da conversão. Não desenhar automaticamente as linhas da grade no jogo.

## Links fornecidos e consultados em 22/10/2026

- [Moon Patrol on-line — Lexaloffle](https://www.lexaloffle.com/bbs/?pid=moonpatrol): referência de jogo. A página apresenta uma adaptação em PICO-8. Serve para observar apresentação e movimento; suas regras e seu código não substituem o enunciado Assembly 8086.
- [Ink Me ASCII](https://inkmeascii.com/): conversor de imagens em arte ASCII, sugerido no enunciado para auxiliar a criação gráfica. A equipe continua responsável por converter caracteres em índices de cor e armazenar/manipular os bitmaps.
- [TAAG](https://patorjk.com/software/taag/): gerador de texto em arte ASCII. O professor exige usá-lo para o título Moon Patrol; GAME OVER também deve ser arte ASCII. Escolher fonte que caiba na tela e registrar qual foi utilizada.

## Procedimento futuro para as artes

1. Obter a referência original e conferir largura/altura exigidas no texto.
2. Separar as variantes; identificar cores e fundo sem incorporar grade.
3. Registrar a correspondência entre caracteres e códigos de cor.
4. Produzir, pela equipe, os dados do bitmap e conferir número de linhas/colunas.
5. Exibir em escala nativa no emulador e comparar com a referência.
6. Registrar origem, dimensões, transparência e versão dos dados.

A E02 foi autorizada em 24/10/2026. A ausência das imagens foi reconfirmada e as referências foram solicitadas. Isso permite avançar no menu/telas e testar molduras, mas não declarar reprodução exata nem copiar o código do jogo on-line.

## Material obtido na E02 em 24/10 — histórico

Moon Patrol foi gerado no TAAG com fonte Mini; GAME e OVER com Small. Saídas, URLs e capturas em `../artes/`. O título mede 39×4 caracteres; GAME 24×5 e OVER 21×5, incluindo a linha em branco das fontes. A impressão usa células BIOS de 8×8 pixels. Os dados arquivados são conferidos contra MOON.ASM.

Molduras do menu (20×10 e três 14×14) são marcadores técnicos. Reservas para vidas/relógio/crateras/rochas usam FFh transparente e não contêm desenhos finais. O relevo não foi convertido. Para concluir, fornecer 05-vidas, 06-relogio, 07-naves, 09-montanhas, 10-montes, 11-jipe, 12-crateras e 13-rochas; 03-menu e 08-partida permitem comparar a composição.

## Artes próprias em 25/10 — estado atual

Foram consultadas três capturas disponibilizadas pela HAMSTER na [página de Arcade Archives MOON PATROL](https://store.playstation.com/en-ca/product/UP0571-CUSA11076_00-HAMPRDC000000001). Elas orientaram formas gerais e contraste, sem extração ou reprodução dos pixels. Fontes e observações estão em `../artes/referencias/README.md`.

As molduras/reservas foram substituídas por 15 sprites pequenos e duas camadas de relevo, todos desenhados em grades novas. O gerador auxiliar `../artes/gerar-artes.py` associa caracteres a índices VGA e produz DB; não lê as capturas. Grades em desenhos.json, catálogo e prévias em `../artes/previas/`. Os sprites usam as dimensões do trabalho; montanhas 320×64 e montes 320×32 são escolhas técnicas. A verificação compara as grades com os bytes montados e com uma galeria estática desenhada no emulador. Não há alegação de fidelidade às figuras ausentes nem implementação da E03.
