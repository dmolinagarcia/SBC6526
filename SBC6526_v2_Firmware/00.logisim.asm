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
// 2018 - 2023
//
// -----------------------------------------------------------------------------

.cpu _65c02
.file [name="logisim.bin", type="bin", segments="ROM"]

			#import "10.addresing.asm"

.segment ROM [min=$0000, max=$FFFF, fill]
 
*=$0300 "CODE" 
reset:
			lda #$01
			sta MACHINE_TYPE				// LOGISIM
			sta $B000 						// CIA RESET

			lda #$92
			sta CIA1_TODH

			lda #$92
			sta CIA1_TODH

			jmp t

			lda #$59
			sta CIA1_TODM
			sta CIA1_TODS
			lda #$00
			sta CIA1_TODT

			jsr krnShortDelay

			lda #$92
			sta CIA1_TODH
			lda #$01
			sta CIA1_TODM
			sta CIA1_TODS
			lda #$00
			sta CIA1_TODT

t:			jmp t



//		#import "90.ciaTests.asm"

codeEnd:	jmp codeEnd

*=$FF00 "KERNEL"
ciaReset:
			sta $B000
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
tickTodFromVia:
			sta $8000
kbdWaitOK:
scrScrollUp:
scrScrollDown:
scrInitialize:
scrClear:
krnDoNothing:
scrRefresh:
enableTodFromVia:
			rts


krnShortDelay:		
			rts		

krnLongDelay:		
			phx
     		ldx #$FF
	krnLongDelayLoop:  	
			jsr krnLongDelayEnd
     		dex
     		bne krnLongDelayLoop
     		plx
	krnLongDelayEnd:	
			rts	




kbdUp:
	jmp (keyUp)
kbdDown:
	jmp (keyDown)
kbdOk:
    jmp (keyOk)
kbdCancel:
	jmp (keyCancel)

keyUp: 		.word scrScrollUp 		// keyUp
keyDown:	.word scrScrollDown     // keydown
keyOk:		.word krnDoNothing      // keyOk
keyCancel:	.word krnDoNothing      // keyCancel


nib2hex:
// Converts lower nibble in A into hexadecimal ascci
// We don't save A in stack, as it's our return value
				cmp #$0a
         		bcc nib2hex0_9           
		        ora #$30
		        clc
		        adc #$07
		        rts
nib2hex0_9:		ora #$30         
				rts

irqHand:		lda CIA2_ICR	
				rti				


//////////////////////////////////////////////////////////////////////////////
//////   VECTORS                                                        //////
//////////////////////////////////////////////////////////////////////////////

*=$FFFA "VECTORS"
vecNMI:		.word irqHand 			// NMI
vecRES:		.word reset  			// Reset
vecIRQ:		.word irqHand  			// IRQ/BRK

// VECTORS ///////////////////////////////////////////////////////////////////



// Test Results

// 41 TB counts TA >> kbdOk
// 48 KO 
// 49 KO 
// 50 KO 
// 51 KO 
// 52 NA 
// 53 STUCK 

// 41 Is normal counting
// 48 - 53 are interrupt firing tests
