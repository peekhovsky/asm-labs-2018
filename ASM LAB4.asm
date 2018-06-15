org 100h

;video memory B800h:0000h - B800h:FFFFh   

.code
;default 16-color mode
mov ah, 00 
mov al, 03
int 10h
 
 
push 0B800h
pop es


;fullfill screen by blue color
mov ah, 001
mov al, '+'  

mov ah, 05
mov al, 0
int 10h
    
game:
    
    ;set visible cursor 
    mov ax,1
    int 33h
   
    mov ah, 03
    mov bh, 0
    int 10h
        
    xor ax, ax
    xor bx, bx
        
    mov al, dh
    mov bl, dl
    mul bx
    mov di, ax 
 
    mov ah, 001
    mov al, '4' 
    mov word ptr es:[di],ax 
    
    mov ah, keyboard_type
    int 16h
    jnz got_key
    
    jmp game
    
    got_key:     
      cmp ah, 4Bh     ;left arrow key    
      je got_left_key   
      cmp ah, 48h     ;up arrow key
      je got_up_key 
      cmp ah, 4Dh     ;right arrow key 
      je got_right_key 
      cmp ah, 50h     ;down arrow key
      je got_down_key
      
     
      jmp end_got_key                    
                          
   got_left_key: 
      mov ah, 1
      call move_cursor        
   jmp end_got_key
        
   got_up_key: 
   ;   mov ah, 2  
    ;  call move_cursor
   jmp end_got_key
    
      
   got_right_key:
      mov ah, 3 
      call move_cursor
   jmp end_got_key 
      
   got_down_key:
   ;   mov ah, 4
   ;   call move_cursor
   jmp end_got_key   
   
   end_got_key:
   mov ah, 00h
   int 16h   
          
jmp game


move_platform_right proc
    pusha 
            
    
    popa
    ret 
move_platform_left endp 


;ah, al - delta 
move_cursor proc
    pusha
    
    push ax 
    
    mov ah, 03
    mov bh, 0
    int 10h ;dh - row, dl - column  
    
    pop ax 
    
    cmp ah, 1
    je move_cursor_left
    
    cmp ah, 2
    je move_cursor_up   
    
    cmp ah, 3
    je move_cursor_right 
    
    cmp ah, 4
    je move_cursor_down  
    
    
    move_cursor_left:
        dec dl
        jmp move_cursor_end    
    move_cursor_up:  
        dec dh
        jmp move_cursor_end 
    move_cursor_right: 
        inc dl
        jmp move_cursor_end 
    move_cursor_down: 
        inc dh
        jmp move_cursor_end 
    
    move_cursor_end:
        mov ax,2; Спрятать курсор
        int 33h
 
        mov ah, 09
        mov bh, 00
        mov bl, 001
        mov cx,1
        mov al, '+'
        int 10h 
        
        mov ax,1
        int 33h
    popa
    ret
move_cursor endp    


;ah and al - color or character
fullfill_screen proc 
    pusha
    push di
     
    mov di, 0000h
    mov word ptr es:[di],ax
      inc di
      inc di 
      push di
      pop dx
      cmp dx, 0FA0h 
        
    pop di  
    popa  
    ret
fullfill_screen endp    


;dh - row, dl - column
;ax - attribute
set_character proc 
    pusha
    
    push ax 
    
    xor ax, ax
    mov ah, dh
    mov bx, 160
    mul bx 
    
    xor dh, dh
    add ax, dl  
    
    mov di, ax
      
    pop ax

    cmp ax, 0FAh
    ja end_set_character   
    mov word ptr es:[di],ax
                   
    end_set_character:
    popa
    ret
set_character endp


;end
int 20h 


.data
previous_position dw 0000h 
keyboard_type db 01h

platform_position db 00h

