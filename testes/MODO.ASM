; Verificacao DOS independente, executada apos ESC.EXE.
.8086
.model small
.stack 100h
.data
ok db 'PASS: modo texto 03h e pagina 0 restaurados',13,10,'$'
erro db 'FAIL: modo/pagina de video',13,10,'$'
.code
; Funcao: consultar modo e pagina apos o programa terminar.
; Entrada: nenhuma. Saida: mensagem DOS e codigo 0=passou/1=falhou.
; Altera: AX,BX,DX,DS,flags.
inicio proc
    mov ax,@data
    mov ds,ax
    mov ah,0Fh
    int 10h
    cmp al,3
    jne falha
    cmp bh,0
    jne falha
    lea dx,ok
    mov ah,09h
    int 21h
    mov ax,4C00h
    int 21h
falha:
    lea dx,erro
    mov ah,09h
    int 21h
    mov ax,4C01h
    int 21h
inicio endp
end inicio
