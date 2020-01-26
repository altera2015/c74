import operator
import pystache

# ISA Code generator
# Generate VHDL and Python definitions for the C74.000 ISA

# Code groups

# GRP Descr.  Full
# 000 Misc    N
# 011 Jump    Y
# 100 ALU     N
# 101 Flags   N
# 110 Memory  N
# 111 Boolean N

op_groups = {
    "MISC": 0,
    "UNSD1": 1,
    "UNSD2": 2,
    "JMP": 3,
    "ALU": 4,
    "FLGS": 5,
    "MEM": 6,
    "BOOL": 7
}

def generate_group_defs():
    for g in op_groups:
        globals()[g] = "{0:03b}".format(op_groups[g])
       
generate_group_defs()

op_codes = {}

instruction_defs = []

STATUS_FLAGS = {
    "Z_FLAG" : 0,
    "V_FLAG" : 1,
    "C_FLAG" : 2,
    "N_FLAG" : 3,
    "I_FLAG" : 4,
}

IRQ_PORTS = {
    "IRQ_BUTTON0": 1,   #0
    "IRQ_BUTTON1": 2,   #1
    "IRQ_BUTTON2": 4,   #2
    "IRQ_BUTTON3": 8,   #3
    "IRQ_BUTTON4": 16,  #4
    "IRQ_BUTTON5": 32,  #5
    "IRQ_INT6": 64,     #6
    "IRQ_UART_RX": 128, #7
    "IRQ_KEYBOARD": 256,#8
    "IRQ_SD_CARD": 512,  #9,
    "IRQ_TIMER1": 1024, #10
    "IRQ_TIMER2": 2048
}

PORT_DEFINITIONS = {
    "PORT_STATUS_REG": 0,
    "PORT_IRQ_CLEAR": 1,
    "PORT_IRQ_MASK": 2,
    "PORT_IRQ_READY": 3,
    
    "PORT_LED": 5,
    "PORT_SEVEN_SEG": 6,
    "PORT_BUTTONS": 7,
    "PORT_SWITCHES": 8,
    
    "PORT_UART_FLAGS": 10,
    "PORT_UART_TX_DATA": 11,    
    "PORT_UART_RX_DATA": 12,
    
    "PORT_SD_FLAGS": 20,    
    "PORT_SD_COMMAND": 21,    
    "PORT_SD_ADDRESS": 22, 
    "PORT_SD_RX_DATA": 23, 
    
    "PORT_PS2_FLAGS": 30,
    "PORT_PS2_RX_DATA": 31,
    "PORT_PS2_TX_DATA": 32,
    
    "PORT_TIMER1_TOP": 40,
    "PORT_TIMER1_VALUE": 41,
    "PORT_TIMER1_RESTART": 42,
    "PORT_TIMER1_ENABLED": 43,
    
    "PORT_TIMER2_TOP": 50,
    "PORT_TIMER2_VALUE": 51,
    "PORT_TIMER2_RESTART": 52,
    "PORT_TIMER2_ENABLED": 53,
}



DEBUG_CMDS = {
    
    # Unsollicited:    
    "HALTED"  : 0x10, # sent when CPU halts
    "RUNNING" : 0x11, # Running.


    # Commands / Responses
    "STATUS"  : 0x12,   # Status Request answers with HALTED/RUNNING + 4 bytes CPUID
    "HALT"    : 0x13,    # HALTED / NAK
    "CONTINUE": 0x14,  # ACK / NAK
    "STEP"    : 0x15,    # ACK / NAK
    "RESET"   : 0x16,    # ACK / NAK Reset CPU Only.
    
        
    "GET_CPU_FLAGS": 0x2f,
    "GET_REG_0": 0x30, # ACK / NAK & 4 bytes MSB first
    "GET_REG_1": 0x31, 
    "GET_REG_2": 0x32,
    "GET_REG_3": 0x33,
    "GET_REG_4": 0x34,
    "GET_REG_5": 0x35,
    "GET_REG_6": 0x36,
    "GET_REG_7": 0x37,
    "GET_REG_8": 0x38,
    "GET_REG_9": 0x39,
    "GET_REG_10": 0x3A,
    "GET_REG_11": 0x3B,
    "GET_REG_12": 0x3C,
    "GET_REG_13": 0x3D,
    "GET_REG_14": 0x3E,
    "GET_REG_15": 0x3F,
    "GET_MEM":    0x40,   # + 4 byte address MSB. ACK & 4 bytes MSB first    
    "SET_MEM": 0x41
    
    # Future?
    # "SET_REG":    
    # "SET_FLAGS":  

}

DEBUG_CONSTANTS = {
    "RUNNING_CPU_ID": 0x43373430, # C740 
    "HALTED_CPU_ID": 0xC3373430 # C740  (MSB bit set)
}




def add_id( mnemonic, cls ):
    
    id = {
        "mnemonic": mnemonic,
        "class": cls,
        "opcode": op_codes[ mnemonic ]         
    }            
    instruction_defs.append(id)    


def generate_op( grp, op, immediate ):
    b = "{0}{1:04b}{2:01b}".format(grp, op, immediate)
    return int(b,2)


################################################
# Misc
################################################

# IMM, OP, REG COUNT
misc_codes = [
    [ "NOP", 0, 0,   "NoOperand" ],    
    [ "OUT", 1, 1,   "InputRegImm" ],
    [ "IN",  1, 2,   "OutputRegInputImm" ],
    [ "CALL", 0, 3,  "InputReg" ],
    [ "CALLI", 1, 3, "InputImm" ],
    [ "RET", 0, 4,   "NoOperand"],
    [ "RETI", 0, 5,  "NoOperand" ],
    [ "PUSH", 0, 6,  "InputReg" ],
    
    [ "POP", 0, 7,   "OutputReg"],
            
    [ "MUL", 0, 8,   "ALU_rr"],
    [ "MULI", 1, 8,  "ALU_ri"],
    [ "SMUL", 0, 9,  "ALU_rr"],
    [ "SMULI", 1, 9, "ALU_ri"]    
    
]

def generate_misc_opcodes():

    for code in misc_codes:        
        op_codes[ code[0] ] = generate_op( MISC, code[2], code[1] )        
        add_id( code[0], code[3])
        

################################################
# ALU
################################################
# ADD R1, R2, R3
# ADDI R1, R2, 321
# SUB R1, R2, R3
# SUBI R1, R2, R3
# ADDC R1, R2, R3
# ADDCI R1, R2, 321
# SUBC R1, R2, R3
# SUBCI R1, R2, R3
# CMP R1, R2
# CMPI R1, 234

alu_codes = [
    [ "ADD", 1, "add[c][i] rA, rB, rC<br>Adds Operand rB to Rc and stores result in rA" ],
    [ "SUB", 0 ]
]


# f => 01 = Add
# f => 00 = SUB

def generate_alu( immediate, f, carry, dont_store_result, mnemonic, cls ):
    
    # GRP      | Short Code          | I-flag    
    # Group    | SR| FFFFFF  | Carry | I 
    # 31 30 29 | 28| 27 | 26 | 25    | 24
    op = int("{0:01b}{1:02b}{2:01b}".format(dont_store_result, f, carry),2)


    id = {
        "mnemonic": mnemonic,
        "class": cls,
        "opcode": op        
    }
        
    instruction_defs.append(id)
        

    return generate_op( ALU, op, immediate)


def generate_alu_opcodes():
    

    op_codes[ "CMP" ] = generate_alu( 0, 0, 0, 1, "CMP", "CMP_rr" )
    op_codes[ "CMPI" ] = generate_alu( 1, 0, 0, 1, "CMPI", "CMP_ri" )

    
    for code in alu_codes:
        op_codes[ code[0] ] = generate_alu( 0, code[1], 0, 0, code[0], "ALU_rr" )
        op_codes[ code[0] + "C" ] = generate_alu( 0, code[1], 1, 0, code[0] + "C", "ALU_rr" )
        op_codes[ code[0] + "I" ] = generate_alu( 1, code[1], 0, 0, code[0] + "I", "ALU_ri" )
        op_codes[ code[0] + "CI" ] = generate_alu( 1, code[1], 1, 0, code[0] + "CI", "ALU_ri" )
        
    

#def generate_alu_doc( dest ):
    #t = open("opcode.template", 'r')
    #template = t.read()
    #t.close()
    
    #doc_codes = {
        #"title": "ALU",
        #"opcodes" : [
            #{
                #"name": "Compare / CMP",
                #"operands": 2,
                #"example": [ "CMP RA, RB", "CMP RA, imm" ],
                #"desc": "Subtracts operand 2 from operand 1 like SUB but discards result, does set flags",
                #"flags": "ZVNC",
            #},
            #{
                #"name": "Addition / ADD",
                #"operands": 3,
                #"example": [ "ADD RA, RB, RC", "ADD RA, RB, imm" ],
                #"desc": "Adds operand 2 to 3 and stores result in first operand",
                #"flags": "ZVNC",
            #},
            #{
                #"name": "Subtraction / SUB",
                #"operands": 3,
                #"example": [ "SUB RA, RB, RC", "SUB RA, RB, imm" ],
                #"desc": "Subtracts operand 3 from operand 2 and stores result in first operand",
                #"flags": "ZVNC",
            #}
        #]
    #}

    
    #html = pystache.render(template, doc_codes)
    
    #f = open(dest + "/alu.html", "w")
    #f.write(html)
    #f.close()
    

################################################
# Flags
################################################

flag_codes = [
    [ "SET", 0, 0, "InputImm" ],
    [ "CLR", 0, 1, "InputImm" ],
    [ "HLT", 0, 2, "NoOperand" ],
    [ "INT", 1, 3, "InputImm" ],
    [ "TST", 1, 4, "InputRegImm" ],
    [ "MOV", 0, 5, "MOV_rr" ],
    [ "MOVI", 1, 5, "MOV_ri" ]
    
]

# 101 group 101X XXRR
def generate_flag_opcodes():
       
    for code in flag_codes:
        
        op_codes[ code[0] ] = generate_op( FLGS, code[2], code[1] )
        add_id( code[0], code[3])

        

################################################
# Jump
################################################

#
# J <imm>
# J <reg>
#  

#001 = EQ
#010 = CS
#011 = NEG
#100 = VS
#101 = HI
#110 = GE
#111 = GT

jump_codes = [    
    [ "J", 0, 0],     
    [ "JEQ", 0, 1],
    [ "JNE", 1, 1],
    [ "JCS", 0, 2],
    [ "JCC", 1, 2],
    [ "JNEG", 0, 3],
    [ "JPOS", 1, 3],
    [ "JVS", 0, 4],
    [ "JVC", 1, 4],
    [ "JHI", 0, 5],
    [ "JLS", 1, 5],
    [ "JGE", 0, 6],
    [ "JLT", 1, 6],
    [ "JGT", 0, 7],
    [ "JLE", 1, 7]
]
#mnemonic




def generate_jump( immediate, invert, condition, mnemonic ):    
    op = int("{0:01b}{1:03b}".format(invert, condition),2)       

    id = {
        "mnemonic": mnemonic,
        "class": "J_reg",
        "opcode": op        
    }
    if immediate == 1:
        id["class"] = "J_imm";
        
    instruction_defs.append(id)
        
    return generate_op(JMP, op, immediate)

def generate_jump_opcodes():
    for code in jump_codes:        
        op_codes[ code[0] + "I" ] = generate_jump( 1, code[1], code[2], code[0] + "I" )
        op_codes[ code[0] ]       = generate_jump( 0, code[1], code[2], code[0] )
        
    
###############################################
# Boolean Operator Codes
###############################################

boolean_codes_binary = [
    
    [ "AND", 0, "ALU_r" ],    
    [ "OR",  1, "ALU_r" ],
    [ "XOR", 2, "ALU_r" ],
    
    [ "LSL", 3, "ALU_r" ],
    [ "LSR", 4, "ALU_r" ],
    [ "ASL", 5, "ALU_r" ],    
    [ "ASR", 6, "ALU_r" ]   
]
boolean_codes_binary2 = [ 
    [ "NOT", 7, "MOV_rr" ]
]



# 101 group 101X XXRR
def generate_boolean_opcodes():       
    for code in boolean_codes_binary:        
        mnemonic = code[0] 
        op_codes[ mnemonic ] = generate_op( BOOL, code[1], 0 )
        add_id(mnemonic, code[2]+'r')
        
        mnemonic = code[0] + "I"
        op_codes[ mnemonic ] = generate_op(BOOL, code[1], 1 )        
        add_id(mnemonic, code[2]+'i')
                

    for code in boolean_codes_binary2:        
        mnemonic = code[0] 
        op_codes[ mnemonic ] = generate_op( BOOL, code[1], 0 )
        add_id(mnemonic, code[2])


###############################################
# Memory Codes
###############################################
# LDR R1, 234
# LDR R1, R2, 4
# STR R1, 234
# STR R1, R2, 4
# LDA R1, R2, 4
# STA R1, R2, 4

memory_codes_I = [    
    [ "LDR", 0, "MEM_r" ],
    [ "STR", 1, "MEM_r" ],
    [ "LDRB", 2, "MEM_r" ],
    [ "STRB", 3, "MEM_r" ]    
]

memory_codes = [    
    [ "LDA", 4, "MEM_rri" ],
    [ "STA", 5, "MEM_rri" ],
    [ "LDAB", 6, "MEM_rri" ],
    [ "STAB", 7, "MEM_rri" ]
]

# 101 group 101X XXRR
def generate_memory_opcodes():
       
    for code in memory_codes_I:        
        op_codes[ code[0] ] = generate_op( MEM, code[1], 0 )
        add_id( code[0], code[2] + "ri")
        
        op_codes[ code[0] + "I" ] = generate_op( MEM, code[1], 1 )
        add_id( code[0] + "I", code[2] + "i")
        
    for code in memory_codes:        
        op_codes[ code[0] ] = generate_op( MEM, code[1], 0 )
        add_id( code[0], code[2])


generate_flag_opcodes()    
generate_jump_opcodes()
generate_alu_opcodes()
generate_memory_opcodes()
generate_boolean_opcodes()
generate_misc_opcodes()

mnemonic_by_op_code = {
}

print("C74 ISA has {} opcodes.".format(len(op_codes)))


print("")
print("SORTED BY Mnemonic")
print("")


for mnemonic in sorted (op_codes.keys()):
    op_code = op_codes[mnemonic]
    print("{0:<5} {1:08b} {1:02X}".format(mnemonic, op_code))
    if op_code in mnemonic_by_op_code:
        print("INVALID DUPLICATE OPCODE GENERATED! {}".format(op_code))
        exit(-1)
    mnemonic_by_op_code[op_code] = mnemonic

print("")
print("SORTED BY OPCODE")
print("")

for op_code in sorted(mnemonic_by_op_code.keys()):
    mnemonic = mnemonic_by_op_code[op_code]
    print("{0:<5} {1:08b} {1:02X}".format(mnemonic, op_code))
          
def write_vhdl(fn):
    f = open(fn, "w")
    f.write("-- Generated by isa.py, do not edit.\n\n")
    f.write("library ieee;\n");
    f.write("use ieee.std_logic_1164.all;\n");
    f.write("use ieee.numeric_std.all;\n\n");
    
    
    f.write("package isa_defs is\n")

    f.write("\n\t-- Op Code Groups\n")    
    for og in sorted(op_groups.items(), key=operator.itemgetter(1)):
        f.write("\tconstant GRP_{0:<4} : std_logic_vector(2 downto 0) := \"{1:03b}\";\n".format(og[0], og[1]))        

    f.write("\n\t-- Op Codes\n")
    for op_code in sorted(mnemonic_by_op_code.keys()):
        mnemonic = mnemonic_by_op_code[op_code]
        f.write("\tconstant OP_{0:<5} : std_logic_vector(7 downto 0) := \"{1:08b}\"; -- 0x{1:02X}\n".format(mnemonic, op_code))    
        
        
    f.write("\n\t-- Short Codes\n")
    for op_code in sorted(mnemonic_by_op_code.keys()):
        mnemonic = mnemonic_by_op_code[op_code]        
        short_code = op_code & 30
        short_code = short_code >> 1
        f.write("\tconstant SC_{0:<5} : std_logic_vector(3 downto 0) := \"{1:04b}\"; -- 0x{1:02X}\n".format(mnemonic, short_code))    
        # 000{1:03b}{0:02b}
        
        
    f.write("\n\t-- Status Register Flags\n")
    
    for flag in sorted(STATUS_FLAGS.items(), key=operator.itemgetter(1)):
        f.write("\tconstant {0}_POS : integer := {1};\n".format(flag[0], flag[1]))


    f.write("\n\t-- IRQ Flags\n")
    
    for flag in sorted(IRQ_PORTS.items(), key=operator.itemgetter(1)):
        f.write("\tconstant {0} : integer := {1};\n".format(flag[0], flag[1]))




    f.write("\n\t-- Port Definitions\n")

    for port in sorted(PORT_DEFINITIONS.items(), key=operator.itemgetter(1)):
        f.write("\tconstant {0:<20} : integer := {1};\n".format(port[0], port[1]))    

    f.write("\n\t-- Debug Port Definitions\n")

    for port in sorted(DEBUG_CMDS.items(), key=operator.itemgetter(1)):
        if port[1]>0x7f:
            print("Debug commands must be less than 0x7f")
            exit(-1)
        f.write("\tconstant DBG_{0:<20} : std_logic_vector(6 downto 0) := \"{1:07b}\"; -- 0x{1:02x}\n".format(port[0], port[1])) 
        

    for port in sorted(DEBUG_CONSTANTS.items(), key=operator.itemgetter(1)):
        f.write("\tconstant DBG_{0:<20} : std_logic_vector(31 downto 0) := \"{1:032b}\"; -- 0x{1:02x}\n".format(port[0], port[1])) 

    
        
    f.write("\nend isa_defs;\n")
    f.close()    

def write_python(fn):
    f = open(fn, "w")
    f.write("# Generated by isa.py, do not edit.\n\n")
    
    
    for op_code in sorted(mnemonic_by_op_code.keys()):
        mnemonic = mnemonic_by_op_code[op_code]
        f.write("OP_{0:<5} = {1:<4}; # {1:02X}\n".format(mnemonic, op_code))    
        
    f.write("\n")
    f.write("predef_constants = {\n")
    #for flag in STATUS_FLAGS:
    #    f.write("\t\"{0}_BIT\": {1},\n".format(flag, STATUS_FLAGS[flag]))    
        
    for flag in STATUS_FLAGS:
        f.write("\t\"{0}\": {1},\n".format(flag, STATUS_FLAGS[flag]))         
    
    f.write("\n");
    for flag in IRQ_PORTS:
        f.write("\t\"{0}\": {1},\n".format(flag, IRQ_PORTS[flag]))         


        
        
    for port in PORT_DEFINITIONS:
        f.write("\t\"{0}\" : {1},\n".format(port, PORT_DEFINITIONS[port]))    
    

    f.write("}\n\n")   
    
    f.write("op_table={\n");
    for op_code in sorted(mnemonic_by_op_code.keys()):
        mnemonic = mnemonic_by_op_code[op_code]
        f.write("\t\"{0}\": {1},\n".format(mnemonic, op_code))     
    f.write("}\n");
    f.close()       



def write_c(fn):
    f = open(fn, "w")
    f.write("// Generated by isa.py, do not edit.\n\n")
    # f.write("#include <stdint.h>\n\n");
    f.write("#ifndef _ISA_DEFS_H_\n");
    f.write("#define _ISA_DEFS_H_\n");
    
    f.write("\n\t// Op Code Groups\n")    
    for og in sorted(op_groups.items(), key=operator.itemgetter(1)):
        f.write("#define GRP_{0:<5} \t\t 0x{1:02X}\n".format(og[0], og[1]))        

    f.write("\n// Op Codes\n")
    for op_code in sorted(mnemonic_by_op_code.keys()):
        mnemonic = mnemonic_by_op_code[op_code]        
        f.write("#define OP_{0:<5} \t\t 0x{1:02X}\n".format(mnemonic, op_code))    
        
        
    f.write("\n// Short Codes\n")
    for op_code in sorted(mnemonic_by_op_code.keys()):
        mnemonic = mnemonic_by_op_code[op_code]        
        short_code = op_code & 30
        short_code = short_code >> 1
        f.write("#define SC_{0:<5} \t\t 0x{1:02X}\n".format(mnemonic, short_code))                    
        
        
    f.write("\n// Status Register Flags\n")
    
    for flag in sorted(STATUS_FLAGS.items(), key=operator.itemgetter(1)):
        f.write("#define {0}_POS \t\t {1}\n".format(flag[0], flag[1]))


    f.write("\n// IRQ Flags\n")
    
    for flag in sorted(IRQ_PORTS.items(), key=operator.itemgetter(1)):
        f.write("#define {0:<20} {1}\n".format(flag[0], flag[1]))

    f.write("\n// Port Definitions\n")

    for port in sorted(PORT_DEFINITIONS.items(), key=operator.itemgetter(1)):
        f.write("#define {0:<20} {1}\n".format(port[0], port[1]))    

    f.write("\n// Debug Port Definitions\n")

    for port in sorted(DEBUG_CMDS.items(), key=operator.itemgetter(1)):
        f.write("#define DBG_{0:<20} 0x{1:02X}\n".format(port[0], port[1])) 

    for port in sorted(DEBUG_CONSTANTS.items(), key=operator.itemgetter(1)):
        f.write("#define DBG_{0:<20} 0x{1:02X}\n".format(port[0], port[1])) 


    f.write("\n#endif\n");
    f.close()    
    

def write_opc_codes(fout):
    #def OPC_LOAD      : C74Opcode<0b0000011>;    
    
    for op_code in sorted(mnemonic_by_op_code.keys()):
        mnemonic = mnemonic_by_op_code[op_code]
        fout.write("def OPC_{0:<5} : C74Opcode<0b{1:08b}>;\n".format(mnemonic, op_code))
        
        

def write_llvm_InstrFormats(targetDir):

    fout = False
    fin = False
    
    target = targetDir + "C74InstrFormats.td"
    source = targetDir + "C74InstrFormats.td.in"
    try:    
        fout = open(target, "w")
    except Exception as e:
        print(e)
        print("Failed to open output file {}".format(target));
        exit(-1)
        
        
    try:
        fin = open(source, "r")        
    except:
        print("Unable to find {}".format(source));
        exit(-1)

    line = fin.readline()
    while line:
        if line.find("{{OPC_CODES}}") != -1:
            write_opc_codes(fout)
        else:
            fout.write(line)
            
        line = fin.readline()
            
    fin.close()        
    fout.close()
    
    
    
def write_instruction_defs(fout):
    #def ADDI  : ALU_ri<0b000, "addi">;
    
    for id in instruction_defs:
        
        fout.write("def {0:<5} : {1}<OPC_{0}, \"{3}\">;\n".format(id["mnemonic"], id["class"], id["opcode"], id["mnemonic"].lower()))
            
    
        
    
def write_llvm_InstrInfo(targetDir):

    fout = False
    fin = False
    
    target = targetDir + "C74InstrInfo.td"
    source = targetDir + "C74InstrInfo.td.in"
    try:    
        fout = open(target, "w")
    except Exception as e:
        print(e)
        print("Failed to open output file {}".format(target));
        exit(-1)
        
        
    try:
        fin = open(source, "r")        
    except:
        print("Unable to find {}".format(source));
        exit(-1)

    line = fin.readline()
    while line:
        if line.find("{{INSTRUCTION_DEFS}}") != -1:
            write_instruction_defs(fout)
        else:
            fout.write(line)
            
        line = fin.readline()
            
    fin.close()        
    fout.close()
    
    
    


write_vhdl("../src/isa_defs.vhdl")
write_python("isa_defs.py")
write_c("../include/isa_defs.h")

td = "/home/ise/devel/llvm/ise/llvm/lib/Target/C74/"
write_llvm_InstrFormats(td)
write_llvm_InstrInfo(td)

#generate_alu_doc(".");

print("C74 ISA has {} opcodes".format(len(mnemonic_by_op_code)))

