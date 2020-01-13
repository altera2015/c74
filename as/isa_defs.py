# Generated by isa.py, do not edit.

OP_NOP   = 0   ; # 00
OP_OUT   = 5   ; # 05
OP_IN    = 9   ; # 09
OP_CALLI = 12  ; # 0C
OP_CALL  = 13  ; # 0D
OP_RET   = 16  ; # 10
OP_RETI  = 20  ; # 14
OP_PUSH  = 25  ; # 19
OP_POP   = 29  ; # 1D
OP_JI    = 64  ; # 40
OP_J     = 65  ; # 41
OP_JEQI  = 68  ; # 44
OP_JEQ   = 69  ; # 45
OP_JCSI  = 72  ; # 48
OP_JCS   = 73  ; # 49
OP_JNEGI = 76  ; # 4C
OP_JNEG  = 77  ; # 4D
OP_JVSI  = 80  ; # 50
OP_JVS   = 81  ; # 51
OP_JHII  = 84  ; # 54
OP_JHI   = 85  ; # 55
OP_JGEI  = 88  ; # 58
OP_JGE   = 89  ; # 59
OP_JGTI  = 92  ; # 5C
OP_JGT   = 93  ; # 5D
OP_JNEI  = 100 ; # 64
OP_JNE   = 101 ; # 65
OP_JCCI  = 104 ; # 68
OP_JCC   = 105 ; # 69
OP_JPOSI = 108 ; # 6C
OP_JPOS  = 109 ; # 6D
OP_JVCI  = 112 ; # 70
OP_JVC   = 113 ; # 71
OP_JLSI  = 116 ; # 74
OP_JLS   = 117 ; # 75
OP_JLTI  = 120 ; # 78
OP_JLT   = 121 ; # 79
OP_JLEI  = 124 ; # 7C
OP_JLE   = 125 ; # 7D
OP_SUBI  = 130 ; # 82
OP_SUB   = 131 ; # 83
OP_SUBCI = 134 ; # 86
OP_SUBC  = 135 ; # 87
OP_ADDI  = 138 ; # 8A
OP_ADD   = 139 ; # 8B
OP_ADDCI = 142 ; # 8E
OP_ADDC  = 143 ; # 8F
OP_CMPI  = 146 ; # 92
OP_CMP   = 147 ; # 93
OP_SET   = 160 ; # A0
OP_CLR   = 164 ; # A4
OP_HLT   = 168 ; # A8
OP_INT   = 172 ; # AC
OP_TST   = 177 ; # B1
OP_MOVI  = 181 ; # B5
OP_MOV   = 182 ; # B6
OP_LDRI  = 193 ; # C1
OP_LDR   = 194 ; # C2
OP_STRI  = 197 ; # C5
OP_STR   = 198 ; # C6
OP_LDRBI = 201 ; # C9
OP_LDRB  = 202 ; # CA
OP_STRBI = 205 ; # CD
OP_STRB  = 206 ; # CE
OP_LDA   = 210 ; # D2
OP_STA   = 214 ; # D6
OP_LDAB  = 218 ; # DA
OP_STAB  = 222 ; # DE
OP_ANDI  = 226 ; # E2
OP_AND   = 227 ; # E3
OP_ORI   = 230 ; # E6
OP_OR    = 231 ; # E7
OP_XORI  = 234 ; # EA
OP_XOR   = 235 ; # EB
OP_LSLI  = 237 ; # ED
OP_LSL   = 238 ; # EE
OP_LSRI  = 241 ; # F1
OP_LSR   = 242 ; # F2
OP_ASLI  = 245 ; # F5
OP_ASL   = 246 ; # F6
OP_ASRI  = 249 ; # F9
OP_ASR   = 250 ; # FA
OP_NOTI  = 253 ; # FD
OP_NOT   = 254 ; # FE

predef_constants = {
	"I_FLAG_BIT": 4,
	"N_FLAG_BIT": 3,
	"V_FLAG_BIT": 1,
	"C_FLAG_BIT": 2,
	"Z_FLAG_BIT": 0,
	"I_FLAG": 16,
	"N_FLAG": 8,
	"V_FLAG": 2,
	"C_FLAG": 4,
	"Z_FLAG": 1,

	"IRQ_UART_RX": 128,
	"IRQ_BUTTON4": 16,
	"IRQ_KEYBOARD": 256,
	"IRQ_SD_CARD": 512,
	"IRQ_BUTTON5": 32,
	"IRQ_BUTTON1": 2,
	"IRQ_BUTTON3": 8,
	"IRQ_BUTTON0": 1,
	"IRQ_BUTTON2": 4,
	"IRQ_VBLANK": 64,
	"PORT_PS2_TX_DATA" : 32,
	"PORT_UART_RX_DATA" : 12,
	"PORT_SD_ADDRESS" : 22,
	"PORT_BUTTONS" : 7,
	"PORT_SD_RX_DATA" : 23,
	"PORT_SD_COMMAND" : 21,
	"PORT_IRQ_MASK" : 2,
	"PORT_SD_FLAGS" : 20,
	"PORT_UART_FLAGS" : 10,
	"PORT_PS2_RX_DATA" : 31,
	"PORT_UART_TX_DATA" : 11,
	"PORT_IRQ_CLEAR" : 1,
	"PORT_LED" : 5,
	"PORT_SEVEN_SEG" : 6,
	"PORT_IRQ_READY" : 3,
	"PORT_STATUS_REG" : 0,
	"PORT_SWITCHES" : 8,
	"PORT_PS2_FLAGS" : 30,
}