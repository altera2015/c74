-- C74.000
--
-- Control Logic Test Bench
-- 
-- Copyright (c) 2019 Ron Bessems

library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;
 
entity control_logic_tb is
end control_logic_tb;
 
architecture behavior of control_logic_tb is 
 
    -- component declaration for the unit under test (uut)
 
    component control_logic
    port(
        clk : in  std_logic;
        reset : in  std_logic;
        cpu_bus : in  std_logic_vector (31 downto 0);

        pc_inc : out  std_logic;
        pc_output_enable : out  std_logic;
        a_inc : out std_logic;
        a_dec : out std_logic;
        sp_inc : out std_logic;
        sp_dec : out std_logic;
        reg_a: out std_logic_vector(3 downto 0);
        reg_b: out std_logic_vector(3 downto 0);
        reg_c: out std_logic_vector(3 downto 0);

        instr_memory_ready: in std_logic;
        instr_address_load : out  std_logic;
        instr_read_enable : out  std_logic;
        instr_memory_output_enable : out  std_logic
    );
    end component;
    
    component memory_interface
    port(
        clk : in  std_logic;
        reset : in  std_logic;           
        cpu_bus : inout  std_logic_vector (31 downto 0);
        
        -- PORT A
        a_address_load : in std_logic;                                              
        a_ready : out  std_logic;                   
        a_output_enable : in  std_logic;
        a_read_enable: in std_logic;
        a_write_enable: in std_logic_vector(3 downto 0) 
    );
    end component;    
    

	COMPONENT reg_file
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		a_reg_idx : IN std_logic_vector(3 downto 0);
		a_load : IN std_logic;
        a_inc  : IN std_logic;
        a_dec  : IN std_logic;
		a_output_enable : IN std_logic;
		b_reg_idx : IN std_logic_vector(3 downto 0);
		b_load : IN std_logic;
		b_output_enable : IN std_logic;
		c_reg_idx : IN std_logic_vector(3 downto 0);
		c_load : IN std_logic;
		c_output_enable : IN std_logic;
		sp_inc : IN std_logic;
		sp_dec : IN std_logic;
		sp_load : IN std_logic;
		sp_output_enable : IN std_logic;
		pc_inc : IN std_logic;
		pc_load : IN std_logic;
		pc_output_enable : IN std_logic;    
		cpu_bus : INOUT std_logic_vector(31 downto 0);      
		a_value : OUT std_logic_vector(31 downto 0);
		b_value : OUT std_logic_vector(31 downto 0);
		c_value : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;    
    
    

    --Inputs
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal cpu_bus : std_logic_vector(31 downto 0);
        
    signal instr_address_load : std_logic;
    signal instr_read_enable : std_logic;
    signal instr_memory_output_enable : std_logic;
    signal instr_memory_ready : std_logic;

    -- register file
    signal pc_inc : std_logic;
    signal pc_output_enable : std_logic;
    signal a_reg_idx        : std_logic_vector(3 downto 0);    
    signal a_load           : std_logic;
    signal a_output_enable  : std_logic;
    signal b_reg_idx        : std_logic_vector(3 downto 0);    
    signal b_load           : std_logic;
    signal b_output_enable  : std_logic;
    signal c_reg_idx        : std_logic_vector(3 downto 0);    
    signal c_load           : std_logic;
    signal c_output_enable  : std_logic;    
    signal a_inc            : std_logic;
    signal a_dec            : std_logic;
    
    
   -- Clock period definitions
   constant clk_period : time := 10 ns;   
   
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: control_logic PORT MAP (
          clk => clk,
          reset => reset,
          cpu_bus => cpu_bus,
          pc_inc => pc_inc,          
          pc_output_enable => pc_output_enable,
          reg_a => a_reg_idx,
          reg_b => b_reg_idx,
          reg_c => c_reg_idx,
          a_inc => a_inc,
          a_dec => a_dec,
          
          instr_address_load => instr_address_load,
          instr_read_enable => instr_read_enable,
          instr_memory_output_enable => instr_memory_output_enable,
          instr_memory_ready => instr_memory_ready
        );

	-- Instantiate the Unit Under Test (UUT)
   mem_if0: memory_interface PORT MAP (
          clk => clk,
          reset => reset,
          cpu_bus => cpu_bus,
          
          a_address_load => instr_address_load,
          a_write_enable => "0000",                    
          a_output_enable => instr_memory_output_enable,
          a_ready => instr_memory_ready,
          a_read_enable => instr_read_enable
        );


	reg_file0: reg_file PORT MAP(
		clk => clk,
		reset => reset,
		cpu_bus => cpu_bus,
		a_reg_idx => a_reg_idx,
		a_load => a_load,
		a_output_enable => a_output_enable,
        a_inc => a_inc,
        a_dec => a_dec,
		--a_value => ,
		b_reg_idx => b_reg_idx,
		b_load => b_load,
		b_output_enable => b_output_enable,
		--b_value => ,
		c_reg_idx => c_reg_idx,
		c_load => c_load,
		c_output_enable => c_output_enable,
		--c_value => ,
		sp_inc => '0',
		sp_dec => '0',
		sp_load => '0',
		sp_output_enable => '0',
		pc_inc => pc_inc,
		pc_load => '0' ,
		pc_output_enable => pc_output_enable
	);


   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

    cpu_bus <= (others => 'Z' );
               
   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      reset <= '1';
      wait for 100 ns;	
      reset <= '0';

      wait for clk_period*100;

      -- insert stimulus here 

      wait;
   end process;

END;
