----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    01:38:52 06/21/2020 
-- Design Name: 
-- Module Name:    Top - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Top is
    Port ( 
	-- clock
	   q50m : in std_logic;
	   nres : in std_logic;
	
	-- config
	  -- boot: in std_logic_vector(1 downto 0);
	   boot: out std_logic_vector(1 downto 0); -- for debug
	   graphic: in std_logic;	-- from I/O, select charset
	   
	-- CPU interface
	   A : in  STD_LOGIC_VECTOR (15 downto 0);
           D : inout  STD_LOGIC_VECTOR (7 downto 0);
           vda : in  STD_LOGIC;
           vpa : in  STD_LOGIC;
	   rwb : in std_logic;
           phi2 : inout  STD_LOGIC;
	   rdy : out std_logic;

	-- V/RAM interface
	   VA : out std_logic_vector (18 downto 0);
	   VD : inout std_logic_vector (7 downto 0);
	   nramsel : out STD_LOGIC;
	   ramrwb : out std_logic;

	-- ROM, I/O (on CPU bus)
	   RA: out std_logic_vector (18 downto 12);
	   nsel1 : out STD_LOGIC;
	   nsel2 : out STD_LOGIC;
	   nsel4 : out STD_LOGIC;
	   nromsel : out STD_LOGIC;
	   npgm: out std_logic;
	   
	-- video out
           pxl : out  STD_LOGIC;
           vsync : out  STD_LOGIC;
           hsync : out  STD_LOGIC;
	 
	-- SPI
	   spi_out : out std_logic;
	   spi_in  : in std_logic;
	   spi_in2  : in std_logic;
	   spi_clk : out std_logic;
	   nflash : out std_logic;
	   
	-- Debug
	   dbg_out: out std_logic
	 );
end Top;

architecture Behavioral of Top is

	-- system
	signal init: std_logic;		-- if true, is running from top of ROM
	
	-- clock
	signal dotclk: std_logic;
	signal dot2clk: std_logic;
	signal slotclk: std_logic;
	signal pxl_window: std_logic;
	signal chr_window: std_logic;
	signal sr_load: std_logic;
	
	signal memclk: std_logic;
	signal clk1m: std_logic;
	signal clk2m: std_logic;
	signal clk4m: std_logic;
	
	signal phi2_int: std_logic;
	signal is_cpu: std_logic;
	signal is_cpu_trigger: std_logic;
	
	-- CPU memory mapper
	signal cfgld_in: std_logic;
	signal ma_out: std_logic_vector(18 downto 12);
	signal m_ramsel_out: std_logic;
	signal m_ffsel_out: std_logic;
	signal m_endinit_out: std_logic;
	signal nramsel_int: std_logic;
	signal nromsel_int: std_logic;
	signal m_iosel: std_logic;
	signal m_romsel: std_logic;

	signal sel0 : std_logic;
	signal sel8 : std_logic;

	signal mode : std_logic_vector(1 downto 0);
	signal wp_rom9 : std_logic;
	signal wp_romA : std_logic;
	signal wp_romPET : std_logic;
	
	-- video
	signal va_out: std_logic_vector(15 downto 0);
	signal vd_in: std_logic_vector(7 downto 0);
	signal vis_80_in: std_logic;
	signal vis_hires_in: std_logic;
	signal is_vid_out: std_logic;
	signal is_char_out: std_logic;
	signal vgraphic: std_logic;
	signal map_char: std_logic;
	
	-- cpu
	signal ca_in: std_logic_vector(15 downto 0);
	signal cd_in: std_logic_vector(7 downto 0);
	signal reset: std_logic;
	signal wait_rom: std_logic;
	signal wait_ram: std_logic;
	signal wait_int: std_logic;
	signal wait_int_d: std_logic;
	signal wait_int_d2: std_logic;
	signal release_int: std_logic;
	signal release_int2: std_logic;
	signal ramrwb_int: std_logic;
	
	-- SPI
	signal spi_dout : std_logic_vector(7 downto 0);
	signal spi_cs : std_logic;
	signal spi_sel : std_logic_vector(1 downto 0);
	signal spi_in_d : std_logic;
	
	-- bummer, not in schematic
	constant vpb: std_logic:= '1';
	constant e: std_logic:= '1';
	
	-- debug
	signal dbg_vid: std_logic;
	signal dbg_map: std_logic;
	
	-- components
	
	component Clock is
	  Port (
	   qclk 	: in std_logic;		-- input clock
	   reset	: in std_logic;
	   
	   memclk 	: out std_logic;	-- memory access clock signal
	   
	   clk1m 	: out std_logic;	-- trigger CPU access @ 1MHz
	   clk2m	: out std_logic;	-- trigger CPU access @ 2MHz
	   clk4m	: out std_logic;	-- trigger CPU access @ 4MHz
	   
	   dotclk	: out std_logic;	-- pixel clock for video
	   dot2clk	: out std_logic;	-- half the pixel clock
	   slotclk	: out std_logic;	-- 1 slot = 8 pixel; 1 slot = 2 memory accesses, one for char, one for pixel data (at end of slot)
	   chr_window	: out std_logic;	-- 1 during character fetch window
	   pxl_window	: out std_logic;	-- 1 during pixel fetch window (end of slot)
	   sr_load	: out std_logic		-- load pixel SR on falling edge of dotclk when this is set
	 );
	end component;
	   
	component Mapper is
	  Port ( 
	   A : in  STD_LOGIC_VECTOR (15 downto 8);
           D : in  STD_LOGIC_VECTOR (7 downto 0);
	   reset : in std_logic;
	   phi2: in std_logic;
	   vpa: in std_logic;
	   vda: in std_logic;
	   vpb: in std_logic;
	   rwb : in std_logic;
	   init : in std_logic;
	   
	   qclk : in std_logic;
	   
           cfgld : in  STD_LOGIC;	-- set when loading the cfg
	   
           RA : out  STD_LOGIC_VECTOR (18 downto 12);
	   ffsel: out std_logic;
	   endinit: out std_logic;
	   iosel: out std_logic;
	   ramsel: out std_logic;
	   romsel: out std_logic;
	   
	   wp_rom9: in std_logic;
	   wp_romA: in std_logic;
	   wp_romPET: in std_logic;
	   
	   dbgout: out std_logic
	  );
	end component;
	
	component Video is
	  Port ( 
	   A : out  STD_LOGIC_VECTOR (15 downto 0);
           D : in  STD_LOGIC_VECTOR (7 downto 0);
	   CPU_D : in std_logic_vector (7 downto 0);
	   
	   pxl_out: out std_logic;	-- video bitstream
           v_sync : out  STD_LOGIC;
           h_sync : out  STD_LOGIC;

           is_80_in : in  STD_LOGIC;	-- is 80 column mode?
	   is_hires : in std_logic;	-- is hires mode?
	   is_graph : in std_logic;	-- from PET I/O
	   crtc_sel : in std_logic;	-- select line for CRTC
	   crtc_rs  : in std_logic;	-- register select
	   crtc_rwb : in std_logic;	-- r/-w
	   
	   qclk: in std_logic;		-- Q clock
	   dotclk : in std_logic;	-- 25MHz in (VGA timing)
	   dot2clk : in std_logic;
           memclk : in STD_LOGIC;	-- system clock 8MHz
	   slotclk : in std_logic;
	   chr_window : in std_logic;
	   pxl_window : in std_logic;
	   sr_load : in std_logic;
	   
           is_vid : out STD_LOGIC;	-- true during video access phase
	   is_char: out std_logic;	-- map character data fetch
	   dbg_out : out std_logic;
	   reset : in std_logic
	 );
	end component;

	component SPI is
	  Port ( 
	   DIN : in  STD_LOGIC_VECTOR (7 downto 0);
	   DOUT : out  STD_LOGIC_VECTOR (7 downto 0);
	   RS: in std_logic_vector(1 downto 0);
	   RWB: in std_logic;
	   CS: in std_logic;	-- includes clock
	   
	   serin: in std_logic;
	   serout: out std_logic;
	   serclk: out std_logic;
	   sersel: out std_logic_vector(1 downto 0);	   
	   spiclk : in std_logic;
	   
	   reset : in std_logic
	 );
	end component;

	function To_Std_Logic(L: BOOLEAN) return std_ulogic is
	begin
		if L then
			return('1');
		else
			return('0');
		end if;
	end function To_Std_Logic;

begin

	clocky: Clock
	port map (
	   q50m,
	   reset,
	   memclk,
	   clk1m,
	   clk2m,
	   clk4m,
	   dotclk,
	   dot2clk,
	   slotclk,
	   chr_window,
	   pxl_window,
	   sr_load
	);

	-- define CPU slots. clk2=1 is reserved for video
	-- mode(1 downto 0): 00=1MHz, 01=2MHz, 10=4MHz, 11=Max speed

	is_cpu_trigger <= '1'	when mode = "11" else
			clk4m	when mode = "10" else
			clk2m	when mode = "01" else
			clk1m;
	
	is_cpu_p: process(reset, is_cpu_trigger, is_cpu, mode, release_int, memclk)
	begin
		if (reset = '1' or release_int = '1') then
			is_cpu <= '0';
		elsif (mode = "11") then
			is_cpu <= '1';
		elsif falling_edge(memclk) then
			if (is_cpu_trigger = '1') then
				is_cpu <= '1';
			end if;
		end if;
	end process;

	reset <= not(nres);
	
	-- WAIT is used to slow 
	-- 1) access to the slow ROM (which is independent from video bus) and
	-- 2) access to the RAM when video access is needed
	--
	wait_rom <= '1' when m_romsel='1' else 	-- start of ROM read;
			'0';
	wait_ram <= '1' when m_ramsel_out = '1' and is_vid_out = '1' else	-- video access in RAM
			'0';
	wait_int <= wait_ram or wait_rom or not(is_cpu);
	
	wait_p: process(wait_int, release_int, memclk, reset)
	begin
		if (reset = '1') then
			wait_int_d <= '1';
		elsif (release_int = '1') then
			wait_int_d <= '0';
		elsif (rising_edge(memclk)) then
			wait_int_d <= wait_int;
		end if;
	end process;
	
	wait_p2: process(wait_int_d, release_int, memclk, reset)
	begin
		if (reset = '1' or release_int = '1') then
			wait_int_d2 <= '0';
		elsif (rising_edge(memclk)) then
			wait_int_d2 <= wait_int_d;
		end if;
	end process;

	release2_p: process(wait_int_d2, dotclk, is_vid_out, q50m, reset)
	begin
		if (reset = '1') then
			release_int2 <= '0';
		elsif (rising_edge(q50m)) then
			if (memclk = '1' and wait_int_d2 = '1' and is_cpu='1' and wait_ram = '0') then
				release_int2 <= '1';
			else
				release_int2 <= '0';
			end if;
		end if;
	end process;

	release_p: process(release_int2, q50m, reset)
	begin
		if (reset = '1') then
			release_int <= '0';
		elsif (falling_edge(q50m)) then
			release_int <= release_int2;
		end if;
	end process;
	

	-- Note if we use phi2 without setting it high on waits (and would use RDY instead), the I/O timers
	-- will always count on 8MHz - which is not what we want
	phi2_int <= memclk or wait_int_d;
	rdy <= '1';
	
	--boot(0) <= spi_out;
	--boot(1) <= spi_clk;
	
	-- use a pullup and this mechanism to drive a 5V signal from a 3.3V CPLD
	-- According to UG445 Figure 7: push up until detected high, then let pull up resistor do the rest.
	-- data_to_pin<= data  when ((data and data_to_pin) ='0') else 'Z';	
	phi2 <= phi2_int when ((phi2_int and phi2) = '0') else 'Z';
	
	------------------------------------------------------
	-- CPU memory mapper
	
	cd_in <= D;
	ca_in <= A;
		
	mappy: Mapper
	port map (
	   ca_in(15 downto 8),
           cd_in,
	   reset,
	   phi2_int,
	   vpa,
	   vda,
	   vpb,
	   rwb,
	   init,
	   q50m,
           cfgld_in,
	   ma_out,
	   m_ffsel_out,
	   m_endinit_out,
	   m_iosel,
	   m_ramsel_out,
	   m_romsel,
	   wp_rom9,
	   wp_romA,
	   wp_romPET,
	   dbg_map
	);

		
	cfgld_in <= '1' when m_ffsel_out ='1' and ca_in(7 downto 0) = x"F0" else '0';

	-- internal selects
	sel0 <= '1' when m_iosel = '1' and ca_in(7 downto 4) = x"0" else '0';
	sel8 <= '1' when m_iosel = '1' and ca_in(7 downto 4) = x"8" else '0';

	dbg_out <= spi_in or spi_in2;
	
	-- external selects are inverted
	nsel1 <= '0' when m_iosel = '1' and ca_in(7 downto 4) = x"1" else '1';
	nsel2 <= '0' when m_iosel = '1' and ca_in(7 downto 4) = x"2" else '1';
	nsel4 <= '0' when m_iosel = '1' and ca_in(7 downto 4) = x"4" else '1';
	
	npgm <= '1';
	
	------------------------------------------------------
	-- video
	--
	viccy: Video
	port map (
		va_out,
		vd_in,
		cd_in, 
		pxl,
		vsync,
		hsync,
		vis_80_in,
		vis_hires_in,
		vgraphic,
		sel8,
		ca_in(0),
		rwb,
		q50m,		-- Q clock (50MHz)
		dotclk,
		dot2clk,
		memclk,		-- sysclk (~8MHz)
		slotclk,
		chr_window,
		pxl_window,
		sr_load,
		is_vid_out,
		is_char_out,
		dbg_vid,
		reset
	);

	vgraphic <= graphic;
	
	------------------------------------------------------
	-- SPI interface
	
	spi_comp: SPI
	port map (
	   cd_in,
	   spi_dout,
	   ca_in(1 downto 0),
	   rwb,
	   spi_cs,
	   
	   spi_in,
	   boot(0),	--spi_out,
	   boot(1),	--spi_clk,
	   spi_sel,
	   memclk,
	   
	   reset
	);
	
	spi_cs <= To_Std_Logic(sel0 = '1' and ca_in(3) = '1' and ca_in(2) = '0' and phi2_int = '1');
	
	-- select flash chip
	nflash <= spi_sel(0);
	
	------------------------------------------------------
	-- control

	-- release initial mapping after first write to $ffxx
	-- but only if write is coming from low memory
	-- (otherwise init could not copy over OS ROM to its boot place)
	--
	Init_P: process(m_ffsel_out, phi2_int, rwb, reset)
	begin
		if (reset='1') then
			init <= '1';
		elsif (falling_edge(phi2_int)) then
			if (m_endinit_out = '1') then
				init <= '0';
			end if;
		end if;
	end process;
	
	-- store video control register $fff1
	--
	-- D0 	: 1= hires
	-- D1	: 1= 80 column
	-- D2-7	: reserved, must be 0
	--
	Ctrl_P: process(sel0, phi2_int, rwb, reset, ca_in, D)
	begin
		if (reset = '1') then
			vis_hires_in <= '0';
			vis_80_in <= '0';
			mode <= "00";
			map_char <= '1';
			wp_rom9 <= '0';
			wp_romA <= '0';
			wp_romPET <= '0';
		elsif (falling_edge(phi2_int) and sel0='1' and rwb='0') then
			-- Write to $E80x
			case (ca_in(3 downto 0)) is
			when x"0" =>
				vis_hires_in <= D(0);
				vis_80_in <= D(1);
				map_char <= not(D(2));
				wp_rom9 <= D(3);
				wp_romA <= D(4);
				wp_romPET <= D(5);
				mode(1 downto 0) <= D(7 downto 6); -- speed bits
			when others =>
				null;
			end case;
		end if;
	end process;

	-- RAM address
	VA(11 downto 0) <= 	ca_in(11 downto 0) 	when is_vid_out = '0' 	else 
				va_out(11 downto 0);
	VA(15 downto 12) <= 	ma_out(15 downto 12) 	when is_vid_out = '0' 	else 
				va_out(15 downto 12);
	VA(18 downto 16) <= 	ma_out(18 downto 16) 	when is_vid_out = '0' 	else	-- CPU access
				"000"			when is_char_out = '1' and map_char='1' else	-- $x08000 for characters like in PET
				"111";							-- hires and charrom pixel data in bank 7
				
	-- RAM data in for video fetch
	--vd_in <= x"EA"; --D; --VD;
	vd_in <= VD;
	
	-- RAM R/W
	ramrwb_int <= 
		'1' 	when is_vid_out ='1' else 
		'1'	when m_ramsel_out ='0' else
		'1'	when memclk='0' else
		rwb;
		
	ramrwb <= ramrwb_int;
	
	-- data transfer between CPU data bus and video/memory data bus
	VD <= 	D when ramrwb_int = '0'
		else
			(others => 'Z');
		
	D <= 	VD when is_vid_out='0' 
			and rwb='1' 
			and m_ramsel_out ='1' 
			and phi2_int='1'
		else 
		spi_dout when spi_cs = '1'
			and rwb = '1'
		else
			(others => 'Z');
	
	-- ROM (4k) page address
	RA(18 downto 12) <= ma_out(18 downto 12);

	-- RA(18 downto 12) <= (others => '1');
		
	-- select RAM
	nramsel_int <= 	'1'	when memclk = '0' else	-- inactive after previous access
			'0' 	when is_vid_out='1' else
			'0' 	when phi2_int ='1' and m_ramsel_out ='1' and is_cpu='1' else
			'1';
		
	
	nramsel <= nramsel_int;

	-- select ROM
	nromsel_int <= 	'1'	when phi2_int = '0' else
			'0'	when m_romsel = '1' else
			'1';

	nromsel <= nromsel_int;
	
end Behavioral;

