# uPET R2

This is a re-incarnation of the Commodore PET computer(s) from the later 1970s.

It is build on a Eurocard board and has (so far almost) only parts that can still be obtained in 2020.
The current version is 1.0E.

![Picture of a MicroPET](images/upet.png)

Some videos on the build process can be found here [YT 8-bit times](https://youtube.com/playlist?list=PLi1dzy7kw1iybjcUccgjCV4fhNH4IPWSx)

## Features

The board is built with a number of potential features, not all of them have been implemented at this time.
So we have two sections - what works and what will (hopefully) work at some point.

### Implemented

- Commodore 3032 / 4032 / 8032 / 8296 with options menu to select at boot
  - Boot-menu to select different PET versions to run
  - 40 col character display
  - 80 col character display
  - IEEE488 interface (card edge)
  - Tape connector (card edge)
  - PET graphics keyboard, or alternatively a C64 keyboard
- Improved system design:
  - 512k video RAM, 512k fast RAM accessible using banks on the W65816 CPU
  - boot from an SPI Flash ROM
  - up to 9 MHz mode (via configuration register)
  - VGA video output
  - Write protection for the PET ROMs once copied to RAM
- Improved Video output:
  - Hires graphics mode (using a configuration register)
  - modifyable character set
  - 40/80 column display switchable

## Build

Here are three subdirectories:

- [Board](Board/) that contains the board schematics and layout
- [CPLD](CPLD/) contains the VHDL code to program the CPLD logic chip used
- [ROM](ROM/) ROM contents to boot
- [Case](Case/) 3-D printed supports and keyboards to mount board in a C64c case

### Board

To build the board, you have to find a provider that builds PCBs from Eagle .brd files.
Currently no gerbers are provided.

### CPLD

The CPLD is a Xilinx xc95288xl programmable logic chip. It runs on 3.3V, but is 5V tolerant,
so can be directly connected to 5V TTL chips. I programmed it in VHDL.

Unfortunately the W65xx parts are "only" CMOS, and not TTL input chips - but 3.3V is still above
the VCC/2 for the 5V chips. Only Phi2 needs improvements on the signal quality using a pull-up resistor
and specific VHDL programming.

### ROM

The ROM image can be built using gcc, xa65, and make. Use your favourite EPROM programmer to burn it into the SPI Flash chip.

Two options are provided:

1. An original ROM version that boots into the original editor ROMs
2. Updated editor ROMs from [Steve's Editor ROM project](http://www.6502.org/users/sjgray/projects/editrom/index.html) that can optionally handle C64 keyboards, has a DOS wedge included, and resets into the Micro-PET boot menu


## Future Plans

These are future expansions I want to look into. Not all may be possible to implement.

- n/a
 
