.model tiny
.code 
    ;set location counter to 100h
    org  100h

    ;заполненная строка состоит из [0] - max_size, [1] - real_size, [2-201] - string

    ;loading @data
    mov AX, @data  
    mov DS, AX      
                  
                  
;/-----------input------------/
    
    ;output enter-message 
    mov dx, offset enter1Message
    call outputString     
    ;input string
    mov dx, offset string1 
    call inputString       
   
    mov dx, offset enter2Message 
    call outputString            
    mov dx, offset string2
    call inputString 
   
     mov dx, offset enter3Message                
    call outputString                 
    mov dx, offset string3
    call inputString      
   
                    
;/-----------checks-----------/  
              
    ;ax = 0, dx = 0
    xor ax, ax
    xor dx, dx  

               
    ;заносим в ax и dx реальные размеры строк
    mov al, string1[1]
    mov dl, string2[1]   
   
   
    ;check Str1 > Str2
    cmp al, dl 
    jb size_error  
     
    ;check Str1 = 0  
    cmp al, 00h
    je null_error  
     
    ;check Str2 = 0  
    cmp dl, 00h
    je null_error  
    
   
    ;check string1 + strting3 - string2 > 200  
    push ax
   
    sub al, dl           ;string1 - string2
    add al, string3[1]   ;+ string3
    cmp al, 200          ;compare with 200 (max size) 
    jnb overflow_error   ;if >200 jump to error
  
    pop ax  
  
   
;/-----------finding substring-----------/  
  
    ;заносим в si и di указатели на начало строк
    mov si, offset string1 + 2
    mov di, offset string2 + 2  
                   
    ;cld       
    
    sub al, dl  ;находим необходимый размер итераций для прохождения цикла loop1
    
    xor cx, cx      
    mov cl, al  ;заносим в cx кол-во итераций для цикла loop1      
    inc cx
  
loop1:
   
    ;регистры в стек для сохранения данных 
    pusha
        
    ;сравниваем строки     
    xor cx, cx
    mov cx, dx ;заносим в cx кол-во итераций
    repe cmpsb ;повторяем пока равны
    jz find    ;если равны goto find
           
    popa       ;выносим из стека нужные регистры   
                         
    inc si                      ;переходим на следующий символ в новой строке                                      
    mov di, offset string2 + 2  ;сбрасываем счетчик    
                        
loop loop1
      
   ;substirng was not found
   mov dx, offset notFoundMessage
   call outputString
   int 20h
   
   ;if we find substring 
   ;si - после выполнения цикла указывает на конец подстроки в строке
   find:                                                    
       mov dx, offset foundMessage
       call outputString 
        
       ;заносим в di адрес начала первой подстроки                              
       mov di, offset string1 + 2    
       ;заносив в cx адрес конца подстроки в строке
       mov cx, si              
       ;находим размер первой части строки с подстрокой (от начала первой строки до конца второй подстроки в первой)
       sub cx, offset string1 + 2  
        
       ;заносим в al размер второй подстроки            
       xor ax, ax 
       mov al, string2[1] 
        
       ;находим размер первой части строки без подстроки 
       sub cx, ax 
  
       ;coхраняем si (еще понадобится - это указатель на конец подстроки в строке)
       push si
            
       ;заносим в di адрес начала новой подстроки, а в si адрес начала первой       
       mov di, offset resultString + 1 
       mov si, offset string1 + 2
                                               
       ;в цикле заносим в новую подстроку посимвольно элементы из первой подстроки
       ;инкременируя для перехода к следующему символу                                      
       call copyData 
        
       ;заносим в cx размер третьей строки 
       xor cx, cx  
       mov cl, string3[1]
       ;заносим в si адрес начала третьей строки
       mov si, offset string3 + 2       
        
       ;в цикле заносим в новую подстроку посимвольно элементы из третьей подстроки   
       ;инкременируя для перехода к следующему символу  
       ;адрес в di сохраняется, поэтому подстрока записывается в конец уже записанного
       ;inc di  
       call copyData
         
       pop si
        
       ;заносим в cx размер первой подстроки  
       xor cx, cx
       mov cl, string1[1]  
       ;заносим в dx размер первой подстроки без 3 части
       mov dx, si
       sub dx, offset string1 + 2  
       
       ;находим размер третьей части
       sub cx, dx
       
       call copyData
       
       call cutting
       
       ;output result      
       mov dx, offset resultString + 1
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
 
 
;to output max 200 characters in result
cutting proc
    pusha
    
    mov resultString[202],'$' 
     
    popa
    ret
cutting endp              
 
 
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

                       
                       
;/----------errors-----------/ 
   
overflow_error:
    mov dx, offset overflowErrorMessage
    call outputString   
    int 20h
    
size_error:
    mov dx, offset sizeErrorMessage
    call outputString
    int 20h 
        
null_error:
    mov dx, offset nullErrorMessage
    call outputString
    int 20h        
        
        
        
  
;/-----------data------------/ 
                               
.data    

;buffers
string1      db 200, 202 dup ('$')   
string2      db 200, 202 dup ('$')
string3      db 200, 202 dup ('$')        
resultString db 200, 202 dup ('$') 

;messages
enter1Message        db "Enter string 1: $"    
enter2Message        db "Enter string 2: $"  
enter3Message        db "Enter string 3: $"     
foundMessage         db "Found!$"
notFoundMessage      db "Not found!$"              
sizeErrorMessage     db "Error: string1 < string2$"  
nullErrorMessage     db "Error: String 1 or String2 == null$"
overflowErrorMessage db "Overflow error!$"