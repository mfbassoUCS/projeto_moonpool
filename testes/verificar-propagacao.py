"""Injeta falha numa COPIA dos BAT: PASS antigo nao pode liberar os pais."""
from pathlib import Path
import json
import shutil
import sys

ROOT=Path(__file__).resolve().parent.parent
OUT=ROOT/'evidencias/correcao-auditoria-2026-11-08/propagacao'

def gerar():
    OUT.mkdir(parents=True,exist_ok=True)
    for name in ['E08TEST.BAT','N08TEST.BAT']:
        shutil.copy2(ROOT/'testes'/name,OUT/name)
    # Filho simula falha ANTES de limpar sua propria marca antiga.
    (OUT/'R08TEST.BAT').write_bytes(b'@echo off\r\necho FAIL R08 injetado > R08RESUL.LOG\r\n')
    for prefix in ['R08','N08','E08']:
        (OUT/(prefix+'.OK')).write_text('PASS antigo\n')
    (OUT/'propagacao.conf').write_text(f'''[sdl]
fullscreen=false
[autoexec]
mount j "{OUT}"
j:
call E08TEST.BAT
exit
''',encoding='ascii')

def conferir():
    logs={p:(OUT/(p+'RESUL.LOG')).read_text() for p in ['R08','N08','E08']}
    for prefix,log in logs.items():
        assert 'FAIL '+prefix in log and 'PASS '+prefix not in log, (prefix,log)
        assert not (OUT/(prefix+'.OK')).exists(),prefix
    assert not list(OUT.glob('*.EXE')),'Nao deve executar testes posteriores a falha'
    (OUT/'resultado.json').write_text(json.dumps(dict(resultado='PASS',
        metodo='Falha injetada no BAT filho e marcas antigas presentes; copia isolada',logs=logs),indent=2),encoding='utf-8')
    print('PASS propagacao: FAIL R08 -> FAIL N08 -> FAIL E08; marcas antigas removidas; nenhum PASS global.')

if __name__=='__main__':
    conferir() if '--conferir' in sys.argv else gerar()
