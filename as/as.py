# C74.000 Assembler
# --details test1.S -c ../src/rom.coe -m ../src/low_mem/low_mem.mif
import sys
import re
import argparse
from datetime import datetime
from isa_defs import *
import shlex
import math
import struct

labels = {}
constants = {}
predefined = {}

for constant in predef_constants:
    predefined[ constant.lower() ] = predef_constants[constant]
               



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

###############################################################################
###############################################################################
#
# Encoding
#
###############################################################################
###############################################################################

RESERVED_LABEL_NAMES = [
    "r0","r1","r2","r3","r4","r5","r6","r7","r8","r9","r10","r11","r12","r13","r14","r15", "sp", "pc"
]

REGISTERS = {
    "r0": 0,
    "r1": 1,
    "r2": 2,
    "r3": 3,
    "r4": 4,
    "r5": 5,
    "r6": 6,
    "r7": 7,
    "r8": 8,
    "r9": 9,
    "r10": 10,
    "r11": 11,
    "r12": 12,
    "r13": 13,
    "r14": 14,
    "r15": 15,
    "sp": 14,
    "pc": 15
}


def parse_address( param, source_line ):
    
    param = param.lower()
    try:
        address = int(param, 0)
        return address
    except:
        if param in labels:
            return labels[param]
        elif param in constants:
            return constants[param]
        elif param in predefined:
            return predefined[param]        
        else:
            d = build_constants(predefined)                        
            d = d + "\n"
            d = d + build_labels(labels)    
            d = d + "\n"            
            d = d + build_constants(constants);                        
            raise Exception("Line {} | ERROR: Could not find label or constant by name {}\n\nAvailable Labels:{}\n".format(source_line, param,d))

def parse_value( param, source_line):

    return parse_address(param, source_line)



def parse_reg(reg, source_line):
    
    if not (reg in REGISTERS):
        raise Exception("Line {} | ERROR: This op requires a register starting with 'r' e.g. r1, r2, r3,...".format(source_line))
        
    r = REGISTERS[reg] # int(reg.strip('r'))
    if r < 0 or r > 15:
        raise Exception("Line {} | ERROR: Available registers 0 through 15".format(source_line))                
    return r



# surely this can be done easier.
def encode_signed(value, bits, source_line):
    o = "{{0:0{0}b}}".format(bits)
    chars = bits // 4
    fo = "{{0:0{0}X}}".format(chars)
    max_val = 2**(bits - 1)
    if value >= max_val or value < - max_val:
        raise Exception("Line {0} | ERROR, Cannot encode {1} in {2} bits as a signed number".format(source_line, value, bits));        

    if value < 0:
        value = (( -1 * value ) - 1)
        encoded =  o.format( value )
        result = ""
        for c in encoded:
            if c == '1':
                result = result + '0'   
            else:
                result = result + '1'
        return fo.format(int(result,2))
    else:

        return fo.format(value)


def encode_value(value, bits, source_line):
    
    if bits == 24:
        assert value <= 0xfffff, "Line {} | INTERNAL ERROR: Larger constants not yet implimented {}".format(source_line, value)        
        return "0{0:05X}".format(value)

    elif bits == 20:
        assert value <= 0xffff,  "Line {} | INTERNAL ERROR: Larger constants not yet implimented {}".format(source_line, value)     
        return "0{0:04X}".format(value)

    elif bits == 16:
        assert value <= 0xfff,  "Line {} | INTERNAL ERROR: Larger constants not yet implimented {}".format(source_line, value)     
        return "0{0:03X}".format(value)

    elif bits == 12:
        assert value <= 0xff,  "Line {} | INTERNAL ERROR: Larger constants not yet implimented {}".format(source_line, value)     
        return "0{0:02X}".format(value)

    else:        
        assert 0==1, "{} ASSEMBLER ERROR: Unsupported bit length {}".format(source_line, bits)

def encode_32(value):
    return "{0:08X}".format(value)



def encode_op( rec, op, reg, arg, pcrelative = False):
    
    args = rec["op"]
    source_line = rec["source"]

    arg_count = 0
    if reg == REG_A:
        arg_count += 1
    elif reg == REG_A_B:
        arg_count += 2
    elif reg == REG_A_PC:
        arg_count += 1
    elif reg == REG_A_B_C:
        arg_count += 3
    elif reg == REG_I_A:
        arg_count += 1
    elif reg == REG_I_A_B:
        arg_count += 2
    
        
    if arg == ARG_SIGNED:
        arg_count += 1
    if arg == ARG_UNSIGNED:
        arg_count += 1
    if arg == ARG_UNSIGNED_OR_LABEL:
        arg_count += 1
    if arg == ARG_32BIT:
        arg_count += 1
    
    if len(args) != arg_count+1: 
        raise Exception("Line: {} | ERROR op {} expects exactly {} parameters, instead got {}:\n{}".format(source_line, args[0], arg_count, len(args)-1, rec["text"]))        
              
    if op > OP_LITERAL:
        cmd = "{0:02X}".format(op)
        bits = 24
    else:
        cmd = ""
        bits = 32
    
    index = 1
    if reg == REG_NONE:
        pass
    elif reg == REG_A:
        bits -= 4
        ra = parse_reg(args[index], source_line)
        index += 1
        cmd += "{0:X}".format( ra )
    elif reg == REG_I_A:
        bits -= 8
        ra = 0
        rb = parse_reg(args[index], source_line)
        index += 1
        cmd += "{0:X}{1:X}".format(ra, rb)        
    elif reg == REG_A_B:
        bits -= 8
        ra = parse_reg(args[index], source_line)
        rb = parse_reg(args[index+1], source_line)
        index += 2
        cmd += "{0:X}{1:X}".format(ra, rb)
    elif reg == REG_A_PC:
        bits -= 8
        ra = parse_reg(args[index], source_line)
        rb = 15
        index += 1
        cmd += "{0:X}{1:X}".format(ra, rb)
    elif reg == REG_I_A_B:
        bits -= 12
        ra = 0
        rb = parse_reg(args[index+0], source_line)
        rc = parse_reg(args[index+1], source_line)
        index += 2
        cmd += "{0:X}{1:X}{2:X}".format(ra, rb, rc)        
    elif reg == REG_A_B_C:
        bits -= 12
        ra = parse_reg(args[index], source_line)
        rb = parse_reg(args[index+1], source_line)
        rc = parse_reg(args[index+2], source_line)
        index += 3
        cmd += "{0:X}{1:X}{2:X}".format(ra, rb, rc)
    else:
        print("Line {} | INTERNAL ERROR Unknown reg parameter given to encode_op {}\n{}".format(source_line, reg, args[0]))
        exit(-1)
        

    if arg == ARG_NONE:
        chars_left = bits // 4
        cmd += "0" * chars_left
    else:
        if arg == ARG_UNSIGNED:
            num = parse_value(args[index], source_line)
            cmd += encode_value(num, bits, source_line)
        elif arg == ARG_UNSIGNED_OR_LABEL:
            num = parse_address(args[index], source_line)
            cmd += encode_value(num, bits, source_line)
        elif arg == ARG_SIGNED:
            
            addr = args[index]
            if addr.startswith("!"):
                pcrelative = False
                addr = int(addr[1:],0)
                num = addr - rec["size"]
            else:
                num = parse_address(addr, source_line)
            if pcrelative:    
                num -= ( rec["pc"] + rec["size"] )
            cmd += encode_signed(num, bits, source_line)
        elif arg == ARG_32BIT:
            num = parse_value(args[index], source_line)
            cmd += encode_32(num)            
        else:            
            print("Line {} | INTERNAL ERROR: Invalid argument option given to encode_op {}\n{}".format(source_line, reg, args[0]))
            exit(-1);
            
        index += 1
    
    if len(cmd) != 8:
        print("{} INTERNAL ERROR: Invalid command length generated {}, rec={}, op={}, regs={}, args={}, pcrelative={}".format(source_line, cmd, args, op, reg, arg, pcrelative))
        exit(-1)

    return cmd




###############################################################################
###############################################################################
#
# Parsing
#
###############################################################################
###############################################################################

baseAddress = 0

def process_op(op, memory):
    
    global baseAddress
    source_line = op[ len(op) - 2 ]
    source_text = op[ len(op) - 1 ]
    op.pop()
    op.pop()
    
    m={                
        "op": op,
        "encode": encode_op,
        "size": 4,
        "source": source_line,
        "text": source_text
    }
    #print(op[0])
    
    first = op[0].lower()
    if first == ".str":        
        
        if len(op)==2:
            str = op[1]
            ba = bytes(str, "ASCII").decode("unicode_escape").encode("ASCII")
            
            l = len(ba)            
            storage_size = int(math.ceil(l / 4.0) * 4)
            
            hexstr = ""
            i = 0
            
            while i < storage_size:
                hexstr = ""
                src_str = ""
                for j in range(4):
                    if i+j < l:
                        c = ba[i+j]
                        src_str += str[i+j]
                    else:
                        c = 0
                    hexstr += "{0:02X}".format(c)
                t = source_text
                if i > 0:
                    t = "# str storage continued"
                m={                
                    "op": op,                        
                    "size": 4,
                    "source": source_line,
                    "text": t,
                    "encoded": hexstr
                }
                memory.append(m) 
                i += 4                                   
                
            
        else:
            print("Line {} | Error, .str expect 1 string".format(source_line));
            exit(-1);
        
        
    elif first in op_defs:
        
        m["args"] = op_defs[first]
        memory.append(m)
        

        
    elif first == ("EXAMPLE"):
        
        # m["args"] = [OP_LITERAL, REG_NONE, ARG_32BIT]
        # memory.append(m)
        print("INTERNAL ERROR")
        exit(-1)
    elif first.startswith(".const"):
        
        constant = op[1].lower()
        
        if constant in constants:            
            print("Line {} | Error, reuse of constant: {}".format(source_line, constant));
            exit(-1);
            
        if constant in labels:
            print("Line {} | Error, this constant was used as a label prior: {}".format(source_line, constant))
            exit(-1)
            
        constants[ constant ] = parse_value(op[2], source_line)    
    elif first.startswith(".mem"):
        if len(op)<2:
            print("Line {} | Missing base address parameter".format(source_line))
            exit(-1)
        baseAddress = int(op[1],0)
    
    elif op[0].startswith(":"):
        
        label = op[0].strip(":").lower()
        
        if label in RESERVED_LABEL_NAMES:
            print("Line {} | Error, {} is a reserved name and cannot be used as a label\n{}".format(source_line,label, source_text))
            exit(-1)
        
        if label in labels:            
            print("Line {} | Error, reuse of label: {}".format(source_line, label));
            exit(-1);
            
        if label in constants:
            print("Line {} | Error, this label was used as a constant prior: {}".format(source_line, label))
            exit(-1)
        
        # this is wrong,...
        labels[label] = len(memory*4) + baseAddress
        op.pop(0)
        if len(op)>0:
            op.append(source_line)
            op.append(source_text)
            process_op(op, memory)

    else:
        print("Line {} | ERROR: Unknown operator {}\n{}".format(source_line, op[0], source_text))
        exit(-1)

def assemble(ops):
    global baseAddress
    
        
    memory = [
        
    ]
    
    for op in ops:
        process_op(op, memory)        

    values = []
    pc = baseAddress
    for m in memory:
        m["pc"] = pc
        if "args" in m:
            list_of_forms = m["args"]
            for form in list_of_forms:
                errors = ""
                ok = False
                try:
                    values.append( m["encode"] (m, *form ) )
                    ok = True
                    break
                except Exception as msg:
                    errors += msg.args[0]
                    
            if not ok:
                print(errors)
                print(m["text"])
                exit(-1)
                
        elif "encode" in m:
            values.append(m["encode"](m))            
        elif "encoded" in m:            
            values.append(m["encoded"])
        
        
        pc = pc + m["size"]

    return values, memory


def load_ops(filename):
    ops = []
    with open(filename) as fp:
        cnt = 1
        line = fp.readline()
        
        
        
        while line:
            
            in_str = False
            cstr = []
            orig = line.rstrip()
            # line = orig.lower()
            line = line.strip('\n')
            args = re.split(',| ',line)
            
            source_args = list(filter(None, args))
            args = []
            
            
            
            for i in range(len(source_args)):
                arg = source_args[i]
                
                if not in_str:
                    
                    if arg.startswith('"'):
                        if arg.endswith('"'):
                            args.append(arg.rstrip("\"").strip("\""))
                        else:
                            in_str = True
                            cstr.append( arg.rstrip("\"") )
                    elif arg.startswith(';') or arg.startswith('#'):                        
                        break;
                    else:
                        args.append(arg)
                    
                else:
                    cstr.append( arg )
                    
                    if arg.endswith('"') and not arg.endswith("\\\""):
                        in_str = False                         
                        cstr = " ".join(cstr)
                        args.append(cstr.strip("\""))

            
            if len(args)>0:
                args.append(cnt)
                args.append(orig)                    
                ops.append(args)

            
            line = fp.readline()
            cnt = cnt + 1

    return ops

###############################################################################
###############################################################################
#
# Output Formatting
#
###############################################################################
###############################################################################

def write_bin(f, values):

    for i in range(len(values)):        
        value = values[i]
        value = int(value,16)
        f.write(struct.pack(">I", value))
        

def build_coe(values, memory, source):
    coe = ""
    coe += "; Zero page ram contents for source file {}\n".format(source)
    coe += "; Assembled {}\n\n".format(datetime.now())

    coe += "memory_initialization_radix = 16;\n"
    coe += "memory_initialization_vector =\n"

    for i in range(len(values)):        
        value = values[i]
        m = memory[i]
        v = int(value,16)
        if i < len(values)-1:
            coe += "{0:08X},\n".format(v)
        else:
            coe += "{0:08X};\n".format(v)
        
    return coe

def build_dump(values, memory, source):
    dump  = "ADDRESS  | MEM      | Source\n"
    dump += "---------+----------+--------------------------\n"
    for i in range(len(values)):        
        value = values[i]
        m = memory[i]
        v = int(value,16)
        dump += "{1:08X} | {0:08X} | {2}\n".format(v, m["pc"], m["text"])

    return dump

def build_labels(labels):
    
    dump  = "Label             | Address\n"
    dump += "------------------+----------------\n"
    for label in sorted(labels.keys()):
        dump += "{0:17} | {1:08X}\n".format(label.upper(), labels[label])
    dump += "\n"
    return dump


def build_constants(constants):
    
    dump  = "Constant          | Value \n"
    dump += "------------------+----------------\n"
    for label in sorted(constants.keys()):
        dump += "{0:17} | {1:X}\n".format(label.upper(), constants[label])
    dump += "\n"
    return dump


###############################################################################
###############################################################################
#
# Entry point
#
###############################################################################
###############################################################################


parser = argparse.ArgumentParser(description='Assemble source file')
parser.add_argument('source', help='Source file to assemble')
parser.add_argument('-c', metavar="coe_file", help='COE output file')
parser.add_argument('-m', metavar="mif_file", help='.mif output file')
parser.add_argument('-b', metavar="bin_file", help="Save Binary File")
parser.add_argument('--details',action='store_true', help="dump details")

args = parser.parse_args()

ops = load_ops(args.source)
values, memory = assemble(ops)

if args.details:
    print("ISA / Predefined Constants\n")
    d = build_constants(predefined)
    print(d)
    print("Project Details\n")
    d = build_labels(labels)    
    print(d)
    if len(constants) > 0:
        d = build_constants(constants);
        print(d)
    d = build_dump(values, memory, "stdout")
    print(d)
    

if args.c:
    try:
        f = open(args.c, "w")
        coe = build_coe(values, memory, args.source)
        f.write(coe)
        f.close()
    except:
        print("Failed to write {}".format(args.c))
        exit(-1)



if args.m:
    try:
        f = open(args.m, "w")
        for value in values:
            v = int(value,16)
            f.write("{0:032b}\n".format(v))
        f.close()
    except:
        print("Failed to write {}".format(args.m))
        exit(-1)

if args.b:
    try:
        f = open(args.b, "bw")
        write_bin(f, values);
        f.close()
    except:
        print("Failed to write {}".format(args.b))
        exit(-1)
    
    
