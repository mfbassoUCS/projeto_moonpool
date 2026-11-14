"""J07: mede distancia REAL no laco de partida; ticks BIOS controlados.
Uso: --gerar, executar topo.conf, --conferir. Nao altera MOON.ASM.
"""
from pathlib import Path
import hashlib
import json
import re
import struct
import sys

ROOT=Path(__file__).resolve().parent.parent
OUT=ROOT/'evidencias/correcao-auditoria-2026-11-08/topo'
DATA='''
tickTopo dw 0
casoTopo dw 0
indiceTopo dw 0
dadosTopo dw 1920 dup(0)
xsTopo dw 0,0,0,0,70,70,70,70,140,140,140,140
teclasTopo db 0,1,2,3,0,1,2,3,0,1,2,3
nomeTopo db 'TOPO.BIN',0
okTopo db 'PASS TOPO: laco real, 12 casos, 240 registros.',13,10,'$'
erroTopo db 'FAIL TOPO',13,10,'$'
'''
MAIN='''inicio proc
    mov ax,@data
    mov ds,ax
    mov ax,13h
    int 10h
    mov ax,VIDEO_SEG
    mov es,ax
topoCaso:
    mov tickTopo,0
    call EntrarPartida
    mov bx,casoTopo
    mov al,teclasTopo[bx]
    mov teclasJipe,al
    shl bx,1
    mov ax,xsTopo[bx]
    mov jipeX,ax
    mov pedidoSalto,1
    mov proximoEm,30000
    mov esperaNave,30000
    mov esperaNave+2,30000
    mov esperaNave+4,30000
topoFrame:
    inc tickTopo
    call AtualizarPartida
    cmp estado,ESTADO_PARTIDA
    jne falhaTopo
    mov di,indiceTopo
    mov ax,casoTopo
    mov dadosTopo[di],ax
    mov ax,tickTopo
    mov dadosTopo[di+2],ax
    mov ax,jipeX
    mov dadosTopo[di+4],ax
    mov ax,jipeY
    mov dadosTopo[di+6],ax
    xor ax,ax
    mov al,estadoSalto
    mov dadosTopo[di+8],ax
    mov ax,rolagem
    mov dadosTopo[di+10],ax
    mov ax,pixelsTopo
    mov dadosTopo[di+12],ax
    xor ax,ax
    mov al,vidas
    mov dadosTopo[di+14],ax
    add indiceTopo,16
    cmp tickTopo,20
    jb topoFrame
    call RestaurarTecladoJogo
    inc casoTopo
    cmp casoTopo,12
    jb topoCaso
    lea dx,nomeTopo
    xor cx,cx
    mov ah,3Ch
    int 21h
    jc falhaTopo
    mov bx,ax
    lea dx,dadosTopo
    mov cx,3840
    mov ah,40h
    int 21h
    jc falhaTopo
    cmp ax,3840
    jne falhaTopo
    mov ah,3Eh
    int 21h
    jc falhaTopo
    mov ax,3
    int 10h
    lea dx,okTopo
    mov ah,09h
    int 21h
    mov ax,4C00h
    int 21h
inicio endp
; Funcao: amostra BIOS deterministica. Entrada: tickTopo. Saida: CX:DX=tick.
RelogioTopo proc near
    xor cx,cx
    mov dx,tickTopo
    ret
RelogioTopo endp
falhaTopo:
    call RestaurarTecladoJogo
    mov ax,3
    int 10h
    lea dx,erroTopo
    mov ah,09h
    int 21h
    mov ax,4C01h
    int 21h
'''

def gerar():
    OUT.mkdir(parents=True,exist_ok=True)
    raw=(ROOT/'MOON.ASM').read_bytes()
    source=raw.decode('ascii').replace('\r\n','\n')
    source=source.replace('.code',DATA+'\n.code',1)
    source=re.sub(r'inicio proc.*?inicio endp',lambda _:MAIN,source,count=1,flags=re.S)
    source=re.sub(r'(?im)^    int 1Ah\s*$', '    call RelogioTopo',source)
    (OUT/'TOPO.ASM').write_bytes(source.replace('\n','\r\n').encode('ascii'))
    (OUT/'fonte.sha256').write_text(hashlib.sha256(raw).hexdigest())
    batch='''@echo off
tasm TOPO.ASM > TOPO.LOG
if errorlevel 1 goto falha
tlink /m TOPO.OBJ >> TOPO.LOG
if errorlevel 1 goto falha
TOPO >> TOPO.LOG
if errorlevel 1 goto falha
goto fim
:falha
echo FAIL BUILD/EXEC >> TOPO.LOG
:fim
'''
    (OUT/'TESTAR.BAT').write_bytes(batch.replace('\n','\r\n').encode('ascii'))
    (OUT/'topo.conf').write_text(f'''[sdl]
fullscreen=false
output=surface
[cpu]
cycles=50000
[autoexec]
mount t "{ROOT/'ferramentas/guitasm/BIN'}"
mount j "{OUT}"
j:
path t:\\;z:\\
call TESTAR.BAT
exit
''',encoding='ascii')

def conferir():
    digest=hashlib.sha256((ROOT/'MOON.ASM').read_bytes()).hexdigest()
    assert digest==(OUT/'fonte.sha256').read_text()
    log=(OUT/'TOPO.LOG').read_text()
    assert 'PASS TOPO' in log and 'FAIL' not in log
    assert 'Error messages:    None' in log and 'Warning messages:  None' in log
    rows=list(struct.iter_unpack('<8H',(OUT/'TOPO.BIN').read_bytes()))
    assert len(rows)==240
    report=[]
    for case in range(12):
        rr=rows[case*20:(case+1)*20]
        assert all(r[0]==case and r[1]==i+1 and r[7]==3 for i,r in enumerate(rr))
        assert [r[3] for r in rr[:5]]==[180,177,174,171,168]
        top=next(r for r in rr if r[4]==2)
        down=next(r for r in rr if r[4]==3)
        assert (down[5]-top[5])%320==5, (case,top,down)
        assert down[6]==5
        assert all(r[3]==168 for r in rr if r[4]==2)
        assert [r[3] for r in rr if r[4]==3]==[171,174,177,180]
        assert rr[13][3:5]==(183,0) and rr[-1][3:5]==(183,0)
        start=[0,70,140][case//4];direction=case%4
        for r in rr:
            expected=max(0,start-5*r[1]) if direction==1 else min(140,start+5*r[1]) if direction==2 else start
            assert r[2]==expected,(case,r)
        report.append(dict(caso=case,x_inicial=start,teclas=['nenhuma','esquerda','direita','ambas'][direction],
                           tick_topo=top[1],tick_descida=down[1],rolagem_topo=top[5],rolagem_descida=down[5],distancia_real=5))
    result=dict(fonte_sha256=digest,referencia='avanco do terreno; interpretacao D05',
                metodo='AtualizarPartida real com amostras BIOS controladas; sem teclado fisico',casos=report,registros=rows)
    (OUT/'resultado.json').write_text(json.dumps(result,indent=2,ensure_ascii=False),encoding='utf-8')
    print('PASS J07: 12 casos (0/70/140 x parado/esquerda/direita/ambas); 5 pixels REAIS de terreno; subida/descida 3; chao no tick 14.')

if __name__=='__main__':
    conferir() if '--conferir' in sys.argv else gerar()
