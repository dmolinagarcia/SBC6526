// -----------------------------------------------------------------------------
// 
// LOGISIM 6526 SBC Firmware
//
//
// 0300 - 7FFF Free RAM
// 8000 - BFFF 8 Blocks IO
// 8800 - CIA1
// 9800 - CIA2
// Write to $A000 outputs to TERM
// Write to $A001 Resets CIAs
// C000 - FEFF Free RAM
// FF00 - FFFF Minimum Kernel
//
// Author : Daniel Molina 
// https://github.com/dmolinagarcia
//
// 2018 - 2021
//
// -----------------------------------------------------------------------------

.cpu _65c02
.file [name="logisim.bin", type="bin", segments="ROM"]

			#import "10.addresing.asm"

.segment ROM [min=$0000, max=$FFFF, fill]

*=$0300 "CODE" 
program: 	
			lda #$01
			sta MACHINE_TYPE				// LOGISIM
			#import "90.ciaTests.asm"

codeEnd:		jmp codeEnd

*=$FF00 "KERNEL"
ciaReset:
			sta $A001
			rts

scrPrintChar:
			sta $A000
			rts

scrPrintStr:
// Prints string stored at X_Y
			pha
			stx STRING_POINTER
			sty STRING_POINTER+1

scrPrintStr1:
			ldy #$00
			lda (STRING_POINTER),y 
			cmp #$00
			beq scrPrintStrEnd
			sta $A000
			inc STRING_POINTER
			bne scrPrintStr1
			inc STRING_POINTER+1
			jmp scrPrintStr1

scrPrintStrEnd:
			pla
			rts

// TODO. Ported form v1 'as is'
// Dummy functions for logisim
// kbd and lcd functions not loaded
// Where are these used???
kbdWaitOK:
lcdReset:
krnShortDelay:
			rts

//////////////////////////////////////////////////////////////////////////////
//////   VECTORS                                                        //////
//////////////////////////////////////////////////////////////////////////////

*=$FFFA "VECTORS"
vecNMI:		.word program 			// NMI
vecRES:		.word program  			// Reset
vecIRQ:		.word program  			// IRQ/BRK

// VECTORS ///////////////////////////////////////////////////////////////////