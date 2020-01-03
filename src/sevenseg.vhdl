-- 7 Segment hex display
-- 
-- Ron Bessems <rbessems@gmail.com> 
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity sevenseg is
	-- 3 digit display.
	port ( 
		value : in  std_logic_vector (11 downto 0);
		clk : in  std_logic;
		en : in  std_logic;

		segments : out  std_logic_vector (6 downto 0);
		digits : out  std_logic_vector (2 downto 0)
	);
	  
end sevenseg;

architecture sevenseg_arch of sevenseg is
	signal count: unsigned(18 downto 0) := ( others => '0' );
	signal digit: std_logic_vector(2 downto 0) := "000";	
begin

	process(clk)		
		variable A: std_logic_vector(3 downto 0) := "0000" ;
	begin
		if rising_edge(clk) then
			count <= count + 1;
			-- slow down the clock
			if count = (count'range => '0') then	
			
				if digit = "110" then
					digit <= "101";
					A:= value(7 downto 4);				
				elsif digit = "101" then
					digit <= "011";
					A:= value(11 downto 8);
				else
					digit <= "110";
					A:= value(3 downto 0);
				end if;

				case A is
				  --when "0000"=> segments <="0000001";  -- '0'
				  when "0001"=> segments <="1001111";  -- '1'
				  when "0010"=> segments <="0010010";  -- '2'
				  when "0011"=> segments <="0000110";  -- '3'
				  when "0100"=> segments <="1001100";  -- '4' 
				  when "0101"=> segments <="0100100";  -- '5'
				  when "0110"=> segments <="0100000";  -- '6'
				  when "0111"=> segments <="0001111";  -- '7'
				  when "1000"=> segments <="0000000";  -- '8'
				  when "1001"=> segments <="0000100";  -- '9'
				  when "1010"=> segments <="0001000";  -- 'A'
				  when "1011"=> segments <="1100000";  -- 'b'
				  when "1100"=> segments <="0110001";  -- 'C'
				  when "1101"=> segments <="1000010";  -- 'd'
				  when "1110"=> segments <="0110000";  -- 'E'
				  when "1111"=> segments <="0111000";  -- 'F'
				  when others => segments <="0000001";  -- '0'				  
				end case;				
				
			end if;
			
		end if;
	end process;
	
	digits <= std_logic_vector(digit) when (en = '1') else "111";

end sevenseg_arch;

