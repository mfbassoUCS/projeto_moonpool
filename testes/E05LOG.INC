; Funcao: preparar caso independente. Entrada: nenhuma. Saida: estado padrao.
ZerarTeste proc near
    call ReiniciarJipe
    call ReiniciarObstaculos
    mov proximoEm,30000
    mov scorePartida,0
    mov vidas,3
    mov rolagem,0
    ret
ZerarTeste endp

; Funcao: registrar nascimento real. Entrada: DI=slot; saida: registro binario.
RegistrarNascimento proc near
    cmp gerando,0
    je nascimentoFim
    push ax
    push bx
    mov bx,nascBytes
    cmp bx,2042
    ja falhaE05
    mov ax,obstTipo[di]
    mov nascimentos[bx],ax
    mov ax,distancia
    add ax,obstX[di]
    mov nascimentos[bx+2],ax
    mov ax,rolagem
    mov nascimentos[bx+4],ax
    add nascBytes,6
    pop bx
    pop ax
nascimentoFim:
    ret
RegistrarNascimento endp

; Funcao: exportar bloco DS. Entrada: DX=nome, SI=dados,CX=tamanho.
; Saida: arquivo real; erro encerra teste.
GravarDados proc near
    push cx
    xor cx,cx
    mov ah,3Ch
    int 21h
    jc falhaE05
    mov bx,ax
    pop cx
    mov dx,si
    mov ah,40h
    int 21h
    jc falhaE05
    cmp ax,cx
    jne falhaE05
    mov ah,3Eh
    int 21h
    ret
GravarDados endp

falhaE05:
    call RestaurarTecladoJogo
    mov ax,3
    int 10h
    mov ax,caso
    call FormatarScore
    lea dx,erroE05
    mov ah,09h
    int 21h
    lea dx,digitosScore
    mov bx,1
    mov cx,5
    mov ah,40h
    int 21h
    mov ax,4C01h
    int 21h
