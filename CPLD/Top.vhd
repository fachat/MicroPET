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
	   qclk : in std_logic;
	   nres : in std_logic;
	
	-- config
	   mode: in std_logic_vector(1 downto 0);	-- 00=1MHz, 01=2MHz, 10=4MHz, 11=Max speed
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
           hsync : out  STD_LOGIC
	 );
end Top;

architecture Behavioral of Top is

	-- system
	signal init: std_logic;		-- if true, is running from top of ROM
	
	-- clock
	signal clkcnt: std_logic_vector(7 downto 0);
	signal dotclk: std_logic;
	signal memclk: std_logic;
	signal memby2: std_logic;
	signal memby4: std_logic;
	signal memby8: std_logic;
	
	signal memclk_d: std_logic;
	signal phi2_int: std_logic;
	signal is_cpu: std_logic;
	
	-- CPU memory mapper
	signal cfgld_in: std_logic;
	signal ma_out: std_logic_vector(18 downto 12);
	signal m_ramsel_out: std_logic;
	signal m_ffsel_out: std_logic;
	signal m_endinit_out: std_logic;
	signal nramsel_int: std_logic;
	signal nramsel_int_d: std_logic;
	signal nromsel_int: std_logic;
	signal m_iosel: std_logic;
	signal m_romsel: std_logic;
	signal m_romsel_d: std_logic;

	-- video
	signal va_out: std_logic_vector(13 downto 0);
	signal vd_in: std_logic_vector(7 downto 0);
	signal vpage: std_logic_vector(3 downto 0);
	signal vis_80_in: std_logic;
	signal vis_hires_in: std_logic;
	signal is_vid_out: std_logic;
	signal is_chrom_out: std_logic;
	signal vgraphic: std_logic;
	
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
	signal ramrwb_int: std_logic;
	
	-- bummer, not in schematic
	constant vpb: std_logic:= '1';
	
	-- debug
	signal dbg_vid: std_logic;
	signal dbg_map: std_logic;
	
	-- components
	
	component Ctrl is
	  Port ( 
	   qclk : in  STD_LOGIC;	-- 32 MHz input
	   dotclk : out std_logic;	-- 16 MHz output
           sysclk : out  STD_LOGIC;	-- 8 MHz output
	   
           is_cpu : out  STD_LOGIC;
           is_vid : out  STD_LOGIC;
	   
	   reset: in std_logic;
           vda : in  STD_LOGIC;
           vpa : in  STD_LOGIC
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
	   
	   dbgout: out std_logic
	  );
	end component;
	
	component Video is
	  Port ( 
	   A : out  STD_LOGIC_VECTOR (13 downto 0);
           D : in  STD_LOGIC_VECTOR (7 downto 0);
           page : in  STD_LOGIC_VECTOR (3 downto 0);
	
	   pxl_out: out std_logic;	-- video bitstream
           v_sync : out  STD_LOGIC;
           h_sync : out  STD_LOGIC;

           is_80_in : in  STD_LOGIC;	-- is 80 column mode?
	   is_hires : in std_logic;	-- is hires mode?
	   is_graph : in std_logic;	-- from PET I/O
	   
	   qclk: in std_logic;		-- Q clock
	   dotclk : in std_logic;	-- 16MHz in
           memclk : in STD_LOGIC;	-- system clock 8MHz
	   memby2: in std_logic;	-- sysclk / 2, i.e. every potential video slot
	   memby4: in std_logic;	-- sysclk / 4
	   memby8: in std_logic;	-- sysclk / 8
           is_vid : out STD_LOGIC;	-- true during video access phase
	   is_chrom: out std_logic;	-- map character set out of 8296's way
	   dbg_out : out std_logic;
	   reset : in std_logic
	 );
	end component;

begin
	
	-- clock
	-- generate sysclk from qclk (32MHz)
	Clk: process(reset, qclk, clkcnt)
	begin
		if (reset = '1') then 
			clkcnt <= "00000000";
		elsif (falling_edge(qclk)) then
			clkcnt <= clkcnt + 1; 
		end if;
	end process;
	dotclk <= clkcnt(0); 	-- 16 MHz / memx2
	memclk <= clkcnt(1);	-- 8 MHz
	memby2 <= clkcnt(2);	-- 4 MHz
	memby4 <= clkcnt(3);	-- 2 MHz
	memby8 <= clkcnt(4);	-- 1 MHz
	
	memclk_p: process(reset, qclk, memclk)
	begin
		if (reset = '1') then
			memclk_d <= '0';
		elsif (rising_edge(qclk)) then
			memclk_d <= memclk;
		end if;
	end process;

	-- define CPU slots. clk2=1 is reserved for video
	-- mode(1 downto 0): 00=1MHz, 01=2MHz, 10=4MHz, 11=Max speed
	is_cpu <= '1' and not(memby2) and not(memby4) and not(memby8); 
--	is_cpu <= '1'		 		when mode = "11" else		-- 8MHz minus video (via RDY)
--		not(memby2) 			when mode = "10" else		-- every 2nd = 4MHz
--		not(memby2) and not(memby4)	when mode = "01" else		-- every 4th = 2MHz
--		not(memby2) and not(memby4) and not(memby8) when mode = "00";	-- every 8th = 1MHz
		
	
	reset <= not(nres);
	
	-- TODO: is_cpu handling to slow down to specified clock
	--
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

	release_p: process(wait_int_d2, dotclk, is_vid_out, memclk, reset)
	begin
		if (reset = '1') then
			release_int <= '0';
		elsif (rising_edge(dotclk)) then
			--if (memclk = '1' and wait_int_d2 = '1' and is_vid_out = '0') then
			if (memclk = '1' and wait_int_d2 = '1' and is_cpu='1') then
				release_int <= '1';
			else
				release_int <= '0';
			end if;
		end if;
	end process;
	

	-- Note. the 65816 puts out the bank address even if RDY=0.
	-- So, in fact the CPU drives the data bus against e.g. a slow ROM starting
	-- to put the data on the bus.
	-- Therefore, RDY cannot be used, but clock stretching must be used,
	-- using the internal wait signal
	--
	phi2_int <= memclk or wait_int_d;
	
	rdy <= '1';
	
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
	   qclk,
           cfgld_in,
	   ma_out,
	   m_ffsel_out,
	   m_endinit_out,
	   m_iosel,
	   m_ramsel_out,
	   m_romsel,
	   
	   dbg_map
	);

	
	Romsel_p: process(reset, m_romsel, memclk)
	begin
		if (reset = '1') then
			m_romsel_d <= '1';
		elsif (falling_edge(memclk)) then
			if (m_romsel_d = '0') then
				m_romsel_d <= m_romsel;
			else
				m_romsel_d <= '0';
			end if;
		end if;
	end process;
	
	cfgld_in <= '1' when m_ffsel_out ='1' and ca_in(7 downto 0) = x"F0" else '0';
	
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
		vpage,
		pxl,
		vsync,
		hsync,
		vis_80_in,
		vis_hires_in,
		vgraphic,
		qclk,
		dotclk,
		memclk,		-- sysclk
		memby2,		-- vid1
		memby4,		-- vid2
		memby8,		-- vid4
		is_vid_out,
		is_chrom_out,
		dbg_vid,
		reset
	);

	vgraphic <= graphic;
	
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
	
	-- store page control register $fff2
	--
	-- D0-3	: video page (0-15)
	-- D4-7 : reserved, must be 0
	--
	Page: process(m_ffsel_out, phi2_int, rwb, reset, ca_in, D)
	begin
		if (reset = '1') then
			vpage <= "0000";
		elsif (falling_edge(phi2_int)) then
			if (rwb = '0' and m_ffsel_out='1' and ca_in(7 downto 0) = x"F2") then
				--vpage <= D(3 downto 0);
			end if;
		end if;
	end process;

	-- store video control register $fff1
	--
	-- D0 	: 1= hires
	-- D1	: 1= 80 column
	-- D2-7	: reserved, must be 0
	--
	Ctrl_P: process(m_ffsel_out, phi2_int, rwb, reset, ca_in, D)
	begin
		if (reset = '1') then
			vis_hires_in <= '0';
			vis_80_in <= '0';
		elsif (falling_edge(phi2_int)) then
			--if (rwb = '0' and m_ffsel_out='1' and ca_in(7 downto 0) = x"F1") then
			--	vis_hires_in <= D(0);
			--	vis_80_in <= D(1);
			--end if;
			
			-- temporary debug
			vis_hires_in <= mode(1);
			vis_80_in <= mode(0);
		end if;
	end process;

	-- RAM address
	VA(11 downto 0) <= 	ca_in(11 downto 0) 	when is_vid_out = '0' 	else 
				va_out(11 downto 0);
	VA(13 downto 12) <= 	ma_out(13 downto 12) 	when is_vid_out = '0' 	else 
				va_out(13 downto 12);
	VA(18 downto 14) <= 	ma_out(18 downto 14) 	when is_vid_out = '0' 	else	-- CPU access
				"11100"			when is_chrom_out = '1' else	-- $x70000 for charrom (lowest 8k of it)
				"00100" 		when vis_hires_in = '1' else	-- $x10000 for hires
				"00010";						-- $x08000 like in the PET for characters
				
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
			(others => 'Z');
	
	-- ROM (4k) page address
	RA(18 downto 12) <= ma_out(18 downto 12);

	-- RA(18 downto 12) <= (others => '1');
		
	-- select RAM
	nramsel_int <= 	'1'	when memclk = '0' else	-- inactive after previous access
			'0' 	when is_vid_out='1' else
			'0' 	when phi2_int ='1' and m_ramsel_out ='1' else
			'1';
		
--	ramsel_p: process(nramsel_int, qclk)
--	begin
--		if (rising_edge(qclk)) then
--			if (ramrwb_int ='1') then
--				-- read RAM then keep a little longer
--				nramsel_int_d <= nramsel_int;
--			else
--				-- write - deselect quick
--				nramsel_int_d <= '1';
--			end if;
--		end if;
--	end process;
	
	nramsel <= nramsel_int; -- and nramsel_int_d;

	-- select ROM
	nromsel_int <= 	'1'	when phi2_int = '0' else
			'0'	when m_romsel = '1' else
			'1';

	nromsel <= nromsel_int;
	
end Behavioral;

