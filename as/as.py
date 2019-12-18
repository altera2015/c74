# C74.000 Assembler
import sys
import re

labels = {}


def parse_reg(reg, source_line):
    if not reg.startswith('r'):
        print("{} ERROR: This op requires a register starting with 'r' e.g. r1, r2, r3,...".format(source_line))
        exit(-1)

    r = int(reg.strip('r'))
    if r < 0 or r > 15:
        print("{} ERROR: Available registers 0 through 15".format(source_line))
        exit(-1)
    return r


def encode_value(value, bits, source_line):
    
    if bits == 24:
        assert value <= 0xfffff, "{} ASSEMBLER ERROR: Larger constants not yet implimented {}".format(source_line, value)        
        return "0{0:05X}".format(value)

    elif bits == 20:
        assert value <= 0xffff,  "{} ASSEMBLER ERROR: Larger constants not yet implimented {}".format(source_line, value)     
        return "0{0:04X}".format(value)

    elif bits == 16:
        assert value <= 0xfff,  "{} ASSEMBLER ERROR: Larger constants not yet implimented {}".format(source_line, value)     
        return "0{0:03X}".format(value)

    elif bits == 12:
        assert value <= 0xff,  "{} ASSEMBLER ERROR: Larger constants not yet implimented {}".format(source_line, value)     
        return "0{0:02X}".format(value)

    else:        
        assert 0==1, "{} ASSEMBLER ERROR: Unsupported bit length {}".format(source_line, bits)

    


def parse_address( param, source_line ):
    
    try:
        address = int(param, 0)
        return address
    except:
        if param in labels:
            return labels[param]
        else:
            print("{} ERROR: Could not find label {} at ".format(source_line, param))
            exit(-1)

def parse_value( param, source_line):
    try:
        op_val = int(param, 0)
        return op_val
    except:
        print("{} ERROR: Could not parse value {}".format(source_line, param))
        exit(-1)


def encode_nop(rec):
    return "00000000"

def encode_word(rec):
    args = rec["op"]
    source_line = rec["source"]
    
    if len(args)<2:
        print("{} ERROR: word requires number parameter: .word <value>, got {}".format(source_line, args))
        exit(-1)    
    
    value = parse_value(args[1], source_line)

    return "{0:08X}".format(value)

def encode_inc(rec):
    args = rec["op"]
    source_line = rec["source"]
    
    if len(args)!=3:
        print("{} ERROR: inc requires a register and value parameter: inc r1, 123".format(source_line))
        exit(-1)
    

    op_val = parse_value(args[2], source_line)
    r = parse_reg(args[1], source_line)
    v = encode_value(op_val, 20, source_line)

    return "01{0:X}{1}".format(r, v)

def encode_dec(rec):
    args = rec["op"]
    source_line = rec["source"]
    
    if len(args)!=3:
        print("{} ERROR: dec requires a register and value parameter: inc r1, 123".format(source_line))
        exit(-1)
    
    op_val = parse_value(args[2], source_line)
    r = parse_reg(args[1], source_line)
    v = encode_value(op_val, 20, source_line)
    return "02{0:X}{1}".format(r, v)

def encode_j(rec):
    args = rec["op"]
    source_line = rec["source"]

    if len(args)!=2:
        print("{} ERROR: j requires a register parameter: j 10".format(source_line))
        exit(-1)

    address = parse_address(args[1], source_line)
    return "03{0}".format(encode_value(address,24, source_line))


def encode_movi(rec):
    args = rec["op"]
    source_line = rec["source"]

    if len(args)!=3:
        print("{} ERROR: movi requires two parameters: mov r1, 0x1000".format(source_line))
        exit(-1)

    dest = args[1]    
    dest_reg = parse_reg(dest, source_line)
    src_val = parse_value(args[2], source_line)

    return "06{0:X}{1}".format( dest_reg, encode_value(src_val, 20, source_line))




def encode_mov(rec):
    args = rec["op"]
    source_line = rec["source"]

    if len(args)!=3:
        print("{} ERROR: mov requires two parameters: mov r1, r2".format(source_line))
        exit(-1)

    dest = args[1]
    source = args[2]
    dest_reg = parse_reg(dest, source_line)

    src_reg = parse_reg(source, source_line)
    return "07{0:X}{1:X}0000".format( dest_reg, src_reg)

def encode_ldr_imm(rec, source_line):
    args = rec["op"]
    source_line = rec["source"]

    if len(args)!=3:
        print("{} ERROR: ldr requires three parameters: ldr r1, 0x1000".format(source_line))
        exit(-1)
    
    dest_reg = parse_reg(args[1] , source_line)
    address = parse_address(args[2], source_line)
    
    return "08{0:X}{1}".format( dest_reg, encode_value(address, 20, source_line))

def encode_ldr_reg(rec, source_line):
    args = rec["op"]
    source_line = rec["source"]

    if len(args)!=4:
        print("{} ERROR: ldr requires four parameters: ldr r1, r2, 2".format(source_line))
        exit(-1)
    
    dest_reg = parse_reg(args[1] , source_line)
    base_reg = parse_reg(args[2] , source_line)
    inc_val = parse_value(args[3], source_line)
        
    return "09{0:X}{1:X}{2}".format( base_reg, dest_reg, encode_value(inc_val, 16, source_line))

def encode_ldr(rec):
    args = rec["op"]
    source_line = rec["source"]

    if len(args)==3:
        return encode_ldr_imm(rec, source_line)
    if len(args)==4:
        return encode_ldr_reg(rec, source_line)


def encode_str_imm(rec, source_line):
    args = rec["op"]
    source_line = rec["source"]

    if len(args)!=3:
        print("{} ERROR: str requires three parameters: ldr r1, 0x1000".format(source_line))
        exit(-1)
    
    dest_reg = parse_reg(args[1] , source_line)
    address = parse_address(args[2], source_line)
    
    return "0A{0:X}{1}".format( dest_reg, encode_value(address, 20, source_line))

def encode_str_reg(rec, source_line):
    args = rec["op"]
    source_line = rec["source"]

    if len(args)!=4:
        print("{} ERROR: str requires four parameters: ldr r1, r2, 2".format(source_line))
        exit(-1)
    
    dest_reg = parse_reg(args[1] , source_line)
    base_reg = parse_reg(args[2] , source_line)
    inc_val = parse_value(args[3], source_line)
        
    return "0B{0:X}{1:X}{2}".format( base_reg, dest_reg, encode_value(inc_val, 16, source_line))


def encode_str(rec):
    args = rec["op"]
    source_line = rec["source"]

    if len(args)==3:
        return encode_str_imm(rec, source_line)
    if len(args)==4:
        return encode_str_reg(rec, source_line)


def process_op(op, memory):
    
    source_line = op[ len(op) - 1 ]
    op.pop()

    if op[0] == "nop":
        m = {
            "op": op,
            "encode": encode_nop,
            "size": 4,
            "source": source_line
        }
        memory.append(m)
            

    elif op[0] == "inc":
        m = {
            "op": op,
            "encode": encode_inc,
            "size": 4,
            "source": source_line
        }
        memory.append(m)

    elif op[0] == "dec":
        m = {
            "op": op,
            "encode": encode_dec,
            "size": 4,
            "source": source_line
        }
        memory.append(m)

    elif op[0] == "j":
        m = {
            "op": op,
            "encode": encode_j,
            "size": 4,
            "source": source_line
        }
        memory.append(m)    

    elif op[0] == "movi":
        m = {
            "op": op,
            "encode": encode_movi,
            "size": 4,
            "source": source_line
        }
        memory.append(m)              

    elif op[0] == "mov":
        m = {
            "op": op,
            "encode": encode_mov,
            "size": 4,
            "source": source_line
        }
        memory.append(m)  

    elif op[0] == "ldr":
        m = {
            "op": op,
            "encode": encode_ldr,
            "size": 4,
            "source": source_line
        }
        memory.append(m)  

    elif op[0] == "str":
        m = {
            "op": op,
            "encode": encode_str,
            "size": 4,
            "source": source_line
        }
        memory.append(m)  


    elif op[0] == (".word"):
        m = {
            "op": op,
            "encode": encode_word,
            "size": 4,
            "source": source_line
        }
        memory.append(m)    

    elif op[0].startswith(":"):
        
        label = op[0].strip(":")
        labels[label] = len(memory*4)
        op.pop(0)
        if len(op)>0:
            op.append(source_line)
            process_op(op, memory)

    else:
        print("{} ERROR: Unknown operator *{}*".format(source_line, op[0]))
        exit(-1)

def assemble(ops):

    memory = [
        
    ]
    
    for op in ops:
        process_op(op, memory)
        

    print("******Labels*******")
    print(labels)
    print("******Labels*******")


    values = []
    for m in memory:
        values.append(m["encode"](m))

    return values


def load_ops(filename):
    ops = []
    with open(filename) as fp:
        cnt = 1
        line = fp.readline()
        
        while line:
            
            line = line.lower()
            line = line.strip('\n')
            #args = line.split(' ')
            args = re.split(',| ',line)
            
            args = list(filter(None, args))

            if len(args)>0:                
                if not args[0].startswith('#') or args[0].startswith(';'):
                    args.append(cnt)                    
                    ops.append(args)
                    print(args)
            
            line = fp.readline()
            cnt = cnt + 1

    return ops

if len(sys.argv) < 2:
    print("please specify file to assemble")
    exit(-1)

ops = load_ops(sys.argv[1])
values = assemble(ops)


for value in values:
    v = int(value,16)
    print("{0:08X},".format(v))

for value in values:
    v = int(value,16)
    print("{0:032b}".format(v))


