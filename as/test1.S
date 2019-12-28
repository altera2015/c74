.const LED_OUT 0
.const SEVEN_SEGMENT_OUT 1
.const UART_OUT 2
.const UART_FLAGS 3


.const STACK_POINTER_BASE 0x800

    mov sp, STACK_POINTER_BASE
    j main
    
:interupt_table
    .word 1
    .word 2
    .word 3
    .word 4
    .word 5
    .word 6
    .word 7
    .word 8
    .word 9
:interupt_tableB
    .word 10
    .word 11
    .word 12
    .word 13
    .word 14
    .word 15
    .word 16
            
:main
    
    mov r0, 0
    mov r1, 0
    ldr r1, interupt_table      # r1 = 1
    mov r1, 0xff                # r1 = 0xff
    str r1, interupt_table      # it[0] = 0xff
    
    mov r3, interupt_table      # r3 = address of interupt table    
    str r1, r3, 4               # store it[4] = 0xff
    ldr r2, r3, 4               # load r2 from it[4] = 0xff
        
    mov r1, 0                   # r1 = 0
    lda r1, r3, 4               # r1 = 0xff, r3 = interupt table + 4
    
    mov r3, interupt_tableB
    lda r1, r3, 4               # r1 = 10
    lda r1, r3, 4               # r1 = 11
    lda r1, r3, 4               # r1 = 12
    lda r1, r3, 4               # r1 = 13
    
    mov r3, interupt_tableB
    sta r0, r3, 4               # it[10] = 0
    sta r0, r3, 4               # it[14] = 0
    sta r0, r3, 4               # it[18] = 0
    sta r0, r3, 4               # it[22] = 0
    
    mov r3, interupt_tableB
    lda r1, r3, 4               # r1 = 0
    lda r1, r3, 4               # r1 = 0
    lda r1, r3, 4               # r1 = 0
    lda r1, r3, 4               # r1 = 0

    
    mov r0, 0xf
    mov r1, 1
    mov r2, 0xff
    
    push r0
    push r1
    
    mov r0, 0
    mov r1, 0
    call set_led
    
    pop r1
    pop r0
    

    mov r0, 0x01
    mov r1, 0xfe
    mov r2, 65
    
    out r2, LED_OUT
    mov r5, 0
:loop
    
    out r5, LED_OUT
    in r3, UART_FLAGS
    cmp r3, 0
    jne loop
    
    inc r5, 1    
    out r2, UART_OUT    
    
    mov r8, 0xffff
:wait

    
    dec r8, 1
    cmp r8, 0
    jne wait
    
    
    j loop
    
    
:set_led

    out r2, LED_OUT
    ret