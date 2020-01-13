-- C74.000
--
-- The Debug Port accessible via serial line
-- 
-- HALT, STEP, CONTINUE, MEMORY Read, GP Register and Status Register Read.
-- 
-- Copyright (c) 2020 Ron Bessems


library ieee;
use ieee.std_logic_1164.all;
use work.types.all;
use work.isa_defs.all;
use ieee.numeric_std.all;

entity dbg_prt is
    port ( clk : in  std_logic;
           reset : in  std_logic;
           rx : in  std_logic;
           tx : out  std_logic;
           qs : in register_array;
           cpu_flags : in  std_logic_vector (31 downto 0);
           address : out  std_logic_vector (31 downto 0);
           data : in  std_logic_vector (31 downto 0);
           ready : in  std_logic;
           re : out  std_logic;
           halt : in  std_logic;
           step : out  std_logic;
           halt_request : out  std_logic;
           continue_request : out std_logic;
           reset_request : out std_logic;
           dout : out  std_logic_vector (31 downto 0);
           we : out std_logic
        );
end dbg_prt;

architecture Behavioral of dbg_prt is


	COMPONENT buffered_uart
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		tx_data : IN std_logic_vector(7 downto 0);
		tx_enable : IN std_logic;
		rx_enable : IN std_logic;
		rx_pin : IN std_logic;          
		tx_full : OUT std_logic;
		tx_busy : OUT std_logic;
		rx_empty : OUT std_logic;
		rx_data : OUT std_logic_vector(7 downto 0);
		tx_pin : OUT std_logic        
		);
	END COMPONENT;

    signal tx_data : std_logic_vector(7 downto 0);
    signal tx_enable : std_logic;
    signal tx_full : std_logic;
    signal tx_busy : std_logic;
    signal rx_empty : std_logic;
    signal rx_data : std_logic_vector(7 downto 0);
    signal rx_enable : std_logic;

     
    type DebugState is ( RUNNING, RUNNING_CMD, HALTED, HALTED_CMD,                          
                        WRITE_STATUS, WRITE_STATUS_AND_DATA,
                        GET_MEMORY_LOAD, GET_MEMORY_LOAD_NOW, GET_MEMORY_WAIT,
                        WRITE_DATA, WRITE_DATA_2, WRITE_DATA_3, WRITE_DATA_4,
                        READ_DATA, READ_DATA_2,READ_DATA_3,READ_DATA_4,
                        WAIT_FOR_RESET_SEND, SET_MEMORY, SET_MEMORY_DATA, WAIT_FOR_WRITE,
                        DELAY_ONE_CLK
                        );
    signal state : DebugState;
    signal post_sub_function_state : DebugState;
    signal post_delay_state : DebugState;
    
    signal cmd : std_logic_vector(6 downto 0); 
    signal status_to_send : std_logic_vector(7 downto 0); 
    signal data_to_send : std_logic_vector(31 downto 0); 
    signal data_read : std_logic_vector(31 downto 0); 
    signal delay : integer range 0 to 8;    
    
    signal debug_reset_request : std_logic;
    

begin

	uart0: buffered_uart PORT MAP(
		clk => clk,
		reset => reset,
		tx_data => tx_data,
		tx_enable => tx_enable,
		tx_full => tx_full,
		tx_busy => tx_busy,
		rx_empty => rx_empty,
		rx_data => rx_data,
		rx_enable => rx_enable,
		rx_pin => rx,
		tx_pin => tx
	);
    
    process(clk)   
       variable reset_wait_cntr : integer range 0 to 31;
    begin   
        if rising_edge(clk) then
        
            if reset = '1' then
                state <= HALTED;
                delay <= 0;   
                step <= '0';
                re <= '0';
                tx_enable <= '0';
                rx_enable <= '0';
                halt_request <= '0';
                continue_request <= '0';
                address <= "00000000000000000000000000000000";
                debug_reset_request <= '0';
            else
                            
                re <= '0';
                tx_enable <= '0';
                rx_enable <= '0';
                step <= '0';
                debug_reset_request <= '0';
                we <= '0';
                
                case state is
                when RUNNING =>

                    if halt = '1' then                        
                        status_to_send <= '1' & DBG_HALTED;
                        state <= WRITE_STATUS;
                        post_sub_function_state <= HALTED;
                        halt_request <= '0';
                    else
                    
                        if rx_empty = '0' then
                            cmd <= rx_data(6 downto 0);
                            rx_enable <= '1';
                            state <= RUNNING_CMD;                            
                        end if;
                        
                    end if;
                    
                when RUNNING_CMD =>
                

                    case cmd is
                    when DBG_HALT =>
                    
                        halt_request <= '1';
                        status_to_send <= '1' & cmd;
                        state <= WRITE_STATUS;
                        post_sub_function_state <= RUNNING;
                        
                    when DBG_STATUS =>
                    
                        status_to_send <= '1' & cmd;
                        data_to_send <= DBG_RUNNING_CPU_ID;
                        state <= WRITE_STATUS_AND_DATA;
                        post_sub_function_state <= RUNNING;                        

                    when others =>                                                    
                        status_to_send <= '0' & cmd;
                        state <= WRITE_STATUS;
                        post_sub_function_state <= RUNNING;                             
                    end case;
                    
                when HALTED =>
                
                    if halt = '0' then                        
                        status_to_send <= '1' & DBG_RUNNING;
                        state <= WRITE_STATUS;
                        post_sub_function_state <= RUNNING;
                        
                        continue_request <= '0';
                    else
                        if rx_empty = '0' then
                            cmd <= rx_data(6 downto 0);
                            rx_enable <= '1';
                            state <= HALTED_CMD;
                        end if;                 
                    end if;
                    
                when HALTED_CMD =>
                
                    case cmd is
                        when DBG_CONTINUE =>                            
                            status_to_send <= '1' & cmd;
                            state <= WRITE_STATUS;
                            post_sub_function_state <= HALTED;                            
                            continue_request <= '1';
                               
                        when DBG_STEP =>                            
                            status_to_send <= '1' & cmd;
                            state <= WRITE_STATUS;
                            post_sub_function_state <= HALTED;                            
                            step <= '1';
                           
                        when DBG_GET_CPU_FLAGS =>
                                          
                            status_to_send <= '1' & cmd;
                            data_to_send <= cpu_flags;
                            state <= WRITE_STATUS_AND_DATA;
                            post_sub_function_state <= HALTED;                            
                            
                           
                        when DBG_GET_REG_0 |
                             DBG_GET_REG_1 |
                             DBG_GET_REG_2 |
                             DBG_GET_REG_3 |
                             DBG_GET_REG_4 |
                             DBG_GET_REG_5 |
                             DBG_GET_REG_6 |
                             DBG_GET_REG_7 |
                             DBG_GET_REG_8 |
                             DBG_GET_REG_9 |
                             DBG_GET_REG_10 |
                             DBG_GET_REG_11 |
                             DBG_GET_REG_12 |
                             DBG_GET_REG_13 |
                             DBG_GET_REG_14 |
                             DBG_GET_REG_15 =>
                                          
                            status_to_send <= '1' & cmd;
                            data_to_send <= Qs( to_integer(unsigned(cmd(3 downto 0))));
                            state <= WRITE_STATUS_AND_DATA;
                            post_sub_function_state <= HALTED;                            
                            
                        when DBG_GET_MEM =>
                            
                            state <= READ_DATA;
                            status_to_send <= '1' & cmd;
                            post_sub_function_state <= GET_MEMORY_LOAD;
                        
                        when DBG_SET_MEM =>
                        
                            state <= READ_DATA;
                            status_to_send <= '1' & cmd;
                            post_sub_function_state <= SET_MEMORY;
                        
                        when DBG_RESET =>
                                          
                            status_to_send <= '1' & cmd;
                            state <= WRITE_STATUS;
                            post_sub_function_state <= WAIT_FOR_RESET_SEND;                            
                            reset_wait_cntr := 31;
                            
                        when DBG_STATUS =>
                        
                            status_to_send <= '1' & cmd;
                            data_to_send <= DBG_HALTED_CPU_ID;
                            state <= WRITE_STATUS_AND_DATA;
                            post_sub_function_state <= HALTED;
                                                    
                        when others =>                                                    
                            status_to_send <= '0' & cmd;
                            state <= WRITE_STATUS;
                            post_sub_function_state <= HALTED;
                    end case;
                    
                when WAIT_FOR_RESET_SEND =>
                
                    if reset_wait_cntr = 0 then
                        debug_reset_request <= '1';
                    else
                        if tx_busy = '0' then
                            reset_wait_cntr := reset_wait_cntr - 1;                       
                        else
                            reset_wait_cntr := 31;
                        end if;
                    end if;
                            
                            
                -- READ MEMORY
                when GET_MEMORY_LOAD =>
                    address <= data_read;
                    state <= GET_MEMORY_LOAD_NOW;                    
                    
                when GET_MEMORY_LOAD_NOW =>                
                    re <= '1';
                    state <= GET_MEMORY_WAIT;
                    
                when GET_MEMORY_WAIT =>
                    if ready = '1' then                        
                        status_to_send <= '1' & DBG_GET_MEM;
                        data_to_send <= data;                        
                        state <= WRITE_STATUS_AND_DATA;
                        post_sub_function_state <= HALTED;                    
                    end if;
                
                
                -- WRITE MEMORY
                when SET_MEMORY =>
                    address <= data_read;
                    state <= READ_DATA;                    
                    post_sub_function_state <= SET_MEMORY_DATA;
                    
                when SET_MEMORY_DATA =>
                    dout <= data_read;
                    we <= '1';
                    state <= WAIT_FOR_WRITE;
                    
                when WAIT_FOR_WRITE =>
                    if ready = '1' then                        
                        status_to_send <= '1' & DBG_SET_MEM;
                        data_to_send <= data;
                        post_sub_function_state <= HALTED;   
                        state <= WRITE_STATUS;
                    end if;

                    
                -- Read 32 bit data and store in data_read.
                when READ_DATA =>
                    if rx_empty = '0' then                    
                        data_read(31 downto 24) <= rx_data;
                        rx_enable <='1';
                        state <= DELAY_ONE_CLK;
                        post_delay_state <= READ_DATA_2;
                    end if;
                when READ_DATA_2 =>
                    if rx_empty = '0' then                    
                        data_read(23 downto 16) <= rx_data;
                        rx_enable <='1';                        
                        state <= DELAY_ONE_CLK;
                        post_delay_state <= READ_DATA_3;                        
                    end if;
                when READ_DATA_3 =>
                    if rx_empty = '0' then                    
                        data_read(15 downto 8) <= rx_data;
                        rx_enable <='1';
                        state <= DELAY_ONE_CLK;
                        post_delay_state <= READ_DATA_4;
                    end if;                    
                when READ_DATA_4 =>
                    if rx_empty = '0' then                    
                        data_read(7 downto 0) <= rx_data;
                        rx_enable <='1';
                        state <= post_sub_function_state;
                    end if;

                -- WRITE SUB FUNCTIONS
                when WRITE_STATUS =>
                    if tx_full = '0' then
                        tx_data <= status_to_send;
                        tx_enable <= '1';
                        state <= post_sub_function_state;
                    end if;
                    
                when WRITE_STATUS_AND_DATA =>
                    if tx_full = '0' then
                        tx_data <= status_to_send;
                        tx_enable <= '1';
                        state <= WRITE_DATA;
                    end if;
                    
                when WRITE_DATA =>
                    if tx_full = '0' then
                        tx_data <= data_to_send(31 downto 24);
                        tx_enable <= '1';
                        state <= WRITE_DATA_2;
                    end if;
                when WRITE_DATA_2 =>
                    if tx_full = '0' then
                        tx_data <= data_to_send(23 downto 16);
                        tx_enable <= '1';
                        state <= WRITE_DATA_3;
                    end if;                             
                when WRITE_DATA_3 =>
                    if tx_full = '0' then
                        tx_data <= data_to_send(15 downto 8);
                        tx_enable <= '1';
                        state <= WRITE_DATA_4;
                    end if;                             
                when WRITE_DATA_4 =>
                    if tx_full = '0' then
                        tx_data <= data_to_send(7 downto 0);
                        tx_enable <= '1';
                        state <= post_sub_function_state;
                    end if;   
                    
                when DELAY_ONE_CLK =>
                    state <= post_delay_state;
                    
                when others =>
                    state <= RUNNING;
                                        
                end case;
            
            
            end if;
                
        end if;
        
    end process;
    
    
    process(clk)
        variable reset_hold_counter : integer range 0 to 31 := 0;
    begin
        if rising_edge(clk) then
        
            if reset_hold_counter > 0 then
                reset_hold_counter := reset_hold_counter -1;
                reset_request <= '1';
            else
                reset_request <= '0';
            end if;
        
            if debug_reset_request = '1' then
                reset_hold_counter := 31;            
            end if;
            
        end if;
        
    end process;
 
    
end Behavioral;

