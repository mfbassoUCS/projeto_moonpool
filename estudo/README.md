# Começar a entender e separar a entrega

Preparado em 08/11/2026. É possível começar o estudo com o checklist manual aberto. Não é possível garantir antecipadamente que todas as correções restantes serão pequenas: mudanças de salto, colisão ou teclado podem exigir rever explicações e testes. Aprenda primeiro a estrutura; confirme os detalhes na versão que será apresentada.

Em 09/11/2026, o `MOON.ASM` recebeu comentários linha por linha, preservando a numeração e o programa compilado. O [guia dos comentários](COMENTARIOS-LINHA-A-LINHA.md) relaciona as etapas às decisões do código e explica, passo a passo, o `push es` da linha 726.

## O que é o trabalho e o que é apoio

| Arquivo/pasta atual | Papel | Entrega ao professor |
|---|---|---|
| `MOON.ASM` na raiz | Fonte completo: constantes, dados, desenhos e 69 procedimentos | **É o código-fonte a entregar**, conforme a seção Entrega do enunciado |
| `MOON.EXE` | Programa DOS de 16 bits gerado a partir do fonte | Útil para executar; o enunciado fornecido não exige enviar o EXE |
| `MOON.OBJ`, `.LST`, `.MAP`, `MONTAGEM.LOG`, `LINK.LOG` | Produtos e diagnósticos da montagem/link | Não são o fonte; não há exigência de envio no texto fornecido |
| `BUILD.BAT`, `ABRIR-GUI.cmd`, `EXECUTAR-E*.cmd` | Atalhos de montagem e execução | Apoio local; não fazem parte da lógica do jogo |
| `ferramentas/` | IDE, emulador, montador e configurações | Ambiente de desenvolvimento/apresentação; não incluir automaticamente no envio |
| `artes/` | Gerador, dados editáveis e prévias dos desenhos | Material de produção; os desenhos necessários ao jogo já estão no ASM |
| `testes/`, `evidencias/` | Verificações, versões antigas e registros | Apoio à revisão; os ASM destas pastas não são o jogo a entregar |
| Markdown da raiz e `planejamento/` | Requisitos, decisões, estudo, instruções e histórico | Documentação de apoio; não existe exigência geral de enviar todos esses arquivos |
| `estudo/` | Orientação e cópia portátil para tutoria | Material de aprendizagem, não uma segunda versão oficial |

Os Markdown não são apenas conversas: preservam regras e motivos que ajudam a dupla a explicar o programa. Já os comentários dentro do próprio `MOON.ASM` **fazem parte da exigência do professor**: cada rotina precisa de função, entradas e saídas. Documentação externa não substitui isso.

O enunciado exige apresentar no GUI Turbo Assembler/Windows e submeter o código-fonte **somente depois da apresentação**. Não define, no material disponível, nome do ZIP, formato de upload, relatório ou inclusão do EXE. Conferir esses detalhes na tarefa da disciplina antes do envio. Não se trata de pedir autorização para estudar.

## Separação no diretório

Mantemos `MOON.ASM` como única fonte de trabalho na raiz. Mover agora código, lançadores, testes e ferramentas exige ajustar referências e caminhos absolutos. Essa reorganização não é necessária para aprender e pode atrapalhar a execução existente.

A pasta `estudo/` reúne o material para levar ao celular/outro chat. Quando a versão final estiver validada e apresentada, preparar uma pasta ou ZIP de entrega com uma cópia atual do `MOON.ASM` e apenas os complementos exigidos na tarefa. Não criar agora uma cópia chamada “final” que possa ficar desatualizada.

## Etapas de aprendizagem

Use os encontros detalhados de [ESTUDO-DO-CODIGO.md](../ESTUDO-DO-CODIGO.md). Sessões de 30–45 minutos são uma sugestão; divida quando necessário.

| Etapa | Encontros do guia | Resultado que você deve conseguir demonstrar |
|---|---|---|
| 0. Reconhecer os arquivos | Este documento | Distinguir fonte, executável, ferramentas e documentação |
| 1. Entender o programa inteiro | 1 | Explicar `inicio`, o laço principal e menu → setor → partida → fim |
| 2. Aprender o Assembly usado | 2 e 3 | Simular registradores, memória, pilha, `CALL/RET`, comparações e flags |
| 3. Entender como aparece na tela | 4 e 5 | Calcular `y*320+x`, explicar bitmap, transparência, rolagem e redesenho |
| 4. Entender tempo e controles | 6 e 7 | Distinguir relógio, cadência e entrada; explicar teclas simultâneas e IRQ |
| 5. Seguir as regras do jogador | 8 e 9 | Simular salto, colisão, perda de vida, reposição e +50 sem repetição |
| 6. Seguir inimigos e tiros | 10 e 11 | Explicar sorteio, grupos, listas de projéteis, impactos e +100 |
| 7. Integrar e apresentar | 12 e guia de apresentação | Traçar uma jogada inteira pelo código e responder perguntas sem decorar |

Para aprofundar cada rotina, explique: quem chama; entradas; instruções e desvios; saída; registradores e flags; efeito na memória/tela; caso normal; caso de limite; requisito atendido. Use uma tabela de valores para acompanhar a execução. Ambos os integrantes devem conseguir fazer isso, mesmo dividindo a fala.

Não comece lendo milhares de valores de cores. Entenda a estrutura dos bitmaps e acompanhe um sprite pequeno; depois explique como a mesma rotina lê os demais. Não é necessário decorar cada byte da montanha. A compreensão detalhada deve se concentrar nas instruções, dados usados por elas e decisões do programa.

## Estudar em outro chat ou pelo celular

1. Salve `pacote-estudo.zip` no celular e extraia. Ele contém o fonte em TXT, contexto, prompt, guia, mapa e enunciado.
2. Anexe `MOON-PARA-LEITURA.txt`, `CONTEXTO-PARA-CHAT.md` e `ESTUDO-DO-CODIGO.md`. Acrescente mapa/enunciado quando for localizar rotinas ou conferir requisitos. Se o aplicativo aceitar abrir ZIP, pode enviar o pacote, mas peça que confirme a leitura dos arquivos.
3. Cole [PROMPT-TUTOR.md](PROMPT-TUTOR.md). Comece pelo encontro 1 e faça perguntas sequenciais. O tutor não precisa acessar este computador.
4. Ao encerrar, peça um resumo de aprendizagem e salve-o numa nota. Leve esse resumo ao próximo chat junto da mesma versão do fonte.
5. Se o jogo mudar, gere novamente o pacote a partir da raiz e atualize os trechos estudados. Não misture explicações de hashes diferentes sem comparar a mudança.

O TXT é uma cópia integral dos bytes do `MOON.ASM`, apenas com outra extensão para facilitar anexar. **Não editar essa cópia para desenvolver o jogo.** O ZIP é um retrato desta sessão, sem atualização automática. O contexto informa seu SHA256. Os links dos documentos copiados podem apontar para arquivos do repositório que não estão no pacote; o tutor deve pedir o trecho faltante, não inventá-lo.

O checklist físico segue separado e pendente. Aprender o código não prova que o jogo foi testado; jogar com sucesso também não prova domínio do Assembly.
