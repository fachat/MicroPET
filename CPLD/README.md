
# CPLD code for the MicroPET 1.0

The CPLD is a Xilinx xc95288xl chip, a 5V tolerable CPLD running with 3.3V supply voltage.
I programmed it in VHDL.

## Memory Map

The memory map looks as follows. There are 512k RAM, and 512k ROM, 
that make up banks 0-7 and banks 8-15 respectively. 

RAM bank 7 is the "video" bank in that hires graphics and character ROMs 
are mapped here. The character data can be mapped there as well using bit 2
of the control register (see below).

RAM bank 1 is the one used for the 8296 RAM extension (that is mapped into the
upper 32k of bank 0 when the 8296 control register at $fff0 is set.

	normal
	+----+ $0FFFFF
	|    |         ROM
	|    |         bank 15
	+----+ $0F0000
	|    |
      	 ...
	|    |
	+----+ $090000
	|    |         ROM
	|    |         bank 8
	+----+ $080000
	|    |         RAM
	|    |         bank 7 (video)
	+----+ $070000
	|    |
	 ...
	|    |
	+----+ $020000
	|    |         RAM
	|    |         bank 1 (8296 mapped memory)
	+----+ $010000
	|    |         RAM (PET ROM / I/O / Video) $8000-$ffff
	|    |         RAM (lower 32k)
	+----+ $000000


### Init Map

When the CPU boots, it tries to do so from bank 0. Here we have RAM, so we have to provide some 
initial mapping.

Therefore, on reset, the uppermost 16k of bank 15 (ROM) is mapped into bank 0, with the exception of the I/O space
at $e8xx.

This mapping can be disabled by writing to the ROM area (bank(3)=1). To boot, the boot loader will
set up the memory as desired, jump to a location outside the boot ROM, disable the initial boot mapping,
and start the main program.


## CRTC emulation

The Video code emulates two CRTC registers:

- Register 9: number of pixel rows per character -1
- Register 12: start of video memory high

All the other registers are not emulated, so any program or demo that
uses them will fail.

### Video memory mapping

The video memory is defined as follows:

#### Character mode

In character mode (see control port below) two memory areas are used:

1. Character memory and
2. Character pixel data (usually "character ROM")

Register 12 is used as follows:

- Bit 0: - unused -
- Bit 1: - unused -
- Bit 2: A10 of character memory in 40 column mode
- Bit 3: A11 of character memory
- Bit 4: A12 of character memory (inverted)
- Bit 5: A13 of character pixel data
- Bit 6: A14 of character pixel data
- Bit 7: A15 of character pixel data

As you can see, the character memory can be mapped in pages of screen size, and using
as many pages to fill up 8k of RAM.
For 40 column mode this means 8 screen pages, or 4 screen pages in 80 column mode.
Character memory is mapped to bank 0 at boot, but can be mapped to bank 7 using the control port below.
Note that Bit 4 is inverted, as the Commodore PET ROM sets address bit 12 to 1 on boot.

The character set is 8k in size: two character sets of 4k each, switchable with the 
VIA I/O pin given to the CRTC as in the PET. Register 12 can be used to select
one of 8 such 8k sets.
Character pixel data is mapped to bank 7.

#### Hires mode

Hires mode is available in 40 as well as 80 "column" mode, i.e. either 320x200 or 640x200 pixels.

- Bit 0: - unused -
- Bit 1: - unused -
- Bit 2: - unused -
- Bit 3: - unused -
- Bit 4: - unused -
- Bit 5: A13 of hires data (in 320x200 mode)
- Bit 6: A14 of hires data
- Bit 7: A15 of hires data

## Control Ports

### Micro-PET

There are two control ports at $e800 and $e801. They are currently only writable.

#### $e800 (59392) Video Control

- Bit 0: 0= character display, 1= hires display
- Bit 1: 0= 40 column display, 1= 80 column display
- Bit 2: 0= character memory in bank 0, 1= character memory in bank 7 (see memory map)
- Bit 3-5: unused, must be 0
- Bit 7: 0= video enabled; 1= video disabled


#### $e801 (59393) Memory Map Control

- Bit 0: 0= 8296 mode is disabled / locked ($fff0 disabled); 1= 8296 control port $fff0 enabled
- Bit 1-3: unused, must be 0
- Bit 4: 0= $009xxx is writable, 1= write protected
- Bit 5: 0= $00Axxx is writable, 1= write protected
- Bit 6: 0= $00Bxxx is writable, 1= write protected
- Bit 7: 0= $00C000-$00FFFF is writable, 1=write protected (except I/O window at $e8xx)

#### $e802 (59394) Low32k Bank

- Bit 0-3: number of 32k bank in 512k RAM, for the lowest 32k of system
- Bit 4-7: unused, must be 0

#### $e803 (59395) Speed Control

- Bit 0/1: speed mode
  - 00 = 1 MHz
  - 01 = 2 MHz
  - 10 = 4 MHz
  - 11 = 8 MHz with wait states for video access to RAM
- Bit 2-7: unused, must be 0


### 8296 control port

This control port enables the RAM mapping in the upper 32k of bank 0, as implemented
in the 8296 machine. The address of this port is $FFF0.

- Bit 0: 0= write enable in $8000-$bfff, 1= write protected
- Bit 1: 0= write enable in $c000-$ffff, 1= write protected
- Bit 2: select one of two block to map for $8000-$bfff (starts either $010000 or $018000)
- Bit 3: select one of two block to map for $c000-$ffff (starts either $014000 or $01c000)
- Bit 4: - unused, must be 0 -
- Bit 5: 0= RAM in $8xxx, 1= screen peek-through the mapped RAM
- Bit 6: 0= RAM in $e8xx, 1= I/O peek-through the mapped RAM
- Bit 7: 0= RAM mapping disabled, 1=enabled

## Code

The code contains three modules:

- Video.vhd: the video controller part
- Mapper.vhd: memory mapping
- Top.vhd: glue logic and timing

- pinout.ucf: Pinout definition

## Build

The VHDL code is compiled using the latest version of WebISE that still supports the xc95xxx chips, i.e. version 14.7.
It can still be downloaded from the Xilinx website.

For more information on the setup, see the [build file](Build.md).

