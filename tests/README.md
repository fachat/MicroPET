
# Unit tests

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

