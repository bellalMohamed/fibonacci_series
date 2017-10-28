org 100h

jmp start
;.........................................................................................................................................

program:
                call newline

start:
                jmp print_msg1          ;print the first msg
new_input:
                call take_input        ;take the number from user
next:
                call check_ZERO         ;if Zero is pressed the programe is terminated
                jmp check_suitable      ;if the input is not suitable print msg2
continue: 
                call intialization      ;set the registers wich will be used to generate the sequence 
                call get_CX             ;set the register "CX" to be the iteration register

                call sequence_generate  ; generate the sequence using only AX,BX,CX registers                       
terminate:
                hlt                     ;Terminate the program !!!
;.........................................................................................................................................

sequence_generate:

        mov dx,ax           ;move AX --> DX to be printed (the AX contain the odd index of numbers in sequence  
        call print_DX       
        call print_comma    ;print comma between the numbers

        dec cx              ;cx=cx-1 "one number is printed"

        cmp cx,0            ;check cx to end the sequence 'incase odd number is entered'
        je  program

        mov dx,bx           ;mov BX --> DX to be printed (the BX contain the even index of numbers in sequence
        call print_DX         
        call print_comma    ;rint comma between numbers

        dec cx              ;cx=cx-1 "one number is printed"

        add ax,bx           ;AX=AX+BX 
                                        ;;;;;;;;the MATH to calculate the next two numbers in sequence;;;;;;;

        add bx,ax           ;BX=BX+AX 

        cmp cx,0            ;check CX to end the sequence 'incase even number is entered'
        jne sequence_generate
                                                                                                                                          
        jmp program
 

;.........................................................................................................................................

                            ;;;;;; << print new line >> ;;;;;;;
newline:
        pusha 
        mov bh,0
        mov ah,03h
        int 10h                        ;get crusor position  

        inc dh                          ;next line
        mov dl,0                        ;col =0
        mov cx,0

        mov ah,2                        ;move crusor to next line 
        int 10h

        popa                               
        ret
;.........................................................................................................................................
verify0:
        pusha                            ;;;;; << verify that 1st input is saved in inputarr[0]>>;;;;;;;
        mov bx,offset inputarr[0]
        mov al,[bx]
        mov ah,0eh                      ;print function
        int 10h
        popa                            
        ret
;.........................................................................................................................................

verify1:
        pusha                            ;;;;; << verify that 1st input is saved in inputarr[0]>>;;;;;;;
        mov bx,offset inputarr[1]
        mov al,[bx]
        mov ah,0eh                      ;print function
        int 10h
        popa                            
        ret
;.........................................................................................................................................

check_ZERO:                                ;ceck for ZERO
        pusha
        mov bx,offset inputarr[0]
        mov bl,[bx]
        cmp bl,0
        je nextdigit
        back1:
        popa
        ret      
;.........................................................................................................................................
nextdigit:
        mov bx,offset inputarr[1]
        mov bl,[bx]
        cmp bl,0h
        je terminate
        jmp back1

;.........................................................................................................................................
check_suitable:
        mov bx,offset inputarr[0]
        mov bl,[bx]                     

        cmp bl,32h
        jg  print_msg2
     
        cmp bl,2dh
        je print_msg2
           
        cmp bl,0h
        je onedigit2
        mov bx,offset inputarr[1]
        mov bl,[bx]
        cmp bl,35h
        jg print_msg2
onedigit2:       
        mov bx,offset inputarr[1]
        mov bl,[bx]
        cmp bl,39h
        jg print_msg2

        jmp continue
;.........................................................................................................................................
print_msg2:
        mov dx,offset msg2
        mov ah,9
        int 21h
        jmp new_input
;.........................................................................................................................................

take_input:
        mov dx, offset myinput
        mov ah,0ah
        int 21h    
        jmp move_to_inputarr

move_to_inputarr: 

        mov ch,myinput[2]
        mov cl,myinput[3]

        cmp myinput[4],5dh
        je onedigit         
    cont0:        
        cmp myinput[4],0dh
        jne  here2
    cont1:    
        cmp cl,0dh
        je  onedigit   
        
        cmp cl,0
        je twodigit


    twodigit:
        mov inputarr[0],ch
        mov inputarr[1],cl
        call newline
        jmp next



    onedigit:

        cmp ch,30h
        je  terminate

        mov inputarr[1],ch
        mov inputarr[0],0             
        ;call verify0
        ;call verify1
        call newline
        jmp next


    here2:                 
        call newline
        call print_msg2

;.........................................................................................................................................
print_msg1:
        mov dx,offset msg1              ;mov the size of msg1 in DX
        mov ah,9                        ;print function
        int 21h                         ; print the msg1  note: the msg1 must end with "$"
        jmp new_input                                                                                        
;.........................................................................................................................................
intialization:
        mov ax,0
        mov bx,1
        mov dx,0
        mov cx,0
        ret
;.........................................................................................................................................
get_CX:
        push ax
        push bx
        push dx

        mov cx,0                    ;prepare CX 
        mov ax,0                    ;prepare AX
        mov bx,0                    ;prepare BX
        mov dx,0                    ;prepare DX
        cmp inputarr[0],0
        je one           
        mov bx,offset inputarr[0]   ;bx=address
        mov bl,[bx]                 ;bl=1st digit+30h
        sub bl,30h                  ;bl=1st digit
        mov al,bl                   ;al=1st digit
        mov dl,10                   ;dl=10
        mul dl                      ;al=1st*10
        mov cx,ax
one:                                ;CH=0,CL=1st*10                                            
        mov bx,offset inputarr[1]   ;bx=address
        mov bl,[bx]                 ;BL=2nd digit+30h
        sub bl,30h                  ;BL=2nd digit
        add al,bl                   ;AL=1st*10+2nd 
                                    ;AH=0
        mov cx,ax                   ;CH=AH=0, CL=AL=1st*10+2nd
            
        pop dx
        pop bx
        pop ax                                             
        ret
;........................................................................................................................................
;Declaring Variables


msg1 db "Please enter the number of elements in the sequence: $"
msg2 db "Please enter suitable number in the range of [1-25]: $"
inputarr db '0','0'         ;inner input to generate sequence                     
myinput db 10,?,10 dup (']')  ;var to take the input from user and save it in inputarr
;.........................................................................................................................................                                  

print_DX proc           ;this procedure is used to convert the number in sequence to ASCII charachter 

        pusha          
;..............................................
digit1:
        mov bx,2710h    ; bx=10000
    
        mov ax,dx       ;AX=number
        mov dx,0        ;prepare dx as reminder  


        div bx          ;AX=number/bx
                        ;AX=digit
                        ;DX=other digits
        cmp ax,0
        je  digit2
        push dx         ;Store original value of DX
        add al,30h      ;Covert to ascii
        mov dl,al       ;Prepare digit to print
        mov ah,2        ;Print function
        int 21h
        pop dx          ;Restore the value of DX
;..............................................
digit2:
        mov bx,3e8h     ;bx=1000
    
        mov ax,dx       ;AX=number
        mov dx,0        ;Prepare dx as reminder  


        div bx          ;AX=number/bx
                        ;AX=digit
                        ;DX=other digits
        cmp ax,0
        je  digit3

        push dx         ;Store original value of DX
        add al,30h      ;Covert to ascii
        mov dl,al       ;Prepare digit to print
        mov ah,2        ;Print function
        int 21h
        pop dx          ;Restore the value of DX
;..............................................
digit3:
        mov bx,64h      ;bx=100
     
        cmp dx,0
        je digit4

        mov ax,dx       ;AX=number
        mov dx,0        ;prepare dx as reminder  


        div bx          ;AX=number/bx
                        ;AX=digit
                        ;DX=other digits

        cmp ax,0
        je digit4

        push dx         ;store original value of DX
        add al,30h      ;covert to ascii
        mov dl,al       ;prepare digit to print
        mov ah,2        ;print function
        int 21h
        pop dx          ;restore the value of DX
;..............................................
digit4:
        mov bx,0ah      ;bx=10
 

        mov ax,dx       ;AX=
        mov dx,0        ;prepare dx as reminder  


        div bx          ;AX=number/bx
                        ;AX=digit
                        ;DX=other digits

        cmp ax,0
        je digit5

        push dx         ;store original value of DX
        add al,30h      ;covert to ascii
        mov dl,al       ;prepare digit to print
        mov ah,2        ;print function
        int 21h
        pop dx          ;restore the value of DX
;..............................................
digit5:     
        mov bx,01h      ;bx=1
 

        mov ax,dx       ;AX=number
        mov dx,0        ;prepare dx as reminder  


        div bx          ;AX=number/bx
                        ;AX=digit
                        ;DX=other digits

        cmp ax,0
        je  zero

        push dx         ;store original value of DX
        add al,30h      ;covert to ascii
        mov dl,al       ;prepare digit to print
        mov ah,2        ;print function
        int 21h
        pop dx          ;restore the value of DX

jmp done
;..............................................
zero:

        mov al,'0'
        mov ah,0eh
        int 10h
;..............................................
done:
        popa
        ret
        endp
;.........................................................................................................................................
print_comma:
        pusha
        mov al,','
        mov ah,0eh
        int 10h
        popa   
        ret 
;.........................................................................................................................................
