# SBC6526

SBC6526 is a single board computer built around A 65c02 CPU. It has been designed with a very specific purpose, that has defined both its name and its specs. I've been working for some time already on a MOS6526 (The famous CIA used in Commodore Computers) replica using 74xx logic series ICs. Testing was done on a real C64, but soon this prove to be a very limiting factor. So I begin working on a small SBC, designed entirely around the 6526, that should allow me to run as many tests, with no limitations at all.

The initial set of requisites was

* Continuosly variable clock, from 1MHz to as far as possible, in order to push my replica to its limits
* Clock Frequency Display. Useful, and should look very cool.
* No input at all. Program the ROM (more on this later) and just run a suite of tests for the 6526.
* Basic output.. Something like a 20x4 Character LCD will do.
* Easy, quick, and on board ROM programming. I will be modifiying the code continuosly, so this is very important.
* Include a 6522. Why not!? It can also be useful for the tests
* Include a socket for a 6526. Compatibility with old NMOS 6526 is not needed, although it would be nice.
* Allow testing of all 6526 pins. Ports, serial, /FLAG interrupt, etc
* Independent reset for 6526.

SBCv1 came to life, fulfilling this requirements. Howeever, after using it for some time, it show some weakness. SBCv1 has a 6522 and a 6526. A 4x40 LCD is used as display, driven by the 6526. This causes the display to blank when running some tests, and sometimes, crashed the LCD into an unrecoverable state, that requires a complete power down. This along some layout issues, forced the next revision. 

> ###### IMPORTANT NOTE
> SBCv1, even with some issues, has been tested. It works, and it's somehow usable. It's no longer under development, except for some minor tweaks.

## SBCv1.sch and SBCv1.brd

These files are the first "production " run of my SBC. It has some issues though:

1. Missing a 3K3 Pull-Up Resistor on the /IRQ line
2. Missing 4 3K3 Pull-Up Resistors on the 4 input buttons
3. LCD connector has to be soldered on the bottom of the PCB, as there's no space on top of it for the connector. Because of this, the cable connected to the LCD has all the even/odd wires interchanged. A quick hack, but works. v2 Will solve this
4. The two left stands for the LCD don't have space either on the PCB, so the build is a bit.. unstable.
5. The power jack is completely disposable. A arduino nano gives enough current for the SBC to work up to 15 Mhz

The adjustable clock works, but it tops at around 17 MHz, beyond that, it won't work at all.

LED2 and LED3 common cathod signals are reversed, solved on this version by cutting the traces and adding some bodge wires.

## bootstrap.ino (and RAm595 library)
Arduino code to upload an image to ram. Arduino listens on the serial port for the following commands

- S         : Pulls BE low, disconnecting the 6502 from the bus and enabling the shift registers
- A 0000    : Sets the address bus to 0000
- R 0000    : Reads and returns over serial value at memory location 0000
- W 0000 00 : Writes 00 in memory location 0000
- X         : Pulls BE high, disabling the shift registers and reenabling the 6502. The CPU is then reset and code execution begins
- B 0000 00 000F : Bulk program, staring at 0000 for 000F bytes. Maximum is 1K (0400). Bytes sent to the arduino after this are written sequentially on memory


## RAMFLASHER.java
Java code to program a .bin file to the SBC. Right now, the address and source file are hardcoded.  Requires jSerialComm-2.6.1.jar

## SBC_TEST_v1
- First firmware. It implements basic IO functions. Handles the LCD screen with a movable window in memory (0x7000 - 0x7fff). Up and Down buttons move the window. All string funcitions move a virtual cursor through the memory map.
- LCD refresh is implemented via interrupts with VIA Timer. The whole screen is redraw 5 time per sec and the keyboard scanned.
- customizable calls are executed whenever any button is pressed. Memory Location 0x30 contains the pressed key to be read by software.

## SBC_TEST_v2
- Last firmware. Main code is splitted into several libraries, and a stripped down version of the firmware has been created to run with a LOGISIM model found at https://github.com/dmolinagarcia/LOGISIM6526


