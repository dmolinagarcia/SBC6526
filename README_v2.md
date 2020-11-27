# SBC6526
A 6502 based SBC, capable of using a MOS6526, or the new replacement 74HCT6526

Being my first attempt at creating a SBC, v1 had many flaws. There were some pull-up resistors missing, the PCB layout was a mess, the bootstrap code was... well... unreadable to be honest. Moreover, the CAD tool I choose for v1, Eagle Cad, has a nasty licensing which is pulling away many users. I decided to make the transition to KiCAD for the v2. It's still a work in progress, and completely untested, but feel free to take a look if you like.

This readme will be updated as soon as new content is commited to the repository.

## BootStrap

The SBC6526 has no ROM. RAM exists between 0000-7FFF and C000-FFFF. As you know, the 6502 CPU needs the startup vectors to be present in the last segment of memory so, how does the SBC6526 boot?

An Arduino NANO handles the startup sequence. On startup, it brings BE low, disconnecting the 6502 from the address and data busses, and the R/W line. This also enables a pair of 8bit shift registers that handle from now on the address bus.

The RAM IC has 2 enable inputs. One is controled via the SBC Address Decoding logic, the other, directly by the ARDUINO. During BootStraping, RAMCE pulses with PHI2 (independent from the arduino) and the Arduino pulses CE line. This is a bit unorthodox and may cause some failures to write, if the arduino pulse happens when PHI2 is  high. This is handled by trying several times to write.

When the ROM image is written, BE is released, and the 6502 is resetted by the Arduino itself.
