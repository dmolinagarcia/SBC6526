// -----------------------------------------------------------------------------
// 
// SBC6526v2 Firmware
//
// 0000 - 7FFF Free RAM
// 8000 - BFFF 8 Blocks IO
// 8800 - 8FFF CIA1
// 9000 - 97FF VIA
// 9800 - 9FFF CIA2
// C000 - FFFF Free RAM
//
// Author : Daniel Molina 
// https://github.com/dmolinagarcia
//
// 2018 - 2021
//
// -----------------------------------------------------------------------------

.cpu _65c02
.file [name="sbc6526_v2.bin", type="bin", segments="ROM"]

#import "10.addresing.asm"

.segment ROM [min=$F000, max=$FFFF, fill]

//////////////////////////////////////////////////////////////////////////////
//////   RAM                                                            //////
//////////////////////////////////////////////////////////////////////////////

*=$F000 "RAM"  
program: 		lda #%11111011			// Test all except R/W
				sta VIA_PRTA			// CiaReset HIGH

programEnd:		jmp programEnd

// RAM ///////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
//////   ROM                                                            //////
//////////////////////////////////////////////////////////////////////////////

reset:
			lda #20						    // DEFAULT 20.0 MHz
			sta FREQ_METER					// Needed to reset CIA in worst case scenario
			jsr viaInit						// Initializes VIA
			jsr ciaReset					// Resets CIAs
			jsr krnShortDelay
			jsr krnShortDelay
			jsr krnShortDelay
			jsr lcdReset					// Initialize display
			jmp program 					// Jump to user code

viaInit:
// Initializes VIA
			pha
			lda #$01
			sta VIA_PRTA			// CiaReset HIGH
									// LCD all LOW
			lda #$FF
			sta VIA_DDRA			// PA0     : ciaReset
									// PA1-PA7 : LCD
			pla
			rts

ciaReset:
// Resets the 6526
			pha
			lda VIA_PRTA
			and #$FE 				
			sta VIA_PRTA			// /CIARES PULLED LOW
			jsr krnShortDelay
			ora #$01
			sta VIA_PRTA			// /CIARES PULLED HIGH
			pla
			rts

krnShortDelay:		
// Short Delay. Constant depending on FREQ_METER
			phx
     		ldx FREQ_METER						// Delay, dependent on the clock
krnShortDelayLoop:  	
			jsr krnShortDelayEnd
     		dex
     		bne krnShortDelayLoop
     		plx
krnShortDelayEnd:	
			rts		

lcdInstr:  
// Send instruction in A HI nibble to lcd
			pha

			ora #$01 				// CIARES a 1 que es PA0
									// Envia instrucción al LCD. Bits 4-7 del acumulador
			and #$F1	            // Me quedo con los bits 4-7. RS, RW, E a 0 /ciares A 1
			sta VIA_PRTA			// Acumulador al PA
  			jsr krnShortDelay
			
			ora #$08				// Enable a 1
			sta VIA_PRTA
			jsr krnShortDelay

			and #$F1				// Enable a 0
			sta VIA_PRTA
 			jsr krnShortDelay

			pla
			rts				

lcdReset:	
// Reset, clear, and set 4 bit mode
			pha


			lda #$30
			jsr lcdInstr		// Enable 8-bit mode
			jsr krnShortDelay
			jsr krnShortDelay
			jsr krnShortDelay
			jsr krnShortDelay
			jsr krnShortDelay
			jsr krnShortDelay
			jsr krnShortDelay
			jsr krnShortDelay
			jsr krnShortDelay
			jsr krnShortDelay
			jsr krnShortDelay
			jsr krnShortDelay
			jsr krnShortDelay
			jsr krnShortDelay
			jsr krnShortDelay
			jsr krnShortDelay
			lda #$30
			jsr lcdInstr		// Enable 8-bit mode
			jsr krnShortDelay
			lda #$30
			jsr lcdInstr		// Enable 4-bit mode
			jsr krnShortDelay
			
			lda #$20
			jsr lcdInstr		// Enable 4-bit mode


			lda #$20			// 4-bit 2 lineas 5x8 fond
			jsr lcdInstr
			lda #$80
			jsr lcdInstr

			lda #$00			// Display OFF
			jsr lcdInstr
			lda #$80
			jsr lcdInstr

			lda #$00			// Clear Display
			jsr lcdInstr
			lda #$10
			jsr lcdInstr

			lda #$00			// Mode Set. Incrementd and shift
			jsr lcdInstr
			lda #$60
			jsr lcdInstr

			lda #$00			// Display on and cursor OFF
			jsr lcdInstr
			lda #$F0
			jsr lcdInstr

			pla
			rts

lcdChar:	
// Sends char in A to LCD at current cursor
			pha
			ora #$01 			// CIARESET mantenido high
			pha					// Guardamos A en la pila
			and #$F1 			// Me quedo con el upper nibble
			ora #$02			// Register = DATA
			sta VIA_PRTA
			jsr krnShortDelay

			ora #$08			// Enable a 1
			sta VIA_PRTA
			jsr krnShortDelay

			and #$F3			// Enable a 0
			sta VIA_PRTA
			jsr krnShortDelay

			pla 				// Recuperamos el caracter de la pila 
			asl
			asl
			asl
			asl					// desplazamos lower nibble a upper nibble
			ora #$01
			and #$F1
			ora #$02
			sta VIA_PRTA
			jsr krnShortDelay

			ora #$08
			sta VIA_PRTA
			jsr krnShortDelay

			and #$F3
			sta VIA_PRTA
			jsr krnShortDelay

			pla
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