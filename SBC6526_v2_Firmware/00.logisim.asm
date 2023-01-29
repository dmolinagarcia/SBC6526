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
program: 	lda #$01
			sta MACHINE_TYPE				// LOGISIM
			// #import "90.ciaTests.asm"

sei

jsr ciaReset
ldy #$82
sty CIA2_ICR
lda #$03
sta loadb+1

 

// CIA 1 fires IRQ

lda #<nmi
sta vecIRQ
lda #>nmi
sta vecIRQ+1

cli



test:
ldx #$00
stx $AA

ldy #$82
sty CIA2_ICR
ldy #$FF
sty CIA1_TALO
ldy #$00
sty CIA1_TAHI

ldy #$d5
sty CIA1_CRGA

loada:
	ldy #$10
	sty CIA2_TALO
	ldy #$00
	sty CIA2_TAHI
forceloada:
	ldy #$d5
	sty CIA2_CRGA

loadb:
	ldy #$01
	sty CIA2_TBLO
	ldy #$00
	sty CIA2_TBHI
forceloadb:
	ldy #$d9
	sty CIA2_CRGB

// Wait for irq
waitfornmi:
	ldy $AA
	cpy #$01
	bne waitfornmi

jmp test

nmi:
	pha 
	lda CIA1_TALO
incHere:	
	sta $0600
	inc incHere+1
	lda CIA2_ICR
 	pla
 	ldx loadb+1
 	dex 
 	stx loadb+1
 	cpx #$FF
 	beq codeEnd
 	inc $AA
	rti



codeEnd:	jmp codeEnd

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
scrScrollUp:
scrScrollDown:
scrInitialize:
scrClear:
krnDoNothing:
scrRefresh:
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
vecRES:		.word program  			// Reset
vecIRQ:		.word irqHand  			// IRQ/BRK

// VECTORS ///////////////////////////////////////////////////////////////////