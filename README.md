## SBCv1.sch and SBCv1.brd

These files are the first "production " run of my SBC. It has some issues though:

1. Missing a 3K3 Pull-Up Resistor on the /IRQ line
2. Missing 4 3K3 Pull-Up Resistors on the 4 input buttons
3. LCD connector has to be soldered on the bottom of the PCB, as there's no space on top of it for the connector. Because of this, the cable connected to the LCD has all the even/odd wires interchanged. A quick hack, but works. v2 Will solve this
4. The two left stands for the LCD don't have space either on the PCB, so the build is a bit.. unstable.
5. The power jack is completely disposable. A arduino nano gives enough current for the SBC to work up to 15 Mhz

The adjustable clock works, but it tops at around 17 MHz, beyond that, it won't work at all.

LED2 and LED3 common cathod signals are reversed, solved on this version by cutting the traces and adding some bodge wires.

## TEST5.ino (and RAm595 library)
Arduino code to upload an image to ram. Arduino listens on the serial port for the following commands

- S         : Pulls BE low, disconnecting the 6502 from the bus and enabling the shift registers
- A 0000    : Sets the address bus to 0000
- R 0000    : Reads and returns over serial value at memory location 0000
- W 0000 00 : Writes 00 in memory location 0000
- X         : Pulls BE high, disabling the shift registers and reenabling the 6502. The CPU is then reset and code execution begins
- B 0000 00 000F : Bulk program, staring at 0000 for 000F bytes. Maximum is 1K (0400). Bytes sent to the arduino after this are written sequentially on memory


## RAMFLASHER.java
Java code to program a .bin file to the SBC. Right now, the address and source file are hardcoded.  Requires jSerialComm-2.6.1.jar

## SBC_TEST1.asm
- Current firmware. It implements basic IO functions. Handles the LCD screen with a movable window in memory (0x7000 - 0x7fff). Up and Down buttons move the window. All string funcitions move a virtual cursor through the memory map.
- LCD refresh is implemented via interrupts with VIA Timer. The whole screen is redraw 5 time per sec and the keyboard scanned.
- customizable calls are executed whenever any button is pressed. Memory Location 0x30 contains the pressed key to be read by software.


