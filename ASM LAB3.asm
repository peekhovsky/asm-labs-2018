;Вариант 4: выполнить набор логических побитовых операций над двумя целыми числами,
;представленными в шеснадцатиричной системе счисления  
    
.model tiny
.code 
org  100h                             
    
    ;/*---------------main-body---------------*/ 
    
    ;intput first number
    ;output message
    lea dx, enterFirstNumberMessage
    call output_string
     
    ;input string with hex to buffer 
    lea dx, input_buffer
    call input_string
    
    ;translate to word-number
    lea si, input_buffer 
    call hex_string_to_word 
    
    mov [var1], dx
         
         
    ;intput second number    
    ;output message
    lea dx, enterSecondNumberMessage
    call output_string
     
    ;input string with hex to buffer 
    lea dx, input_buffer
    call input_string
    
    ;translate to word-number
    lea si, input_buffer 
    call hex_string_to_word  
    
    mov [var2], dx
     
     
    ;and operation         
    mov dx, [var1]   
    mov ax, [var2]  
    
    and ax, dx
     
    ;output message
    lea dx, andResultMessage
    call output_string    
    
    ;translate num to hex string
    mov si, offset output_buffer
    call word_to_hex_string
    
    ;output hex string
    lea dx, output_buffer
    call output_string
        
        
    ;or operation          
    mov dx, [var1]   
    mov ax, [var2]  
    
    or ax, dx
     
    ;output message
    lea dx, orResultMessage
    call output_string    
    
    ;translate num to hex string
    mov si, offset output_buffer
    call word_to_hex_string
    
    ;output hex string
    lea dx, output_buffer
    call output_string
     
     
    ;xor operation       
    mov dx, [var1]   
    mov ax, [var2]  
    
    xor ax, dx
     
    ;output message
    lea dx, xorResultMessage
    call output_string    
    
    ;translate num to hex string
    mov si, offset output_buffer
    call word_to_hex_string
    
    ;output hex string
    lea dx, output_buffer
    call output_string 
    
    ;not operation       
    mov ax, [var1]   
    not ax
     
    ;output message
    lea dx, notFirstResultMessage
    call output_string    
    
    ;translate num to hex string
    mov si, offset output_buffer
    call word_to_hex_string
    
    ;output hex string
    lea dx, output_buffer
    call output_string  
     
    ;not operation 
    mov ax, [var2]   
    not ax 

    ;output message
    lea dx, notSecondResultMessage
    call output_string    
    
    ;translate num to hex string
    mov si, offset output_buffer
    call word_to_hex_string
    
    ;output hex string
    lea dx, output_buffer
    call output_string 
   
    int 20h
    
;/*----------------translations---------------*/
    
;si -> pointer to buffer with string 
;dx <- return word 
hex_string_to_word proc
    push ax
    push bx
    push cx
        
    xor cx, cx      ;cx == 0
    mov cl, [si]+1  ;string length to cx
    
    cmp cl, 4       ; if (cx > 4) oversized_string_error
    jg oversized_string_error
   
    xor dx, dx      ;dx == 0
                       
    inc si          ;si to string front  
    
    hex_string_to_word_loop:
        
        inc si          ;move in buffer
        shl dx, 4       ;move bits in dx (0000 0000 0000 0000) <-4
        
        xor ax, ax      ;ax == 0
       
        mov al, [si]    ;ax == &si    
        
        cmp al, '0'     ;if (ax < '0') not a number
        jl not_a_number_error
         
        cmp al, '9'     ;if (ax > '9') it is a letter
        jg letter 
        
        sub al, '0'     ;get tetrade number
        jmp not_a_letter_skip
        
        letter: 
            and al, 11011111b ;uppercase  
            
            cmp al, 'A'   ;if (ax < 'A') not a number
            jl not_a_number_error  
           
            cmp al, 'F'   ;if (ax > 'F') not a number
            jg not_a_number_error   
            
            sub al,'A'-10 ;get tetrade number
        
        not_a_letter_skip:
        
        or dx, ax       ;push into dx     
        
        
    loop hex_string_to_word_loop 
     
    pop cx 
    pop bx    
    pop ax
    ret
hex_string_to_word endp 
     
     
     
;ax   -> word number
;si   -> pointer to buffer
;[si] <- hex string
word_to_hex_string proc
    push ax
    push bx
    push cx
    push dx
    
    mov dx, ax
    
    and dl, 00001111b  ;move bits to get small tetrade   
    call tetrage_to_char
    mov [si]+3, dl      
    
    mov dx, ax
    
    shr dl, 4  ;move bits to get big tetrade   
    call tetrage_to_char
    mov [si]+2, dl    
    
    mov dx, ax 
    mov dl, dh
    
    and dl, 00001111b  ;move bits to get small tetrade   
    call tetrage_to_char
    mov [si]+1, dl      
    
    mov dx, ax
    mov dl, dh
    
    shr dl, 4  ;move bits to get big tetrade   
    call tetrage_to_char
    mov [si], dl
    
    pop dx
    pop cx
    pop bx 
    pop ax
      
    ret 
word_to_hex_string endp    
 
 
;dl -> register with tetrade
;dl <- ascii of char
tetrage_to_char proc
        
        add dl, '0'    ;add ascii of '0' to get dec num char 
        
        cmp dl, '9'    ;if al > '9' it is a letter 
        jle tetrage_to_char_end
        
        add dl, 7      ;if letter get right letter by adding 7
                       ;(acsii codes)
    
    tetrage_to_char_end:    
    ret
tetrage_to_char endp

 
    ;/*----------input-output-procedures---------*/ 
    
;input string in memory consist of: [0] - max_size, [1] - real_size, [2-201] - string   
;dx - adress in memory with buffer for new string                        
input_string proc  
    push ax       
                     
    mov AH, 0Ah
    int 21h          
    call statr_new_line  
    
    pop ax
    ret      
input_string endp    

;procedure for new line     
statr_new_line proc    
    pusha   
    
    mov DL, 0Dh
    mov Ah, 02h
    int 21h 
    
    mov DL, 0Ah
    mov Ah, 02h
    int 21h
    
    popa
    ret    
statr_new_line endp  


;dx - pointer to start of your string
;string must have '$' at the end of itself 
output_string proc    
    push ax        
     
    mov AH, 09h
    int 21h  
    call statr_new_line  
  
    pop ax
    ret              
output_string endp



  ;/*---------errors--------*/

oversized_string_error:
    lea dx, oversizedStringErrorMessage       
    call output_string
    int 20h   
    
not_a_number_error:
    lea dx, notANumberErrorMessage       
    call output_string
    int 20h           
             
  ;/*---------data----------*/  
.data 

;buffers     
input_buffer db 5, 8 dup ('$') 
output_buffer db 5, 8 dup ('$')   

var1 dw 0000h    
var2 dw 0000h
                                  
;messages
enterFirstNumberMessage    db "Enter first number: $"
enterSecondNumberMessage   db "Enter second number: $"  

andResultMessage   db   "And result: $"
orResultMessage    db   "Or result: $"
xorResultMessage   db   "Xor result: $" 
notFirstResultMessage   db   "Not result (first number): $" 
notSecondResultMessage   db   "Not result (second number): $"
;errors
oversizedStringErrorMessage db "Error: oversized input!$"  
notANumberErrorMessage      db "Error: not a number!$" 