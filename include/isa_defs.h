// Generated by isa.py, do not edit.

#ifndef _ISA_DEFS_H_
#define _ISA_DEFS_H_

	// Op Code Groups
#define GRP_MISC  		 0x00
#define GRP_UNSD1 		 0x01
#define GRP_UNSD2 		 0x02
#define GRP_JMP   		 0x03
#define GRP_ALU   		 0x04
#define GRP_FLGS  		 0x05
#define GRP_MEM   		 0x06
#define GRP_BOOL  		 0x07

// Op Codes
#define OP_NOP   		 0x00
#define OP_OUT   		 0x03
#define OP_IN    		 0x05
#define OP_CALL  		 0x06
#define OP_CALLI 		 0x07
#define OP_RET   		 0x08
#define OP_RETI  		 0x0A
#define OP_PUSH  		 0x0C
#define OP_PUSHI 		 0x0D
#define OP_POP   		 0x0E
#define OP_J     		 0x60
#define OP_JI    		 0x61
#define OP_JEQ   		 0x62
#define OP_JEQI  		 0x63
#define OP_JCS   		 0x64
#define OP_JCSI  		 0x65
#define OP_JNEG  		 0x66
#define OP_JNEGI 		 0x67
#define OP_JVS   		 0x68
#define OP_JVSI  		 0x69
#define OP_JHI   		 0x6A
#define OP_JHII  		 0x6B
#define OP_JGE   		 0x6C
#define OP_JGEI  		 0x6D
#define OP_JGT   		 0x6E
#define OP_JGTI  		 0x6F
#define OP_JNE   		 0x72
#define OP_JNEI  		 0x73
#define OP_JCC   		 0x74
#define OP_JCCI  		 0x75
#define OP_JPOS  		 0x76
#define OP_JPOSI 		 0x77
#define OP_JVC   		 0x78
#define OP_JVCI  		 0x79
#define OP_JLS   		 0x7A
#define OP_JLSI  		 0x7B
#define OP_JLT   		 0x7C
#define OP_JLTI  		 0x7D
#define OP_JLE   		 0x7E
#define OP_JLEI  		 0x7F
#define OP_SUB   		 0x80
#define OP_SUBI  		 0x81
#define OP_SUBC  		 0x82
#define OP_SUBCI 		 0x83
#define OP_ADD   		 0x84
#define OP_ADDI  		 0x85
#define OP_ADDC  		 0x86
#define OP_ADDCI 		 0x87
#define OP_CMP   		 0x88
#define OP_CMPI  		 0x89
#define OP_SET   		 0xA0
#define OP_CLR   		 0xA2
#define OP_HLT   		 0xA4
#define OP_INT   		 0xA6
#define OP_TST   		 0xA9
#define OP_MOV   		 0xAA
#define OP_MOVI  		 0xAB
#define OP_LDR   		 0xC0
#define OP_LDRI  		 0xC1
#define OP_STR   		 0xC2
#define OP_STRI  		 0xC3
#define OP_LDRB  		 0xC4
#define OP_LDRBI 		 0xC5
#define OP_STRB  		 0xC6
#define OP_STRBI 		 0xC7
#define OP_LDA   		 0xC8
#define OP_STA   		 0xCA
#define OP_LDAB  		 0xCC
#define OP_STAB  		 0xCE
#define OP_AND   		 0xE0
#define OP_ANDI  		 0xE1
#define OP_OR    		 0xE2
#define OP_ORI   		 0xE3
#define OP_XOR   		 0xE4
#define OP_XORI  		 0xE5
#define OP_LSL   		 0xE6
#define OP_LSLI  		 0xE7
#define OP_LSR   		 0xE8
#define OP_LSRI  		 0xE9
#define OP_ASL   		 0xEA
#define OP_ASLI  		 0xEB
#define OP_ASR   		 0xEC
#define OP_ASRI  		 0xED
#define OP_NOT   		 0xEE
#define OP_NOTI  		 0xEF

// Short Codes
#define SC_NOP   		 0x00
#define SC_OUT   		 0x01
#define SC_IN    		 0x02
#define SC_CALL  		 0x03
#define SC_CALLI 		 0x03
#define SC_RET   		 0x04
#define SC_RETI  		 0x05
#define SC_PUSH  		 0x06
#define SC_PUSHI 		 0x06
#define SC_POP   		 0x07
#define SC_J     		 0x00
#define SC_JI    		 0x00
#define SC_JEQ   		 0x01
#define SC_JEQI  		 0x01
#define SC_JCS   		 0x02
#define SC_JCSI  		 0x02
#define SC_JNEG  		 0x03
#define SC_JNEGI 		 0x03
#define SC_JVS   		 0x04
#define SC_JVSI  		 0x04
#define SC_JHI   		 0x05
#define SC_JHII  		 0x05
#define SC_JGE   		 0x06
#define SC_JGEI  		 0x06
#define SC_JGT   		 0x07
#define SC_JGTI  		 0x07
#define SC_JNE   		 0x09
#define SC_JNEI  		 0x09
#define SC_JCC   		 0x0A
#define SC_JCCI  		 0x0A
#define SC_JPOS  		 0x0B
#define SC_JPOSI 		 0x0B
#define SC_JVC   		 0x0C
#define SC_JVCI  		 0x0C
#define SC_JLS   		 0x0D
#define SC_JLSI  		 0x0D
#define SC_JLT   		 0x0E
#define SC_JLTI  		 0x0E
#define SC_JLE   		 0x0F
#define SC_JLEI  		 0x0F
#define SC_SUB   		 0x00
#define SC_SUBI  		 0x00
#define SC_SUBC  		 0x01
#define SC_SUBCI 		 0x01
#define SC_ADD   		 0x02
#define SC_ADDI  		 0x02
#define SC_ADDC  		 0x03
#define SC_ADDCI 		 0x03
#define SC_CMP   		 0x04
#define SC_CMPI  		 0x04
#define SC_SET   		 0x00
#define SC_CLR   		 0x01
#define SC_HLT   		 0x02
#define SC_INT   		 0x03
#define SC_TST   		 0x04
#define SC_MOV   		 0x05
#define SC_MOVI  		 0x05
#define SC_LDR   		 0x00
#define SC_LDRI  		 0x00
#define SC_STR   		 0x01
#define SC_STRI  		 0x01
#define SC_LDRB  		 0x02
#define SC_LDRBI 		 0x02
#define SC_STRB  		 0x03
#define SC_STRBI 		 0x03
#define SC_LDA   		 0x04
#define SC_STA   		 0x05
#define SC_LDAB  		 0x06
#define SC_STAB  		 0x07
#define SC_AND   		 0x00
#define SC_ANDI  		 0x00
#define SC_OR    		 0x01
#define SC_ORI   		 0x01
#define SC_XOR   		 0x02
#define SC_XORI  		 0x02
#define SC_LSL   		 0x03
#define SC_LSLI  		 0x03
#define SC_LSR   		 0x04
#define SC_LSRI  		 0x04
#define SC_ASL   		 0x05
#define SC_ASLI  		 0x05
#define SC_ASR   		 0x06
#define SC_ASRI  		 0x06
#define SC_NOT   		 0x07
#define SC_NOTI  		 0x07

// Status Register Flags
#define Z_FLAG_POS 		 0
#define V_FLAG_POS 		 1
#define C_FLAG_POS 		 2
#define N_FLAG_POS 		 3
#define I_FLAG_POS 		 4

// IRQ Flags
#define IRQ_BUTTON0          1
#define IRQ_BUTTON1          2
#define IRQ_BUTTON2          4
#define IRQ_BUTTON3          8
#define IRQ_BUTTON4          16
#define IRQ_BUTTON5          32
#define IRQ_VBLANK           64
#define IRQ_UART_RX          128
#define IRQ_KEYBOARD         256
#define IRQ_SD_CARD          512

// Port Definitions
#define PORT_STATUS_REG      0
#define PORT_IRQ_CLEAR       1
#define PORT_IRQ_MASK        2
#define PORT_IRQ_READY       3
#define PORT_LED             5
#define PORT_SEVEN_SEG       6
#define PORT_BUTTONS         7
#define PORT_SWITCHES        8
#define PORT_UART_FLAGS      10
#define PORT_UART_TX_DATA    11
#define PORT_UART_RX_DATA    12
#define PORT_SD_FLAGS        20
#define PORT_SD_COMMAND      21
#define PORT_SD_ADDRESS      22
#define PORT_SD_RX_DATA      23
#define PORT_PS2_FLAGS       30
#define PORT_PS2_RX_DATA     31
#define PORT_PS2_TX_DATA     32

// Debug Port Definitions
#define DBG_HALTED               0x10
#define DBG_RUNNING              0x11
#define DBG_STATUS               0x12
#define DBG_HALT                 0x13
#define DBG_CONTINUE             0x14
#define DBG_STEP                 0x15
#define DBG_RESET                0x16
#define DBG_GET_CPU_FLAGS        0x2F
#define DBG_GET_REG_0            0x30
#define DBG_GET_REG_1            0x31
#define DBG_GET_REG_2            0x32
#define DBG_GET_REG_3            0x33
#define DBG_GET_REG_4            0x34
#define DBG_GET_REG_5            0x35
#define DBG_GET_REG_6            0x36
#define DBG_GET_REG_7            0x37
#define DBG_GET_REG_8            0x38
#define DBG_GET_REG_9            0x39
#define DBG_GET_REG_10           0x3A
#define DBG_GET_REG_11           0x3B
#define DBG_GET_REG_12           0x3C
#define DBG_GET_REG_13           0x3D
#define DBG_GET_REG_14           0x3E
#define DBG_GET_REG_15           0x3F
#define DBG_GET_MEM              0x40
#define DBG_SET_MEM              0x41
#define DBG_RUNNING_CPU_ID       0x43373430
#define DBG_HALTED_CPU_ID        0xC3373430

#endif
