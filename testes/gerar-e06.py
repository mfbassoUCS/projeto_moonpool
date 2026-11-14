"""Variantes E06 do fonte real; nenhum codigo de teste entra em MOON."""
from pathlib import Path
import argparse, hashlib, re, subprocess, sys
from contrato_atual import inteiro
root=Path(__file__).resolve().parent.parent
t=root/'testes'
parser=argparse.ArgumentParser()
parser.add_argument('--fonte',default='testes/E06BASE.ASM')
parser.add_argument('--prefixo',default='E06')
parser.add_argument('--regressao',default='R06')
args=parser.parse_args()
src=(root/args.fonte).read_text()
def nomes(s):return s.replace('E06',args.prefixo).replace('R06',args.regressao)
def save(name,s):
    (t/nomes(name)).write_bytes(nomes(s).replace('\r\n','\n').replace('\n','\r\n').encode('ascii'))
def variant(name,data,main):
    s=src.replace('.code',data+'\n.code',1)
    s=re.sub(r'inicio proc.*?inicio endp',lambda _:main,s,count=1,flags=re.S)
    save(name+'.ASM',s)

# Os mesmos testes E03/E04/E05, agora sobre MOON, em nomes separados.
subprocess.run([sys.executable,str(t/'gerar-e05.py'),'--fonte',args.fonte,'--prefixo',args.regressao],check=True)
# Estender o fluxo real da regressao: movimento, persistencia na morte e reset.
p=t/(args.regressao+'AUTO.ASM');s=p.read_text().replace(args.regressao,'R06')
s=s.replace('.code',"autoE06Dados dw 45 dup(0)\nautoE06X dw 0\nautoE06Nome db 'E06AUT.BIN',0\n.code",1)
s=s.replace('autoInicio:\n','autoInicio:\n    call ConferirInicioNaves\n    lea si,autoE06Dados\n    call GuardarNavesAuto\n')
s=s.replace('autoNatural:\n','autoNatural:\n    call ConferirMovimentoNaves\n')
s=s.replace('autoRepor:\n','autoRepor:\n    call ConferirMovimentoNaves\n')
s=s.replace('    lea dx,nomeMorte','    lea si,autoE06Dados+22\n    call GuardarNavesAuto\n    lea dx,nomeMorte')
s=s.replace('    lea dx,nomeRepor','    lea si,autoE06Dados+44\n    call GuardarNavesAuto\n    lea dx,nomeRepor')
s=s.replace('autoNovaPartida:\n','autoNovaPartida:\n    call ConferirInicioNaves\n    lea si,autoE06Dados+66\n    call GuardarNavesAuto\n')
s=s.replace('GravarRegistroR06 proc near\n','GravarRegistroR06 proc near\n    call GravarNavesAuto\n')
s=s.replace('end inicio',(t/'E06AUTO.INC').read_text()+'\nend inicio')
save(p.name,s)
code=[];case=0
def emit(s): code.extend('    '+line if not line.endswith(':') else line for line in s.splitlines())
def check(expr,value):
    global case
    case+=1
    emit(f'mov caso,{case}\ncmp {expr},{value}\njne falhaE06')
def carry(expected):
    global case
    case+=1
    emit(f'mov caso,{case}\n'+('jnc' if expected else 'jc')+' falhaE06')
emit('mov ax,@data\nmov ds,ax\nmov semente,12345\ncall ReiniciarNaves')
check('semente',12345)
check('naveQuantidade',0)
emit('call ContarNavesAtivas');check('ax',0)
for i,(x,y) in enumerate([(-13,15),(0,86),(320,41)]):
    emit(f'mov naveAtiva+{i*2},1\nmov naveX+{i*2},{x}\nmov naveY+{i*2},{y}')
emit('mov naveQuantidade,3\nmov naveTipo,2\ncall GerarGrupoNaves')
check('semente',12345);check('naveX',-13)
for di in [0,2]:
    emit(f'mov di,{di}\ncall RemoverNave');carry(True)
    emit('call RemoverNave');carry(False)
for di in [1,6,65535]:
    emit(f'mov di,{di}\ncall RemoverNave');carry(False)
emit('call ContarNavesAtivas');check('ax',1)
emit('call GerarGrupoNaves');check('semente',12345);check('naveX+4',320)
emit('mov scorePartida,4321\nmov vidas,2\nmov tempoRestante,61\nmov rolagem,178\ncall AtualizarNaves')
check('naveX+4',319);check('naveX',-13);check('naveY+4',41)
emit('mov naveX+4,-12\ncall AtualizarNaves')
check('naveX+4',-13);check('naveAtiva+4',1)
emit('call GerarGrupoNaves');check('semente',12345)
emit('call AtualizarNaves');check('naveX+4',-14);check('naveAtiva+4',0)
check('semente',12345)
emit('call AtualizarNaves\ncall ContarNavesAtivas\ncmp ax,naveQuantidade\njne falhaE06')
for expr,val in [('scorePartida',4321),('vidas',2),('tempoRestante',61),('rolagem',178)]:check(expr,val)
# Cadencia: mesmo tick, tick insuficiente, duas atualizacoes, wrap de word.
emit('call ReiniciarNaves\nmov naveAtiva,1\nmov naveX,100\nmov naveY,15\nmov tickNave,100')
for tick,x in [(100,100),(101,100),(102,99),(102,99),(103,99),(104,98)]:
    emit(f'mov dx,{tick}\ncall AtualizarCadenciaNaves');check('dx',tick);check('naveX',x)
emit('mov tickNave,65535')
for tick,x in [(0,98),(1,97)]:
    emit(f'mov dx,{tick}\ncall AtualizarCadenciaNaves');check('naveX',x)
# Dois passos do jipe; nave 1 px nas mesmas duas amostras.
emit('call ReiniciarJipe\nmov teclasJipe,BIT_DIREITA\nmov tickNave,0\nmov naveX,100')
for tick in [1,2]:emit(f'call AtualizarJipe\nmov dx,{tick}\ncall AtualizarCadenciaNaves')
check('jipeX','2*PASSO_JIPE');check('naveX',99)
# Perder vida nao limpa nem repoe grupo/semente/cadencia.
emit('mov vidas,3\nmov semente,2468\ncall PerderVida')
for expr,val in [('naveX',99),('naveAtiva',1),('tickNave',2),('semente',2468)]:check(expr,val)
emit('call PrepararArquivosE06\nmov modoRegistro,1\nmov amostra,0')
emit('amostrasLoop:\ncall ReiniciarNaves\nmov ax,amostra\nmov semente,ax\ncall GerarGrupoNaves\ninc amostra\ncmp amostra,4096\njb amostrasLoop')
# 20.000 passos reais das duas geracoes, sem limpar naves entre grupos.
emit(f'call ReiniciarObstaculos\ncall ReiniciarNaves\nmov semente,12345\nmov distancia,0\nmov passos,{40000//inteiro(src,"PASSO_CENARIO")}\nmov modoRegistro,2')
emit('mistoLoop:\nadd distancia,PASSO_CENARIO\ncall AvancarCenario\ncall AvancarObstaculos\ncall RetirarObstaculos\ncall AtualizarNaves\ndec passos\njnz mistoLoop\nmov modoRegistro,0\ncall FecharArquivosE06')
emit('lea dx,okE06\nmov ah,09h\nint 21h\nmov ax,4C00h\nint 21h')
data=f'''caso dw 0
okE06 db 'PASS E06 LOGICA: {case} verificacoes; 4096 sementes; 40000 pixels de terreno em passos mistos.',13,10,'$'
erroE06 db 'FAIL E06 caso=$'
modoRegistro db 0
amostra dw 0
distancia dw 0
passos dw 0
nomesE06 db 'E06GER.BIN',0,'E06MIX.BIN',0,'E06GRP.BIN',0
handlesE06 dw 3 dup(0)
registro dw 13 dup(0)
'''
variant('E06LOG',data,'inicio proc\n'+'\n'.join(code)+'\ninicio endp\n'+(t/'E06LOG.INC').read_text())
p=t/(args.prefixo+'LOG.ASM');s=p.read_text().replace(args.prefixo,'E06')
# O rotulo pode ter um comentario explicativo antes da quebra de linha.
s=re.sub(r'(?m)^(gerarNavesProntas:[^\n]*\n)',r'\1    call RegistrarGrupoE06\n',s,count=1)
s=s.replace('    mov obstTipo[di],ax','    mov obstTipo[di],ax\n    call RegistrarObstE06')
save(p.name,s)
pixdata='''caso dw 0
okE06 db 'PASS E06 PIX: 390 quadros; naves/jipe/terreno/remocao/recorte.',13,10,'$'
nomePixels db 'E06PIX.BIN',0
handlePixels dw 0
tipoTeste dw 0
yTeste dw 15
xIndice dw 0
posTeste dw -15,-14,-13,-1,0,1,100,306,307,319,320,335,466
meta dw 17 dup(0)
.fardata videoTeste
 db 65000 dup(?)
'''
variant('E06PIX',pixdata,(t/'E06PIX.INC').read_text())
batch=['@echo off','if exist E06.OK del E06.OK','echo E06 - inicio > E06RESUL.LOG','if exist R06.OK del R06.OK','call R06TEST.BAT','if not exist R06.OK goto falha','config -set "cpu cycles=50000"']
for name in ['E06LOG','E06PIX']:
    batch += [f'tasm {name}.ASM > {name}.LOG','if errorlevel 1 goto falha',f'tlink /m {name}.OBJ >> {name}.LOG','if errorlevel 1 goto falha',f'{name} >> E06RESUL.LOG','if errorlevel 1 goto falha']
batch+=['echo PASS E06 >> E06RESUL.LOG','echo PASS > E06.OK','goto fim',':falha','echo FAIL E06 >> E06RESUL.LOG',':fim']
save('E06TEST.BAT','\n'.join(batch)+'\n')
(t/(args.prefixo+'-FONTE.txt')).write_text(hashlib.sha256((root/args.fonte).read_bytes()).hexdigest().upper()+'\n')
print(f'Gerados {args.prefixo}LOG ({case} verificacoes) e {args.prefixo}PIX; regressao {args.regressao} separada.')
