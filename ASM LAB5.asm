.model tiny 

.code
org 100h

mov si, 81h
mov di, 2

skip_space:
    mov al, es[si]
    cmp al, 0dh
    je file_not_exist_error
    cmp al, 20h
    jne read_file_name
    inc si 
    jmp skip_space
    
    read_file_name:
        mov string[di], al
        inc si
        mov al, es[si]
        cmp al, 20h
        je _open_file
        cmp al, 0dh
        je _open_file
        inc di  
        jmp read_file_name

lea dx, messageOpenFile
call outputString      

_open_file:   
 
mov ax, di
dec ax
dec ax 
mov size_of_string, ax
                                   
call open_file
mov file_id, ax             ;get file id from ax 

call create_new_file

;output hello-message 
;mov dx, offset enterMessage
;call outputString     
;input string
mov dx, offset string + 2
call outputString     
    
    ;ax - size of buffer   
    xor dx, dx         
    ;mov dl, string      
    ;mov size_of_string, dx
       
    ;translate a string to a word
    call string_to_word 

    lea dx, messageParsing
    call outputString   
    
reading: 
    mov start_buffer_flag, 0
    
    call read_file           ;ax <- кол-во считанных байт 
    
    mov ax, read_bytes   
    cmp ax, 0000h            ;CBh == 200 (size of buffer)  
    je ending                ;if (read_bytes < size_of_string) end 
    
    mov dx, size_of_word
    cmp ax, dx
    jb tail_writting  
    
    ;заносим в si и di указатели на начало строк
    mov si, offset file_buffer
    mov di, offset word_
                          
    sub al, dl  ;находим необходимый размер итераций для прохождения цикла loop1
    
    xor cx, cx      
    mov cl, al  ;заносим в cx кол-во итераций для цикла loop1      
    inc cx
    
    word_finding_loop:
        pusha  
        
        cmp start_buffer_flag, 0
        je compare_str_ 
                
        cmp ds[si-1], ' '
        je compare_str_ 
        
        cmp ds[si-1], '$'
        je compare_str_
        
        cmp ds[si-1], 0Dh
        je compare_str_   
        
        cmp ds[si-1], 0Dh
        je compare_str_
        
        cmp ds[si-1], 0Ah
        je compare_str_
        
        cmp ds[si-1], 09h
        je compare_str_
       
        cmp ds[si-1], 0h
        je compare_str_
       
        jmp continue_
         
        compare_str_:        
               
        ;сравниваем строки     
        xor cx, cx 
        mov cx, dx          ;заносим в cx кол-во итераций
        repe cmpsb          ;повторяем пока равны
        jnz continue_       ;если равны goto find
        
         cmp ds[si], ' '
        je find 
        
        cmp ds[si], '$'
        je find
        
        cmp ds[si], 0Dh
        je find
        
        cmp ds[si], 0Ah
        je find
        
        cmp ds[si], 09h
        je find
       
        cmp ds[si], 0h
        je find
         
        continue_:
        
        popa                ;выносим из стека нужные регистры   
        
        mov start_buffer_flag, 0
                         
        inc si                      ;переходим на следующий символ в новой строке                                      
        mov di, offset word_        ;сбрасываем счетчик                                  
    loop word_finding_loop              
  
    mov ax, read_bytes
    call write_whole_buffer
   
    ;mov bx, processed_bytes 
    ;mov ax, read_bytes
    ;add bx, ax
    ;mov processed_bytes, bx 
    
    mov ax, read_bytes  
    ;add ax, size_of_word 
    call add_to_processed_bytes_dd   
 
    jmp reading          
                  
   ;if we find substring 
   ;si - после выполнения цикла указывает на конец подстроки в строке
   find:
       
       lea dx, messageDot
       call outputString 
        
       ;mov dx, offset foundMessage
       ;call outputString                                                      
       ;заносим в di адрес начала первой подстроки                              
       mov di, offset file_buffer   
       ;заносив в cx адрес конца подстроки в строке
       mov cx, si              
       ;находим размер первой части строки с подстрокой (от начала первой строки до конца второй подстроки в первой)
       sub cx, offset file_buffer  
       
       xor ax, ax
       mov ax, size_of_word
              
       ;заносим в al размер второй подстроки            
       ;mov ax, size_of_string
       ;находим размер первой части строки без подстроки 
       sub cx, ax 
       
       write_to_buffer_with_sub:
       
       mov ax, cx
       
       call write_whole_buffer 
       
       ;mov bx, processed_bytes
       ;add bx, ax
       ;mov ax, size_of_word
       ;add bx, ax
       ;mov processed_bytes, bx  
       
       ;dec ax 
       call add_to_processed_bytes_dd
      
       mov ax, size_of_word
       call add_to_processed_bytes_dd
       
       jmp reading                            ;if (read_bytes < size_of_string) end
   
       tail_writting:
       mov ax, read_bytes
       call write_whole_buffer 
       jmp ending  
                
ending:
    
lea dx, messageCloseFile
call outputString 



mov bx, file_id
call close_file  


mov bx, new_file_id
call close_file  

;delete file
mov ah, 41h    
mov dx, offset file_name
int 21h 
cmp cx, 0000h 
jne io_error 
 
  
;rename file
mov ah, 56h
lea dx, new_file_name
lea di, file_name    
int 21h 
cmp cx, 0000h 
jne io_error 


int 20h
 
 
;/-------------------file------------------/   
;opens file
;ax <- file_id 
open_file proc
    push dx

    mov ax, 3D02h  ;3D - open file, 02 - for reading and recording  
    lea dx, file_name  
    int 21h       
    jc io_error  ;if (cf != 0) io_error 

    pop dx
    ret
open_file endp

;reads next 200 bytes of file  
;file_id -> file_id
;file_buffer <- updating 
read_file proc 
    push bx
    push cx
    push dx
    
    call move_pointer_by_processed_bytes
    
    mov bx, file_id              ; a part of file to buffer  
    mov ah, 3Fh                  ;           
    mov cx, 00C8h                ; 00C8h = 200 bytes         
    mov dx, offset file_buffer   ; 
    int 21h   
    
    mov read_bytes, ax
    
    pop dx
    pop cx
    pop bx
    ret
read_file endp

move_pointer_by_processed_bytes proc 
    pusha
      
    mov bx, file_id
    mov al, 00h  
    xor cx, cx                      ;the beginning of file  
    mov dx, processed_bytes_l         ; - 
    mov cx, processed_bytes_h         ; - amount of bytes
    mov ah, 42h 
   
    int 21h
    jc io_error  ;if (cx != 0) io_error 
     
    popa    
    ret
move_pointer_by_processed_bytes endp

;closes file
;file_id -> file to close
close_file proc
    pusha
    
    mov bx, file_id ;
    xor ax, ax      ; 
    mov ah, 3Eh     ; close file
    int 21h         ; 
    
    popa
    ret
close_file endp   

;   -> new_file_name 
;new_file_id <- file_id
create_new_file proc
    pusha
        mov ah, 3Ch
        mov cx, 00000000h 
        lea dx, new_file_name
        int 21h
        mov new_file_id, ax
        jc io_error  ;if (cx != 0) io_error       
    popa
    ret
create_new_file endp   

;ax -> bytes to write
write_whole_buffer proc
    pusha
        lea dx, file_buffer      
        mov bx, new_file_id
        mov cx, ax
        mov ah, 40h   
        int 21h
        jc io_error  ;if (cx != 0) io_error    
    popa
    ret  
write_whole_buffer endp    

    
string_to_word proc
   pusha
       lea si, string + 2
       lea di, word_
       
       xor dx, dx  
       
       mov cx, size_of_string
       inc cx
                        
       string_to_word_loop: 
            cmp string:[si], 0Dh     ;new line character
            je passing    
            
            cmp string:[si], 0Ah    ;return character
            je passing
            
            cmp string:[si], ' '     ;space character
            je passing  
            
            cmp string:[si], 09h       ;tab character     
            je passing 
            
            cmp string:[si], 00h       ;tab character     
            je passing
             
            mov ah, string:[si]
            mov word_:[di], ah
            
            inc dx
            inc di 
            
            cmp dx, 32h                 ;32h == 50 (max size of word)
            ja max_size_of_word_error   ;if (dx > 50) error
            
            passing:   
            inc si 
                    
       loop string_to_word_loop
       
       mov size_of_word, dx
        
   popa
   ret  
string_to_word endp 

;ax -> num that you add to dd processed_bytes_dd
add_to_processed_bytes_dd proc 
    pusha
        mov dx, processed_bytes_l
        mov bx, processed_bytes_h 
        
        add dx, ax
        jae end_add_to_processed_bytes_dd
        
        inc bx 
               
        end_add_to_processed_bytes_dd:    
        
        mov processed_bytes_l, dx
        mov processed_bytes_h, bx
    popa
    ret
add_to_processed_bytes_dd endp

;/----------------errors-------------------/   
io_error: 
    cmp ax, 0003h
    je cannot_find_path
    cmp ax, 0004h
    je too_many_opened_files
    cmp ax, 0005h
    je cannot_access
    cmp ax, 0006h
    je invalid_identifier
     
    mov dx, offset IOError
    call outputString   
    int 20h
     
    cannot_find_path: 
    mov dx, offset pathError
    call outputString   
    int 20h 
    
    too_many_opened_files:   
    mov dx, offset openedFilesError
    call outputString   
    int 20h  
    
    cannot_access:
    mov dx, offset accessError
    call outputString   
    int 20h    
    
    invalid_identifier:
    mov dx, offset invalidIdentifierError
    call outputString   
    int 20h    
    
    max_size_of_word_error:
    mov dx, offset maxSizeOfWordError  
    call outputString
    int 20h  
    
    file_not_exist_error:
     mov dx, offset  fileNotExistError  
    call outputString
    int 20h    
    call outputString
    int 20h  
;/--------------procedures-----------------/      

;for string output
;dx - pointer to start of your string
;string must have '$' at the end of itself 
outputString proc    
    push ax        
     
    mov AH, 09h
    int 21h  
    call startNewLine  
  
    pop ax
    ret              
outputString endp
       
       
;input string in memory consist of: [0] - max_size, [1] - real_size, [2-201] - string   
;dx - adress in memory with buffer for new string                        
inputString proc  
    push ax       
                     
    mov AH, 0Ah
    int 21h          
    call startNewLine  
    
    pop ax
    ret      
inputString endp   
               
               
;procedure for new line                  
startNewLine proc    
    pusha  
    
    mov DL, 0Dh
    mov Ah, 02h
    int 21h 
    
    mov DL, 0Ah
    mov Ah, 02h
    int 21h
    
    popa
    ret    
startNewLine endp                 

 
;to move data to a buffer from another buffer             
;si - pointer to the start of source string
;di - pointer to the start of buffer string 
copyData proc  
    push ax  
      
    cmp cx, 0000h
    jz endCopyData   
    
    loop2:  
        mov ax, [si]
        mov [di], ax 
        inc si
        inc di
        loop loop2
   
    endCopyData:        
    pop ax  
    ret
    copyData endp    



.data 

;file                       
file_name db "file.txt", 0    
file_id dw 0000h    

new_file_name db "newfile.txt", 0    
new_file_id dw 0000h

read_bytes dw 0000h
processed_bytes_l dw 0000h 
processed_bytes_h dw 0000h 
size_of_string dw 0000h  
size_of_word dw 0000h  

;error messages
pathError        db "IO Error: cannot fild path!$" 
openedFilesError db "IO Error: too many opened files!$"     
accessError      db "IO Error: access error!$"       
IOError          db "IO Error!$" 
maxSizeOfWordError db "Error: word that you have entered is bigger than max size of word!$"
invalidIdentifierError db "IO Error: invalid identifier$"
;messages
enterMessage         db "Enter string: $"  
foundMessage         db "Found!$"
notFoundMessage      db "Not found!$" 
fileNotExistError    db "Error: empty command line!$"
;buffers                `
 
 
;string db 0, 0, "Welle$" 
string db 50, 52 dup ('$')   
word_ db 50, 52 dup ('$')
file_buffer db 202 dup ('$')  

start_buffer_flag db 0      

messageOpenFile db "Opening file...$"
messageParsing db "Parsing...$"
messageCloseFile db "Saving and closing$"   
messageDot db ".$"