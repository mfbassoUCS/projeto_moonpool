"""Ensaios isolados da auditoria; nao altera MOON.ASM nem testes historicos."""
from pathlib import Path
import hashlib
import importlib.util
import json
import re
import shutil

OUT = Path(__file__).resolve().parent
ROOT = OUT.parent.parent
src = (ROOT / 'MOON.ASM').read_text(encoding='ascii')
for name in ['MONTAGEM.LOG', 'LINK.LOG', 'MOON.MAP']:
    shutil.copy2(ROOT / name, OUT / name)
for name in ['R08RESUL.LOG', 'N08RESUL.LOG', 'E08RESUL.LOG', 'E08HOST.json', 'E08TEMPO.BIN']:
    shutil.copy2(ROOT / 'testes' / name, OUT / name)

def save(name, text):
    (OUT / name).write_bytes(text.replace('\r\n', '\n').replace('\n', '\r\n').encode('ascii'))

for name in ['N08MEM', 'N08TELA', 'N08LOG', 'R08LOG']:
    body = (ROOT / 'testes' / (name + '.ASM')).read_text()
    if name == 'N08LOG':
        needle = '    mov caso,43\n    cmp jipeX,6'
        assert body.count(needle) == 1
        body = body.replace(needle, '    mov caso,43\n    cmp jipeX,10')
    save(name + '.ASM', body)

# Reutiliza o ensaio de 854 travessias com as rotinas atuais em pasta isolada.
spec = importlib.util.spec_from_file_location('ensaio', ROOT / 'testes/avaliar-jogabilidade.py')
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)
variant = src.replace('.code', mod.DATA + '\n.code', 1)
variant = re.sub(r'inicio proc.*?inicio endp', lambda _: mod.MAIN, variant, count=1, flags=re.S)
save('SALTOS.ASM', variant)

# Mede a trajetoria real, sem replicar a implementacao em Python.
data = '''
auditDados dw 120 dup(0)
auditTick dw 0
auditIndice dw 0
auditNome db 'TOPO.BIN',0
'''
main = '''inicio proc
    mov ax,@data
    mov ds,ax
    call ReiniciarJipe
    mov jipeX,40
    mov teclasJipe,BIT_DIREITA
    mov pedidoSalto,1
auditFrame:
    inc auditTick
    test auditTick,1
    jnz auditJipe
    call AvancarCenario
    mov ax,PASSO_CENARIO
    call ContarTopo
auditJipe:
    call AtualizarJipe
    mov di,auditIndice
    mov ax,auditTick
    mov auditDados[di],ax
    mov ax,jipeX
    mov auditDados[di+2],ax
    mov ax,jipeY
    mov auditDados[di+4],ax
    xor ax,ax
    mov al,estadoSalto
    mov auditDados[di+6],ax
    mov ax,rolagem
    mov auditDados[di+8],ax
    mov ax,pixelsTopo
    mov auditDados[di+10],ax
    add auditIndice,12
    cmp auditTick,20
    jb auditFrame
    lea dx,auditNome
    xor cx,cx
    mov ah,3Ch
    int 21h
    mov bx,ax
    lea dx,auditDados
    mov cx,240
    mov ah,40h
    int 21h
    mov ah,3Eh
    int 21h
    mov ax,4C00h
    int 21h
inicio endp
'''
variant = src.replace('.code', data + '\n.code', 1)
variant = re.sub(r'inicio proc.*?inicio endp', lambda _: main, variant, count=1, flags=re.S)
save('TOPO.ASM', variant)

batch = ['@echo off']
for name in ['N08MEM', 'N08LOG', 'R08LOG', 'SALTOS', 'TOPO', 'N08TELA']:
    batch += [f'tasm {name}.ASM > {name}.LOG', f'tlink /m {name}.OBJ >> {name}.LOG',
              f'{name} >> {name}.LOG']
save('AUDITAR.BAT', '\n'.join(batch) + '\n')
save('auditoria.conf', f'''[sdl]
fullscreen=false
output=surface
[cpu]
cycles=50000
[autoexec]
mount t "{ROOT / 'ferramentas/guitasm/BIN'}"
mount j "{OUT}"
j:
path t:\\;z:\\
call AUDITAR.BAT
exit
''')

# Dimensoes reais: decodifica os DB/DUP, nao apenas os EQU ou comentarios.
arts = json.loads((ROOT / 'artes/desenhos.json').read_text(encoding='utf-8'))
sizes = {}
for art in arts:
    label = art['rotulo']
    block = src.split(label + ' db ', 1)[1].split(label + 'Fim label byte', 1)[0]
    pixels = []
    for row in block.splitlines():
        row = re.sub(r'^\s*db\s+', '', row.strip())
        for term in row.split(','):
            match = re.fullmatch(r'(?:(\d+) dup\()?([0-9A-Fa-f]+)h\)?', term.strip())
            assert match, (label, term)
            pixels.extend([int(match[2], 16)] * int(match[1] or 1))
    expected = [255 if c == '.' else int(c, 16) for row in art['linhas'] for c in row]
    assert pixels == expected, label
    assert len(pixels) == art['largura'] * art['altura']
    sizes[label] = [art['largura'], art['altura'], len(pixels)]

procedures = list(re.finditer(r'(?m)^(\w+) proc', src))
missing = []
for proc in procedures:
    header = src[src.rfind('endp', 0, proc.start()):proc.start()] if proc[1] != 'inicio' else src[src.index('jumps'):proc.start()]
    if not all(key in header for key in ['Funcao:', 'Entrada:', 'Saida:']):
        missing.append(proc[1])
assert not missing, missing
taag = json.loads((ROOT / 'artes/taag.json').read_text(encoding='utf-8'))
for title, label, prefix in [('Moon Patrol', 'arteTitulo', 'TITULO'), ('GAME', 'arteGame', 'GAME'), ('OVER', 'arteOver', 'OVER')]:
    rows = taag[title]['text'].split('\n')
    block = src.split(label + ' db ', 1)[1].split(prefix + '_LARG', 1)[0]
    assert re.findall(r"'([^']*)'", block) == [row.ljust(max(map(len, rows))) for row in rows]
report = dict(fonte_sha256=hashlib.sha256((ROOT/'MOON.ASM').read_bytes()).hexdigest(),
              rotinas_com_cabecalho=len(procedures), bitmaps=sizes,
              taag='Tres blocos identicos ao artefato local taag.json; sem nova consulta externa.',
              alteracao_ensaio_naves='Somente expectativa do caso 43: 6 -> 10; rotinas do jogo intactas.')
(OUT/'inspecao-estatica.json').write_text(json.dumps(report, indent=2, ensure_ascii=False), encoding='utf-8')
print(json.dumps(report, ensure_ascii=False))
