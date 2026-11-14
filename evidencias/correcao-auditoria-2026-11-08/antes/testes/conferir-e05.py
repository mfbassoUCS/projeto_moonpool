"""Oraculo independente de geracao, pixels e evidencias reais E05."""
from pathlib import Path
import hashlib, json, re, struct, argparse
from collections import Counter
from PIL import Image

root=Path(__file__).resolve().parent.parent
t=root/'testes'
parser=argparse.ArgumentParser()
parser.add_argument('--fonte',default='testes/E05BASE.ASM')
parser.add_argument('--prefixo',default='E05')
parser.add_argument('--naves',action='store_true',help='ceu validado pelo conferidor E06')
parser.add_argument('--e07',action='store_true',help='interface Game Over limpa; sem aviso de etapa')
parser.add_argument('--saida')
args=parser.parse_args()
def arquivo(name): return t/name.replace('E05',args.prefixo)
out=root/('evidencias/e07/regressao' if args.e07 else ('evidencias/e06/regressao' if args.naves else 'evidencias/e05'))
if args.saida:out=root/args.saida
out.mkdir(parents=True,exist_ok=True)
src=(root/args.fonte).read_text()
old=(t/'E04BASE.ASM').read_text()
digest=hashlib.sha256((root/args.fonte).read_bytes()).hexdigest().upper()
assert digest==arquivo('E05-FONTE.txt').read_text().strip(),'Fonte mudou depois dos testes'
artblock=lambda s:s.split('; ARTES_INICIO')[1].split('; ARTES_FIM')[0]
assert artblock(src)==artblock(old),'Artes E02 mudaram'
unchanged=['AtualizarJipe','ContarTopo','LerCentissegundos','AtualizarRelogio','ConsumirTempo',
           'AvancarCenario','ComporLinhaCircular','DesenharCenario','DesenharStatus',
           'DesenharSprite','SalvarFundo','DesenharBitmap','EntrarGameOver']
if args.e07:unchanged.remove('EntrarGameOver')
for proc in unchanged:
    body=lambda s:re.search(rf'{proc} proc.*?{proc} endp',s,re.S).group()
    assert body(src)==body(old),proc+' mudou'
assert src.isascii() and '.8086' in src
for match in re.finditer(r'(?m)^(\w+) proc',src):
    head=src[max(0,src.rfind('endp',0,match.start())):match.start()]
    assert all(x in head for x in ['Funcao:','Entrada:','Saida:']),match[1]

for name in ['E05REG','E05JIPE','E05LOG','E05PIX','E05AUTO']:
    log=arquivo(name+'.LOG').read_text()
    assert 'Error messages:    None' in log and 'Warning messages:  None' in log,name
result=arquivo('E05RESUL.LOG').read_text()
assert 'FAIL' not in result and re.search(rf'(?m)^PASS {args.prefixo}\s*$',result)
assert all(x.replace('E05',args.prefixo) in result for x in ['PASS MEM','PASS JIPE','PASS E05 LOGICA','PASS E05 PIX','PASS E05 AUTO'])
assert 'Error messages:    None' in (root/'MONTAGEM.LOG').read_text()
assert 'Warning messages:  None' in (root/'MONTAGEM.LOG').read_text()

records=list(struct.iter_unpack('<3H',arquivo('E05GER.BIN').read_bytes()))
assert len(records)>150
counts=Counter(r[0] for r in records)
assert set(counts)==set(range(7)),counts
for i,(typ,x,scroll) in enumerate(records):
    assert (typ<3)==(i%2==0),'Sequencia deve alternar cratera/rocha'
    assert 0<=scroll<320
    if i%2==0 and i>=2:
        prev=records[i-2][1]; rock=records[i-1][1]
        assert 150<=x-(prev+14)<=230,('gap crateras',prev,x)
        assert rock-(prev+14)>=60 and x-(rock+12)>=60,('folgas rocha',prev,rock,x)
assert records[0][1]==320
assert [r[1] for r in records]==sorted(r[1] for r in records)
gaps=[records[i][1]-records[i-2][1]-14 for i in range(2,len(records),2)]
assert min(gaps)==150 and max(gaps)==230,'Os dois limites devem aparecer no ensaio'
assert min(records[i-1][1]-records[i-2][1]-14 for i in range(2,len(records),2))==60
assert min(records[i][1]-records[i-1][1]-12 for i in range(2,len(records),2))==60

artes={a['rotulo']:a for a in json.loads((root/'artes/desenhos.json').read_text(encoding='utf-8'))}
names=[f'bitmapCratera{i}' for i in range(1,4)]+[f'bitmapRocha{i}' for i in range(1,5)]
for i,name in enumerate(names):
    assert (artes[name]['largura'],artes[name]['altura'])==((14,7) if i<3 else (12,10))

palette=[0,0,0,0,0,170,0,170,0,0,170,170,170,0,0,170,0,170,170,85,0,170,170,170,
85,85,85,85,85,255,85,255,85,85,255,255,255,85,85,255,85,255,255,255,85,255,255,255]+[0]*720
def png(data,name):
    im=Image.frombytes('P',(320,200),data[:64000]); im.putpalette(palette);im.save(out/name)
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
scenarios={}
def scenario(offset,upper=0x55):
    key=(offset,upper)
    if key not in scenarios:
        b=bytearray([upper])*32000
        for y in range(100,200):
            row=base[y*320:(y+1)*320]
            b+=row[offset:]+row[:offset]
        scenarios[key]=b
    return bytearray(scenarios[key])
data=arquivo('E05PIX.BIN').read_bytes()
size=16+65000
assert len(data)==336*size
for n in range(336):
    chunk=data[n*size:(n+1)*size]
    scroll,jx,jy,active,typ,x,seq,_=struct.unpack('<8H',chunk[:16])
    if x>=32768:x-=65536
    assert seq==n
    expected=scenario(scroll)
    sprite(expected,names[typ],x,193 if typ<3 else 183)
    if active:sprite(expected,'bitmapJipe',jx,jy)
    expected+=bytes([0xAA])*1000
    actual=chunk[16:]
    if actual!=expected:
        pixel=next(i for i,(a,b) in enumerate(zip(actual,expected)) if a!=b)
        raise AssertionError((n,typ,x,scroll,pixel%320,pixel//320,actual[pixel],expected[pixel]))
    if x==30 and active and jx==0:png(actual,f'tipo-{typ}.png')
    if n in [12,37,180,181,182,183]:png(actual,f'quadro-{n}.png')

raws={name:arquivo(f'E05{name}.RAW').read_bytes() for name in ['MORT','REPO','FIM']}
for name,raw in raws.items():
    assert len(raw)==64000
    png(raw,name.lower()+'.png')
naturalLo,naturalHi,lifeTime,lifeScroll,respawnTime,respawnScroll,expiry,score=struct.unpack('<8H',arquivo('E05AUTO.BIN').read_bytes())
natural=(naturalHi*65536+naturalLo)/100
assert 10<natural<30 and 400<=expiry<=450 and score==250
assert respawnTime<=lifeTime<90 and respawnScroll!=lifeScroll
def crop(b,x,y,w,h):return b''.join(b[yy*320+x:yy*320+x+w] for yy in range(y,y+h))
for name in ['MORT','REPO']:
    art=artes['bitmapVidas2']
    expected=bytes(0 if c=='.' else int(c,16) for row in art['linhas'] for c in row)
    assert crop(raws[name],151,2,18,11)==expected
    if not args.naves: assert not any(raws[name][15*320:100*320])
assert {v for v in crop(raws['FIM'],0,24,320,40)}-{0}=={4}
# Guia visual: sete tipos em uma prancha, recortes copiados de RAM real.
sheet=Image.new('RGB',(320*2,40*7),(0,0,0))
for typ in range(7):
    im=Image.open(out/f'tipo-{typ}.png').convert('RGB').crop((0,180,80,200)).resize((640,40))
    sheet.paste(im,(0,typ*40))
sheet.save(out/'tipos-reais.png')
report=[f'Fonte SHA256: {digest}',result.strip(),f'Geracao: {len(records)} nascimentos em 20000 pixels; tipos {dict(sorted(counts.items()))}.',
'D07: espaco livre 150..230 entre crateras; uma rocha no intervalo, >=60 px livres de cada lado.',
'Pixels: 336 quadros reais, 65000 bytes cada (21.840.000 comparacoes), recorte esquerdo/direito, fundo com/sem rolagem, jipe presente/ausente, HUD/ceu/1000 bytes guarda.',
f'Fluxo real: primeira morte natural em {natural:.2f}s DOS; tempo {lifeTime}s -> {respawnTime}s na reposicao; rolagem {lifeScroll} -> {respawnScroll}; expiracao separada {expiry/100:.2f}s DOS, score final {score}.',
f'Inspecao: artes E02 e {len(unchanged)} rotinas preservadas; ASCII/.8086 e cabecalhos conferidos.',
('Dados MOON atual: '+re.search(r'(?m)^.*_DATA.*$',(root/'MOON.MAP').read_text()).group().strip()) if args.naves else 'Snapshot E05: 35072 bytes de dados; mapa atual pertence a etapa vigente.',
'PENDENTE: teclado fisico, botoes IDE, conforto/fluidez/cintilacao, precisao externa dos 90 s, aceitacao das convencoes tecnicas pelo professor.',
'Dumps/PNGs sao memoria reconstruida, nao filmagem/uso fisico. Valores forcados de teste nao mudam a configuracao normal.']
(out/'verificacao.txt').write_text('\n'.join(report)+'\n',encoding='utf-8')
print('\n'.join(report))
