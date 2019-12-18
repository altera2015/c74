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
        lpddr_pB_rd_error                          : in std_logic
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
    signal stage : unsigned(2 downto 0) := "111";
    
    
    
begin
    

    
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
    
    
    process(clk)
        variable instruction : std_logic_vector(31 downto 0);
    begin
        if rising_edge(clk) then
            if reset = '1' then
                stage <= "000";
                
                a_reg_idx<= "0000";
                b_reg_idx<= "0000";
                c_reg_idx<= "0000";
                a_reg_load <= '0';
                b_reg_load <= '0';
                c_reg_load <= '0';
                sp_load <= '0';
                pc_load <= '0';
                
                a_reg_D <= (others=>'0');
                b_reg_D <= (others=>'0');
                c_reg_D <= (others=>'0');
                sp_D <= (others=>'0');
                pc_D <= (others=>'0');
                                
                a_RE <= '0';
                a_WE <= "0000";                
                b_RE <= '0';
                b_WE <= "0000";
                
                a_D <= (others=>'0');
                b_D <= (others=>'0');

                
            else
                case stage is
                    
                    when "000" =>
                        -- Fetch Next Instrction
                        a_Address <= pc_Q;
                        a_RE <= '1';
                        stage <= stage + 1;
                        pc_inc <= '1';
                    when "001" =>
                        a_RE <= '0';
                        pc_inc <= '0';
                        -- Wait for instruction to arrive
                        if a_Ready = '1' then
                            instruction := a_Q;
                            stage <= "000";
                        end if;
                        
                    when others =>
                        stage <= "000";
                    
                        
                end case;    
                            
            end if;        
        end if;
        
    end process;
    

end Behavioral;


 