-- C74.000
--
-- Register File
-- 
-- 16 Registers
--
-- 14 General Purpose Registers ( 0 - 13 )
-- 1  Stack Pointer ( 14 )
-- 1  Program Counter ( 15 )
--
-- 3 Configurable value outputs ( a, b & c )
-- Direct Access to SP and PC
-- Atomic increment and decrement (r0-r13 inc/dec = 1, r14 & r15 inc/dec = 4)
-- 
-- 
-- Copyright (c) 2019 Ron Bessems

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg_file is
    port ( clk             : in  std_logic;
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
           
end reg_file;

architecture rtl of reg_file is
    signal load_regs : std_logic_vector(15 downto 0);    
    signal inc_regs : std_logic_vector(15 downto 0);
    signal dec_regs : std_logic_vector(15 downto 0);
    type ValueArray is array( 0 to 15 ) of std_logic_vector(31 downto 0);
    signal Qs : ValueArray;
    signal Ds : ValueArray;
begin
    
    generator_loop: for i in 0 to 15 generate
        
        inc_regs(i) <= '1' when a_inc='1' and to_integer(unsigned(a_reg_idx)) = i else 
                       '1' when sp_inc='1' and i = 14 else
                       '1' when pc_inc='1' and i = 15 else
                       '0';
                       
        dec_regs(i) <= '1' when a_dec='1' and to_integer(unsigned(a_reg_idx)) = i else 
                       '1' when sp_dec='1' and i = 14 else                       
                       '0';

        
        load_regs(i) <= '1' when a_load='1' and to_integer(unsigned(a_reg_idx)) = i else 
                        '1' when b_load='1' and to_integer(unsigned(b_reg_idx)) = i else
                        '1' when c_load='1' and to_integer(unsigned(c_reg_idx)) = i else
                        '1' when sp_load='1' and i = 14 else
                        '1' when pc_load='1' and i = 15 else
                        '0';

--        output_enable_regs(i) <= '1' when a_output_enable='1' and to_integer(unsigned(a_reg_idx)) = i else
--                                 '1' when b_output_enable='1' and to_integer(unsigned(b_reg_idx)) = i else
--                                 '1' when c_output_enable='1' and to_integer(unsigned(c_reg_idx)) = i else
--                                 '1' when sp_output_enable='1' and i = 14 else
--                                 '1' when pc_output_enable='1' and i = 15 else
--                                 '0';


        regs_0_13 : if i < 14 generate
        
            reg_instance : entity work.reg(rtl) port map (
                clk           => clk,
                reset         => reset,            
                load          => load_regs(i),
                q             => qs(i),
                d             => ds(i),
                inc           => inc_regs(i),
                dec           => dec_regs(i),
                op_value      => a_op_value
            );
                  
            Ds(i) <= a_D when to_integer(unsigned(a_reg_idx)) = i else
                     b_D when to_integer(unsigned(b_reg_idx)) = i else
                     c_D when to_integer(unsigned(c_reg_idx)) = i else
                     (others => '0');
                  
         end generate;

        reg_14_15: if i = 14 or i = 15 generate
        
            reg_instance : entity work.reg(rtl) port map (
                clk           => clk,
                reset         => reset,            
                load          => load_regs(i),
                q             => Qs(i),
                d             => Ds(i),
                inc           => inc_regs(i),
                dec           => dec_regs(i),
                op_value      => "0000000000000100"
            );
                    
                                 
        end generate;
    end generate generator_loop;


    Ds(14) <= sp_D when sp_load = '1' else
             a_D when to_integer(unsigned(a_reg_idx)) = 14 else
             b_D when to_integer(unsigned(b_reg_idx)) = 14 else
             c_D when to_integer(unsigned(c_reg_idx)) = 14 else
             (others => '0');    

    Ds(15) <= pc_D when pc_load = '1' else
             a_D when to_integer(unsigned(a_reg_idx)) = 15 else
             b_D when to_integer(unsigned(b_reg_idx)) = 15 else
             c_D when to_integer(unsigned(c_reg_idx)) = 15 else
             (others => '0');    


    sp_Q <= Qs(14);
    pc_Q <= Qs(15);
  

    
    a_Q     <= Qs(0) when a_reg_idx = "0000" else
               Qs(1) when a_reg_idx = "0001" else
               Qs(2) when a_reg_idx = "0010" else
               Qs(3) when a_reg_idx = "0011" else
               Qs(4) when a_reg_idx = "0100" else
               Qs(5) when a_reg_idx = "0101" else
               Qs(6) when a_reg_idx = "0110" else
               Qs(7) when a_reg_idx = "0111" else
               Qs(8) when a_reg_idx = "1000" else
               Qs(9) when a_reg_idx = "1001" else
               Qs(10) when a_reg_idx = "1010" else
               Qs(11) when a_reg_idx = "1011" else
               Qs(12) when a_reg_idx = "1100" else
               Qs(13) when a_reg_idx = "1101" else
               Qs(14) when a_reg_idx = "1110" else
               Qs(15) when a_reg_idx = "1111" else
               (others => 'Z');
               
               
    b_Q     <= Qs(0) when b_reg_idx = "0000" else
               Qs(1) when b_reg_idx = "0001" else
               Qs(2) when b_reg_idx = "0010" else
               Qs(3) when b_reg_idx = "0011" else
               Qs(4) when b_reg_idx = "0100" else
               Qs(5) when b_reg_idx = "0101" else
               Qs(6) when b_reg_idx = "0110" else
               Qs(7) when b_reg_idx = "0111" else
               Qs(8) when b_reg_idx = "1000" else
               Qs(9) when b_reg_idx = "1001" else
               Qs(10) when b_reg_idx = "1010" else
               Qs(11) when b_reg_idx = "1011" else
               Qs(12) when b_reg_idx = "1100" else
               Qs(13) when b_reg_idx = "1101" else
               Qs(14) when b_reg_idx = "1110" else
               Qs(15) when b_reg_idx = "1111" else
               (others => 'Z');
        
               
    c_Q     <= Qs(0) when c_reg_idx = "0000" else
               Qs(1) when c_reg_idx = "0001" else
               Qs(2) when c_reg_idx = "0010" else
               Qs(3) when c_reg_idx = "0011" else
               Qs(4) when c_reg_idx = "0100" else
               Qs(5) when c_reg_idx = "0101" else
               Qs(6) when c_reg_idx = "0110" else
               Qs(7) when c_reg_idx = "0111" else
               Qs(8) when c_reg_idx = "1000" else
               Qs(9) when c_reg_idx = "1001" else
               Qs(10) when c_reg_idx = "1010" else
               Qs(11) when c_reg_idx = "1011" else
               Qs(12) when c_reg_idx = "1100" else
               Qs(13) when c_reg_idx = "1101" else
               Qs(14) when c_reg_idx = "1110" else
               Qs(15) when c_reg_idx = "1111" else
               (others => 'Z');               
    
end architecture;

