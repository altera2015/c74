# C74 Self Check
    
# Check MOVI & CMPI
    mov sp, 0xff
    cmp sp, 0xff    # Error 1 = MOVI check
    jeq !12
    mov r0, 1
    hlt

# Check MOV & CMPI
    mov r1, sp
    cmp r1, 0xff    # MOVI check
    jeq !12
    mov r0, 2       # Error 2 = MOV failed
    hlt
        
# Check CMP for True
    cmp r1, sp
    jeq !12
    mov r0, 3
    hlt

# Check CMP for False
    cmp r1, r3
    jne !12
    mov r0, 4
    hlt
    
# ADD
    add r1, r1, 1
    cmp r1, 0x100
    jeq !12
    mov r0, 5
    hlt
    
# SUB
    sub r1, r1, 2
    cmp r1, 0xfe
    jeq !12
    mov r0, 6
    hlt
    
# SUB Carry flag check
    mov r1, 0
    sub r1, r1, 1
    in r1, PORT_STATUS_REG
    tst r1, C_FLAG_BIT
    jeq !12
    mov r0, 6
    hlt
    
    
# AND
    and r1, r1, 0
    cmp r1, 0
    jeq !12    
    mov r0, 7
    hlt

# OR
    or r1, r1, 0xff
    cmp r1, 0xff
    jeq !12    
    mov r0, 8
    hlt
    
# XOR
    xor r1, r1, 0xa
    cmp r1, 0xf5
    jeq !12    
    mov r0, 9
    hlt
    
# NOT
    mov r1, 0
    sub r1, r1, 1
    not r1, r1
    cmp r1, 0
    jeq !12    
    mov r0, 0xa
    hlt    
    
# LSL 1
    mov r1, 1
    lsl r1, r1, 1
    cmp r1, 2
    jeq !12    
    mov r0, 0xb
    hlt
    
# LSL 2
    mov r1, 1
    lsl r1, r1, 2
    cmp r1, 4
    jeq !12    
    mov r0, 0xc
    hlt

# LSR 1
    mov r1, 2
    lsr r1, r1, 1
    cmp r1, 1
    jeq !12    
    mov r0, 0xd
    hlt
    
# LDR
    LDR r1, mem1
    cmp r1, 0x01
    jeq !12    
    mov r0, 0xe
    hlt
    
# LDA
    MOV r2, mem1
    ADD r3, r2, 4
    LDA r1, r2, 4
    cmp r1, 0x01
    jeq !20
    cmp r2, r3
    jeq !12
    mov r0, 0xf
    hlt


# OK!!    
    mov r0, 0       # Error 0 = C74 OK!
    sub r0, r0, 1
    hlt
    
    
:mem1
    .word 0x01
:mem2
    .word 0x02
:mem3
    .word 0x03
:mem4
    .word 0x04
