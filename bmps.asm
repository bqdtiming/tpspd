.8086
.model small
.stack 100h
.data
filename db 'veamos.bmp',0
filename1 db 'sigana.bmp',0
filename2 db 'sipierde.bmp',0
filehandle dw ?
Header db 54 dup (0)
Palette db 256*4 dup (0)
ScrLine db 320 dup (0)
ErrorMsg db 'Error', 13, 10,'$'

public mostrarImagen
public imagenPierde
public imagenGana

.code

mostrarImagen proc

    mov ax, 13h
    int 10h
    ;procesar la imagen
    call OpenFile
    call ReadHeader
    call ReadPalette
    call CopyPal
    call CopyBitmap
    
    mov ah,1
    int 21h
    ; texto (03h)
    mov ah, 0
    mov ax, 03h
    int 10h

ret
mostrarImagen endp 

imagenGana proc

    mov ax, 13h ;entro a modo grafico
    int 10h
    ;procesar la imagen
    call OpenFile1
    call ReadHeader
    call ReadPalette
    call CopyPal
    call CopyBitmap
    
    ;espero cualquier tecla
    mov ah,1
    int 21h
    ;vuelvo a texto (03h)
    mov ah, 0
    mov ax, 03h
    int 10h

ret
ImagenGana endp

ImagenPierde proc
    mov ax, 13h ;entro a modo grafico
    int 10h
    ;procesar la imagen
    call OpenFile2
    call ReadHeader
    call ReadPalette
    call CopyPal
    call CopyBitmap
    
    ;espero cualquier tecla
    mov ah,1
    int 21h
    ;vuelvo a texto (03h)
    mov ah, 0
    mov ax, 03h
    int 10h

pop ax
ret
ImagenPierde endp  

proc OpenFile

    ; Open file

    mov ah, 3Dh
    xor al, al
    mov dx, offset filename
    int 21h

    jc opnerror
    mov [filehandle], ax
    ret

    opnerror:
    mov dx, offset ErrorMsg
    mov ah, 9h
    int 21h

    ret
endp OpenFile

proc OpenFile1

    ; Open file

    mov ah, 3Dh
    xor al, al
    mov dx, offset filename1
    int 21h

    jc AbrirError
    mov [filehandle], ax
    ret

    AbrirError:
    mov dx, offset ErrorMsg
    mov ah, 9h
    int 21h

    ret
endp OpenFile1

proc OpenFile2

    ; Open file

    mov ah, 3Dh
    xor al, al
    mov dx, offset filename2
    int 21h

    jc ErrorAbrir
    mov [filehandle], ax
    ret

    ErrorAbrir:
    mov dx, offset ErrorMsg
    mov ah, 9h
    int 21h

    ret
endp OpenFile2

proc ReadHeader

    ; Read BMP file header, 54 bytes

    mov ah,3fh
    mov bx, [filehandle]
    mov cx,54
    mov dx,offset Header
    int 21h
    ret
    endp ReadHeader
    proc ReadPalette

    ; Read BMP file color palette, 256 colors * 4 bytes (400h)

    mov ah,3fh
    mov cx,400h
    mov dx,offset Palette
    int 21h

    ret
endp ReadPalette
proc CopyPal

    ; Copy the colors palette to the video memory
    ; The number of the first color should be sent to port 3C8h
    ; The palette is sent to port 3C9h

    mov si,offset Palette
    mov cx,256
    mov dx,3C8h
    mov al,0

    ; Copy starting color to port 3C8h

    out dx,al

    ; Copy palette itself to port 3C9h

    inc dx
    PalLoop:

    ; Note: Colors in a BMP file are saved as BGR values rather than RGB.

    mov al,[si+2] ; Get red value.
    shr al,2 ; Max. is 255, but video palette maximal

    ; value is 63. Therefore dividing by 4.

    out dx,al ; Send it.
    mov al,[si+1] ; Get green value.
    shr al,2
    out dx,al ; Send it.
    mov al,[si] ; Get blue value.
    shr al,2
    out dx,al ; Send it.
    add si,4 ; Point to next color.

    ; (There is a null chr. after every color.)

    loop PalLoop

    ret
endp CopyPal

proc CopyBitmap

    ; BMP graphics are saved upside-down.
    ; Read the graphic line by line (200 lines in VGA format),
    ; displaying the lines from bottom to top.

    mov ax, 0A000h
    mov es, ax
    mov cx,200
    PrintBMPLoop:
    push cx

    ; di = cx*320, point to the correct screen line

    mov di,cx
    shl cx,6
    shl di,8
    add di,cx

    ; Read one line

    mov ah,3fh
    mov cx,320
    mov dx,offset ScrLine
    ;add dx,0
    int 21h

    ; Copy one line into video memory

    cld 

    ; Clear direction flag, for movsb

    mov cx,320
    mov si,offset ScrLine
    rep movsb 

    ; Copy line to the screen
    ;rep movsb is same as the following code:
    ;mov es:di, ds:si
    ;inc si
    ;inc di
    ;dec cx
    ;loop until cx=0

       pop cx
    loop PrintBMPLoop

    ret
endp CopyBitmap
end 
