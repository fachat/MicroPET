
# CPLD code for the MicroPET 1.0

The CPLD is a Xilinx xc95288xl chip, a 5V tolerable CPLD running with 3.3V supply voltage.
It is programmed in VHDL.

## Modes

The CPLD can be programmed in three modes:

- Composite mode - video output produces composite video timing, with full memory mapping (Note that this will go away in Release 2)
- VGA mode - VGA video output and full memory mapping, but rather basic CRTC emulation
- 4032 mode - VGA video output with a much more detailled CRTC emulation, but only 4032 memory mapping

The VGA and 4032 modes had to be separated due to resource restrictions in the CPLD.

See notes below which feature is available in which mode (but 8296 features are not in 4032 mode even if not mentioned).
Most notably also the 80 column and hires modes are not available in 4032.

Please see the [Build document](Build.md) for how to build the different versions.

## Memory Map

The memory map looks as follows. There are 512k RAM
that make up banks 0-7. 

RAM bank 7 is the "video" bank in that hires graphics and character ROMs 
are mapped here. The character data can be mapped there as well using bit 2
of the control register (see below).

RAM bank 1 is the one used for the 8296 RAM extension (that is mapped into the
upper 32k of bank 0 when the 8296 control register at $fff0 is set.

	normal
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
initial program load.

This is done by loading the lowermost 256 byte from the SPI Flash chip into the uppermost page
of bank 0. For this, the CPLD takes over control of the SPI lines, sends the READ command and address
to the SPI Flash, and stores the data in RAM. before it releases the reset signal to the CPU.

## CRTC emulation

The Video code (partially) emulates three CRTC registers:

- Register 1: characters per line (4032 mode only - fixed to 40 and 80 for 40 column and 80 column modes respectively))
- Register 6: character lines per screen (4032 mode only)
- Register 8: control register bit 0 (interlace)
- Register 9: number of pixel rows per character -1 (full for 4032, only check on > 8 else)
- Register 12: start of video memory high (see below)
- Register 13: start of video memory low (4032 only)

All the other registers are not emulated, so any program or demo that
uses them will fail.

### Interlace

In normal mode (after reset), the VGA video circuit runs in interlace mode,
i.e. only every second raster line is displayed with video data.

Writing a "1" into CRTC register 8, interlace is switched off, and every
single line is displayed with video data. I.e. every rasterline is 
displayed twice, to get to the same height as in interlace mode.

### Double mode

As VGA runs in 640x400 resolution, each pixel row is normally displayed twice, to get 
an appropriate width/height ratio on the screen.

However, using the Video control register the video output can be switched into double mode.
This means that pixel rows are not displayed twice, but one time only, resulting in
400 real pixel rows.

In character mode this means up to 50 lines (with 8 pixel rows per char), or 400 pixel vertical resolution.
So, we get additional hires resolutions of 320x400 pixel (40 column) and 640x400 (80 column).
Interlace must be switched off for this. 

### Video memory mapping

The video memory is defined as follows:

#### Character mode

In character mode (see control port below) two memory areas are used:

1. Character memory and
2. Character pixel data (usually "character ROM")

Register 12 is used as follows:

- Bit 0: A8 of character memory start address
- Bit 1: A9 of character memory start address
- Bit 2: A10 of character memory start address
- Bit 3: A11 of character memory start address
- Bit 4: A12 of character memory start address (inverted)
- Bit 5: A13 of character pixel data
- Bit 6: A14 of character pixel data
- Bit 7: A15 of character pixel data

As you can see, the character memory can be mapped in pages of screen size, and using
as many pages to fill up 8k of RAM.
For 40 column mode this means 8 screen pages, or 4 screen pages in 80 column mode.
Character memory is mapped into the upper half of bank 7, i.e. starting from $078000 up to $079FFF
Character memory is mapped to bank 0 at boot, but can be mapped to bank 7 using the control port below.
Note that Bit 4 is inverted, as the Commodore PET ROM sets address bit 12 to 1 on boot.

The character set is 8k in size: two character sets of 4k each, switchable with the 
VIA I/O pin given to the CRTC as in the PET. Register 12 can be used to select
one of 8 such 8k sets.
Character pixel data is mapped to bank 7 and can be mapped in the full 64k bank in steps of 8k 
using control bits 5,6 and 7. After reset it is at $070000.


Register 9: pixel rows per characters (stored minus 1)

- Bit 0: Bit 0 of number of pixel rows per char - 1 (4032 only)
- Bit 1: Bit 1 of number of pixel rows per char - 1 (4032 only)
- Bit 2: Bit 2 of number of pixel rows per char - 1 (4032 only)
- Bit 3: Bit 3 of number of pixel rows per char - 1


In 4032 mode, the following registers are also implemented:

Register 13: start of video memory low

- Bit 0-3: ignored
- Bit 4: A4 of character memory start address
- Bit 5: A5 of character memory start address
- Bit 6: A6 of character memory start address
- Bit 7: A7 of character memory start address

Register 1: Number of characters per line

- Bit 0-5: Number of characters per line (up to 63)
- Bit 6-7: ignored

Register 6: Number of character lines per screen

- Bit 0-6: Number of character lines per screen (up to 127)
- Bit 7: ignored


#### Hires mode

Hires mode is available in 40 as well as 80 "column" mode, i.e. either 320x200 or 640x200 pixels.
Note: it is not available in 4032 mode.

- Bit 0: A8 of start of hires data
- Bit 1: A9 of start of hires data
- Bit 2: A10 of start of hires data
- Bit 3: A11 of start of hires data
- Bit 4: A12 of start of hires data
- Bit 5: A13 of start of hires data (in 320x200 mode)
- Bit 6: A14 of start of hires data (in 320x200, 640x200 or 320x400 mode)
- Bit 7: A15 of start of hires data

## Control Ports

### Micro-PET

There are two control ports at $e800 and $e801. They are currently only writable.

#### $e800 (59392) Video Control

- Bit 0: 0= character display, 1= hires display
- Bit 1: 0= 40 column display, 1= 80 column display
- Bit 2: 0= character memory in bank 0, 1= character memory in bank 7 (see memory map)
- Bit 3: 0= double pixel rows, 1= single pixel rows (also 400 px vertical hires)
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

