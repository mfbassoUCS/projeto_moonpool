"""Conferencia dos dados novos da auditoria, sem alterar o jogo."""
from collections import Counter
from pathlib import Path
import hashlib
import json
import struct

OUT = Path(__file__).resolve().parent
ROOT = OUT.parent.parent
meta = json.loads((OUT/'inspecao-estatica.json').read_text(encoding='utf-8'))
assert meta['fonte_sha256'] == hashlib.sha256((ROOT/'MOON.ASM').read_bytes()).hexdigest()
for name in ['N08MEM', 'N08LOG', 'N08TELA', 'SALTOS', 'TOPO']:
    log = (OUT/(name+'.LOG')).read_text()
    assert 'Error messages:    None' in log and 'Warning messages:  None' in log
    if name.startswith('N08'):
        assert 'PASS' in log and 'FAIL' not in log

groups = list(struct.iter_unpack('<13H', (OUT/'N08GER.BIN').read_bytes()))
assert len(groups) == 4096
counts = Counter()
ys = set()
gaps = []
for expected_seed, (seed, count, kind, *rest) in enumerate(groups):
    xs, yy, active = rest[:3], rest[3:6], rest[6:9]
    assert seed == expected_seed and 1 <= count <= 3 and 0 <= kind <= 2
    assert active == [1]*count + [0]*(3-count)
    counts[count, kind] += 1
    assert 320 <= xs[0] <= 335
    for i in range(count):
        assert 320 <= xs[i] and xs[i]+14 <= 480
        assert 15 <= yy[i] <= 86
        ys.add(yy[i])
        if i:
            gaps.append(xs[i]-xs[i-1]-14)
            assert gaps[-1] >= 30
assert len(counts) == 9 and min(gaps) == 30 and min(ys) == 15 and max(ys) == 86

obstacles = list(struct.iter_unpack('<3H', (OUT/'N08MIX.BIN').read_bytes()))
assert set(row[0] for row in obstacles) == set(range(7))
crater_gaps = []
for i, (kind, x, _) in enumerate(obstacles):
    assert (kind < 3) == (i % 2 == 0)
    if i >= 2 and i % 2 == 0:
        prev, rock = obstacles[i-2][1], obstacles[i-1][1]
        crater_gaps.append(x-prev-14)
        assert 150 <= crater_gaps[-1] <= 230
        assert rock-prev-14 >= 60 and x-rock-12 >= 60

mixed = list(struct.iter_unpack('<13H', (OUT/'N08GRP.BIN').read_bytes()))
for a, b in zip(mixed, mixed[1:]):
    assert b[12]-a[12] == 2*(max(a[3:3+a[1]])+14+1)

raw = (OUT/'SALTO.BIN').read_bytes()
assert len(raw) == 854 and set(raw) <= {0, 1}
windows = []
for phase in range(2):
    windows.append([[gap for gap in range(61) if raw[(phase*7+kind)*61+gap]] for kind in range(7)])
    assert all(windows[-1]), 'Todos os sete tipos devem permitir travessia segura'
trajectory = list(struct.iter_unpack('<6H', (OUT/'TOPO.BIN').read_bytes()))
assert [r[2] for r in trajectory[:5]] == [180, 177, 174, 171, 168]
assert [r[2] for r in trajectory[9:14]] == [171, 174, 177, 180, 183]
assert trajectory[4] == (5, 65, 168, 2, 4, 0)
assert trajectory[8] == (9, 85, 168, 2, 8, 4)
assert trajectory[9] == (10, 90, 171, 3, 10, 5)
lo, hi, sector_lo, sector_hi = struct.unpack('<4H', (OUT/'N08TELA.BIN').read_bytes())
dos_lo, dos_hi, _, _ = struct.unpack('<4H', (OUT/'E08TEMPO.BIN').read_bytes())

# Cores/retorno das telas reais, sem exigir identidade com um fonte antigo.
screens = {name: (OUT/f'N08{name}.RAW').read_bytes() for name in ['INI','MOV','SEL','SET','FIM','RET']}
assert all(len(raw) == 64000 for raw in screens.values())
assert screens['INI'] == screens['RET']
assert screens['INI'][:96*320] == screens['MOV'][:96*320]
assert screens['INI'][110*320:] == screens['MOV'][110*320:]
def colors(screen, x, y, w, h):
    return set(c for yy in range(y,y+h) for c in screens[screen][yy*320+x:yy*320+x+w]) - {0}
assert colors('INI',0,16,320,32) == {10}
assert colors('INI',112,128,88,24) == {12}
assert colors('INI',112,160,88,24) == {15}
assert colors('SEL',112,128,88,24) == {15}
assert colors('SEL',112,160,88,24) == {12}
assert colors('FIM',0,24,320,40) == {4}
assert colors('FIM',0,80,320,40) == {4}

report = dict(fonte_sha256=meta['fonte_sha256'], sementes=4096,
              combinacoes_quantidade_tipo={str(k):v for k,v in sorted(counts.items())},
              grupos_mistos=len(mixed), obstaculos_mistos=len(obstacles),
              gap_crateras_min=min(crater_gaps), gap_crateras_max=max(crater_gaps),
              salto_gaps_seguros_fase_tipo=windows,
              trajeto_colunas=['tick','jipeX','jipeY','estadoSalto','rolagem','pixelsTopo'],
              trajeto=trajectory,
              menu_320_frames_segundos=(hi*65536+lo)/100,
              setor_segundos=(sector_hi*65536+sector_lo)/100,
              fluxo_6s_dos=(dos_hi*65536+dos_lo)/100,
              fluxo_6s_windows=json.loads((OUT/'E08HOST.json').read_text(encoding='utf-8-sig'))['segundos'],
              telas='Cores de titulo/opcoes/fim, faixas estaticas e retorno identico conferidos.',
              ressalva='Variantes controladas; nenhuma aprovacao de teclado fisico ou partida normal de 90 s.')
(OUT/'resultados.json').write_text(json.dumps(report,indent=2,ensure_ascii=False),encoding='utf-8')
print('PASS auditoria: bitmaps/cabecalhos, telas, 4096 sementes,', len(mixed), 'grupos,', len(obstacles), 'obstaculos, 854 tentativas de salto e trajetoria.')
print('Gaps seguros para cratera 1 e rocha 1 por fase:', [(p[0],p[3]) for p in windows])
print('Topo:', trajectory[4:10])
print('Duracoes:', report['menu_320_frames_segundos'], report['fluxo_6s_dos'], report['fluxo_6s_windows'])
