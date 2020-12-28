
# Board

The board is a two-layer Eurocard, i.e. 160mm x 100mm.

## Schematics & Layout

The schematics and layout have been created with Cadsoft Eagle.
So, here you can find the 

- [micropet_v1.sch](micropet_v1.sch) and
- [micropet_v1.brd](micropet_v1.brd) files

But, you can still have a look at the schematics and layout using the
PNG images created

- [micropet_v1-sch-1.png](micropet_v1-sch-1.png) Part 1
- [micropet_v1-sch-2.png](micropet_v1-sch-2.png) Part 2
- [micropet_v1-sch-3.png](micropet_v1-sch-3.png) Part 3

## Bill of Material

- 1x W65816S CPU
- 2x W65C21S PIA
- 1x W65C22N VIA

- 1x xc95288xl CPLD
- 1x AS6C4008-55PCN 512k RAM
- 1x 39SF040-70 512k ROM
- 3x MC3446 IEEE488 drivers
- 1x 74LS145 4-to-10 BCD O.C. driver (keyboard)
- 1x 74LS07
- 1x DS1813 RESET controller

- 50 MHZ crystal oscillator

- LM317T variable voltage regulator

- 21x 0.1uF bypass caps

- 5.1kOhm / 2.4kOhm pairs for IEEE488
- 10kOhm pullup
- 1x 1kOhm pullup
- 1x 8x10kOhm resistor array (keyboard pull up)

- div. resistors/caps to generate 3.3V output

More details can be found in the [Eagle parts list](micropet_v1.parts).

## Erratum

- 1.0A has the bug that the CON pin for the clock oscillator is pulled low. This disables clock oscillators with tri-state input (which I did not notice with the original 32MHz oscillator, only with a 50MHz part later).

-
