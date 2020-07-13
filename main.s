.section .rodata

    #Magic numbers of each file
    sb_pbm: .string "0x5031"
    sb_rle: .string "0x524C4549"
    
    #Elements to be referenced in stdout file
    mnu: .asciz "\nMenu:\n1. Compress PBM image\n2. Decompress RLE image\n3. Exit\n\nSo your choice is: "
    req: .asciz "Input file name with extension: "
    req2: .asciz "Output file name: "
    err1: .asciz "Invalid answer. You can try again: "
    err2: .asciz "File couldn't be opened"
    err3: .asciz "%s: In this project, the PBM image should start at 0x5031\n"
    err4: .asciz "%s: In this project, the RLE image should start at 0x524C4549\n"
    err5: .asciz "%s: In regards to this project, that RLE format file is invalid\n"
    ag: .asciz "Done.\nWould you want to operate with another file? (y/n): "
    y: .asciz "y"
    n: .asciz "n"
    hzero: .asciz "0x"
    
    #Header files parameters, printf formats, macros and extensions
    frle: .asciz ".rle"
    fpbm: .asciz ".pbm"
    fmt1: .asciz "%d"
    fmt2: .asciz "%s"
    fmt3: .asciz "06%d"
    fmtx: .asciz ""
    fmode1: .asciz "rb"
    fmode2: .asciz "w"
    hxpadd1: .asciz "%04X%s"
    hxpadd2: .asciz "%04X"
    succ: .asciz "EXIT_SUCCESS"
    fail: .asciz "EXIT_FAILURE"
    null: .asciz "NULL"

.section .data

    #Pitch image
    pitch: .int 0

    #Multiplier
    multi: .int 1

.section .bss
    
    #Reserved memory areas (big lengths in case of underflow issues)
    .comm opt, 10
    .comm fptr, 10
    .comm fname, 10
    .comm fname2, 10
    .lcomm fncpy, 10
    .lcomm cpy1, 10
    .lcomm cpy2, 10
    .lcomm cpy3, 10
    .lcomm cpy4, 10
    .lcomm buff1, 1000
    .lcomm buff2, 1000
    .lcomm buff3, 1000
    .lcomm rle_pixels, 100000000
    .lcomm pbm_pixels, 100000000
    
.section .text
.globl _main

_main:

    call ___main
    
    choice:
       	
        pushl $sb_rle
        pushl $cpy1	  #Copying RLE file
        call _strcpy      #magic number
        addl $8, %esp

        pushl $sb_pbm
        pushl $cpy2	  #Copying PBM file
        call _strcpy      #magic number
        addl $8, %esp

        pushl $mnu
        call _printf      #Invoking menu
        addl $4, %esp
    	
        pushl $opt          
        pushl $fmt1
        call _scanf       #Reading the user choice
        addl $8, %esp       
        movl opt, %eax
        
        movl $1, %ebx
        cmpl %ebx, %eax
        jl ipt_err1       #Checking out
        movl $3, %ebx     #inputs
        cmpl %ebx, %eax
        jg ipt_err1

        cmpl $1, %eax
        je compressing
        cmpl $2, %eax     #Determining
        je decompressing  #the program focus
        cmpl $3, %eax
        je finish
    
    whatnow:
    
        pushl $ag
        pushl $fmt2
        call _printf
        addl $8, %esp
        
        pushl $opt
        pushl $fmt2       #Asking user
        call _scanf       #for another decision 
        addl $8, %esp
       
        pushl $y
        pushl $opt
        call _strcmp
        addl $8, %esp
        cmpl $0, %eax
        jne finish
        
        jmp choice
        
    compressing:

    	movl $0, pitch    #Restarting pitch
    
        pushl $req
        call _printf
        addl $4, %esp     #Saving
        pushl $fname      #file name
        pushl $fmt2       
        call _scanf  
        addl $8, %esp

        pushl $req2
        call _printf
        addl $4, %esp     #Saving output
        pushl $fname2     #file name
        pushl $fmt2       
        call _scanf  
        addl $8, %esp 
        
        pushl $fmode1        
        pushl $fname     
        call _fopen       #Getting
        addl $8, %esp     #file pointer
        cmpb $0, %al
        je ipt_err2
        movl %eax, fptr

        pushl fptr
        pushl $3
        pushl $2          #Reading magic
        pushl $buff1      #number
        call _fread         
        addl $16, %esp
     
        pushl $buff1     
        pushl $cpy2  
        call _strcmp      #Validating PBM file magic number
        addl $8, %esp     
        cmpl $0, %eax
        jne ipt_err3

        pushl fptr
        pushl $4
        pushl $2          #Getting image
        pushl $buff1      #width and height
        call _fread
        addl $16, %esp

        pushl $buff1
        pushl $cpy1       #Appending width and height
        call _strcat      #to rle file preface
        addl $8, %esp

        pushl $10000
        pushl $0            
        pushl $buff1      #Clearing buff1
        call _memset
        addl $12, %esp

        pushl fptr
        pushl $1
        pushl $2          #Reading first
        pushl $buff1      #two pixels
        call _fread       
        addl $16, %esp    

        pushl $buff1
        pushl $cpy3 	  #Copying those last two pixels
        call _strcpy      
        addl $8, %esp
        
        movl $1, %ebx     #Initializing counter
    
    	pwhile:

    		pushl $10000
        	pushl $0            
        	pushl $buff1      #Clearing buff1
        	call _memset
        	addl $12, %esp

        	pushl fptr
        	pushl $1
        	pushl $2            
        	pushl $buff1          
        	call _fread       #Reading 2 bytes from file
        	addl $16, %esp    #until it is no longer applicable
        	cmpl $1, %eax
        	jne lastb
            
        	pushl $buff1
        	pushl $cpy3        
        	call _strcmp      #Comparing copy of last byte
        	addl $8, %esp     #with actual byte
        	cmpb $0, %al
        	jne diff
            
        	pushl $buff1
        	pushl $cpy3	  #Copying actual byte
        	call _strcpy
        	addl $8, %esp
            
        	
        	addl $1, %ebx
        	jmp pwhile
            
        	diff:             #If there was some difference      
            
            	pushl $cpy3
            	pushl %ebx
            	pushl $hxpadd1
            	pushl $buff2         #Saving similar pixels
            	call _sprintf
            	addl $16, %esp
            	addl $3, pitch
                
            	pushl $buff2
            	pushl $rle_pixels    #Saving pixels
            	call _strcat          
            	addl $8, %esp
                
            	pushl $buff1
            	pushl $cpy3          #Saving last byte
            	call _strcpy
            	addl $8, %esp
                
            	movl $1, %ebx        #Restarting counter
            	jmp pwhile
            
        	lastb:            #We reach last byte
                
            	pushl $cpy3
            	pushl %ebx
            	pushl $hxpadd1
            	pushl $buff2         #Saving similar pixels
            	call _sprintf
            	addl $16, %esp
            	addl $3, pitch
                
            	pushl $buff2
            	pushl $rle_pixels    #Saving pixels
            	call _strcat
            	addl $8, %esp
        
        pushl fptr
        call _fclose      #Closing pbm file
        addl $4, %esp
        
        pushl $frle
        pushl $fname2     #Adding .rle extension
        call _strcat
        addl $8, %esp
        
        pushl $fmode2
        pushl $fname2
        call _fopen       #Opening compression file
        addl $8, %esp
        movl %eax, fptr
        
        pushl $cpy1
        pushl $fmt2       #Writing starting bytes
        pushl fptr
        call _fprintf     
        addl $8, %esp
        
        pushl pitch
        pushl $hxpadd2
        pushl fptr        #Writing the indicator of n compressed pixels
        call _fprintf     
        addl $8, %esp
        
        pushl fptr
        pushl $rle_pixels
        call _fputs       #Writing compressed pixels
        addl $4, %esp

        pushl $100000000
        pushl $0
        pushl $rle_pixels #Clearing buff1
        call _memset
        addl $8, %esp

        pushl fptr
        call _fclose      #Closing compressed file
        addl $4, %esp  
    
        jmp whatnow
    
    decompressing:

    	movl $1, multi    #Restarting multiplier

    	pushl $hzero
    	pushl $cpy4	  #Copying leading hexa-zero Ox
    	call _strcpy
    	addl $8, %esp

    	pushl $req
        call _printf
        addl $4, %esp     #Saving
        pushl $fname      #file name
        pushl $fmt2       
        call _scanf 
        addl $8, %esp      

        pushl $req2
        call _printf
        addl $4, %esp     #Saving output
        pushl $fname2     #file name
        pushl $fmt2       
        call _scanf
        addl $8, %esp 

        pushl $fmode1        
        pushl $fname     
        call _fopen       #Getting
        addl $8, %esp     #file pointer
        cmpb $0, %al
        je ipt_err2
        movl %eax, fptr

        pushl fptr
        pushl $5
        pushl $2          #Reading magic
        pushl $buff1      #number
        call _fread         
        addl $16, %esp
    
        pushl $buff1     
        pushl $cpy1  
        call _strcmp      #Validating RLE file magic number
        addl $8, %esp     
        cmpl $0, %eax
        jne ipt_err4

        pushl $10000
        pushl $0               
        pushl $buff1      #Clearing buff1
        call _memset	     
        addl $12, %esp

        pushl fptr
        pushl $4
        pushl $2          #Getting image width,
        pushl $buff1      #height and n-pixels
        call _fread
        addl $16, %esp

        pushl $buff1
        pushl $cpy2       #Appending width and height
        call _strcat      #to pbm file preface
        addl $8, %esp

        pushl $10000
        pushl $0               
        pushl $buff1      #Clearing buff1
        call _memset	     
        addl $12, %esp

	pushl fptr
        pushl $2
        pushl $2          #Skipping image pitch
        pushl $buff1      
        call _fread
        addl $16, %esp

        movl $1, %ebx     #Initializing multiplier

        rwhile:

        	pushl fptr
        	pushl $2
        	pushl $2            
        	pushl $buff1          
        	call _fread       #Reading 4 bytes from file
        	addl $16, %esp    
        	cmpl $2, %eax
        	jne endwhile

        	pushl $buff1
        	pushl $cpy4       #Appending leading hexa-zero 
        	call _strcat	  #to those last 4 bytes
        	addl $8, %esp

        	pushl $16
        	pushl $null
        	pushl $cpy4	  #Conversion from hex to long
        	call _strtol	  
        	movl %eax, %ebx   #%ebx will have this resulting long

        	pushl $hzero
    		pushl $cpy4       #Restoring copy of 
    		call _strcpy	  #leading hexa-zero Ox
    		addl $8, %esp

        	pushl fptr
        	pushl $1	  #Reading next 2 bytes
        	pushl $2          #corresponding the image pixel, respectively.
        	pushl $buff2      #If this was not applicable, then
        	call _fread       #we can assume that the input rle format
        	addl $16, %esp    #was not correct in regards to the
        	cmpl $1, %eax     #approach to this project issue
        	jne ipt_err5

            	pushl %ebx

            	pushl $buff2
            	pushl %ebx    	  #Multiplying bytes
            	call mul
            	addl $12, %esp

            	popl %ebx

        	movl $1, %ebx     #Restoring multiplier
        	jmp rwhile

        endwhile:

        pushl fptr
        call _fclose      #Closing RLE file
        addl $4, %esp
        
        pushl $fpbm
        pushl $fname2     #Adding .pbm extension
        call _strcat
        addl $8, %esp
        
        pushl $fmode2
        pushl $fname2
        call _fopen       #Opening decompressed file
        addl $8, %esp
        movl %eax, fptr
        
        pushl $cpy2
        pushl $fmt2       #Adding pbm file preface
        pushl fptr
        call _fprintf     
        addl $8, %esp
        
        pushl fptr
        pushl $pbm_pixels
        call _fputs       #Writing decompressed pixels
        addl $4, %esp

        pushl $100000000
        pushl $0
        pushl $pbm_pixels #Clearing memory areas
        call _memset
        addl $8, %esp

        pushl fptr
        call _fclose      #Closing decompressed file
        addl $4, %esp  
    
        jmp whatnow

    mul:

    	pushl %ebp
    	movl %esp, %ebp
    	movl 8(%ebp), %esi
        movl 12(%ebp), %edi

        movl $0, %ebx

        loop:

            cmpl %esi, %ebx    
            je eloop

            pushl %edi
            pushl $pbm_pixels  
            call _strcat
            addl $8, %esp

            incl %ebx  
            jmp loop 

        eloop: 

    	leave
    	ret

    finish:
    
        pushl $succ
        call _exit
    
    ipt_err1:

        pushl $err1
        call _printf     
        addl $4, %esp
        
        jmp choice
        
    ipt_err2:
        
        pushl $err2
        call _perror    
        addl $4, %esp
        
        pushl $fail
        call _exit
        
    ipt_err3:
        
        pushl $fname
        pushl $err3
        call _printf     
        addl $8, %esp
        
        pushl fptr
        call _fclose
        addl $4, %esp
    
        pushl $fail
        call _exit

    ipt_err4:
        
        pushl $fname
        pushl $err4
        call _printf     
        addl $8, %esp
        
        pushl fptr
        call _fclose
        addl $4, %esp
    
        pushl $fail
        call _exit

    ipt_err5:
        
        pushl $fname
        pushl $err5
        call _printf     
        addl $8, %esp
        
        pushl fptr
        call _fclose
        addl $4, %esp
    
        pushl $fail
        call _exit
    
