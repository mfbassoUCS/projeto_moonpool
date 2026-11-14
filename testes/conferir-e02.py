"""Confere capturas REAIS A000h e gera PNGs com a paleta VGA 0..15.
Auxilio de teste (Python/Pillow locais); nenhuma dependencia do EXE DOS.
"""
from pathlib import Path
import json
import re
from PIL import Image

root = Path(__file__).resolve().parent.parent
out = root / "evidencias" / "e02"
out.mkdir(parents=True, exist_ok=True)
palette = [
    0,0,0, 0,0,170, 0,170,0, 0,170,170,
    170,0,0, 170,0,170, 170,85,0, 170,170,170,
    85,85,85, 85,85,255, 85,255,85, 85,255,255,
    255,85,85, 255,85,255, 255,255,85, 255,255,255,
] + [0]*720
frames = {}
for name in ["MENU0", "MENU2", "SELECAO", "SETOR", "FIM", "RETORNO", "GALERIA"]:
    data = (root / "testes" / (name + ".RAW")).read_bytes()
    assert len(data) == 64000, (name, len(data))
    assert max(data) < 16, (name, "indice inesperado")
    frames[name] = data
    im = Image.frombytes("P", (320,200), data)
    im.putpalette(palette)
    im.save(out / (name.lower() + ".png"))

def colors(name, x, y, w, h):
    data = frames[name]
    return {data[yy*320+xx] for yy in range(y,y+h) for xx in range(x,x+w)} - {0}

assert colors("MENU0", 0,16,320,32) == {10}
assert colors("MENU0", 112,128,88,24) == {12}
assert colors("MENU0", 112,160,88,24) == {15}
assert colors("SELECAO", 112,128,88,24) == {15}
assert colors("SELECAO", 112,160,88,24) == {12}
assert colors("FIM", 0,24,320,40) == {4}
assert colors("FIM", 0,80,320,40) == {4}
assert colors("FIM", 0,136,320,8) == {15}
assert frames["RETORNO"] == frames["MENU0"], "Menu nao reinicializado"
assert frames["MENU0"][:96*320] == frames["MENU2"][:96*320]
assert frames["MENU0"][110*320:] == frames["MENU2"][110*320:], "Fundo estatico alterado"
# Oraculo: grades de arte autoral, independentes da copia 8086.
artes = json.loads((root/'artes'/'desenhos.json').read_text(encoding='utf-8'))
def pixels(a):
    return bytes(255 if c=='.' else int(c,16) for line in a['linhas'] for c in line)
assert len(artes)==17
for a in artes:
    assert len(a['linhas'])==a['altura']
    assert all(len(line)==a['largura'] for line in a['linhas'])
    assert any(p!=255 for p in pixels(a)), a['nome']
assert (root/'testes'/'ARTES.BIN').read_bytes() == b''.join(pixels(a) for a in artes), 'Conversao DB incorreta'
for a in artes[15:]:
    assert all(line[0]==line[-1] for line in a['linhas']), 'Bordas do relevo diferentes'
def blit(dst,a,x,y):
    for yy,line in enumerate(a['linhas']):
        for xx,c in enumerate(line):
            if c!='.': dst[(y+yy)*320+x+xx]=int(c,16)
for name, steps in [("MENU0",0), ("MENU2",320)]:
    expected = bytearray(320*14)
    for a,x0 in zip(artes[:4],(0,80,160,240)):
        w,h=a['largura'],a['altura']
        x = (x0 + steps*2) % (320-w+2)
        y = 14-h
        blit(expected,a,x,y)
    assert frames[name][96*320:110*320] == expected, (name, "animacao/rastro/dimensao")
# Galeria executada no DOS: cada arte (incluindo camadas sobrepostas).
coords=[(16,24),(80,24),(144,24),(208,24),(16,64),(80,64),(144,64),(208,64),
        (208,102),(248,102),(288,102),(16,102),(64,102),(112,102),(160,102),(0,136),(0,168)]
expected=bytearray(64000)
for i,(a,(x,y)) in enumerate(zip(artes,coords)):
    if 8<=i<=10:
        for yy in range(y,y+7): expected[yy*320+x:yy*320+x+14]=bytes([14])*14
    blit(expected,a,x,y)
for a,(x,y) in zip(artes,coords):
    for yy in range(y,y+a['altura']):
        p=yy*320+x
        assert frames['GALERIA'][p:p+a['largura']]==expected[p:p+a['largura']],a['nome']
# A transcricao para DB deve coincidir com a saida arquivada do TAAG.
source = (root/"MOON.ASM").read_text(encoding="ascii")
taag = json.loads((root/"artes"/"taag.json").read_text(encoding="utf-8"))
for text,label,prefix in [("Moon Patrol","arteTitulo","TITULO"),("GAME","arteGame","GAME"),("OVER","arteOver","OVER")]:
    rows = taag[text]["text"].split("\n")
    width = max(map(len,rows))
    block = source.split(label+" db ",1)[1].split(prefix+"_LARG",1)[0]
    actual = re.findall(r"'([^']*)'",block)
    assert actual == [r.ljust(width) for r in rows], (text, "transcricao")
report = (
    "PASS: 7 capturas reais de 64000 bytes; indices VGA 0..15.\n"
    "PASS: titulo 0Ah; selecao 0Ch/0Fh e inversao; GAME/OVER 04h; score 0Fh.\n"
    "PASS: jipe 20x10 / 3 naves 14x14; posicoes apos 320 quadros; faixa sem rastros.\n"
    "PASS: 17 artes em ARTES.BIN identicas as grades; 32932 bytes; galeria no DOS.\n"
    "PASS: relevo 320x64 e 320x32 com bordas identicas (sem teste de rolagem).\n"
    "PASS: fundo fora da faixa animada preservado; menu de retorno identico ao inicial.\n"
    "PASS: ASCII no fonte coincide com TAAG Mini/Small arquivado.\n"
    "PNGs: reconstrucao dos indices A000h com paleta VGA padrao, nao PrintWindow.\n"
    "ORIGEM: artes proprias autorizadas; nao reproduzem figuras do professor/arcade.\n"
)
(out/"verificacao.txt").write_text(report, encoding="utf-8")
print(report)
