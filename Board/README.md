
# Board V2.1A

The board is a two-layer Eurocard, i.e. 160mm x 100mm.

## Schematics & Layout

The schematics and layout have been created with Cadsoft Eagle.
So, here you can find the 

- [micropet_v2.sch](micropet_v2.sch) and
- [micropet_v2.brd](micropet_v2.brd) files

But, you can still have a look at the schematics and layout using the
PNG images created

- [micropet_v2-sch-1.png](micropet_v2-sch-1.png) Part 1 - PETIO
- [micropet_v2-sch-2.png](micropet_v2-sch-2.png) Part 2 - CPLD, CPU, RAM
- [micropet_v2-sch-3.png](micropet_v2-sch-3.png) Part 3 - Power
- [micropet_v2-sch-4.png](micropet_v2-sch-4.png) Part 4 - Video and Audio output
- [micropet_v2-sch-5.png](micropet_v2-sch-5.png) Part 5 - SPI devices (Eth, USB, RTCC, ...)

## Bill of Material

The main chips are:

- 1x W65816S CPU
- 2x W65C21N PIA
- 1x W65C22N VIA

- 1x xc95288xl CPLD
- 2x 8x512k parallel SRAM with 25ns access time
- 2x 74LS641-1
- 1x 74LS145 4-to-10 BCD O.C. driver (keyboard)
- 1x 74LS07
- 1x DS1813 RESET controller

- 50 MHZ crystal oscillator

- Voltage regulator

- x 0.1uF bypass caps

- 5.1kOhm / 2.4kOhm pairs of resistor arrays for IEEE488
- 10kOhm pullup
- 1x 1kOhm pullup
- 1x 8x10kOhm resistor array (keyboard pull up)

- div. resistors/caps to generate 3.3V output

More details can be found in the [Eagle parts list](micropet_v2.parts).

## Changelog

### V2.1A

In this version I incorporated the fixes I had to apply to the first prototype board. Also, I changed the IEEE488 circuit such that it can now really work as a disk drive for another PET. This brings it in line with the CSA PETIO 1.2A/1.3A boards that have this functionaly fixed.

## Erratum

This section describes fixes from my 2.0A prototype board, and these are the cuts/additional wires you see on the pictures, where I fixed my 2.0A boards.

### 2.0C

- I pulled up /IRQ to 5V, but that was potentially backfeeding to the 3.3V SPI devices. A pull-up to 3.3V still worked just fine without problems

### 2.0B

- In 2.0A I planned to use the 74245 to drive the system's Phi2 clocks (CPU & I/O), and to level-shift it. But it turned out that this was not stable, so I reverted to the pull-up resistor method again
- I was missing a cross-sheet connection for the I/O Phi2 clock
- Also I was missing the SPI select line for the RTCC


- 
-
