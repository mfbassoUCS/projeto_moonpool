"""Oraculo externo para dumps A000h e medidas de tempo reais da E04."""
from pathlib import Path
import json
import re
import struct
import hashlib
from PIL import Image

root = Path(__file__).resolve().parent.parent
testes = root / 'testes'
out = root / 'evidencias/e04'
out.mkdir(parents=True, exist_ok=True)
artes = {a['rotulo']: a for a in json.loads((root/'artes/desenhos.json').read_text(encoding='utf-8'))}
source = (testes/'E04BASE.ASM').read_text()
assert hashlib.sha256((testes/'E04BASE.ASM').read_bytes()).hexdigest().upper() in (testes/'E04-FONTE.txt').read_text(), 'Fonte mudou depois da geracao dos testes'
old = (testes/'E02BASE.ASM').read_text()
artblock = lambda s: s.split('; ARTES_INICIO')[1].split('; ARTES_FIM')[0]
assert artblock(source) == artblock(old), 'Artes da E02 alteradas'
palette = [0,0,0,0,0,170,0,170,0,0,170,170,170,0,0,170,0,170,170,85,0,170,170,170,
           85,85,85,85,85,255,85,255,85,85,255,255,255,85,85,255,85,255,255,255,85,255,255,255] + [0]*720
frames = {}
for name in ['INI','EMEN','VOLTA','DOIS','VID2','VID1','VID0','FIM','J0','J1','J2','J3']:
    data = (testes/f'E04{name}.RAW').read_bytes()
    assert len(data) == 64000
    assert max(data) < 16
    frames[name] = data
    im = Image.frombytes('P',(320,200),data)
    im.putpalette(palette)
    im.save(out/f'{name.lower()}.png')

def scenario(offset):
    expected = bytearray(320*100)
    for y in range(100,193):
        for x in range(320):
            col = (x+offset) % 320
            c = artes['bitmapMontanhas']['linhas'][min(y-100,63)][col]
            if c != '.': expected[(y-100)*320+x] = int(c,16)
            if y >= 132:
                c = artes['bitmapMontes']['linhas'][min(y-132,31)][col]
                if c != '.': expected[(y-100)*320+x] = int(c,16)
    expected[93*320:] = bytes([14])*(7*320)
    return expected

# Composicao independente: grades autorais + coordenadas exportadas no DOS.
jipe = artes['bitmapJipe']
assert (jipe['largura'],jipe['altura']) == (20,10)
positions = {}
for name in frames:
    if name == 'FIM': continue
    x,y,offset,topo = struct.unpack('<4H',(testes/f'E04{name}.POS').read_bytes())
    positions[name] = (x,y,offset,topo)
    assert 0 <= x <= 140 and 168 <= y <= 183
    expected = scenario(offset)
    for row,line in enumerate(jipe['linhas']):
        for col,c in enumerate(line):
            if c != '.': expected[(y+row-100)*320+x+col] = int(c,16)
    assert frames[name][32000:] == expected, (name,'cenario e sprite sem rastros')
    assert not any(frames[name][15*320:100*320]), (name,'ceu invadido')
assert positions['INI'] == (0,183,0,0)
assert positions['EMEN'][2] == 318
assert positions['VOLTA'][2] == positions['DOIS'][2] == 0
assert positions['J0'][1] == 183
assert positions['J1'][1] == 180
assert positions['J2'][1] == 168
assert positions['J3'][1] == 171
assert positions['J3'][3] == 5

def crop(data,x,y,w,h):
    return b''.join(data[yy*320+x:yy*320+x+w] for yy in range(y,y+h))

for name,vidas in [('INI',3),('VID2',2),('VID1',1)]:
    a = artes[f'bitmapVidas{vidas}']
    assert (a['largura'],a['altura']) == (18,11)
    expected = bytes(0 if c=='.' else int(c,16) for row in a['linhas'] for c in row)
    assert crop(frames[name],151,2,18,11) == expected
assert not any(crop(frames['VID0'],151,2,18,11)), 'Vidas antigas ficaram na tela'
clock = artes['bitmapRelogio']
assert (clock['largura'],clock['altura']) == (7,8)
expected_clock = bytes(0 if c=='.' else int(c,16) for row in clock['linhas'] for c in row)
for name in ['INI','VID2','VID1','VID0','EMEN','VOLTA','DOIS']:
    assert crop(frames[name],280,3,7,8) == expected_clock
    assert not any(crop(frames[name],0,13,320,2))
# Campo fixo: os zeros e o nove sao comparados aos mesmos glifos BIOS reais.
zero = crop(frames['VID0'],56,0,8,8)
assert any(zero)
for x in [56,64,72,80,88,296,304,312]:
    assert crop(frames['VID0'],x,0,8,8) == zero
for x in [56,64,72,80,296]:
    assert crop(frames['VID1'],x,0,8,8) == zero
nine = crop(frames['VID1'],88,0,8,8)
assert nine != zero
assert crop(frames['VID1'],304,0,8,8) == crop(frames['VID1'],312,0,8,8) == nine
assert {c for c in crop(frames['FIM'],0,24,320,40)}-{0} == {4}
assert {c for c in crop(frames['FIM'],0,80,320,40)}-{0} == {4}

rows = []
for file in ['TEMPOE42.BIN','TEMPOE44.BIN','E04TEMPO.BIN']:
    duration,ticks,steps,lo,hi,first = struct.unpack('<6H',(testes/file).read_bytes())
    elapsed = (hi*65536+lo)/100
    assert duration <= elapsed < duration+0.5
    assert 100 <= first < 150
    rows.append((duration,ticks,steps,elapsed,first/100))
assert rows[0][0] == rows[1][0] == 4
assert 1.6 < rows[0][2]/rows[1][2] < 2.4
assert abs(rows[0][3]-rows[1][3]) < .25
assert rows[2][2] >= 320

# Eventos de escrita observados pelo Stopwatch Windows, agrupados por teste.
host = []
if (testes/'E04HOST.LOG').exists():
    start = None
    for line in (testes/'E04HOST.LOG').read_text().splitlines():
        file,t = line.split()
        t = float(t)
        if file=='E04HOST.BIN' and start is None:
            start = t
        elif file=='E04TEMPO.BIN' and start is not None:
            host.append(t-start)
            start = None
    assert len(host)==3, host
    for actual,row in zip(host,rows):
        assert row[0] <= actual < row[0]+.5, (actual,row)

assert 'PASS E04' in (testes/'E04RESUL.LOG').read_text()
assert 'FAIL' not in (testes/'E04RESUL.LOG').read_text()
for file in ['E04REG.LOG','E04MEM.LOG','E04AUTO.LOG','E04T2.LOG','E04T4.LOG','E04KEY.LOG']:
    log=(testes/file).read_text()
    assert 'Error messages:    None' in log and 'Warning messages:  None' in log
report = ['PASS: artes E02 identicas; 12 dumps reais A000h; cenario e jipe sem rastros;',
          'jipe 20x10, X 0..140, Y 168..183; quatro fases; pista/HUD/relogio preservados.',
          'DOS: duracao(s), ticks/quadro, quadros, expiracao(s), primeiro desconto observado(s):']
report += [str(row) for row in rows]
if host: report.append('Stopwatch Windows entre escritas de inicio/fim (inclui instrumentacao): '+str([round(t,3) for t in host]))
report += ['Inspecao e execucao automatizada; nao equivalem a teclado fisico nem botoes da IDE.',
           'Resolucao DOS aproximadamente 55 ms; atraso de consulta/desenho permitido. Sem medir FPS visual/tearing.']
report += ['Capturas (X,Y,rolagem,pixelsTopo): '+str(positions)]
assert 'PASS KEY' in (testes/'E04KRES.LOG').read_text()
assert 'FAIL' not in (testes/'E04KRES.LOG').read_text()
report += ['PASS KEY: eventos Windows PostMessage -> SDL windib -> DOSBox -> IRQ1; simultaneas/soltura/retorno BIOS.', 'E04MEM: tabela explicita de estados; 640 quadros de RAM, 65000 bytes conferidos por quadro.']
report += ['Limite observado em execucao anterior: 45,15 s DOS / 48,508 s Windows; causa externa nao determinada.', 'Repeticao final acima passou; nao garante precisao sob carga/pausa do host. Ver inspecao.txt e teste fisico pendente.']
(out/'verificacao.txt').write_text('\n'.join(report)+'\n',encoding='utf-8')
print('\n'.join(report))
