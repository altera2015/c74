-- C74.000
--
-- 2 FF Clock Domain Sync
-- 
-- Copyright (c) 2020 Ron Bessems

library ieee;
use ieee.std_logic_1164.all;

entity input_sync is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           input : in  STD_LOGIC;
           output : out  STD_LOGIC);
end input_sync;

architecture Behavioral of input_sync is
    signal ff : std_logic_vector(1 downto 0);
begin

    process(clk)        
    begin
    
        if rising_edge(clk) then
        
            if reset = '1' then
                ff <= "00";
            else
                ff <= ff(0) & input;            
            end if;        
        
        end if;
        
    end process;
    
    output <= ff(1);
    
end Behavioral;

