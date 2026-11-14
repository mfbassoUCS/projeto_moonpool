# Prompt de retomada E06 — validação física e ajustes

E06 implementada e testada automaticamente em 29/10/2026. O fonte atual já está integrado na E07; prefira sua retomada para validar o conjunto. Este prompt serve como referência para ajustes restritos às naves; leia também LEIA-E07 e preserve sua apresentação.

```text
Vamos retomar somente a E06 (grupos de naves) do Moon Patrol para validar e corrigir o que for necessário.

Leia planejamento/README.md, planejamento/01-contexto-e-regras.md,
planejamento/03-medidas-e-constantes.md, planejamento/05-pendencias-e-decisoes.md,
planejamento/06-roteiro-de-execucao.md e planejamento/14-andamento.md.
Leia também, dentro de planejamento/: 11-etapa-naves.md.
Inspecione o fonte atual, os scripts de montagem e os testes existentes antes de editar.
Use o enunciado original para conferir dúvidas; não refaça etapas já concluídas.

Leia LEIA-E06.md, testes/README.md, evidencias/e06/verificacao.txt e
evidencias/e06/regressao/verificacao.txt. A E06 está implementada; não recrie naves,
artes E02, cenário E03, salto E04 ou obstáculos/vidas/pontos E05.
Testes automáticos passaram: 48 verificações E06, 4096 sementes, 48 grupos/394
obstáculos intercalados, 390 quadros, regressão E03–E05 e fluxo real de morte/reset.
Snapshots E01–E05 e evidências históricas estão preservados.

Convenções técnicas, sem confirmação do professor:
D06: formação de até 160 px preparada em [320,480), primeira origem 320..335;
as demais posições consomem a sobra após reservar larguras e gaps. Entrada gradual.
D07: >=30 pixels livres entre bordas de naves (origens >=44). Crateras continuam
150..230 livres, uma rocha intermediária com folgas >=60.
D09: Y=15..86, sprite 14x14 inteiro no céu [15,100). Y fixo, movimento para esquerda.
Quantidade 1..3 e tipo 0..2 sorteados; um tipo por grupo, repetição permitida.
PASSO_NAVE=1/TICKS_NAVE=2, cadência própria. Ativa inclusive fora da direita;
saída quando X<=-14. Novo grupo só no passo seguinte à última remoção.
RemoverNave(DI=0/2/4) preserva registradores; CF=1 só na primeira remoção válida,
CF=0 para inativa/índice inválido. Não pontua; tiros continuam fora do escopo.
Sortear(CX=1..256) preserva LCG/byte alto/resto da E05 e semente compartilhada,
inicializada somente na nova partida. Não semear novamente ao gerar grupo ou morrer.

Dados atuais E07=35.105 bytes, buffers cenário=320 e jipe=200. navesMudou solicita recomposição
do céu preto 15..99 mesmo sem movimento de terreno/jipe. Sem fundo velho de naves.
DesenharSpriteRecortado aceita X signed e recorta só na horizontal; Y deve caber
inteiro. DesenharSprite original não recorta. FFh transparente/00h opaco preservados.
Parte inferior: cenário -> obstáculos -> captura/jipe; só jipe restaura fundo atual.
Jipe 20x10, X=0..140, chão=183/topo=168, 3 px/1 tick; assertiva jipe > nave.
D05: topo pelo avanço do terreno até cruzar 5 px, amostras 2/4/6. Não trocar por frames.
D14/D15: morte/reposição, score, relógio e progresso preservados; grupo continua.
SomarPontos satura em 65535; +50 terrestre só no pouso seguro. Saída de nave não pontua.
SETOR 1/objetivo/Enter adotado tecnicamente na E07 (D04); integração automática aprovada.

Pendências: teclado físico, botões Assemble/Build/Run no fonte atual, conforto dos
saltos, aparência/fluidez/cintilação/rasgos e sessão normal de 90 s com cronômetro externo.
Siga LEIA-E06 para observar entrada/saída, grupos/alturas/gaps, espera pela última,
morte com ↑ mantida, reposição, pontos, reinício e Sair. Não marque teste físico
como aprovado por BIOS/scans/dumps. Registre o relato do aluno antes de concluir.
Se houver defeito, reproduza e corrija só o necessário; execute testes afetados.
Não repita etapas prontas ou toda a suíte sem motivo. Comandos de reprodução:
powershell -NoProfile -ExecutionPolicy Bypass -File testes\executar-e07.ps1
python testes\conferir-e07.py
E06 usa snapshot histórico; E07/R07 testam o fonte atual. Não inicie disparos nesta retomada.

Regras permanentes: Assembly 8086 simples e compreensível, compatível com GUI Turbo
Assembler no Windows. Reutilize a base; mantenha constantes e cabeçalhos de rotinas
com função, entradas e saídas. Desenhe/apague gráficos por memória, conforme enunciado.
Não acrescente arquitetura ou dependências desnecessárias. Separe regra do professor,
decisão do aluno e hipótese técnica. Peça informação somente quando necessária e
continue as partes independentes enquanto aguarda.

Ao concluir:
1. Monte e teste no ambiente existente o que for possível, com evidências reais.
2. Explique as alterações, o fluxo e as rotinas para eu conseguir apresentá-los.
3. Registre testes executados e pendentes, distinguindo execução, inspeção e teste físico.
4. Atualize planejamento/14-andamento.md e as decisões/documentos afetados.
5. Informe exatamente o que depende da minha ação e deixe o prompt da próxima etapa
   ajustado ao estado real; se algo faltar nesta etapa, deixe instrução de retomada dela.
Pare ao fim desta etapa. Não inicie a próxima automaticamente.
```

