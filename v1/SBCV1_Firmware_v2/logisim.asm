.cpu _65c02
.file [name="logisim.bin", type="bin", segments="ROM"]

.segment ROM [min=$0000, max=$FFFF, fill]

// PERIPHERAL ADDRESSING
//////////////////////////////////////////////////////////////////////////////

.const VIA_PRTB			= $9000
.const VIA_PRTA			= $9001
.const VIA_DDRB			= $9002
.const VIA_DDRA  		= $9003
.const VIA_T1CL			= $9004
.const VIA_T1CH			= $9005
.const VIA_T1LL			= $9006
.const VIA_T1LH			= $9007		
.const VIA_ACR			= $900B
.const VIA_IER			= $900E

.const CIA_PRTA			= $8800
.const CIA_PRTB			= $8001
.const CIA_DDRA			= $8802
.const CIA_DDRB			= $8803
.const CIA_TALO		    = $8804
.const CIA_TAHI         = $8805
.const CIA_TBLO		    = $8806
.const CIA_TBHI         = $8807
.const CIA_TODT			= $8808
.const CIA_TODS			= $8809
.const CIA_TODM			= $880A
.const CIA_TODH			= $880B
.const CIA_SDR   	    = $800C
.const CIA_ICR			= $880D
.const CIA_CRGA			= $880E
.const CIA_CRGB			= $880F

// SCREEN 
//////////////////////////////////////////////////////////////////////////////

// Buffer Starts at 7000
// Screen memory es 4 KB. hasta $7FFF

// Top left corner of screen at startup
.const SCREEN_BASE      = $7000
// 10 11. Pointer to top left on Screen
.const SCREEN_POINTER   = $10
// 12 13, Similar a screen pointer, pero para el cursor
.const SCREEN_CURSOR_POINTER = $12
// 14   . Cursor, next position to print (SCREEN_CURSOR_POINTER),SCREEN_CURSOR
.const SCREEN_CURSOR	= $14
// 15 16 . temporal para calculos de screen windows
.const SCREEN_WINDOW_TEMP = $15

// Kernal variables
//////////////////////////////////////////////////////////////////////////////

// 20 21 string pointer
.const STRING_POINTER	= $20

//////////////////////////////////////////////////////////////////////////////
//////   RAM                                                            //////
//////////////////////////////////////////////////////////////////////////////

*=$E000 "RAM"  
program:

#import "ciaTests.asm"


programEnd:		jmp programEnd

/////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
//////   ROM                                                            //////
//////////////////////////////////////////////////////////////////////////////

*=$FC00 "ROM"

reset:
			jsr scrInitialize
			jsr ciaReset
			jmp program

ciaReset:
// Resets the 6526
			sta $4000
			// En el logisim, un write a 4xxx resetea la cia
// Dummy functions for logisim
// kbd and lcd functions not loadesd
kbdWaitOK:
lcdReset:
krnShortDelay:
			rts

scrPrintStr:
			pha
			phy
			stx STRING_POINTER
			sty STRING_POINTER+1

scrPrintStr1:
			ldy #$00
			lda (STRING_POINTER),y 
			cmp #$00
			beq scrPrintStrEnd
			// jsr scrPrintChar
			// EN logisim, sustituimos por un sta $7000
			sta $7000
			inc STRING_POINTER
			bne scrPrintStr1
			inc STRING_POINTER+1
			jmp scrPrintStr1

scrPrintStrEnd:
			ply 
			pla
			rts

scrPrintChar:
			sta $7000
			rts
			
scrInitialize:
			pha
			lda #<SCREEN_BASE
			sta SCREEN_POINTER
			sta SCREEN_CURSOR_POINTER
			lda #>SCREEN_BASE
			sta SCREEN_POINTER+1 	// Set up base window
			sta SCREEN_CURSOR_POINTER+1
			lda #$00
			sta SCREEN_CURSOR		// Initialize cursor position to 0
			pla
			rts

*=$FFFA "VECTORS"
vecNMI:		.word reset 			// NMI
vecRES:		.word reset  			// Reset
vecIRQ:		.word reset  			// IRQ/BRK
     