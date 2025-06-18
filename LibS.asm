.8086
.model small
.stack 100h

.data
	salto 			db 0dh, 0ah, 24h
	EseNo   		db "Ingrese una opcion valida.", 0dh, 0ah, 24h
	seguro 			db "Ahora, listo?", 0dh, 0ah, 24h
	cartel 			db  "S (si) / N (no)", 0ah, 0dh, 24h
	personajesOG	db '0',"1","2","3","4","5","6","7","8","9","10",0dh,0ah,24h
	personajes		db '0',"1","2","3","4","5","6","7","8","9","10",0dh,0ah,24h
	pregunta1		db "Tu personaje es femenino?",0dh,0ah,24h
	pregunta2 		db "Tu personaje es animado?",0dh,0ah,24h
	pregunta3 		db "Tu personaje es de nacionalidad argentina?",0dh,0ah,24h
	pregunta4 		db "Tu personaje sale en una serie o pelicula?",0dh,0ah,24h
	pregunta5 		db "Tu personaje es deportista?",0dh,0ah,24h
	textoFinal		db "Tu personaje es: ",24h
	archivo			db "txt.txt",24h
	filehandler 	db 00h,00h
 	readchar 		db 20h
 	filerror 		db "Archivo no existe o error de apertura", 0dh, 0ah, '$'
 	charactererror 	db "Error de lectura de caracter", 0dh, 0ah, '$'
 	nextpage 		db "Presione <Enter> para seguir, otra tecla para salir...", "$"
 	currentline 	db 01h
 	lastReadPos 	dw 00h
 	;sonidos
 	notasPierde dw 2280, 3043, 3619                   ; C5, G4, E4                 ;3
    notasGana   dw 4560, 3619, 3043, 2280             ; C4, E4, G4, C5             ;4
    notasInicio dw 8609, 2152, 1436, 2031, 5746, 4304 ; C3, C5#, G5#, D5, G3#, C4# ;6
  
.code

public sonidoGana
public sonidoPierde
public sonidoInicio ;no 
public regToAscii
public impresion
public cargaEspecial
public cargaEspecial2
public preguntar1
public preguntar2
public preguntar3
public preguntar4
public preguntar5
public resultado
public respuestas
public Clearscreen
public leer 
public restablecerPersonajes
public preguntaSN

	saltoFunc proc 
		mov ah,9
		mov dx, offset salto
		int 21h
	ret
	saltoFunc endp

	proc Clearscreen
		push ax
		push es
		push cx
		push di
		mov ax,3
		int 10h
		mov ax,0b800h
		mov es,ax
		mov cx,1000
		mov ax,7
		mov di,ax
		cld
		rep stosw
		pop di
		pop cx
		pop es
		pop ax
		ret 
	Clearscreen endp

	impresion proc 
        push ax
        mov ah,9
        int 21h
        pop ax
        ret
	impresion endp

	regtoascii proc	;recibe en bx el offset de una variable de 3 bytes
					;el numero a convertir por dl
        push ax
        push dx

		add bx,2

		xor ax,ax
		mov al, dl
		mov dl, 10
		div dl
		add ah,30h
		mov [bx],ah

		xor ah,ah
		dec bx
	    div dl
		add [bx],ah

		xor ah,ah
		dec bx
	    div dl
		add [bx],ah

        pop dx
        pop ax

        ret
    regtoascii endp
;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;Funcion para recibir un si o un no
cargaEspecial proc
		push ax
		push bx

		proceso24:
			mov ah, 1
			int 21h
			cmp al, 1Bh      ; Si el usuario presiona ESC
			je int60h2

			cmp al, 's'
			je sigue
			cmp al, 'S'
			je sigue
			cmp al, 'n'
			je asustadoPotter
			cmp al, 'N'
			je asustadoPotter

			call saltoFunc

			mov dx, offset EseNo
			call impresion

			mov dx, offset cartel
			call impresion

		jmp proceso24

		asustadoPotter:
			call saltoFunc

			mov dx, offset seguro
			call impresion

			mov dx, offset cartel
			call impresion

		jmp proceso24

		sigue:

		finCarga24:
			pop bx
			pop ax
			ret

		int60h2:
		int 60h           ; Llamar a la interrupción 60h

	cargaEspecial endp

	cargaEspecial2 proc
		push bx

	proceso25:
		mov ah, 1
		int 21h
		cmp al, 1Bh      ; Si el usuario presiona ESC
		je int60h

		cmp al, 's'
		je sigue25
		cmp al, 'S'
		je sigue25
		cmp al, 'n'
		je sigue25
		cmp al, 'N'
		je sigue25

		call saltoFunc
		mov dx, offset EseNo
		call impresion
		mov dx, offset cartel
		call impresion
		jmp proceso25

	sigue25:
		pop bx
		ret

	int60h:
		int 60h           ; Llamar a la interrupción 60h

cargaEspecial2 endp

	leer proc
	  push dx
	  push cx
	  push bx
	  push ax 

	  lea dx,archivo
	  mov ah,3dH
	  mov al,0
	  int 21H
	  jc openerr
	  mov word ptr[filehandler], ax

	char:
	  mov ah,3FH
	  mov bx, word ptr [filehandler]
	  mov cx,1
	  lea dx,readchar
	  int 21H
	  jc charerr
	  
	  cmp ax,0
	  je finalLeer
	  
	  cmp byte ptr [readchar],'#'
	  je foundHash

	  mov dl,readchar
	  mov ah,02H
	  int 21H
	  
	  cmp dl,0ah
	  jne char
	  cmp currentline,18h
	  je endofpage
	  inc currentline
	  jmp char

	foundHash:
		jmp finalLeer

	endofpage:
	  lea dx, nextpage
	  mov ah,9
	  int 21h
	  
	  mov ah,1
	  int 21h
	  cmp al,0dh
	  jne finalLeer
	  mov currentline,01h
	  jmp char
	 
	 openerr:
	  lea dx, filerror
	  mov ah,9
	  int 21h
	  jmp finalLeer
	  
	 charerr:
	  lea dx, charactererror
	  mov ah,9
	  int 21h
	  jmp finalLeer
	 
	finalLeer:
		call saltoFunc
		pop ax
		pop bx
		pop cx
		pop dx
		ret 
	leer endp

	respuestas proc
			mov ah, 1
			int 21h
			call saltoFunc
		ret
	respuestas endp

	preguntar1 proc
		push ax
		push dx
		
		mov al, 0
		mov personajes[0],0
		mov dx, offset pregunta1
		call impresion

		call cargaEspecial2
		call saltoFunc

		cmp al, 'S'
		je esFemenino
		cmp al, 's'
		je esFemenino
		cmp al, 'N'
		je noEsFemenino
		cmp al, 'n'
		je noEsFemenino

		esFemenino:
			mov al, 0
			mov personajes[1],al 
			mov personajes[2],al 
			mov personajes[3],al 
			mov personajes[6],al 
			mov personajes[9],al  
			jmp finPreguntar1

		noEsFemenino:
			mov al, 0
			mov personajes[4],al
			mov personajes[5],al
			mov personajes[7],al
			mov personajes[8],al
			mov personajes[10],al
			jmp finPreguntar1

		finPreguntar1:
		pop dx
		pop ax
		ret 
	preguntar1 endp

	preguntar2 proc
		push ax
		push dx
		
		mov dx, offset pregunta2
		call impresion

		call cargaEspecial2
		call saltoFunc

		cmp al, 'S'
		je esAnimado
		cmp al, 's'
		je esAnimado
		cmp al, 'N'
		je noEsAnimado
		cmp al, 'n'
		je noEsAnimado

		esAnimado:
			mov al, 0
			mov personajes[1],al
			mov personajes[2],al 
			mov personajes[5],al
			mov personajes[6],al
			mov personajes[7],al
			mov personajes[8],al 
			jmp finPreguntar2

		noEsAnimado:
			mov al, 0
			mov personajes[3],al
			mov personajes[4],al
			mov personajes[9],al
			mov personajes[10],al
			jmp finPreguntar2
			 
		finPreguntar2:
		pop dx
		pop ax
		ret
	preguntar2 endp

	preguntar3 proc
		push ax
		push dx
		
		mov dx, offset pregunta3
		call impresion

		call cargaEspecial2
		call saltoFunc

		cmp al, 'S'
		je esArgentino
		cmp al, 's'
		je esArgentino
		cmp al, 'N'
		je noEsArgentino
		cmp al, 'n'
		je noEsArgentino

		esArgentino:
			mov al, 0
			mov personajes[1],al
			mov personajes[3],al
			mov personajes[4],al
			mov personajes[7],al
			mov personajes[9],al 
			jmp finPreguntar3

		noEsArgentino:
			mov al, 0
			mov personajes[2],al
			mov personajes[5],al
			mov personajes[6],al
			mov personajes[8],al
			mov personajes[10],al
			jmp finPreguntar3
			 
		finPreguntar3:
		pop dx
		pop ax
		ret
	preguntar3 endp

	preguntar4 proc
		push ax
		push dx

		mov dx, offset pregunta4
		call impresion

		call cargaEspecial2
		call saltoFunc

		cmp al, 'S'
		je seriePeli
		cmp al, 's'
		je seriePeli
		cmp al, 'N'
		je noSeriePeli
		cmp al, 'n'
		je noSeriePeli

		seriePeli:
			mov al, 0
			mov personajes[5],al
			mov personajes[6],al 
			jmp finPreguntar4

		noSeriePeli:
			mov al, 0
			mov personajes[1],al
			mov personajes[2],al
			mov personajes[3],al
			mov personajes[4],al
			mov personajes[7],al
			mov personajes[8],al
			mov personajes[9],al
			mov personajes[10],al
			jmp finPreguntar4
			 
		finPreguntar4:
		pop dx
		pop ax
		ret
	preguntar4 endp

	preguntar5 proc
		push ax
		push dx 

		mov dx, offset pregunta5
		call impresion

		call cargaEspecial2
		call saltoFunc

		cmp al, 'S'
		je esDeportista
		cmp al, 's'
		je esDeportista
		cmp al, 'N'
		je noEsDeportista
		cmp al, 'n'
		je noEsDeportista

		esDeportista:
			mov al, 0
			mov personajes[1],al
			mov personajes[2],al
			mov personajes[4],al
			mov personajes[7],al
			mov personajes[8],al
			mov personajes[9],al
			mov personajes[10],al
			jmp finPreguntar5

		noEsDeportista:
			mov al, 0
			mov personajes[3],al
			mov personajes[5],al
			mov personajes[6],al
			jmp finPreguntar5
			 
		finPreguntar5:
		pop dx
		pop ax
		ret
	preguntar5 endp

	resultado proc 
		mov si,0

		compara:
			cmp si, 11
			je finProceso
			cmp personajes[si],0 
			jne final 
			inc si 
			jmp compara

		final:
			;mov bx, offset personajeAscii
			;mov dx, si
			;call regtoascii

			jmp finProceso

		finProceso:
	ret 
	resultado endp

restablecerPersonajes proc
	push ax
	push si
	mov si, 0
	siguiente_byte:
		cmp si, 12       ; hay 12 caracteres en total
		je fin_restaura
		mov al, personajesOG[si]
		mov personajes[si], al
		inc si
		jmp siguiente_byte
	fin_restaura:
	pop si
	pop ax
	ret
restablecerPersonajes endp

preguntaSN proc ;DEVUELVE EN AH si es SI o NO 
push bx
push dx
		comparandoo:
			mov ah,1
			int 21h
			cmp al, 's'
			je EsSi
			cmp al, 'S'
			je EsSi
			cmp al, 'n'
			je EsNo
			cmp al, 'N'
			je EsNo

			call saltoFunc

			mov dx, offset EseNo
			call impresion

			mov dx, offset cartel
			call impresion

		jmp comparandoo

        EsNo:
		 mov ah, 0
         jmp FinCargaSN

        EsSi:
         mov ah, 1
         jmp FinCargaSN

finCargaSN:
pop dx
pop bx
ret
preguntaSN endp
    
sonidoInicio proc
push si
push cx

    mov si, offset notasInicio
    mov cx, 6
    proximo:
    lodsw
    call sonido
    call delayMain
    loop proximo

pop cx
pop si
ret
sonidoInicio endp
;
sonidoPierde proc
push si
push cx

    mov si, offset notasPierde
    mov cx, 3
    next:
    lodsw
    call sonido
    call delayMain
    loop next

pop cx
pop si
ret
sonidoPierde endp
;
sonidoGana proc
push si 
push cx

    mov si, offset notasGana
    mov cx, 4            

siguiente:
    lodsw ;va a la prox frecuencia 
    call sonido
    call delay  
    loop siguiente

pop cx
pop si
ret
sonidoGana endp 

sonido proc
push bx
push dx

    ;configuracion para el sonido (?)
    mov al, 0B6h
    out 43h, al

    ;hay q dividir frecuencia base (1.193.180 Hz) por el valor en AX
    mov dx, ax
    mov al, dl
    out 42h, al
    mov al, dh
    out 42h, al

    ;prende altavoz (bit 0 y 1 de puerto 61h)
    in al, 61h
    or al, 3
    out 61h, al

    call delay
    in al, 61h
    and al, 0FCh
    out 61h, al

pop dx
pop bx
ret
sonido endp

delay proc 
    push ax
    push cx
    mov cx, 2  ;cant ticks a esperar (1 x 55ms) -> lo cambie a 2
    mov ax, 40h
    mov es, ax

esperarTiempo:
    mov ax, es:[6Ch] ;leo tick actual
esperarTick:
    cmp ax, es:[6Ch]
    je esperarTick ;espero a q cambie
    loop esperarTiempo

    pop cx
    pop ax
    ret
delay endp

delayMain proc ;alargo delay
    push ax
    push cx
    mov cx, 5  ;cant ticks a esperar (1 x 55ms) -> lo cambie a 3
    mov ax, 40h
    mov es, ax

esperarTiempoMain:
    mov ax, es:[6Ch] ;leo tick actual
esperarTickMain:
    cmp ax, es:[6Ch]
    je esperarTick ;espero a q cambie
    loop esperarTiempoMain

    pop cx
    pop ax
    ret
delayMain endp

end
