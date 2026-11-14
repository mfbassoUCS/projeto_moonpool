; Auxiliares de evidencia, fora do programa entregue.
; Funcao: abrir tres arquivos. Entrada: nomes. Saida: handles DOS.
PrepararArquivosE06 proc near
    xor di,di
    lea dx,nomesE06
abrirE06Loop:
    xor cx,cx
    mov ah,3Ch
    int 21h
    jc falhaE06
    mov handlesE06[di],ax
    add dx,11
    add di,2
    cmp di,6
    jb abrirE06Loop
    ret
PrepararArquivosE06 endp
; Funcao: fechar arquivos. Entrada: handles. Saida: arquivos completos.
FecharArquivosE06 proc near
    xor di,di
fecharE06Loop:
    mov bx,handlesE06[di]
    mov ah,3Eh
    int 21h
    jc falhaE06
    add di,2
    cmp di,6
    jb fecharE06Loop
    ret
FecharArquivosE06 endp
; Funcao: gravar buffer. Entrada: BX=handle,CX=bytes. Saida: registro DOS.
EscreverRegistroE06 proc near
    lea dx,registro
    mov ah,40h
    int 21h
    jc falhaE06
    cmp ax,cx
    jne falhaE06
    ret
EscreverRegistroE06 endp
; Funcao: registrar grupo recem-gerado. Entrada: dados; saida: 26 bytes.
; Preserva todos os registradores. Flags nao sao utilizadas nesse ponto.
RegistrarGrupoE06 proc near
    cmp modoRegistro,0
    je grupoE06Fim
    push ax
    push bx
    push cx
    push dx
    push si
    mov ax,amostra
    mov registro,ax
    mov ax,naveQuantidade
    mov registro+2,ax
    mov ax,naveTipo
    mov registro+4,ax
    xor si,si
grupoE06Copiar:
    mov ax,naveX[si]
    mov registro[si+6],ax
    mov ax,naveY[si]
    mov registro[si+12],ax
    mov ax,naveAtiva[si]
    mov registro[si+18],ax
    add si,2
    cmp si,6
    jb grupoE06Copiar
    mov ax,distancia
    mov registro+24,ax
    mov bx,handlesE06
    cmp modoRegistro,1
    je grupoE06Gravar
    mov bx,handlesE06+4
grupoE06Gravar:
    mov cx,26
    call EscreverRegistroE06
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
grupoE06Fim:
    ret
RegistrarGrupoE06 endp
; Funcao: registrar obstaculo gerado entre chamadas de naves.
; Entrada: DI=vaga. Saida: tipo/coordenada de mundo/rolagem, seis bytes.
RegistrarObstE06 proc near
    cmp modoRegistro,2
    jne obstE06Fim
    push ax
    push bx
    push cx
    push dx
    mov ax,obstTipo[di]
    mov registro,ax
    mov ax,obstX[di]
    add ax,distancia
    mov registro+2,ax
    mov ax,rolagem
    mov registro+4,ax
    mov bx,handlesE06+2
    mov cx,6
    call EscreverRegistroE06
    pop dx
    pop cx
    pop bx
    pop ax
obstE06Fim:
    ret
RegistrarObstE06 endp
falhaE06:
    mov ax,caso
    call FormatarScore
    lea dx,erroE06
    mov ah,09h
    int 21h
    lea dx,digitosScore
    mov bx,1
    mov cx,5
    mov ah,40h
    int 21h
    mov ax,4C01h
    int 21h
