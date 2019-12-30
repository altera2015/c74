-- C74.000
--
-- Memory interface
-- 
-- Used to abstract the LPDDR, RAM and (future cache) blocks
-- from the Control Logic.
-- 
-- Copyright (c) 2019 Ron Bessems

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memory_interface is

    port ( 
        clk : in  std_logic;
        reset : in  std_logic;           

        -- PORT_A
        a_address : in std_logic_vector(31 downto 0);
        a_D : in  std_logic_vector(31 downto 0);
        a_RE: in std_logic;
        a_WE: in std_logic_vector(3 downto 0);
        a_ready : out  std_logic;
        a_Q : out std_logic_vector(31 downto 0);

        -- PORT_B
        b_address : in std_logic_vector(31 downto 0);
        b_D : in  std_logic_vector(31 downto 0);
        b_RE: in std_logic;
        b_WE: in std_logic_vector(3 downto 0);
        b_ready : out  std_logic;
        b_Q : out std_logic_vector(31 downto 0);

        -- LPDDR Interface
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
        lpddr_pB_rd_error                          : in std_logic

     );
end memory_interface;

architecture Behavioral of memory_interface is
	
    -- FastRam, unregistered RAM.
    -- Shotly after clk up, data becomes
    -- available.
    component low_mem
      port (
        clka : in std_logic;
        ena : in std_logic;
        wea : in std_logic_vector(3 downto 0);
        addra : in std_logic_vector(8 downto 0);
        dina : in std_logic_vector(31 downto 0);
        douta : out std_logic_vector(31 downto 0);
        
        clkb : in std_logic;        
        enb : in std_logic;
        web : in std_logic_vector(3 downto 0);
        addrb : in std_logic_vector(8 downto 0);
        dinb : in std_logic_vector(31 downto 0);
        doutb : out std_logic_vector(31 downto 0)        
      );
    end component;

	COMPONENT memory_interface_port
	PORT(
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
        
        lpddr_wr_en                             : out std_logic;
        lpddr_wr_mask                           : out std_logic_vector(3 downto 0);
        lpddr_wr_data                           : out std_logic_vector(31 downto 0);
        lpddr_wr_full                           : in std_logic;
        lpddr_wr_empty                          : in std_logic;
        lpddr_wr_count                          : in std_logic_vector(6 downto 0);
        lpddr_wr_underrun                       : in std_logic;
        lpddr_wr_error                          : in std_logic;
        
        lpddr_rd_en                             : out std_logic;
        lpddr_rd_data                           : in std_logic_vector(31 downto 0);
        lpddr_rd_full                           : in std_logic;
        lpddr_rd_empty                          : in std_logic;
        lpddr_rd_count                          : in std_logic_vector(6 downto 0);
        lpddr_rd_overflow                       : in std_logic;
        lpddr_rd_error                          : in std_logic               
	);
	END COMPONENT;

    
    signal fr_dina  : std_logic_vector(31 downto 0);
    signal fr_douta : std_logic_vector(31 downto 0);
    signal fr_addra : std_logic_vector(8 downto 0);
    signal fr_ena : std_logic;
    signal fr_wea : std_logic_vector(3 downto 0);
    
    signal fr_dinb  : std_logic_vector(31 downto 0);
    signal fr_doutb : std_logic_vector(31 downto 0);
    signal fr_addrb : std_logic_vector(8 downto 0);
    signal fr_enb : std_logic;
    signal fr_web : std_logic_vector(3 downto 0);    
   
begin
    
   -- 512 x 32 bits ram   
   zero_page : low_mem
      PORT MAP (
        clka => clk,
        ena => fr_ena,
        wea => fr_wea,
        addra => fr_addra,
        dina => fr_dina,
        douta => fr_douta,
        
        clkb => clk,        
        enb => fr_enb,
        web => fr_web,
        addrb => fr_addrb,
        dinb => fr_dinb,
        doutb => fr_doutb        
      );
    
    
	mip_port_a: memory_interface_port PORT MAP(
		clk => clk,
		reset => reset,
        

        address => a_address,
        D => a_D,
        RE => a_RE,
        WE => a_WE,
        ready => a_ready,
        Q => a_Q,
        
        -- Fast Ram interface Port A
		fr_en => fr_ena,
		fr_we => fr_wea,
		fr_addr => fr_addra,
		fr_din => fr_dina,
		fr_dout => fr_douta,
        
        -- LPDDR Interface Port A
		lpddr_cmd_en => lpddr_pA_cmd_en,
		lpddr_cmd_instr => lpddr_pA_cmd_instr,
		lpddr_cmd_bl => lpddr_pA_cmd_bl,
		lpddr_cmd_byte_addr => lpddr_pA_cmd_byte_addr,
		lpddr_cmd_empty => lpddr_pA_cmd_empty,
		lpddr_cmd_full => lpddr_pA_cmd_full,
	
		lpddr_wr_en => lpddr_pA_wr_en,
		lpddr_wr_mask => lpddr_pA_wr_mask,
		lpddr_wr_data => lpddr_pA_wr_data,
		lpddr_wr_full => lpddr_pA_wr_full,
		lpddr_wr_empty => lpddr_pA_wr_empty,
		lpddr_wr_count => lpddr_pA_wr_count,
		lpddr_wr_underrun => lpddr_pA_wr_underrun,
		lpddr_wr_error => lpddr_pA_wr_error,

		lpddr_rd_en => lpddr_pA_rd_en,
		lpddr_rd_data => lpddr_pA_rd_data,
		lpddr_rd_full => lpddr_pA_rd_full,
		lpddr_rd_empty => lpddr_pA_rd_empty,
		lpddr_rd_count => lpddr_pA_rd_count,
		lpddr_rd_overflow => lpddr_pA_rd_overflow,
		lpddr_rd_error => lpddr_pA_rd_error       
	);

	mip_port_b: memory_interface_port PORT MAP(
		clk => clk,
		reset => reset,
        
        address => b_address,
        D => b_D,
        RE => b_RE,
        WE => b_WE,
        ready => b_ready,
        Q => b_Q,
        
        -- Fast Ram interface Port B
		fr_en => fr_enb,
		fr_we => fr_web,
		fr_addr => fr_addrb,
		fr_din => fr_dinb,
		fr_dout => fr_doutb,
       
        -- LPDDR Interface Port B
		lpddr_cmd_en => lpddr_pB_cmd_en,
		lpddr_cmd_instr => lpddr_pB_cmd_instr,
		lpddr_cmd_bl => lpddr_pB_cmd_bl,
		lpddr_cmd_byte_addr => lpddr_pB_cmd_byte_addr,
		lpddr_cmd_empty => lpddr_pB_cmd_empty,
		lpddr_cmd_full => lpddr_pB_cmd_full,

		lpddr_wr_en => lpddr_pB_wr_en,
		lpddr_wr_mask => lpddr_pB_wr_mask,
		lpddr_wr_data => lpddr_pB_wr_data,
		lpddr_wr_full => lpddr_pB_wr_full,
		lpddr_wr_empty => lpddr_pB_wr_empty,
		lpddr_wr_count => lpddr_pB_wr_count,
		lpddr_wr_underrun => lpddr_pB_wr_underrun,
		lpddr_wr_error => lpddr_pB_wr_error,

		lpddr_rd_en => lpddr_pB_rd_en,
		lpddr_rd_data => lpddr_pB_rd_data,
		lpddr_rd_full => lpddr_pB_rd_full,
		lpddr_rd_empty => lpddr_pB_rd_empty,
		lpddr_rd_count => lpddr_pB_rd_count,
		lpddr_rd_overflow => lpddr_pB_rd_overflow,
		lpddr_rd_error => lpddr_pB_rd_error        
	);
    
    

end Behavioral;

