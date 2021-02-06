----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:29:52 06/19/2020 
-- Design Name: 
-- Module Name:    Video - Behavioral 
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

entity Video is
	  Port ( 
	   A : out  STD_LOGIC_VECTOR (15 downto 0);
           D : in  STD_LOGIC_VECTOR (7 downto 0);
	   CPU_D : in std_logic_vector (7 downto 0);
	   phi2 : in std_logic;
	   
	   pxl_out: out std_logic;	-- video bitstream
	   dena   : out std_logic;	-- display enable
           v_sync : out  STD_LOGIC;
           h_sync : out  STD_LOGIC;
	   pet_vsync : out std_logic;

	   is_enable: in std_logic;	-- display enable
           is_80_in : in  STD_LOGIC;	-- is 80 column mode?
	   is_hires : in std_logic;	-- is hires mode?
	   is_graph : in std_logic;	-- from PET I/O
	   is_double: in std_logic;	-- unused
	   is_nowrap: in std_logic;
	   
	   crtc_sel : in std_logic;	-- select line for CRTC
	   crtc_rs  : in std_logic;	-- register select
	   crtc_rwb : in std_logic;	-- r/-w
	   
	   qclk: in std_logic;		-- Q clock
	   dotclk : in std_logic;	-- 25MHz in
	   dot2clk : in std_logic;	-- half the pixel clock
           memclk : in STD_LOGIC;	-- system clock 8MHz
	   slotclk : in std_logic;
	   chr_window : in std_logic;
	   pxl_window : in std_logic;
	   sr_load: in std_logic;
	   
           is_vid : out STD_LOGIC;	-- true during video access phase
	   is_char: out std_logic;	-- map character data fetch
	   dbg_out : out std_logic;
	   reset : in std_logic
	 );
end Video;

architecture Behavioral of Video is

	-- slot clock
	signal sr_load_d : std_logic;
	signal dot2clk_d : std_logic;
	
	signal in_slot: std_logic;
	
	-- mode
	signal is_80: std_logic;
	
	-- crtc register emulation
	-- only 8/9 rows per char are emulated right now
	signal crtc_reg: std_logic_vector(3 downto 0);	
	signal is_9rows: std_logic;
	signal is_10rows: std_logic;
	signal vpage : std_logic_vector(7 downto 0);
	
	-- hold and shift the pixel
	signal pxlhold : std_logic_vector (7 downto 0) := (others => '0');
	-- hold the character information
	signal charhold : std_logic_vector (7 downto 0) := (others => '0');

	-- count "slots", i.e. 8pixels
	-- 
	-- one slot may need none (out of screen), one (hires), or two (character display) 
	-- memory accesses. At 16MHz pixel, a slot has four potential memory accesses at 8MHz
	signal slot_cnt : std_logic_vector (9 downto 0) := (others => '0');
	-- count raster lines
	signal rline_cnt : std_logic_vector (9 downto 0) := (others => '0');
	-- count character lines
	signal cline_cnt : std_logic_vector (3 downto 0) := (others => '0');
	
	-- computed video memory address
	signal vid_addr : std_logic_vector (13 downto 0) := (others => '0');
	-- computed video memory address at start of line (to re-load chars each raster line)
	signal vid_addr_hold : std_logic_vector(13 downto 0) := (others => '0');
	
	-- geo signals
	--
	-- pulse at end of raster line
	signal last_slot_of_line : std_logic := '0';
	-- pulse for last visible character/slot
	signal last_vis_slot_of_line : std_logic := '0';
	-- pulse at end of character line 
	signal last_line_of_char : std_logic := '0';
	-- pulse at end of screen
	signal last_line_of_screen : std_logic := '0';
	
	-- enable
	signal h_enable : std_logic := '0';	
	signal v_enable : std_logic := '0';
	signal enable : std_logic;
	
	-- sync
	signal h_sync_int : std_logic := '0';	
	signal v_sync_int : std_logic := '0';
	
	-- intermediate
	signal a_out : std_logic_vector (15 downto 0);
	
	-- convenience
	signal chr40 : std_logic;
	signal chr80 : std_logic;
	signal pxl40 : std_logic;
	signal pxl80 : std_logic;
	
	signal chr_fetch : std_logic;
	signal pxl_fetch : std_logic;
	
begin

	-- On end of line, in_slot is set to 1, to start with chr40,
	-- which is valid on both 40 and 80 columns.
	-- Otherwise 40col would start to display a slot later (1/2 40col char).
	-- Which also happens in every 2nd line if not reset at the end of the line
	-- and total slots/line is an odd number
	in_slot_cnt_p: process(in_slot, slotclk, reset, last_slot_of_line)
	begin
		if (reset = '1' or last_slot_of_line = '1') then
			in_slot <= '1';
		elsif (falling_edge(slotclk)) then
			in_slot <= not(in_slot);
		end if;
	end process;
	
	-- access indicators
	--
	-- pxl40/chr40 are used in both 40 and 80 col mode
	-- pxl40/80 must be active at last cycle before loading the pixel shift register
	-- 	as the pixel SR is directly loaded from the data bus
	chr40 <= chr_window and in_slot 	and not(is_hires);
	pxl40 <= pxl_window and in_slot;
	chr80 <= chr_window and not(in_slot) 	and not(is_hires) 	and is_80;
	pxl80 <= pxl_window and not(in_slot)		  		and is_80;

	-- note: at least pxl_fetch is used in loading the video shift register, at falling edge of a clock
	-- so the combinatorial part will glitch, and sometimes not fulfill the condition to load the SR.
	-- Therefore the outputs are registered here on the rising edge of qclk
	vid_p: process(chr40, chr80, pxl40, pxl80, qclk)
	begin
		if (rising_edge(qclk)) then
	-- do we fetch character index?
	-- not hires, and first cycle in streak
	chr_fetch <= is_enable and (chr40 or chr80);

	-- dot fetch
	pxl_fetch <= is_enable and (pxl40 or pxl80);
	
	-- video access?
	is_vid <= chr_fetch or pxl_fetch;
	
	-- character rom fetch
	is_char <= chr_fetch;
		end if;
	end process;
	
	-----------------------------------------------------------------------------
	-- horizontal geometry calculation

	-- note: needs to be synchronized, as otherwise bouncing would appear from 
	-- different signal path lengths in different bits, resulting in line counter running
	-- twice the speed it should.
	CharCnt: process(slotclk, last_slot_of_line, slot_cnt, reset)
	begin
		if (reset = '1') then
			slot_cnt <= (others => '0');
		elsif (rising_edge(slotclk)) then
			if (last_slot_of_line = '1') then
				slot_cnt <= (others => '0');
			else
				slot_cnt <= slot_cnt + 1;
			end if;
		end if;
	end process;

	SlotProx: process(slot_cnt, slotclk) 
	begin
		if (falling_edge(slotclk)) then
			-- end of line
			if(slot_cnt = 132) then
				last_slot_of_line <= '1';
			else
				last_slot_of_line <= '0';
			end if;
			
			-- sync
			if (slot_cnt >= 99 and slot_cnt <= 108) then
				h_sync_int <= '1';
			else
				h_sync_int <= '0';
			end if;
			
			-- last visible slot
			if (slot_cnt = 80) then
				last_vis_slot_of_line <= '1';
			else 
				last_vis_slot_of_line <= '0';
			end if;
			
			-- enable
			-- note:  falling edge of enable may be used to count lines
			if (slot_cnt < 80) then
				h_enable <= '1';
			else
				h_enable <= '0';
			end if;			
		end if;
	end process;

	h_sync <= h_sync_int xor v_sync_int;
	
	-----------------------------------------------------------------------------
	-- vertical geometry calculation

	LineCnt: process(h_enable, last_line_of_screen, rline_cnt, cline_cnt, reset)
	begin
		if (reset = '1') then
			rline_cnt <= (others => '0');
			cline_cnt <= (others => '0');
		elsif (falling_edge(h_enable)) then
			if (last_line_of_screen = '1') then
				rline_cnt <= (others => '0');
				cline_cnt <= (others => '0');
			else
				rline_cnt <= rline_cnt + 1;
				
				if (last_line_of_char = '1') then
					cline_cnt <= (others => '0');
				else
					cline_cnt <= cline_cnt + 1;
				end if;
			end if;
		end if;
	end process;

	LineProx: process(h_enable)
	begin
		if (rising_edge(h_enable)) then
			
		    if (is_9rows = '1') then
			-- timing for 9 pixel rows per character
			-- end of character line
			if (is_hires = '1' or cline_cnt = 8) then
				-- if hires, everyone
				last_line_of_char <= '1';
			else
				last_line_of_char <= '0';
			end if;
				
			-- vsync
			if (rline_cnt >= 265 and rline_cnt < 281) then
				v_sync_int <= '1';
			else
				v_sync_int <= '0';
			end if;
			
			-- venable
			if (rline_cnt < 225) then
				v_enable <= '1';
			else
				v_enable <= '0';
			end if;
		    elsif (is_10rows = '1') then
			-- timing for 10 pixel rows per character
			-- end of character line
			if (is_hires = '1' or cline_cnt = 9) then
				-- if hires, everyone
				last_line_of_char <= '1';
			else
				last_line_of_char <= '0';
			end if;
				
			-- vsync
			if (rline_cnt >= 275 and rline_cnt < 291) then
				v_sync_int <= '1';
			else
				v_sync_int <= '0';
			end if;
			
			-- venable
			if (rline_cnt < 250) then
				v_enable <= '1';
			else
				v_enable <= '0';
			end if;
		    else
			-- timing for 8 pixel rows per character
			-- end of character line
			if (is_hires = '1' or cline_cnt = 7) then
				-- if hires, everyone
				last_line_of_char <= '1';
			else
				last_line_of_char <= '0';
			end if;
			
			-- vsync
			if (rline_cnt >= 255 and rline_cnt < 271) then
				v_sync_int <= '1';
			else
				v_sync_int <= '0';
			end if;
			
			-- venable
			if (rline_cnt < 200) then
				v_enable <= '1';
			else
				v_enable <= '0';
			end if;
		    end if; -- crtc_is_9rows

		    -- common for 8/9 pixel rows per char
		    
			-- end of screen
			if (rline_cnt = 313) then
				last_line_of_screen <= '1';
			else
				last_line_of_screen <= '0';
			end if;
	
		
		end if; -- rising edge...
	end process;

	v_sync <= v_sync_int;
	pet_vsync <= v_sync_int;
	
	-----------------------------------------------------------------------------
	-- address calculations
	
	AddrHold: process(slotclk, last_slot_of_line, last_line_of_screen, vid_addr, reset) 
	begin
		if (reset ='1') then
			vid_addr_hold <= (others => '0');
		elsif (rising_edge(slotclk)) then
			if (last_vis_slot_of_line = '1') then
				if (last_line_of_screen = '1') then
					vid_addr_hold <= (others => '0');
				else
					if (last_line_of_char = '1') then
						vid_addr_hold <= vid_addr;
					end if;
				end if;
			end if;
		end if;
	end process;
	
	AddrCnt: process(last_slot_of_line, last_line_of_screen, vid_addr, vid_addr_hold, is_80, in_slot, slotclk, reset)
	begin
		if (reset = '1') then
			vid_addr <= (others => '0');
		elsif (falling_edge(slotclk)) then
			if (last_line_of_screen = '1' and last_slot_of_line = '1') then
				vid_addr <= (others => '0');
				is_80 <= is_80_in;
			else
				if (last_slot_of_line = '0') then
					if (is_80 = '1' or in_slot = '1') then
						vid_addr <= vid_addr + 1;
					end if;
				else
					vid_addr <= vid_addr_hold;
				end if;
			end if;
		end if;
	end process;

	-----------------------------------------------------------------------------
	-- address output
	
	a_out(3 downto 0) <= vid_addr(3 downto 0) when is_hires ='1' or chr_fetch = '1' else 
			cline_cnt;
	a_out(9 downto 4) <= vid_addr(9 downto 4) when is_hires ='1' or chr_fetch = '1' else 
			charhold(5 downto 0);
	a_out(10) <= vid_addr(10) when is_hires ='1' else
			charhold(6) when pxl_fetch ='1' else 
				vid_addr(10) when is_80 ='1' else 
					vpage(2);
	a_out(11) <= vid_addr(11) when is_hires ='1' else
			charhold(7) when pxl_fetch ='1' else
				vpage(3);
	a_out(12) <= vid_addr(12) when is_hires ='1' else
			is_graph when pxl_fetch ='1' else
				vpage(4);
	a_out(13) <= vid_addr(13) when is_hires ='1' and is_80 ='1' else
			vpage(5) when is_hires ='1' or pxl_fetch ='1' else
				'0';
	a_out(15 downto 14) <= vpage(7 downto 6) when is_hires = '1' or pxl_fetch = '1' else
			"10";		-- $8000 for PET character data

	A <= a_out when chr_fetch ='1' or pxl_fetch ='1' else (others => 'Z');

	-----------------------------------------------------------------------------
	-- char hold
	
	CHold: process(chr_fetch, D, reset)
	begin
		if (reset = '1') then
			charhold <= (others => '0');
		elsif (falling_edge(chr_fetch)) then
			charhold <= D;
		end if;
	end process;
	
	-----------------------------------------------------------------------------
	-- output sr control

	memclk_p: process (dotclk, memclk, dot2clk)
	begin 
		if (rising_edge(dotclk)) then
			dot2clk_d <= dot2clk;
			sr_load_d <= sr_load;
		end if;
	end process;
	
	-- note that switching dotclk depending on 40/80 cols delays it to the effect
	-- that it generates artifacts. So we always use 80col dotclk (16MHz), and in 40 column
	-- mode we just shift out every pixel twice.
	SR: process(pxl_fetch, D, reset, memclk, dotclk, pxlhold, pxl_fetch)
	begin
		if (reset ='1') then
			pxlhold <= (others => '0');
		elsif (falling_edge(dotclk)) then
			if (pxl_fetch = '1' and sr_load_d ='1') then
				enable <= h_enable and v_enable;
				pxlhold <= D;
			-- note that checking memclk_d is required as it seems there are 
			-- glitches using memclk itself
			elsif (dot2clk_d = '1' or is_80 = '1') then 
				pxlhold(7) <= pxlhold(6);
				pxlhold(6) <= pxlhold(5);
				pxlhold(5) <= pxlhold(4);
				pxlhold(4) <= pxlhold(3);
				pxlhold(3) <= pxlhold(2);
				pxlhold(2) <= pxlhold(1);
				pxlhold(1) <= pxlhold(0);
				pxlhold(0) <= '0';
			end if;
		end if;
	end process;
	
	pxl_out <= (pxlhold(7)) and enable;

	dena <= enable;
	
	--------------------------------------------
	-- crtc register emulation
	-- only 8/9 rows per char are emulated right now

	dbg_out <= '0';
	
	regfile: process(memclk, CPU_D, crtc_sel, crtc_rs, reset) 
	begin
		if (reset = '1') then
			crtc_reg <= X"0";
		elsif (falling_edge(memclk) 
				and crtc_sel = '1' 
				and crtc_rs='0'
				and crtc_rwb = '0'
				) then
			crtc_reg <= CPU_D(3 downto 0);
		end if;
	end process;
	
	reg9: process(phi2, CPU_D, crtc_sel, crtc_rs, crtc_rwb, crtc_reg, reset) 
	begin
		if (reset = '1') then
			is_9rows <= '0';
			is_10rows <= '0';
			vpage <= x"00";
		elsif (falling_edge(phi2) 
				and crtc_sel = '1' 
				and crtc_rs='1' 
				and crtc_rwb = '0'
				) then
			case (crtc_reg) is
			when x"9" =>
				is_9rows <= '0';
				is_10rows <= '0';
				if (CPU_D = x"08") then
					is_9rows <= '1';
				elsif (CPU_D = x"09") then
					is_10rows <= '1';
				end if;
			when x"c" =>
				vpage(3 downto 0) <= CPU_D(3 downto 0);
				vpage(4) <= not(CPU_D(4));	-- invert for PET boot
				vpage(7 downto 5) <= CPU_D(7 downto 5);
			when others =>
				null;
			end case;
		end if;
	end process;
	

end Behavioral;

