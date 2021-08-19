
# SPI interface

## Overview

The SPI interface is as simple as I could make it, to save resources in the CPLD.

Nevertheless it has a transmit data register where data can be loaded to transmit, even if the
previous transmit is already in progress.
Also, there are two registers to read the data - one that just returns the current shift register value,
and another that automatically triggers reading a new byte from SPI.
These two features are implemented to increase throughput.

The CPHA and CPOL bits in the control register can be used to select the required SPI mode.

## Register Set

The SPI interface has four addresses, of which 3 are currently used:

- $e808: control register (read/write)
  - Bit 0-2: SPI device selection (write only)
  - Bit 3: - unused, must be 0
  - Bit 4: CPHA (write only)
  - Bit 5: CPOL (write only)
  - Bit 6: 1: tx data register is occupied; 0: tx data register is free, you can reload it (read only)
  - Bit 7: 1: shift register is in use (read only)

- $e809: data register (read/write)
  - Read: Bit 0-7: read the current state of the shift register, and trigger reading a new byte from SPI
  - Write: Bit 0-7: write to the transmit data register, and start shifting it out (waiting for a previous byte to finish if needed)

- $e80a: data register (peek)
  - Read: Bit 0-7: read the current state of the shift register


