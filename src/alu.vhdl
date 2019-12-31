----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:53:13 12/28/2019 
-- Design Name: 
-- Module Name:    alu - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


-- f(1) => 1 = add, 0 = subtract
-- f(0) => 1 = use carry, 0 do not use carry

entity alu is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           op1 : in  STD_LOGIC_VECTOR (31 downto 0);
           op2 : in  STD_LOGIC_VECTOR (31 downto 0);
           result : out  STD_LOGIC_VECTOR (31 downto 0);
           c_in : in  STD_LOGIC;
           c : out  STD_LOGIC;
           n : out  STD_LOGIC;
           v : out  STD_LOGIC;
           z : out  STD_LOGIC;
           f : in  STD_LOGIC_VECTOR (1 downto 0));
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

