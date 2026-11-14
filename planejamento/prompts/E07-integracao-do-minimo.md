# Prompt de retomada E07 — validação física do mínimo e ajustes

E07 integrada e verificada automaticamente em 31/10/2026. A validação física para apresentação permanece pendente. Use este prompt para registrar testes manuais e corrigir defeitos; não recrie etapas prontas nem inicie E08 automaticamente.

```text
Vamos retomar somente a E07 (integração do mínimo) do Moon Patrol para validar as pendências e corrigir o necessário.

Leia planejamento/README.md, planejamento/01-contexto-e-regras.md,
planejamento/03-medidas-e-constantes.md, planejamento/05-pendencias-e-decisoes.md,
planejamento/06-roteiro-de-execucao.md e planejamento/14-andamento.md.
Leia também, dentro de planejamento/: 02-requisitos-e-escopo.md e 13-validacao-e-entrega.md.
Inspecione o fonte atual, os scripts de montagem e os testes existentes antes de editar.
Use o enunciado original para conferir dúvidas; não refaça etapas já concluídas.

Leia LEIA-E07.md, testes/README.md e os relatórios em evidencias/e07/:
verificacao.txt, regressao-naves.txt e regressao/verificacao.txt.
A matriz T01–T20 já distingue execução automática, inspeção e pendências físicas.
O mínimo está integrado e passou na suíte; não o declare totalmente validado para
apresentação enquanto faltarem os testes físicos. Não refaça artes ou regras E02–E06.

D04 adotada tecnicamente: SETOR 1, objetivo e Enter para iniciar, sem avanço automático
ou consumo de tempo no setor. Relógio inicia após o primeiro quadro. Avisos de etapa
e mecanismo de demonstração removidos. Game Over recebe score real; letra/seta volta.
Não houve confirmação do professor sobre conteúdo/duração/tecla do setor.

Pendentes: Assemble/Build/Run no fonte atual, teclado físico (mantidas/simultâneas/
soltura, ↑ no pouso/morte), conforto da janela estreita das rochas, fluidez/rasgos,
observação das naves/terreno e comparação externa dos 90 s normais. Siga LEIA-E07.
Registre o relato do aluno; não trate BIOS/scans/dumps como teclado físico.
Se houver defeito, reproduza, corrija só o necessário e execute os testes afetados.
Não repita toda a suíte sem motivo nem substitua pendência de teste por nova mecânica.

Passagem técnica preservada:
- Naves 14x14, grupos 1..3 do mesmo tipo; D06 faixa de formação [320,480), primeira
  origem 320..335; D07 >=30 livres entre bordas; D09 Y=15..86 fixo. Tipos podem repetir.
- Naves 1 px/2 ticks; jipe 3 px/1 tick. Ativas inclusive fora da direita; saída X<=-14.
  Novo grupo só quando não resta ativa. RemoverNave(DI=0/2/4): CF=1 apenas ao remover,
  preserva registradores e não pontua. LCG/byte alto, CX=1..256, semente só na nova partida.
- Céu 15..99 recomposto quando navesMudou, mesmo sem rolagem; sem fundo antigo.
  Parte inferior: cenário -> obstáculos -> captura/jipe. Dados 35.105 bytes; buffers 320/200.
- D05: topo pelo avanço do terreno até cruzar 5 px, amostras 2/4/6; não frames/X líquido.
  Jipe X=0..140, chão=183/topo=168. D14/D15 e reposição em [0,20) livre preservados.
- +50 terrestre somente após travessia e pouso seguro; score satura em 65535.
  Morte preserva relógio/progresso/grupo; Game Over restaura IRQ1.

Reprodução: testes/executar-e07.ps1 seguido de testes/conferir-e07.py, sem simultâneas.
E01–E06 usam snapshots; E07/R07 testam MOON atual. Foram executados 320 quadros de menu
por ticks, espera de 2,03 s no setor, seis dumps de telas, 400 quadros de menu em RAM,
regressão de cenário/salto/vida/score/tempo, 4096 sementes, 48 grupos/394 obstáculos,
390 quadros de naves, 336 terrestres e fluxo real de morte/tempo/reset/saída.
T17–T20 são não aplicáveis ao mínimo; nenhum tiro implementado. Pare nesta retomada,
deixando explícito o que ainda falta validar. Não inicie E08 ou novas fases.

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

