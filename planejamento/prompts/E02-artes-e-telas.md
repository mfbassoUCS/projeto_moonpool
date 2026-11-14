# Prompt de retomada E02 — validar artes próprias e telas

Copie o bloco abaixo para um novo chat neste repositório, quando chegar a esta etapa. Consulte o andamento atual antes de executar; este arquivo não comprova conclusão das etapas anteriores.

```text
Vamos retomar somente a validação da E02 (artes e telas) do Moon Patrol.

Leia planejamento/README.md, planejamento/01-contexto-e-regras.md,
planejamento/03-medidas-e-constantes.md, planejamento/05-pendencias-e-decisoes.md,
planejamento/06-roteiro-de-execucao.md e planejamento/14-andamento.md.
Leia também, dentro de planejamento/: 08-etapa-artes-e-telas.md e 04-referencias-visuais.md.
Inspecione o fonte atual, os scripts de montagem e os testes existentes antes de editar.
Use o enunciado original para conferir dúvidas; não refaça etapas já concluídas.

Parta do MOON.ASM atual, que já inclui E03; leia LEIA-E02.md como histórico e LEIA-E03.md para o fluxo atual, além de artes/README.md, artes/referencias/README.md e testes/README.md. As bases históricas estão em testes/E01BASE.ASM e testes/E02BASE.ASM. O ambiente está em ferramentas/guitasm (GUI Turbo Assembler 5.1, TASM 4.1 e TLINK); confira BUILD.BAT, EXECUTAR-E03.cmd e ferramentas/e03.conf antes de usar. Já existem menu, jipe/três naves animados, SETOR 1, cenário/HUD com relógio e GAME OVER. Não refaça essas partes nem trate a base como jogo pronto.
D18 foi encaminhada em 25/10/2026: o aluno autorizou referências do arcade e artes próprias, sem cópia. Não volte a exigir imagens originais como pré-condição. Os bitmaps são autorais, não reproduções do arcade/professor; não invente fidelidade.
As 17 artes estão implementadas: jipe 20x10; três naves 14x14; vidas 18x11 (3/2/1); relógio 7x8; três crateras 14x7; quatro rochas 12x10; montanhas 320x64 e montes 320x32. O relevo e o HUD já são usados pela E03. Grades em artes/desenhos.json; gerador/conversor em artes/gerar-artes.py; prancha em artes/previas/. Confira o resultado do teste físico e o feedback visual do aluno; ajuste somente o necessário. Preserve o título TAAG Mini, caixas e navegação.
Preserve GAME/OVER em duas linhas, cor 04h e interface EntrarGameOver(AX=score). D04 está registrada como proposta técnica SETOR 1 com Enter, sem confirmação do professor. A E03 transmite scorePartida ao fim do tempo. Não restaure o salto demonstrativo para 12345; ele só existe no snapshot histórico E02. Preserve cenário e relógio ao revisar artes/telas.
O desenho ainda rejeita retângulos parciais e volta inteiro a X=0. Vários objetos já usam restaurar todos -> capturar todos os fundos limpos -> desenhar todos. Essa estratégia foi testada sobre fundo estático, inclusive com sobreposição; não é solução validada para cenário rolando.
Os testes automatizados de 25/10 passaram para memória, 400 quadros, navegação, 320 quadros por ticks, cores, score e saída. ARTES.BIN e GALERIA.RAW foram comparados com as grades. Se alterar artes, regenere seus bytes e os testes afetados; não repita implementação concluída. Registre o teste físico e a aprovação visual efetivamente recebidos; não confunda buffer BIOS com teclado físico. Não implemente cenário rolando, jipe jogável, obstáculos ou naves da partida.

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

