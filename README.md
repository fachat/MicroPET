# uPET

This is a re-incarnation of the Commodore PET computer(s) from the later 1970s.

It is build on a Eurocard board and has (so far almost) only parts that can still be obtained in 2020.
The current version is 1.0E.

![Picture of a MicroPET](images/upet.png)

## Features

The board is built with a number of potential features, not all of them have been implemented at this time.
So we have two sections - what works and what will (hopefully) work at some point.

### Implemented

- Commodore 3032 
  - 40 col character display
  - IEEE488 interface
  - PET graphics keyboard
- Improved system design:
  - 512k RAM, 512k ROM, accessible using banks on the W65816 CPU
  - up to 8 MHz mode (currently by modifying VHDL)
  - Composite video output
- Improved Video output:
  - Hires graphics mode (currently using a jumper)
  - modifyable character set
  - 40/80 column display switchable

### Planned

- Other Commodore models 4032, 8032, 8296
- Configurable modes (speed 1/2/4/8 MHz, 40/80 column, character/hires mode)
- Writable ROM (although that may be superseded with the SPI-based ROM)

## Build

Here are three subdirectories:

- [Board](Board/) that contains the board schematics and layout
- [CPLD](CPLD/) contains the VHDL code to program the CPLD logic chip used
- [ROM](ROM/) ROM contents to boot

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

The ROM image can be built using gcc, xa65, and make. Use your favourite EPROM programmer to burn it into the ROM chip.

## Future Plans

These are future expansions I want to look into. Not all may be possible to implement.

- Replace MC3446 IEEE488 drives with 74LS640-1 
- Replace IEEE488 connector with board edge connector
- Add Tape board edge connector
- VGA video output (may break timing-related demos though)
- add SPI bus
- Replace 8-bit ROM with an SPI-based ROM, boot from SPI

 
