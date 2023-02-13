// -----------------------------------------------------------------------------
// 
// 6526 Test Suite for SBC6526 v2 v2.0.2
//
// -----------------------------------------------------------------------------
//  
// Target Test is CIA2 (CIAEXT)
// CIA1 should be regular CIA
//
// Author : Daniel Molina 
// https://github.com/dmolinagarcia
//

// 2018 - 2023
//
// -----------------------------------------------------------------------------


//////// small test for 01cmpold


 					lda #%01000000
 					sta VIA_IER				// Disable VIA INTERRUPT
					
					jsr ciaReset			// Reset CIA
					sei 					// Disable CIA interrupts

					lda #<nmi
					sta vecIRQ
					lda #>nmi
					sta vecIRQ+1 			// IRQ vector pointed to nmi:

					cli 					// Enable CIA interrupts

test:
					ldx #$00
					stx $AA

					ldy #$82
					sty CIA2_ICR			// Enable CIA2 TB interrupts
					ldy #$ff
					sty CIA1_TALO
					ldy #$00
					sty CIA1_TAHI		    // CIA1 TA set to 0x00ff
					ldy #$01
					sty CIA1_CRGA			// Start CIA1 TALO

loada:
					ldy #$10
					sty CIA2_TALO
					ldy #$00
					sty CIA2_TAHI			// CIA2 TA set to 0x0010
forceloada:
					ldy #%00010011			// 00010111 : FL PULSE PB6ON START CONT PHI2
					sty CIA2_CRGA
loadb:
					ldy #$00
					sty CIA2_TBLO			// CIA2 TB set to 0x0000
					ldy #$00
					sty CIA2_TBHI
forceloadb:
					ldy #%01011011			// 01011011 : FL PULSE PB7 ON START O.S TAunderflows
					sty CIA2_CRGB

waitfornmi:
					nop
					sta $2000
					nop
					ldy $AA
					cpy #$01
					bne waitfornmi			// Wait for interrupt to happen
test01_end:
	 				lda #%11000000
 					sta VIA_IER				// Enable VIA INTERRUPT				

stop01cmp:			jmp stop01cmp

nmi:
					pha 
					lda CIA2_ICR
					lda CIA1_TALO
					jsr scrPrint8
 					inc $AA
 					pla
					rti






#import "91.ciaTestsInit.asm"
testCIA2:
#import "92.ciaTestsDdrPort.asm"
lda #$13
sta testNo
#import "93.ciaTestsCregTimerA.asm"
#import "94.ciaTestsCregTimerB.asm"
#import "95.ciaTestsIcr.asm"
#import "99.ciaTestsEnd.asm"

jsr kbdWaitOK
jmp reset

