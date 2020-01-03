j main

j irq0
j irq1
j irq2
j irq3
j irq4
j irq5
j irq6
j irq7
j irq8
j irq9
j irq10
j irq11
j irq12
j irq13
j irq14
j irq15

:irq1
:irq2
:irq3
:irq4
:irq5
:irq6
:irq7
:irq8
:irq9
:irq10
:irq11
:irq12
:irq13
:irq14
:irq15
    reti

:irq0
    # Save all modified registers
    push r0
    # Save the Status Register
    in r0, PORT_STATUS_REG
    push r0

    not r9, r9
    out r9, PORT_LED
    
    # Restore the status Register
    pop r0
    out r0, PORT_STATUS_REG    
    # Restore modified registers
    pop r0
    reti

:main

mov r9, 0

mov sp, 0x800 
mov r0, 0x01
out r0, PORT_LED

mov r0, IRQ_BUTTON0
out r0, PORT_IRQ_MASK
set I_FLAG_BIT

:start
    mov r0, welcome 
    call uart_print
    
    # Wait for data
    :wait_for_data
    in r1, PORT_UART_FLAGS
    #out r1, PORT_LED
    tst r1, 1 # empty bit    
    jeq wait_for_data
    
    in r1, PORT_UART_RX_DATA
    out r1, PORT_SEVEN_SEG
    out r1, PORT_UART_TX_DATA
    j wait_for_data
    
    hlt
    
# address pointer in r0
# no return    
:uart_print   
    push r0
    push r1

    :uart_print_wait
            in r1, PORT_UART_FLAGS
            tst r1, 0
        jeq uart_print_wait
        ldab r1, r0, 1    
        cmp r1, 0
    jeq uart_print_done
    out r1, PORT_UART_TX_DATA
    j uart_print_wait
    
:uart_print_done    
    pop r1
    pop r0
    ret
    
:welcome
    .str "C74====\nC74.000\nCopyright (c) 2020 Ron Bessems\nRevision 0.0.2\n\0"