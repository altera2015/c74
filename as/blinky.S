.const LED_OUT 0
.const FRAME_BUFFER 6144


    mov r1, 0
    
    mov r5, FRAME_BUFFER
    ldr r6, pixel_count
    add r6, r5, r6
:loop
    mov r3, 0xffff    
:wait_loop
    sub r3, r3, 1
    jne wait_loop
    add r1, r1, 1        
    out r1, 0
    
    str r1, r5, 4
    cmp r5, r6
    jne loop    
    mov r5, FRAME_BUFFER
    
    j loop
    
:pixel_count
    .word 120000