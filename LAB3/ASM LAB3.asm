;Вариант 4: выполнить набор логических побитовых операций над двумя целыми числами,
;представленными в шеснадцатиричной системе счисления  
    
.model tiny
.code 
org  100h                             
                 
                 
;/-------------input--------------/
mov dx, offset hex_buffer 
call input_string     

mov dx, offset hex_buffer + 2 
mov al, hex_buffer[1]
call hex_string_to_word  

mov hex_number3, ax


mov ax, hex_number3 
mov di, offset hex_buffer2 
call number_to_hex_string

mov ax, hex_number3  
mov al, ah
mov di, offset hex_buffer2 + 1 
call number_to_hex_string


mov dx, offset hex_buffer2 
call output_string 

int 20h

mov al, [hex_number1]
mov di, offset hex_buffer
call number_to_hex_string
 
mov dx, offset hex_buffer
call output_string
mov buffer1, al

mov al, [hex_number2]
mov di, offset hex_buffer
call number_to_hex_string

mov di, offset hex_buffer 
call output_string
mov buffer2, al  
 
call orProcedure
call xorProcedure
call andProcedure

int 20h

; -> al - string length
; -> dx - string adress
;    ax - word ->
hex_string_to_word proc
    pusha
    xor cx, cx
    
    mov cl, al             
    jcxz nan_error       
    cmp cx,4
    jg nan_error           
    xor ax,ax               
    mov si,dx              
 
    loop1:
    mov dl,[si]             
    inc si                
    call hex_string_to_digit 
    jc nan_error          
    shl ax,4               
    or al,dl
    loop loop1
    
    popa
    ret
    hex_string_to_word endp

; dl - byte string  
hex_string_to_digit proc
    
    ;comparing with '0'  (if lower => error)
    cmp dl,'0'             
    jl nan_error       
    
    ;comparing with '9'  (if higher => it is a letter)        
    cmp dl,'9'              
    jg is_a_letter
    
    ;if '0' < x < '9': make a digit from letter       
    sub dl,'0'             
    ret                   
   
    is_a_letter:  
    
    ;make uppercase
    and dl,11011111b  
    
    ;comparing with 'A' (if lower => error)      
    cmp dl,'A'             
    jl nan_error
    
    ;comparing with 'F' (if higher => error)            
    cmp dl,'F'             
    jg nan_error 
    
    ;make a digit from letter              
    sub dl,'A'-10 
              
    ret                           
hex_string_to_digit endp


;dl - перевести byte-число в строку
number_to_hex_string proc
    
    push dx
    push ax
    
    ;сохраним содержимое регистра ah в al
    mov ah, al     
    
    ;выделим старшую тертаду
    shr al, 4
     
    ;переведем число в al в hex
    call register_to_hex_string  
    
    ;запишем старшую тетраду с буфер
    mov [di], al
    inc di                         
    
    ;восстановим число и выделим младшую тетраду
    mov al, ah
    and al, 0Fh   ;0Fh = 0000 1111
     
    ;переведем число в al в hex
    call register_to_hex_string 
    
    ;запишем в буфер
    mov [di], al
    inc di

      
    pop ax
    pop dx
    ret
number_to_hex_string endp 
 
;преобразование числа в hex цифру в al
register_to_hex_string proc  
    add al, '0'
    cmp al, '9'
    jle end_of_proc
    add al, 7
    
    end_of_proc:
    ret
register_to_hex_string endp   
  
  
   
;(or) buffer1 - first hex-number, buffer2 - second hex-number  
orProcedure proc 
  xor dx, dx
  mov ah, [buffer1]
  mov al, [buffer2]
  
  or al, ah  
 

  mov di, offset hex_buffer 
  call number_to_hex_string  
                                  
  mov dx, offset hex_buffer
  call output_string
  
  ret
  orProcedure endp     

;(xor) buffer1 - first hex-number, buffer2 - second hex-number   
xorProcedure proc 
  xor dx, dx
  mov ah, [buffer1]
  mov al, [buffer2]
  
  xor al, ah  
  mov dl, ah
  
  mov di, offset hex_buffer
  call number_to_hex_string
  
  mov dx, offset hex_buffer 
  call output_string      
  
  ret
  xorProcedure endp 

;(and) buffer1 - first hex-number, buffer2 - second hex-number
andProcedure proc  
  xor dx, dx  
  mov ah, [buffer1]
  mov al, [buffer2]
  
  and al, ah     
  mov dl, ah
  
  mov di, offset hex_buffer
  call number_to_hex_string
 
  mov dx, offset hex_buffer 
  call output_string  
  
  ret
  andProcedure endp
   
;output   
   
;for string output
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
 
 
;/--------errors---------/ 
nan_error: 
    mov dx, offset nanErrorMessage
    call output_string
    int 20h                     


;/---------data----------/  
.data 

;char buffers     
hex_buffer db 4, 5 dup ('$')
hex_buffer2 db 4, 5 dup ('$')

hex_number1 db 0x00
hex_number2 db 0x00  

hex_number3 dw 0x0000 

;number buffers         
buffer1 db 0x00
buffer2 db 0x00   
andResult db 0x00
xorResult db 0x00 
orResult db  0x00  

;messages
nanErrorMessage db "Error: not a number!$"