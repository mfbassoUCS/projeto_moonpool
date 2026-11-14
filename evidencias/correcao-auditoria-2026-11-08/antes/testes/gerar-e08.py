"""Harnesses E08: executam as rotinas ASM reais, sem testes no EXE entregue."""
from pathlib import Path
import hashlib, re, subprocess, sys
root=Path(__file__).resolve().parent.parent
t=root/'testes'
src=(root/'MOON.ASM').read_text()
def save(name,s):
    (t/name).write_bytes(s.replace('\r\n','\n').replace('\n','\r\n').encode('ascii'))
def variant(name,data,main):
    s=src.replace('.code',data+'\n.code',1)
    s=re.sub(r'inicio proc.*?inicio endp',lambda _:main,s,count=1,flags=re.S)
    save(name+'.ASM',s)

# Nomes novos; os resultados E01-E07 nao sao reexecutados/sobrescritos.
subprocess.run([sys.executable,str(t/'gerar-e07.py'),'--fonte','MOON.ASM',
    '--prefixo','N08','--regressao','R08'],check=True)
# Isolar o oraculo antigo do minimo, que espera ceu sem tiros. A suite E08
# abaixo testa emissao/impactos no fluxo completo, com a rotina habilitada.
p=t/'R08AUTO.ASM'
save(p.name,p.read_text().replace('    call DispararNaves',
    '    ; Regressao isolada do minimo: sem emissao inimiga neste harness.'))

support='''
; Funcao: arranjo controlado. Entrada: nenhuma. Saida: partida limpa.
ZerarE08 proc near
    call ReiniciarJipe
    call ReiniciarObstaculos
    call ReiniciarNaves
    call ReiniciarDisparos
    mov scorePartida,0
    mov vidas,3
    mov tempoRestante,63
    mov fracaoSegundo,42
    mov rolagem,178
    mov semente,12345
    mov proximoEm,1000
    mov estado,ESTADO_PARTIDA
    ret
ZerarE08 endp
; Funcao: encerrar com numero do caso. Entrada: caso. Saida: ERRORLEVEL 1.
FalhaE08 proc near
    cld
    call RestaurarTecladoJogo
    mov ax,3
    int 10h
    lea dx,erroE08
    mov ah,09h
    int 21h
    mov ax,caso
    call FormatarScore
    lea dx,digitosScore
    mov bx,1
    mov cx,5
    mov ah,40h
    int 21h
    mov ax,4C01h
    int 21h
FalhaE08 endp
'''
code=[];case=0
def emit(s):code.extend('    '+line if not line.endswith(':') else line for line in s.splitlines())
def check(expr,val):
    global case
    case+=1;emit(f'mov caso,{case}\ncmp {expr},{val}\njne FalhaE08')
def carry(yes):
    global case
    case+=1;emit(f'mov caso,{case}\n'+('jnc' if yes else 'jc')+' FalhaE08')
def reset():emit('call ZerarE08')
def shot(slot,x,y,d=0):emit(f'mov tiroAtivo+{slot},1\nmov tiroX+{slot},{x}\nmov tiroY+{slot},{y}\nmov tiroDistancia+{slot},{d}')
emit('mov ax,@data\nmov ds,ax')
# T17: origem real no chao e em todas as alturas, dois canhoes atomicos.
for x in [0,140]:
    for y in [183,180,177,174,171,168]:
        reset();emit(f'mov jipeX,{x}\nmov jipeY,{y}\ncall DispararJipe');carry(True)
        for a,v in [('tiroAtivo',1),('tiroAtivo+16',1),('tiroX',x+6),('tiroY',y-4),('tiroX+16',x+20),('tiroY+16',y+4)]:check(a,v)
        emit('mov jipeX,70\nmov jipeY,174\ncall DispararJipe');carry(True)
        check('tiroX',x+6);check('tiroY',y-4);check('tiroX+2',76);check('tiroAtivo+18',1)
# Oito pares sem sobrescrever nenhum. Recusa inteira se apenas uma faixa lotar.
reset()
for i in range(8):emit(f'mov jipeX,{i*3}\ncall DispararJipe');carry(True)
emit('mov jipeX,100\ncall DispararJipe');carry(False)
for i in range(8):check(f'tiroX+{i*2}',i*3+6);check(f'tiroX+{16+i*2}',i*3+20)
emit('mov tiroAtivo,0\ncall DispararJipe');carry(False);check('tiroAtivo',0)
emit('mov tiroAtivo+16,0\ncall DispararJipe');carry(True);check('tiroX',106);check('tiroX+16',120)
reset();emit('mov tiroAtivo,1\nmov jipeAtivo,0\ncall DispararJipe');carry(False);check('tiroAtivo+16',0)
# Cadencia mantida, tap curto, soltura, repeticao, tick repetido e wrap.
reset();emit('mov al,SCAN_ESPACO\ncall RegistrarScanJipe\nmov dx,1\ncall AtualizarCadenciaDisparos')
check('tiroAtivo',1);check('tiroAtivo+16',1);check('esperaJipe',6);check('tiroY',179)
emit('call AtualizarCadenciaDisparos');check('tiroY',179)
for tick in range(2,7):emit(f'mov dx,{tick}\ncall AtualizarCadenciaDisparos')
check('tiroAtivo+2',0);check('esperaJipe',1)
emit('mov dx,7\ncall AtualizarCadenciaDisparos');check('tiroAtivo+2',1);check('tiroY',155)
emit('mov al,SCAN_ESPACO+80h\ncall RegistrarScanJipe');check('teclasJipe',0)
reset();emit('mov al,SCAN_ESPACO\ncall RegistrarScanJipe\nmov al,SCAN_ESPACO+80h\ncall RegistrarScanJipe\nmov dx,1\ncall AtualizarCadenciaDisparos');check('tiroAtivo',1)
emit('mov tickTiro,65535\nmov dx,0\ncall AtualizarCadenciaDisparos');check('tiroY',175);check('dx',0)
reset();emit('mov jipeAtivo,0\nmov al,SCAN_ESPACO\ncall RegistrarScanJipe');check('pedidoTiro',0)
# T18: alcance relativo exato 50, imune a deslocamentos posteriores do jipe.
for x in [0,70,140]:
    reset();emit(f'mov jipeX,{x}\ncall DispararJipe')
    for n in range(12):emit(f'mov jipeX,{140 if n%2 else 0}\ncall MoverDisparos')
    check('tiroAtivo+16',1);check('tiroDistancia+16',48);check('tiroX+16',x+68)
    emit('call MoverDisparos');check('tiroAtivo+16',0);check('tiroDistancia+16',50);check('tiroX+16',x+70)
    check('scorePartida',0)
reset();shot(0,10,16);emit('call MoverDisparos');check('tiroAtivo',0);check('tiroY',15);check('scorePartida',0)
# Nave, uma remocao/100; bordas laterais, signed, extremo Y=15 e todas vagas.
for slot in [0,2,4]:
    for nx,tx,hit in [(-13,0,True),(10,8,False),(10,9,True),(10,24,False),(306,319,True)]:
        reset();emit(f'mov naveAtiva+{slot},1\nmov naveX+{slot},{nx}\nmov naveY+{slot},15')
        shot(0,tx,29);emit('call MoverDisparos')
        check(f'naveAtiva+{slot}',0 if hit else 1);check('scorePartida',100 if hit else 0)
        emit('call ConferirDisparos');check('scorePartida',100 if hit else 0)
reset();emit('mov naveAtiva,1\nmov naveX,10\nmov naveY,15')
shot(0,10,16);shot(2,10,16);emit('call ConferirDisparos');check('scorePartida',100);check('tiroAtivo+2',1)
emit('call AtualizarNaves\ncall ContarNavesAtivas\ncmp ax,0\nje FalhaE08');check('tiroAtivo+2',1)
reset();emit('mov naveAtiva,1\nmov naveX,10\nmov naveY,86\nmov scorePartida,65500')
shot(0,10,100);emit('call MoverDisparos');check('scorePartida',65535)
# T19: todos os tipos; dano persistente, nao por outros tiros ou pelo tempo.
for typ in range(7):
    reset();emit(f'mov obstTipo,{typ}\nmov obstX,30')
    shot(16,26,187);emit('call MoverDisparos')
    check('obstTipo',65535 if typ in [4,5] else typ)
    check('scorePartida',50 if typ in [4,5] else 0)
    check('tiroAtivo+16',1 if typ<3 else 0)
    check('obstImpactos',1 if typ>=4 else 0)
    if typ==6:
        shot(18,50,187);emit('call MoverDisparos');check('obstImpactos',1)
        emit('call PerderVida');check('obstImpactos',1)
        shot(20,26,187);emit('call MoverDisparos');check('obstTipo',65535);check('scorePartida',50)
    emit('call ConferirDisparos');check('scorePartida',50 if typ>=4 else 0)
# Pontuada por salto nao paga ao destruir; candidata paga apenas destruicao.
for passage in [0,2,3,4,5]:
    reset();emit(f'mov obstTipo,4\nmov obstX,30\nmov obstPassagem,{passage}\nmov scorePartida,50')
    shot(16,26,187);emit('call MoverDisparos\ncall ConferirObstaculos')
    check('scorePartida',50 if passage==4 else 100);check('obstTipo',65535)
# Frontal no salto nao acerta rocha abaixo; encostar bordas e limite.
for y,hit in [(181,False),(182,True),(168,False),(193,False)]:
    reset();emit('mov obstTipo,4\nmov obstX,30');shot(16,27,y)
    emit('call ConferirDisparos');check('obstTipo',65535 if hit else 4)
reset();emit('mov obstTipo,4\nmov obstX,73');shot(16,69,187,49)
emit('call MoverDisparos');check('tiroDistancia+16',50);check('obstTipo',65535);check('scorePartida',50)
reset();emit('mov obstImpactos,1\nmov proximoEm,0\nmov proximaRocha,1\ncall AvancarObstaculos');check('obstImpactos',0)
# T20: extremidade inferior, laterais, meio, acima/abaixo e salto.
for jx,jy,tx,ty,hit in [(10,183,8,179,False),(10,183,9,179,True),(10,183,30,179,False),
    (10,183,20,178,False),(10,183,20,179,True),(10,183,20,193,False),
    (10,168,20,164,True),(10,168,20,178,False)]:
    reset();emit(f'mov jipeX,{jx}\nmov jipeY,{jy}');shot(32,tx,ty)
    emit('call ConferirDisparos');check('vidas',2 if hit else 3);check('jipeAtivo',0 if hit else 1)
    check('tempoRestante',63);check('fracaoSegundo',42);check('rolagem',178)
reset();shot(32,2,179);shot(34,2,179)
emit('call ConferirDisparos');check('vidas',2);check('tiroAtivo+34',1)
emit('call TentarReporJipe');check('jipeAtivo',0)
for _ in range(6):emit('call MoverDisparos')
emit('call TentarReporJipe');check('vidas',2);check('jipeAtivo',1);check('jipeX',0)
reset();shot(32,100,188);emit('call MoverDisparos');check('tiroY+32',189);check('tiroAtivo+32',0);check('vidas',3)
# Emissao das tres naves visiveis; espera congela fora da tela; capacidade.
reset()
for i in range(3):emit(f'mov naveAtiva+{2*i},1\nmov naveX+{2*i},{40+50*i}\nmov naveY+{2*i},{15+30*i}')
for _ in range(17):emit('call DispararNaves')
check('tiroAtivo+32',0)
emit('call DispararNaves')
for i in range(3):check(f'tiroX+{32+2*i}',46+50*i);check(f'tiroY+{32+2*i}',29+30*i)
emit('mov di,0\ncall RemoverNave\nmov di,2\ncall RemoverNave\nmov di,4\ncall RemoverNave\ncall AtualizarNaves')
check('tiroAtivo+32',1);check('tiroX+32',46)
reset();emit('mov naveAtiva,1\nmov naveX,320\nmov naveY,15\nmov esperaNave,1\ncall DispararNaves')
check('esperaNave',1);check('tiroAtivo+32',0)
emit('mov naveX,-7\ncall DispararNaves');check('tiroAtivo+32',0)
emit('mov naveX,-6\ncall DispararNaves');check('tiroAtivo+32',1);check('tiroX+32',0)
reset();emit('mov naveAtiva,1\nmov naveX,100\nmov naveY,15')
for i in range(12):emit('mov esperaNave,0\ncall DispararNaves')
emit('mov naveX,200\nmov esperaNave,0\ncall DispararNaves')
for i in range(12):check(f'tiroX+{32+2*i}',106)
emit('mov tiroAtivo+38,0\ncall DispararNaves');check('tiroX+38',206);check('tiroX+36',106)
emit('call ReiniciarDisparos')
for i in range(28):check(f'tiroAtivo+{2*i}',0)
check('semente',12345)
emit('lea dx,okE08\nmov ah,09h\nint 21h\nmov ax,4C00h\nint 21h')
data=f"caso dw 0\nerroE08 db 'FAIL E08 LOG caso=$'\nokE08 db 'PASS E08 LOG: {case} verificacoes T17-T20.',13,10,'$'\n"
variant('E08LOG',data,'inicio proc\n'+'\n'.join(code)+'\ninicio endp\n'+support)

# Pixels: captura metadados do estado e 65000 bytes, oraculo externo independente.
pixdata="""caso dw 0
numeroQuadroE08 dw 0
tickE08 dw 0
handleE08 dw 0
nomeE08 db 'E08PIX.BIN',0
metaE08 dw 6 dup(0)
erroE08 db 'FAIL E08 PIX caso=$'
okE08 db 'PASS E08 PIX: composicao de tiros/ceu/terreno/jipe/guardas.',13,10,'$'
.fardata videoTeste
 db 65000 dup(?)
"""
variant('E08PIX',pixdata,(t/'E08PIX.INC').read_text()+'\n'+support)
variant('E08AUTO',(t/'E08AUTO.DAT').read_text(),(t/'E08AUTO.INC').read_text()+'\n'+support)
batch=['@echo off','echo E08 - inicio > E08RESUL.LOG','call N08TEST.BAT','config -set "cpu cycles=50000"']
for name in ['E08LOG','E08PIX','E08AUTO']:
    batch += [f'tasm {name}.ASM > {name}.LOG','if errorlevel 1 goto falha',
              f'tlink /m {name}.OBJ >> {name}.LOG','if errorlevel 1 goto falha']
    if name=='E08AUTO':batch+=['config -set "cpu cycles=auto"']
    batch += [f'{name} >> E08RESUL.LOG','if errorlevel 1 goto falha']
batch+=['MODO >> E08RESUL.LOG','if errorlevel 1 goto falha','echo PASS E08 >> E08RESUL.LOG',
        'goto fim',':falha','echo FAIL E08 >> E08RESUL.LOG',':fim','config -set "cpu cycles=auto"']
save('E08TEST.BAT','\n'.join(batch)+'\n')
(t/'E08-FONTE.txt').write_text(hashlib.sha256((root/'MOON.ASM').read_bytes()).hexdigest().upper()+'\n')
print(f'E08: {case} verificacoes de logica, pixels e fluxo; regressao N08/R08.')
