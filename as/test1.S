    mov r4, 0 ; color
    ldr r5, color_inc
    ldr r1, pixel_count
:start
    add r4,r4,r5
    
    ldr r2, frame_buffer    ; address pointer
    add r3, r1, r2          ; max address
    
           
:loop
    
    str r4, r2, 4
    cmp r2, r3
    jne loop
    j start


    mov r1, 0x10
    mov r2, 0x20
    
    add r3, r1, r2
    add r4, r1, 4
    
    ldr r1, big_num
    ldr r2, big_num
    cmp r1,r2
    
    jeq start
    
    


    nop
    inc r1, 2
    dec r9, 3000
    setz, 1
    setc, 1
    setn, 1

    setz, 0
    setc, 0
    setn, 0

    mov r1, 0x10
    mov r2, 0x20

    mov r0, source_mem
    ldr r3, r0, 4   ; r3 = 1
    ldr r4, r0, 0   ; r4 = 2
    mov r0, source_mem
    str r1, r0, 4   ; source_mem[0] = 0x10
    str r2, r0, 0   ; source_mem[1] = 0x20
    mov r0, source_mem
    ldr r5, r0, 4   ; r5 = 0x10
    ldr r6, r0, 2   ; r6 = 0x20
    j, start

:source_mem  
    .word 0x1
:storage_mem 
    .word 0x2
:big_num
    .word 0xffffffff
    
:pixel_count
    .word 0x1D4C0 ; 800x600 / 4
:pixel_count_fake
    .word 8
:frame_buffer
    .word 0x1000 ; 4096
:color_inc
    .word 0x01010101
    
    
#    
#
#    str r1, d2
#    nop
#    ldr r0, d2
#    inc r0, 2
#    dec r0, 4
##    movi r1, 0x1abc
#    mov r3, r1
#    ldr r1, d
#    movi r2, 2
#    ldr r1,r2,2
#    j 0x1000    



#12 * 4  = 48

