mov sp, 0x800 
mov r0, 0x01
out r0, PORT_LED
:start
    mov r0, welcome 
    call uart_print    
    j start
    mov r0, 0xff
    out r0, PORT_LED
    hlt
# address pointer in r0
# modifies r0,r1,r2,r3,r4 and r5
# no returns
:uart_print
    lda r4, r0, 4
    lsr r3, r4, 8
    lsr r2, r3, 8
    lsr r1, r2, 8
                
:uart_print_wait1
    in r5, PORT_UART_FLAGS
    tst r5, 0
    jeq uart_print_wait1
    
    out r1, PORT_UART_TX_DATA
    cmp r1, 0    
    jeq uart_print_done


:uart_print_wait2
    in r5, PORT_UART_FLAGS
    tst r5, 0
    jeq uart_print_wait2
    
    cmp r2, 0    
    jeq uart_print_done
    
    out r2, PORT_UART_TX_DATA

:uart_print_wait3
    in r5, PORT_UART_FLAGS
    tst r5, 0
    jeq uart_print_wait3
    cmp r3, 0    
    jeq uart_print_done
    
    out r3, PORT_UART_TX_DATA

:uart_print_wait4
    in r5, PORT_UART_FLAGS
    tst r5, 0
    jeq uart_print_wait4
    cmp r4, 0    
    jeq uart_print_done
    
    out r4, PORT_UART_TX_DATA
    j uart_print
    
:uart_print_done
    ret    
    
    
:welcome
    .str "C74.000\r\nCopyright (c) 2020 Ron Bessems\r\n\0"