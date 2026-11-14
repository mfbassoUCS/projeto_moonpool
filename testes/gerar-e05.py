"""Gera variantes do snapshot E05 ou fonte/prefixo indicados para regressao."""
from pathlib import Path
import re, hashlib, argparse
from contrato_atual import inteiro
root=Path(__file__).resolve().parent.parent
t=root/'testes'
parser=argparse.ArgumentParser()
parser.add_argument('--fonte',default='testes/E05BASE.ASM')
parser.add_argument('--prefixo',default='E05')
args=parser.parse_args()
source=(root/args.fonte).read_text()
passo_cenario=inteiro(source,'PASSO_CENARIO')
ticks_cenario=inteiro(source,'TICKS_CENARIO')
passo_jipe=inteiro(source,'PASSO_JIPE')
def save(name,s):
    (t/name.replace('E05',args.prefixo)).write_bytes(s.replace('E05',args.prefixo).replace('\r\n','\n').replace('\n','\r\n').encode('ascii'))
def variant(name,data,main):
    s=source.replace('.code',data+'\n.code',1)
    s=re.sub(r'inicio proc.*?inicio endp',lambda _:main,s,count=1,flags=re.S)
    save(name+'.ASM',s)

# Reexecutar os oraculos independentes E03/E04; sem depender de ASM gerado.
regdata='''passoTeste dw 0
faseMem db 0
relogioLo dw 0
relogioHi dw 0
memOk db 'PASS MEM: 2 voltas completas; pixels, guarda, DF e relogio.',13,10,'$'
memErro db 'FAIL MEM fase='
erroFase db '?',13,10,'$'
.fardata videoTeste
 db 65000 dup(?)
.fardata referencia
 db 32000 dup(?)
'''
jipedata='''passoTeste dw 0
numeroCaso dw 0
faseMem db 0
include E04CASOS.INC
memOk db 'PASS JIPE: 80 casos; 640 quadros, 65000 bytes por quadro.',13,10,'$'
memErro db 'FAIL JIPE fase='
erroFase db '? caso=$'
.fardata videoTeste
 db 65000 dup(?)
.fardata referencia
 db 64000 dup(?)
.fardata esperado
 db 65000 dup(?)
'''
for dest,data,inc in [('E05REG',regdata,'E03MEM'),('E05JIPE',jipedata,'E04MEM')]:
    s=source.replace('.code',data+'.code',1)
    main=(t/(inc+'.INC')).read_text()
    if dest=='E05REG': main=main.replace('cmp passoTeste,320','cmp passoTeste,2*TELA_LARG/PASSO_CENARIO')
    s=re.sub(r'inicio proc.*?inicio endp',lambda _:main,s,count=1,flags=re.S)
    if dest=='E05REG': s=s.replace('call LerCentissegundos','call LerHoraTeste')
    save(dest+'.ASM',s)

code=[]; case=0
def emit(s): code.extend('    '+line if not line.endswith(':') else line for line in s.splitlines())
def check(expr,value):
    global case
    case+=1
    emit(f'mov caso,{case}\ncmp {expr},{value}\njne falhaE05')
def reset(typ=0,x=31):
    emit(f'call ZerarTeste\nmov obstTipo, {typ}\nmov obstX,{x}')
emit('mov ax,@data\nmov ds,ax\nmov ax,13h\nint 10h\nmov ax,VIDEO_SEG\nmov es,ax')
# Tres crateras e quatro rochas com a trajetoria real do jipe e rolagem real.
for typ in range(7):
    # Arranjos explicitos: a rocha exige ganhar altura antes da sobreposicao.
    # Manter o caso historico nos snapshots; atual: gap 24, longe dos limites.
    reset(typ,31 if passo_jipe==3 else 44)
    emit('call ConferirObstaculos\nmov al,SCAN_CIMA\ncall RegistrarScanJipe\nmov al,SCAN_DIREITA\ncall RegistrarScanJipe')
    for tick in range(1,16):
        if tick%ticks_cenario==0: emit('call AvancarCenario\ncall AvancarObstaculos\nmov ax,PASSO_CENARIO\ncall ContarTopo')
        emit('call AtualizarJipe\ncall ConferirObstaculos\ncall RetirarObstaculos')
        check('vidas',3)
        if tick<14: check('scorePartida',0)
    check('estadoSalto','SALTO_CHAO'); check('scorePartida',50)
    emit('call ConferirObstaculos\ncall ConferirObstaculos'); check('scorePartida',50)
# Choques em todos os tipos; repeticao custa apenas uma vida.
for typ in range(7):
    reset(typ,10)
    emit('mov tempoRestante,63\nmov fracaoSegundo,42\nmov margemInicial,0\nmov rolagem,178\nmov scorePartida,250\nmov teclasJipe,BIT_CIMA+BIT_DIREITA\nmov pedidoSalto,1\ncall ConferirObstaculos\ncall ConferirObstaculos\ncall PerderVida')
    for expr,val in [('vidas',2),('jipeAtivo',0),('scorePartida',250),('tempoRestante',63),('fracaoSegundo',42),('rolagem',178),('pedidoSalto',0),('obstPassagem','PASS_INVALIDO')]: check(expr,val)
    emit('call TentarReporJipe'); check('jipeAtivo',0)
    emit('mov obstX,-14\ncall TentarReporJipe')
    for expr,val in [('jipeAtivo',1),('jipeX',0),('jipeY',183),('teclasJipe','BIT_CIMA+BIT_DIREITA')]: check(expr,val)
    emit('mov al,SCAN_CIMA\ncall RegistrarScanJipe\ncall AtualizarJipe')
    check('jipeX','PASSO_JIPE'); check('estadoSalto','SALTO_CHAO')
    emit('mov al,SCAN_CIMA+80h\ncall RegistrarScanJipe\nmov al,SCAN_CIMA\ncall RegistrarScanJipe\ncall AtualizarJipe')
    check('estadoSalto','SALTO_SUBINDO')
    # Simula travessia posterior do MESMO obstaculo fatal: proibida pontuacao.
    emit('mov jipeX,0\nmov obstX,31\ncall ConferirObstaculos\nmov jipeX,25\nmov jipeY,168\nmov estadoSalto,SALTO_TOPO\ncall ConferirObstaculos\nmov jipeX,60\nmov jipeY,183\nmov estadoSalto,SALTO_CHAO\ncall ConferirObstaculos')
    check('scorePartida',250)
# Contato exclusivo; crateras no chao, rocha a altura geometricamente exata.
for typ in [0,3]:
    reset(typ,20); emit('call ConferirObstaculos'); check('vidas',3)
    emit('mov obstX,19\nmov jipeY,180\nmov estadoSalto,SALTO_DESCENDO\ncall ConferirObstaculos')
    check('vidas',3 if typ==0 else 2)
reset(0,10); emit('mov jipeY,180\nmov estadoSalto,SALTO_DESCENDO\ncall ConferirObstaculos\ncall AtualizarJipe\ncall ConferirObstaculos'); check('vidas',2)
reset(3,10); emit('mov jipeY,173\nmov estadoSalto,SALTO_DESCENDO\ncall ConferirObstaculos'); check('vidas',3)
emit('mov jipeY,174\ncall ConferirObstaculos'); check('vidas',2)
# Saida simples, sobreposicao inicial, recuo e travessia interrompida nao pontuam.
reset(0,-14); emit('call ConferirObstaculos\ncall RetirarObstaculos'); check('scorePartida',0); check('obstTipo','OBST_LIVRE')
reset(0,0); emit('mov jipeY,168\nmov estadoSalto,SALTO_TOPO\ncall ConferirObstaculos\nmov jipeX,30\nmov jipeY,183\nmov estadoSalto,SALTO_CHAO\ncall ConferirObstaculos'); check('scorePartida',0)
reset(0,31); emit('call ConferirObstaculos\nmov jipeX,20\nmov jipeY,168\nmov estadoSalto,SALTO_TOPO\ncall ConferirObstaculos\nmov jipeX,0\nmov jipeY,183\nmov estadoSalto,SALTO_CHAO\ncall ConferirObstaculos'); check('scorePartida',0)
reset(0,31); emit('call ConferirObstaculos\nmov jipeX,20\nmov jipeY,168\nmov estadoSalto,SALTO_TOPO\ncall ConferirObstaculos\nmov obstX,-14\ncall ConferirObstaculos\ncall RetirarObstaculos'); check('obstPassagem','PASS_CRUZOU'); check('obstTipo',0); check('scorePartida',0)
emit('mov jipeY,183\nmov estadoSalto,SALTO_CHAO\ncall ConferirObstaculos\ncall RetirarObstaculos'); check('scorePartida',50); check('obstTipo','OBST_LIVRE')
# Colisao tem prioridade sobre candidato a pontuar; dois choques = uma vida.
reset(0,-14); emit('mov obstPassagem,PASS_CRUZOU\nmov obstTipo+2,3\nmov obstX+2,0\nmov obstTipo+4,1\nmov obstX+4,1\ncall ConferirObstaculos'); check('vidas',2); check('scorePartida',0); check('obstPassagem','PASS_INVALIDO')
emit('mov al,SCAN_CIMA\ncall RegistrarScanJipe'); check('pedidoSalto',0)
# Ultima vida e saturacao da interface de pontos.
reset(3,10); emit('mov vidas,1\ncall ConferirObstaculos\ncall TentarReporJipe'); check('vidas',0); check('jipeAtivo',0)
for start,add,end in [(65450,50,65500),(65500,50,65535),(65535,50,65535),(0,50,50)]:
    emit(f'mov scorePartida,{start}\nmov ax,{add}\ncall SomarPontos'); check('scorePartida',end)
# Geracao de 20000 pixels; exportar nascimentos para oraculo Python.
emit(f'call ZerarTeste\nmov semente,12345\nmov proximoEm,0\nmov jipeAtivo,0\nmov gerando,1\nmov passos,{20000//passo_cenario}')
emit('gerarLoop:\nadd distancia,PASSO_CENARIO\ncall AvancarCenario\ncall AvancarObstaculos\ncall RetirarObstaculos\ndec passos\njnz gerarLoop\nmov gerando,0\nlea dx,nomeGeracao\nlea si,nascimentos\nmov cx,nascBytes\ncall GravarDados')
emit('mov ax,3\nint 10h\nlea dx,okE05\nmov ah,09h\nint 21h\nmov ax,4C00h\nint 21h')
main='inicio proc\n'+'\n'.join(code)+'\ninicio endp\n'+(t/'E05LOG.INC').read_text()
data=f'''caso dw 0
okE05 db 'PASS E05 LOGICA: {case} verificacoes; 7 saltos reais; 20000 pixels gerados.',13,10,'$'
erroE05 db 'FAIL E05 caso=$'
gerando db 0
distancia dw 0
passos dw 0
nascBytes dw 0
nascimentos dw 1024 dup(0)
nomeGeracao db 'E05GER.BIN',0
'''
variant('E05LOG',data,main)
p=t/(args.prefixo+'LOG.ASM');s=p.read_text().replace('    mov obstTipo[di],ax','    mov obstTipo[di],ax\n    call RegistrarNascimento');save(p.name,s)

pixdata='''caso dw 0
okE05 db 'PASS E05 PIX: 336 quadros exportados com guarda e metadados.',13,10,'$'
erroE05 db 'FAIL E05 PIX caso=$'
nomePixels db 'E05PIX.BIN',0
handlePixels dw 0
tipoTeste dw 0
xIndice dw 0
posTeste dw -15,-14,-13,-1,0,1,10,30,308,319,320,321
meta dw 8 dup(0)
.fardata videoTeste
 db 65000 dup(?)
'''
variant('E05PIX',pixdata,(t/'E05PIX.INC').read_text())
# Programa inteiro: primeira morte por geracao natural; outras por arranjo controlado.
s=source.replace('.code',(t/'E05AUTO.DAT').read_text()+'\n.code',1)
# Preservar comentarios ao lado do rotulo no fonte de estudo.
s=re.sub(r'(?m)^(ciclo:[^\n]*\n)',r'\1    call DirigirE05\n',s,count=1)
s=s.replace('end inicio',(t/'E05AUTO.INC').read_text()+'\nend inicio')
save('E05AUTO.ASM',s)
batch=['@echo off','if exist E05.OK del E05.OK','echo E05 - inicio > E05RESUL.LOG','config -set "cpu cycles=50000"']
for name in ['E05REG','E05JIPE','E05LOG','E05PIX','E05AUTO']:
    batch += [f'tasm {name}.ASM > {name}.LOG','if errorlevel 1 goto falha',f'tlink /m {name}.OBJ >> {name}.LOG','if errorlevel 1 goto falha']
    batch += [f'{name} >> E05RESUL.LOG','if errorlevel 1 goto falha']
batch+=['MODO >> E05RESUL.LOG','if errorlevel 1 goto falha','echo PASS E05 >> E05RESUL.LOG','echo PASS > E05.OK','goto fim',':falha','echo FAIL E05 >> E05RESUL.LOG',':fim']
save('E05TEST.BAT','\n'.join(batch)+'\n')
(t/(args.prefixo+'-FONTE.txt')).write_text(hashlib.sha256((root/args.fonte).read_bytes()).hexdigest().upper()+'\n')
print(f'Gerados testes {args.prefixo}: {case} verificacoes explicitas e regressao E03/E04.')
