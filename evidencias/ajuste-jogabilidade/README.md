# Evidências dos ajustes — 07/11/2026

Contexto, resultados e limites em [AJUSTES-JOGABILIDADE](../../AJUSTES-JOGABILIDADE.md). `ANTES.ASM`, `desenhos-antes.json`, `gerar-artes-antes.py`, `relevo-antes.png` e `e08-antes.conf` preservam a versão recebida antes de modificar. Não sobrescrever esses arquivos para repetir um ensaio.

## Arquivos

- `ENSAIO.LOG`: montagem e execução comparativa.
- `ANTAUTO.CPU`, `ANTFAST.CPU`, `NOVFAST.CPU`: CPU efetiva. Apesar do nome ANTAUTO histórico do auxiliar, o ensaio final usa **3.000 ciclos fixos**, explicitamente registrados; os demais usam 50.000.
- `*S.BIN`: 854 resultados de travessias, um byte por caso. Ordem: fase 0/1, tipo 0..6, distância 0..60.
- `*T.BIN`: tempo de 40 composições em centésimos, inteiro de 32 bits little endian.
- `medidas.json`: interpretação/conferência dos dados e hash atual.
- `regressao-primeira.log`, `regressao-segunda.log`, `debug-fluxo.log`: falhas anteriores preservadas, não aprovadas.
- `regressao-final.log`, `montagem-final.log`, `link-final.log`: execução final aprovada.
- `pixels/`: imagens reconstruídas dos dumps reais da execução; não são filmagem nem teste humano.
- `fonte-final.sha256`: identidade da versão validada.

## Reproduzir

Na raiz, `python testes/avaliar-jogabilidade.py` gera JOLD/JNEW e ENSAIO.BAT. Rodar o emulador do pacote com `-conf evidencias/ajuste-jogabilidade/ensaio.conf`, esperar terminar e executar `python testes/avaliar-jogabilidade.py --conferir`. O uso de `Z:\CONFIG.COM` e a validação dos arquivos `.CPU` são obrigatórios; sem isso não considerar a comparação de CPU válida.

Para regressão: `python testes/avaliar-jogabilidade.py --regressao`, rodar com `-conf evidencias/ajuste-jogabilidade/regressao.conf` e conferir `testes/AJUSTE.LOG` sem FAIL, terminando em PASS AJUSTE. Depois `python testes/conferir-e08.py --pixels --saida evidencias/ajuste-jogabilidade/pixels` verifica todos os bytes renderizados. Conferir hash E08-FONTE e logs TASM/TLINK. As variantes geradas em testes são auxiliares; a fonte normal continua MOON.ASM.

Executar sequencialmente, sem duas suítes simultâneas gravando os mesmos resultados. As configurações de ensaio contêm o caminho local C:\ucs\moon_patrol. Os arquivos `host-out/err` são diagnóstico de tentativas iniciais de abertura, não prova de regressão aprovada.
