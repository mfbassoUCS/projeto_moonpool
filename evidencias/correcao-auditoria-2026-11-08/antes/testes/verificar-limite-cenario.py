"""Ensaio do laco real: jipe no limite, terreno continua, com/sem seta.
Uso: python testes/verificar-limite-cenario.py [--conferir]
Executar limite.conf no DOSBox entre geracao e conferencia.
"""
from pathlib import Path
import hashlib
import json
import re
import struct
import sys

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT/'evidencias/limite-cenario'
DATA = '''
faseLimite dw 0
inicioLimite dw 0
registrosLimite dw 12 dup(0)
nomeLimite db 'LIMITE.BIN',0
nomeQuadro db 'LIM0A.RAW',0
mensagemOk db 'PASS LIMITE: jipe X140; terreno/rocha/relogio continuam.',13,10,'$'
mensagemErro db 'FAIL LIMITE',13,10,'$'
diagnosticoLimite dw 6 dup(0)
'''
MAIN = '''
inicio proc
    mov ax,@data
    mov ds,ax
    mov ax,13h
    int 10h
    mov ax,VIDEO_SEG
    mov es,ax
    cld
faseInicio:
    call EntrarPartida
    mov jipeX,JIPE_X_MAX
    mov teclasJipe,BIT_DIREITA
    cmp faseLimite,0
    je prepararLimite
    mov teclasJipe,0
prepararLimite:
    ; Isolar rolagem: naves continuam movendo, mas nao disparam neste ensaio.
    mov esperaNave,30000
    mov esperaNave+2,30000
    mov esperaNave+4,30000
    mov proximoEm,30000
    mov obstTipo,ROCHA_1
    mov obstX,280
    mov cenarioMudou,1
    mov jipeMudou,1
    call DesenharQuadroPartida
    mov byte ptr nomeQuadro+4,'A'
    call SalvarQuadroLimite
    mov ah,0
    int 1Ah
    mov inicioLimite,dx
limiteRodar:
    call AtualizarPartida
    cmp estado,ESTADO_PARTIDA
    jne falhaLimite
    cmp jipeX,JIPE_X_MAX
    jne falhaLimite
    mov ah,0
    int 1Ah
    sub dx,inicioLimite
    cmp dx,56
    jb limiteRodar
    cmp rolagem,20
    jb falhaLimite
    cmp rolagem,100
    ja falhaLimite
    mov ax,280
    sub ax,rolagem
    cmp obstX,ax
    jne falhaLimite
    cmp tempoRestante,90
    jae falhaLimite
    cmp vidas,3
    jne falhaLimite
    mov bx,faseLimite
    mov ax,12
    mul bx
    mov di,ax
    mov ax,faseLimite
    mov registrosLimite[di],ax
    mov ax,jipeX
    mov registrosLimite[di+2],ax
    mov ax,rolagem
    mov registrosLimite[di+4],ax
    mov ax,obstX
    mov registrosLimite[di+6],ax
    mov ax,tempoRestante
    mov registrosLimite[di+8],ax
    mov ax,jipeY
    mov registrosLimite[di+10],ax
    mov byte ptr nomeQuadro+4,'B'
    call SalvarQuadroLimite
    call RestaurarTecladoJogo
    inc faseLimite
    mov byte ptr nomeQuadro+3,'1'
    cmp faseLimite,2
    jb faseInicio
    lea dx,nomeLimite
    xor cx,cx
    mov ah,3Ch
    int 21h
    jc falhaLimite
    mov bx,ax
    lea dx,registrosLimite
    mov cx,24
    mov ah,40h
    int 21h
    jc falhaLimite
    cmp ax,24
    jne falhaLimite
    mov ah,3Eh
    int 21h
    mov ax,3
    int 10h
    lea dx,mensagemOk
    mov ah,09h
    int 21h
    mov ax,4C00h
    int 21h
falhaLimite:
    mov ax,jipeX
    mov diagnosticoLimite,ax
    mov ax,rolagem
    mov diagnosticoLimite+2,ax
    mov ax,obstX
    mov diagnosticoLimite+4,ax
    mov ax,tempoRestante
    mov diagnosticoLimite+6,ax
    xor ax,ax
    mov al,vidas
    mov diagnosticoLimite+8,ax
    mov al,estado
    mov diagnosticoLimite+10,ax
    call RestaurarTecladoJogo
    mov ax,3
    int 10h
    lea dx,mensagemErro
    mov ah,09h
    int 21h
    xor si,si
diagnosticoNumero:
    mov ax,diagnosticoLimite[si]
    call FormatarScore
    lea dx,digitosScore
    mov bx,1
    mov cx,5
    mov ah,40h
    int 21h
    add si,2
    cmp si,12
    jb diagnosticoNumero
    mov ax,4C01h
    int 21h
inicio endp
; Funcao: salvar video real. Entrada: ES=A000h, nomeQuadro. Saida: RAW.
; Altera: AX,BX,CX,DX,flags. Preserva DS e ES.
SalvarQuadroLimite proc near
    lea dx,nomeQuadro
    xor cx,cx
    mov ah,3Ch
    int 21h
    jc falhaLimite
    mov bx,ax
    push ds
    push es
    pop ds
    xor dx,dx
    mov cx,64000
    mov ah,40h
    int 21h
    pop ds
    jc falhaLimite
    cmp ax,64000
    jne falhaLimite
    mov ah,3Eh
    int 21h
    jc falhaLimite
    ret
SalvarQuadroLimite endp
'''

def gerar():
    OUT.mkdir(exist_ok=True)
    src=(ROOT/'MOON.ASM').read_text(encoding='ascii')
    (OUT/'fonte.sha256').write_text(hashlib.sha256((ROOT/'MOON.ASM').read_bytes()).hexdigest())
    src=src.replace('.code',DATA+'\n.code',1)
    src=re.sub(r'inicio proc.*?inicio endp',lambda _:MAIN,src,count=1,flags=re.S)
    (OUT/'LIMITE.ASM').write_bytes(src.replace('\r\n','\n').replace('\n','\r\n').encode('ascii'))
    bat='''@echo off
tasm LIMITE.ASM > LIMITE.LOG
if errorlevel 1 goto falha
tlink LIMITE.OBJ >> LIMITE.LOG
if errorlevel 1 goto falha
LIMITE >> LIMITE.LOG
if errorlevel 1 goto falha
goto fim
:falha
echo FAIL BUILD/EXEC >> LIMITE.LOG
:fim
'''
    (OUT/'TESTAR.BAT').write_bytes(bat.replace('\n','\r\n').encode('ascii'))
    config=f'''[sdl]
fullscreen=false
output=surface
[cpu]
cycles=50000
[autoexec]
mount t "{ROOT / 'ferramentas/guitasm/BIN'}"
mount j "{OUT}"
j:
path t:\\;z:\\
call TESTAR.BAT
exit
'''
    (OUT/'limite.conf').write_text(config,encoding='ascii')

def conferir():
    digest=hashlib.sha256((ROOT/'MOON.ASM').read_bytes()).hexdigest()
    assert digest==(OUT/'fonte.sha256').read_text()
    log=(OUT/'LIMITE.LOG').read_text()
    assert 'PASS LIMITE' in log and 'FAIL' not in log
    assert 'Error messages:    None' in log and 'Warning messages:  None' in log
    rows=struct.unpack('<12H',(OUT/'LIMITE.BIN').read_bytes())
    arts={a['rotulo']:a for a in json.loads((ROOT/'artes/desenhos.json').read_text(encoding='utf-8'))}
    report=[]
    for phase in range(2):
        p,x,scroll,rock,time,y=rows[phase*6:phase*6+6]
        assert p==phase and x==140 and y==183 and 20<=scroll<=100
        assert rock==280-scroll and 0<time<90
        before=(OUT/f'LIM{phase}A.RAW').read_bytes()
        after=(OUT/f'LIM{phase}B.RAW').read_bytes()
        assert len(before)==len(after)==64000
        for raw,offset in [(before,0),(after,scroll)]:
            # Area inteira do relevo acima do jipe: conferir o desenho, nao
            # apenas a variavel rolagem. Oraculo a partir das grades da arte.
            for yy in range(100,164):
                for xx in range(320):
                    source=(xx+offset)%320
                    c=arts['bitmapMontanhas']['linhas'][yy-100][source]
                    color=0 if c=='.' else int(c,16)
                    if yy>=132:
                        c=arts['bitmapMontes']['linhas'][yy-132][source]
                        if c!='.':color=int(c,16)
                    assert raw[yy*320+xx]==color,(phase,offset,xx,yy)
        assert before[32000:52480]!=after[32000:52480]
        report.append(f'PASS fase {phase} ({"direita mantida" if phase==0 else "sem tecla"}): X={x}, Y={y}, rolagem 0->{scroll}, rocha 280->{rock}, tempo 90->{time}; pixels do relevo conferidos.')
    report += ['Fonte SHA256: '+digest, 'Ensaio controlado (~3 s por fase), usa AtualizarPartida e video reais; teclas sintetizadas por estado e cadencia inimiga adiada somente na variante para isolar pixels do relevo. Sem teste fisico. Nenhuma alteracao no jogo.']
    (OUT/'resultado.txt').write_text('\n'.join(report)+'\n',encoding='utf-8')
    print('\n'.join(report))

if __name__=='__main__':
    conferir() if '--conferir' in sys.argv else gerar()
