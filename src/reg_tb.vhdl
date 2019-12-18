-- C74.000
--
-- Register Test Bench
-- 
-- Copyright (c) 2019 Ron Bessems

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 

ENTITY reg_tb IS
END reg_tb;
 
ARCHITECTURE behavior OF reg_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT reg
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         load : IN  std_logic;
         output_enable : IN  std_logic;
         cpu_bus : INOUT  std_logic_vector(31 downto 0);
         value : OUT  std_logic_vector(31 downto 0);
           
         inc           : in std_logic;
         dec           : in std_logic;
         op_value      : in std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal load : std_logic := '0';
   signal output_enable : std_logic := '0';
   signal inc : std_logic := '0';
   signal dec : std_logic := '0';
   signal op_value : std_logic_vector(15 downto 0) := "0000000000000100";

	--BiDirs
   signal cpu_bus : std_logic_vector(31 downto 0);

 	--Outputs
   signal value : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: reg PORT MAP (
          clk => clk,
          reset => reset,
          load => load,
          output_enable => output_enable,
          cpu_bus => cpu_bus,
          value => value,
          inc => inc,
          dec => dec,
          op_value => op_value
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      cpu_bus <= ( others => 'Z');
      reset <= '1';
      wait for 100 ns;	
      reset <= '0';
      
      wait for clk_period*10;

      cpu_bus <= "01010101010101010101010101010101";
      wait for clk_period;
      load <= '1';
      wait for clk_period;
      cpu_bus <= ( others => 'Z');
      load <= '0';
      wait for clk_period;
      output_enable <= '1';
      wait for clk_period;
      
      -- insert stimulus here 
        
      inc <='1';
      wait for clk_period;
      inc <='0';
      output_enable <= '1';
      dec <='1';
      wait for clk_period;
      dec <='0';


      wait;
   end process;

END;
