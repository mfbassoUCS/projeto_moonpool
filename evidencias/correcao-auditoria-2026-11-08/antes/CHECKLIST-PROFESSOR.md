# Checklist para testar jogando

Revisado em **08/11/2026**. Este é o roteiro para você jogar, observar e anotar. **Não precisa contar pixels, conhecer Assembly ou medir a velocidade dos objetos.**

As medidas e a conferência do código estão na [cópia técnica preenchida](CHECKLIST-PROFESSOR-VERIFICADO.md), com os 115 requisitos e os resultados da auditoria de 07/11. Os IDs entre parênteses abaixo permitem localizar o requisito nessa cópia. Reunimos passos relacionados para evitar testes repetidos.

**Aqui as caixas começam vazias porque a rodada com seu teclado ainda não foi registrada.** As marcações técnicas não significam que você já jogou esses testes.

## Como preencher

- Marque **[x]** quando fizer o passo e observar o resultado descrito.
- Se der diferente, deixe vazio e anote **F — falhou**, com o que aconteceu.
- Se não conseguir testar ou o objeto não aparecer, deixe vazio e anote **NT — não testado**. Não precisa ficar tentando indefinidamente.
- Pode dividir em várias partidas. Só conclua uma caixa depois de conferir todos os comportamentos nela; anote o que faltou.

Você vai avaliar aparência, resposta das teclas, facilidade de jogar, pontuação e fim de partida. Tamanhos, distâncias exatas, cores numéricas e regras internas ficam na cópia técnica. **A pendência do ponto mais alto do salto (J07) e a atualização dos testes automáticos são trabalho técnico; não tente resolvê-las olhando a tela.**

| Onde está | Teclas |
|---|---|
| Menu | ↑/↓ escolhem; Enter confirma. |
| Tela SETOR 1 | Enter começa a partida. |
| Partida | ←/→ movem; ↑ salta; Espaço dispara para cima e para a frente. |
| Depois de um salto | Solte ↑ antes de apertar novamente. |
| GAME OVER | Uma tecla volta ao menu. |
| Para sair | No menu, selecione Sair e Enter. Não há saída por Esc durante a partida. |

## 1. Abrir e começar

- [ ] Anote **data, seu nome e computador**. Use esta pasta do projeto e a mesma configuração durante a rodada. (P01)
- [ ] Abra `ABRIR-GUI.cmd`, confira que está com `MOON.ASM`, escolha **Turbo 16-bit** e use **Assemble → Build → Run**. A montagem não deve mostrar erros. Para os detalhes, consulte o [README](README.md). (P02)
- [ ] Clique na janela do jogo e confirme que ↑/↓ respondem. Use seu teclado. Deixe disponível um celular para anotar/fotografar uma falha; o cronômetro só será necessário no teste de tempo ao final. (P03, P04)

Data: __________  Testador: __________  Computador: __________

Configuração usada, se souber: __________

## 2. Menu e entrada na partida

- [ ] O título **Moon Patrol** está no alto, verde-claro e legível. Há um jipe e três naves entre o título e as opções. (M01, M03)
- [ ] Deixe o menu animando: os quatro desenhos vão para a direita e reaparecem à esquerda. Observe cada desenho voltar duas vezes, sem deixar restos na tela. (M04)
- [ ] **Jogar** e **Sair** aparecem dentro de caixas com bordas inteiras. ↑/↓ mudam a seleção; a selecionada fica vermelho-claro e a outra branca. A animação continua. (M05–M08)
- [ ] Enter em **Jogar** abre **SETOR 1**. Espere um pouco nessa tela; depois pressione Enter e confira que a partida começa. (M09, F01)
- [ ] Na partida, a pontuação (**score**) fica à esquerda, as vidas no centro e o tempo à direita. Céu/naves, relevo e pista são fáceis de distinguir; o jipe começa apoiado na pista. (F02, F03, H01, J01)

Configuração atual esperada ao começar: **score zero, três vidas e 90 no tempo**. São escolhas do projeto, não números obrigatórios do professor.

## 3. Controles, salto e cenário

Faça os primeiros testes em espaço livre, antes de tentar passar pelos obstáculos.

- [ ] Segure ← e depois →: o jipe vai para o lado correto. Ao soltar, ele para de se deslocar na tela. (J02, J10)
- [ ] Segure ← até o limite: o jipe não sai da tela. Depois segure →: ele para antes de entrar na metade direita. (J03)
- [ ] Mantendo → no limite, o terreno e os obstáculos continuam passando para a esquerda. Solte → e confira que o cenário continua andando. (C04)
- [ ] Aperte ↑ sem andar: o jipe sobe, fica brevemente no alto e volta à pista, sem ficar preso no ar. Solte e aperte de novo: outro salto funciona. (J05, J09, J10)
- [ ] Repita o salto andando para a direita, para a esquerda e perto dos dois limites. O movimento lateral continua no ar; o jipe não muda de tamanho e termina o salto. Isso não garante vencer um obstáculo se saltar tarde demais. (J01, J05, J09)
- [ ] Segure ← e → juntas: o jipe fica parado na tela. Solte uma: ele responde à outra. Solte ambas: não fica uma direção “presa”. (J10)
- [ ] Combine direção + ↑ + Espaço: deve ser possível mover, saltar e atirar juntos. Depois solte tudo e veja se alguma ação continua indevidamente. (J10, T09)
- [ ] O relevo tem variações, a pista é plana e amarela, e o chão entra pela direita e sai pela esquerda. Observe o relevo se repetir duas vezes: não deve surgir lacuna, emenda brusca ou pausa. Rochas e crateras acompanham o terreno. (C01, C03, C05–C07)
- [ ] Enquanto joga e atira, não aparecem restos dos desenhos, retângulos apagados ou números corrompidos. Anote se o jogo parece lento, dá trancos ou pisca a ponto de atrapalhar. (C08)

Se não sobreviver tempo suficiente para observar duas voltas do relevo, anote NT nessa parte. O teste técnico de rolagem já tem evidência; dificuldade de sobreviver não é falha automática do cenário.

## 4. Crateras, rochas e pontuação

Para reconhecer os tipos, abra o [catálogo dos desenhos](artes/previas/catalogo.png). Cratera é o buraco na pista; rocha é o obstáculo sobre ela. A comparação de tamanho exato fica na cópia técnica.

**Dica:** comece a saltar antes de encostar, usando ↑ junto com → e deixando espaço para avançar. Se já estiver no limite direito, recue antes da próxima tentativa. O ajuste de velocidade mudou o momento certo do salto.

Para conferir pontos, anote o score antes e depois de **um evento isolado**. Evite acertar uma nave ao mesmo tempo. No salto, espere o jipe pousar em segurança: o prêmio é aplicado nessa etapa.

- [ ] Ao longo de algumas partidas, reconheci os três desenhos de cratera entrando pela direita. Se faltar algum, anote qual; o sorteio pode repetir. (O01)
- [ ] Saltei uma cratera, pousei do outro lado sem perder vida e ganhei **50 pontos uma única vez**. (O04, O06)
- [ ] De propósito, alcancei uma cratera sem saltar: perdi uma vida. Em outra tentativa, pousar ainda sobre o buraco também causa perda de vida. (O05)
- [ ] A cratera que causou minha morte não deu pontos pela travessia. Não apareceu prêmio apenas por um obstáculo sair da tela sem ter sido superado. Se não conseguir separar os eventos, anote NT. (O07)
- [ ] As rochas aparecem entre crateras, acompanham o terreno e não ficam dentro dos buracos. (R01, R03)
- [ ] Saltei a **rocha 1**, pousei em segurança e ganhei 50 pontos. (R04)
- [ ] Saltei a **rocha 2**, pousei em segurança e ganhei 50 pontos. (R04)
- [ ] Saltei a **rocha 3**, pousei em segurança e ganhei 50 pontos. (R04)
- [ ] Saltei a **rocha 4**, pousei em segurança e ganhei 50 pontos. (R04)
- [ ] Encostar numa rocha, inclusive ao cair sobre ela, faz o jipe desaparecer e custa uma vida. O score permanece legível e não fica subindo sozinho depois de um prêmio pelo mesmo obstáculo. (R05, H05, R11)

Tipos que não apareceram: __________

Se os saltos parecerem impraticáveis após várias tentativas, anote a direção, o tipo de obstáculo e se estava no limite. Isso é informação útil de jogabilidade, mesmo havendo saltos automáticos aprovados.

## 5. Naves e tiros

Os tiros são complementares ao mínimo do professor, mas fazem parte desta versão e devem funcionar.

- [ ] As naves entram pela direita, seguem para a esquerda sem mudar de altura e saem pela esquerda. Ficam abaixo da barra de informações e acima do relevo, sem se sobrepor. (N02, N07–N09)
- [ ] Vi grupos de **uma, duas e três naves**. Dentro de cada grupo, os desenhos são do mesmo tipo. Entre grupos, vi os três tipos e posições diferentes. Anote os que faltarem; não espere alternância obrigatória. (N01, N03–N05)
- [ ] Observei mais de uma troca de grupo: o próximo só começa depois que todas as naves anteriores saem ou são destruídas. Destruir apenas parte do grupo não faz aparecer outro imediatamente. (N10–N12)
- [ ] Um toque em Espaço lança **um tiro amarelo para cima e um vermelho para a frente**, partindo do jipe. Novos tiros não fazem os anteriores mudar de lugar ou sumir sem motivo. (T01, T02, T05, T06)
- [ ] Um tiro amarelo acertou uma nave: ambos desapareceram e o score aumentou **100 pontos uma única vez**. (T03)
- [ ] Sem acertar nada, o amarelo desaparece antes de invadir os números no topo e o vermelho termina à frente do jipe, sem atravessar a tela inteira. Não preciso medir a distância exata. (T04, T07)
- [ ] Atirei no chão, no ar e andando: os tiros saem da posição atual do jipe. Segurar Espaço repete os disparos com intervalo; soltar interrompe novas emissões, mas tiros já lançados continuam. Um toque durante a recarga pode não gerar tiro. (T09, T10)
- [ ] Acertei a **rocha 1** com tiro vermelho: o tiro desapareceu e a rocha permaneceu. (R06, T08)
- [ ] Acertei a **rocha 2** com tiro vermelho: ela desapareceu com um impacto e deu 50 pontos. (R07, R10, T08)
- [ ] Acertei a **rocha 3** com tiro vermelho: ela desapareceu com um impacto e deu 50 pontos. (R08, R10, T08)
- [ ] Acertei a **rocha 4**: primeiro impacto não destruiu nem deu 50; segundo impacto na mesma rocha destruiu e deu 50. Conte acertos visíveis, não apertos de Espaço. O sentido de “consecutivos” ainda precisa do aceite registrado na cópia técnica. (R09, R10, T08)
- [ ] As naves lançam tiros brancos para baixo. Eles desaparecem ao atingir o jipe ou a pista amarela; podem atravessar o relevo decorativo. Consegui reagir e desviar; anote se a velocidade ou lentidão tornam a esquiva consistentemente impraticável. (I01–I04)
- [ ] Um tiro branco que me acertou tirou uma vida; outro que passou ao lado não tirou. Estar saltando não torna o jipe imune. Se não observar o caso no ar, anote essa parte como NT. (I05, I06)
- [ ] Vi uma nave ser destruída ou sair depois de atirar: seu tiro continuou até atingir algo ou a pista. Se não aparecer essa situação, anote NT. (I07)

Grupos/tipos de nave ou rochas que faltam observar: __________

## 6. Perder vidas, encerrar e recomeçar

- [ ] Conferi separadamente perda de vida por **cratera**, **rocha** e **tiro branco**. Em cada evento, o jipe desaparece e o indicador de vidas muda. Anote quais causas faltaram. (H02, V01)
- [ ] Com vidas restantes, o jipe reaparece na margem esquerda. Se ali houver obstáculo ou tiro, pode esperar até a região ficar livre. A morte não zera score/tempo e não reinicia o cenário. (V02, V03)
- [ ] Uma mesma colisão não desconta todas as vidas de uma vez. (V04)
- [ ] Ao perder a última vida, aparece **GAME OVER**, vermelho, em duas linhas no centro, com o score final abaixo. O score corresponde ao que alcancei. (V05, V07, V08)
- [ ] Em um encerramento, apertei uma letra e voltei ao menu; em outro, fiz isso com uma seta. (V09)
- [ ] Iniciei outra partida: score voltou a zero, vidas a três e tempo a 90. Não ficaram tiros ou objetos da partida anterior. (V10)
- [ ] Completei o ciclo **menu → partida → GAME OVER → menu** três vezes, sem teclas presas, desenhos restantes ou cores erradas. (V11)
- [ ] No menu, selecionei **Sair** e Enter: o programa encerrou. Conferi também depois de voltar de uma partida. (M10, V10)

## 7. Tempo — faça em uma rodada separada

Use um relógio comum; não há medição de pixels. Se não conseguir sobreviver até o fim, registre NT para o encerramento por tempo. Não precisa mudar o jogo nem forçar uma aprovação.

- [ ] Com cronômetro ou vídeo, acompanhei o tempo do jogo por um trecho contínuo. Ele diminui regularmente. Anotei quantos segundos passaram no cronômetro e quantos o jogo descontou, inclusive qualquer atraso visível. (H04)
- [ ] Sobrevivi com pelo menos uma vida até o contador chegar a zero e aparecer GAME OVER. Medi desde aparecer a partida até o encerramento e anotei a duração. A configuração atual é 90 segundos; o professor não fixou tolerância para essa medição. (H06, V06)

Trecho: cronômetro ______ s / jogo descontou ______ s.

Partida encerrada por tempo: duração ______ s / vidas restantes ______.

Os testes automáticos confirmaram o encerramento numa partida controlada curta. Eles não foram registrados como uma partida normal completa de 90 segundos.

## Registro de problemas e do que faltou

| ID ou passo | Passou / F / NT | O que fiz e observei | Foto/vídeo, se houver |
|---|---|---|---|
| Exemplo: J10 | F | Segurei direita, saltei e soltei tudo; jipe continuou andando. | — |
| A preencher | | | |

Para uma falha, anote as teclas usadas, se foram mantidas ou soltas, o tipo de alvo, se o jipe estava no limite e score/vidas antes e depois. Não precisa explicar a causa técnica.

## Antes da apresentação — tarefas da equipe

Estas tarefas não são testes de jogabilidade; os detalhes estão na cópia técnica.

- [ ] Confirmamos integrantes, inscrição, data e formato da entrega. (A01, A02)
- [ ] Os dois conseguem explicar o código e a transformação dos desenhos em dados, sem depender do histórico de chat. (Q06, A03)
- [ ] Revimos as pendências técnicas e dúvidas do professor: salto, artes, formação das naves, impactos da rocha 4 e ambiente exigido. Não confundimos caixas técnicas marcadas com aprovação final. (J07, N06, R09, Q07, Q08, A04)
- [ ] Apresentamos no GUI Turbo Assembler/Windows e, **somente depois**, submetemos o fonte no canal pedido. (A05, A06)
