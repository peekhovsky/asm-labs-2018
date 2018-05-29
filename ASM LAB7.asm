;Написать программу, запускающую другую программу N раз (0 < N < 256).
;Имя запускаемой программы и ее параметры передаются в командной
;строке

.model tiny
.code 
org 100h
 
main:
 
call  getConsoleParameters

mov dx, offset program_name
call output_string

mov dx, offset program_parameters
call output_string        

mov dx, offset iterations_string
call output_string

call string_to_number  

call change_memory_size

xor cx, cx
mov cl, iterations

iteration:
    call run_program
loop iteration

int 20h                     

;/-------------memory---------------/ 
change_memory_size proc      
    ;stack pointer to the end of memory block
    ;100h + program_size + 200h
    mov sp, program_size + 300h 
    mov ah, 4Ah
    stack_shift = program_size + 300h    
    mov bx, stack_shift shr 4 + 1 
    int 21h
    jb change_memory_size_error
   
    mov ax, cs
    ;command line segment  
    mov word ptr EPB+4,   ax 
    ;first FCB segment
    mov word ptr EPB+8,   ax
    ;second FCB segment
    mov word ptr EPB+0Ch, ax   
    ret
change_memory_size endp    
;/-----------------------------------/ 
   
;/---------------run-----------------/ 
run_program proc 
    mov ah, 4Bh
    mov al, 00h
    mov dx, offset program_name
    mov bx, offset EPB 
    int 21h
    jc run_program_error 
    
    ret
run_program endp    
;/-----------------------------------/ 

;/-------------console---------------/
getConsoleParameters proc
    pusha
    push si
    push di
    
    mov si, 81h
    mov di, 0
    
    skip_space_1:
        mov al, es[si]
        cmp al, 0dh 
        je error_cannot_read_all_parameters
        cmp al, 20h
        jne read_program_name
        inc si 
        jmp skip_space_1
    
    read_program_name:
        mov program_name[di], al
        inc si
        mov al, es[si]
        cmp al, 20h
        je skip_space_2
        cmp al, 0dh
        je error_cannot_read_all_parameters
        inc di  
        jmp read_program_name
          
     skip_space_2:  
        mov di, 0
        mov al, es[si]
        cmp al, 0dh 
        je error_cannot_read_all_parameters
        cmp al, 20h
        jne read_program_parameters
        inc si 
        jmp skip_space_2
    
    read_program_parameters:
        mov program_parameters[di], al
        inc si
        mov al, es[si]
        cmp al, 20h
        je skip_space_3
        cmp al, 0dh
        je error_cannot_read_all_parameters
        inc di  
        jmp read_program_parameters
    
    skip_space_3:  
        mov di, 0
        mov al, es[si]
        cmp al, 0dh 
        je error_cannot_read_all_parameters
        cmp al, 20h
        jne read_iterations
        inc si 
        jmp skip_space_3
    
    read_iterations:
        mov iterations_string[di], al
        inc si
        mov al, es[si]
        cmp al, 20h
        je end_read_parameters
        cmp al, 0dh
        je end_read_parameters
        inc di  
        jmp read_iterations    
        
    end_read_parameters:
    inc di
    cmp di, 3
    ja error_overflow
    mov iterations_string_size, di
    pop di
    pop si
    popa
    ret 
getConsoleParameters endp 
;/--------------------------------------/

;/---------------output-----------------/
;dx - pointer to start of your string
output_string proc    
    push ax        
     
    mov AH, 09h
    int 21h  
    call start_new_line  
  
    pop ax
    ret              
output_string endp    

output_string_without_new_line proc    
    push ax        
     
    mov AH, 09h
    int 21h  
    ;call startNewLine  
  
    pop ax
    ret              
output_string_without_new_line endp         
       
;input string in memory consist of: [0] - max_size, [1] - real_size, [2-201] - string   
;dx - adress in memory with buffer for new string                        
input_string proc  
    push ax       
                     
    mov AH, 0Ah
    int 21h          
    call start_new_line  
    
    pop ax
    ret      
input_string endp   
                             
;procedure for new line                  
start_new_line proc    
    pusha  
    
    mov DL, 0Dh
    mov Ah, 02h
    int 21h 
    
    mov DL, 0Ah
    mov Ah, 02h
    int 21h
    
    popa
    ret    
start_new_line endp                 
;/--------------------------------------/

;/------------translations--------------/  
string_to_number proc 
    pusha
    push si
    
        mov cx, iterations_string_size
        xor ax, ax 
        xor bx, bx 
        xor dx, dx 
        mov si, 0 
        
        get_digit:       
            mov dl, iterations_string[si]
            sub dl, '0'
            cmp dl, 9
            ja error_nan
                        
            mov bl, 10    
            mul bl
            
            cmp ah, 0
            jne error_overflow
 
            add al, dl                        
            inc si
                
        loop get_digit
    
    mov iterations, al     
    
    pop si        
    popa
    ret
string_to_number endp
;/--------------------------------------/ 

;/----------------errors----------------/
error_cannot_read_all_parameters:
    mov dx, offset errorCannotReadAllParametersMessage
    call output_string   
    int 20h
error_overflow:
    mov dx, offset errorOverflowMessage 
    call output_string  
    int 20h 
error_nan:
    mov dx, offset errorNanMessage 
    call output_string  
    int 20h
     
change_memory_size_error:
    cmp ax, 07
    je error_memory_manager_blocks_are_destroyed 
    cmp ax, 08
    je error_too_few_memory
    cmp ax, 09
    je error_invalid_adress_in_es 
    
    mov dx, offset errorChangeMemorySize
    call output_string  
    int 20h 
     
error_memory_manager_blocks_are_destroyed:
    mov dx, offset errorMemoryManagerBlocksAreDestroyed 
    call output_string  
    int 20h 
       
error_too_few_memory:  
    mov dx, offset errorTooFewMemory 
    call output_string  
    int 20h
    
error_invalid_adress_in_es:
    mov dx, offset errorInvalidAdressInEs 
    call output_string  
    int 20h  
    
run_program_error:
    cmp ax, 02h
    je error_cannot_find_file
    cmp ax, 05h
    je error_cannot_access_file
    cmp ax, 08h
    je error_too_few_memory  
    cmp ax, 0Ah
    je error_bad_enviroment
    cmp ax, 0Bh
    je error_invalid_format

error_cannot_find_file:        
    mov dx, offset errorCannotFindFile 
    call output_string  
    int 20h 
    
error_cannot_access_file:
    mov dx, offset errorCannotAccessFile 
    call output_string  
    int 20h
      
error_bad_enviroment:     
    mov dx, offset errorBadEnviroment 
    call output_string  
    int 20h 

error_invalid_format:
    mov dx, offset errorInvalidFormat 
    call output_string  
    int 20h       
;/--------------------------------------/

.data  

;parameters
program_name db 128 dup ('$')
program_parameters db 128 dup ('$') 
iterations_string db 64 dup ('$')
iterations_string_size dw 0 
iterations db 0 

;errors
errorCannotReadAllParametersMessage db "Error: too few parameters!$"
errorOverflowMessage db "Error: too big number!$"  
errorNanMessage db "Error: not a number!$"  
errorChangeMemorySize db "Error: changing size of memory!$"
errorMemoryManagerBlocksAreDestroyed db "Error: memory manager blocks are destroyed!$"
errorTooFewMemory db "Error: too few memory!$"
errorInvalidAdressInEs db "Error: invalid adress in es!$"
errorCannotFindFile db "Error: cannot find file path!$"  
errorCannotAccessFile db "Error: cannot access file!$"  
errorBadEnviroment db "Error: bad enviroment!$"  
errorInvalidFormat db "Error: invalid format!$"    

;EPB
EPB             dw 0000h
                dw offset program_parameters, 0
                dw 005Ch, 0, 006Ch, 0

program_size equ $ - main 
end main