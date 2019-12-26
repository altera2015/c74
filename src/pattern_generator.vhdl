library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pattern_generator is
    generic(
        DATA_PORT_SIZE      : integer := 32;
        WIDTH : integer := 800; -- 1023 max, must be multiple of 4
        HEIGHT : integer := 600; -- 1023 max
        BASE_ADDRESS : integer := 4096      
    );
    port (
        clk                               : in std_logic;
        reset                             : in std_logic;
        done                              : out std_logic;

        cmd_en                            : out std_logic;
        cmd_instr                         : out std_logic_vector(2 downto 0);
        cmd_bl                            : out std_logic_vector(5 downto 0);
        cmd_byte_addr                     : out  std_logic_vector(29 downto 0);
        cmd_empty                         : in std_logic;
        cmd_full                          : in std_logic;
        
        wr_en                             : out std_logic;
        wr_mask                           : out std_logic_vector(3 downto 0);
        wr_data                           : out std_logic_vector(31 downto 0);
        wr_full                           : in std_logic;
        wr_empty                          : in std_logic;
        wr_count                          : in std_logic_vector(6 downto 0);
        wr_underrun                       : in std_logic;
        wr_error                          : in std_logic
       
    );
end pattern_generator;

architecture pattern_generator_arch of pattern_generator is


    function fill_pixel( x: integer; y: integer ) return std_logic_vector is
        variable red : std_logic_vector(2 downto 0);
        variable green : std_logic_vector(2 downto 0);
        variable blue : std_logic_vector(1 downto 0);
        variable pixel : std_logic_vector(7 downto 0);
    begin

        if y < 400 then
            red := "111";
        else
            red := "000";
        end if;
        if y>=200 and y < 400 then
            green := "111";
        else
            green := "000";
        end if;
        if y>=200 then
            blue := "11";
        else
            blue := "00";
        end if;
        
        if ( x > 300 and x < 500 ) and ( y > 150 and y < 450 ) then
            red  := "000";
            green := "111";
            blue := "00";
            
        end if;
        
        pixel := red & green & blue;
        
        --if (y mod 2) = 0 then
        --    pixel := red & green & blue;
        --else
        --    pixel := "00000000";
        --end if;
        return pixel;    
    end fill_pixel;
    
    type FillStateType is ( FillWord, QueueWord, QueueWordDone, PrepareCommand, SendCommand, GenerateDone);
    signal fill_state : FillStateType;
    constant MAX_MEMORY : integer := WIDTH * HEIGHT + BASE_ADDRESS;


begin    

    wr_mask <= "0000"; -- always write a whole word.
    cmd_instr <= "000"; -- always writing.
    


    process(clk)
        variable x : unsigned(9 downto 0);
        variable y : unsigned(9 downto 0);
        variable pixel_word : std_logic_vector(31 downto 0);
        variable byte_address : integer;
        variable queued_words : integer;
    begin
    
        if rising_edge(clk) then
            if reset = '1' then
            
                done <= '0';
                wr_en <= '0';
                cmd_en <= '0';
                x := (others => '0');
                y := (others => '0');
                byte_address := BASE_ADDRESS;
                queued_words := 0;
                fill_state <= FillWord;
                
            else
                wr_en <= '0';
                cmd_en <= '0';
                case (fill_state) is
                
                when FillWord =>

                    if y < height then
    
                        case ( x(1 downto 0) ) is
                            when "00" =>
                                pixel_word(31 downto 24) := fill_pixel(to_integer(x),to_integer(y));
                            when "01" =>
                                pixel_word(23 downto 16) := fill_pixel(to_integer(x),to_integer(y));
                            when "10" =>
                                pixel_word(15 downto 8) := fill_pixel(to_integer(x),to_integer(y));
                            when "11" =>
                                pixel_word(7 downto 0) := fill_pixel(to_integer(x),to_integer(y));
                                fill_state <= QueueWord; 
                            when others =>
                                -- do nothing.
                        end case;
                        
                        x := x + 1;
                        if x = WIDTH + 1 then
                            x := (others => '0');
                            y := y + 1;
                        end if;
                    else 
                        if queued_words = 0 then
                            fill_state <= GenerateDone;
                        else
                            fill_state <= PrepareCommand;
                        end if;
                    end if;
                
                when QueueWord =>                
                    
                    if wr_full = '0' then
                        wr_data <= pixel_word;
                        wr_en <= '1';
                        fill_state <= QueueWordDone;
                    end if;
                    
                when QueueWordDone =>
                                        
                    queued_words := queued_words + 1;
                    if queued_words = 64 then
                        fill_state <= PrepareCommand;
                    else
                        fill_state <= FillWord;
                    end if;                
                               
                when PrepareCommand =>
                    
                    if cmd_full = '0' then                        
                        cmd_byte_addr <= std_logic_vector(to_unsigned(byte_address, cmd_byte_addr'length));
                        cmd_bl <= std_logic_vector(to_unsigned(queued_words-1, cmd_bl'length));                        
                        fill_state <= SendCommand;
                    end if;
                    
                when SendCommand =>
                
                    cmd_en <= '1';
                    byte_address := byte_address + (queued_words * 4);
                    fill_state <= FillWord;
                    queued_words := 0;
                               
                when GenerateDone =>
                
                    done <= '1';
                    
                end case;
                    
            end if;
        end if;    
    end process;

end pattern_generator_arch;

