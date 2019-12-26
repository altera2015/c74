.const LED_OUT 0
.const SEVEN_SEGMENT_OUT 1
.const UART_OUT 2
.const UART_FLAGS 3

.const STACK_POINTER_BASE 0x800

    mov r14, STACK_POINTER_BASE
    mov r0, 0xf
    mov r1, 1
    
    
    push r0
    push r1
    
    mov r0, 0
    mov r1, 0
    
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
    