; Auxilio de teste: dirige o laco REAL por teclas no buffer BIOS.
; Funcao: testar menu -> setor -> fim -> menu -> Sair apos 320 quadros.
; Entrada: faseTeste/quadroTeste/estado. Saida: teclas, capturas ou DOS FAIL.
; Altera: registradores, buffer BIOS e arquivos de evidencia.
DirigirTeste proc near
    cmp faseTeste,0
    jne autoFase1
    cmp quadroTeste,320
    jb autoAguardar
    lea dx,nomeCiclo
    call SalvarTelaTeste
    mov cx,5000h
    call InjetarE02
    inc faseTeste
autoAguardar:
    ret
autoFase1:
    cmp faseTeste,1
    jne autoFase2
    cmp opcao,OPCAO_SAIR
    je autoSairSelecionado
    jmp autoFalha
autoSairSelecionado:
    lea dx,nomeSelecao
    call SalvarTelaTeste
    mov cx,4800h
    call InjetarE02
    inc faseTeste
    ret
autoFase2:
    cmp faseTeste,2
    jne autoFase3
    cmp opcao,OPCAO_JOGAR
    je autoJogarSelecionado
    jmp autoFalha
autoJogarSelecionado:
    mov cx,1C0Dh
    call InjetarE02
    ; Enter antigo adicional deve ser descartado ao entrar no setor.
    mov cx,1C0Dh
    call InjetarE02
    inc faseTeste
    ret
autoFase3:
    cmp faseTeste,3
    jne autoFase4
    cmp estado,ESTADO_SETOR
    je autoSetorOk
    jmp autoFalha
autoSetorOk:
    call ConferirBufferVazio
    lea dx,nomeSetor
    call SalvarTelaTeste
    mov cx,1C0Dh
    call InjetarE02
    mov cx,1C0Dh
    call InjetarE02
    inc faseTeste
    ret
autoFase4:
    cmp faseTeste,4
    jne autoFase5
    cmp estado,ESTADO_FIM
    je autoFimOk
    jmp autoFalha
autoFimOk:
    call ConferirBufferVazio
    cmp scoreFinal,SCORE_DEMO
    je autoScoreOk
    jmp autoFalha
autoScoreOk:
    lea si,digitosScore
    lea di,scoreEsperado
    call ConferirDigitos
    lea dx,nomeFim
    call SalvarTelaTeste
    mov cx,1E61h
    call InjetarE02
    inc faseTeste
    ret
autoFase5:
    cmp faseTeste,5
    je autoTestarRetorno
    jmp autoFase6
autoTestarRetorno:
    cmp estado,ESTADO_MENU
    je autoRetornoOk
    jmp autoFalha
autoRetornoOk:
    cmp scoreFinal,0
    je autoResetScoreOk
    jmp autoFalha
autoResetScoreOk:
    cmp opcao,OPCAO_JOGAR
    je autoResetOpcaoOk
    jmp autoFalha
autoResetOpcaoOk:
    lea dx,nomeRetorno
    call SalvarTelaTeste
    ; Letra/Esq/Esc nao alteram selecao nem encerram o menu.
    mov cx,1E61h
    call InjetarE02
    call LerTeclado
    mov cx,4B00h
    call InjetarE02
    call LerTeclado
    mov cx,011Bh
    call InjetarE02
    call LerTeclado
    cmp estado,ESTADO_MENU
    je autoIgnoradasOk
    jmp autoFalha
autoIgnoradasOk:
    cmp opcao,OPCAO_JOGAR
    je autoIgnoradasOpcaoOk
    jmp autoFalha
autoIgnoradasOpcaoOk:
    ; Segunda demonstracao: seta (ASCII zero) tambem retorna do fim.
    mov cx,1C0Dh
    call InjetarE02
    call LerTeclado
    mov cx,1C0Dh
    call InjetarE02
    call LerTeclado
    cmp scoreFinal,SCORE_DEMO
    je autoSegundaOk
    jmp autoFalha
autoSegundaOk:
    mov cx,4800h
    call InjetarE02
    call LerTeclado
    cmp estado,ESTADO_MENU
    je autoSetaRetornoOk
    jmp autoFalha
autoSetaRetornoOk:
    ; Extremos da conversao unsigned, sem alterar o fluxo normal.
    xor ax,ax
    call FormatarScore
    lea si,digitosScore
    lea di,scoreZero
    call ConferirDigitos
    mov ax,65535
    call FormatarScore
    lea si,digitosScore
    lea di,scoreMaximo
    call ConferirDigitos
    mov cx,5000h
    call InjetarE02
    inc faseTeste
    ret
autoFase6:
    cmp opcao,OPCAO_SAIR
    je autoFinalizar
    jmp autoFalha
autoFinalizar:
    mov cx,1C0Dh
    call InjetarE02
    ret
DirigirTeste endp

; Funcao: comparar cinco caracteres. Entrada: DS:SI e DS:DI.
; Saida: retorna ou DOS FAIL. Altera: AX,CX,SI,DI,flags.
ConferirDigitos proc near
    mov cx,5
autoDigito:
    mov al,[si]
    cmp al,[di]
    jne autoFalha
    inc si
    inc di
    loop autoDigito
    ret
ConferirDigitos endp

; Funcao: confirmar descarte das teclas antigas.
; Entrada: buffer BIOS. Saida: retorna ou FAIL. Altera: AX,flags.
ConferirBufferVazio proc near
    mov ah,01h
    int 16h
    jnz autoFalha
    ret
ConferirBufferVazio endp

; Funcao: inserir tecla BIOS. Entrada: CH=scan, CL=ASCII.
; Saida: tecla inserida ou FAIL. Altera: AX,flags.
InjetarE02 proc near
    mov ah,05h
    int 16h
    cmp al,0
    jne autoFalha
    ret
InjetarE02 endp

; Funcao: guardar os 64000 bytes REAIS de A000h para analise externa.
; Entrada: DS:DX=nome ASCIIZ, ES=A000h. Saida: arquivo RAW.
; Altera: AX,BX,CX,DX,flags; preserva DS,ES.
SalvarTelaTeste proc near
    xor cx,cx
    mov ah,3Ch
    int 21h
    jc autoFalha
    mov bx,ax
    push ds
    mov ax,VIDEO_SEG
    mov ds,ax
    xor dx,dx
    mov cx,64000
    mov ah,40h
    int 21h
    pop ds
    jc autoFalha
    cmp ax,64000
    jne autoFalha
    mov ah,3Eh
    int 21h
    jc autoFalha
    ret
SalvarTelaTeste endp

autoFalha:
    mov ax,3
    int 10h
    lea dx,autoErro
    mov ah,09h
    int 21h
    mov ax,4C01h
    int 21h
