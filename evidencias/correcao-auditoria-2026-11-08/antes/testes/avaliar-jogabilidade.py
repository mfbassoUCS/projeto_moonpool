"""Gera ensaios das rotinas reais: janela de salto e tempo de composicao.
Nao modifica o fonte do jogo. Saidas isoladas em evidencias/ajuste-jogabilidade.
Uso: python testes/avaliar-jogabilidade.py [--conferir]
"""
from pathlib import Path
import hashlib
import json
import re
import struct
import subprocess
import sys

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / 'evidencias' / 'ajuste-jogabilidade'
DATA = '''
testeTipo dw 0
testeGap dw 0
testeFase dw 0
testeTick dw 0
testeIndice dw 0
testeInicio dw 0,0
testeDuracao dw 0,0
testeResultados db 854 dup(0)
nomeSaltos db 'SALTO.BIN',0
nomeTempo db 'TEMPO.BIN',0
'''
MAIN = '''
inicio proc
    mov ax,@data
    mov ds,ax
    mov ax,VIDEO_MODO
    int 10h
    mov ax,VIDEO_SEG
    mov es,ax
    cld
testeCaso:
    call ReiniciarJipe
    call ReiniciarObstaculos
    call ReiniciarNaves
    call ReiniciarDisparos
    mov proximoEm,30000
    mov scorePartida,0
    mov vidas,3
    mov jipeX,20
    mov ax,testeTipo
    mov obstTipo,ax
    mov ax,testeGap
    add ax,40
    mov obstX,ax
    mov obstPassagem,PASS_FRENTE
    mov teclasJipe,BIT_DIREITA
    mov pedidoSalto,1
    mov testeTick,0
testeFrame:
    inc testeTick
    mov ax,testeTick
    add ax,testeFase
    test ax,1
    jnz testeJipe
    call AvancarObstaculos
    mov ax,PASSO_CENARIO
    call ContarTopo
testeJipe:
    call AtualizarJipe
    call ConferirObstaculos
    cmp jipeAtivo,0
    je testeRegistrar
    cmp estadoSalto,SALTO_CHAO
    je testeRegistrar
    cmp testeTick,60
    jb testeFrame
testeRegistrar:
    mov di,testeIndice
    mov al,0
    cmp scorePartida,50
    jne testeGravarResultado
    cmp jipeAtivo,1
    jne testeGravarResultado
    mov al,1
testeGravarResultado:
    mov testeResultados[di],al
    inc testeIndice
    inc testeGap
    cmp testeGap,61
    jb testeCaso
    mov testeGap,0
    inc testeTipo
    cmp testeTipo,7
    jb testeCaso
    mov testeTipo,0
    inc testeFase
    cmp testeFase,2
    jb testeCaso
    lea dx,nomeSaltos
    lea si,testeResultados
    mov cx,854
    call GravarEnsaio
    call ReiniciarJipe
    call ReiniciarObstaculos
    call ReiniciarNaves
    call ReiniciarDisparos
    mov tempoRestante,90
    mov vidas,3
    mov scorePartida,0
    mov rolagem,0
    call LimparTela
    call DesenharStatus
    mov testeTick,0
    call LerCentissegundos
    mov testeInicio,ax
    mov testeInicio+2,dx
testeDesenho:
    mov cenarioMudou,1
    mov navesMudou,1
    mov tirosMudou,1
    call AvancarCenario
    call DesenharQuadroPartida
    inc testeTick
    cmp testeTick,40
    jb testeDesenho
    call LerCentissegundos
    sub ax,testeInicio
    sbb dx,testeInicio+2
    mov testeDuracao,ax
    mov testeDuracao+2,dx
    lea dx,nomeTempo
    lea si,testeDuracao
    mov cx,4
    call GravarEnsaio
    mov ax,3
    int 10h
    mov ax,4C00h
    int 21h
inicio endp
; Funcao: gravar dados do ensaio. Entrada DS:DX nome, DS:SI dados,CX tamanho.
; Saida: arquivo ou retorno DOS 1. Altera AX,BX,CX,DX,flags.
GravarEnsaio proc near
    push cx
    xor cx,cx
    mov ah,3Ch
    int 21h
    jc ensaioFalhou
    mov bx,ax
    pop cx
    mov dx,si
    mov ah,40h
    int 21h
    jc ensaioFalhou
    cmp ax,cx
    jne ensaioFalhou
    mov ah,3Eh
    int 21h
    jc ensaioFalhou
    ret
ensaioFalhou:
    mov ax,4C01h
    int 21h
GravarEnsaio endp
'''

def gerar():
    for name, path in [('JOLD', OUT/'ANTES.ASM'), ('JNEW', ROOT/'MOON.ASM')]:
        source = path.read_text(encoding='ascii')
        source = source.replace('.code', DATA+'\n.code', 1)
        source = re.sub(r'inicio proc.*?inicio endp', lambda _: MAIN, source, count=1, flags=re.S)
        (OUT/(name+'.ASM')).write_bytes(source.replace('\r\n','\n').replace('\n','\r\n').encode('ascii'))
    batch = ['@echo off', 'echo inicio > ENSAIO.LOG']
    for exe in ('JOLD','JNEW'):
        batch += [f'tasm {exe}.ASM >> ENSAIO.LOG', 'if errorlevel 1 goto falha',
                  f'tlink {exe}.OBJ >> ENSAIO.LOG', 'if errorlevel 1 goto falha']
    # CONFIG.COM vive em Z:. PATH apenas T: oculta o comando; use caminho
    # absoluto e registre a configuracao efetiva para nao falsear a medicao.
    for exe, cycles, prefix in [('JOLD','3000','ANTAUTO'),('JOLD','50000','ANTFAST'),('JNEW','50000','NOVFAST')]:
        batch += [f'z:\\config.com -set "cpu cycles={cycles}"', f'z:\\config.com -get "cpu cycles" > {prefix}.CPU', exe, 'if errorlevel 1 goto falha',
                  f'copy SALTO.BIN {prefix}S.BIN > nul', f'copy TEMPO.BIN {prefix}T.BIN > nul']
    batch += ['echo PASS ENSAIO >> ENSAIO.LOG', 'goto fim', ':falha', 'echo FAIL ENSAIO >> ENSAIO.LOG', ':fim']
    (OUT/'ENSAIO.BAT').write_bytes(('\r\n'.join(batch)+'\r\n').encode('ascii'))

def conferir():
    log = (OUT/'ENSAIO.LOG').read_text()
    assert 'PASS ENSAIO' in log and 'FAIL' not in log, log
    result = {}
    for prefix in ('ANTAUTO','ANTFAST','NOVFAST'):
        cpu = (OUT/(prefix+'.CPU')).read_text().strip()
        assert cpu == ('3000' if prefix=='ANTAUTO' else '50000'), (prefix,cpu)
        raw = (OUT/(prefix+'S.BIN')).read_bytes()
        assert len(raw)==854 and set(raw)<={0,1}
        cent = struct.unpack('<I',(OUT/(prefix+'T.BIN')).read_bytes())[0]
        windows = []
        for phase in range(2):
            windows.append([[gap for gap in range(61) if raw[(phase*7+kind)*61+gap]] for kind in range(7)])
        result[prefix] = dict(ciclos=cpu, centissegundos_40_quadros=cent, quadros_por_segundo=round(4000/cent,2),
                              gaps_seguros_por_fase_e_tipo=windows)
    assert (OUT/'ANTAUTOS.BIN').read_bytes()==(OUT/'ANTFASTS.BIN').read_bytes(), 'CPU alterou logica isolada'
    for phase in range(2):
        for kind in range(7):
            old = result['ANTFAST']['gaps_seguros_por_fase_e_tipo'][phase][kind]
            new = result['NOVFAST']['gaps_seguros_por_fase_e_tipo'][phase][kind]
            assert len(new)>len(old), (phase,kind,old,new)
    result['fonte_sha256'] = hashlib.sha256((ROOT/'MOON.ASM').read_bytes()).hexdigest()
    result['limites'] = 'Ensaio controlado: direita+salto, jipe X20, 61 gaps, 7 tipos, 2 fases. Mede composicao de 40 quadros, nao FPS do laco nem conforto humano. Sem tiros ativos no ensaio de salto.'
    (OUT/'medidas.json').write_text(json.dumps(result,indent=2)+'\n')
    for prefix, row in list(result.items())[:3]:
        print(prefix, row['centissegundos_40_quadros'], 'centesimos / 40 quadros;',
              'gaps rocha fase0:', row['gaps_seguros_por_fase_e_tipo'][0][3])
    print('PASS: janela segura maior nos 7 tipos / 2 fases; logica antiga igual em auto/50000.')

def regressao():
    subprocess.run([sys.executable,str(ROOT/'testes/gerar-e08.py')],check=True,cwd=ROOT)
    tests = ROOT/'testes'
    source = (tests/'E08AUTO.ASM').read_text()
    needle = '    mov esperaNave,0\n    mov al,SCAN_ESPACO'
    assert needle in source
    # O caso original espera UMA morte, mas deixava a nave emitir varios
    # brancos antes de morrer. Em CPU rapida um segundo tambem atinge X=0.
    # Isolar explicitamente um disparo real, sem mudar o codigo do jogo.
    source = source.replace(needle, '    mov esperaNave,0\n    call DispararNaves\n    mov esperaNave,30000 ; ensaio: um branco real, sem repeticao neste alvo\n    mov al,SCAN_ESPACO',1)
    (tests/'AJAUTO.ASM').write_bytes(source.replace('\r\n','\n').replace('\n','\r\n').encode('ascii'))
    source = (tests/'N08LOG.ASM').read_text()
    needle = '    mov caso,43\n    cmp jipeX,6'
    assert needle in source
    # Dois passos horizontais de 5 agora terminam em 10, nao em 6.
    source = source.replace(needle,'    mov caso,43\n    cmp jipeX,10',1)
    (tests/'AJNAVE.ASM').write_bytes(source.replace('\r\n','\n').replace('\n','\r\n').encode('ascii'))
    batch = ['@echo off','echo inicio > AJUSTE.LOG','z:\\config.com -get "cpu cycles" >> AJUSTE.LOG','echo. >> AJUSTE.LOG']
    for name in ('E08LOG','E08PIX','AJAUTO','AJNAVE'):
        batch += [f'tasm {name}.ASM > {name}.LOG','if errorlevel 1 goto falha',
                  f'tlink /m {name}.OBJ >> {name}.LOG','if errorlevel 1 goto falha',
                  f'{name} >> AJUSTE.LOG','if errorlevel 1 goto falha']
    batch += ['MODO >> AJUSTE.LOG','if errorlevel 1 goto falha','echo PASS AJUSTE >> AJUSTE.LOG',
              'goto fim',':falha','echo FAIL AJUSTE >> AJUSTE.LOG',':fim']
    (tests/'AJUSTE.BAT').write_bytes(('\r\n'.join(batch)+'\r\n').encode('ascii'))

if __name__=='__main__':
    if '--conferir' in sys.argv:
        conferir()
    elif '--regressao' in sys.argv:
        regressao()
    else:
        gerar()
