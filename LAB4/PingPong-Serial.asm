; multi-segment executable file template.

data segment
    ; add your data here!
    pkey db 10,13,"+++++You Lost!+++++",13,10,"press any key...$"
    StartINT db "Enter ID:",13,10,"$"
    waitforplayer db "Wait For Second Player...",13,10,"$"
    playerfound db "Second Player Found!",13,10,"$"
    Pad_Center db 3
    ball_x db 1
    ball_y db 1
    machin_ID db 1
    turn db 0
    ball_dir db 0 
    is_alive db 1
ends

stack segment
    dw   128  dup(0)
ends

code segment
start:
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
    
    mov dx,2
    mov ah,0
    int 14h
     
     
    cmp machin_ID,0
    jne sendtomaster 
    

    mov ball_dir,1 
    lea dx, waitforplayer
    mov ah, 9
    int 21h 
     
    waitforplayer_re:
    
    mov dx,2
    mov ah,3
    int 14h
    
    and ah,1h
    cmp ah,1       
    
    jne waitforplayer_re 
    
    lea dx, playerfound
    mov ah, 9
    int 21h        
           
    mov ah, 1
    int 21h 

    jmp alive
    
    
    
    sendtomaster:
    
    mov turn,1
    mov dx,2
    mov ah,1
    int 14h 
   
    call CLEAR_SCREEN
alive: 

    cmp is_alive,1
    jne exit


    mov ah,01
    int 16h
    jz ball
    
    movepad:
        mov ah,0
        int 16h 
        cmp ah,72
        je move_up_pad 
        cmp ah,80
        je move_down_pad  
        cmp al,27
        je exit
        jmp alive
      
      
    move_up_pad: 
        cmp Pad_Center,3
        jbe alive
        dec Pad_Center
        jmp print_pad
    
    move_down_pad:  
        cmp Pad_Center,21
        jge alive
        inc Pad_Center
                    
        print_pad:
        call refreshpage
        jmp alive
    
    
    ball:  
    
        ;mov dx,2
        ;mov ah,3
        ;int 14h
        
        ;shr al,4
        ;and al,1
        cmp turn,1
        jne waitforball
        
                     
        mov dh, ball_y
        mov dl, ball_x
        mov bh, 0
        mov ah, 2
        int 10h
     
        mov ah, 2
        mov dl, ' '
        int 21h 
        
        
        call move_ball 
        
        mov dh, ball_y
        mov dl, ball_x
        mov bh, 0
        mov ah, 2
        int 10h
     
        mov ah, 2
        mov dl, 'o'
        int 21h
        
        call delay
        jmp alive
        
        
    waitforball:
        mov dx,2
        mov ah,3
        int 14h
            
        and ah,1h
        cmp ah,1
        jne alive
        
        
        ;;;;;;;read ball pos

         
        xor dx,dx
        mov dx,2
        mov ah,2
        int 14h          
        
        mov ball_y,al  
        ;;;;;;;;;;;;;;;;;;;;
        
        mov turn,1
        
        jmp alive       
        

 exit:
    lea dx, pkey
    mov ah, 9
    int 21h 
    
    ; wait for any key....    
    mov ah, 1
    int 21h
    
    mov ax, 4c00h ; exit to operating system.
    int 21h

    

proc refreshpage

     call CLEAR_SCREEN
     
     mov al,Pad_Center
     sub al,3
     mov cx,7
pad:
     
    mov dh, al
    mov dl, 0
    mov bh, 0
    mov ah, 2
    int 10h
    
    push ax
    mov ah, 2
    mov dl, '|'
    int 21h 
    pop ax
    inc ax
loop pad 

ret       
endp











print_ax_bin proc  
    pusha
    ; print result value in binary:
    mov cx, 16
    mov bx, ax
    print: mov ah, 2   ; print function.
           mov dl, '0'
           test bx, 1000000000000000b  ; test first bit.
           jz zero
           mov dl, '1'
    zero:  int 21h
           shl bx, 1
    loop print      
    ; print binary suffix:
    mov dl, 'b'
    int 21h  
    popa  
    ret
endp    

print_nl proc 
    push ax  
    push dx  
    mov ah, 2
    mov dl, 0Dh
    int 21h  
    mov dl, 0Ah
    int 21h   
    pop dx 
    pop ax      
    ret
endp







DELAY PROC 
    frst dw ?
    MOV     AH, 00H
    INT     1AH 
    add dx,01h;delay time
    mov frst,dx
    TIMER:
    MOV     AH, 00H
    INT     1AH
    CMP     DX,frst
    JB      TIMER
    RET
DELAY ENDP





proc move_ball
 
    cmp ball_dir,1
    je move_ball_left
    
    cmp ball_x,79
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
    jnge lost
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

    ;;;;;Send ball pos
    
   
        
    mov dx,2
    mov ah,1
    mov al,ball_y
    int 14h       

    mov turn,0
    
    jmp revers_ball_dir
    ;;;;;;;;;;;;;;;;;;
                        

 
ret    

    
endp


CLEAR_SCREEN PROC
    PUSH    AX      ; store registers...
    PUSH    DS      ;
    PUSH    BX      ;
    PUSH    CX      ;
    PUSH    DI      ;
    
    MOV     AX, 40h
    MOV     DS, AX  ; for getting screen parameters.
    MOV     AH, 06h ; scroll up function id.
    MOV     AL, 0   ; scroll all lines!
    MOV     BH, 07  ; attribute for new lines.
    MOV     CH, 0   ; upper row.
    MOV     CL, 0   ; upper col.
    MOV     DI, 84h ; rows on screen -1,
    MOV     DH, [DI] ; lower row (byte).
    MOV     DI, 4Ah ; columns on screen,
    MOV     DL, [DI]
    DEC     DL      ; lower col.
    INT     10h
    
    ; set cursor position to top
    ; of the screen:
    MOV     BH, 0   ; current page.
    MOV     DL, 0   ; col.
    MOV     DH, 0   ; row.
    MOV     AH, 02
    INT     10h
    
    POP     DI      ; re-store registers...
    POP     CX      ;
    POP     BX      ;
    POP     DS      ;
    POP     AX      ;
    
    RET
CLEAR_SCREEN ENDP 



end start ; set entry point and stop the assembler.
ends