# Prompt de retomada E05 — validação física e ajustes

E05 implementada e verificada automaticamente em 29/10/2026. Este prompt é uma referência para ajustes das regras terrestres. **O fonte atual já está na E06:** preserve as naves e consulte também LEIA-E06 e suas evidências. Para validar o conjunto atual, prefira a retomada E06.

```text
Vamos retomar somente a E05 (obstáculos e vidas) do Moon Patrol para validar e corrigir o que for necessário.

Leia planejamento/README.md, planejamento/01-contexto-e-regras.md,
planejamento/03-medidas-e-constantes.md, planejamento/05-pendencias-e-decisoes.md,
planejamento/06-roteiro-de-execucao.md, planejamento/10-etapa-jipe-e-obstaculos.md
e planejamento/14-andamento.md. Leia LEIA-E05.md, LEIA-E04.md, testes/README.md
e evidencias/e05/verificacao.txt. Inspecione fonte, scripts e testes antes de editar.
Leia também LEIA-E06.md e evidencias/e06/verificacao.txt: MOON atual inclui naves;
E05BASE.ASM é o snapshot histórico. Use a regressão R06 para validar o fonte atual.
Use planejamento/fontes/enunciado-original.md para dúvidas. Não refaça artes E02,
cenário/relógio E03, jipe/salto E04 ou a implementação E05 que já foi testada.

E05 implementa três crateras 14x7, quatro rochas 12x10, geração pela direita com o terreno,
colisões, vidas e +50 por travessia de salto seguida de pouso seguro. Preserve as naves
da E06 já presentes no fonte atual; tiros continuam fora do escopo.
D07: 150..230 pixels LIVRES entre bordas das crateras, uma rocha no intervalo planejado
com >=60 livres de cada lado. Oito entradas fixas, X signed, tipo 0..2/3..6 e marcador.
D15: retângulos inteiros semiabertos. Cratera mata por sobreposição horizontal e apoio
Y=183; rocha mata por sobreposição horizontal e jipeY+10>183. Bordas apenas encostadas
são seguras. A janela da rocha é estreita; qualquer ajuste desse critério deve ser explícito.
Pontos somente depois de aproximação, sobreposição no salto, saída completa e pouso seguro;
sem repetição, sem pontos por saída da tela ou obstáculo fatal. SomarPontos satura em 65535.
D14: uma vida por evento; jipe ausente até próximo tick e [0,20) livre, sem invulnerabilidade,
remoção de obstáculos ou reset de tempo/score/progresso. Laterais mantidas retomam no tick
seguinte; ↑ mantida ou pressionada ausente não enfileira salto, exige soltura/nova pressão.

Preserve D05: escolha técnica delegada pelo aluno, topo pelo avanço do terreno até cruzar
5 pixels, amostras 2/4/6, até 1 px de discretização e descida na atualização seguinte.
Não trocar por frames nem X líquido. Jipe 20x10, X=0..140, chão=183/topo=168,
3 px/1 tick; naves E06 implementadas em 1 px/2 ticks. Pista=193..199.
Desenho: cenário -> obstáculos -> captura/jipe; só jipe restaura fundo atual de 200 bytes.
DesenharSpriteRecortado recorta na horizontal; DesenharSprite original não recorta.
Dados atuais E06=35.100 bytes, buffer cenário=320, pilha=100h. HUD=0..14. Relógio DOS/frações,
margem inicial única 6 centésimos, 90 s e Game Over com score real preservados.
SETOR 1/Enter ainda é proposta D04. Snapshots E04/E05 e testes históricos preservados.

Já executado: TASM/TLINK sem erros/avisos; regressão E03/E04; 362 verificações E05,
sete saltos reais, geração de 20.000 pixels (199 objetos), 336 quadros/21.840.000 bytes
conferidos, morte natural/reposição, última vida, expiração curta, reset e Sair.
Não confundir execução automatizada, inspeção de fonte/pixels e teste físico.

Minha ação pendente: Assemble/Build/Run do fonte atual na IDE; teclado físico (segurar/soltar,
simultâneas, inverter no ar, ↑ mantida no pouso/morte); saltar os sete tipos com avanço,
conferir +50 uma vez no pouso; provocar colisões/pousos, perda 3->2->1->Game Over,
espera/reposição X=0 e continuidade do relógio/score/terreno; reiniciar e Sair.
Observar rastros/cintilação/fluidez em várias gerações e duas voltas, avaliar janela das
rochas, comparar cronômetro externo e tentar sobreviver aos 90 s normais.
Os resultados físicos que eu informar devem orientar ajustes pontuais; não invente evidência.

Mantenha Assembly 8086 simples, constantes e cabeçalhos de função/entrada/saída;
gráficos por memória; compatibilidade GUI Turbo Assembler. Diferencie regras do professor,
decisão do aluno e escolha técnica. Se corrigir fonte, rode testes pertinentes e atualize
LEIA-E05, decisões, andamento, evidências e prompts afetados. Explique o fluxo para apresentação.
Registre precisamente o que ainda depende de mim. Pare após os ajustes terrestres pedidos;
preserve E06 e não inicie E07 ou disparos.
```
