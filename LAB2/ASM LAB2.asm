.model tiny
.code 
    ;set location counter to 100h
    org  100h

    ;����������� ������ ������� �� [0] - max_size, [1] - real_size, [2-201] - string

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

               
    ;������� � ax � dx �������� ������� �����
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
  
    ;������� � si � di ��������� �� ������ �����
    mov si, offset string1 + 2
    mov di, offset string2 + 2  
                   
    ;cld       
    
    sub al, dl  ;������� ����������� ������ �������� ��� ����������� ����� loop1
    
    xor cx, cx      
    mov cl, al  ;������� � cx ���-�� �������� ��� ����� loop1      
    inc cx
  
loop1:
   
    ;�������� � ���� ��� ���������� ������ 
    pusha
        
    ;���������� ������     
    xor cx, cx
    mov cx, dx ;������� � cx ���-�� ��������
    repe cmpsb ;��������� ���� �����
    jz find    ;���� ����� goto find
           
    popa       ;������� �� ����� ������ ��������   
                         
    inc si                      ;��������� �� ��������� ������ � ����� ������                                      
    mov di, offset string2 + 2  ;���������� �������    
                        
loop loop1
      
   ;substirng was not found
   mov dx, offset notFoundMessage
   call outputString
   int 20h
   
   ;if we find substring 
   ;si - ����� ���������� ����� ��������� �� ����� ��������� � ������
   find:                                                    
       mov dx, offset foundMessage
       call outputString 
        
       ;������� � di ����� ������ ������ ���������                              
       mov di, offset string1 + 2    
       ;������� � cx ����� ����� ��������� � ������
       mov cx, si              
       ;������� ������ ������ ����� ������ � ���������� (�� ������ ������ ������ �� ����� ������ ��������� � ������)
       sub cx, offset string1 + 2  
        
       ;������� � al ������ ������ ���������            
       xor ax, ax 
       mov al, string2[1] 
        
       ;������� ������ ������ ����� ������ ��� ��������� 
       sub cx, ax 
  
       ;co������� si (��� ����������� - ��� ��������� �� ����� ��������� � ������)
       push si
            
       ;������� � di ����� ������ ����� ���������, � � si ����� ������ ������       
       mov di, offset resultString + 1 
       mov si, offset string1 + 2
                                               
       ;� ����� ������� � ����� ��������� ����������� �������� �� ������ ���������
       ;������������ ��� �������� � ���������� �������                                      
       call copyData 
        
       ;������� � cx ������ ������� ������ 
       xor cx, cx  
       mov cl, string3[1]
       ;������� � si ����� ������ ������� ������
       mov si, offset string3 + 2       
        
       ;� ����� ������� � ����� ��������� ����������� �������� �� ������� ���������   
       ;������������ ��� �������� � ���������� �������  
       ;����� � di �����������, ������� ��������� ������������ � ����� ��� �����������
       ;inc di  
       call copyData
         
       pop si
        
       ;������� � cx ������ ������ ���������  
       xor cx, cx
       mov cl, string1[1]  
       ;������� � dx ������ ������ ��������� ��� 3 �����
       mov dx, si
       sub dx, offset string1 + 2  
       
       ;������� ������ ������� �����
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