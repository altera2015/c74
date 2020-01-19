-- C74.000
--
-- ALU
-- 
-- Copyright (c) 2019 Ron Bessems

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- f(1) => 1 = add, 0 = subtract
-- f(0) => 1 = use carry, 0 do not use carry

-- f(2) => 1 = mult

entity alu is
    port ( clk : in  std_logic;
           reset : in  std_logic;
           op1 : in  std_logic_vector (31 downto 0);
           op2 : in  std_logic_vector (31 downto 0);
           result : out  std_logic_vector (31 downto 0);
           c_in : in  std_logic;
           c : out  std_logic;
           n : out  std_logic;
           v : out  std_logic;
           z : out  std_logic;
           f : in  std_logic_vector (1 downto 0));
end alu;

architecture Behavioral of alu is

    COMPONENT alu_adder
      PORT (
        a : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        b : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        clk : IN STD_LOGIC;
        add : IN STD_LOGIC;
        c_in : IN STD_LOGIC;
        ce : IN STD_LOGIC;
        c_out : OUT STD_LOGIC;
        s : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
      );
    END COMPONENT;    
    
    signal gated_carry : std_logic;
    signal res : STD_LOGIC_VECTOR(31 DOWNTO 0);
    
begin
    
    gated_carry <= c_in and f(0);        
    alu_adder0 : alu_adder
        PORT MAP (
            a => op1,
            b => op2,
            clk => clk,
            add => f(1),
            c_in => gated_carry,
            ce => '1',
            c_out => c,
            s => res
        );

    result <= res;
    
    z <= '1' when res = "00000000000000000000000000000000" else '0';
    n <= res(0);
    v <= f(1) when op1(31) /= res(31) and op1(31) = op2(31) else not f(1);
        
end Behavioral;

