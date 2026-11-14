"""Integra testes existentes no fonte atual e acrescenta menu/setor/fim."""
from pathlib import Path
import argparse, re, subprocess, sys
root=Path(__file__).resolve().parent.parent;t=root/'testes'
parser=argparse.ArgumentParser()
parser.add_argument('--fonte',default='testes/E07BASE.ASM')
parser.add_argument('--prefixo',default='E07')
parser.add_argument('--regressao',default='R07')
args=parser.parse_args()
def nomes(s):return s.replace('E07',args.prefixo).replace('R07',args.regressao)
src=(root/args.fonte).read_text()
subprocess.run([sys.executable,str(t/'gerar-e06.py'),'--fonte',args.fonte,'--prefixo',args.prefixo,'--regressao',args.regressao],check=True)
def save(name,s):(t/nomes(name)).write_bytes(nomes(s).replace('\r\n','\n').replace('\n','\r\n').encode('ascii'))
def variant(name,data,main):
    s=src.replace('.code',data+'\n.code',1)
    s=re.sub(r'inicio proc.*?inicio endp',lambda _:main,s,count=1,flags=re.S)
    save(name+'.ASM',s)
# Reaplicar o oraculo de sprites/menu E02, sem duplicar seus casos.
gen=(t/'gerar-e02.ps1').read_text()
data=re.search(r"\$memData = @'\n(.*?)\n'@",gen,re.S)[1].replace('.code','')
assertions=re.search(r"\$assertions = @'\n(.*?)\n'@",gen,re.S)[1]
variant('E07MEM',assertions+'\n'+data,(t/'E02MEM.INC').read_text())
data='''faseTela dw 0
quadrosTela dw 0
horaTelaLo dw 0
horaTelaHi dw 0
esperaTelaLo dw 0
esperaTelaHi dw 0
nomeTela db 'E07INI.RAW',0
nomeMov db 'E07MOV.RAW',0
nomeSel db 'E07SEL.RAW',0
nomeSet db 'E07SET.RAW',0
nomeFim db 'E07FIM.RAW',0
nomeRet db 'E07RET.RAW',0
nomeMedidas db 'E07TELA.BIN',0
medidasTela dw 4 dup(0)
telaOk db 'PASS E07 TELAS: 320 quadros/ticks; selecao; SETOR/Enter;',13,10
 db '2 s sem consumir tempo; Enter antigo; reset; GAME OVER; letra/seta; Sair.',13,10,'$'
telaErro db 'FAIL E07 TELAS fase=$'
'''
variant('E07TELA',data,(t/'E07TELA.INC').read_text())
p=t/nomes('E07TELA.ASM');s=p.read_text().replace('    call MoverSpritesMenu','    call MoverSpritesMenu\n    inc quadrosTela')
save(p.name,s)
p=t/nomes('E07TEST.BAT');s=p.read_text().replace(args.prefixo,'E07').replace(args.regressao,'R07')
extra=[]
for name in ['E07MEM','E07TELA']:
    extra += [f'tasm {name}.ASM > {name}.LOG','if errorlevel 1 goto falha',f'tlink /m {name}.OBJ >> {name}.LOG','if errorlevel 1 goto falha']
    if name=='E07TELA':extra+=['config -set "cpu cycles=auto"']
    extra += [f'{name} >> E07RESUL.LOG','if errorlevel 1 goto falha']
extra += ['MODO >> E07RESUL.LOG','if errorlevel 1 goto falha']
s=s.replace('echo PASS E07 >> E07RESUL.LOG','\n'.join(extra)+'\necho PASS E07 >> E07RESUL.LOG')
save(p.name,s)
print('Gerados E07MEM/E07TELA e suite completa E07/R07 com nomes separados.')
