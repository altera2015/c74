# C74 Self Check
    
# Check MOVI & CMPI
    mov sp, 0x800
    cmp sp, 0x800    # Error 1 = MOVI check
    jeq !12
    mov r0, 1
    hlt

# Check MOV & CMPI
    mov r1, sp
    cmp r1, 0x800    # MOVI check
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
    cmp r1, 0x801
    jeq !12
    mov r0, 5
    hlt
    
# SUB
    sub r1, r1, 2
    cmp r1, 0x7ff
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

# LDRB + 0
    mov r2, mem7
    LDRB r3, r2, 0
    cmp r3, 65
    jeq !12
    mov r0, 0x10
    hlt

# LDRB + 1    
    LDRB r3, r2, 1
    cmp r3, 66
    jeq !12
    mov r0, 0x11
    hlt

# LDRB + 2    
    LDRB r3, r2, 2
    cmp r3, 67
    jeq !12
    mov r0, 0x12
    hlt

# LDRB + 3    
    LDRB r3, r2, 3
    cmp r3, 68
    jeq !12
    mov r0, 0x13
    hlt


    # clear r3
    mov r3, 0

# LDAB @ mem7
    mov r2, mem7
    LDAB r3, r2, 1
    cmp r3, 65
    jeq !12
    mov r0, 0x14
    hlt

# LDAB @ mem7 + 1    
    LDAB r3, r2, 1
    cmp r3, 66
    jeq !12
    mov r0, 0x15
    hlt

# LDAB @ mem7 + 2    
    LDAB r3, r2, 1
    cmp r3, 67
    jeq !12
    mov r0, 0x16
    hlt

# LDAB @ mem7 + 3    
    LDAB r3, r2, 1
    cmp r3, 68
    jeq !12
    mov r0, 0x17
    hlt


# STR 0xfff @ mem 4a
    mov r3, 0xfff
    mov r2, mem4
    STR r3, r2, 4
    
    mov r3, 0
    mov r2, mem4
    LDR r3, r2, 4
    
    cmp r3, 0xfff
    jeq !12
    mov r0, 0x18
    hlt
    


# STA 0xfff @ mem 4
    mov r3, 0x404
    mov r2, mem4
    STA r3, r2, 4   # Store 0x404 at memeory address mem4.
    sub r2, r2, 4   # check that r2 advanced by 4
    cmp r2, mem4    # should now match mem4 address
    jeq !12
    mov r0, 0x19
    hlt

    
    mov r3, 0
    mov r2, mem4
    LDR r3, r2, 4 # READ memory address at mem4 + 4    
    cmp r3, 0xfff # should still be at fff
    jeq !12
    mov r0, 0x1a
    hlt
    
    mov r3, 0
    mov r2, mem4
    LDR r3, r2, 0 # READ memory address at mem4
    cmp r3, 0x404 # should be 404
    jeq !12
    mov r0, 0x1b
    hlt



# STRB 0x00 @ mem_ba_1 + 1
    mov r3, 0
    mov r2, mem_ba_1
    STRB r3, r2, 1   # Store 0x00 at memeory address mem_ba_1 + 1
    
    LDR r3, mem_ba_1
    LDR r4, mem_ba_2
    
    cmp r3, r4    # Compare with mem_ba_+ 2
    jeq !12
    mov r0, 0x1c
    hlt

# Mult

    mov r3, 10
    mov r4, 20
    mul r2, r3, r4
    cmp r2, 200

    jeq !12
    mov r0, 0x1d
    hlt

# Multi

    mov r3, 25    
    mul r2, r3, 4
    cmp r2, 100

    jeq !12
    mov r0, 0x1e
    hlt



    mov r1, 2
    call func_r0_equals_r1_plus_2
    cmp r0, 4

    jeq !12
    mov r0, 0x1e
    hlt


# OK!!    
    mov r0, 0       # Error 0xffffffff = C74 OK!
    sub r0, r0, 1
    hlt
    
:func_r0_equals_r1_plus_2
    add r0, r1, 2
    ret    
    
:mem1
    .word 0x01
:mem2
    .word 0x02
:mem3
    .word 0x03
:mem4
    .word 0x04
:mem4b
    .word 0xaaaaaaaa

:mem_ba_1
    .word 0xffffffff
:mem_ba_2 
    .word 0xff00ffff
    
:mem5
    .word 0x01020304
:mem6
    .word 0x11121314
:mem7
    .str "ABCD"