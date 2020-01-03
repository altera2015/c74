-- C74.000
--
-- 16 Channel Interupt Controller
-- 
-- Copyright (c) 2020 Ron Bessems

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity irq_controller is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           irq_en : in  STD_LOGIC;
           irq_mask : in std_logic_vector(15 downto 0);
           irq_clear : in std_logic_vector(15 downto 0);
           irq_lines : in  STD_LOGIC_VECTOR(15 downto 0);
           
           irq : out  STD_LOGIC;
           irq_table_entry : out  STD_LOGIC_VECTOR (31 downto 0);
           irq_active_line : out  STD_LOGIC_VECTOR (15 downto 0)
    );
           
end irq_controller;

architecture Behavioral of irq_controller is    
    signal irq_ready : std_logic_vector(15 downto 0);        
    signal irq_previous : std_logic_vector(15 downto 0);
    signal rising : std_logic_vector(15 downto 0);

begin

    process(clk)        
    begin
        if rising_edge(clk) then
        
            if reset = '1' then
                irq_ready <= (others => '0');
                irq_previous <= (others => '0');
            else
                
                -- detect rising edge
                rising <= (irq_lines xor irq_previous) and irq_lines and irq_mask;
                irq_ready <= ( irq_ready and (not irq_clear)) or 
                             ( (irq_lines xor irq_previous) and irq_lines and irq_mask);
                irq_previous <= irq_lines;  
            end if;
        end if;
            
      end process;
      
      
      process(clk)
      begin
           if rising_edge(clk) then 
              if reset = '1' then
                irq <= '0';
                irq_table_entry <= (others=>'0');
                irq_active_line <= (others=>'0');
                
              else
              
                if irq_en = '1' then
                    
                    irq <= '1';
                    
                    if irq_ready(0) = '1' then                        
                        irq_table_entry <= std_logic_vector(to_unsigned(4, irq_table_entry'length));
                        irq_active_line <= "0000000000000001";
                        
                    elsif irq_ready(1) = '1' then
                        irq_table_entry <= std_logic_vector(to_unsigned(8, irq_table_entry'length));
                        irq_active_line <= "0000000000000010";
                        
                    elsif irq_ready(2) = '1' then
                        irq_table_entry <= std_logic_vector(to_unsigned(12, irq_table_entry'length));
                        irq_active_line <= "0000000000000100";
                        
                    elsif irq_ready(3) = '1' then
                        irq_table_entry <= std_logic_vector(to_unsigned(16, irq_table_entry'length));
                        irq_active_line <= "0000000000001000";
                        
                    elsif irq_ready(4) = '1' then
                        irq_table_entry <= std_logic_vector(to_unsigned(20, irq_table_entry'length));
                        irq_active_line <= "0000000000010000";
                        
                    elsif irq_ready(5) = '1' then
                        irq_table_entry <= std_logic_vector(to_unsigned(24, irq_table_entry'length));
                        irq_active_line <= "0000000000100000";
                        
                    elsif irq_ready(6) = '1' then
                        irq_table_entry <= std_logic_vector(to_unsigned(28, irq_table_entry'length));
                        irq_active_line <= "0000000001000000";
                        
                    elsif irq_ready(7) = '1' then
                        irq_table_entry <= std_logic_vector(to_unsigned(32, irq_table_entry'length));
                        irq_active_line <= "0000000010000000";
                        
                    elsif irq_ready(8) = '1' then
                        irq_table_entry <= std_logic_vector(to_unsigned(36, irq_table_entry'length));
                        irq_active_line <= "0000000100000000";
                        
                    elsif irq_ready(9) = '1' then
                        irq_table_entry <= std_logic_vector(to_unsigned(40, irq_table_entry'length));
                        irq_active_line <= "0000001000000000";
                        
                    elsif irq_ready(10) = '1' then
                        irq_table_entry <= std_logic_vector(to_unsigned(44, irq_table_entry'length));
                        irq_active_line <= "0000010000000000";
                        
                    elsif irq_ready(11) = '1' then
                        irq_table_entry <= std_logic_vector(to_unsigned(48, irq_table_entry'length));
                        irq_active_line <= "0000100000000000";
                        
                    elsif irq_ready(12) = '1' then
                        irq_table_entry <= std_logic_vector(to_unsigned(52, irq_table_entry'length));
                        irq_active_line <= "0001000000000000";
                        
                    elsif irq_ready(13) = '1' then
                        irq_table_entry <= std_logic_vector(to_unsigned(56, irq_table_entry'length));
                        irq_active_line <= "0010000000000000";
                        
                    elsif irq_ready(14) = '1' then
                        irq_table_entry <= std_logic_vector(to_unsigned(60, irq_table_entry'length));
                        irq_active_line <= "0100000000000000";
                        
                    elsif irq_ready(15) = '1' then
                        irq_table_entry <= std_logic_vector(to_unsigned(64, irq_table_entry'length));
                        irq_active_line <= "1000000000000000";
                                               
                    else
                        irq_table_entry <= (others=>'0');
                        irq_active_line <= "0000000000000000";                    
                        irq <= '0';                        
                    end if;
                else
                    irq_table_entry <= (others=>'0');
                    irq_active_line <= "0000000000000000";                    
                    irq <= '0';
                end if;
                
            end if;              
                
          end if;
            
 
        
    end process;
    
end Behavioral;

