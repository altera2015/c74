:start
    nop

    movi r1, 0xaaaa
    str r1, d2
    nop
    ldr r0, d2
    inc r0, 2
    dec r0, 4
    movi r1, 0x1abc
    mov r3, r1
    ldr r1, d
    movi r2, 2
    ldr r1,r2,2
    j 0x1000    
:d  .word 0xffffaaaa
:d2 .word 0x00000000

#12 * 4  = 48

