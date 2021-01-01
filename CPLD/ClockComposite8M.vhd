----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12/30/2020 
-- Design Name: 
-- Module Name:    Clock - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- 	This implements the clock management for 
--		- 50 MHz input clock
--		- 25 MHz pixel clock output (VGA)
--		- 8 MHz memory access (slightly above due to clock shaping)
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


entity Clock is
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
	   sr_load	: out std_logic		-- load SR on falling dotclk when this is set
	 );
end Clock;

architecture Behavioral of Clock is

	signal clk_cnt1 : std_logic_vector(1 downto 0);
	signal clk_cnt2 : std_logic_vector(3 downto 0);
	
	function To_Std_Logic(L: BOOLEAN) return std_ulogic is
	begin
		if L then
			return('1');
		else
			return('0');
		end if;
	end function To_Std_Logic;

begin

	clk_p: process(qclk, reset, clk_cnt1, clk_cnt2)
	begin
		if (reset = '1') then 
			clk_cnt1 <= (others => '0');
			clk_cnt2 <= (others => '0');
		elsif rising_edge(qclk) then
			if (clk_cnt1 = "10") then
				clk_cnt1 <= "00";
				clk_cnt2 <= clk_cnt2 + 1;
			else 
				clk_cnt1 <= clk_cnt1 + 1;
			end if;
		end if;
	end process;
	
	out_p: process(qclk, reset, clk_cnt2)
	begin
		if (reset = '1') then
			memclk <= '0';
			pxl_window <= '0';
			chr_window <= '0';
		elsif (falling_edge(qclk)) then

			chr_window <= To_Std_Logic(clk_cnt2(2 downto 1) = "01");	-- 2nd in slot
			pxl_window <= To_Std_Logic(clk_cnt2(2 downto 1) = "11");	-- last in slot
			
			dotclk <= clk_cnt1 (1);		-- 16 MHz (asymmetric)
			dot2clk <= clk_cnt2 (0);
			memclk <= clk_cnt2 (0);		-- 8 MHz
			sr_load <= clk_cnt2 (0);
			slotclk <= clk_cnt2 (2);	-- 2 MHz
			
		end if;
	end process;
	
	clk2_p: process(reset, qclk, clk_cnt2)
	begin
		if (reset = '1') then
			clk4m <= '0';
			clk2m <= '0';
			clk1m <= '0';
		elsif (rising_edge(qclk)) then
			clk4m <= clk_cnt2(1);
			clk2m <= To_Std_Logic(clk_cnt2(2 downto 1) = "11");
			clk1m <= To_Std_Logic(clk_cnt2 = "111");
		end if;
	end process;
	
end Behavioral;

