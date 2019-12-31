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
use work.types.all;

entity reg_file is
    port ( 
        clk             : in  std_logic;
        reset           : in  std_logic;

        -- idx = 0xe / 14
        sp_inc          : in std_logic;
        sp_dec          : in std_logic;

        -- idx = 0x0f / 15
        pc_inc          : in std_logic;        
        Ds              : in register_array;
        Qs              : out register_array;
        load            : in std_logic_vector(15 downto 0)

    );
           
end reg_file;

architecture rtl of reg_file is
begin
    
    generator_loop: for i in 0 to 15 generate

        regs_0_13 : if i < 14 generate
        
            reg_instance : entity work.reg(rtl) port map (
                clk           => clk,
                reset         => reset,            
                load          => load(i),
                q             => Qs(i),
                d             => Ds(i),
                inc           => '0',
                dec           => '0',
                op_value      => "0000000000000000"
            );
          
         end generate;

        reg_14: if i = 14 generate
                
            reg_instance : entity work.reg(rtl) port map (
                clk           => clk,
                reset         => reset,            
                load          => load(i),
                q             => Qs(i),
                d             => Ds(i),
                inc           => sp_inc,
                dec           => sp_dec,
                op_value      => "0000000000000100"
            );   
                     
        end generate;
        
        reg_15: if i = 15 generate
        
            reg_instance : entity work.reg(rtl) port map (
                clk           => clk,
                reset         => reset,            
                load          => load(i),
                q             => Qs(i),
                d             => Ds(i),
                inc           => pc_inc,
                dec           => '0',
                op_value      => "0000000000000100"
            );
                                 
        end generate;        
        
        
    end generate generator_loop;              
    
end architecture;

