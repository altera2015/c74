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
use work.isa_defs.all;
use work.types.all;


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
        seven_seg : out std_logic_vector( 7 downto 0);
        
        -- UART Pins.
   		rx_pin : IN std_logic;          
        tx_pin : OUT std_logic;
        
        -- SD Card
        SD_MISO             : in std_logic;
        SD_MOSI             : out std_logic;
        SD_CS               : out std_logic;
        SD_CLK              : out std_logic        

    );
end control_logic;


architecture behavioral of control_logic is
    
	COMPONENT blu
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		f : IN std_logic_vector(2 downto 0);
		op1 : IN std_logic_vector(31 downto 0);
		op2 : IN std_logic_vector(31 downto 0);          
		r : OUT std_logic_vector(31 downto 0);
        repeats_in : in std_logic_vector(4 downto 0);
        repeats_out : out std_logic_vector(4 downto 0)
        
		);
	END COMPONENT;

    COMPONENT adder
      PORT (
        a : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        b : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        clk : IN STD_LOGIC;
        add : IN STD_LOGIC;
        c_in : IN STD_LOGIC;
        ce : IN STD_LOGIC;
        c_out : OUT STD_LOGIC;
        s : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        bypass : in STD_LOGIC
      );
    END COMPONENT;  
    

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
		clk    : IN std_logic;
		reset  : IN std_logic;
		sp_inc : IN std_logic;
		sp_dec : IN std_logic;
		pc_inc : IN std_logic;
        Ds     : in register_array;
        Qs     : out register_array;
        load   : in std_logic_vector(15 downto 0)
		);
	END COMPONENT;

    
	COMPONENT buffered_uart
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		tx_data : IN std_logic_vector(7 downto 0);
		tx_enable : IN std_logic;
		rx_enable : IN std_logic;
		
		tx_full : OUT std_logic;
		tx_busy : OUT std_logic;
		rx_empty : OUT std_logic;
		rx_data : OUT std_logic_vector(7 downto 0);
		rx_pin : IN std_logic;          
        tx_pin : OUT std_logic
		);
	END COMPONENT;
    
	COMPONENT sd_controller
	PORT(
		miso : IN std_logic;
		card_present : IN std_logic;
		card_write_prot : IN std_logic;
		rd : IN std_logic;
		rd_multiple : IN std_logic;
		dout_taken : IN std_logic;
		wr : IN std_logic;
		wr_multiple : IN std_logic;
		din : IN std_logic_vector(7 downto 0);
		din_valid : IN std_logic;
		addr : IN std_logic_vector(31 downto 0);
		erase_count : IN std_logic_vector(7 downto 0);
		reset : IN std_logic;
		clk : IN std_logic;          
		cs : OUT std_logic;
		mosi : OUT std_logic;
		sclk : OUT std_logic;
		dout : OUT std_logic_vector(7 downto 0);
		dout_avail : OUT std_logic;
		din_taken : OUT std_logic;
		sd_error : OUT std_logic;
		sd_busy : OUT std_logic;
		sd_error_code : OUT std_logic_vector(2 downto 0);
		sd_type : OUT std_logic_vector(1 downto 0);
		sd_fsm : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT; 

	COMPONENT alu
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		op1 : IN std_logic_vector(31 downto 0);
		op2 : IN std_logic_vector(31 downto 0);
		c_in : IN std_logic;
		f : IN std_logic_vector(1 downto 0);          
		result : OUT std_logic_vector(31 downto 0);
		c : OUT std_logic;
		v : OUT std_logic;
        n : OUT std_logic;
		z : OUT std_logic
		);
	END COMPONENT;

       
        

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



    -- UART
    signal tx_enable : std_logic;
    signal rx_enable : std_logic;
    signal tx_full : std_logic;
    signal tx_busy : std_logic;
    signal rx_empty : std_logic;
    signal rx_data : std_logic_vector(7 downto 0);
    signal tx_data : std_logic_vector(7 downto 0);    

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
    constant REG_SP : integer := 14;
    constant REG_PC : integer := 15;
    
    signal reg_Qs : register_array;
    signal reg_Ds : register_array;
    signal reg_load : std_logic_vector(15 downto 0);

    signal a_reg_idx : integer range 0 to 15;
    signal b_reg_idx : integer range 0 to 15;
    signal c_reg_idx : integer range 0 to 15;

    -- idx = 0xe / 14
    signal sp_inc : std_logic;
    signal sp_dec : std_logic;    
    
    -- idx = 0x0f / 15
    signal pc_inc : std_logic;

    -- Primary Signals    
    signal status_register : std_logic_vector(31 downto 0);
    
    -- Stage Signals
    signal stage : integer range 0 to 7 := 7;
    signal instruction : std_logic_vector(31 downto 0);
    signal opcode : std_logic_vector(7 downto 0);
    
    signal imm0 : std_logic_vector(31 downto 0);
    signal imm1 : std_logic_vector(31 downto 0);
    signal imm2 : std_logic_vector(31 downto 0);
    signal signed_val0 : signed(31 downto 0);
    signal signed_val1 : signed(31 downto 0);    
    signal signed_val2 : signed(31 downto 0);
    
    
    
    -- Register Input Mux
    signal reg_value : std_logic_vector(31 downto 0);
    signal reg_intermediate_value : std_logic_vector(31 downto 0);
    signal reg_value_mux : std_logic; -- // 0 = ALU, 1 = reg_value.
    
    -- Address Add/Sub logic
    signal data_address_adder_op1 : std_logic_vector(31 downto 0);
    signal data_address_adder_op2 : std_logic_vector(31 downto 0);
    signal data_address_adder_S : std_logic_vector(31 downto 0);
    signal data_address_adder_f : std_logic; -- // 1 = add, 0 = sub
    signal data_address_adder_bypass : std_logic;

    
    -- SD Card Interface
    signal sd_rd : std_logic;
    signal sd_dout : std_logic_vector(7 downto 0);
    signal sd_dout_avail : std_logic;     
    signal sd_dout_taken : std_logic;
    
    signal sd_address : std_logic_vector(31 downto 0);    
    signal sd_busy : std_logic;    
    signal sd_error : std_logic;
    signal sd_error_code : std_logic_vector(2 downto 0);
    signal sd_type : std_logic_vector(1 downto 0);
    
    
    -- ALU
    signal alu_c : std_logic;
    signal alu_v : std_logic;
    signal alu_n : std_logic;
    signal alu_z : std_logic;   
    signal alu_result : std_logic_vector(31 downto 0);
    signal alu_op1 : std_logic_vector(31 downto 0);
    signal alu_op2 : std_logic_vector(31 downto 0);
    signal alu_f : std_logic_vector(1 downto 0);
    
    -- BLU
    signal blu_f : std_logic_vector(2 downto 0);
    signal blu_op1 : std_logic_vector(31 downto 0);
    signal blu_op2 : std_logic_vector(31 downto 0);
    signal blu_r : std_logic_vector(31 downto 0);
    signal blu_repeats_in : std_logic_vector(4 downto 0);    
    signal blu_repeats_out : std_logic_vector(4 downto 0);    
    	
begin

    a_address <= reg_Qs(REG_PC);
    
    process(clk)
        variable jump_use_pc_relative : std_logic;        
        variable va_reg_idx : integer range 0 to 15;
        variable vb_reg_idx : integer range 0 to 15;
        variable vc_reg_idx : integer range 0 to 15;
        variable vopcode : std_logic_vector(7 downto 0);
        variable vimm0 : std_logic_vector(31 downto 0);
        variable vimm1 : std_logic_vector(31 downto 0);
        variable vimm2 : std_logic_vector(31 downto 0);
        variable vsigned_val0 : signed(31 downto 0);
        variable vsigned_val1 : signed(31 downto 0);    
        variable vsigned_val2 : signed(31 downto 0); 
        variable opgroup : std_logic_vector(2 downto 0);
        variable short_code : std_logic_vector(2 downto 0);
        variable register_cnt : integer range 0 to 3;
        variable temp : std_logic;
        variable temp_idx : integer range 0 to 31;
        variable temp_word : std_logic_vector(31 downto 0);
    begin
    
        if rising_edge(clk) then
            if reset = '1' then
                
                
                stage <= 0;
                reg_value_mux<='0';
                
                status_register <= (others=>'0');
                instruction <= (others=>'0');    

                sp_inc <= '0';
                pc_inc <= '0';
                sp_dec <= '0';

                                
                a_RE <= '0';
                a_WE <= "0000";
                b_RE <= '0';
                b_WE <= "0000";         
                led <= "00000000";

                
                sd_rd <= '0';
                sd_dout_taken <= '0';
                opgroup := GRP_MISC;
                
                data_address_adder_f <= '1';
                data_address_adder_op1 <= (others =>'0');
                data_address_adder_op2 <= (others =>'0');
                data_address_adder_bypass <= '0';
            else
                
                data_address_adder_bypass <= '0';
                
                reg_value_mux<='0';
                sp_inc <= '0';
                pc_inc <= '0';
                sp_dec <= '0';
                
                reg_load(0) <= '0';
                reg_load(1) <= '0';
                reg_load(2) <= '0';
                reg_load(3) <= '0';
                reg_load(4) <= '0';
                reg_load(5) <= '0';
                reg_load(6) <= '0';
                reg_load(7) <= '0';
                reg_load(8) <= '0';
                reg_load(9) <= '0';
                reg_load(10) <= '0';
                reg_load(11) <= '0';
                reg_load(12) <= '0';
                reg_load(13) <= '0';
                reg_load(REG_SP) <= '0';
                reg_load(REG_PC) <= '0';                
                                
                a_RE <= '0';
                a_WE <= "0000";
                b_RE <= '0';
                b_WE <= "0000";
                
                sd_dout_taken <= '0';
                tx_enable <= '0';
            
                case stage is
                    
                    -- ***********************************************************************
                    -- STAGE 0
                    -- ***********************************************************************                    
                    when 0 =>

                        a_RE <= '1';
                        instruction <= (others=>'0');
                        stage <= 1;
                        pc_inc <= '1';
                    -- ***********************************************************************
                    -- STAGE 1
                    -- ***********************************************************************                        
                    when 1 =>             
                       
                        -- Wait for instruction to arrive
                        -- and decode as needed.
                        if a_ready = '1' then
                            
                            -- op decode!
                            instruction <= a_Q;                            

                            va_reg_idx := to_integer(unsigned(a_Q(23 downto 20)));
                            vb_reg_idx := to_integer(unsigned(a_Q(19 downto 16)));
                            vc_reg_idx := to_integer(unsigned(a_Q(15 downto 12)));
                            
                            a_reg_idx <= va_reg_idx;
                            b_reg_idx <= vb_reg_idx;
                            c_reg_idx <= vc_reg_idx;
                            
                            stage <= 2;
                            vopcode := a_Q(31 downto 24);
                            opcode <= vopcode;                            
                            
                            vimm0 := immediate(a_Q, 0);
                            vimm1 := immediate(a_Q, 1);
                            vimm2 := immediate(a_Q, 2);                            
                            vsigned_val0 := signed_value(a_Q,0);
                            vsigned_val1 := signed_value(a_Q,1);
                            vsigned_val2 := signed_value(a_Q,2);

                            imm0 <= vimm0;
                            imm1 <= vimm1;
                            imm2 <= vimm2;                            
                            signed_val0 <= vsigned_val0;
                            signed_val1 <= vsigned_val1;
                            signed_val2 <= vsigned_val2;
                            
                            opgroup := a_Q(31 downto 29);
                            short_code := a_Q(28 downto 26);
                            register_cnt := to_integer(unsigned(a_Q(25 downto 24)));
                            
                            
                            
                            case opgroup is

                            when GRP_MISC =>
                            
                                case short_code is
                                when SC_NOP =>
                                    stage <= 0;
                                    
                                when SC_IN =>
                                
                                    alu_f <= "10";
                                    alu_op2 <= "00000000000000000000000000000000";

                                    case to_integer(unsigned(vimm0)) is
                                    when PORT_STATUS_REG =>
                                        alu_op1 <= status_register;    
                                    when PORT_LED =>
                                        -- alu_op1 <= status_register;    
                                        -- LED <= regs_Q(va_reg_idx)(7 downto 0);
                                    when PORT_SEVEN_SEG =>
                                        -- SevenSeg <= regs_Q(va_reg_idx)(7 downto 0);
                                    when others =>
                                        --
                                    end case;
                                    
                                when SC_CALL | SC_PUSH =>
                                
                                    alu_f <= "10";                                    
                                    sp_dec <= '1';
                                                    
                                    data_address_adder_f <= '0';
                                    data_address_adder_op1 <= reg_Qs(REG_SP);
                                    data_address_adder_op2 <= "00000000000000000000000000000100";
                                    
                                    if register_cnt = 1 then
                                        alu_op1 <= reg_Qs(va_reg_idx);
                                        alu_op2 <= "00000000000000000000000000000000";
                                    else                                        
                                        alu_op1 <= reg_Qs(REG_PC);
                                        alu_op2 <= std_logic_vector(vsigned_val0);
                                    end if;

                                when SC_RET | SC_RETI | SC_POP =>
                                    
                                    sp_inc <= '1';
                                    data_address_adder_f <= '0';
                                    data_address_adder_op1 <= reg_Qs(REG_SP);
                                    data_address_adder_op2 <= "00000000000000000000000000000000";                                    
                                    
                                    
                                when others =>
                                
                                end case;
                            
                            -- memory access
                            when GRP_MEM =>
                                case short_code is
                                
                                    when SC_MOV =>
                                        alu_f <= "10";
                                        if register_cnt = 1 then
                                            alu_op1 <= vimm1;
                                            alu_op2 <= "00000000000000000000000000000000";
                                        else                                        
                                            alu_op1 <= reg_Qs(vb_reg_idx);
                                            alu_op2 <= "00000000000000000000000000000000";
                                        end if;
                                        
                                    when SC_LDR | SC_LDA =>
                                    
                                        if register_cnt = 1 then
                                            data_address_adder_f <= '1';
                                            data_address_adder_op1 <= std_logic_vector(vsigned_val1);
                                            data_address_adder_op2 <= reg_Qs(REG_PC);
                                        else
                                            data_address_adder_f <= '1';
                                            data_address_adder_op1 <= std_logic_vector(vsigned_val2);
                                            data_address_adder_op2 <= reg_Qs(vb_reg_idx);
                                        end if;
                                        
                                    when SC_STR | SC_STA =>
                                    
                                        if register_cnt = 1 then
                                            data_address_adder_f <= '1';
                                            data_address_adder_op1 <= std_logic_vector(vsigned_val1);
                                            data_address_adder_op2 <= reg_Qs(REG_PC);
                                        else
                                            data_address_adder_f <= '1';
                                            data_address_adder_op1 <= std_logic_vector(vsigned_val2);
                                            data_address_adder_op2 <= reg_Qs(vb_reg_idx);
                                        end if;                                        

                                    when others =>
                                    

                                end case;
                                
                                if short_code = SC_STA or short_code = SC_LDA then
                                    -- we read from the address before the offset calculation
                                    data_address_adder_bypass <= '1';
                                end if;               

                     
                            -- ALU
                            when GRP_ALU =>
                                
                                alu_f <= a_Q(27 downto 26);                                
                                case register_cnt is
                                when 2 =>
                                    alu_op1 <= reg_Qs(vb_reg_idx);
                                    alu_op2 <= vimm2;
                                when 3 =>
                                    alu_op1 <= reg_Qs(vb_reg_idx);
                                    alu_op2 <= reg_Qs(vc_reg_idx);
                                when others =>
                                    -- nothing.
                                end case;

                            
                            -- Jump groups
                            when GRP_JMP1 | GRP_JMP2 =>
                            
                                alu_f <= "10";
                                case register_cnt is
                                when 0 =>
                                    alu_op1 <= reg_Qs(REG_PC);
                                    alu_op2 <= std_logic_vector(unsigned(vsigned_val0));
                                when 1 =>
                                    alu_op1 <= reg_Qs(vb_reg_idx);
                                    alu_op2 <= "00000000000000000000000000000000";
                                when others =>
                                    -- nothing.
                                end case;
                                
                            -- FLAGS
                            when GRP_FLGS =>
                            
                                case short_code is
                                    when SC_HLT =>
                                        stage <= 1;
                                    when SC_TST =>
                                        temp_idx := to_integer(unsigned(vimm1(4 downto 0)) );
                                        status_register(Z_FLAG_POS) <= reg_Qs(va_reg_idx)( temp_idx );
                                        stage <= 0;
                                        
                                    when others =>
                                        -- nothing.
                                end case;
                                
                                
                            -- BLU
                            when GRP_BOOL =>
                                
                                blu_f <= a_Q(28 downto 26);                                
                                case register_cnt is
                                when 1 =>
                                    blu_op1 <= vimm1;
                                    blu_op2 <= "00000000000000000000000000000000";
                                    blu_repeats_in <= "00001";
                                when 2 =>
                                    blu_op1 <= reg_Qs(vb_reg_idx);
                                    blu_op2 <= vimm2;
                                    blu_repeats_in <= vimm2(4 downto 0);
                                when 3 =>
                                    blu_op1 <= reg_Qs(vb_reg_idx);
                                    blu_op2 <= reg_Qs(vc_reg_idx);
                                    blu_repeats_in <= reg_Qs(vc_reg_idx)(4 downto 0);                                    
                                when others =>
                                    -- nothing.
                                end case;                                
                                
                            when others =>
                             -- nothing.                                
                            end case;

                        end if;
                        
                        
                    -- ***********************************************************************
                    -- STAGE 2
                    -- ***********************************************************************                    
                    when 2 =>
                        stage <= 3;
                        case opgroup is
                        when GRP_MISC =>
                            
                            case short_code is
                            
                                when SC_PUSH =>
                                
                                    b_WE <= "1111";                                    
                                    b_D <= reg_Qs(va_reg_idx);
                                
                                when SC_CALL =>
                                    
                                    b_WE <= "1111";                                    
                                    b_D <= reg_Qs(REG_PC);                                
                                
                                when SC_POP | SC_RET | SC_RETI =>
                                
                                    b_RE <= '1';                                                            
                            
                                when SC_OUT =>

                                    case to_integer(unsigned(vimm0)) is
                                    when PORT_STATUS_REG =>
                                        status_register <= reg_Qs(va_reg_idx);
                                    when PORT_LED =>
                                        LED <= reg_Qs(va_reg_idx)(7 downto 0);
                                    when PORT_SEVEN_SEG =>
                                        seven_seg <= reg_Qs(va_reg_idx)(7 downto 0);
                                    when others =>
                                        --
                                    end case;
                                    
                                when SC_IN =>
                                    stage <= 0;
                                    reg_load(va_reg_idx) <= '1';
                                when others =>
                            end case;
                            
                        -- ALU groups
                        when GRP_ALU =>
                            
                            reg_load(va_reg_idx) <= not instruction(28);
                            
                        -- Flags
                        when GRP_FLGS =>
                            stage <= 0;
                            case short_code is
                                when SC_SET =>
                                    status_register( to_integer(unsigned(imm0(4 downto 0))) ) <= '1';
                                when SC_CLR =>
                                    status_register( to_integer(unsigned(imm0(4 downto 0))) ) <= '0';                                
                                when others =>
                                    -- nothing.
                            end case;
                            
                        -- Jump
                        when GRP_JMP1 | GRP_JMP2 =>
                            stage <= 0;
                            case short_code is
                            when SC_J =>
                                temp := '1';
                            when SC_JEQ =>
                                temp := status_register(Z_FLAG_POS);
                            when SC_JCS =>
                                temp := status_register(C_FLAG_POS);
                            when SC_JNEG =>
                                temp := status_register(N_FLAG_POS);
                            when SC_JVS =>
                                temp := status_register(V_FLAG_POS);
                            when SC_JHI =>                                
                                temp := (status_register(C_FLAG_POS)) and (not status_register(Z_FLAG_POS));
                            when SC_JGE =>                                
                                temp := not (status_register(N_FLAG_POS) xor status_register(V_FLAG_POS));
                            when SC_JGT =>     
                                temp := status_register(Z_FLAG_POS) or ( status_register(N_FLAG_POS)  xor status_register(V_FLAG_POS) );
                            when others =>
                                temp := '0';
                            end case;
                                                        
                            if instruction(29) = '1' then
                                reg_load(REG_PC) <= not temp;
                            else
                                reg_load(REG_PC) <= temp;
                            end if;
                            
                        -- memory access
                        when GRP_MEM =>
                            case short_code is
                            
                                when SC_MOV =>
                                    reg_load(va_reg_idx) <= '1';
                                    stage <= 0;
                                    
                                when SC_STR =>
                                    
                                    b_WE <= "1111";                                    
                                    b_D <= reg_Qs(va_reg_idx);                                
                                
                                when SC_LDR =>
                                
                                    b_RE <= '1'; 

                                when SC_STA =>
                                    
                                    b_WE <= "1111";                                    
                                    b_D <= reg_Qs(va_reg_idx); 
                                    
                                    reg_load(vb_reg_idx) <= '1';
                                    reg_value_mux<='1';
                                    reg_value <= data_address_adder_S;
                                    
                                when SC_LDA =>
                                    
                                    reg_load(vb_reg_idx) <= '1';
                                    reg_value_mux<='1';
                                    reg_value <= data_address_adder_S;
                                    b_RE <= '1'; 
                                    

                                    
                                when others =>
                            end case; 
                            
                        when GRP_BOOL => 
                            -- wait wait...     
                        
                        when others =>
                            -- nothing.
                            
                        end case;
                        
                    -- ***********************************************************************
                    -- STAGE 3
                    -- *********************************************************************** 
                    when 3 =>
                        stage <= 0;
                        case opgroup is
                        
                        when GRP_MISC =>                            
                            case short_code is
                                when SC_POP =>
                                
                                    if b_ready = '0' then                                        
                                        stage <= 3;
                                    else
                                        reg_value_mux<='1';
                                        reg_value <= b_Q;
                                        reg_load(va_reg_idx) <= '1';
                                        stage <= 0;                                        
                                                                            
                                    end if;                                 
                            
                                when SC_PUSH =>
                                
                                    if b_ready = '0' then
                                        stage <= 3;
                                    end if;                            
                                
                                when SC_RET =>
                                
                                    if b_ready = '0' then                                        
                                        stage <= 3;
                                    else
                                        reg_value_mux<='1';
                                        reg_value <= b_Q;
                                        reg_load(REG_PC) <= '1';
                                        stage <= 0;                                     
                                    end if;       
                                
                                
                                when SC_RETI =>
                                
                                    if b_ready = '0' then                                        
                                        stage <= 3;
                                        
                                    else
                                        reg_value_mux<='1';
                                        reg_value <= b_Q;
                                        reg_load(REG_PC) <= '1';
                                        stage <= 0;                                        
                                        status_register(I_FLAG_POS) <= '1';                                        
                                    end if;       
                                    
                                when SC_CALL =>
                                
                                    if b_ready = '0' then
                                        stage <= 3;                                        
                                    else
                                        reg_load(REG_PC) <= '1';
                                    end if;
                                    
                                when others =>
                            end case;                        
                        
                        when GRP_ALU =>
                            
                            status_register(Z_FLAG_POS) <= alu_z;
                            status_register(N_FLAG_POS) <= alu_n;
                            status_register(V_FLAG_POS) <= alu_v;
                            status_register(C_FLAG_POS) <= alu_c;
                            
                        
                        when GRP_MEM =>
                            case short_code is
                            
                                when SC_STR | SC_STA =>
                                    
                                    if b_ready = '0' then
                                        stage <= 3;
                                    end if;                             
                                
                                when SC_LDR | SC_LDA =>
                                
                                    if b_ready = '0' then                                        
                                        stage <= 3;                                        
                                    else
                                        reg_value_mux<='1';
                                        reg_value <= b_Q;
                                        reg_load(va_reg_idx) <= '1';
                                        stage <= 0;                                        
                                    end if;                                      
                                    
                                when others =>
                            end case;
                          
                        
                        when GRP_BOOL =>
                        
                            reg_value_mux<='1';
                            reg_value <= blu_R;
                            reg_load(va_reg_idx) <= '1';
                            
                            case short_code is
                            when SC_LSL | SC_LSR | SC_ASL | SC_ASR =>
                            
                                if blu_repeats_out = "00000" then
                                    stage <= 0; 
                                else
                                    -- we can't do multiple shifts in
                                    -- once go, back up and redo.
                                    blu_repeats_in <= blu_repeats_out;
                                    blu_op1 <= blu_r;
                                    stage <= 2;
                                end if;
                                
                            when others =>
                                stage <= 0;
                            end case;
                            
                        
                        
                        when others =>
                            -- nothing
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
		a_D => (others=>'0'),
		a_RE => a_RE,
		a_WE => "0000",
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
		Qs => reg_Qs,
        Ds => reg_Ds,
        load => reg_load,
		sp_inc => sp_inc,
		sp_dec => sp_dec,		
		pc_inc => pc_inc
	);  
    
    reg_intermediate_value <= reg_value when reg_value_mux = '1' else alu_result;
    
    reg_Ds(0) <= reg_intermediate_value;
    reg_Ds(1) <= reg_intermediate_value;
    reg_Ds(2) <= reg_intermediate_value;
    reg_Ds(3) <= reg_intermediate_value;
    reg_Ds(4) <= reg_intermediate_value;
    reg_Ds(5) <= reg_intermediate_value;
    reg_Ds(6) <= reg_intermediate_value;
    reg_Ds(7) <= reg_intermediate_value;
    reg_Ds(8) <= reg_intermediate_value;
    reg_Ds(9) <= reg_intermediate_value;
    reg_Ds(10) <= reg_intermediate_value;
    reg_Ds(11) <= reg_intermediate_value;
    reg_Ds(12) <= reg_intermediate_value;
    reg_Ds(13) <= reg_intermediate_value;
    reg_Ds(14) <= reg_intermediate_value;
    reg_Ds(15) <= reg_intermediate_value;

	buffered_uart0: buffered_uart PORT MAP(
		clk => clk,
		reset => reset,
		tx_data => tx_data,
		tx_enable => tx_enable,
		tx_full => tx_full,
		tx_busy => tx_busy,		
		rx_empty => rx_empty,
		rx_data => rx_data,
		rx_enable => rx_enable,
		rx_pin => rx_pin,
		tx_pin => tx_pin
	);
      
	sd_controller0: sd_controller 
    PORT MAP(
		cs => SD_CS,
		mosi => SD_MOSI,
		miso => SD_MISO,
		sclk => SD_CLK,
		card_present => '1',
		card_write_prot => '1',
		rd => sd_rd,
		rd_multiple => '0',
		dout => sd_dout,
		dout_avail => sd_dout_avail,
		dout_taken => sd_dout_taken,
		wr => '0',
		wr_multiple => '0',
		din => "00000000",
		din_valid => '0',
		-- din_taken => '0',
		addr => sd_address,
		erase_count => "00000000",
		sd_error => sd_error,
		sd_busy => sd_busy,
		sd_error_code => sd_error_code,
		reset => reset,
		clk => clk,
		sd_type => sd_type

	);
    
    alu0: alu PORT MAP(
		clk => clk,
		reset => reset,
		op1 => alu_op1,
		op2 => alu_op2,
		result => alu_result,
		c_in => status_register(C_FLAG_POS),
		c => alu_c,
        n => alu_n,
		v => alu_v,
		z => alu_z,
		f => alu_f
	);   
    
    b_address <= data_address_adder_S;
    da_adder : adder
        PORT MAP (
            a => data_address_adder_op1,
            b => data_address_adder_op2,
            clk => clk,
            add => data_address_adder_f,
            c_in => '0',
            ce => '1',
            -- c_out => a,
            s => data_address_adder_S,
            bypass => data_address_adder_bypass
        );   


	blu0: blu PORT MAP(
		clk => clk,
		reset => reset,
		f => blu_f,
		op1 => blu_op1,
		op2 => blu_op2,
		r => blu_r,
        repeats_in => blu_repeats_in,
        repeats_out => blu_repeats_out        
	);
    
end Behavioral;


 