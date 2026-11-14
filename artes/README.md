# Origem das artes — E02

**Atualização de 07/11/2026:** dois bitmaps de relevo foram redesenhados com contornos curvos e sombras menores após o relato do aluno. Medidas, quantidade e 15 sprites pequenos preservados. As descrições históricas abaixo continuam válidas para origem/formato; ver [comparação e testes atuais](../AJUSTES-JOGABILIDADE.md).

Em 25/10/2026, o aluno autorizou consultar o Moon Patrol original e **criar desenhos próprios, sem copiá-lo**. As figuras da disciplina continuam ausentes, mas D18 deixou de impedir a implementação das artes. O fonte agora contém 17 bitmaps autorais, incluindo as duas camadas de relevo; as molduras e reservas transparentes da versão de 24/10 foram substituídas.

`taag.json` guarda a saída real obtida no navegador do TAAG para Moon Patrol (Mini), GAME (Small) e OVER (Small), incluindo os URLs. `taag-*.png` documentam as páginas usadas. A transcrição em `MOON.ASM` preserva os caracteres e completa as linhas com espaços à direita. `testes/conferir-e02.py` compara as duas representações.

`obter-taag.cjs` é um auxílio opcional de criação gráfica. Foi executado com a instalação de Playwright já disponível no computador; recebe o caminho do módulo como argumento. Não é requisito de montagem nem parte do programa DOS. Também é possível reproduzir manualmente cada URL no navegador.

## Desenhos próprios e conversão

- `referencias/README.md`: fontes consultadas e limites de uso; capturas do arcade apenas como referência visual.
- `gerar-artes.py`: desenhos em grades e conversão para linhas DB de índices VGA. Não lê as capturas de referência.
- `desenhos.json`: grades resultantes para inspeção, um caractere por pixel; `.` vira FFh transparente, `0` vira preto opaco e `1`..`F` viram índices da paleta.
- `previas/catalogo.png`: prancha ampliada dos 15 sprites pequenos. `previas/relevo.png`: composição estática das duas camadas. PNGs individuais têm dimensões nativas e transparência.
- `MOON.ASM`: os mesmos pixels já convertidos e incorporados, entre ARTES_INICIO/ARTES_FIM. Não carrega PNG/JSON/Python durante a execução.

Para regenerar somente catálogo e grades: `python artes/gerar-artes.py`. Para também atualizar os dados no fonte: `python artes/gerar-artes.py --aplicar`. O auxiliar requer Pillow no ambiente de criação; o jogo continua exigindo somente TASM/TLINK e o emulador. Uma linha DB corresponde a uma linha de pixels; `DUP` reduz a repetição escrita, mas o montador expande tudo para bytes normais.

Os 17 bitmaps ocupam 32.932 bytes: 2.212 dos sprites pequenos, 20.480 das montanhas 320×64 e 10.240 dos montes 320×32. O relevo tem primeira/última colunas iguais e altura abaixo do máximo de 95; isso prepara os dados, sem implementar ou validar rolagem. As camadas podem ser alinhadas pela base; a composição de prévia sobrepõe os montes aos 32 pixels inferiores das montanhas.

Não há alegação de reprodução das figuras do professor. A escolha de aparência é do projeto, autorizada pelo aluno. Na versão atual, D04 (SETOR 1/Enter) foi adotada tecnicamente na E07, ainda sem confirmação do professor. As descrições de galeria/escopo estático acima registram a E02; para o jogo integrado atual, consultar [README](../README.md) e [LEIA-E09](../LEIA-E09.md).

Em 26/10, a E03 passou a reutilizar esses mesmos bytes no HUD e no cenário rolando; as artes não foram modificadas. Montanhas em y=100, montes em y=132, última linha composta prolongada até 192 e pista em 193..199. A rolagem/emenda agora têm testes próprios, descritos em [LEIA-E03](../LEIA-E03.md). A galeria acima permanece evidência estática da E02, separada dessa validação.
