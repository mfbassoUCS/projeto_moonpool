; Cada linha: operacao,arg,X,Y,fase,pixelsTopo esperados.
; 0=reset, 1=posicionar X, 2=scan, 3=frame jipe, 4=pixels terreno.
; Resultados explicitos: nao sao calculados copiando o algoritmo do jogo.
casos dw 0,0,0,183,0,0
; Saturacao nas duas bordas, incluindo passo final menor que 3.
dw 2,4Bh,0,183,0,0
dw 3,0,0,183,0,0
dw 2,0CBh,0,183,0,0
dw 1,139,139,183,0,0
dw 2,4Dh,139,183,0,0
dw 3,0,140,183,0,0
dw 3,0,140,183,0,0
; Duas direcoes simultaneas neutras; soltar uma retoma a outra.
dw 2,4Bh,140,183,0,0
dw 3,0,140,183,0,0
dw 2,0CDh,140,183,0,0
dw 3,0,137,183,0,0
dw 1,1,1,183,0,0
dw 3,0,0,183,0,0
dw 2,0CBh,0,183,0,0
; Parado: cinco subidas, repeticoes nao reiniciam a fase.
dw 2,48h,0,183,0,0
dw 3,0,0,180,1,0
dw 2,48h,0,180,1,0
dw 3,0,0,177,1,0
; Nova pressao NO AR tambem nao fica enfileirada para depois.
dw 2,0C8h,0,177,1,0
dw 2,48h,0,177,1,0
dw 3,0,0,174,1,0
dw 3,0,0,171,1,0
dw 3,0,0,168,2,0
; Frames sem distancia nao contam; 1+2+1=4 ainda topo, +1 inicia descida.
dw 3,0,0,168,2,0
dw 3,0,0,168,2,0
dw 4,0,0,168,2,0
dw 4,1,0,168,2,1
dw 4,2,0,168,2,3
dw 4,1,0,168,2,4
dw 3,0,0,168,2,4
dw 4,1,0,168,3,5
dw 3,0,0,171,3,5
dw 3,0,0,174,3,5
dw 3,0,0,177,3,5
dw 3,0,0,180,3,5
dw 3,0,0,183,0,5
dw 2,48h,0,183,0,5
dw 3,0,0,183,0,5
; Soltar e pressionar novamente no chao autoriza outro salto, indo a direita.
dw 2,0C8h,0,183,0,5
dw 2,48h,0,183,0,5
dw 2,4Dh,0,183,0,5
dw 3,0,3,180,1,0
dw 3,0,6,177,1,0
dw 3,0,9,174,1,0
dw 3,0,12,171,1,0
dw 3,0,15,168,2,0
; Trocar para esquerda no topo: distancia de tela nao altera D05.
dw 2,0CDh,15,168,2,0
dw 2,4Bh,15,168,2,0
dw 3,0,12,168,2,0
dw 4,2,12,168,2,2
dw 3,0,9,168,2,2
dw 4,2,9,168,2,4
dw 3,0,6,168,2,4
dw 4,2,6,168,3,5
dw 3,0,3,171,3,5
dw 3,0,0,174,3,5
dw 3,0,0,177,3,5
dw 3,0,0,180,3,5
dw 3,0,0,183,0,5
; Salto no limite direito, mesmo pressionando para fora.
dw 0,0,0,183,0,0
dw 1,140,140,183,0,0
dw 2,4Dh,140,183,0,0
dw 2,48h,140,183,0,0
dw 3,0,140,180,1,0
dw 3,0,140,177,1,0
dw 3,0,140,174,1,0
dw 3,0,140,171,1,0
dw 3,0,140,168,2,0
dw 4,4,140,168,2,4
dw 3,0,140,168,2,4
dw 4,1,140,168,3,5
dw 3,0,140,171,3,5
dw 3,0,140,174,3,5
dw 3,0,140,177,3,5
dw 3,0,140,180,3,5
dw 3,0,140,183,0,5
dw 3,0,140,183,0,5
; Reset de todos os dados depois de um salto, sem herdar tecla/pedido.
dw 0,0,0,183,0,0
dw 3,0,0,183,0,0
dw 0FFFFh
