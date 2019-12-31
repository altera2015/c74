-- C74.000
--
-- Boolean Arithmetic Unic
--
-- 
-- Copyright (c) 2019 Ron Bessems



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.isa_defs.all;

entity blu is
    port ( clk : in  std_logic;
           reset : in  std_logic;
           f : in  std_logic_vector (2 downto 0);
           op1 : in  std_logic_vector (31 downto 0);
           op2 : in  std_logic_vector (31 downto 0);
           r : out  std_logic_vector (31 downto 0);
           
           repeats_in : in std_logic_vector(4 downto 0);
           repeats_out : out std_logic_vector(4 downto 0)
    );
end blu;

architecture Behavioral of blu is

begin
    
    process(clk)
    begin
        
        if rising_edge(clk) then
        
            repeats_out <= std_logic_vector(unsigned(repeats_in) - 1);
            
            case f is
            when SC_AND =>
                r <= op1 and op2;
            when SC_OR =>
                r <= op1 or op2;
            when SC_XOR =>
                r <= op1 xor op2;
            when SC_NOT =>
                r <= not op1;
            when SC_LSL =>
                r <= std_logic_vector(shift_left( unsigned(op1), 1 )) ;
            when SC_LSR =>
                r <= std_logic_vector(shift_right( unsigned(op1), 1 )) ;
            when SC_ASL =>
                r <= std_logic_vector(shift_left( signed(op1), 1 )) ;
            when SC_ASR =>
                r <= std_logic_vector(shift_right( signed(op1), 1 )) ;
            when others =>
                -- nothing.                 
            end case;
            
        end if;
        
    end process;
             
end Behavioral;

