-- C74.000
--
-- 32 bit register with inc/dec operations.
-- 
-- Copyright (c) 2019 Ron Bessems


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg is
    port ( clk           : in std_logic;
           reset         : in std_logic;           
           load          : in std_logic;           
           Q             : out std_logic_vector (31 downto 0);
           D             : in std_logic_vector (31 downto 0);
           inc           : in std_logic;
           dec           : in std_logic;
           op_value      : in std_logic_vector(15 downto 0)
    );
end reg;

architecture rtl of reg is
    signal ival : std_logic_vector(31 downto 0);
begin
    
    Q <= ival;
    
    process(clk)
    begin
        if rising_edge(clk) then
        
            if reset = '1' then
                ival <= (others => '0');                
            elsif load = '1' then
                ival <= D;            
            elsif inc = '1' then
                ival <= std_logic_vector(unsigned(ival) + unsigned(op_value));
            elsif dec = '1' then
                ival <= std_logic_vector(unsigned(ival) - unsigned(op_value));
            end if;
        
        end if;
    end process;
  
end rtl;

