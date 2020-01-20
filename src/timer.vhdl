-- C74.000
--
-- 32 bit Timer
-- 
-- Copyright (c) 2020 Ron Bessems

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity timer is
    port (
        clk : in std_logic;
        reset : in std_logic;
        
        top : in std_logic_vector(31 downto 0);
        clr : in std_logic;
        en  : in std_logic;
        
        q   : out std_logic_vector(31 downto 0);
        irq : out std_logic
        
    );
end timer;

architecture behaviour of timer is

    COMPONENT timer_core
      PORT (
        clk : IN STD_LOGIC;
        ce : IN STD_LOGIC;
        sclr : IN STD_LOGIC;
        q : OUT STD_LOGIC_VECTOR(39 DOWNTO 0)
      );
    END COMPONENT;

    signal cntr : std_logic_vector(39 downto 0);   
    
begin
    
    q <= cntr(39 downto 8);
    
    tcore0 : timer_core
      PORT MAP (
        clk => clk,
        ce => en,
        sclr => clr,
        q => cntr
      );  
    
    process(clk)
    begin
        if rising_edge(clk) then
            irq <= '0';
            if reset = '1' then                                
            else                                                
                if cntr(39 downto 8) = top then
                    irq <= '1';
                end if;                    
            end if; -- reset    
       end if;
    end process;
    


end behaviour;

