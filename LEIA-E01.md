# E01 — primeira base executável

**Documento histórico da E01.** Desde 24/10/2026, MOON.ASM contém a E02 parcial; consulte [LEIA-E02](LEIA-E02.md) para o programa atual. A base descrita abaixo foi preservada, sem alterações, em testes/E01BASE.ASM. O atalho EXECUTAR-E01 monta o fonte atual, não restaura a demonstração antiga.

Esta versão contém somente uma demonstração técnica. Não contém menu, jipe, terreno do jogo, pontuação ou partida. O quadrado amarelo é um bitmap de teste, não uma arte definitiva.

## Abrir, montar e executar

O ambiente 5.1 foi extraído localmente em `ferramentas/guitasm`, sem instalação global. No Windows, dê duplo clique em **`ABRIR-GUI.cmd`** para abrir o editor com o fonte. A abertura do editor em Turbo 16-bit foi conferida.

O caminho efetivamente testado para montagem e execução foi o comando utilizado por **`EXECUTAR-E01.cmd`**: abre o emulador incluído, monta as pastas e executa `BUILD.BAT`. Confira `MONTAGEM.LOG` e `LINK.LOG`; no prompt `C:\>`, digite **`MOON`** e pressione Enter. Esc sai da demonstração; `exit` fecha o emulador. A configuração `ferramentas/e01.conf` contém o caminho absoluto `C:\ucs\moon_patrol`; ajuste-o se mover o projeto.

O fluxo pelos três botões da IDE também foi executado em 24/10/2026: **Assemble**, **Build** e **Run**, nessa ordem. O log está em `evidencias/gui-fluxo-24.log`. Na barra de ferramentas, são os três botões consecutivos imediatamente antes do ícone do inseto: montagem (seta verde com zeros/uns), link e execução (triângulo verde). Passe o mouse para conferir a descrição.

1. Abra o GUI Turbo Assembler e selecione **Turbo 16-bit** (não TASM32/TLINK32).
2. Abra `C:\ucs\moon_patrol\MOON.ASM`. O nome curto evita problemas com nomes longos no DOS. O fonte usa ASCII e sintaxe compatível com TASM.
3. Use as ações de montar (**Assemble**), vincular (**Build**) e executar (**Run**) da versão instalada. Confira o log após cada ação; não execute um EXE antigo se a montagem falhar.
4. O equivalente no DOS, com TASM e TLINK disponíveis, é:

```bat
tasm /l MOON.ASM
tlink MOON.OBJ
MOON.EXE
```

Não use `/t`: esta versão é EXE com `.model small`, não COM. Arquivos esperados: `MOON.OBJ`, `MOON.LST` (com `/l`), `MOON.EXE` e possivelmente `MOON.MAP`. Windows de 64 bits não executa diretamente um EXE DOS: use o DOSBox do ambiente.

O pacote oficial é distribuído em [SourceForge](https://sourceforge.net/projects/guitasm8086/files/); o [repositório do autor](https://github.com/ljnath/GUI-Turbo-Assembler) descreve TASM, TLINK e DOSBox incluídos. Os nomes/atalhos exatos das ações dependem da versão; não é preciso adivinhar teclas de função.

## O que observar

- Tela azul, uma faixa ciano horizontal e um quadrado amarelo que atravessa essa faixa da esquerda para a direita.
- Texto com contador de segundos, que muda mesmo sem pressionar teclas.
- Quatro pixels brancos nos cantos e um pixel amarelo em `(100,10)`.
- O quadrado volta para a esquerda depois de chegar à direita. A faixa e o azul reaparecem sem rastros.
- **Esc** sai, restaura modo e página de vídeo anteriores e devolve o controle ao DOS. O conteúdo antigo da tela não é guardado.

## Como o fonte funciona

### Dados e segmentos

`.8086` pede ao montador o conjunto de instruções do 8086. `.model small` organiza um segmento de código e um de dados. `.stack 100h` reserva 256 bytes para a pilha, usada por chamadas e `push`/`pop`. `DS` aponta para os dados; `ES` aponta para `A000h`, onde fica a memória gráfica do modo 13h.

Um segmento e um deslocamento formam um endereço. No modo real, o endereço físico é `segmento × 16 + deslocamento`. Assim, `A000h:0000h` corresponde a `A0000h`. Cada pixel ocupa um byte com o índice da cor. A linha seguinte começa 320 bytes depois. Para `(x,y)`, o deslocamento é `y × 320 + x`; `(100,10)` resulta em 3300, ou `0CE4h`. O último pixel é o deslocamento 63999, ou `F9FFh`.

### Entrada, saída e teclado

`inicio` prepara DS, guarda modo/página de vídeo, ativa 13h e define ES. `INT 10h` muda o modo; não desenha gráficos pixel a pixel. `LerTeclado` consulta o buffer com `INT 16h/AH=01h`. Só chama a leitura `AH=00h` quando existe tecla, evitando parar a animação. Esc muda `estado` de demonstração para saída. Estados de menu/setor/partida/fim ficam para suas etapas, sem código vazio antecipado.

### Desenho e ocultação

`DesenharFundo` usa `REP STOSB`: repete CX vezes a gravação da cor AL em ES:DI. `CLD` faz os endereços avançarem. Os marcadores usam `ES:[DI]`, um acesso indireto.

`PrepararRetangulo` verifica largura, altura e posição antes de multiplicar. Rejeita o retângulo inteiro se qualquer parte sair da tela. Isso evita escrita fora dos 64000 bytes visíveis; ainda não há recorte de sprites entrando parcialmente na tela.

`DesenharBitmap` recebe AX=x, BX=y, CX=largura, DX=altura e DS:SI=origem. ES precisa conter A000h. `REP MOVSB` copia uma linha de DS:SI para ES:DI, depois pula `320-largura` bytes no destino. Todos os índices, inclusive zero, são opacos. O chamador deve fornecer um bitmap completo que não atravesse o fim do segmento de dados.

`SalvarFundo` recebe os mesmos parâmetros, mas DS:SI aponta para o buffer de destino. Copia o vídeo para esse buffer por endereçamento indireto. Para ocultar, `MoverTeste` usa o próprio `DesenharBitmap` com o fundo salvo. Só depois muda a posição, captura o novo fundo e desenha novamente. O buffer ocupa apenas 64 bytes. Essa estratégia atende ao único objeto sobre fundo estático da E01; objetos sobrepostos e cenário rolando precisarão de uma política própria na etapa pertinente.

`call` chama uma rotina e guarda na pilha o endereço de retorno; `ret` retorna ao chamador. `push` salva um registrador e `pop` recupera seu valor. Os cabeçalhos dizem o que cada rotina recebe, entrega e altera. Nas rotinas de bitmap, os registradores são preservados; as flags não são uma saída pública de sucesso. O auxiliar `PrepararRetangulo` usa a flag CF para indicar área inválida.

### Movimento e segundos

O movimento consulta os ticks do BIOS por `INT 1Ah/AH=00h`, cerca de 18,2 por segundo. `TICKS_MOVIMENTO=2` dá aproximadamente 110 ms entre passos de dois pixels. O programa usa a diferença do contador de 16 bits, suficiente para consultas frequentes. Na meia-noite pode acontecer um passo imediato pela reinicialização do contador do BIOS. Não há recuperação de todos os movimentos perdidos após uma pausa longa.

Separadamente, `AtualizarTempo` consulta `INT 21h/AH=2Ch`: DH contém o segundo atual do relógio DOS. A diferença entre leituras incrementa `segundos`, tratando a passagem 59→0. Teclas e frames não contam como segundos. A consulta deve ocorrer ao menos uma vez por minuto; pausas longas no depurador não são contabilizadas integralmente. O primeiro incremento pode ocorrer em menos de um segundo, porque a demonstração acompanha a mudança do segundo do DOS. Não é ainda o cronômetro de uma partida. O contador de 16 bits retorna a zero depois de 65535.

`MostrarTempo` divide o número por dez para obter cinco dígitos e escreve texto com `INT 10h/AH=13h`, permitido pelo enunciado. Essa chamada recebe ES:BP como endereço do texto; a rotina salva ES, aponta temporariamente para os dados e restaura ES=A000h antes de retornar.

## Testes manuais de aceitação

1. Montar sem erros e vincular; anotar as versões usadas.
2. Deixar rodar sem teclado por 20 segundos: movimento e contador continuam.
3. Pressionar letras/setas: não devem pausar a demonstração. Esc deve sair.
4. Esperar um ciclo completo (aproximadamente 17 segundos): o quadrado deve alcançar a borda direita e retornar, sem apagar a faixa.
5. Conferir os quatro cantos e o ponto `(100,10)`; em depuração, inspecionar A000:0CE4 e A000:F9FF.
6. Para testar limites via depurador: chamar o desenho de 8×8 em `(312,192)` (válido) e `(313,192)` ou `(312,193)` (inválidos, sem escrita). Largura/altura zero também devem ser rejeitadas.
7. Como experiência separada, mudar `TICKS_MOVIMENTO` de 2 para 4 e remontar: movimento fica mais lento, contador mantém a cadência. Depois restaurar 2.
8. Sair com Esc e executar de novo. Confirmar retorno ao ambiente e reinicialização do contador.

O registro do que foi realmente testado, distinto deste roteiro, fica em `planejamento/14-andamento.md`.

## Resultado da validação em 24/10/2026

Montagem, link e Run pela IDE foram verificados. O fonte final foi montado sem erros nem avisos. Os testes em `testes/` passaram para retângulo no canto inferior direito, oito entradas inválidas, restauração do fundo, direção de cópia, teclado vazio/letra/seta/Esc e restauração de modo 03h/página 0 após saída. As teclas desses testes foram inseridas no buffer do BIOS; tentativas de envio pela automação do Windows não são usadas como evidência de teclado físico.

Duas variantes executadas até o contador chegar a cinco segundos alcançaram x=84 (intervalo de 2 ticks) e x=44 (4 ticks), ambas com contador 5. A diferença não precisa ser exatamente o dobro, porque a leitura dos segundos começa em fases diferentes do relógio. A versão normal permanece com 2 ticks.

A única correção no fonte nesta revisão foi antecipar `CLD` em `DesenharBitmap`: DF agora fica zero também quando a área é inválida, conforme o cabeçalho promete. Isso não muda o desenho normal.

Ao executar pelo botão Run, o lançador está configurado para mostrar `Press any key to exit...` depois que o programa termina; outra tecla fecha a janela. Esse aviso pertence ao ambiente, não ao jogo. A saída da versão normal deve ser feita com Esc; a validação automatizada dessa saída está descrita acima.

Os testes são auxiliares de desenvolvimento: o jogo continua em um único `MOON.ASM`. Consulte `testes/README.md` para reproduzi-los.
