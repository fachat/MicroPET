----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:06:36 06/20/2020 
-- Design Name: 
-- Module Name:    Mapper - Behavioral 
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

entity Mapper is
    Port ( A : in  STD_LOGIC_VECTOR (15 downto 8);
           D : in  STD_LOGIC_VECTOR (7 downto 0);
	   reset : in std_logic;
	   phi2: in std_logic;
	   vpa: in std_logic;
	   vda: in std_logic;
	   vpb: in std_logic;
	   rwb : in std_logic;
	   init: in std_logic;
	   
	   qclk: in std_logic;
	   
           cfgld : in  STD_LOGIC;	-- set when loading the cfg
	   
           RA : out  STD_LOGIC_VECTOR (18 downto 12);
	   ffsel: out std_logic;
	   endinit: out std_logic;	-- when set, de-assert init
	   iosel: out std_logic;
	   ramsel: out std_logic;
	   romsel: out std_logic;
	   
   	   wp_rom9: in std_logic;
	   wp_romA: in std_logic;
	   wp_romPET: in std_logic;

	   dbgout: out std_logic
	);
end Mapper;

architecture Behavioral of Mapper is

	signal cfg_mp: std_logic_vector(7 downto 0);
	signal bankl: std_logic_vector(7 downto 0);
	
	-- convenience
	signal low64k: std_logic;
	signal c8296ram: std_logic;
	signal petrom: std_logic;
	signal petrom9: std_logic;
	signal petromA: std_logic;
	signal petio: std_logic;
	signal wprot: std_logic;
	signal screen: std_logic;
	signal iopeek: std_logic;
	signal scrpeek: std_logic;

	signal avalid: std_logic;
	signal is_init: std_logic;
	
	signal bank: std_logic_vector(7 downto 0);
	
	constant init_bank: std_logic_vector(7 downto 0) := "00000111"; -- top most bank - boot loader

	function To_Std_Logic(L: BOOLEAN) return std_ulogic is
	begin
		if L then
			return('1');
		else
			return('0');
		end if;
	end function To_Std_Logic;
	
begin

	
	avalid <= vda or vpa;
	
	-- bummer, vpb is not connected to the CPLD
	-- and unfortunately vector pulls are vpa=0,vda=1,vpb=0
	-- so checking for vpa only does not work
	-- so let's at least do reads only ...
	-- but only on the upper 32k of bank0, as we need
	-- access to stack RAM to change data bank via stack ops(bummer!)
	is_init <= init and rwb --and (vpa or not(vpb)) -- read program or vectors
		and A(15) and A(14) 		-- in upper 16k (in all banks!)
		and To_Std_Logic(bankl = "00000000")
		and To_Std_Logic(A(15 downto 8) /= x"E8");
	
	-----------------------------------

	-- note: simply latching D at rising phi2 does not work,
	-- as in the logical part after the latch, the changing D already
	-- bleeds through, before the result is switched back when bankl is in effect.
	-- Therefore we sample D at half-qclk before the transition of phi2.
	-- This may lead to speed limits in faster designs, but works here.
	BankLatch: process(reset, D, phi2, qclk)
	begin
		if (reset ='1') then
			bankl <= (others => '0');
		elsif (rising_edge(qclk) and phi2='0') then
			bankl <= D;
		end if;
	end process;
	
	bank <= init_bank when is_init = '1' else bankl;
	
	low64k <= '1' when bank = "00000000" else '0';
	
	-- we may disable petio completely during init, our crude first boot loader just copies ROM over the
	-- the I/O area and triggers writes to I/O space
	petio <= '1' when low64k ='1'
			and A(15 downto 8) = x"E8"
		else '0';
	
	-- the following are only used to determine write protect
	-- of ROM area in the upper half of bank 0
	-- Is evaluated in bank 0 only, so low64k can be ignored here
	petrom <= '1' when A(15) = '1' and			-- upper half
			(A(14) = '1' or (A(13) ='1' and A(12) ='1'))	-- B-F (leaves 9/A as RAM) 
			else '0';
			
	petrom9 <= '1' when A(15 downto 12) = x"9"
			else '0';

	petromA <= '1' when A(15 downto 12) = x"A"
			else '0';

	screen <= '1' when A(15 downto 12) = x"8" 
			else '0';

	-- 8296 specifics. *peek allow using the IO and screen memory windows despite mapping RAM
	
	iopeek <= '1' when petio = '1' and cfg_mp(6)='1' else '0';
			 
	scrpeek <= '1' when screen = '1' and cfg_mp(5)='1' else '0';

	-- when c8296 is set, upper 16k of bank0 are mapped to RAM (with holes on *peek)
	-- evaluated in bank0 only, so low64k ignored here
	c8296ram <= '1' when cfg_mp(7) = '1'
				and iopeek = '0' 
				and scrpeek = '0'
				else '0';

	-- write should not happen (only evaluated in upper half of bank 0)
	wprot <= '0' when rwb = '1' else			-- read access are ok
			'0' when cfg_mp(7) = '1' and		-- ignore I/O window
				petio = '1' and iopeek = '1' 
				else
			'1' when cfg_mp(7) = '1' and		-- 8296 enabled
				((A(14)='1' and cfg_mp(1)='1')	-- upper 16k write protected
				or (A(14)='0' and cfg_mp(0)='1')) -- lower 16k write protected
				else 
			'0' when cfg_mp(7) = '1' 		-- 8296 RAM but no wp
				else
			'1' when petrom = '1' and wp_romPET = '1'
				else
			'1' when petrom9 = '1' and wp_rom9 = '1'
				else
			'1' when petromA = '1' and wp_romA = '1'
				else
			'0';
			 
	-----------------------------------
	-- addr output
	
	-- banks 2-15
	RA(18 downto 17) <= 
			bank(2 downto 1);			-- just map
	
	-- bank 0/1
	RA(16) <= 
			bank(0) when low64k = '0' else  	-- CPU is not in low 64k
			'1' 	when c8296ram = '1' 		-- 8296 enabled,
					and A(15) = '1' 	-- upper half of bank0
					else  			 
			'0';
			
	-- within bank0
	RA(15) <= A(15) when low64k = '0' else		-- some upper bank
			'0' when A(15) = '0' else	-- lower half of bank0
			'1' when c8296ram = '0' else	-- upper half of bank0, no 8296 mapping
			cfg_mp(3) when A(14) = '1' else	-- 8296 map block $c000-$ffff -> $1c000-1ffff / 14000-17fff
			cfg_mp(2);			-- 8296 map block $8000-$bfff -> $18000-1bfff / 10000-13fff
	
	-- the nice thing is that all mapping happens at A15/A16
	RA(14 downto 12) <= A(14 downto 12);

	ramsel <= '0' when avalid='0' else
			'0' when is_init = '1' else	-- not in init (reads)
			'0' when bank(3) = '1' else	-- not in upper half of 1M address space is ROM (4-7 are ignored, only 1M addr space)
			'1' when low64k = '0' else	-- 64k-512k is RAM, i.e. all above 64k besides ROM
			'1' when A(15) = '0' else	-- lower half bank0
			'0' when wprot = '1' else	-- 8296 write protect - upper half of bank0
			'1' when c8296ram = '1' else	-- upper half mapped (except peek through)
			'0' when petio = '1' else	-- not in I/O space
			'1';
	
	dbgout <= low64k; -- bank(3);
	
	romsel <= '0' when avalid='0' else
			'0' when rwb = '0' else		-- ignore writes
			'0' when petio = '1' else	-- ignore in PET I/O window
			'1' when is_init = '1' else	-- all reads during init (only upper 16k in each bank)
			'1' when bank(3) = '1' else	-- upper half of 1M address space is ROM (ignoring bits 4-7)
			'0';
	
	iosel <= '0' when avalid='0' else 
			'0' when c8296ram = '1' else	-- no peekthrough in 8296 mode
			'1' when petio ='1' else 
			'0';
			
	ffsel <= '0' when avalid='0' else
			'1' when low64k ='1' 
				and A(15 downto 8) = x"FF" else 
			'0';
	
	endinit <= '0' when avalid='0' else
			'0' when rwb = '1' else		-- ignore reads
			'1' when bank(3)='1' else	-- writes to upper memory (ROM)
			'0';
			
	-----------------------------------
	-- cfg
	
	CfgMP: process(reset, phi2, rwb, cfgld, D)
	begin
		if (reset ='1') then
			cfg_mp <= (others => '0');
		elsif (falling_edge(phi2)) then
			if (init = '0' and cfgld = '1' and rwb = '0') then
				cfg_mp <= D;
			end if;
		end if;
	end process;
	
	
end Behavioral;

