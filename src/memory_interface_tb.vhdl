--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:15:12 12/17/2019
-- Design Name:   
-- Module Name:   /home/ise/devel/c74.000/src/low_mem/memory_interface_tb.vhdl
-- Project Name:  C74.000
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: memory_interface
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
library unisim;
use unisim.vcomponents.all;

ENTITY memory_interface_tb IS
END memory_interface_tb;
 
ARCHITECTURE behavior OF memory_interface_tb IS 


    constant C3_MEM_ADDR_ORDER     : string := "ROW_BANK_COLUMN"; 
    constant C3_NUM_DQ_PINS        : integer := 16;
    constant C3_MEM_ADDR_WIDTH     : integer := 13;
    constant C3_MEM_BANKADDR_WIDTH : integer := 2; 
    constant C3_SIMULATION         : string := "TRUE"; 
    constant DEBUG_EN              : integer := 0; 
    constant C3_RST_ACT_LOW        : integer := 0; 
    constant C3_CALIB_SOFT_IP      : string := "TRUE"; 
    constant C3_INPUT_CLK_TYPE     : string := "SINGLE_ENDED"; 
    constant C3_P0_MASK_SIZE       : integer := 4;
    constant C3_P0_DATA_PORT_SIZE  : integer := 32;
    constant C3_P1_MASK_SIZE       : integer := 4;
    constant C3_P1_DATA_PORT_SIZE  : integer := 32;    
    constant C3_MEMCLK_PERIOD      : integer := 6000; 
    
    COMPONENT memory_interface
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
 
         a_address : IN  std_logic_vector(31 downto 0);
         a_D : IN  std_logic_vector(31 downto 0);
         a_RE : IN  std_logic;
         a_WE : IN  std_logic_vector(3 downto 0);
         a_ready : OUT  std_logic;
         a_Q : OUT  std_logic_vector(31 downto 0);

         b_address : IN  std_logic_vector(31 downto 0);
         b_D : IN  std_logic_vector(31 downto 0);
         b_RE : IN  std_logic;
         b_WE : IN  std_logic_vector(3 downto 0);
         b_ready : OUT  std_logic;
         b_Q : OUT  std_logic_vector(31 downto 0);
         
         lpddr_pA_cmd_en : OUT  std_logic;
         lpddr_pA_cmd_instr : OUT  std_logic_vector(2 downto 0);
         lpddr_pA_cmd_bl : OUT  std_logic_vector(5 downto 0);
         lpddr_pA_cmd_byte_addr : OUT  std_logic_vector(29 downto 0);
         lpddr_pA_cmd_empty : IN  std_logic;
         lpddr_pA_cmd_full : IN  std_logic;
         
         lpddr_pA_wr_en : OUT  std_logic;
         lpddr_pA_wr_mask : OUT  std_logic_vector(3 downto 0);
         lpddr_pA_wr_data : OUT  std_logic_vector(31 downto 0);
         lpddr_pA_wr_full : IN  std_logic;
         lpddr_pA_wr_empty : IN  std_logic;
         lpddr_pA_wr_count : IN  std_logic_vector(6 downto 0);
         lpddr_pA_wr_underrun : IN  std_logic;
         lpddr_pA_wr_error : IN  std_logic;

         lpddr_pA_rd_en : OUT  std_logic;
         lpddr_pA_rd_data : IN  std_logic_vector(31 downto 0);
         lpddr_pA_rd_full : IN  std_logic;
         lpddr_pA_rd_empty : IN  std_logic;
         lpddr_pA_rd_count : IN  std_logic_vector(6 downto 0);
         lpddr_pA_rd_overflow : IN  std_logic;
         lpddr_pA_rd_error : IN  std_logic;
         lpddr_pB_cmd_en : OUT  std_logic;
         lpddr_pB_cmd_instr : OUT  std_logic_vector(2 downto 0);
         lpddr_pB_cmd_bl : OUT  std_logic_vector(5 downto 0);
         lpddr_pB_cmd_byte_addr : OUT  std_logic_vector(29 downto 0);
         lpddr_pB_cmd_empty : IN  std_logic;
         lpddr_pB_cmd_full : IN  std_logic;
         
         lpddr_pB_wr_en : OUT  std_logic;
         lpddr_pB_wr_mask : OUT  std_logic_vector(3 downto 0);
         lpddr_pB_wr_data : OUT  std_logic_vector(31 downto 0);
         lpddr_pB_wr_full : IN  std_logic;
         lpddr_pB_wr_empty : IN  std_logic;
         lpddr_pB_wr_count : IN  std_logic_vector(6 downto 0);
         lpddr_pB_wr_underrun : IN  std_logic;
         lpddr_pB_wr_error : IN  std_logic;
         
         lpddr_pB_rd_en : OUT  std_logic;
         lpddr_pB_rd_data : IN  std_logic_vector(31 downto 0);
         lpddr_pB_rd_full : IN  std_logic;
         lpddr_pB_rd_empty : IN  std_logic;
         lpddr_pB_rd_count : IN  std_logic_vector(6 downto 0);
         lpddr_pB_rd_overflow : IN  std_logic;
         lpddr_pB_rd_error : IN  std_logic
        );
    END COMPONENT;
    
    component lpddr_model_c3 is
    port (
      Clk     : in    std_logic;
      Clk_n   : in    std_logic;
      Cke     : in    std_logic;
      Cs_n    : in    std_logic;
      Ras_n   : in    std_logic;
      Cas_n   : in    std_logic;
      We_n    : in    std_logic;
      Dm      : inout std_logic_vector((C3_NUM_DQ_PINS/16) downto 0);
      Ba      : in    std_logic_vector((C3_MEM_BANKADDR_WIDTH - 1) downto 0);
      Addr    : in    std_logic_vector((C3_MEM_ADDR_WIDTH  - 1) downto 0);
      Dq      : inout std_logic_vector((C3_NUM_DQ_PINS - 1) downto 0);
      Dqs     : inout std_logic_vector((C3_NUM_DQ_PINS/16) downto 0)
      );
    end component;    
    
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
       c3_p3_rd_error                          : out std_logic
    );
    end component;



   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal a_address_load : std_logic := '0';
   signal a_address : std_logic_vector(31 downto 0) := (others => '0');
   signal a_D : std_logic_vector(31 downto 0) := (others => '0');
   signal a_RE : std_logic := '0';
   signal a_WE : std_logic_vector(3 downto 0) := (others => '0');
   signal b_address_load : std_logic := '0';
   signal b_address : std_logic_vector(31 downto 0) := (others => '0');
   signal b_D : std_logic_vector(31 downto 0) := (others => '0');
   signal b_RE : std_logic := '0';
   signal b_WE : std_logic_vector(3 downto 0) := (others => '0');
   signal lpddr_pA_cmd_empty : std_logic := '0';
   signal lpddr_pA_cmd_full : std_logic := '0';
   signal lpddr_pA_wr_full : std_logic := '0';
   signal lpddr_pA_wr_empty : std_logic := '0';
   signal lpddr_pA_wr_count : std_logic_vector(6 downto 0) := (others => '0');
   signal lpddr_pA_wr_underrun : std_logic := '0';
   signal lpddr_pA_wr_error : std_logic := '0';
   signal lpddr_pA_rd_data : std_logic_vector(31 downto 0) := (others => '0');
   signal lpddr_pA_rd_full : std_logic := '0';
   signal lpddr_pA_rd_empty : std_logic := '0';
   signal lpddr_pA_rd_count : std_logic_vector(6 downto 0) := (others => '0');
   signal lpddr_pA_rd_overflow : std_logic := '0';
   signal lpddr_pA_rd_error : std_logic := '0';
   signal lpddr_pB_cmd_empty : std_logic := '0';
   signal lpddr_pB_cmd_full : std_logic := '0';
   signal lpddr_pB_wr_full : std_logic := '0';
   signal lpddr_pB_wr_empty : std_logic := '0';
   signal lpddr_pB_wr_count : std_logic_vector(6 downto 0) := (others => '0');
   signal lpddr_pB_wr_underrun : std_logic := '0';
   signal lpddr_pB_wr_error : std_logic := '0';
   signal lpddr_pB_rd_data : std_logic_vector(31 downto 0) := (others => '0');
   signal lpddr_pB_rd_full : std_logic := '0';
   signal lpddr_pB_rd_empty : std_logic := '0';
   signal lpddr_pB_rd_count : std_logic_vector(6 downto 0) := (others => '0');
   signal lpddr_pB_rd_overflow : std_logic := '0';
   signal lpddr_pB_rd_error : std_logic := '0';

 	--Outputs
   signal a_ready : std_logic;
   signal a_Q : std_logic_vector(31 downto 0);
   signal b_ready : std_logic;
   signal b_Q : std_logic_vector(31 downto 0);
   signal lpddr_pA_cmd_en : std_logic;
   signal lpddr_pA_cmd_instr : std_logic_vector(2 downto 0);
   signal lpddr_pA_cmd_bl : std_logic_vector(5 downto 0);
   signal lpddr_pA_cmd_byte_addr : std_logic_vector(29 downto 0);
   signal lpddr_pA_wr_clk : std_logic;
   signal lpddr_pA_wr_en : std_logic;
   signal lpddr_pA_wr_mask : std_logic_vector(3 downto 0);
   signal lpddr_pA_wr_data : std_logic_vector(31 downto 0);
   signal lpddr_pA_rd_clk : std_logic;
   signal lpddr_pA_rd_en : std_logic;
   signal lpddr_pB_cmd_en : std_logic;
   signal lpddr_pB_cmd_instr : std_logic_vector(2 downto 0);
   signal lpddr_pB_cmd_bl : std_logic_vector(5 downto 0);
   signal lpddr_pB_cmd_byte_addr : std_logic_vector(29 downto 0);
   signal lpddr_pB_wr_clk : std_logic;
   signal lpddr_pB_wr_en : std_logic;
   signal lpddr_pB_wr_mask : std_logic_vector(3 downto 0);
   signal lpddr_pB_wr_data : std_logic_vector(31 downto 0);
   signal lpddr_pB_rd_clk : std_logic;
   signal lpddr_pB_rd_en : std_logic;


	--BiDirs
   signal mcb3_dram_dq : std_logic_vector(15 downto 0);
   signal mcb3_dram_udqs : std_logic;
   signal mcb3_rzq : std_logic;
   signal mcb3_dram_dqs : std_logic;

 	--Outputs
   signal mcb3_dram_a : std_logic_vector(12 downto 0);
   signal mcb3_dram_ba : std_logic_vector(1 downto 0);
   signal mcb3_dram_cke : std_logic;
   signal mcb3_dram_ras_n : std_logic;
   signal mcb3_dram_cas_n : std_logic;
   signal mcb3_dram_we_n : std_logic;
   signal mcb3_dram_dm : std_logic;
   signal mcb3_dram_udm : std_logic;
   signal mcb3_dram_ck : std_logic;
   signal mcb3_dram_ck_n : std_logic;
   signal c3_rst0 : std_logic;

   signal mcb3_dram_dqs_vector : std_logic_vector(1 downto 0);  
   signal mcb3_dram_dm_vector : std_logic_vector(1 downto 0);
   signal mcb3_command : std_logic_vector(2 downto 0);
   signal mcb3_enable1 : std_logic;
   signal mcb3_enable2 : std_logic;  
   
   signal c3_calib_done : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
   signal clk_100mhz : std_logic;
   signal master_reset : std_logic;
   
   
   
   
    -- declare record type
    type test_vector is record
        address : std_logic_vector(31 downto 0);
        data : std_logic_vector(31 downto 0);
    end record; 

    type test_vector_array is array (natural range <>) of test_vector;
    constant test_vectors : test_vector_array := (
        ("00000000000000000000000000000000", "00000000000000000000000011111111"),
        ("00000000000000000000000000000100", "00000000000000000000000000001111"),
        ("00000000000000000000100000001000", "00000000000000000000000011111111"),
        ("00000000000000000000100000001100", "00000000000000000000000000001111")
        );   
   
 
BEGIN
 
   rzq_pulldown3 : PULLDOWN port map(O => mcb3_rzq);
   mcb3_command <= (mcb3_dram_ras_n & mcb3_dram_cas_n & mcb3_dram_we_n);

   process(mcb3_dram_ck)
   begin
      if (rising_edge(mcb3_dram_ck)) then
        if (master_reset = '1') then
          mcb3_enable1   <= '0';
          mcb3_enable2 <= '0';
        elsif (mcb3_command = "100") then
          mcb3_enable2 <= '0';
        elsif (mcb3_command = "101") then
          mcb3_enable2 <= '1';
        else
          mcb3_enable2 <= mcb3_enable2;
        end if;
        mcb3_enable1     <= mcb3_enable2;
      end if;
   end process;
 
 -----------------------------------------------------------------------------
--read
-----------------------------------------------------------------------------
    mcb3_dram_dqs_vector(1 downto 0)               <= (mcb3_dram_udqs & mcb3_dram_dqs)
                                                           when (mcb3_enable2 = '0' and mcb3_enable1 = '0')
							   else "ZZ";

-----------------------------------------------------------------------------
--write
-----------------------------------------------------------------------------
    mcb3_dram_dqs          <= mcb3_dram_dqs_vector(0)
                              when ( mcb3_enable1 = '1') else 'Z';

    mcb3_dram_udqs          <= mcb3_dram_dqs_vector(1)
                              when (mcb3_enable1 = '1') else 'Z';
    mcb3_dram_dm_vector <= (mcb3_dram_udm & mcb3_dram_dm);
    
    lpddr0 : lpddr_model_c3 port map(
        Clk        => mcb3_dram_ck,
        Clk_n      => mcb3_dram_ck_n,
        Cke       => mcb3_dram_cke,
        Cs_n      => '0',
        Ras_n     => mcb3_dram_ras_n,
        Cas_n     => mcb3_dram_cas_n,
        We_n      => mcb3_dram_we_n,
        Dm        => mcb3_dram_dm_vector ,
        Ba        => mcb3_dram_ba,
        Addr      => mcb3_dram_a,
        Dq        => mcb3_dram_dq,
        Dqs       => mcb3_dram_dqs_vector
      );
 
  
 
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
            c3_p0_cmd_clk                           =>  clk,
            c3_p0_cmd_en                            =>  lpddr_pA_cmd_en,
            c3_p0_cmd_instr                         =>  lpddr_pA_cmd_instr,
            c3_p0_cmd_bl                            =>  lpddr_pA_cmd_bl,
            c3_p0_cmd_byte_addr                     =>  lpddr_pA_cmd_byte_addr,
            c3_p0_cmd_empty                         =>  lpddr_pA_cmd_empty,
            c3_p0_cmd_full                          =>  lpddr_pA_cmd_full,
            c3_p0_wr_clk                            =>  clk,
            c3_p0_wr_en                             =>  lpddr_pA_wr_en,
            c3_p0_wr_mask                           =>  lpddr_pA_wr_mask,
            c3_p0_wr_data                           =>  lpddr_pA_wr_data,
            c3_p0_wr_full                           =>  lpddr_pA_wr_full,
            c3_p0_wr_empty                          =>  lpddr_pA_wr_empty,
            c3_p0_wr_count                          =>  lpddr_pA_wr_count,
            c3_p0_wr_underrun                       =>  lpddr_pA_wr_underrun,
            c3_p0_wr_error                          =>  lpddr_pA_wr_error,
            c3_p0_rd_clk                            =>  clk,
            c3_p0_rd_en                             =>  lpddr_pA_rd_en,
            c3_p0_rd_data                           =>  lpddr_pA_rd_data,
            c3_p0_rd_full                           =>  lpddr_pA_rd_full,
            c3_p0_rd_empty                          =>  lpddr_pA_rd_empty,
            c3_p0_rd_count                          =>  lpddr_pA_rd_count,
            c3_p0_rd_overflow                       =>  lpddr_pA_rd_overflow,
            c3_p0_rd_error                          =>  lpddr_pA_rd_error,
            c3_p1_cmd_clk                           =>  clk,
            c3_p1_cmd_en                            =>  lpddr_pB_cmd_en,
            c3_p1_cmd_instr                         =>  lpddr_pB_cmd_instr,
            c3_p1_cmd_bl                            =>  lpddr_pB_cmd_bl,
            c3_p1_cmd_byte_addr                     =>  lpddr_pB_cmd_byte_addr,
            c3_p1_cmd_empty                         =>  lpddr_pB_cmd_empty,
            c3_p1_cmd_full                          =>  lpddr_pB_cmd_full,
            c3_p1_wr_clk                            =>  clk,
            c3_p1_wr_en                             =>  lpddr_pB_wr_en,
            c3_p1_wr_mask                           =>  lpddr_pB_wr_mask,
            c3_p1_wr_data                           =>  lpddr_pB_wr_data,
            c3_p1_wr_full                           =>  lpddr_pB_wr_full,
            c3_p1_wr_empty                          =>  lpddr_pB_wr_empty,
            c3_p1_wr_count                          =>  lpddr_pB_wr_count,
            c3_p1_wr_underrun                       =>  lpddr_pB_wr_underrun,
            c3_p1_wr_error                          =>  lpddr_pB_wr_error,
            c3_p1_rd_clk                            =>  clk,
            c3_p1_rd_en                             =>  lpddr_pB_rd_en,
            c3_p1_rd_data                           =>  lpddr_pB_rd_data,
            c3_p1_rd_full                           =>  lpddr_pB_rd_full,
            c3_p1_rd_empty                          =>  lpddr_pB_rd_empty,
            c3_p1_rd_count                          =>  lpddr_pB_rd_count,
            c3_p1_rd_overflow                       =>  lpddr_pB_rd_overflow,
            c3_p1_rd_error                          =>  lpddr_pB_rd_error,
            c3_p2_cmd_clk                           =>  clk,
            c3_p2_cmd_en                            =>  '0',
            c3_p2_cmd_instr                         =>  (others=>'0'),
            c3_p2_cmd_bl                            =>  (others=>'0'),
            c3_p2_cmd_byte_addr                     =>  (others=>'0'),
            --c3_p2_cmd_empty                         =>  c3_p2_cmd_empty,
            --c3_p2_cmd_full                          =>  c3_p2_cmd_full,
            c3_p2_rd_clk                            =>  clk,
            c3_p2_rd_en                             =>  '0',
            --c3_p2_rd_data                           =>  c3_p2_rd_data,
            --c3_p2_rd_full                           =>  c3_p2_rd_full,
            --c3_p2_rd_empty                          =>  c3_p2_rd_empty,
            --c3_p2_rd_count                          =>  c3_p2_rd_count,
            --c3_p2_rd_overflow                       =>  c3_p2_rd_overflow,
            --c3_p2_rd_error                          =>  c3_p2_rd_error,
            c3_p3_cmd_clk                           =>  clk,
            c3_p3_cmd_en                            =>  '0',
            c3_p3_cmd_instr                         =>  (others=>'0'),
            c3_p3_cmd_bl                            =>  (others=>'0'),
            c3_p3_cmd_byte_addr                     =>  (others=>'0'),
            --c3_p3_cmd_empty                         =>  c3_p3_cmd_empty,
            --c3_p3_cmd_full                          =>  c3_p3_cmd_full,
            c3_p3_rd_clk                            =>  clk,
            c3_p3_rd_en                             =>  '0'
            --c3_p3_rd_data                           =>  c3_p3_rd_data,
            --c3_p3_rd_full                           =>  c3_p3_rd_full,
            --c3_p3_rd_empty                          =>  c3_p3_rd_empty,
            --c3_p3_rd_count                          =>  c3_p3_rd_count,
            --c3_p3_rd_overflow                       =>  c3_p3_rd_overflow,
            --c3_p3_rd_error                          =>  c3_p3_rd_error
    );
 
 
	-- Instantiate the Unit Under Test (UUT)
   uut: memory_interface PORT MAP (
          clk => clk,
          reset => reset,

          a_address => a_address,
          a_D => a_D,
          a_RE => a_RE,
          a_WE => a_WE,
          a_ready => a_ready,
          a_Q => a_Q,

          b_address => b_address,
          b_D => b_D,
          b_RE => b_RE,
          b_WE => b_WE,
          b_ready => b_ready,
          b_Q => b_Q,
          lpddr_pA_cmd_en => lpddr_pA_cmd_en,
          lpddr_pA_cmd_instr => lpddr_pA_cmd_instr,
          lpddr_pA_cmd_bl => lpddr_pA_cmd_bl,
          lpddr_pA_cmd_byte_addr => lpddr_pA_cmd_byte_addr,
          lpddr_pA_cmd_empty => lpddr_pA_cmd_empty,
          lpddr_pA_cmd_full => lpddr_pA_cmd_full,

          lpddr_pA_wr_en => lpddr_pA_wr_en,
          lpddr_pA_wr_mask => lpddr_pA_wr_mask,
          lpddr_pA_wr_data => lpddr_pA_wr_data,
          lpddr_pA_wr_full => lpddr_pA_wr_full,
          lpddr_pA_wr_empty => lpddr_pA_wr_empty,
          lpddr_pA_wr_count => lpddr_pA_wr_count,
          lpddr_pA_wr_underrun => lpddr_pA_wr_underrun,
          lpddr_pA_wr_error => lpddr_pA_wr_error,

          lpddr_pA_rd_en => lpddr_pA_rd_en,
          lpddr_pA_rd_data => lpddr_pA_rd_data,
          lpddr_pA_rd_full => lpddr_pA_rd_full,
          lpddr_pA_rd_empty => lpddr_pA_rd_empty,
          lpddr_pA_rd_count => lpddr_pA_rd_count,
          lpddr_pA_rd_overflow => lpddr_pA_rd_overflow,
          lpddr_pA_rd_error => lpddr_pA_rd_error,
          lpddr_pB_cmd_en => lpddr_pB_cmd_en,
          lpddr_pB_cmd_instr => lpddr_pB_cmd_instr,
          lpddr_pB_cmd_bl => lpddr_pB_cmd_bl,
          lpddr_pB_cmd_byte_addr => lpddr_pB_cmd_byte_addr,
          lpddr_pB_cmd_empty => lpddr_pB_cmd_empty,
          lpddr_pB_cmd_full => lpddr_pB_cmd_full,

          lpddr_pB_wr_en => lpddr_pB_wr_en,
          lpddr_pB_wr_mask => lpddr_pB_wr_mask,
          lpddr_pB_wr_data => lpddr_pB_wr_data,
          lpddr_pB_wr_full => lpddr_pB_wr_full,
          lpddr_pB_wr_empty => lpddr_pB_wr_empty,
          lpddr_pB_wr_count => lpddr_pB_wr_count,
          lpddr_pB_wr_underrun => lpddr_pB_wr_underrun,
          lpddr_pB_wr_error => lpddr_pB_wr_error,

          lpddr_pB_rd_en => lpddr_pB_rd_en,
          lpddr_pB_rd_data => lpddr_pB_rd_data,
          lpddr_pB_rd_full => lpddr_pB_rd_full,
          lpddr_pB_rd_empty => lpddr_pB_rd_empty,
          lpddr_pB_rd_count => lpddr_pB_rd_count,
          lpddr_pB_rd_overflow => lpddr_pB_rd_overflow,
          lpddr_pB_rd_error => lpddr_pB_rd_error
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk_100mhz <= '0';
		wait for clk_period/2;
		clk_100mhz <= '1';
		wait for clk_period/2;
   end process;
 

   reset <= '1' when master_reset = '1' or c3_calib_done = '0' else '0';
   
 
   
   
   -- Stimulus process
   stim_proc: process
   begin		
      
    a_RE <= '0';
    a_WE <= "0000";
    b_RE <= '0';
    b_WE <= "0000";


    -- hold reset state for 100 ns.
    master_reset <= '1';
    wait for 105 ns;	
    master_reset <= '0';        
    wait for clk_period*500;
    wait until c3_calib_done = '1';
    

    -- Write Values
    for i in test_vectors'range loop
                
        wait until clk = '1';    
        a_address <= test_vectors(i).address;
        a_WE <= "1111";
        a_D <= test_vectors(i).data;
        wait until clk = '1';
        a_WE <= "0000";        
        while a_ready = '0' loop
        wait until clk = '1';
        end loop;
        wait for clk_period * 25;              
    
    end loop;
    
    wait for clk_period * 100;
    
    -- Read back to see if values are correct.
    for i in test_vectors'range loop
                
        wait until clk = '1';        
        a_address <= test_vectors(i).address;
        a_RE <= '1';      
        wait until clk = '1';
        a_RE <= '0';        
        while a_ready = '0' loop
        wait until clk = '1';
        end loop;
        assert a_Q = test_vectors(i).data report "Memory read failed " & integer'image(i) severity failure;
                              
    end loop;    

    wait;
     
   end process;

END;
