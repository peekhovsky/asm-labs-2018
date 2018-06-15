; multi-segment executable file template.

data segment
    ; add your data here!
    pkey db 10,13,"+++++You Lost!+++++",13,10,"press any key...$"
    StartINT db "Enter ID:",13,10,"$"
    Pad_Center db 3
    ball_x db 39
    ball_y db 12
    machin_ID db 1
    ball_dir db 0 
    is_alive db 1
ends

stack segment
    dw   128  dup(0)
ends

code segment
start:
; set segment registers:
    mov ax, data
    mov ds, ax
    mov es, ax
    

    lea dx, StartINT
    mov ah, 9
    int 21h        
    
    mov ah,0
    int 16h
    
    sub al,48
    
    mov machin_ID,al
    
    mov ch, 32
    mov ah, 1
    int 10h  

    
alive:
    mov ah,01
    int 16h
    jnz movepad
return:
  in al,121
  cmp al,machin_ID
  jne waitforball 
  
  in ax,123
  
   mov ball_x,ah
   mov ball_y,al  
  


  
  call move_ball
   
  mov ah,ball_x
  mov al,ball_y    
  out 123,ax 
waitforball:
    call refreshpage
 cmp is_alive,1
 je alive  
 
 lea dx, pkey
 mov ah, 9
 int 21h 
    ; wait for any key....    
    mov ah, 1
    int 21h
    
    mov ax, 4c00h ; exit to operating system.
    int 21h
    
 

movepad:
  mov ah,0
  int 16h 
  cmp ah,72
  je move_up_pad 
  cmp ah,80
  je move_down_pad  
  jmp return
  
move_up_pad: 
  cmp Pad_Center,3
  jng return  
  dec Pad_Center
  jmp return

move_down_pad:  
  cmp Pad_Center,20
  jge return

  inc Pad_Center
  jmp return
  
    
    ; add your code here
            

    

proc refreshpage
     push ax
     push bx
     push cx
     push dx
     
     mov ax,0h
     int 10h
     
     mov dl ,Pad_Center
     sub dl ,3
    
     mov cx,7 
     mov ax, 0b800h
     mov ds,ax   

    pad: 
     xor ax,ax
     mov al,dl  
     mov bl,80
     mul bl
     mov si,ax 
	 mov [si], '|'
     inc dl    
 loop pad    
 
   	mov ax,data 
	mov ds,ax 
    
    in al,121
    cmp al,machin_ID
    jne dont_print_ball 
    
    mov ah,2
    mov dh,ball_y
    mov dl,ball_x
    xor bh,bh
    int 10h
    
    mov ah,2
    mov dl,'O'
    int 21h
    
	dont_print_ball:

    pop ax
    pop bx
    pop cx
    pop dx
ret       
endp

proc move_ball
    
    cmp ball_dir,1
    je move_ball_left
    
    cmp ball_x,39
    jge pass_ball
    inc ball_x 
    ret
    move_ball_left:
    dec ball_x
    cmp ball_x,1
    jng check_pad_pos
    ret
    
    check_pad_pos:
    
    mov al,ball_y
    sub al,Pad_Center
    cmp al,3 
    jg lost
    cmp al,-3
    jng lost
    cmp al,0
    jg top_reflect
    jnge down_reflect
    
    top_reflect:
    sub ball_y,2
    jmp revers_ball_dir
    
    down_reflect:
    add ball_y,2 
    
    revers_ball_dir:
    mov al,ball_dir
    xor al,0001b
    mov ball_dir,al
    
    cmp ball_y,0
    jle lost
    
    cmp ball_y,24
    jg lost
     
    ret
    
    lost:
     mov is_alive,0
     ret 
    
    
    pass_ball:
     mov al,machin_ID
     xor al,0001b 
     out 121,al
     mov al,ball_dir
     xor al,0001b
     mov ball_dir,al
     
     ret
    
endp

ends

end start ; set entry point and stop the assembler.
