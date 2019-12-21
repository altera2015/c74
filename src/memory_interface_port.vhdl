-- C74.000
--
-- Memory interface Port
-- 
-- Used to abstract the LPDDR, RAM and (future cache) blocks
-- from the Control Logic.
-- 
-- Copyright (c) 2019 Ron Bessems


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.alL;


entity memory_interface_port is
    port ( 
        clk : in  std_logic;
        reset : in  std_logic;
        
        -- User Interface
        address : in std_logic_vector(31 downto 0);
        D : in  std_logic_vector(31 downto 0);
        RE: in std_logic;
        WE: in std_logic_vector(3 downto 0);
        ready : out  std_logic;
        Q : out std_logic_vector(31 downto 0);
        
        -- Fast Ram Interface
        fr_en : out std_logic;
        fr_we : out std_logic_vector(3 downto 0);
        fr_addr : out std_logic_vector(8 downto 0);
        fr_din : out std_logic_vector(31 downto 0);
        fr_dout : in std_logic_vector(31 downto 0);

        -- lpddr interface
        lpddr_cmd_en                            : out std_logic;
        lpddr_cmd_instr                         : out std_logic_vector(2 downto 0);
        lpddr_cmd_bl                            : out std_logic_vector(5 downto 0);
        lpddr_cmd_byte_addr                     : out std_logic_vector(29 downto 0);
        lpddr_cmd_empty                         : in std_logic;
        lpddr_cmd_full                          : in std_logic;
        lpddr_wr_clk                            : out std_logic;
        lpddr_wr_en                             : out std_logic;
        lpddr_wr_mask                           : out std_logic_vector(3 downto 0);
        lpddr_wr_data                           : out std_logic_vector(31 downto 0);
        lpddr_wr_full                           : in std_logic;
        lpddr_wr_empty                          : in std_logic;
        lpddr_wr_count                          : in std_logic_vector(6 downto 0);
        lpddr_wr_underrun                       : in std_logic;
        lpddr_wr_error                          : in std_logic;
        lpddr_rd_clk                            : out std_logic;
        lpddr_rd_en                             : out std_logic;
        lpddr_rd_data                           : in std_logic_vector(31 downto 0);
        lpddr_rd_full                           : in std_logic;
        lpddr_rd_empty                          : in std_logic;
        lpddr_rd_count                          : in std_logic_vector(6 downto 0);
        lpddr_rd_overflow                       : in std_logic;
        lpddr_rd_error                          : in std_logic       
               
        
    );
        
end memory_interface_port;

architecture Behavioral of memory_interface_port is
    signal bank: std_logic := '1';
    signal lpddr_data : std_logic_vector(31 downto 0);
    type AccessState is ( IDLE, B0_R_START, B0_W_START, B1_R_START, B1_R_START_DELAYED, B1_R_READ, B1_W_WAIT_TO_START, B1_W_START, B1_W_DELAY, B1_W_COMMIT_COMMAND, CLEAR_READY,CLEAR_READY_A);
    signal state_sig : AccessState;
begin


    -- mark Q to bank as multi cycle
    Q <= fr_dout when bank='0' else lpddr_data;
    fr_din <= D;

    process(clk)
        constant bank_cutoff : integer := 2048;
        variable state_address : std_logic_vector(31 downto 0);
        variable input : std_logic_vector(31 downto 0);        
        variable state : AccessState;
    begin
    
        
        if rising_edge(clk) then 
        
            if reset = '1' then
            
                bank <= '0';
                state := IDLE;  
                state_sig <= IDLE;
                
                fr_we <= "0000";
                fr_en <= '0';
                ready <= '0';                
                
                lpddr_cmd_en <= '0';
                lpddr_wr_en <= '0';
                lpddr_rd_en <= '0';
                                
            else
            
                case state is
                
                when IDLE =>
                    
                    if ( RE = '1' ) then
                        state_address := address;
                        
                        if unsigned(address) < bank_cutoff then
                            bank <= '0';
                            state := B0_R_START;
                            
                            fr_addr <= state_address(10 downto 2);
                            fr_en <= '1';                        
                            
                        else 
                            bank <= '1';
                            
                            
                            lpddr_cmd_bl <= "000000";
                            lpddr_cmd_instr <= "001";
                            lpddr_cmd_byte_addr <= std_logic_vector((unsigned(address(29 downto 0)) - bank_cutoff));
                            if lpddr_cmd_full = '0' then
                                lpddr_cmd_en <= '1';
                                state := B1_R_START;
                            else
                                state := B1_R_START_DELAYED;
                            end if;
                            
                        end if;                    
                        
                    elsif ( WE /= "0000" ) then                    
                        state_address := address;
                        
                        if unsigned(address) < bank_cutoff then
                            bank <= '0';
                            state := B0_W_START;                        
                            fr_addr <= state_address(10 downto 2);
                            fr_en <= '1';
                            fr_we <= WE;                        
                        else 
                            bank <= '1';
                                   
                            lpddr_cmd_bl <= "000000";
                            lpddr_cmd_instr <= "000";                            
                            lpddr_cmd_byte_addr <= std_logic_vector((unsigned(address(29 downto 0)) - bank_cutoff));
                            
                            lpddr_wr_mask <= not WE;
                            lpddr_wr_data <= D;
                            
                            if lpddr_wr_full='0' then
                                state := B1_W_START;
                                lpddr_wr_en <= '1';
                            else
                                state := B1_W_WAIT_TO_START;
                            end if;
                            
                        end if;
                    end if;
                    
                    
                -- ******************************************
                -- Block RAM
                -- ******************************************
                when B0_R_START =>            
                    ready <= '1';
                    fr_en <= '0';
                    state := CLEAR_READY;
                when CLEAR_READY_A =>
                    state := CLEAR_READY;
                when B0_W_START =>
                    ready <= '1';
                    fr_en <= '0';
                    fr_we <= "0000";
                    state := CLEAR_READY;                

                -- ******************************************
                -- LPDDR RAM
                -- ******************************************
                -- **** WRITE ****
                when B1_W_WAIT_TO_START => 
                
                    if lpddr_wr_full='0' then
                        state := B1_W_START;
                        lpddr_wr_en <= '1';
                    end if;
                    
                when B1_W_START =>
                    lpddr_wr_en <= '0';
                    if lpddr_cmd_full='0' then
                        lpddr_cmd_en <= '1';
                        state := B1_W_COMMIT_COMMAND;
                    end if;

                when B1_W_COMMIT_COMMAND =>
                    lpddr_cmd_en <= '0';
                    ready <= '1';
                    state := CLEAR_READY;
                    
                    
                -- **** READ ****  
                when B1_R_START_DELAYED=>
                    lpddr_cmd_en <= '1';
                    state := B1_R_START;               
                when B1_R_START =>
                
                   lpddr_cmd_en <= '0';
                   if lpddr_rd_count /= "0000000" then
                     lpddr_data <= lpddr_rd_data;
                     lpddr_rd_en <= '1';
                     state := B1_R_READ;
                   end if;
                   
                when B1_R_READ =>
                    lpddr_rd_en <= '0';
                    ready <= '1';
                    state := CLEAR_READY;
                    
                -- ******************************************
                -- Cleanup
                -- ******************************************

                when CLEAR_READY =>                
                    ready <= '0';
                    state := IDLE;
                    
                when others => 
                    ready <= '0';
                    state := IDLE;
                end case;
                state_sig <= state;
            end if; -- reset
        end if; -- rising edge.
    
    end process;    

end Behavioral;

