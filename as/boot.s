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

:irq0
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

#:irq0
    ## Save all modified registers
    #push r0
    ## Save the Status Register
    #in r0, PORT_STATUS_REG
    #push r0

    #not r9, r9
    #out r9, PORT_LED
    
    ## Restore the status Register
    #pop r0
    #out r0, PORT_STATUS_REG    
    ## Restore modified registers
    #pop r0
    #reti
    


:main

mov r9, 0
mov sp, 0x800 

#mov r0, IRQ_BUTTON0
#out r0, PORT_IRQ_MASK
#set I_FLAG_BIT

:start
    mov r0, welcome 
    call uart_print
    
    mov r3, 0xffff
    lsl r3, r3, 16

:wait_for_sd_ready
    in r0, PORT_SD_FLAGS
    tst r0, 1 # is busy?    
    jeq wait_for_sd_ready    
    tst r0, 4 # error bit
    jne start_load

:failed
    in r0, PORT_SD_FLAGS
    call word_print    
    mov r0, sd_errorB
    call uart_print
    hlt
            
:start_load            

    mov r0, loading
    call uart_print
    
    # Load the first block from SDCard.
    mov r0, 0
    out r0, PORT_SD_ADDRESS
    mov r0, 0 # READ SECTOR
    out r0, PORT_SD_COMMAND
    
    mov r0, loading2
    call uart_print
        
    mov r1, 0x300
    mov r2, 512
    
:wait_for_sd_data
    mov r10, 0xffff
:slow
    sub r10, r10, 1    
    jne slow 
    
    out r2, PORT_SEVEN_SEG
    
    in r0, PORT_SD_FLAGS
    tst r0, 4 # error bit
    jeq failed
    tst r0, 0 
    jne wait_for_sd_data
    
    
    in r3, PORT_SD_RX_DATA
    out r3, PORT_LED
    
    #mov r0, r1
    #call word_print
    #mov r0, 0x20
    #call char_print
    #mov r0, r3
    #call bin_print
    #mov r0, 0x20
    #call char_print
    
    stab r3, r1, 1 # store at address stored in r1 and post increment.
    sub r2, r2, 1
    jne wait_for_sd_data
    
    # all data loaded, jump to application.
    mov r0, sd_loaded
    call uart_print
    
    
    #mov r1, 0x300    
#:read_back
    #lda r0, r1, 4
    #call word_print
    #mov r0, 0x20
    #call char_print    
    #cmp r1, 0x310
    #jne read_back
    
    mov r0, sd_loaded
    call uart_print
    
    mov r0, 0xfff
    out r0, PORT_SEVEN_SEG
    mov r0, 0x500
    mov r1, 0x300    
    j r1        
    hlt
   
   
:char_print
    push r1
:char_print_wait
    in r1, PORT_UART_FLAGS
    tst r1, 0
    jeq char_print_wait
    out r0, PORT_UART_TX_DATA
    pop r1
    ret

:word_print
    push r1
    push r2
    push r3
    push r4
    
    mov r1, r0
    lsr r2, r1, 8
    lsr r3, r2, 8
    lsr r4, r3, 8
    
    mov r0, r4
    call bin_print
    mov r0, r3
    call bin_print
    mov r0, r2
    call bin_print
    mov r0, r1
    call bin_print
        
    pop r4
    pop r3
    pop r2
    pop r1
    
    ret
    
# 8 bit value to print in r0
:bin_print
    push r1
    push r2   
    and r1, r0, 0xff
    and r2, r1, 0x0f    
    lsr r1, r1, 4
    
    cmp r2, 10
    JHI a1 # 10 larger than r2
    add r2, r2, 55 # = 'A'
    j a2
:a1
    add r2, r2, 48 # = '0'
:a2    
    cmp r1, 10
    JHI b1 # 10 larger than r2
    add r1, r1, 55 # = 'A'
    j b2
:b1
    add r1, r1, 48 # = '0'
:b2
:c1
    in r0, PORT_UART_FLAGS
    tst r0, 0
    jeq c1
    out r1, PORT_UART_TX_DATA

:c2
    in r0, PORT_UART_FLAGS
    tst r0, 0
    jeq c2
    out r2, PORT_UART_TX_DATA
    
    pop r2
    pop r1    
    ret
    
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
    .str "\nC74.000\rCopyright (c) 2020 Ron Bessems\rBuild 0.0.4\n\0"
:loading
    .str "Loading...\n\0"
:loading2
    .str "Loading (2)\n\0"
:sd_errorB
    .str "SD Error, B.\n\0"
:sd_loaded
    .str "booting,...\n\0"