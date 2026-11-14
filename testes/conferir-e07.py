"""Confere a integracao do minimo com evidencias da execucao real E07/R07."""
from pathlib import Path
import argparse, hashlib, json, re, struct, subprocess, sys
from PIL import Image
root=Path(__file__).resolve().parent.parent;t=root/'testes';out=root/'evidencias/e07'
parser=argparse.ArgumentParser()
parser.add_argument('--fonte',default='testes/E07BASE.ASM')
parser.add_argument('--prefixo',default='E07')
parser.add_argument('--regressao',default='R07')
parser.add_argument('--e08',action='store_true')
parser.add_argument('--saida',default='evidencias/e07')
args=parser.parse_args()
out=root/args.saida
out.mkdir(parents=True,exist_ok=True)
def nomes(s):return s.replace('E07',args.prefixo).replace('R07',args.regressao)
def arquivo(s):return t/nomes(s)
src=(root/args.fonte).read_text();old=(t/'E06BASE.ASM').read_text()
digest=hashlib.sha256((root/args.fonte).read_bytes()).hexdigest().upper()
assert hashlib.sha256((t/'E06BASE.ASM').read_bytes()).hexdigest().upper()=='E87893D6D70B330A3843C4739FD2AAB69000EF8EDF98775E0C02C18D517F2158'
subprocess.run([sys.executable,str(t/'conferir-e06.py'),'--fonte',args.fonte,'--prefixo',args.prefixo,'--regressao',args.regressao,'--e07','--saida',args.saida]+(['--e08'] if args.e08 else []),check=True,stdout=subprocess.PIPE)
if args.fonte=='MOON.ASM':
    from contrato_atual import conferir
    conferir(src)
    unchanged=[]
else:
    # Mudancas do minimo sao de apresentacao. Nenhuma regra/cadencia antiga mudou.
    for label,value in re.findall(r'(?m)^(\w+)\s+equ\s+([^;\r\n]+)',old):
        if label in ['DEMO_LINHA','DEMO_TAM']:continue
        current=re.search(rf'(?m)^{label}\s+equ\s+([^;\r\n]+)',src)
        assert current and current[1].strip()==value.strip(),label
assert 'demonstracao' not in src and 'MostrarAvisoDemo' not in src
assert "textoSetor db 'SETOR 1'" in src
assert "textoAvanco db 'Enter: iniciar   Setas: mover/saltar'" in src
assert "textoObjetivo db 'Salte os obstaculos e sobreviva!'" in src
for name in ['E07MEM','E07TELA']:
    log=arquivo(name+'.LOG').read_text()
    assert 'Error messages:    None' in log and 'Warning messages:  None' in log,name
result=arquivo('E07RESUL.LOG').read_text()
assert nomes('PASS E07 TELAS') in result and 'PASS MEM: dimensoes' in result
assert 'PASS: modo texto 03h e pagina 0 restaurados' in result
palette=[0,0,0,0,0,170,0,170,0,0,170,170,170,0,0,170,0,170,170,85,0,170,170,170,
85,85,85,85,85,255,85,255,85,85,255,255,255,85,85,255,85,255,255,255,85,255,255,255]+[0]*720
frames={}
for name in ['INI','MOV','SEL','SET','FIM','RET']:
    raw=arquivo(f'E07{name}.RAW').read_bytes();assert len(raw)==64000 and max(raw)<16
    frames[name]=raw
    im=Image.frombytes('P',(320,200),raw);im.putpalette(palette);im.save(out/(name.lower()+'.png'))
def crop(name,x,y,w,h):
    b=frames[name];return b''.join(b[yy*320+x:yy*320+x+w] for yy in range(y,y+h))
def colors(name,x,y,w,h):return set(crop(name,x,y,w,h))-{0}
assert frames['INI']==frames['RET'],'Menu deve voltar a mesma imagem inicial'
assert frames['INI'][:96*320]==frames['MOV'][:96*320]
assert frames['INI'][110*320:]==frames['MOV'][110*320:]
assert colors('INI',0,16,320,32)=={10}
assert colors('INI',112,128,88,24)=={12} and colors('INI',112,160,88,24)=={15}
assert colors('SEL',112,128,88,24)=={15} and colors('SEL',112,160,88,24)=={12}
assert colors('SET',0,56,320,8)=={10} and colors('SET',0,152,320,8)=={14}
assert colors('SET',0,168,320,8)=={15}
assert colors('FIM',0,24,320,40)=={4} and colors('FIM',0,80,320,40)=={4}
assert colors('FIM',0,136,320,8)=={15}
assert not any(crop('FIM',0,152,320,8)),'Aviso de etapa ainda aparece no Game Over'
assert colors('FIM',0,168,320,8)=={15}
artes=json.loads((root/'artes/desenhos.json').read_text(encoding='utf-8'))
for name,steps in [('INI',0),('MOV',320)]:
    expected=bytearray(320*14)
    for a,x0 in zip(artes[:4],(0,80,160,240)):
        x=(x0+steps*2)%(320-a['largura']+2);y=14-a['altura']
        for yy,line in enumerate(a['linhas']):
            for xx,c in enumerate(line):
                if c!='.':expected[(y+yy)*320+x+xx]=int(c,16)
    assert frames[name][96*320:110*320]==expected,(name,'menu/rastros')
taag=json.loads((root/'artes/taag.json').read_text(encoding='utf-8'))
for title,label,prefix in [('Moon Patrol','arteTitulo','TITULO'),('GAME','arteGame','GAME'),('OVER','arteOver','OVER')]:
    rows=taag[title]['text'].split('\n');width=max(map(len,rows))
    block=src.split(label+' db ',1)[1].split(prefix+'_LARG',1)[0]
    assert re.findall(r"'([^']*)'",block)==[r.ljust(width) for r in rows]
lo,hi,slo,shi=struct.unpack('<4H',arquivo('E07TELA.BIN').read_bytes())
menu=(hi*65536+lo)/100;sector=(shi*65536+slo)/100
assert 30<menu<65 and 2<=sector<3,(menu,sector)
report=[f'Data: 31/10/2026. Fonte SHA256: {digest}',
result.strip(),
f'Telas: 320 quadros reais por ticks em {menu:.2f}s DOS; SETOR esperou {sector:.2f}s sem consumir tempo da partida.',
'D04: SETOR 1 e Enter para iniciar; letras/setas nao iniciam; Enter enfileirado descartado; nova partida reinicia os 90 s.',
'Seis dumps A000h de 64000 bytes: menu/animacao/selecao/setor/fim/retorno; cores, areas estaticas, sprites e retorno identico conferidos.',
'E07MEM: 400 quadros de menu em RAM, duas voltas por objeto, invalidos, FF/00, DF e 1000 bytes de guarda; artes/TAAG preservados.',
'Regressao completa E03-E06 sobre MOON atual aprovada: ver regressao-naves.txt e regressao/verificacao.txt. Saida por vidas e tempo, reset, score real, IRQ1 e modo/pagina restaurados.',
'Inspecao: medidas obrigatorias e artes atuais conferidas; cadencias e relevo podem evoluir sem exigir identidade com E06.',
'Dados: '+(re.search(r'(?m)^.*_DATA.*$',(root/'MOON.MAP').read_text()).group().strip() if args.fonte=='MOON.ASM' else 'Snapshot E07: 35105 bytes; mapa MOON pertence ao fonte atual.'),
'T01-T16: evidencias automaticas/inspecao mapeadas em planejamento/13-validacao-e-entrega.md; partes fisicas continuam pendentes.',
'T17-T20: NAO APLICAVEIS ao minimo; nenhum tiro implementado.',
'PENDENTE: teclado fisico, botoes IDE atuais, conforto dos saltos, fluidez/rasgos, 90 s normais com cronometro externo. Sem medicao externa nova.',
'A integracao minima passou nas verificacoes automaticas; isso nao conclui a validacao fisica para apresentacao. PNGs sao memoria reconstruida.']
if args.e08:
    report=[line for line in report if not any(x in line for x in ['31/10/2026','T17-T20','apenas apresentacao'])]
    report.insert(0,f'Regressao de telas E08: fonte SHA256 {digest}')
    report=[nomes(line).replace('Sem medicao externa nova.', 'Medicao externa curta E08 registrada no relatorio principal; 90 s normais pendentes.') for line in report]
(out/('regressao-telas.txt' if args.e08 else 'verificacao.txt')).write_text('\n'.join(report)+'\n',encoding='utf-8')
print('\n'.join(report))
