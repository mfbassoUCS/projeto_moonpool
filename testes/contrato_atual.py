"""Contrato do fonte atual: requisitos/dados, sem exigir copia de fonte antigo."""
from pathlib import Path
import json
import re

ROOT = Path(__file__).resolve().parent.parent


def inteiro(src, name):
    value = re.search(rf'(?m)^{name}\s+equ\s+(\d+)\s*(?:;.*)?$', src)
    assert value, name
    return int(value[1])


def conferir(src):
    assert src.isascii() and '.8086' in src
    # Medidas normativas independem de cadencia e aparencia autoral.
    for name, expected in {'TELA_LARG':320, 'TELA_ALT':200, 'JIPE_LARG':20,
                          'JIPE_ALT':10, 'NAVE_LARG':14, 'NAVE_ALT':14,
                          'CRATERA_LARG':14, 'CRATERA_ALT':7, 'ROCHA_LARG':12,
                          'ROCHA_ALT':10, 'SALTO_ALTURA':15, 'SALTO_PASSO':3,
                          'SALTO_TOPO_PX':5, 'PISTA_ALT':7}.items():
        assert inteiro(src, name) == expected, name
    assert inteiro(src,'PASSO_JIPE')*inteiro(src,'TICKS_NAVE') > inteiro(src,'PASSO_NAVE')*inteiro(src,'TICKS_JIPE')
    assert 5 % inteiro(src,'PASSO_CENARIO') == 0
    assert inteiro(src,'TICKS_CENARIO') % inteiro(src,'TICKS_JIPE') == 0
    for proc in re.finditer(r'(?m)^(\w+) proc',src):
        start = max(0,src.rfind('endp',0,proc.start()))
        assert all(s in src[start:proc.start()] for s in ['Funcao:','Entrada:','Saida:']),proc[1]
    arts = json.loads((ROOT/'artes/desenhos.json').read_text(encoding='utf-8'))
    for art in arts:
        label = art['rotulo']
        block = src.split(label+' db ',1)[1].split(label+'Fim label byte',1)[0]
        pixels=[]
        for row in block.splitlines():
            # As linhas de pixels podem ter comentarios didaticos apos os bytes.
            row=row.split(';',1)[0]
            row=re.sub(r'^\s*db\s+','',row.strip())
            for term in row.split(','):
                match=re.fullmatch(r'(?:(\d+) dup\()?([0-9A-Fa-f]+)h\)?',term.strip())
                assert match,(label,term)
                pixels.extend([int(match[2],16)]*int(match[1] or 1))
        expected=[255 if c=='.' else int(c,16) for row in art['linhas'] for c in row]
        assert pixels==expected and len(pixels)==art['largura']*art['altura'],label
    return len(arts)
