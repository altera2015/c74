-- C74.000
--
-- Control Logic
-- 
-- The heart of the CPU controlling the various resources
-- coded as a multi-cycle CPU.
-- 
-- Copyright (c) 2019 Ron Bessems

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_logic is
    port ( 
    
        clk   : in  std_logic;
        reset : in  std_logic;

        -- LPDDR Interface
        lpddr_pA_cmd_en                            : out std_logic;
        lpddr_pA_cmd_instr                         : out std_logic_vector(2 downto 0);
        lpddr_pA_cmd_bl                            : out std_logic_vector(5 downto 0);
        lpddr_pA_cmd_byte_addr                     : out std_logic_vector(29 downto 0);
        lpddr_pA_cmd_empty                         : in std_logic;
        lpddr_pA_cmd_full                          : in std_logic;
        
        lpddr_pA_wr_en                             : out std_logic;
        lpddr_pA_wr_mask                           : out std_logic_vector(3 downto 0);
        lpddr_pA_wr_data                           : out std_logic_vector(31 downto 0);
        lpddr_pA_wr_full                           : in std_logic;
        lpddr_pA_wr_empty                          : in std_logic;
        lpddr_pA_wr_count                          : in std_logic_vector(6 downto 0);
        lpddr_pA_wr_underrun                       : in std_logic;
        lpddr_pA_wr_error                          : in std_logic;
        
        lpddr_pA_rd_en                             : out std_logic;
        lpddr_pA_rd_data                           : in std_logic_vector(31 downto 0);
        lpddr_pA_rd_full                           : in std_logic;
        lpddr_pA_rd_empty                          : in std_logic;
        lpddr_pA_rd_count                          : in std_logic_vector(6 downto 0);
        lpddr_pA_rd_overflow                       : in std_logic;
        lpddr_pA_rd_error                          : in std_logic;

        
        lpddr_pB_cmd_en                            : out std_logic;
        lpddr_pB_cmd_instr                         : out std_logic_vector(2 downto 0);
        lpddr_pB_cmd_bl                            : out std_logic_vector(5 downto 0);
        lpddr_pB_cmd_byte_addr                     : out std_logic_vector(29 downto 0);
        lpddr_pB_cmd_empty                         : in std_logic;
        lpddr_pB_cmd_full                          : in std_logic;
        
        lpddr_pB_wr_en                             : out std_logic;
        lpddr_pB_wr_mask                           : out std_logic_vector(3 downto 0);
        lpddr_pB_wr_data                           : out std_logic_vector(31 downto 0);
        lpddr_pB_wr_full                           : in std_logic;
        lpddr_pB_wr_empty                          : in std_logic;
        lpddr_pB_wr_count                          : in std_logic_vector(6 downto 0);
        lpddr_pB_wr_underrun                       : in std_logic;
        lpddr_pB_wr_error                          : in std_logic;
        
        lpddr_pB_rd_en                             : out std_logic;
        lpddr_pB_rd_data                           : in std_logic_vector(31 downto 0);
        lpddr_pB_rd_full                           : in std_logic;
        lpddr_pB_rd_empty                          : in std_logic;
        lpddr_pB_rd_count                          : in std_logic_vector(6 downto 0);
        lpddr_pB_rd_overflow                       : in std_logic;
        lpddr_pB_rd_error                          : in std_logic;
        
        led : out std_logic_vector(7 downto 0);
        seven_seg : out std_logic_vector( 7 downto 0)
    );
end control_logic;

architecture behavioral of control_logic is


    COMPONENT memory_interface
        PORT(
        clk : in  std_logic;
        reset : in  std_logic;           

        -- PORT_A
        a_address : in std_logic_vector(31 downto 0);
        a_D : in  std_logic_vector(31 downto 0);
        a_RE: in std_logic;
        a_WE: in std_logic_vector(3 downto 0);
        a_ready : out  std_logic;
        a_Q : out std_logic_vector(31 downto 0);

        -- PORT_B
        b_address : in std_logic_vector(31 downto 0);
        b_D : in  std_logic_vector(31 downto 0);
        b_RE: in std_logic;
        b_WE: in std_logic_vector(3 downto 0);
        b_ready : out  std_logic;
        b_Q : out std_logic_vector(31 downto 0);

        -- LPDDR Interface
        lpddr_pA_cmd_en                            : out std_logic;
        lpddr_pA_cmd_instr                         : out std_logic_vector(2 downto 0);
        lpddr_pA_cmd_bl                            : out std_logic_vector(5 downto 0);
        lpddr_pA_cmd_byte_addr                     : out std_logic_vector(29 downto 0);
        lpddr_pA_cmd_empty                         : in std_logic;
        lpddr_pA_cmd_full                          : in std_logic;
        
        lpddr_pA_wr_en                             : out std_logic;
        lpddr_pA_wr_mask                           : out std_logic_vector(3 downto 0);
        lpddr_pA_wr_data                           : out std_logic_vector(31 downto 0);
        lpddr_pA_wr_full                           : in std_logic;
        lpddr_pA_wr_empty                          : in std_logic;
        lpddr_pA_wr_count                          : in std_logic_vector(6 downto 0);
        lpddr_pA_wr_underrun                       : in std_logic;
        lpddr_pA_wr_error                          : in std_logic;
        
        lpddr_pA_rd_en                             : out std_logic;
        lpddr_pA_rd_data                           : in std_logic_vector(31 downto 0);
        lpddr_pA_rd_full                           : in std_logic;
        lpddr_pA_rd_empty                          : in std_logic;
        lpddr_pA_rd_count                          : in std_logic_vector(6 downto 0);
        lpddr_pA_rd_overflow                       : in std_logic;
        lpddr_pA_rd_error                          : in std_logic;       
        lpddr_pB_cmd_en                            : out std_logic;
        lpddr_pB_cmd_instr                         : out std_logic_vector(2 downto 0);
        lpddr_pB_cmd_bl                            : out std_logic_vector(5 downto 0);
        lpddr_pB_cmd_byte_addr                     : out std_logic_vector(29 downto 0);
        lpddr_pB_cmd_empty                         : in std_logic;
        lpddr_pB_cmd_full                          : in std_logic;
        
        lpddr_pB_wr_en                             : out std_logic;
        lpddr_pB_wr_mask                           : out std_logic_vector(3 downto 0);
        lpddr_pB_wr_data                           : out std_logic_vector(31 downto 0);
        lpddr_pB_wr_full                           : in std_logic;
        lpddr_pB_wr_empty                          : in std_logic;
        lpddr_pB_wr_count                          : in std_logic_vector(6 downto 0);
        lpddr_pB_wr_underrun                       : in std_logic;
        lpddr_pB_wr_error                          : in std_logic;
        
        lpddr_pB_rd_en                             : out std_logic;
        lpddr_pB_rd_data                           : in std_logic_vector(31 downto 0);
        lpddr_pB_rd_full                           : in std_logic;
        lpddr_pB_rd_empty                          : in std_logic;
        lpddr_pB_rd_count                          : in std_logic_vector(6 downto 0);
        lpddr_pB_rd_overflow                       : in std_logic;
        lpddr_pB_rd_error                          : in std_logic
        
	);
	END COMPONENT;
    
	COMPONENT reg_file
	PORT(
           clk             : in  std_logic;
           reset           : in  std_logic;
         
           a_reg_idx       : in  std_logic_vector (3 downto 0);
           a_load          : in  std_logic;           
           a_Q             : out std_logic_vector (31 downto 0);
           a_D             : in std_logic_vector (31 downto 0);
           a_inc           : in  std_logic;
           a_dec           : in  std_logic;
           a_op_value      : in  std_logic_vector(15 downto 0);
           
           b_reg_idx       : in  std_logic_vector (3 downto 0);
           b_load          : in  std_logic;
           b_Q             : out std_logic_vector (31 downto 0);
           b_D             : in std_logic_vector (31 downto 0);

           c_reg_idx       : in  std_logic_vector (3 downto 0);
           c_load          : in  std_logic;
           c_Q             : out std_logic_vector (31 downto 0);
           c_D             : in std_logic_vector (31 downto 0);
           
           
           -- idx = 0xe / 14
           sp_inc          : in std_logic;
           sp_dec          : in std_logic;
           sp_load         : in std_logic;
           sp_Q            : out std_logic_vector (31 downto 0);
           sp_D            : in std_logic_vector (31 downto 0);
           -- idx = 0x0f / 15
           pc_inc          : in std_logic;
           pc_load         : in std_logic;
           pc_Q            : out std_logic_vector (31 downto 0);
           pc_D            : in std_logic_vector (31 downto 0)
		);
	END COMPONENT;    
    

    -- Memory Interface
    -- PORT_A
    signal a_address : std_logic_vector(31 downto 0);
    signal a_D : std_logic_vector(31 downto 0);
    signal a_RE: std_logic;
    signal a_WE: std_logic_vector(3 downto 0);
    signal a_ready : std_logic;
    signal a_Q : std_logic_vector(31 downto 0);

    -- PORT_B
    signal b_address : std_logic_vector(31 downto 0);
    signal b_D : std_logic_vector(31 downto 0);
    signal b_RE: std_logic;
    signal b_WE: std_logic_vector(3 downto 0);
    signal b_ready : std_logic;
    signal b_Q : std_logic_vector(31 downto 0);



    -- Register File Signals
    signal a_reg_idx : std_logic_vector (3 downto 0);
    signal a_reg_load : std_logic;           
    signal a_reg_Q : std_logic_vector (31 downto 0);
    signal a_reg_D : std_logic_vector (31 downto 0);
    signal a_reg_inc : std_logic;
    signal a_reg_dec : std_logic;
    signal a_reg_op_value : std_logic_vector(15 downto 0);

    signal b_reg_idx : std_logic_vector (3 downto 0);
    signal b_reg_load : std_logic;
    signal b_reg_Q : std_logic_vector (31 downto 0);
    signal b_reg_D : std_logic_vector (31 downto 0);

    signal c_reg_idx : std_logic_vector (3 downto 0);
    signal c_reg_load : std_logic;
    signal c_reg_Q : std_logic_vector (31 downto 0);
    signal c_reg_D : std_logic_vector (31 downto 0);


    -- idx = 0xe / 14
    signal sp_inc : std_logic;
    signal sp_dec : std_logic;
    signal sp_load : std_logic;
    signal sp_Q : std_logic_vector (31 downto 0);
    signal sp_D : std_logic_vector (31 downto 0);
    -- idx = 0x0f / 15
    signal pc_inc : std_logic;
    signal pc_load : std_logic;
    signal pc_Q : std_logic_vector (31 downto 0);
    signal pc_D : std_logic_vector (31 downto 0);  


    -- Primary Signals
    signal stage : integer range 0 to 7 := 7;
    
    constant OP_NOP  : integer := 0;
    
    constant OP_JI   : integer := 2;
    constant OP_J    : integer := 3;
    constant OP_JEQI : integer := 4;
    constant OP_JEQ  : integer := 5;
    constant OP_JNEI : integer := 6;
    constant OP_JNE  : integer := 7;
    constant OP_JCSI : integer := 8;
    constant OP_JCS  : integer := 9;
    constant OP_JCCI : integer := 10;
    constant OP_JCC  : integer := 11;
    constant OP_JNEGI: integer := 12;
    constant OP_JNEG : integer := 13;
    constant OP_JPOSI: integer := 14;
    constant OP_JPOS : integer := 15;
    constant OP_JVSI : integer := 16;
    constant OP_JVS  : integer := 17;
    constant OP_JVCI : integer := 18;
    constant OP_JVC  : integer := 19;
    constant OP_JHII : integer := 20;
    constant OP_JHI  : integer := 21;
    constant OP_JLSI : integer := 22;
    constant OP_JLS  : integer := 23;
    constant OP_JGEI : integer := 24;
    constant OP_JGE  : integer := 25;
    constant OP_JLTI : integer := 26;
    constant OP_JLT  : integer := 27;
    constant OP_JGTI : integer := 28;
    constant OP_JGT  : integer := 29;
    constant OP_JLEI : integer := 30;
    constant OP_JLE  : integer := 31;
    
    constant OP_SETZ : integer := 32;   -- set zero flag to lowest bit of immediate.
    constant OP_SETC : integer := 33;   -- set carry flag to lowest bit of immediate.
    constant OP_SETN : integer := 34;   -- set negative flag to lowest bit of immediate.
    constant OP_SETO : integer := 35;   -- set negative flag to lowest bit of immediate.

    constant OP_MOVI : integer := 40;
    constant OP_MOV  : integer := 41;
    constant OP_LDRI : integer := 42;
    constant OP_LDR  : integer := 43;
    constant OP_STRI : integer := 44;
    constant OP_STR  : integer := 45;
            
    constant OP_ADDI : integer := 50;
    constant OP_ADD  : integer := 51;    
    constant OP_ADDCI: integer := 52;
    constant OP_ADDC : integer := 53;
    constant OP_SUBI : integer := 54;
    constant OP_SUB  : integer := 55;
    constant OP_SUBCI: integer := 56;
    constant OP_SUBC : integer := 57;
    constant OP_CMPI : integer := 58;
    constant OP_CMP  : integer := 59;
    constant OP_INC  : integer := 60;    
    constant OP_DEC  : integer := 61;    
    
    constant OP_OUT  : integer := 70;
    
    signal zero_flag : std_logic;
    signal carry_flag : std_logic;
    signal negative_flag : std_logic;
    signal overflow_flag : std_logic;
    
    -- Stage Signals
    signal instruction : std_logic_vector(31 downto 0);
    signal imm : std_logic_vector(31 downto 0);
    signal signed_val : signed(31 downto 0);    
    signal opcode : integer range 0 to 255;
    signal alu : std_logic_vector(32 downto 0); -- 33 bits for overflow calc.    
    
    -- Assembler
    --
    -- | 3 3 2 2 2 2 2 2 | 2 2 2 2 1 1 1 1 | 1 1 1 1 1 1 0 0 | 0 0 0 0 0 0 0 0
    -- |-----------------|-----------------|-----------------|----------------
    -- | 1 0 9 8 7 6 5 4 | 3 2 1 0 9 8 7 6 | 5 4 3 2 1 0 9 8 | 7 6 5 4 3 2 1 0
    -- | 3               | 2               | 1               | 0
    -- | 7 6 5 4 3 2 1 0 | 7 6 5 4 3 2 1 0 | 7 6 5 4 3 2 1 0 | 7 6 5 4 3 2 1 0
    -- | OP Code         | REGA   | REG B  | REG C  |                  
    function signed_value(
        instruction : in std_logic_vector(31 downto 0);
        regs : in integer )
        return signed is
        
        variable v1 : signed(19 downto 0);
    begin
        case regs is
        when 0 =>
            return resize(signed(instruction(23 downto 0)), 32);
        when 1 =>
            return resize(signed(instruction(19 downto 0)), 32);
        when 2 =>
            return resize(signed(instruction(15 downto 0)), 32);        
        when 3 =>
            return resize(signed(instruction(7 downto 0)), 32);        
        when others =>
            return "00000000000000000000000000000000";
        end case;
    end;
    
    function immediate(
        instruction : in std_logic_vector(31 downto 0);
        regs : in integer )
        return std_logic_vector is
        
        variable r : std_logic_vector(3 downto 0);
        variable i : std_logic_vector(31 downto 0);
    begin
        case regs is
            when 0 => 
                r := instruction(23 downto 20);
                i := "000000000000" & instruction(19 downto 0);                            
            when 1 => 
                r := instruction(19 downto 16);
                i := "0000000000000000" & instruction(15 downto 0);                            
            when 2 => 
                r := instruction(15 downto 12);
                i := "00000000000000000000" & instruction(11 downto 0);                        
            when 3 => 
                r := instruction(11 downto 8);
                i := "000000000000000000000000" & instruction(7 downto 0);                            
            when others => i := (others=>'0');
        end case;
        
        case r is
            when "0000" => return i;
            when "0001" => return i(1 downto 0) & i(31 downto 2);
            when "0010" => return i(3 downto 0) & i(31 downto 4);
            when "0011" => return i(5 downto 0) & i(31 downto 6);
            when "0100" => return i(7 downto 0) & i(31 downto 8);
            when "0101" => return i(9 downto 0) & i(31 downto 10);                        
            when "0110" => return i(11 downto 0) & i(31 downto 12);
            when "0111" => return i(13 downto 0) & i(31 downto 14);
            when "1000" => return i(15 downto 0) & i(31 downto 16);
            when "1001" => return i(17 downto 0) & i(31 downto 18);
            when "1010" => return i(19 downto 0) & i(31 downto 20);
            when "1011" => return i(21 downto 0) & i(31 downto 22);
            when "1100" => return i(23 downto 0) & i(31 downto 24);
            when "1101" => return i(25 downto 0) & i(31 downto 26);
            when "1110" => return i(27 downto 0) & i(31 downto 28);
            when "1111" => return i(29 downto 0) & i(31 downto 30);
            when others => return i;
        end case;        

    end;
    signal wait_one : std_logic;
begin

    a_address <= pc_Q;
    
    process(clk)
        
    begin
    
        if rising_edge(clk) then
            if reset = '1' then
                stage <= 0;
                zero_flag <= '0';
                carry_flag <= '0';
                negative_flag <= '0';
                
                instruction <= (others=>'0');    
                a_reg_load <= '0';
                b_reg_load <= '0';
                c_reg_load <= '0';
                a_reg_inc <= '0';
                a_reg_dec <= '0';

                sp_inc <= '0';
                pc_inc <= '0';
                sp_load <= '0';
                pc_load <= '0';

                                
                a_RE <= '0';
                a_WE <= "0000";
                b_RE <= '0';
                b_WE <= "0000";         
                led <= "11110000";
                --sp_D <= (others=>'0');
                --pc_D <= (others=>'0');

            else
            

                a_reg_load <= '0';
                b_reg_load <= '0';
                c_reg_load <= '0';
                a_reg_inc <= '0';
                a_reg_dec <= '0';

                sp_inc <= '0';
                pc_inc <= '0';
                sp_load <= '0';
                pc_load <= '0';

                                
                a_RE <= '0';
                a_WE <= "0000";
                b_RE <= '0';
                b_WE <= "0000";

            
                case stage is
                    
                    when 0 =>
                    
                        -- led <= "00000001";
                        -- Fetch Next Instrction
                        a_RE <= '1';
                        instruction <= (others=>'0');
                        stage <= 1;
                        pc_inc <= '1';

                        --wait_one <= '1';
                        
                    when 1 =>             
                        --led <= "00000010";
                        
                        a_RE <= '0';
                        pc_inc <= '0';                        
                        
                        --if wait_one = '1' then
                          --  wait_one <= '0';
                        
                        
                        -- Wait for instruction to arrive
                        -- and decode as needed.
                        if a_ready = '1' then
                            
                            -- op decode!
                            instruction <= a_Q;                            
                            imm <= (others => '0' );
                            a_reg_idx <= a_Q(23 downto 20);
                            b_reg_idx <= a_Q(19 downto 16);
                            c_reg_idx <= a_Q(15 downto 12);
                            stage <= 2;
                            opcode <= to_integer(unsigned(a_Q(31 downto 24)));

                            case to_integer(unsigned(a_Q(31 downto 24))) is
                                when OP_NOP =>
                                    stage <= 0;
                                    
                                when OP_SETZ | OP_SETC | OP_SETN | OP_SETO =>
                                    imm <= immediate(a_Q, 0);
                                    
                                when OP_INC | OP_DEC | OP_MOVI | OP_CMPI | OP_OUT =>
                                    imm <= immediate(a_Q, 1);
                                    
                                when OP_LDR | OP_STR |                                      
                                     OP_ADDI | OP_ADDCI | 
                                     OP_SUBI | OP_SUBCI =>
                                    imm <= immediate(a_Q, 2); 
                                    
                                when OP_JI | OP_JEQI | OP_JNEI | OP_JCSI | OP_JCCI =>
                                    signed_val <= signed_value(a_Q,0);
                                    
                                when OP_LDRI | OP_STRI =>
                                    signed_val <= signed_value(a_Q,1);
                                   
                                when others =>
                                    -- do nothing.
                            end case;
                            
                        end if;
                        
                        
                    when 2 =>
                        --led <= "00000100";
                        stage <= 3;
                        case opcode is
                            when OP_INC =>
                                a_reg_inc <= '1';
                                a_reg_op_value <= imm(15 downto 0);                                
                                
                            when OP_DEC =>
                                a_reg_dec <= '1';
                                a_reg_op_value <= imm(15 downto 0);                                
                                
                            when OP_JI =>
                                pc_D <= std_logic_vector(unsigned(pc_Q) + unsigned(signed_val));
                                pc_load <= '1';
                                stage <= 0; -- done!
                                
                            when OP_J =>
                                pc_D <= a_reg_Q;
                                pc_load <= '1';
                                stage <= 0; -- done!
                                
                            when OP_OUT =>
                                stage <= 0;
                                case to_integer(unsigned(imm)) is
                                when 0 =>
                                    led <= a_reg_Q(7 downto 0);
                                when 1 =>
                                    seven_seg <= a_reg_Q(7 downto 0);
                                when others =>
                                    -- do nothing.
                                end case;
                                          
                                
                            when OP_JEQI =>
                                if zero_flag = '1' then
                                    pc_D <= std_logic_vector(unsigned(pc_Q) + unsigned(signed_val));
                                    pc_load <= '1';
                                end if;
                                stage <= 0; -- done!
                            when OP_JEQ =>
                                if zero_flag = '1' then
                                    pc_D <= a_reg_Q;
                                    pc_load <= '1';
                                end if;
                                stage <= 0; -- done!
                                
                            when OP_JNEI =>
                                if zero_flag = '0' then
                                    pc_D <= std_logic_vector(unsigned(pc_Q) + unsigned(signed_val));
                                    pc_load <= '1';
                                end if;
                                stage <= 0; -- done!
                            when OP_JNE =>
                                if zero_flag = '0' then
                                    pc_D <= a_reg_Q;
                                    pc_load <= '1';
                                end if;
                                stage <= 0; -- done!


                                
                            when OP_MOVI =>
                                a_reg_D <= imm;
                                a_reg_load <= '1';
                                stage <= 0; -- done!
                                
                            when OP_MOV =>
                                a_reg_D <= b_reg_Q;
                                a_reg_load <= '1';
                                
                            when OP_LDRI =>
                                b_RE <= '1';
                                b_address <= std_logic_vector(unsigned(pc_Q) + unsigned(signed_val));
                                
                            when OP_LDR =>
                                b_RE <= '1';
                                b_address <= a_reg_Q;
                                a_reg_op_value <= imm(15 downto 0);
                                a_reg_inc <= '1';
                                
                            when OP_STRI =>
                                b_WE <= "1111";
                                b_address <= std_logic_vector(unsigned(pc_Q) + unsigned(signed_val));
                                b_D <= a_reg_Q;
                                
                            when OP_STR =>
                                b_WE <= "1111";
                                b_address <= a_reg_Q;
                                b_D <= b_reg_Q;                                
                                a_reg_op_value <= imm(15 downto 0);
                                a_reg_inc <= '1';
                                
                            when OP_SETZ =>
                                zero_flag <= imm(0);
                                stage <= 0;
                            when OP_SETc =>
                                carry_flag <= imm(0);
                                stage <= 0;
                            when OP_SETN =>
                                negative_flag <= imm(0);
                                stage <= 0;
                            when OP_SETO =>
                                overflow_flag <= imm(0);
                                stage <= 0;
                                
                            when OP_ADD =>
                                alu <= std_logic_vector(unsigned('0' & b_reg_Q) + unsigned('0' & c_reg_Q));
                                
                            when OP_ADDC =>
                                alu <= std_logic_vector(unsigned('0' & b_reg_Q) + unsigned('0' & c_reg_Q) + ("00000000000000000000000000000000" & carry_flag) );
                                
                            when OP_ADDI =>
                                alu <= std_logic_vector(unsigned('0' & b_reg_Q) + unsigned('0' & imm));
                                
                            when OP_ADDCI =>
                                alu <= std_logic_vector(unsigned('0' & b_reg_Q) + unsigned('0' & imm) + ("00000000000000000000000000000000" & carry_flag));

                            when OP_SUB =>
                                alu <= std_logic_vector(unsigned('0' & b_reg_Q) - unsigned('0' & c_reg_Q));
                                
                            when OP_SUBC =>
                                alu <= std_logic_vector(unsigned('0' & b_reg_Q) - unsigned('0' & c_reg_Q) - ("00000000000000000000000000000000" & carry_flag));
                                
                            when OP_SUBI =>
                                alu <= std_logic_vector(unsigned('0' & b_reg_Q) - unsigned('0' & imm));
                                
                            when OP_SUBCI =>
                                alu <= std_logic_vector(unsigned('0' & b_reg_Q) - unsigned('0' & imm) - ("00000000000000000000000000000000" & carry_flag));
                                
                            when OP_CMPI =>
                                alu <= std_logic_vector(unsigned('0' & a_reg_Q) - unsigned('0' & imm));

                            when OP_CMP =>
                                alu <= std_logic_vector(unsigned('0' & a_reg_Q) - unsigned('0' & b_reg_Q));
                                
                            when others =>
                                -- do nothing.
                        end case;
                            
                    when 3 =>
                        --led <= "00001000";   
                        stage <= 0;                        
                        case opcode is
                        
                            when OP_INC =>
                            
                                if a_reg_Q = "00000000000000000000000000000000" then
                                    zero_flag <= '1';
                                else
                                    zero_flag <= '0';
                                end if;
                                
                            when OP_DEC =>
                            
                                if a_reg_Q = "00000000000000000000000000000000" then
                                    zero_flag <= '1';
                                else
                                    zero_flag <= '0';
                                end if;
                        
                        
                        when OP_LDRI =>
                            if b_READY = '1' then
                                a_reg_D <= b_Q;
                                a_reg_load <= '1';
                            else
                                -- stick around for results.
                                stage <= 3;
                            end if;
                            
                        when OP_LDR =>
                            if b_READY = '1' then
                                b_reg_D <= b_Q;
                                b_reg_load <= '1';
                            else
                                -- stick around for results.
                                stage <= 3;
                            end if;   
                            
                        when OP_STRI | OP_STR =>
                            if b_ready = '0' then
                                stage <= 3; -- stick around a bit.
                            end if; 
                            
                        when OP_ADD | OP_ADDC | OP_ADDI | OP_ADDCI |
                             OP_SUB | OP_SUBC | OP_SUBI | OP_SUBCI =>
                             
                            a_reg_D <= alu(31 downto 0);
                            a_reg_load <= '1';
                            stage <= 0;
                             
                            carry_flag <= alu(32);
                            if alu = "000000000000000000000000000000000" then
                                zero_flag <= '1';
                            else
                                zero_flag <= '0';
                            end if;
                            negative_flag <= alu(31);
                                
                        when OP_CMP | OP_CMPI =>
                             
                            stage <= 0;                             
                            carry_flag <= alu(32);
                            if alu = "000000000000000000000000000000000" then
                                zero_flag <= '1';
                            else
                                zero_flag <= '0';
                            end if;
                            negative_flag <= alu(31);

                        when others =>
                            -- do nothing.
                        end case;
                        
                    when others =>
                        stage <= 0;
                        
                end case;    
                            
            end if;        
        end if;
        
    end process;

    
    memory_interface0: memory_interface PORT MAP(
		clk => clk,
		reset => reset,
		a_address => a_address,
		a_D => a_D,
		a_RE => a_RE,
		a_WE => a_WE,
		a_ready => a_ready,
		a_Q => a_Q,
		b_address => b_address,
		b_D => b_D,
		b_RE => b_RE,
		b_WE => b_WE,
		b_ready => b_ready,
		b_Q => b_Q,
		lpddr_pA_cmd_en => lpddr_pA_cmd_en,
		lpddr_pA_cmd_instr => lpddr_pA_cmd_instr,
		lpddr_pA_cmd_bl => lpddr_pA_cmd_bl,
		lpddr_pA_cmd_byte_addr => lpddr_pA_cmd_byte_addr,
		lpddr_pA_cmd_empty => lpddr_pA_cmd_empty,
		lpddr_pA_cmd_full => lpddr_pA_cmd_full,
		lpddr_pA_wr_en => lpddr_pA_wr_en ,
		lpddr_pA_wr_mask => lpddr_pA_wr_mask,
		lpddr_pA_wr_data => lpddr_pA_wr_data,
		lpddr_pA_wr_full => lpddr_pA_wr_full,
		lpddr_pA_wr_empty => lpddr_pA_wr_empty,
		lpddr_pA_wr_count => lpddr_pA_wr_count,
		lpddr_pA_wr_underrun => lpddr_pA_wr_underrun,
		lpddr_pA_wr_error => lpddr_pA_wr_error,
		lpddr_pA_rd_en => lpddr_pA_rd_en,
		lpddr_pA_rd_data => lpddr_pA_rd_data,
		lpddr_pA_rd_full => lpddr_pA_rd_full,
		lpddr_pA_rd_empty => lpddr_pA_rd_empty,
		lpddr_pA_rd_count => lpddr_pA_rd_count,
		lpddr_pA_rd_overflow => lpddr_pA_rd_overflow,
		lpddr_pA_rd_error => lpddr_pA_rd_error,
		lpddr_pB_cmd_en => lpddr_pB_cmd_en,
		lpddr_pB_cmd_instr => lpddr_pB_cmd_instr,
		lpddr_pB_cmd_bl => lpddr_pB_cmd_bl,
		lpddr_pB_cmd_byte_addr => lpddr_pB_cmd_byte_addr,
		lpddr_pB_cmd_empty => lpddr_pB_cmd_empty,
		lpddr_pB_cmd_full => lpddr_pB_cmd_full,
		lpddr_pB_wr_en => lpddr_pB_wr_en,
		lpddr_pB_wr_mask => lpddr_pB_wr_mask,
		lpddr_pB_wr_data => lpddr_pB_wr_data,
		lpddr_pB_wr_full => lpddr_pB_wr_full,
		lpddr_pB_wr_empty => lpddr_pB_wr_empty,
		lpddr_pB_wr_count => lpddr_pB_wr_count,
		lpddr_pB_wr_underrun => lpddr_pB_wr_underrun,
		lpddr_pB_wr_error => lpddr_pB_wr_error,
		lpddr_pB_rd_en => lpddr_pB_rd_en,
		lpddr_pB_rd_data => lpddr_pB_rd_data,
		lpddr_pB_rd_full => lpddr_pB_rd_full,
		lpddr_pB_rd_empty => lpddr_pB_rd_empty,
		lpddr_pB_rd_count => lpddr_pB_rd_count,
		lpddr_pB_rd_overflow => lpddr_pB_rd_overflow,
		lpddr_pB_rd_error => lpddr_pB_rd_error
	);    
    
    
    reg_file0: reg_file PORT MAP(
		clk => clk,
		reset => reset,
		a_reg_idx => a_reg_idx,
		a_load => a_reg_load,
		a_Q => a_reg_Q,
		a_D => a_reg_D ,
		a_inc => a_reg_inc,
		a_dec => a_reg_dec,
		a_op_value => a_reg_op_value,
		b_reg_idx => b_reg_idx,
		b_load => b_reg_load,
		b_Q => b_reg_Q,
		b_D => b_reg_D,
		c_reg_idx => c_reg_idx,
		c_load => c_reg_load,
		c_Q => c_reg_Q,
		c_D => c_reg_D,
		sp_inc => sp_inc,
		sp_dec => sp_dec,
		sp_load => sp_load,
		sp_Q => sp_Q,
		sp_D => sp_D,
		pc_inc => pc_inc,
		pc_load => pc_load,
		pc_Q => pc_Q,
		pc_D => pc_D
	);    
    

end Behavioral;


 