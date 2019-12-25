--
-- VGA MIG ( DDR Ram ) based Frame buffer
--
-- Copyright (c) 2019, Ron Bessems
-- 
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity vga_framebuffer is
    generic (
        BASE_ADDRESS           : integer := 4096;        
        WIDTH                  : integer := 800;
        HEIGHT                 : integer := 600               
    );
    port (
        
        clk                               : in std_logic; -- expecting 100MHz.
        reset                             : in std_logic;
        -- VGA output
        hsync                             : out  std_logic;
        vsync                             : out  std_logic;
        red                               : out  std_logic_vector (2 downto 0);
        green                             : out  std_logic_vector (2 downto 0);
        blue                              : out  std_logic_vector (2 downto 1);
        
        -- Read-only MIG
        cmd_en                            : out std_logic;
        cmd_instr                         : out std_logic_vector(2 downto 0);
        cmd_bl                            : out std_logic_vector(5 downto 0);
        cmd_byte_addr                     : out  std_logic_vector(29 downto 0);
        cmd_empty                         : in std_logic;
        cmd_full                          : in std_logic;
        
        rd_en                             : out std_logic;
        rd_data                           : in std_logic_vector(31 downto 0);
        rd_full                           : in std_logic;
        rd_empty                          : in std_logic;
        rd_count                          : in std_logic_vector(6 downto 0);
        rd_overflow                       : in std_logic;
        rd_error                          : in std_logic 
    );

end vga_framebuffer;


architecture vga_framebuffer_arch of vga_framebuffer is

    component vga
        generic (
            
        H_VISIBLE       : integer := 800;
        H_FRONT_PORCH   : integer := 40;
        H_SYNC_PULSE    : integer := 128;
        H_BACK_PORCH    : integer := 88;
    
        V_VISIBLE       : integer := 600;
        V_FRONT_PORCH   : integer := 1;
        V_SYNC_PULSE    : integer := 4;
        V_BACK_PORCH    : integer := 23

        );
        port (
            clk      : in std_logic; -- expecting 40MHz.
            reset    : in std_logic;
            h_sync_n : out std_logic;
            v_sync_n : out std_logic;
            x        : out unsigned(9 downto 0);
            y        : out unsigned(9 downto 0);
            blank    : out std_logic;
            sof      : out std_logic --start of frame
        );
    
    end component;
    
    -- Width * height must be multiple of 4 at the moment.
    constant SIZE: integer := WIDTH * HEIGHT;
    constant SIZE_IN_WORDS: integer := SIZE / 4;
    -- VGA Output
    signal x: unsigned(9 downto 0);
    signal y: unsigned(9 downto 0);
    signal blank: std_logic; 
    signal sof : std_logic;
    signal address: integer := BASE_ADDRESS;

    signal requested_data: integer := 0;

    
    type mem_read_state is ( WaitForSof, Idle, QueueCommand, QueueDone );        
    signal read_state: mem_read_state := WaitForSof;
    
    type mem_word_state is ( PREPARE_BYTE1,        
                             PREPARE_BYTE2, 
                             PREPARE_BYTE3, 
                             PREPARE_BYTE4 );
                             
    signal word_state: mem_word_state := PREPARE_BYTE1;
    signal red_intermediary : std_logic_vector(2 downto 0);
    signal green_intermediary : std_logic_vector(2 downto 0);
    signal blue_intermediary : std_logic_vector(2 downto 1);

    signal blank_internal : std_logic;
    signal vsync_internal : std_logic;
    signal hsync_internal : std_logic;
begin

    vga_0: vga port map (
       clk => clk,
       reset => reset,
       h_sync_n => hsync_internal,
       v_sync_n => vsync_internal,
       x => x,
       y => y,
       blank => blank_internal,
       sof => sof

    );
        
    
    cmd_instr <= "001"; -- we only read.
    cmd_byte_addr <= std_logic_vector(to_unsigned(address, cmd_byte_addr'length));
        
    process(clk)    
        -- variable ifd : integer;
        variable trd : integer;
        variable total_read : integer;
        variable to_read : integer;
        variable pixel_word : std_logic_vector(31 downto 0);
    begin
    
        if rising_edge(clk) then
            
            if reset = '1' then
                cmd_en <= '0';
                rd_en <= '0';                
                hsync <= '0';
                vsync <= '0';
                blank <= '1';
                read_state <= WaitForSof;
                word_state <= PREPARE_BYTE1;
                cmd_bl <= "000000";
                red <= "000";
                green <= "000";
                blue <= "00";                
            else
                
                blank <= blank_internal;
                vsync <= not vsync_internal;
                hsync <= not hsync_internal;
                
                cmd_en <= '0'; -- disable command.
                rd_en <= '0';  -- disable read.
                            
                ----------------------------------
                -- Memory read-ahead
                ----------------------------------
                --
                -- This code makes sure we have
                -- a few words of data ready to go
                -- for the output.
                --
                case (read_state) is
                when WaitForSof =>
                
                   if sof = '1' then
                        address <= BASE_ADDRESS;                       
                        read_state <= QueueCommand;                          
                        total_read := 0;
                        word_state <= PREPARE_BYTE1;
                        cmd_bl <= "111111"; -- 64 bytes.
                        requested_data <= 64;                        
                        trd := 64;                        
                    end if;            
                
                when QueueCommand =>
                
                    cmd_en <= '1';
                    read_state <= QueueDone;
                    
                when QueueDone =>
                
                    address <= address + requested_data * 4;
                    cmd_en <= '0';              
                    read_state <= Idle;
                    
                when Idle =>
                    
                    if trd < SIZE_IN_WORDS then
                        if (trd - total_read) <= 32 then
                            to_read := SIZE_IN_WORDS - trd;
                            if to_read > 32 then
                                to_read := 32;
                            end if;                            
                            requested_data <= to_read;                            
                            trd := trd + to_read;
                            to_read := to_read - 1;
                            cmd_bl <= std_logic_vector(to_unsigned(to_read, cmd_bl'length));                            
                            read_state <= QueueCommand;
                        end if;
                    else
                        read_state <= WaitForSof;
                    end if;
                        
                end case;
                

                ----------------------------------
                -- Pixel Readout
                ----------------------------------
                --
                -- This code takes available 
                -- pixels
                --                
                if blank_internal = '0' then
                
                    case( word_state ) is
                        when PREPARE_BYTE1 => 
                            if to_integer(unsigned(rd_count)) > 0 then
                                rd_en <= '1';                
                                total_read := total_read+1;
                            end if;                        
                            pixel_word := rd_data;                            
                            word_state <= PREPARE_BYTE2;
                        when PREPARE_BYTE2 =>
                            pixel_word(31 downto 8) := pixel_word(23 downto 0);
                            word_state <= PREPARE_BYTE3;
                        when PREPARE_BYTE3 =>
                            pixel_word(31 downto 16) := pixel_word(23 downto 8);
                            word_state <= PREPARE_BYTE4;
                        when PREPARE_BYTE4 =>
                            pixel_word(31 downto 24) := pixel_word(23 downto 16);
                            word_state <= PREPARE_BYTE1;
                    end case;
                    
                    red <= pixel_word(31 downto 29);
                    green <= pixel_word(28 downto 26);
                    blue <= pixel_word(25 downto 24);
                 
                else
                    red <= "000";
                    green <= "000";
                    blue <= "00";
                    
                end if;
            end if; -- else for reset
        end if; --rising edge(clk)
        
    end process;
   
    
--    red <= pixel_word(31 downto 29) when blank = '0' else "000";
--    green <= pixel_word(28 downto 26) when blank = '0' else "000";
--    blue <= pixel_word(25 downto 24) when blank = '0' else "00";
    
    -- Red, white and blue!
    -- red <= "111" when blank='0' and y < 400 else "000";
    -- green <= "111" when blank='0' and y>=200 and y < 400 else "000";
    -- blue <= "11" when blank='0' and y >= 200 else "00";  

end vga_framebuffer_arch;

