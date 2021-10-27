.cpu _65c02
.file [name="logisim.bin", type="bin", segments="ROM"]

.segment ROM [min=$0000, max=$FFFF, fill]

#import "10.addresing.asm"

//////////////////////////////////////////////////////////////////////////////
//////   RAM                                                            //////
//////////////////////////////////////////////////////////////////////////////

*=$E000 "RAM"  
program:
		lda CIA1_DDRA
		inc
		sta CIA1_DDRA
		inc CIA2_DDRA
		sta CIA2_PRTB

		ldx #<str_title				// Print title			
		ldy #>str_title
		jsr scrPrintStr


programEnd:		jmp program

str_title:
	.text "-= 74HCT6526 TEST =-"
	.byte $00

// RAM ///////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
//////   ROM                                                            //////
//////////////////////////////////////////////////////////////////////////////

*=$FC00 "ROM"

reset:
// Reset Routine
// Sets up screen and resets CIAs
// Jumps back to program
			jsr scrInitialize
			jsr ciaReset
			jmp program

scrInitialize:
// Sets up screen pointers
			pha
			lda #<SCREEN_BASE
			sta SCREEN_POINTER
			sta SCREEN_CURSOR_POINTER
			lda #>SCREEN_BASE
			sta SCREEN_POINTER+1 					// Set up base window
			sta SCREEN_CURSOR_POINTER+1
			lda #$00
			sta SCREEN_CURSOR						// Initialize cursor 
													// position to 0
			pla
			rts

ciaReset:
// Resets the 6526s
// In logisim model, any write to $4000 resets CIAs
			sta $4000
			rts

scrPrintStr:
// Prints string stored at X_Y
			pha
			phy
			stx STRING_POINTER
			sty STRING_POINTER+1

scrPrintStr1:
			ldy #$00
			lda (STRING_POINTER),y 
			cmp #$00
			beq scrPrintStrEnd
			sta $7000								// TERM sits at $7000
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


// TODO. Ported form v1 'as is'
// Dummy functions for logisim
// kbd and lcd functions not loadesd
kbdWaitOK:
lcdReset:
krnShortDelay:
			rts


// ROM ///////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
//////   VECTORS                                                        //////
//////////////////////////////////////////////////////////////////////////////

*=$FFFA "VECTORS"
vecNMI:		.word reset 			// NMI
vecRES:		.word reset  			// Reset
vecIRQ:		.word reset  			// IRQ/BRK

// VECTORS ///////////////////////////////////////////////////////////////////