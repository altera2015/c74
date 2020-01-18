# python3 as.py app.s -b app.bin --details
# sudo dd if=app.bin of=/dev/sdb bs=512 count=1 conv=notrunc
# verify: sudo dd if=/dev/sdb of=mbr bs=512 count=1
.mem 0x300
    mov r0, 0x101
    out r0, PORT_SEVEN_SEG

:uart_print_wait    
    in r1, PORT_UART_FLAGS
    tst r1, 0
    jeq uart_print_wait    
    mov r2, 65
    out r2, PORT_UART_TX_DATA
    j uart_print_wait