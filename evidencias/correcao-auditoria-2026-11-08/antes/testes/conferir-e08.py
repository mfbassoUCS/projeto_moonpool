"""Confere logs reais e pixels E08, usando grades autorais como oraculo."""
from pathlib import Path
import argparse, hashlib, json, re, struct, subprocess, sys
from PIL import Image
root=Path(__file__).resolve().parent.parent;t=root/'testes'
p=argparse.ArgumentParser();p.add_argument('--pixels',action='store_true')
p.add_argument('--saida',default='evidencias/e08')
p.add_argument('--data',default='01/11/2026')
p.add_argument('--data-suite',help='Data da execucao DOS, se diferente da conferencia')
p.add_argument('--data-teclado',help='Data da execucao KEY, se diferente da conferencia')
p.add_argument('--e09',action='store_true',help='Identificar a revisao, sem mudar os oraculos E08')
args=p.parse_args();out=root/args.saida
out.mkdir(parents=True,exist_ok=True)
digest=hashlib.sha256((root/'MOON.ASM').read_bytes()).hexdigest().upper()
assert digest==(t/'E08-FONTE.txt').read_text().strip()
assert hashlib.sha256((t/'E07BASE.ASM').read_bytes()).hexdigest().upper()=='FCA3099062C1F4BF34EB1EAADE7E98991587453E6D5A77B83A7025DBCBE10901'
artes={a['rotulo']:a for a in json.loads((root/'artes/desenhos.json').read_text(encoding='utf-8'))}
palette=[0,0,0,0,0,170,0,170,0,0,170,170,170,0,0,170,0,170,170,85,0,170,170,170,
85,85,85,85,85,255,85,255,85,85,255,255,255,85,85,255,85,255,255,255,85,255,255,255]+[0]*720
def png(b,name):
    im=Image.frombytes('P',(320,200),bytes(b[:64000]));im.putpalette(palette);im.save(out/name)
signed=lambda x:x-65536 if x>=32768 else x
def sprite(b,name,x,y):
    for yy,line in enumerate(artes[name]['linhas']):
        for xx,c in enumerate(line):
            if c!='.' and 0<=x+xx<320:b[(y+yy)*320+x+xx]=int(c,16)
base=bytearray(64000)
for y in range(100,193):
    for x in range(320):
        c=artes['bitmapMontanhas']['linhas'][min(y-100,63)][x]
        if c!='.':base[y*320+x]=int(c,16)
        if y>=132:
            c=artes['bitmapMontes']['linhas'][min(y-132,31)][x]
            if c!='.':base[y*320+x]=int(c,16)
base[193*320:]=bytes([14])*(7*320)
raw=(t/'E08PIX.BIN').read_bytes();size=286+65000
assert len(raw)%size==0
frames=len(raw)//size;assert frames==170,frames
active_max=[0,0,0];absent=0;with_shots=0
names=[f'bitmapCratera{i}' for i in range(1,4)]+[f'bitmapRocha{i}' for i in range(1,5)]
for n in range(frames):
    chunk=raw[n*size:(n+1)*size]
    st=struct.unpack('<143H',chunk[:286])
    seq,scroll,jx,jy,ja,nt=st[:6];assert seq==n
    ox=list(map(signed,st[6:14]));ot=st[14:22]
    nx=list(map(signed,st[22:25]));ny=st[25:28];na=st[28:31]
    ta=st[31:59];tx=list(map(signed,st[59:87]));ty=st[87:115];td=st[115:143]
    expected=bytearray([0x55])*(15*320)+bytearray(85*320)
    for y in range(100,200):
        row=base[y*320:(y+1)*320];expected+=row[scroll:]+row[:scroll]
    for x,y,a in zip(nx,ny,na):
        if a:sprite(expected,f'bitmapNave{nt+1}',x,y)
    for x,typ in zip(ox,ot):
        if typ!=65535:sprite(expected,names[typ],x,193 if typ<3 else 183)
    for i,(a,x,y,d) in enumerate(zip(ta,tx,ty,td)):
        if not a:continue
        w,h,color=(2,4,14) if i<8 else ((4,2,4) if i<16 else (2,4,15))
        assert 15<=y and y+h<=193,(n,i,y)
        if 8<=i<16:assert d<50
        for yy in range(y,y+h):
            for xx in range(max(0,x),min(320,x+w)):expected[yy*320+xx]=color
    if ja:sprite(expected,'bitmapJipe',jx,jy)
    expected+=bytes([0xAA])*1000
    actual=chunk[286:]
    if actual!=expected:
        i=next(i for i,(a,b) in enumerate(zip(actual,expected)) if a!=b)
        raise AssertionError((n,i%320,i//320,actual[i],expected[i]))
    absent+=not ja;with_shots+=any(ta)
    active_max=[max(m,sum(ta[a:b])) for m,a,b in zip(active_max,[0,8,16],[8,16,28])]
    if n in [0,1,2,3,4,5,6,7,8,10,20,30,50,70,100,140,169]:png(actual,f'quadro-{n:03}.png')
assert active_max==[8,8,12] and absent>0
pixel_report=f'{frames} quadros x 65000 bytes = {frames*65000:,} bytes conferidos; HUD/guarda, recorte, ceu/terreno, tiros/jipe e apagamento. Maximos ativos {active_max}; {absent} quadros com jipe ausente.'
print(pixel_report)
if args.pixels:sys.exit(0)
subprocess.run([sys.executable,str(t/'conferir-e07.py'),'--fonte','MOON.ASM',
    '--prefixo','N08','--regressao','R08','--e08','--saida',args.saida],check=True,stdout=subprocess.PIPE)
if args.e09:
    # Somente metadados de apresentacao: preservar todos os resultados/oraculos.
    for relative in ['regressao-naves.txt','regressao-telas.txt','regressao/verificacao.txt']:
        path=out/relative
        lines=path.read_text(encoding='utf-8').splitlines()
        lines=[line.replace('botoes IDE atuais, ', '').replace('botoes IDE, ', '') for line in lines]
        lines.insert(0,f'Suite executada em {args.data_suite or args.data}; conferencia E09 em {args.data}; botoes da IDE registrados separadamente em gui-validacao.md.')
        path.write_text('\n'.join(lines)+'\n',encoding='utf-8')
for name in ['E08LOG','E08PIX','E08AUTO','E08KEY']:
    log=(t/(name+'.LOG')).read_text()
    assert 'Error messages:    None' in log and 'Warning messages:  None' in log,name
result=(t/'E08RESUL.LOG').read_text()
assert 'FAIL' not in result and re.search(r'(?m)^PASS E08\s*$',result)
assert all(s in result for s in ['PASS E08 LOG: 426','PASS E08 PIX','PASS E08 AUTO','modo texto 03h'])
key=(t/'E08KRES.LOG').read_text()
assert 'PASS KEY' in key and 'FAIL' not in key
assert digest==(t/'E08K-FONTE.txt').read_text().strip()
lo,hi,_,_=struct.unpack('<4H',(t/'E08TEMPO.BIN').read_bytes())
dos=(hi*65536+lo)/100
host=json.loads((t/'E08HOST.json').read_text(encoding='utf-8-sig'))
assert 6<=dos<7 and 6<=host['segundos']<7,(dos,host)
src=(root/'MOON.ASM').read_text()
assert 'call RemoverNave\n    jnc tiroNaveProxima' in src
assert all(x in src for x in ['TIRO_SUP_MAX    equ 8','TIRO_FRE_MAX    equ 8','TIRO_INI_MAX    equ 12','IMPACTOS_ROCHA4 equ 2'])
report=[f'Data: {args.data}. Fonte SHA256: {digest}',result.strip(),pixel_report,
f'Fluxo completo: 6 s controlados = {dos:.2f}s DOS / {host["segundos"]:.3f}s Windows entre sinais (inclui instrumentacao).',
'T17: origens no chao/todas as alturas, dois canhoes atomicos, toque curto/mantida/soltura, cadencia/wrap, 8+8 vagas sem substituir ativos.',
'T18: superior/linha15/nave/100 unico, signed/bordas/todas vagas, saturacao65535; frontal 50 exatos desde origem com jipe movendo, impacto no ultimo pixel.',
'T19: crateras intactas; rocha1 indestrutivel, 2/3 um impacto, 4 dois persistentes; salto OU destruicao, sem duplicar; reuso zera dano.',
'T20: grupos 1..3, branco2x4/continuo/capacidade12, canhao visivel, contato inferior/laterais/salto/pista, morte unica/reposicao livre, tiro persiste depois da ultima nave.',
'E08AUTO: entrada BIOS e scans sinteticos; rotinas completas com tiro inimigo habilitado; rocha+nave=150, tiro orfao tira uma vida, reposicao, fim por tempo e ultima vida, reset, IRQ e Sair.',
'E08KEY: '+key.strip()+' Eventos Windows PostMessage -> SDL windib -> DOSBox -> IRQ1; nao equivale a teclado fisico/backend normal.',
'Regressao N08/R08 do minimo passou: 4096 sementes, 48 grupos/394 obstaculos, 362 verificacoes terrestres/sete saltos, cenario/relogio, 80 estados/640 quadros do jipe, 390 quadros naves/336 terrestres, telas/menu/IRQ.',
'R08AUTO isola o minimo desabilitando SOMENTE a emissao inimiga nessa variante para reutilizar o oraculo sem tiros; E08AUTO executa o fluxo com todos os disparos.',
'D11/D13 sao escolhas tecnicas: dois impactos na mesma rocha sem prazo; superior2x4; movimento4/4/2 pixels por tick; cadencia6/18; superficie=pista193.',
'Dados MOON: '+re.search(r'(?m)^.*_DATA.*$',(root/'MOON.MAP').read_text()).group().strip(),
'INSPECAO: E07BASE preservado por hash; artes, rotinas de salto/tempo/sorteio/pontuacao e constantes anteriores preservadas; .8086/ASCII/cabecalhos; desenho/apagamento por memoria.',
'PENDENTE: teclado fisico, botoes Assemble/Build/Run do fonte atual, conforto/esquiva/fluidez/rasgos e 90 s normais com cronometro externo. Aluno informou que ainda nao realizou esses testes.',
'PNGs sao RAM real reconstruida, nao teste fisico. Poses/sementes/tempo curto sao arranjos exclusivos dos harnesses. E09 nao iniciada.']
if args.e09:
    report[-2]='PENDENTE: teclado fisico, conforto/esquiva/fluidez/rasgos e 90 s normais com cronometro externo. Botoes IDE: consultar registro separado gui-validacao.md; esta suite nao os aciona.'
    report[-1]='E09: reexecucao dos testes E08 no fonte revisado. PNGs sao RAM reconstruida; poses/sementes/tempo curto sao exclusivos dos harnesses. Sem comprovacao de teste fisico, apresentacao ou entrega.'
    report.insert(1,f'Data da conferencia acima. Suite DOS: {args.data_suite or args.data}; KEY: {args.data_teclado or args.data}.')
(out/'verificacao.txt').write_text('\n'.join(report)+'\n',encoding='utf-8')
print('\n'.join(report))
