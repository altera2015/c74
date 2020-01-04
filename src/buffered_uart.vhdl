-- C74.000
--
-- UART Interface.
-- 
-- Copyright (c) 2019 Ron Bessems

library ieee;
use ieee.std_logic_1164.all;


entity buffered_uart is
    port ( clk : in  std_logic;
           reset : in  std_logic;
           
           tx_data : in  std_logic_vector (7 downto 0);
           tx_enable : in  std_logic;
           tx_full : out  std_logic;
           tx_busy : out std_logic;
                     
           rx_empty : out  std_logic;
           rx_data : out  std_logic_vector (7 downto 0);
           rx_enable : in  std_logic;
           
           rx_pin : in std_logic;
           tx_pin : out std_logic
           
           );
end buffered_uart;

architecture Behavioral of buffered_uart is

	COMPONENT module_fifo_regs_no_flags
	PORT(
		i_rst_sync : IN std_logic;
		i_clk : IN std_logic;
		i_wr_en : IN std_logic;
		i_wr_data : IN std_logic_vector(7 downto 0);
		i_rd_en : IN std_logic;          
		o_full : OUT std_logic;
		o_rd_data : OUT std_logic_vector(7 downto 0);
		o_empty : OUT std_logic
		);
	END COMPONENT;
 

	COMPONENT uart_tx
	PORT(
		i_Clk : IN std_logic;
		i_TX_DV : IN std_logic;
		i_TX_Byte : IN std_logic_vector(7 downto 0);          
		o_TX_Active : OUT std_logic;
		o_TX_Serial : OUT std_logic;
		o_TX_Done : OUT std_logic
		);
	END COMPONENT;

	COMPONENT UART_RX
	PORT(
		i_Clk : IN std_logic;
		i_RX_Serial : IN std_logic;          
		o_RX_DV : OUT std_logic;
		o_RX_Byte : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;


    signal fifo_rd_en : std_logic;
    signal fifo_rd_empty : std_logic;
    signal fifo_rd_data : std_logic_vector(7 downto 0);
    
    signal uart_tx_en : std_logic;
    signal uart_tx_busy : std_logic;
    
    type TxState is ( TX_IDLE, TX_PREPARE_TX, TX_REQUESTED, TX_TRANSMITTED );
    signal tx_state : TxState;

    signal uart_rx_dv : std_logic;
    signal uart_rx_data : std_logic_vector(7 downto 0);
    
    signal rx_fifo_wr_data : std_logic_vector(7 downto 0);
    
    signal rx_fifo_wr_enable : std_logic;
    signal rx_fifo_rd_empty : std_logic;
    signal rx_fifo_full : std_logic;
    signal rx_fifo_rd_en : std_logic;
     
    
begin

	tx_fifo: module_fifo_regs_no_flags PORT MAP(
		i_rst_sync => reset,
		i_clk => clk,
		i_wr_en => tx_enable,
		i_wr_data => tx_data ,
		o_full => tx_full,
        
		i_rd_en => fifo_rd_en,
		o_rd_data => fifo_rd_data,
		o_empty => fifo_rd_empty 
	);
    

    uart_tx0: uart_tx PORT MAP(
		i_Clk => clk ,
		i_TX_DV => uart_tx_en,
		i_TX_Byte => fifo_rd_data,
		o_TX_Active => uart_tx_busy,
		o_TX_Serial => tx_pin
		-- o_TX_Done => 
	);

    tx_busy <= uart_tx_busy;
    
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                tx_state <= TX_IDLE;            
            else
                uart_tx_en <= '0';
                fifo_rd_en <= '0';    
                                
                case tx_State is
                when TX_IDLE =>
                    if uart_tx_busy = '0' then
                       tx_state <= TX_PREPARE_TX;
                    end if;
                when TX_PREPARE_TX =>
                    if (fifo_rd_empty = '0') and (uart_tx_busy='0') then
                        uart_tx_en <= '1';
                        fifo_rd_en <= '1';
                        tx_state <= TX_REQUESTED;
                    end if;
                when TX_REQUESTED =>                    
                    if uart_tx_busy = '0' then
                       tx_state <= TX_IDLE;
                    end if;                    
                when others =>
                    -- tx_state <= TX_IDLE;
                end case;
                
            end if; -- reset
        
        end if;
    
    end process;


	uart_rx0: UART_RX PORT MAP(
		i_Clk => clk,
		i_RX_Serial => rx_pin,
		o_RX_DV => uart_rx_dv,
		o_RX_Byte => uart_rx_data
	);

	rx_fifo: module_fifo_regs_no_flags PORT MAP(
		i_rst_sync => reset,
		i_clk => clk,
		i_wr_en => rx_fifo_wr_enable,
		i_wr_data => rx_fifo_wr_data ,
		o_full => rx_fifo_full,
        
		i_rd_en => rx_enable,
		o_rd_data => rx_data,
		o_empty => rx_empty 
	);

    process(clk)        
    begin
        if rising_edge(clk) then
            if reset = '1' then
            else
                rx_fifo_wr_enable <= '0';
                
                if uart_rx_dv = '1' then
                
                    if rx_fifo_full = '0' then
                        rx_fifo_wr_data <= uart_rx_data;
                        rx_fifo_wr_enable <= '1';     
                    end if;  
                    
                end if;
                                
            end if; -- reset
        
        end if;
    
    end process;    

end Behavioral;

