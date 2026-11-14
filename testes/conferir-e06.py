"""Confere resultados executados, geometria e pixels sem reproduzir o ASM."""
from pathlib import Path
from collections import Counter
from contrato_atual import inteiro
import argparse, hashlib, json, re, struct, subprocess, sys
from PIL import Image
root=Path(__file__).resolve().parent.parent
parser=argparse.ArgumentParser()
parser.add_argument('--fonte',default='testes/E06BASE.ASM')
parser.add_argument('--prefixo',default='E06')
parser.add_argument('--regressao',default='R06')
parser.add_argument('--e07',action='store_true')
parser.add_argument('--e08',action='store_true')
parser.add_argument('--saida')
args=parser.parse_args()
t=root/'testes';out=root/('evidencias/e07' if args.e07 else 'evidencias/e06');
if args.saida:out=root/args.saida
out.mkdir(parents=True,exist_ok=True)
def nomes(s):return s.replace('E06',args.prefixo).replace('R06',args.regressao)
def arquivo(name):return t/nomes(name)
src=(root/args.fonte).read_text();old=(t/('E07BASE.ASM' if args.e08 else ('E06BASE.ASM' if args.e07 else 'E05BASE.ASM'))).read_text()
digest=hashlib.sha256((root/args.fonte).read_bytes()).hexdigest().upper()
assert digest==arquivo('E06-FONTE.txt').read_text().strip()
assert digest==arquivo('R06-FONTE.txt').read_text().strip()
assert hashlib.sha256((t/'E05BASE.ASM').read_bytes()).hexdigest().upper()=='F5BA545D4B333C3D5F25397251E83386F2D20AFBBB5AD0103E9940BC888CB91F'
if args.fonte=='MOON.ASM':
    from contrato_atual import conferir
    conferir(src)
    unchanged=[]
else:
    artblock=lambda s:s.split('; ARTES_INICIO')[1].split('; ARTES_FIM')[0]
    assert artblock(src)==artblock(old)
    unchanged=[]
    for proc in re.findall(r'(?m)^(\w+) proc',old):
        excepts=['EntrarSetor','EntrarGameOver','MostrarAvisoDemo'] if args.e07 else ['EntrarPartida','AtualizarPartida','DesenharQuadroPartida']
        if args.e08:excepts=['EntrarPartida','AtualizarPartida','RegistrarScanJipe','RestaurarTecladoJogo',
            'DesenharQuadroPartida','ReiniciarObstaculos','AvancarObstaculos','PerderVida',
            'TentarReporJipe','GerarGrupoNaves','EntrarSetor']
        if proc in excepts:continue
        body=lambda s:re.search(rf'{proc} proc.*?{proc} endp',s,re.S).group()
        assert body(src)==body(old),proc
        unchanged.append(proc)
assert src.isascii() and '.8086' in src
for match in re.finditer(r'(?m)^(\w+) proc',src):
    head=src[max(0,src.rfind('endp',0,match.start())):match.start()]
    assert all(x in head for x in ['Funcao:','Entrada:','Saida:']),match[1]
for name in ['E06LOG','E06PIX']:
    log=arquivo(name+'.LOG').read_text()
    assert 'Error messages:    None' in log and 'Warning messages:  None' in log,name
result=arquivo('E06RESUL.LOG').read_text()
assert 'FAIL' not in result and re.search(rf'(?m)^PASS {args.prefixo}\s*$',result)
assert nomes('PASS E06 LOGICA') in result and nomes('PASS E06 PIX') in result
subprocess.run([sys.executable,str(t/'conferir-e05.py'),'--fonte',args.fonte,'--prefixo',args.regressao,'--naves']+(['--e07'] if args.e07 else [])+(['--saida',str(out.relative_to(root)/'regressao')] if args.saida else []),check=True,stdout=subprocess.PIPE)

def groups(file):
    rows=list(struct.iter_unpack('<13H',arquivo(file).read_bytes()))
    for seed,q,typ,*rest in rows:
        xs,ys,act=rest[:3],rest[3:6],rest[6:9]
        assert 1<=q<=3 and 0<=typ<=2
        assert act==[1]*q+[0]*(3-q)
        assert 320<=xs[0]<=335
        for i in range(q):
            assert 320<=xs[i] and xs[i]+14<=480
            assert 15<=ys[i] and ys[i]+14<=100
            if i: assert xs[i]-xs[i-1]-14>=30
    return rows
samples=groups('E06GER.BIN');mixed=groups('E06GRP.BIN')
assert len(samples)==4096 and [r[0] for r in samples]==list(range(4096))
counts=Counter((r[1],r[2]) for r in samples)
assert set(counts)=={(q,ty) for q in [1,2,3] for ty in [0,1,2]}
assert min(counts.values())>100
ys=[r[6+i] for r in samples for i in range(r[1])]
gaps=[r[3+i]-r[2+i]-14 for r in samples for i in range(1,r[1])]
assert min(ys)==15 and max(ys)==86
assert min(r[3] for r in samples)==320 and max(r[3] for r in samples)==335
assert min(gaps)==30
assert max(r[3+r[1]-1]+14 for r in samples)==480
assert len({tuple(r[3:9]) for r in samples})>3000
assert len(mixed)>30
assert set(r[1] for r in mixed)=={1,2,3} and set(r[2] for r in mixed)=={0,1,2}
repeats=sum(a[2]==b[2] for a,b in zip(mixed,mixed[1:]))
assert repeats>0
for a,b in zip(mixed,mixed[1:]):
    # Um passo depois da ultima saida inteira; nenhuma renovacao antecipada.
    assert b[12]-a[12]==inteiro(src,"PASSO_CENARIO")*(max(a[3:3+a[1]])+14+1)
obst=list(struct.iter_unpack('<3H',arquivo('E06MIX.BIN').read_bytes()))
obst_counts=Counter(r[0] for r in obst)
assert len(obst)>350 and set(obst_counts)==set(range(7)) and min(obst_counts.values())>=20
for i,(typ,x,scroll) in enumerate(obst):
    assert (typ<3)==(i%2==0) and 0<=scroll<320
    if i>=2 and i%2==0:
        c0,r=obst[i-2][1],obst[i-1][1]
        assert 150<=x-c0-14<=230
        assert r-c0-14>=60 and x-r-12>=60

artes={a['rotulo']:a for a in json.loads((root/'artes/desenhos.json').read_text(encoding='utf-8'))}
for i in range(1,4):assert (artes[f'bitmapNave{i}']['largura'],artes[f'bitmapNave{i}']['altura'])==(14,14)
palette=[0,0,0,0,0,170,0,170,0,0,170,170,170,0,0,170,0,170,170,85,0,170,170,170,
85,85,85,85,85,255,85,255,85,85,255,255,255,85,85,255,85,255,255,255,85,255,255,255]+[0]*720
def png(data,name):
    im=Image.frombytes('P',(320,200),bytes(data[:64000]));im.putpalette(palette);im.save(out/name)
def sprite(buf,name,x,y):
    for row,line in enumerate(artes[name]['linhas']):
        for col,c in enumerate(line):
            if c!='.' and 0<=x+col<320:buf[(y+row)*320+x+col]=int(c,16)
base=bytearray(64000)
for y in range(100,193):
    for x in range(320):
        c=artes['bitmapMontanhas']['linhas'][min(y-100,63)][x]
        if c!='.':base[y*320+x]=int(c,16)
        if y>=132:
            c=artes['bitmapMontes']['linhas'][min(y-132,31)][x]
            if c!='.':base[y*320+x]=int(c,16)
base[193*320:]=bytes([14])*(7*320)
def scenario(offset):
    b=bytearray([0x55])*(15*320)+bytearray(85*320)
    for y in range(100,200):
        row=base[y*320:(y+1)*320];b+=row[offset:]+row[:offset]
    return b
signed=lambda n:n-65536 if n>=32768 else n
data=arquivo('E06PIX.BIN').read_bytes();size=34+65000
assert len(data)==390*size
for n in range(390):
    chunk=data[n*size:(n+1)*size]
    seq,scroll,jx,jy,ja,ot,ox,typ,*rest=struct.unpack('<17H',chunk[:34])
    assert seq==n
    xs=list(map(signed,rest[:3]));ys=rest[3:6];active=rest[6:9]
    expected=scenario(scroll)
    sprite(expected,f'bitmapRocha{ot-2}',signed(ox),183)
    if ja:sprite(expected,'bitmapJipe',jx,jy)
    for x,y,a in zip(xs,ys,active):
        if a:sprite(expected,f'bitmapNave{typ+1}',x,y)
    expected+=bytes([0xAA])*1000
    actual=chunk[34:]
    if actual!=expected:
        p=next(i for i,(a,b) in enumerate(zip(actual,expected)) if a!=b)
        raise AssertionError((n,typ,xs,ys,p%320,p//320,actual[p],expected[p]))
    if n%130 in [30,31,32,33,34,45,46,95,96]:png(actual,f'quadro-{n:03d}.png')

auto=arquivo('E06AUT.BIN').read_bytes();assert len(auto)==90
states=[struct.unpack('<11H',auto[i:i+22]) for i in range(0,88,22)]
steps=struct.unpack('<H',auto[88:])[0];assert 100<=steps<=220
initial,death,repo,restart=states
assert initial[:2]==death[:2]==repo[:2]
assert initial[5:]==death[5:]==repo[5:]
assert initial[2]-repo[2]==steps and death[2]>repo[2]
for st in [initial,restart]:
    q,typ=st[:2];assert 1<=q<=3 and 0<=typ<=2
    assert 320<=st[2]<=335 and st[8:]==tuple([1]*q+[0]*(3-q))
    assert all(15<=y<=86 for y in st[5:5+q])
for name,st in [('MORT',death),('REPO',repo)]:
    raw=arquivo(f'R06{name}.RAW').read_bytes();assert len(raw)==64000
    expected=bytearray(64000)
    for x,y,a in zip(st[2:5],st[5:8],st[8:11]):
        if a:sprite(expected,f'bitmapNave{st[1]+1}',signed(x),y)
    assert raw[15*320:100*320]==expected[15*320:100*320]
    png(raw,name.lower()+'.png')
mapping=re.search(r'(?m)^.*_DATA.*$',(root/'MOON.MAP').read_text()).group().strip() if args.fonte=='MOON.ASM' else 'Snapshot E06: 35100 bytes; mapa MOON pertence ao fonte atual.'
report=[f'Fonte SHA256: {digest}',result.strip(),
f'4096 sementes executadas: combinacoes (quantidade,tipo)={dict(sorted(counts.items()))}.',
f'Y=15..86; primeira origem=320..335; limite direito da formacao=480; gaps livres minimos={min(gaps)}; sem sobreposicao.',
f'Geracao intercalada real: {len(mixed)} grupos, {repeats} repeticoes consecutivas de tipo; novo grupo somente um passo apos a ultima saida completa.',
f'Obstaculos intercalados: {len(obst)} nascimentos / 40000 pixels; tipos={dict(sorted(obst_counts.items()))}; crateras 150..230 e folgas >=60 respeitadas.',
'Pixels E06: 390 quadros x 65000 bytes = 25.350.000 comparacoes; todos os tipos, Y extremos, entrada/saida, movimento so de naves/so de jipe, remocao, terreno e guarda.',
f'Fluxo real R06AUTO: {steps} passos de naves por ticks BIOS; grupo persiste na morte/reposicao, reset ao iniciar; ceu de dois dumps A000h conferido pixel a pixel.',
'Regressao completa R06 aprovada: E03/E04, 362 verificacoes E05, 336 quadros/21.840.000 bytes, morte natural/ultima vida/expiracao/reinicio/IRQ/modo. Ver regressao/verificacao.txt.',
f'Inspecao: requisitos/dados atuais e cabecalhos conferidos; identidade historica apenas nos snapshots.',
'Dados MOON: '+mapping,
'PENDENTE: teclado fisico, botoes IDE, conforto/fluidez/rasgos, 90 s externos e eventual orientacao do professor sobre D04/D06/D07/D09.',
'Sementes e arranjos forcados pertencem aos testes. PNGs sao memoria real reconstruida; nao sao teste fisico. ' + ('Regressao do minimo: emissao inimiga desabilitada SOMENTE em R08AUTO; E08AUTO testa todos os disparos.' if args.e08 else 'Sem tiros.')]
report=[nomes(line) for line in report]
(out/('regressao-naves.txt' if args.e07 else 'verificacao.txt')).write_text('\n'.join(report)+'\n',encoding='utf-8')
print('\n'.join(report))
