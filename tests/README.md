
# Unit tests

## virtpet

This little test program shows the mapping features for the lower 32k, as well as the video memory window (where the
$8xxx area in CPU address space is mapped to video memory). 
It installs itself as a terminate-and-stay-resident (TSR), and checks when both SHIFT keys are pressed at the same time.
It then switches to the next of a total of four "virtual" PETs.

## low32k / map

These tests check the functionality to re-map the low 32k in bank 0 CPU address space into one of 16 32k-banks
in the 512k RAM chip.

### low32k 

This writes a signature into (almost) every block in each bank, and checks in a second pass if none of the
signatures have been overwritten.

Note that it will mangle the system font, as it writes the RAM signature there as well.

### map

This are (will be) small routines that can be used from the machine language monitor to fill / exchange 
data from other banks.

## ROM tests

### readflash

Reads the flash memory from BASIC

### romtest

- romtest01(a).a65: This test program fills bank 1 continuously with an increasing value. This can be used to check the hires mode. The output o
f its build has to be copied into the top 4k of the ROM to boot/run
- romtest02(a).a65: This test program copies an 8k character ROM image from start of the ROM to start of bank 7, where the video code takes its 
character information. Then fills the character screen, and continuously increase the value in the character screen at $008000. This tests the c
haracter display output. The output of its build has to be copied into the top 4k of the ROM to boot/run

