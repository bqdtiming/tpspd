.8086
.model tiny
.code
org 100h

start:
    cli
    mov ax, cs
    mov ds, ax
    mov es, ax

    ; Guardamos vector original
    mov ax, 3560h
    int 21h
    mov word ptr old_offset, bx
    mov word ptr old_segment, es

    ; Instalamos nuestra INT 60h
    mov dx, offset nueva_int
    mov ax, 2560h
    int 21h
    sti

    ; Mensaje de instalación exitosa
    mov dx, offset mensaje
    mov ah, 09h
    int 21h

    ; Salimos dejando residente el programa
    mov dx, offset final_programa
    sub dx, 100h      ; calcular cantidad de bytes a dejar residentes
    mov ah, 31h       ; FUNC: Terminate and Stay Resident
    int 21h

; -----------------------
; Interrupción personalizada
nueva_int:
    push ax
    push dx
    mov ax, 4C00h  ; INT 21h / AH=4Ch → salir del programa
    int 21h
    pop dx
    pop ax
    iret

; -----------------------
; Datos
mensaje db "INT 60h instalada. El programa queda residente.$", 0Dh, 0Ah, '$'
activo  db "¡INT 60h activa!$"

old_offset dw 0
old_segment dw 0

final_programa:

end start
