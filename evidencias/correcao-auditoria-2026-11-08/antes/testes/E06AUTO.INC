; Funcao: validar grupo de uma nova partida real. Entrada: dados.
; Saida: erro se reset/geracao/cadencia invalidos.
ConferirInicioNaves proc near
    call ContarNavesAtivas
    cmp ax,1
    jb autoFalhaR06
    cmp ax,3
    ja autoFalhaR06
    cmp ax,naveQuantidade
    jne autoFalhaR06
    cmp naveTipo,2
    ja autoFalhaR06
    mov ax,tickNave
    cmp ax,tickJipe
    jne autoFalhaR06
    cmp navesMudou,0
    jne autoFalhaR06
    xor di,di
autoNaveInicioLoop:
    cmp naveAtiva[di],0
    je autoNaveInicioProxima
    cmp naveX[di],320
    jl autoFalhaR06
    cmp naveX[di],466
    jg autoFalhaR06
    cmp naveY[di],15
    jb autoFalhaR06
    cmp naveY[di],86
    ja autoFalhaR06
autoNaveInicioProxima:
    add di,2
    cmp di,6
    jb autoNaveInicioLoop
    mov ax,naveX
    mov autoE06X,ax
    ret
ConferirInicioNaves endp
; Funcao: verificar movimento por ticks reais antes/depois da primeira morte.
; Entrada: grupo inicial; saida: contador de passos, erro se reiniciado/mudado.
ConferirMovimentoNaves proc near
    mov ax,naveQuantidade
    cmp ax,autoE06Dados
    jne autoFalhaR06
    mov ax,naveTipo
    cmp ax,autoE06Dados+2
    jne autoFalhaR06
    mov ax,autoE06X
    sub ax,naveX
    cmp ax,1
    ja autoFalhaR06
    add autoE06Dados+88,ax
    mov ax,naveX
    mov autoE06X,ax
    xor di,di
autoNaveMovLoop:
    mov ax,naveY[di]
    cmp ax,autoE06Dados[di+10]
    jne autoFalhaR06
    mov ax,naveAtiva[di]
    cmp ax,autoE06Dados[di+16]
    jne autoFalhaR06
    add di,2
    cmp di,6
    jb autoNaveMovLoop
    ret
ConferirMovimentoNaves endp
; Funcao: registrar grupo na captura real. Entrada: DS:SI=destino 22 bytes.
; Saida: quantidade/tipo/X3/Y3/atividade3, para oraculo de pixels externo.
GuardarNavesAuto proc near
    mov ax,naveQuantidade
    mov [si],ax
    mov ax,naveTipo
    mov [si+2],ax
    mov bx,si
    xor di,di
autoNaveCopiar:
    mov ax,naveX[di]
    mov [bx+di+4],ax
    mov ax,naveY[di]
    mov [bx+di+10],ax
    mov ax,naveAtiva[di]
    mov [bx+di+16],ax
    add di,2
    cmp di,6
    jb autoNaveCopiar
    ret
GuardarNavesAuto endp
; Funcao: exportar quatro estados e passos. Entrada: dados coletados.
; Saida: E06AUT.BIN 90 bytes; pelo menos 100 passos reais antes da reposicao.
GravarNavesAuto proc near
    cmp autoE06Dados+88,100
    jb autoFalhaR06
    lea dx,autoE06Nome
    xor cx,cx
    mov ah,3Ch
    int 21h
    jc autoFalhaR06
    mov bx,ax
    lea dx,autoE06Dados
    mov cx,90
    mov ah,40h
    int 21h
    jc autoFalhaR06
    cmp ax,cx
    jne autoFalhaR06
    mov ah,3Eh
    int 21h
    ret
GravarNavesAuto endp
