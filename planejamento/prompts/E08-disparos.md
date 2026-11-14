# Prompt E08 — retomada da versão completa

Prompt histórico da E08, implementada em 01/11/2026. A revisão E09 foi preparada em 02/11; para o estado atual e pendências físicas, use [retomada E09](E09-revisao-e-apresentacao.md). O bloco abaixo conserva a passagem anterior e não deve substituir o andamento atual.

```text
Vamos retomar somente a E08 do Moon Patrol, sem iniciar E09.

Leia planejamento/README.md, 01-contexto-e-regras.md, 03-medidas-e-constantes.md,
05-pendencias-e-decisoes.md, 06-roteiro-de-execucao.md, 10-etapa-jipe-e-obstaculos.md,
11-etapa-naves.md, 12-etapa-disparos.md, 13-validacao-e-entrega.md e 14-andamento.md.
Leia LEIA-E08.md, testes/README.md e os relatórios em evidencias/e08/.
Inspecione MOON.ASM, scripts e testes antes de editar; confira dúvidas no enunciado original.

Estado: tiros completos implementados e verificados automaticamente em E08/N08/R08.
Fonte SHA256 27B2C4915F13B43CE55E4B0BC79A1F477A0E048B4F6BB94EA479D342D56DCB1A.
E07BASE preserva o mínimo anterior; E01–E07/testes/evidências são históricos.
426 verificações de lógica, 170 quadros/11.050.000 bytes, fluxo com tiro inimigo persistente,
vida/reposição/fim/reset e regressões do mínimo aprovados. E08KEY passou por eventos Windows
em SDL windib/IRQ1; não é teste físico/backend normal. R08AUTO isola emissão inimiga somente
na variante antiga; E08AUTO testa o fluxo com todos os tiros e MOON mantém emissão normal.

Ainda faltam: Assemble/Build/Run nos botões atuais; teclado físico com setas/Espaço,
salto/morte/soltura; conforto da janela de salto e da esquiva; fluidez/rasgos;
90 s normais com cronômetro externo. Aluno informou em 01/11 que não fez os testes manuais E07.
Obtenha meu relato disponível e registre pendências sem marcá-las aprovadas. Corrija defeitos
concretos e repita somente verificações pertinentes; não refaça etapas nem acrescente recursos.

Preserve D11: rocha 4 recebe dois impactos persistentes, sem temporizador; reuso zera dano.
D13: superior 2×4/amarelo, frontal 4×2/vermelho/50 px desde origem, inimigo 2×4/branco;
8/8/12 vagas; passos 4/4/2 por tick e cadências 6/18. Par inteiro ou nenhum se faltar vaga;
ativos não são sobrescritos. Morte do emissor e novo grupo não apagam seus tiros.
RemoverNave(DI=0/2/4) preserva registradores; CF deve ser testado imediatamente; +100 só por
primeira remoção por impacto. +50 por salto OU destruição, sem duplicar; teto 65535.
Crateras intactas. Reposição também espera branco sair da área inicial, sem invulnerabilidade.

Preserve D04 (setor/Enter/tempo após primeiro quadro), D05 (avanço do terreno 5 px/amostras 2/4/6),
limites/salto/velocidades do jipe, grupos naves X signed/Y=15..86/três vagas/D06/D07/D09,
sorteio compartilhado só semeado na nova partida, D14/D15 e relógio/score/progresso.
O compositor desenha tiros após céu/terreno e antes da captura/jipe; tirosMudou provoca
apagamento mesmo sem rolagem. Recorte só horizontal: manter Y válido. Buffers 320/200;
dados 35.431 bytes na passagem. Assembly 8086 simples, ASCII, cabeçalhos função/entrada/saída,
gráficos por memória; sem dependências/arquitetura desnecessárias.

Ao concluir: monte/teste o possível com evidências reais; explique mudanças/fluxo/rotinas;
distinga execução, inspeção e teste físico; atualize 14 e documentos/decisões afetados;
liste exatamente minha ação pendente e ajuste a retomada E08 ou o prompt E09 conforme estado.
Pare nesta etapa. Não inicie E09 automaticamente.
```
