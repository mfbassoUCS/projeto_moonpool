"""Artes proprias E02: desenhar em grades, converter para DB e gerar catalogo.
Nao le imagens de referencia. Auxilio grafico, sem dependencia no EXE DOS.
Uso: python artes/gerar-artes.py [--aplicar]
"""
from pathlib import Path
from itertools import groupby
import json
import sys
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent
PALETA = [
    (0,0,0),(0,0,170),(0,170,0),(0,170,170),
    (170,0,0),(170,0,170),(170,85,0),(170,170,170),
    (85,85,85),(85,85,255),(85,255,85),(85,255,255),
    (255,85,85),(255,85,255),(255,255,85),(255,255,255),
]

def grade(w, h):
    return [['.']*w for _ in range(h)]

def faixa(g, x, y, n, cor):
    assert 0 <= y < len(g) and 0 <= x <= x+n <= len(g[0])
    g[y][x:x+n] = [cor]*n

def criar():
    artes = []
    def adicionar(nome, rotulo, w, h, linhas):
        linhas = [''.join(l) for l in linhas]
        assert len(linhas) == h, (nome, 'altura', len(linhas))
        assert all(len(l)==w for l in linhas), (nome, [(i,len(l)) for i,l in enumerate(linhas)])
        assert set(''.join(linhas)) <= set('.0123456789ABCDEF'), nome
        assert any(c!='.' for l in linhas for c in l), nome
        artes.append(dict(nome=nome, rotulo=rotulo, largura=w, altura=h, linhas=linhas))

    # Veiculo proprio: cabine ciano, carroceria magenta, dois canhoes,
    # tres rodas de 3x3. Coordenadas escolhidas nesta grade, sem tracing.
    j = grade(20,10)
    faixa(j,6,0,1,'F')
    for y in range(1,5): faixa(j,6,y,1,'7')
    faixa(j,11,1,3,'B')
    faixa(j,10,2,5,'B'); faixa(j,11,2,2,'9')
    faixa(j,9,3,7,'B'); faixa(j,10,3,3,'9')
    faixa(j,3,4,14,'D'); faixa(j,2,5,16,'D')
    faixa(j,0,6,18,'5')
    faixa(j,2,5,3,'5'); faixa(j,7,5,7,'F')
    faixa(j,16,4,4,'7'); faixa(j,19,4,1,'F')
    for x in (2,8,14):
        faixa(j,x+1,7,1,'8'); faixa(j,x,8,3,'8'); faixa(j,x+1,8,1,'F')
        faixa(j,x+1,9,1,'8')
    adicionar('Jipe', 'bitmapJipe',20,10,j)
    adicionar('Nave 1 - disco','bitmapNave1',14,14,[
        '..............','.....BBBB.....','....B9999B....','...B999999B...',
        '...77777777...','..EEEEEEEEEE..','.EE6EEEEEE6EE.','EEEEEEEEEEEEEE',
        '..6666666666..','...E......E...','..C........C..','...4......4...',
        '..............','..............'])
    adicionar('Nave 2 - asas','bitmapNave2',14,14,[
        '...B......B...','...BB....BB...','..3BB3..3BB3..','..3BBB33BBB3..',
        '...3BBBBBB3...','....BFFFFB....','...BB9009BB...','..BBBBBBBBBB..',
        '.3BB3BBBB3BB3.','3BB3..33..3BB3','.3....CC....3.','......44......',
        '..............','..............'])
    adicionar('Nave 3 - losango','bitmapNave3',14,14,[
        '......DD......','.....D55D.....','....D5555D....','...D555555D...',
        '..D55F55F55D..','.D5550550555D.','.D5555555555D.','..DDDDDDDDDD..',
        '...5DDDDDD5...','..5..D55D..5..','.5....CC....5.','......44......',
        '..............','..............'])
    # Tres coracoes de cinco colunas, separados por uma coluna; ultimo
    # pixel da caixa de 18 colunas e margem. Coracoes perdidos ficam cinza.
    coracao = ['.X.X.','XXXXX','XXXXX','.XXX.','..X..']
    for vidas in (3,2,1):
        g = grade(18,11)
        for n in range(3):
            for y,linha in enumerate(coracao):
                for x,c in enumerate(linha):
                    if c=='X': g[y+3][n*6+x] = 'C' if n<vidas else '8'
            if n<vidas: g[4][n*6+1]='F'
        adicionar(f'Vidas {vidas}',f'bitmapVidas{vidas}',18,11,g)
    adicionar('Relogio','bitmapRelogio',7,8,[
        '..EEE..','.E000E.','E00E00E','E00E00E','E00EE0E','E00000E','.E000E.','..EEE..'])
    adicionar('Cratera 1','bitmapCratera1',14,7,[
        '...66666666...','.668888888866.','68000000000086','60000000000006',
        '.680000000086.','..6688888866..','....666666....'])
    adicionar('Cratera 2','bitmapCratera2',14,7,[
        '.666....666...','6800666680866.','60000000000086','68000000000006',
        '.680000000086.','..6680008666..','....66666.....'])
    adicionar('Cratera 3','bitmapCratera3',14,7,[
        '......6666....','...666800866..','.668000000086.','68000000000086',
        '6000000000086.','.66800008666..','...666666.....'])
    adicionar('Rocha 1','bitmapRocha1',12,10,[
        '....777.....','...7FF77....','..7FF7787...','..7F77887...',
        '.7F7788887..','.777888887..','77888888887.','788878888887',
        '788888888887','888888888888'])
    adicionar('Rocha 2','bitmapRocha2',12,10,[
        '.....66.....','....6EE6....','...6EE666...','..6EE66666..',
        '.6EE6666666.','6EE666666666','6E6666666666','.6666666666.',
        '..66666666..','...666666...'])
    adicionar('Rocha 3','bitmapRocha3',12,10,[
        '..3......3..','..B3....B3..','.BB33..BB33.','.BB33.BBB33.',
        'BBB33.BB333.','BB333BBB333.','BB333BB33333','B3333B333333',
        '333333333333','333333333333'])
    adicionar('Rocha 4','bitmapRocha4',12,10,[
        '...444444...','..4CC44444..','.4CC4444444.','.4C444C4444.',
        '4CC44C444444','4C444CC44444','444444C44444','44444C444444',
        '.4444CC4444.','..44444444..'])

    # Relevo proprio: contornos arredondados e sombras diagonais discretas.
    # Mesmas dimensoes e paleta; apenas dados graficos, sem custo no jogo.
    def relevo(w,h,pontos,clara,escura):
        g = grade(w,h)
        alturas = [0]*w
        for (x0,y0),(x1,y1) in zip(pontos,pontos[1:]):
            for x in range(x0,x1+1):
                t = (x-x0)/(x1-x0)
                curva = t*t*(3-2*t)
                alturas[x] = round(y0+(y1-y0)*curva)
        for x,topo in enumerate(alturas):
            for y in range(topo,h):
                g[y][x] = clara
        # Cada pico recebe uma face estreita; pontilhado apenas na borda.
        for i in range(1,len(pontos)-1):
            pico,topo = pontos[i]
            if topo >= pontos[i-1][1] or topo >= pontos[i+1][1]:
                continue
            for y in range(topo+2,h-2):
                profundidade = y-topo
                borda = pico+profundidade//2
                largura = max(1,profundidade//5)
                for x in range(borda-largura,borda+2):
                    if 0 <= x < w and y >= alturas[x]+2:
                        if x < borda-1 or (x+y)%2 == 0:
                            g[y][x] = escura
        for y in range(h): g[y][-1]=g[y][0]
        return g
    adicionar('Montanhas','bitmapMontanhas',320,64,
        relevo(320,64,[(0,42),(24,30),(43,5),(70,37),(95,18),(119,44),
                      (151,0),(180,32),(206,15),(237,40),(268,9),(293,30),(319,42)],'9','1'))
    adicionar('Montes','bitmapMontes',320,32,
        relevo(320,32,[(0,23),(25,17),(56,4),(89,15),(116,26),(149,12),
                      (176,0),(205,13),(240,24),(269,9),(295,16),(319,23)],'A','2'))
    return artes

def indices(arte):
    return bytes(255 if c=='.' else int(c,16) for linha in arte['linhas'] for c in linha)

def converter(artes):
    linhas = ['; ARTES_INICIO', '; Desenhos proprios E02, autorizados em 25/10/2026.',
              '; Grade editavel/origem: artes/gerar-artes.py e desenhos.json.',
              '; Cada DB e uma linha. DUP repete bytes na montagem, nao no jogo.',
              '; FFh transparente; 00h preto opaco. Nao sao copias do arcade.']
    for i,a in enumerate(artes):
        if i==15: linhas.append('bitmapsFim label byte')
        linhas.append(f"; {a['nome']} - {a['largura']} x {a['altura']}")
        for y,linha in enumerate(a['linhas']):
            termos=[]
            for c,run in groupby(linha):
                n=len(list(run)); v='0FFh' if c=='.' else f'0{c}h'
                termos.append(v if n==1 else f'{n} dup({v})')
            label=a['rotulo'] if y==0 else ' '*len(a['rotulo'])
            linhas.append(label+' db '+','.join(termos))
        linhas.append(a['rotulo']+'Fim label byte')
    linhas += ['; ARTES_FIM']
    return '\n'.join(linhas)

def imagem(a):
    im=Image.new('RGBA',(a['largura'],a['altura']))
    im.putdata([(0,0,0,0) if n==255 else (*PALETA[n],255) for n in indices(a)])
    return im

def catalogo(artes):
    out=ROOT/'artes'/'previas'; out.mkdir(exist_ok=True)
    sheet=Image.new('RGB',(800,560),(24,28,39)); d=ImageDraw.Draw(sheet)
    for i,a in enumerate(artes[:15]):
        im=imagem(a); im.save(out/(a['rotulo']+'.png'))
        x=20+(i%4)*200; y=15+(i//4)*135
        d.text((x,y),a['nome']+f" ({a['largura']}x{a['altura']})",fill='white')
        # Fundo mostarda apenas para visualizar os buracos pretos.
        bg=(170,140,30) if 'Cratera' in a['nome'] else (0,0,0)
        large=im.resize((a['largura']*6,a['altura']*6),Image.Resampling.NEAREST)
        d.rectangle((x,y+25,x+large.width-1,y+24+large.height),fill=bg)
        sheet.paste(large,(x,y+25),large)
    sheet.save(out/'catalogo.png')
    terreno=Image.new('RGBA',(320,64),(0,0,0,255))
    terreno.alpha_composite(imagem(artes[15]),(0,0))
    terreno.alpha_composite(imagem(artes[16]),(0,32))
    terreno.resize((960,192),Image.Resampling.NEAREST).save(out/'relevo.png')
    for a in artes[15:]: imagem(a).save(out/(a['rotulo']+'.png'))

def main():
    artes=criar()
    (ROOT/'artes'/'desenhos.json').write_text(json.dumps(artes,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
    catalogo(artes)
    if '--aplicar' in sys.argv:
        path=ROOT/'MOON.ASM'; source=path.read_text(encoding='ascii')
        inicio=source.index('; ARTES_INICIO') if '; ARTES_INICIO' in source else source.index('; MARCADORES PROVISORIOS:')
        fim=source.index('; ARTES_FIM')+len('; ARTES_FIM') if '; ARTES_FIM' in source else source.index('bitmapsFim label byte')+len('bitmapsFim label byte')
        source=source[:inicio]+converter(artes)+source[fim:]
        path.write_bytes(source.replace('\r\n','\n').replace('\n','\r\n').encode('ascii'))
    print('17 artes proprias; '+str(sum(len(indices(a)) for a in artes))+' bytes; catalogo em artes/previas.')

if __name__=='__main__': main()
