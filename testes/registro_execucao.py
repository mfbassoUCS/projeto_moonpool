"""Vincula uma execucao concluida aos arquivos e ao fonte que a produziram."""
from pathlib import Path
import hashlib
import json
import sys

ROOT=Path(__file__).resolve().parent.parent
T=ROOT/'testes'
SUITE=['MONTAGEM.LOG','LINK.LOG','MOON.MAP','MOON.EXE']
for prefix,names in {
    'R08':['RESUL.LOG','REG.LOG','JIPE.LOG','LOG.LOG','PIX.LOG','AUTO.LOG','GER.BIN','PIX.BIN','AUTO.BIN','MORT.RAW','REPO.RAW','FIM.RAW'],
    'N08':['RESUL.LOG','LOG.LOG','PIX.LOG','MEM.LOG','TELA.LOG','GER.BIN','GRP.BIN','MIX.BIN','AUT.BIN','PIX.BIN','TELA.BIN','INI.RAW','MOV.RAW','SEL.RAW','SET.RAW','FIM.RAW','RET.RAW'],
    'E08':['RESUL.LOG','LOG.LOG','PIX.LOG','AUTO.LOG','PIX.BIN','TEMPO.BIN','HOST.json'],
}.items():
    SUITE += ['testes/'+prefix+name for name in names]
KEY=['testes/E08KEY.LOG','testes/E08KRES.LOG','testes/E08KEY.EXE']


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def caminho(group):
    assert group in ('suite','teclado')
    return T/('execucao-'+group+'.json')


def iniciar(group):
    # Remove somente produtos conhecidos: nunca considera resultado antigo.
    outputs=SUITE if group=='suite' else KEY
    record=dict(status='em andamento',fonte_sha256=sha(ROOT/'MOON.ASM'))
    caminho(group).write_text(json.dumps(record,indent=2),encoding='utf-8')
    for name in outputs:
        (ROOT/name).unlink(missing_ok=True)


def concluir(group):
    record=json.loads(caminho(group).read_text(encoding='utf-8'))
    assert record['status']=='em andamento'
    assert record['fonte_sha256']==sha(ROOT/'MOON.ASM'),'Fonte mudou durante execucao'
    outputs=SUITE if group=='suite' else KEY
    record['arquivos']={name:sha(ROOT/name) for name in outputs}
    record['status']='concluida'
    caminho(group).write_text(json.dumps(record,indent=2),encoding='utf-8')


def conferir(group):
    record=json.loads(caminho(group).read_text(encoding='utf-8'))
    assert record['status']=='concluida',f'Execucao {group} incompleta'
    assert record['fonte_sha256']==sha(ROOT/'MOON.ASM'),f'Fonte mudou desde {group}'
    for name,digest in record['arquivos'].items():
        assert sha(ROOT/name)==digest,f'Resultado alterado desde {group}: {name}'


if __name__=='__main__':
    {'iniciar':iniciar,'concluir':concluir,'conferir':conferir}[sys.argv[1]](sys.argv[2])
