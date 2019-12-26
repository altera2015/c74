library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--library unisim;
--use unisim.vcomponents.all;

entity machine is

    generic(
        C3_P0_MASK_SIZE           : integer := 4;
        C3_P0_DATA_PORT_SIZE      : integer := 32;
        C3_P1_MASK_SIZE           : integer := 4;
        C3_P1_DATA_PORT_SIZE      : integer := 32;
        C3_MEMCLK_PERIOD        : integer := 6000; 
                                           -- Memory data transfer clock period.
        C3_RST_ACT_LOW          : integer := 0; 
                                           -- # = 1 for active low reset,
                                           -- # = 0 for active high reset.
        C3_INPUT_CLK_TYPE       : string := "SINGLE_ENDED"; 
                                           -- input clock type DIFFERENTIAL or SINGLE_ENDED.
        C3_CALIB_SOFT_IP        : string := "TRUE"; 
                                           -- # = TRUE, Enables the soft calibration logic,
                                           -- # = FALSE, Disables the soft calibration logic.
        C3_SIMULATION           : string := "FALSE"; 
                                           -- # = TRUE, Simulating the design. Useful to reduce the simulation time,
                                           -- # = FALSE, Implementing the design.
        C3_HW_TESTING           : string := "FALSE"; 
                                           -- Determines the address space accessed by the traffic generator,
                                           -- # = FALSE, Smaller address space,
                                           -- # = TRUE, Large address space.
        DEBUG_EN                : integer := 0; 
                                           -- # = 1, Enable debug signals/controls,
                                           --   = 0, Disable debug signals/controls.
        C3_MEM_ADDR_ORDER       : string := "ROW_BANK_COLUMN"; 
                                           -- The order in which user address is provided to the memory controller,
                                           -- ROW_BANK_COLUMN or BANK_ROW_COLUMN.
        C3_NUM_DQ_PINS          : integer := 16; 
                                           -- External memory data width.
        C3_MEM_ADDR_WIDTH       : integer := 13; 
                                           -- External memory address width.
        C3_MEM_BANKADDR_WIDTH   : integer := 2 
                                           -- External memory bank address width.
    );

    port ( 
        clk_100mhz          : in std_logic;        
        reset_button        : in std_logic; -- button is high when not pressed.
                
        LED                 : out std_logic_vector(7 downto 0);
        SevenSegment        : out  std_logic_vector (7 downto 0);
        SevenSegmentEnable  : out  std_logic_vector (2 downto 0); 
        
        -- VGA output
        hsync               : out  std_logic;
        vsync               : out  std_logic;
        red                 : out  std_logic_vector (2 downto 0);
        green               : out  std_logic_vector (2 downto 0);
        blue                : out  std_logic_vector (2 downto 1);
        
        -- LPDDR pins
        mcb3_dram_dq        : inout  std_logic_vector(C3_NUM_DQ_PINS-1 downto 0);
        mcb3_dram_a         : out std_logic_vector(C3_MEM_ADDR_WIDTH-1 downto 0);
        mcb3_dram_ba        : out std_logic_vector(C3_MEM_BANKADDR_WIDTH-1 downto 0);
        mcb3_dram_cke       : out std_logic;
        mcb3_dram_ras_n     : out std_logic;
        mcb3_dram_cas_n     : out std_logic;
        mcb3_dram_we_n      : out std_logic;
        mcb3_dram_dm        : out std_logic;
        mcb3_dram_udqs      : inout  std_logic;
        mcb3_rzq            : inout  std_logic;
        mcb3_dram_udm       : out std_logic;
        mcb3_dram_dqs       : inout  std_logic;
        mcb3_dram_ck        : out std_logic;
        mcb3_dram_ck_n      : out std_logic;        
        c3_rst0             : out std_logic ;

        UART_TX             : out std_logic;
        UART_RX             : in std_logic
    );
end machine;

architecture machine_arch of machine is

	COMPONENT control_logic
	PORT(
		clk                                        : IN std_logic;
		reset                                      : IN std_logic;
        
        lpddr_pA_cmd_en                            : out std_logic;
        lpddr_pA_cmd_instr                         : out std_logic_vector(2 downto 0);
        lpddr_pA_cmd_bl                            : out std_logic_vector(5 downto 0);
        lpddr_pA_cmd_byte_addr                     : out std_logic_vector(29 downto 0);
        lpddr_pA_cmd_empty                         : in std_logic;
        lpddr_pA_cmd_full                          : in std_logic;
        
        lpddr_pA_wr_en                             : out std_logic;
        lpddr_pA_wr_mask                           : out std_logic_vector(3 downto 0);
        lpddr_pA_wr_data                           : out std_logic_vector(31 downto 0);
        lpddr_pA_wr_full                           : in std_logic;
        lpddr_pA_wr_empty                          : in std_logic;
        lpddr_pA_wr_count                          : in std_logic_vector(6 downto 0);
        lpddr_pA_wr_underrun                       : in std_logic;
        lpddr_pA_wr_error                          : in std_logic;
        
        lpddr_pA_rd_en                             : out std_logic;
        lpddr_pA_rd_data                           : in std_logic_vector(31 downto 0);
        lpddr_pA_rd_full                           : in std_logic;
        lpddr_pA_rd_empty                          : in std_logic;
        lpddr_pA_rd_count                          : in std_logic_vector(6 downto 0);
        lpddr_pA_rd_overflow                       : in std_logic;
        lpddr_pA_rd_error                          : in std_logic;

        
        lpddr_pB_cmd_en                            : out std_logic;
        lpddr_pB_cmd_instr                         : out std_logic_vector(2 downto 0);
        lpddr_pB_cmd_bl                            : out std_logic_vector(5 downto 0);
        lpddr_pB_cmd_byte_addr                     : out std_logic_vector(29 downto 0);
        lpddr_pB_cmd_empty                         : in std_logic;
        lpddr_pB_cmd_full                          : in std_logic;
        
        lpddr_pB_wr_en                             : out std_logic;
        lpddr_pB_wr_mask                           : out std_logic_vector(3 downto 0);
        lpddr_pB_wr_data                           : out std_logic_vector(31 downto 0);
        lpddr_pB_wr_full                           : in std_logic;
        lpddr_pB_wr_empty                          : in std_logic;
        lpddr_pB_wr_count                          : in std_logic_vector(6 downto 0);
        lpddr_pB_wr_underrun                       : in std_logic;
        lpddr_pB_wr_error                          : in std_logic;
        
        lpddr_pB_rd_en                             : out std_logic;
        lpddr_pB_rd_data                           : in std_logic_vector(31 downto 0);
        lpddr_pB_rd_full                           : in std_logic;
        lpddr_pB_rd_empty                          : in std_logic;
        lpddr_pB_rd_count                          : in std_logic_vector(6 downto 0);
        lpddr_pB_rd_overflow                       : in std_logic;
        lpddr_pB_rd_error                          : in std_logic;
        led                                        : out std_logic_vector(7 downto 0);
        seven_seg                                  : out std_logic_vector( 7 downto 0);
        
        -- UART Pins.
   		rx_pin : IN std_logic;          
        tx_pin : OUT std_logic
	);
	END COMPONENT;

    
    component lpddr
     generic(
        C3_P0_MASK_SIZE           : integer := 4;
        C3_P0_DATA_PORT_SIZE      : integer := 32;
        C3_P1_MASK_SIZE           : integer := 4;
        C3_P1_DATA_PORT_SIZE      : integer := 32;
        C3_MEMCLK_PERIOD          : integer := 6000;
        C3_RST_ACT_LOW            : integer := 0;
        C3_INPUT_CLK_TYPE         : string := "SINGLE_ENDED";
        C3_CALIB_SOFT_IP          : string := "TRUE";
        C3_SIMULATION             : string := "FALSE";
        DEBUG_EN                  : integer := 0;
        C3_MEM_ADDR_ORDER         : string := "ROW_BANK_COLUMN";
        C3_NUM_DQ_PINS            : integer := 16;
        C3_MEM_ADDR_WIDTH         : integer := 13;
        C3_MEM_BANKADDR_WIDTH     : integer := 2
    );
        port (
       mcb3_dram_dq                            : inout  std_logic_vector(C3_NUM_DQ_PINS-1 downto 0);
       mcb3_dram_a                             : out std_logic_vector(C3_MEM_ADDR_WIDTH-1 downto 0);
       mcb3_dram_ba                            : out std_logic_vector(C3_MEM_BANKADDR_WIDTH-1 downto 0);
       mcb3_dram_cke                           : out std_logic;
       mcb3_dram_ras_n                         : out std_logic;
       mcb3_dram_cas_n                         : out std_logic;
       mcb3_dram_we_n                          : out std_logic;
       mcb3_dram_dm                            : out std_logic;
       mcb3_dram_udqs                          : inout  std_logic;
       mcb3_rzq                                : inout  std_logic;
       mcb3_dram_udm                           : out std_logic;
       c3_sys_clk                              : in  std_logic;
       c3_sys_rst_i                            : in  std_logic;
       c3_calib_done                           : out std_logic;
       c3_clk0                                 : out std_logic;
       c3_rst0                                 : out std_logic;
       mcb3_dram_dqs                           : inout  std_logic;
       mcb3_dram_ck                            : out std_logic;
       mcb3_dram_ck_n                          : out std_logic;
       c3_p0_cmd_clk                           : in std_logic;
       c3_p0_cmd_en                            : in std_logic;
       c3_p0_cmd_instr                         : in std_logic_vector(2 downto 0);
       c3_p0_cmd_bl                            : in std_logic_vector(5 downto 0);
       c3_p0_cmd_byte_addr                     : in std_logic_vector(29 downto 0);
       c3_p0_cmd_empty                         : out std_logic;
       c3_p0_cmd_full                          : out std_logic;
       c3_p0_wr_clk                            : in std_logic;
       c3_p0_wr_en                             : in std_logic;
       c3_p0_wr_mask                           : in std_logic_vector(C3_P0_MASK_SIZE - 1 downto 0);
       c3_p0_wr_data                           : in std_logic_vector(C3_P0_DATA_PORT_SIZE - 1 downto 0);
       c3_p0_wr_full                           : out std_logic;
       c3_p0_wr_empty                          : out std_logic;
       c3_p0_wr_count                          : out std_logic_vector(6 downto 0);
       c3_p0_wr_underrun                       : out std_logic;
       c3_p0_wr_error                          : out std_logic;
       c3_p0_rd_clk                            : in std_logic;
       c3_p0_rd_en                             : in std_logic;
       c3_p0_rd_data                           : out std_logic_vector(C3_P0_DATA_PORT_SIZE - 1 downto 0);
       c3_p0_rd_full                           : out std_logic;
       c3_p0_rd_empty                          : out std_logic;
       c3_p0_rd_count                          : out std_logic_vector(6 downto 0);
       c3_p0_rd_overflow                       : out std_logic;
       c3_p0_rd_error                          : out std_logic;
       c3_p1_cmd_clk                           : in std_logic;
       c3_p1_cmd_en                            : in std_logic;
       c3_p1_cmd_instr                         : in std_logic_vector(2 downto 0);
       c3_p1_cmd_bl                            : in std_logic_vector(5 downto 0);
       c3_p1_cmd_byte_addr                     : in std_logic_vector(29 downto 0);
       c3_p1_cmd_empty                         : out std_logic;
       c3_p1_cmd_full                          : out std_logic;
       c3_p1_wr_clk                            : in std_logic;
       c3_p1_wr_en                             : in std_logic;
       c3_p1_wr_mask                           : in std_logic_vector(C3_P1_MASK_SIZE - 1 downto 0);
       c3_p1_wr_data                           : in std_logic_vector(C3_P1_DATA_PORT_SIZE - 1 downto 0);
       c3_p1_wr_full                           : out std_logic;
       c3_p1_wr_empty                          : out std_logic;
       c3_p1_wr_count                          : out std_logic_vector(6 downto 0);
       c3_p1_wr_underrun                       : out std_logic;
       c3_p1_wr_error                          : out std_logic;
       c3_p1_rd_clk                            : in std_logic;
       c3_p1_rd_en                             : in std_logic;
       c3_p1_rd_data                           : out std_logic_vector(C3_P1_DATA_PORT_SIZE - 1 downto 0);
       c3_p1_rd_full                           : out std_logic;
       c3_p1_rd_empty                          : out std_logic;
       c3_p1_rd_count                          : out std_logic_vector(6 downto 0);
       c3_p1_rd_overflow                       : out std_logic;
       c3_p1_rd_error                          : out std_logic;
       c3_p2_cmd_clk                           : in std_logic;
       c3_p2_cmd_en                            : in std_logic;
       c3_p2_cmd_instr                         : in std_logic_vector(2 downto 0);
       c3_p2_cmd_bl                            : in std_logic_vector(5 downto 0);
       c3_p2_cmd_byte_addr                     : in std_logic_vector(29 downto 0);
       c3_p2_cmd_empty                         : out std_logic;
       c3_p2_cmd_full                          : out std_logic;
       c3_p2_rd_clk                            : in std_logic;
       c3_p2_rd_en                             : in std_logic;
       c3_p2_rd_data                           : out std_logic_vector(31 downto 0);
       c3_p2_rd_full                           : out std_logic;
       c3_p2_rd_empty                          : out std_logic;
       c3_p2_rd_count                          : out std_logic_vector(6 downto 0);
       c3_p2_rd_overflow                       : out std_logic;
       c3_p2_rd_error                          : out std_logic;
       c3_p3_cmd_clk                           : in std_logic;
       c3_p3_cmd_en                            : in std_logic;
       c3_p3_cmd_instr                         : in std_logic_vector(2 downto 0);
       c3_p3_cmd_bl                            : in std_logic_vector(5 downto 0);
       c3_p3_cmd_byte_addr                     : in std_logic_vector(29 downto 0);
       c3_p3_cmd_empty                         : out std_logic;
       c3_p3_cmd_full                          : out std_logic;
       c3_p3_rd_clk                            : in std_logic;
       c3_p3_rd_en                             : in std_logic;
       c3_p3_rd_data                           : out std_logic_vector(31 downto 0);
       c3_p3_rd_full                           : out std_logic;
       c3_p3_rd_empty                          : out std_logic;
       c3_p3_rd_count                          : out std_logic_vector(6 downto 0);
       c3_p3_rd_overflow                       : out std_logic;
       c3_p3_rd_error                          : out std_logic;
       user_clk                                : out std_logic
    );
    end component;
    
    
	COMPONENT vga_framebuffer
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		cmd_empty : IN std_logic;
		cmd_full : IN std_logic;
		rd_data : IN std_logic_vector(31 downto 0);
		rd_full : IN std_logic;
		rd_empty : IN std_logic;
		rd_count : IN std_logic_vector(6 downto 0);
		rd_overflow : IN std_logic;
		rd_error : IN std_logic;          
		hsync : OUT std_logic;
		vsync : OUT std_logic;
		red : OUT std_logic_vector(2 downto 0);
		green : OUT std_logic_vector(2 downto 0);
		blue : OUT std_logic_vector(2 downto 1);
		cmd_en : OUT std_logic;
		cmd_instr : OUT std_logic_vector(2 downto 0);
		cmd_bl : OUT std_logic_vector(5 downto 0);
		cmd_byte_addr : OUT std_logic_vector(29 downto 0);
		rd_en : OUT std_logic
		);
	END COMPONENT;    
    
    
    	COMPONENT pattern_generator
    	PORT(
    		clk : IN std_logic;
    		reset : IN std_logic;
    		cmd_empty : IN std_logic;
    		cmd_full : IN std_logic;
    		wr_full : IN std_logic;
    		wr_empty : IN std_logic;
    		wr_count : IN std_logic_vector(6 downto 0);
    		wr_underrun : IN std_logic;
    		wr_error : IN std_logic;          
    		done : OUT std_logic;
    		cmd_en : OUT std_logic;
    		cmd_instr : OUT std_logic_vector(2 downto 0);
    		cmd_bl : OUT std_logic_vector(5 downto 0);
    		cmd_byte_addr : OUT std_logic_vector(29 downto 0);
    		wr_en : OUT std_logic;
    		wr_mask : OUT std_logic_vector(3 downto 0);
    		wr_data : OUT std_logic_vector(31 downto 0)
    		);
    	END COMPONENT;
        

    signal master_reset : std_logic;
    signal reset : std_logic;
    signal pattern_generate_done : std_logic;

    -- Memory Connectivity.    
    signal  c3_calib_done                            : std_logic;
    signal  clk                                      : std_logic;
    signal  c3_p0_cmd_en                             : std_logic;
    signal  c3_p0_cmd_instr                          : std_logic_vector(2 downto 0);
    signal  c3_p0_cmd_bl                             : std_logic_vector(5 downto 0);
    signal  c3_p0_cmd_byte_addr                      : std_logic_vector(29 downto 0);
    signal  c3_p0_cmd_empty                          : std_logic;
    signal  c3_p0_cmd_full                           : std_logic;
    signal  c3_p0_wr_en                              : std_logic;
    signal  c3_p0_wr_mask                            : std_logic_vector(C3_P0_MASK_SIZE - 1 downto 0);
    signal  c3_p0_wr_data                            : std_logic_vector(C3_P0_DATA_PORT_SIZE - 1 downto 0);
    signal  c3_p0_wr_full                            : std_logic;
    signal  c3_p0_wr_empty                           : std_logic;
    signal  c3_p0_wr_count                           : std_logic_vector(6 downto 0);
    signal  c3_p0_wr_underrun                        : std_logic;
    signal  c3_p0_wr_error                           : std_logic;
    signal  c3_p0_rd_en                              : std_logic;
    signal  c3_p0_rd_data                            : std_logic_vector(C3_P0_DATA_PORT_SIZE - 1 downto 0);
    signal  c3_p0_rd_full                            : std_logic;
    signal  c3_p0_rd_empty                           : std_logic;
    signal  c3_p0_rd_count                           : std_logic_vector(6 downto 0);
    signal  c3_p0_rd_overflow                        : std_logic;
    signal  c3_p0_rd_error                           : std_logic;

    signal  c3_p1_cmd_en                             : std_logic;
    signal  c3_p1_cmd_instr                          : std_logic_vector(2 downto 0);
    signal  c3_p1_cmd_bl                             : std_logic_vector(5 downto 0);
    signal  c3_p1_cmd_byte_addr                      : std_logic_vector(29 downto 0);
    signal  c3_p1_cmd_empty                          : std_logic;
    signal  c3_p1_cmd_full                           : std_logic;
    signal  c3_p1_wr_en                              : std_logic;
    signal  c3_p1_wr_mask                            : std_logic_vector(C3_P1_MASK_SIZE - 1 downto 0);
    signal  c3_p1_wr_data                            : std_logic_vector(C3_P1_DATA_PORT_SIZE - 1 downto 0);
    signal  c3_p1_wr_full                            : std_logic;
    signal  c3_p1_wr_empty                           : std_logic;
    signal  c3_p1_wr_count                           : std_logic_vector(6 downto 0);
    signal  c3_p1_wr_underrun                        : std_logic;
    signal  c3_p1_wr_error                           : std_logic;
    signal  c3_p1_rd_en                              : std_logic;
    signal  c3_p1_rd_data                            : std_logic_vector(C3_P1_DATA_PORT_SIZE - 1 downto 0);
    signal  c3_p1_rd_full                            : std_logic;
    signal  c3_p1_rd_empty                           : std_logic;
    signal  c3_p1_rd_count                           : std_logic_vector(6 downto 0);
    signal  c3_p1_rd_overflow                        : std_logic;
    signal  c3_p1_rd_error                           : std_logic;    

    signal  c3_p2_cmd_en                             : std_logic;
    signal  c3_p2_cmd_instr                          : std_logic_vector(2 downto 0);
    signal  c3_p2_cmd_bl                             : std_logic_vector(5 downto 0);
    signal  c3_p2_cmd_byte_addr                      : std_logic_vector(29 downto 0);
    signal  c3_p2_cmd_empty                          : std_logic;
    signal  c3_p2_cmd_full                           : std_logic;
    signal  c3_p2_rd_en                              : std_logic;
    signal  c3_p2_rd_data                            : std_logic_vector(C3_P1_DATA_PORT_SIZE - 1 downto 0);
    signal  c3_p2_rd_full                            : std_logic;
    signal  c3_p2_rd_empty                           : std_logic;
    signal  c3_p2_rd_count                           : std_logic_vector(6 downto 0);
    signal  c3_p2_rd_overflow                        : std_logic;
    signal  c3_p2_rd_error                           : std_logic; 
    
    signal  c3_p3_cmd_en                             : std_logic;
    signal  c3_p3_cmd_instr                          : std_logic_vector(2 downto 0);
    signal  c3_p3_cmd_bl                             : std_logic_vector(5 downto 0);
    signal  c3_p3_cmd_byte_addr                      : std_logic_vector(29 downto 0);
    signal  c3_p3_cmd_empty                          : std_logic;
    signal  c3_p3_cmd_full                           : std_logic;
    signal  c3_p3_rd_en                              : std_logic;
    signal  c3_p3_rd_data                            : std_logic_vector(C3_P1_DATA_PORT_SIZE - 1 downto 0);
    signal  c3_p3_rd_full                            : std_logic;
    signal  c3_p3_rd_empty                           : std_logic;
    signal  c3_p3_rd_count                           : std_logic_vector(6 downto 0);
    signal  c3_p3_rd_overflow                        : std_logic;
    signal  c3_p3_rd_error                           : std_logic; 
    signal  user_clk                                 : std_logic;
    signal  framebuffer_reset                        : std_logic;
begin
   
    master_reset <= not reset_button;


    u_lpddr3 : lpddr
        generic map (
            C3_P0_MASK_SIZE => C3_P0_MASK_SIZE,
            C3_P0_DATA_PORT_SIZE => C3_P0_DATA_PORT_SIZE,
            C3_P1_MASK_SIZE => C3_P1_MASK_SIZE,
            C3_P1_DATA_PORT_SIZE => C3_P1_DATA_PORT_SIZE,
            C3_MEMCLK_PERIOD => C3_MEMCLK_PERIOD,
            C3_RST_ACT_LOW => C3_RST_ACT_LOW,
            C3_INPUT_CLK_TYPE => C3_INPUT_CLK_TYPE,
            C3_CALIB_SOFT_IP => C3_CALIB_SOFT_IP,
            C3_SIMULATION => C3_SIMULATION,
            DEBUG_EN => DEBUG_EN,
            C3_MEM_ADDR_ORDER => C3_MEM_ADDR_ORDER,
            C3_NUM_DQ_PINS => C3_NUM_DQ_PINS,
            C3_MEM_ADDR_WIDTH => C3_MEM_ADDR_WIDTH,
            C3_MEM_BANKADDR_WIDTH => C3_MEM_BANKADDR_WIDTH
        )
        port map (

            c3_sys_clk         =>    clk_100mhz,
            c3_sys_rst_i       =>    master_reset,                        

            mcb3_dram_dq       =>    mcb3_dram_dq,  
            mcb3_dram_a        =>    mcb3_dram_a,  
            mcb3_dram_ba       =>    mcb3_dram_ba,
            mcb3_dram_ras_n    =>    mcb3_dram_ras_n,                        
            mcb3_dram_cas_n    =>    mcb3_dram_cas_n,                        
            mcb3_dram_we_n     =>    mcb3_dram_we_n,                          
            mcb3_dram_cke      =>    mcb3_dram_cke,                          
            mcb3_dram_ck       =>    mcb3_dram_ck,                          
            mcb3_dram_ck_n     =>    mcb3_dram_ck_n,       
            mcb3_dram_dqs      =>    mcb3_dram_dqs,                          
            mcb3_dram_udqs  =>       mcb3_dram_udqs,    -- for X16 parts           
            mcb3_dram_udm  =>        mcb3_dram_udm,     -- for X16 parts
            mcb3_dram_dm  =>         mcb3_dram_dm,
            c3_clk0	=>	             clk,
            c3_rst0		=>           c3_rst0,
            c3_calib_done      =>    c3_calib_done,
            mcb3_rzq         =>            mcb3_rzq,
            user_clk         => user_clk,
            c3_p0_cmd_clk                           =>  user_clk,
            c3_p0_cmd_en                            =>  c3_p0_cmd_en,
            c3_p0_cmd_instr                         =>  c3_p0_cmd_instr,
            c3_p0_cmd_bl                            =>  c3_p0_cmd_bl,
            c3_p0_cmd_byte_addr                     =>  c3_p0_cmd_byte_addr,
            c3_p0_cmd_empty                         =>  c3_p0_cmd_empty,
            c3_p0_cmd_full                          =>  c3_p0_cmd_full,
            c3_p0_wr_clk                            =>  user_clk,
            c3_p0_wr_en                             =>  c3_p0_wr_en,
            c3_p0_wr_mask                           =>  c3_p0_wr_mask,
            c3_p0_wr_data                           =>  c3_p0_wr_data,
            c3_p0_wr_full                           =>  c3_p0_wr_full,
            c3_p0_wr_empty                          =>  c3_p0_wr_empty,
            c3_p0_wr_count                          =>  c3_p0_wr_count,
            c3_p0_wr_underrun                       =>  c3_p0_wr_underrun,
            c3_p0_wr_error                          =>  c3_p0_wr_error,
            c3_p0_rd_clk                            =>  user_clk,
            c3_p0_rd_en                             =>  c3_p0_rd_en,
            c3_p0_rd_data                           =>  c3_p0_rd_data,
            c3_p0_rd_full                           =>  c3_p0_rd_full,
            c3_p0_rd_empty                          =>  c3_p0_rd_empty,
            c3_p0_rd_count                          =>  c3_p0_rd_count,
            c3_p0_rd_overflow                       =>  c3_p0_rd_overflow,
            c3_p0_rd_error                          =>  c3_p0_rd_error,
            c3_p1_cmd_clk                           =>  user_clk,
            c3_p1_cmd_en                            =>  c3_p1_cmd_en,
            c3_p1_cmd_instr                         =>  c3_p1_cmd_instr,
            c3_p1_cmd_bl                            =>  c3_p1_cmd_bl,
            c3_p1_cmd_byte_addr                     =>  c3_p1_cmd_byte_addr,
            c3_p1_cmd_empty                         =>  c3_p1_cmd_empty,
            c3_p1_cmd_full                          =>  c3_p1_cmd_full,
            c3_p1_wr_clk                            =>  user_clk,
            c3_p1_wr_en                             =>  c3_p1_wr_en,
            c3_p1_wr_mask                           =>  c3_p1_wr_mask,
            c3_p1_wr_data                           =>  c3_p1_wr_data,
            c3_p1_wr_full                           =>  c3_p1_wr_full,
            c3_p1_wr_empty                          =>  c3_p1_wr_empty,
            c3_p1_wr_count                          =>  c3_p1_wr_count,
            c3_p1_wr_underrun                       =>  c3_p1_wr_underrun,
            c3_p1_wr_error                          =>  c3_p1_wr_error,
            c3_p1_rd_clk                            =>  user_clk,
            c3_p1_rd_en                             =>  c3_p1_rd_en,
            c3_p1_rd_data                           =>  c3_p1_rd_data,
            c3_p1_rd_full                           =>  c3_p1_rd_full,
            c3_p1_rd_empty                          =>  c3_p1_rd_empty,
            c3_p1_rd_count                          =>  c3_p1_rd_count,
            c3_p1_rd_overflow                       =>  c3_p1_rd_overflow,
            c3_p1_rd_error                          =>  c3_p1_rd_error,
            c3_p2_cmd_clk                           =>  user_clk,
            c3_p2_cmd_en                            =>  c3_p2_cmd_en,
            c3_p2_cmd_instr                         =>  c3_p2_cmd_instr,
            c3_p2_cmd_bl                            =>  c3_p2_cmd_bl,
            c3_p2_cmd_byte_addr                     =>  c3_p2_cmd_byte_addr,
            c3_p2_cmd_empty                         =>  c3_p2_cmd_empty,
            c3_p2_cmd_full                          =>  c3_p2_cmd_full,
            c3_p2_rd_clk                            =>  user_clk,
            c3_p2_rd_en                             =>  c3_p2_rd_en,
            c3_p2_rd_data                           =>  c3_p2_rd_data,
            c3_p2_rd_full                           =>  c3_p2_rd_full,
            c3_p2_rd_empty                          =>  c3_p2_rd_empty,
            c3_p2_rd_count                          =>  c3_p2_rd_count,
            c3_p2_rd_overflow                       =>  c3_p2_rd_overflow,
            c3_p2_rd_error                          =>  c3_p2_rd_error,
            
            
            -- vga frame buffer on clk attached to port 3.
            c3_p3_cmd_clk                           =>  clk,
            c3_p3_cmd_en                            =>  c3_p3_cmd_en,
            c3_p3_cmd_instr                         =>  c3_p3_cmd_instr,
            c3_p3_cmd_bl                            =>  c3_p3_cmd_bl,
            c3_p3_cmd_byte_addr                     =>  c3_p3_cmd_byte_addr,
            c3_p3_cmd_empty                         =>  c3_p3_cmd_empty,
            c3_p3_cmd_full                          =>  c3_p3_cmd_full,
            c3_p3_rd_clk                            =>  clk,
            c3_p3_rd_en                             =>  c3_p3_rd_en,
            c3_p3_rd_data                           =>  c3_p3_rd_data,
            c3_p3_rd_full                           =>  c3_p3_rd_full,
            c3_p3_rd_empty                          =>  c3_p3_rd_empty,
            c3_p3_rd_count                          =>  c3_p3_rd_count,
            c3_p3_rd_overflow                       =>  c3_p3_rd_overflow,
            c3_p3_rd_error                          =>  c3_p3_rd_error
    );



    process(clk)
    begin
        if rising_edge(clk) then
            if master_reset = '1' or c3_calib_done = '0' then
                framebuffer_reset <= '1';
            else
                framebuffer_reset <= '0';
            end if;            
        end if;
    end process;
    

	vga_framebuffer0: vga_framebuffer PORT MAP(
		clk => clk,
		reset => framebuffer_reset,
		hsync => hsync,
		vsync => vsync,
		red => red,
		green => green,
		blue => blue,
		cmd_en => c3_p3_cmd_en,
		cmd_instr => c3_p3_cmd_instr,
		cmd_bl => c3_p3_cmd_bl,
		cmd_byte_addr => c3_p3_cmd_byte_addr,
		cmd_empty => c3_p3_cmd_empty,
		cmd_full => c3_p3_cmd_full,
		rd_en => c3_p3_rd_en,
		rd_data => c3_p3_rd_data,
		rd_full => c3_p3_rd_full,
		rd_empty => c3_p3_rd_empty,
		rd_count => c3_p3_rd_count,
		rd_overflow => c3_p3_rd_overflow,
		rd_error => c3_p3_rd_error
	);



    c3_p2_cmd_en <= '0';
    c3_p2_rd_en <= '0';
    
    -- c3_p2_wd_en <= '0';
    
--    c3_p2_cmd_instr <= "000";
--    c3_p2_cmd_bl <= "000000";
--    c3_p2_cmd_byte_addr <= (others=>'0');
    
    -- c3_p0_cmd_en <= '0';
    -- c3_p1_rd_en <= '0';
    --c3_p0_wr_en <= '0';
    
    process(user_clk)
    begin
        if rising_edge(user_clk) then
            if master_reset = '1' or c3_calib_done = '0' then
                reset <= '1';
            else
                reset <= '0';
            end if;            
        end if;
    end process;

--    uncomment when using the pattern generator.
--    c3_p0_cmd_en <= '0';
--    c3_p0_rd_en <= '0';
--    c3_p0_wr_en <= '0';
--    c3_p1_rd_en <= '0';

--	pattern_generator0: pattern_generator PORT MAP(
--		clk => user_clk,
--		reset => reset,
--		done => pattern_generate_done,
--		cmd_en => c3_p1_cmd_en,
--		cmd_instr => c3_p1_cmd_instr,
--		cmd_bl => c3_p1_cmd_bl,
--		cmd_byte_addr => c3_p1_cmd_byte_addr,
--		cmd_empty => c3_p1_cmd_empty,
--		cmd_full => c3_p1_cmd_full,
--		wr_en => c3_p1_wr_en,
--		wr_mask => c3_p1_wr_mask,
--		wr_data => c3_p1_wr_data,
--		wr_full => c3_p1_wr_full,
--		wr_empty => c3_p1_wr_empty,
--		wr_count => c3_p1_wr_count,
--		wr_underrun => c3_p1_wr_underrun,
--		wr_error => c3_p1_wr_error
--	);

	control_logic0: control_logic PORT MAP(
		clk => user_clk,
		reset => reset,
		lpddr_pA_cmd_en => c3_p0_cmd_en,
		lpddr_pA_cmd_instr => c3_p0_cmd_instr,
		lpddr_pA_cmd_bl => c3_p0_cmd_bl,
		lpddr_pA_cmd_byte_addr => c3_p0_cmd_byte_addr,
		lpddr_pA_cmd_empty => c3_p0_cmd_empty,
		lpddr_pA_cmd_full => c3_p0_cmd_full,
		lpddr_pA_wr_en => c3_p0_wr_en,
		lpddr_pA_wr_mask => c3_p0_wr_mask,
		lpddr_pA_wr_data => c3_p0_wr_data,
		lpddr_pA_wr_full => c3_p0_wr_full,
		lpddr_pA_wr_empty => c3_p0_wr_empty,
		lpddr_pA_wr_count => c3_p0_wr_count,
		lpddr_pA_wr_underrun => c3_p0_wr_underrun,
		lpddr_pA_wr_error => c3_p0_wr_error,
		lpddr_pA_rd_en => c3_p0_rd_en,
		lpddr_pA_rd_data => c3_p0_rd_data,
		lpddr_pA_rd_full => c3_p0_rd_full,
		lpddr_pA_rd_empty => c3_p0_rd_empty,
		lpddr_pA_rd_count => c3_p0_rd_count,
		lpddr_pA_rd_overflow => c3_p0_rd_overflow,
		lpddr_pA_rd_error => c3_p0_rd_error,
		lpddr_pB_cmd_en => c3_p1_cmd_en,
		lpddr_pB_cmd_instr => c3_p1_cmd_instr,
		lpddr_pB_cmd_bl => c3_p1_cmd_bl,
		lpddr_pB_cmd_byte_addr => c3_p1_cmd_byte_addr,
		lpddr_pB_cmd_empty => c3_p1_cmd_empty,
		lpddr_pB_cmd_full => c3_p1_cmd_full,
		lpddr_pB_wr_en => c3_p1_wr_en,
		lpddr_pB_wr_mask => c3_p1_wr_mask,
		lpddr_pB_wr_data => c3_p1_wr_data,
		lpddr_pB_wr_full => c3_p1_wr_full,
		lpddr_pB_wr_empty => c3_p1_wr_empty,
		lpddr_pB_wr_count => c3_p1_wr_count,
		lpddr_pB_wr_underrun => c3_p1_wr_underrun,
		lpddr_pB_wr_error => c3_p1_wr_error,
		lpddr_pB_rd_en => c3_p1_rd_en,
		lpddr_pB_rd_data => c3_p1_rd_data,
		lpddr_pB_rd_full => c3_p1_rd_full,
		lpddr_pB_rd_empty => c3_p1_rd_empty,
		lpddr_pB_rd_count => c3_p1_rd_count,
		lpddr_pB_rd_overflow => c3_p1_rd_overflow,
		lpddr_pB_rd_error => c3_p1_rd_error,
        led=>led,
        tx_pin => UART_TX,
        rx_pin => UART_RX
     );


    -- disable 7 segment displays
    SevenSegmentEnable <= "111";
    SevenSegment <= "11111111";

    -- LED outputs
--    LED(0) <= c3_calib_done;    
--    LED(1) <= pattern_generate_done;
--    LED(2) <= '0';
--    LED(3) <= '0';
--    LED(4) <= '0';
--    LED(5) <= '0';
--    LED(6) <= '0';
--    LED(7) <= '0';
--    

end machine_arch;