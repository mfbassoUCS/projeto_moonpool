# E09 — revisão rastreável do escopo existente

Revisão de 02/11/2026, conferência final e fechamento técnico em 06/11. Fonte completo E08 revisado na E09; [guia de apresentação](../GUIA-APRESENTACAO.md), [estado e reprodução](../LEIA-E09.md) e [matriz detalhada T01–T20](13-validacao-e-entrega.md). Este documento cruza o enunciado, o fonte e as evidências; não certifica apresentação ou teste físico.

## Requisitos R × fonte × testes

Os nomes de harnesses são os já existentes, reutilizados na E09. Evidências históricas de 01/11 ficam em `evidencias/e08`; as novas ficam em `evidencias/e09`. Os testes não são incorporados ao EXE normal.

| R | Implementação conferida em MOON.ASM | T / evidência e limite |
|---|---|---|
| R01 | `.8086`, small, TASM/TLINK 16-bit | T01; montagem da suíte e ações Assemble/Build/Run na IDE, registro `gui-validacao.md`; apresentação humana pendente |
| R02 | `VIDEO_MODO/SEG`, `PrepararRetangulo`, primitivas de memória | T02; N08MEM/R08REG/R08JIPE/PIX, guardas e inspeção de INT 10h para texto/modo |
| R03 | `arteTitulo`, `EntrarMenu`, `COR_TITULO=0Ah` | T03; TAAG arquivado, N08TELA e captura de Run |
| R04 | quatro tabelas do menu, `MoverSpritesMenu` | T03; N08MEM, 400 quadros e duas voltas, N08TELA 320 quadros |
| R05 | `caixaJogar/Sair`, `DesenharOpcoes`, `LerTeclado` | T03/T15; bytes 218/191/192/217/196/179, 0Ch/0Fh, navegação BIOS; teclado físico pendente |
| R06 | `DesenharStatus`, `AtualizarRelogio`, `SomarPontos` | T05; R08REG/AUTO e E08AUTO; 90 s externos ainda pendentes |
| R07 | bitmaps de vidas 18×11 e relógio 7×8, HUD | T05; dimensões na montagem, regressões HUD/pixels e artes preservadas |
| R08 | três bitmaps 14×14, Y=15..86 | T12; N08LOG/PIX; D09 mantém último pixel ≤99 |
| R09 | `GerarGrupoNaves`, `Sortear`, três vagas | T12; 4.096 sementes, nove combinações, gap livre ≥30; D06/D07 técnicas |
| R10 | `ContarNavesAtivas`, `AtualizarNaves`, `RemoverNave` | T12/T13; N08LOG, E08LOG/AUTO; nova geração somente após zero ativas |
| R11 | `DispararNaves`, brancos 2×4, `MoverDisparos` | T20; E08LOG/PIX/AUTO; reação/esquiva humana pendente |
| R12 | superior amarelo, `ConferirUmDisparo`, CF imediato/+100 | T17/T18; E08LOG/PIX/AUTO; remoção/linha15/saturação |
| R13 | montanhas desde 100, montes desde 132, base até 192 | T06; relevo de 93 linhas, largura 320, R08REG e artes; D10 técnica |
| R14 | `AvancarCenario`, `ComporLinhaCircular` | T06; duas voltas, offsets 1/319, emenda; percepção de rasgos/fluidez pendente |
| R15 | `PISTA_Y=193`, altura7/cor0Eh, `DesenharCenario` | T06; pista de 320×7 conferida em memória |
| R16 | `AtualizarJipe`, X=0..140, passo3/tick | T07; R08JIPE e N08LOG com comparação jipe/nave; teclado físico pendente |
| R17 | `DispararJipe`, par atômico, frontal4×2/vermelho/50 | T17/T18; 8+8 vagas, origens, alcance relativo; E08KEY é sintético |
| R18 | `AvancarObstaculos`, três crateras14×7 | T09; R08LOG 199 nascimentos; N08LOG 394 intercalados; gap livre150..230 |
| R19 | `AtualizarJipe`, `ContarTopo`, fases e 15/3/5/3 | T08; 80 estados, sete travessias; D05 limiar por terreno, conforto pendente |
| R20 | `ConferirObstaculos`, estados de passagem, +50 | T10; pouso seguro/recuo/morte/saída da tela/ponto único |
| R21 | quatro rochas12×10 e sequência cratera/rocha/cratera | T09; R08LOG/PIX e N08LOG; folgas ≥60 técnicas |
| R22 | `obstImpactos`, `ConferirUmDisparo` | T19; indestrutível/1/1/2 impactos; D11 mesma rocha sem prazo |
| R23 | `PASS_PONTO`, `SomarPontos` | T10/T19; salto OU destruição, saturação e reutilização de vaga |
| R24 | `PerderVida`, `TentarReporJipe`, `TiroNaReposicao` | T11/T20; uma vida por evento, X=0 livre, mundo continua; D14/D15 |
| R25 | fim por zero tempo/vidas, `EntrarGameOver`, retorno/menu | T14/T15; R08AUTO/N08TELA/E08AUTO e ciclo sintético na IDE; tempo normal externo pendente |
| R26 | constantes, 69 cabeçalhos, listas e primitivas comuns | T16; `inspecao.txt`, corpo executável igual à E08, mapa/montagem |
| R27 | `EntrarSetor`, SETOR 1/objetivo/Enter/ajuda | T04; N08TELA espera sem consumir tempo; D04 adotada tecnicamente |
| R28 | regra acadêmica, fora do programa | Inscrição/data, apresentação e submissão posterior dependem do aluno; sem comprovação recebida |

## Achados e alterações

1. **Comentários desatualizados no Assembly:** `inicio` ainda dizia “sem tiros”; o campo de teclas omitia Espaço e `RemoverNave` descrevia impacto futuro. Corrigidos, junto da identificação da revisão e descrição de reinício/pontos. A comparação do fonte removendo comentários confirma que instruções, dados e constantes executáveis são iguais à E08. Não foi identificado defeito funcional que justificasse refatorar o jogo.
2. **Sessão antiga da IDE:** a abertura restaurou uma aba E01. Ela foi fechada sem salvar e MOON.ASM reaberto do disco. A captura `gui-fonte-atual.png` mostra E09 e Turbo 16-bit. O guia alerta para essa condição observada, evitando montar o buffer antigo.
3. **Falha real do auxiliar de execução:** na primeira tentativa, `ReadAllBytes(E08SINAL.BIN)` encontrou compartilhamento exclusivo durante escrita do DOSBox. O executor abortou; `tentativa-01-E08RESUL.LOG` é incompleto e não conta como aprovação. `executar-e08.ps1` agora trata IOException transitória e tenta novamente no próximo polling, preservando timeout e exigência de sinais. A mesma leitura do auxiliar KEY recebeu a proteção. Não se ignoram falhas dos harnesses nem se inventa uma duração.
4. **Relatório fixo na E08:** `conferir-e08.py` passou a aceitar saída/data e identificação E09, encaminhando a pasta às regressões. Os oráculos não foram relaxados. Relatórios E07/E08 preservados por manifesto SHA256; o fonte anterior completo foi salvo byte a byte em E08BASE.

## Revisão técnica

As constantes de jogo, medidas, cores, limites e cadências estão centralizadas; valores de instruções/portas BIOS/DOS e bases aritméticas não são parâmetros novos de jogabilidade. Os números 25173/13849 pertencem ao algoritmo de sorteio explicado no guia. Não foram renomeados dados ou refeitas artes para aumentar artificialmente a revisão.

Montagem `.8086` com `jumps` do TASM expande saltos longos em instruções compatíveis. DS/ES e índices word foram conferidos; BP não é usado inadvertidamente para endereçar tabelas em SS. Rotinas gráficas compartilham validação, cópia, transparência e recorte. Não há BIOS pixel a pixel. Os 69 procedimentos possuem cabeçalhos imediatamente anteriores, inventariados com linha e contrato.

Preservados: CF imediato de remoção; pontos únicos/saturação; lista de tiros independente; reserva atômica de ambos os canhões; colisão por pixel do trajeto do projétil; sorteio compartilhado; nenhuma nova semente na morte/grupo; recomposição antes de capturar/desenhar jipe. D04/D05/D06/D07/D08/D09/D11/D13/D14/D15 continuam técnicas, com a autorização específica do aluno para escolher D05 já registrada.

## Limites e problemas conhecidos

- **Validação humana incompleta:** sem resultado físico novo registrado, continuam teclado real/simultâneas/solturas, conforto da janela de salto de rochas, reação aos brancos, fluidez/cintilação/rasgos e sessão normal de 90 s com cronômetro externo. Pergunta sobre resultados posteriores a 01/11 foi enviada; ausência de resposta não é aprovação.
- **Duração:** a expiração curta DOS/Windows e os resets de 90 s são testes distintos de sobreviver 90 s em uso normal. Carga do host pode atrasar desenho e relógio emulado; a discrepância histórica E04 permanece documentada. Suspensão/ajuste manual de hora/intervalo ≥24 h não estão validados.
- **Convenções relevantes:** D04 setor, D05 referência do topo, D06 metade horizontal, D07 distâncias, D09 limites, D11 consecutivos, D13 parâmetros e D14/D15 reposição/colisão não têm confirmação adicional do professor. Figuras originais ausentes; artes próprias autorizadas pelo aluno em D18. D12 menciona “ambas as plataformas”, mas o enunciado só identifica GUI Turbo Assembler.
- **Sem recursos extras:** uma fase, sem invulnerabilidade, efeitos, níveis, sons ou novos inimigos. Colisão por retângulos pode parecer conservadora perto de pixels transparentes; a implementação e os testes usam a mesma decisão explícita.
- **Ambiente portátil local:** `ferramentas/e08.conf` usa caminho absoluto C:\ucs\moon_patrol. Para outra máquina, abrir o fonte na IDE e ajustar o caminho do atalho/configuração se usar o lançador auxiliar. Não é preciso instalar Python/Pillow para executar MOON.

Código revisado e material preparado são estados diferentes de validação física concluída e de obrigação acadêmica cumprida. Não foi submetido nenhum arquivo à faculdade. A retomada permanece dentro da E09.
