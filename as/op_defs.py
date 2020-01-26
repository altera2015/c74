from isa_defs import *

###############################################################################
###############################################################################
#
# OpCode Table & Encoding Definition
#
###############################################################################
###############################################################################
OP_LITERAL = -1

REG_NONE = 0
REG_A = 1
REG_A_B = 2
REG_A_B_C = 3
REG_A_PC = 4
REG_I_A = 5 #hidden first
REG_I_A_B = 6 #hidden first

ARG_NONE = 0
ARG_UNSIGNED_OR_LABEL = 1
ARG_UNSIGNED = 2
ARG_SIGNED = 3
ARG_32BIT = 4
ARG_STR = 5

op_defs = {
    
    "nop": [[OP_NOP, REG_NONE, ARG_NONE]],
    
    "j":   [[OP_JI, REG_NONE, ARG_SIGNED, True], [OP_J, REG_A, ARG_NONE]],
    "jeq": [[OP_JEQI, REG_NONE, ARG_SIGNED, True]],
    "jne": [[OP_JNEI, REG_NONE, ARG_SIGNED, True], [OP_JNE, REG_A, ARG_NONE]],
    "jcs": [[OP_JCSI, REG_NONE, ARG_SIGNED, True], [OP_JCS, REG_A, ARG_NONE]],
    "jcc": [[OP_JCCI, REG_NONE, ARG_SIGNED, True], [OP_JCC, REG_A, ARG_NONE]],
    "jneg":[[OP_JNEGI, REG_NONE, ARG_SIGNED, True], [OP_JNEG, REG_A, ARG_NONE]],
    "jpos":[[OP_JPOSI, REG_NONE, ARG_SIGNED, True], [OP_JPOS, REG_A, ARG_NONE]],
    "jvs": [[OP_JVSI, REG_NONE, ARG_SIGNED, True], [OP_JVS, REG_A, ARG_NONE]],
    "jvc": [[OP_JVCI, REG_NONE, ARG_SIGNED, True], [OP_JVC, REG_A, ARG_NONE]],
    "jhi": [[OP_JHII, REG_NONE, ARG_SIGNED, True], [OP_JHI, REG_A, ARG_NONE]],
    "jls": [[OP_JLSI, REG_NONE, ARG_SIGNED, True], [OP_JLS, REG_A, ARG_NONE]],
    "jge": [[OP_JGEI, REG_NONE, ARG_SIGNED, True], [OP_JGE, REG_A, ARG_NONE]],
    "jlt": [[OP_JLTI, REG_NONE, ARG_SIGNED, True], [OP_JLT, REG_A, ARG_NONE]],
    "jgt": [[OP_JGTI, REG_NONE, ARG_SIGNED, True], [OP_JGT, REG_A, ARG_NONE]],    
    "jle": [[OP_JLEI, REG_NONE, ARG_SIGNED, True], [OP_JLE, REG_A, ARG_NONE]],
    
    "mov": [[OP_MOV, REG_A_B, ARG_NONE], [OP_MOVI, REG_A, ARG_UNSIGNED]],    
    "ldr": [[OP_LDR, REG_A_B, ARG_SIGNED], [OP_LDRI, REG_A, ARG_SIGNED, True]],
    "str": [[OP_STR, REG_A_B, ARG_SIGNED], [OP_STRI, REG_A, ARG_SIGNED, True]],
    "lda": [[OP_LDA, REG_A_B, ARG_SIGNED]],
    "sta": [[OP_STA, REG_A_B, ARG_SIGNED]],

    "ldrb": [[OP_LDRB, REG_A_B, ARG_SIGNED], [OP_LDRBI, REG_A, ARG_SIGNED, True]],
    "strb": [[OP_STRB, REG_A_B, ARG_SIGNED], [OP_STRBI, REG_A, ARG_SIGNED, True]],
    "ldab": [[OP_LDAB, REG_A_B, ARG_SIGNED]],
    "stab": [[OP_STAB, REG_A_B, ARG_SIGNED]],

    
    "set":[[OP_SET, REG_NONE, ARG_UNSIGNED]],
    "clr":[[OP_CLR, REG_NONE, ARG_UNSIGNED]],
    "hlt": [[OP_HLT, REG_NONE, ARG_NONE]],
    "int": [[OP_INT, REG_NONE, ARG_UNSIGNED]],
    "tst": [[OP_TST, REG_A, ARG_UNSIGNED]],
        
    
    "add": [[OP_ADDI, REG_A_B, ARG_UNSIGNED],[OP_ADD, REG_A_B_C, ARG_NONE]],
    "addc":[[OP_ADDCI, REG_A_B, ARG_UNSIGNED],[OP_ADDC, REG_A_B_C, ARG_NONE]],
    "sub": [[OP_SUBI, REG_A_B, ARG_UNSIGNED],[OP_SUB, REG_A_B_C, ARG_NONE]],
    "subc":[[OP_SUBCI, REG_A_B, ARG_UNSIGNED],[OP_SUBC, REG_A_B_C, ARG_NONE]],
    "cmp": [[OP_CMPI, REG_I_A, ARG_UNSIGNED],[OP_CMP, REG_I_A_B, ARG_NONE]],
    "mul": [[OP_MULI, REG_A_B, ARG_UNSIGNED],[OP_MUL, REG_A_B_C, ARG_NONE]],
    "smul": [[OP_SMULI, REG_A_B, ARG_UNSIGNED],[OP_SMUL, REG_A_B_C, ARG_NONE]],

    
    "and": [[OP_ANDI, REG_A_B, ARG_UNSIGNED],[OP_AND, REG_A_B_C, ARG_NONE]],
    "or":  [[OP_ORI, REG_A_B, ARG_UNSIGNED],[OP_OR, REG_A_B_C, ARG_NONE]],
    "xor": [[OP_XORI, REG_A_B, ARG_UNSIGNED],[OP_XOR, REG_A_B_C, ARG_NONE]],
    "not": [[OP_NOTI, REG_A, ARG_UNSIGNED], [OP_NOT, REG_A_B, ARG_NONE]],
    "lsl": [[OP_LSL, REG_A_B, ARG_UNSIGNED]],
    "lsr": [[OP_LSR, REG_A_B, ARG_UNSIGNED]],
    "asl": [[OP_ASL, REG_A_B, ARG_UNSIGNED]],
    "asr": [[OP_ASR, REG_A_B, ARG_UNSIGNED]],
    
    "out": [[OP_OUT, REG_A, ARG_UNSIGNED]],
    "in":  [[OP_IN, REG_A, ARG_UNSIGNED]],
    
    "push": [[OP_PUSH, REG_A, ARG_NONE]],
    "pop": [[OP_POP, REG_A, ARG_NONE]],
    "call": [[OP_CALLI, REG_NONE, ARG_SIGNED, True], [OP_CALL, REG_A, ARG_NONE]],
    "ret": [[OP_RET, REG_NONE, ARG_NONE]],
    "reti": [[OP_RETI, REG_NONE, ARG_NONE]],
    
    
    ".word":[[OP_LITERAL, REG_NONE, ARG_32BIT] ]
}
