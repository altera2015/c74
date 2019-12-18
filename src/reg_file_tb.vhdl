-- C74.000
--
-- Registery File Test Bench
-- 
-- Copyright (c) 2019 Ron Bessems

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY reg_file_tb IS
END reg_file_tb;
 
ARCHITECTURE behavior OF reg_file_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT reg_file
    PORT(
         clk             : in  std_logic;
           reset           : in  std_logic;
           cpu_bus         : inout  std_logic_vector (31 downto 0);
                      
           a_reg_idx       : in  std_logic_vector (3 downto 0);
           a_load          : in  std_logic;
           a_output_enable : in  std_logic;
           a_value         : out std_logic_vector (31 downto 0);           
           a_inc           : in  std_logic;
           a_dec           : in  std_logic;
           
           b_reg_idx       : in  std_logic_vector (3 downto 0);
           b_load          : in  std_logic;
           b_output_enable : in  std_logic;
           b_value         : out  std_logic_vector (31 downto 0);

           c_reg_idx       : in  std_logic_vector (3 downto 0);
           c_load          : in  std_logic;
           c_output_enable : in  std_logic;
           c_value         : out  std_logic_vector (31 downto 0);
           
           -- idx = 0xe / 14
           sp_inc          : in std_logic;
           sp_dec          : in std_logic;
           sp_load         : in std_logic;
           sp_output_enable: in std_logic;
           
           -- idx = 0x0f / 15
           pc_inc          : in std_logic;
           pc_load         : in std_logic;
           pc_output_enable: in std_logic
         
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal a_reg_idx : std_logic_vector(3 downto 0) := (others => '0');
   signal a_load : std_logic := '0';
   signal a_inc : std_logic := '0';
   signal a_dec : std_logic := '0';
   signal a_output_enable : std_logic := '0';
   signal b_reg_idx : std_logic_vector(3 downto 0) := (others => '0');
   signal b_load : std_logic := '0';
   signal b_output_enable : std_logic := '0';
   signal c_reg_idx : std_logic_vector(3 downto 0) := (others => '0');
   signal c_load : std_logic := '0';
   signal c_output_enable : std_logic := '0';
   signal pc_inc : std_logic := '0';
   signal pc_load : std_logic := '0';   
   signal pc_output_enable : std_logic := '0';
   signal sp_load : std_logic := '0';
   signal sp_output_enable : std_logic := '0';
   signal sp_inc : std_logic := '0';
   signal sp_dec : std_logic := '0';
	--BiDirs
   signal cpu_bus : std_logic_vector(31 downto 0);

 	--Outputs
   signal a_value : std_logic_vector(31 downto 0);
   signal b_value : std_logic_vector(31 downto 0);
   signal c_value : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: reg_file PORT MAP (
          clk => clk,
          reset => reset,
          cpu_bus => cpu_bus,
          a_reg_idx => a_reg_idx,
          a_load => a_load,
          a_output_enable => a_output_enable,
          a_value => a_value,
          a_inc => a_inc,
          a_dec => a_dec,          
          b_reg_idx => b_reg_idx,
          b_load => b_load,
          b_output_enable => b_output_enable,
          b_value => b_value,
          c_reg_idx => c_reg_idx,
          c_load => c_load,
          c_output_enable => c_output_enable,
          c_value => c_value,
          pc_inc => pc_inc,
          pc_load => pc_load,          
          pc_output_enable => pc_output_enable,
          sp_load => sp_load,
          sp_output_enable => sp_output_enable,
          sp_inc => sp_inc,
          sp_dec => sp_dec
          
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
      a_reg_idx <= "0000";
      b_reg_idx <= "0000";
      c_reg_idx <= "0000";
      -- hold reset state for 100 ns.
      cpu_bus <= (others => 'Z');
      reset <= '1';
      wait for clk_period*10;
      reset <= '0';

      wait for clk_period;
      
      
      -- Test A
      for i in 0 to 15 loop
        a_reg_idx <= std_logic_vector(to_unsigned(i, a_reg_idx'length));

        cpu_bus <= "0000000000000000000000000000" & std_logic_vector(to_unsigned(i, a_reg_idx'length)); 
        -- wait for clk_period;        
        a_load <='1';
        wait for clk_period;
        a_load <= '0';      
        wait for clk_period;
        assert(a_value = cpu_bus) report " a_value is not cpu_bus" severity failure;
        wait for clk_period;
        
      end loop;
      
      cpu_bus <= (others => 'Z');
      
      for i in 0 to 15 loop
        a_reg_idx <= std_logic_vector(to_unsigned(i, a_reg_idx'length));
        a_output_enable <='1';
        a_output_enable <='1';
        wait for clk_period;
        assert(cpu_bus = "0000000000000000000000000000" & std_logic_vector(to_unsigned(i, a_reg_idx'length))) report " a register not reporting correctly: " & integer'image(i) severity failure;
        wait for clk_period;            
        a_output_enable <= '0';
        wait for clk_period;            
      end loop;
        
        
        
      -- Test "B"
      for i in 0 to 15 loop
        b_reg_idx <= std_logic_vector(to_unsigned(i, a_reg_idx'length));

        cpu_bus <= "0000000000000000000000000001" & std_logic_vector(to_unsigned(i, a_reg_idx'length)); 
        wait for clk_period;        
        b_load <='1';
        wait for clk_period;
        b_load <= '0';      
        wait for clk_period;
        assert(b_value = cpu_bus) report " b_value is not cpu_bus" severity failure;
        wait for clk_period;
        
      end loop;
      
      cpu_bus <= (others => 'Z');
      
      for i in 0 to 15 loop
        b_reg_idx <= std_logic_vector(to_unsigned(i, a_reg_idx'length));
        b_output_enable <='1';
        wait for clk_period;
        assert(cpu_bus = "0000000000000000000000000001" & std_logic_vector(to_unsigned(i, a_reg_idx'length))) report " b register not reporting correctly: " & integer'image(i) severity failure;
        wait for clk_period;            
        b_output_enable <= '0';
        wait for clk_period;            
      end loop;        
        
      -- Test "C"
      for i in 0 to 15 loop
        c_reg_idx <= std_logic_vector(to_unsigned(i, a_reg_idx'length));

        cpu_bus <= "0000000000000000000000000010" & std_logic_vector(to_unsigned(i, a_reg_idx'length)); 
        wait for clk_period;        
        c_load <='1';
        wait for clk_period;
        c_load <= '0';      
        wait for clk_period;
        assert(c_value = cpu_bus) report " c_value is not cpu_bus" severity failure;
        wait for clk_period;
        
      end loop;
      
      cpu_bus <= (others => 'Z');
      
      for i in 0 to 15 loop
        c_reg_idx <= std_logic_vector(to_unsigned(i, a_reg_idx'length));
        c_output_enable <='1';
        wait for clk_period;
        assert(cpu_bus = "0000000000000000000000000010" & std_logic_vector(to_unsigned(i, a_reg_idx'length))) report " c register not reporting correctly: " & integer'image(i) severity failure;
        wait for clk_period;            
        c_output_enable <= '0';
        wait for clk_period;            
      end loop;        
                
            

      reset <= '1';
      wait for clk_period;
      reset <= '0';
      
      sp_output_enable <= '1';
      
        sp_inc <= '1';
        wait for clk_period;
        sp_inc <= '0';
        assert(cpu_bus = "00000000000000000000000000000100") report " sp not incrementing correctly." severity failure;        
        sp_dec <= '1';
        wait for clk_period;
        sp_dec <= '0';
    
      assert(cpu_bus = "00000000000000000000000000000000") report " sp not decrementing correctly." severity failure;                
      
      wait for clk_period;            
      sp_output_enable <= '0';      
        
        
      wait;
   end process;

END;
