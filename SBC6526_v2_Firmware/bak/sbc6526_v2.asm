// 30 Key pressed
.const KEY_PRESSED		= $30
.const UP 				= %00001000
.const DOWN 			= %00000100
.const OK 				= %00000010
.const CANCEL 			= %00000001


reset:

			jsr ciaReset					
			jsr ciaTodStart
			jsr krnFreqMeter
			jsr scrClear
			jsr scrInitialize
			jsr kbdSetup
			jsr lcdReset
			jsr viaSetTimerInterrupt
			jmp program



ciaTodStart:
// Sets TOD and starts it
			pha
	 		lda #$12			
	 		sta CIA_TODH			// 12 AM
	 		lda #$00
 			sta CIA_TODM
			sta CIA_TODS
			sta CIA_TODT			// AM 12:00:00.0
 			pla
			rts

#import "kbdFunctions.asm"

krnFreqMeter:
//Determines current clock frequency
			pha
			phx
			phy

			ldx #$4A					// Counter LO prescaler
			stx FREQ_COUNTER_LO			// Counter LO stored
			ldy #$0A        			// Counter HI prescaler
			sty FREQ_COUNTER_HI			// Counter HI stored
			lda #$00		
			sta FREQ_METER				// Result location Initialized

			lda CIA_TODT
krnFreqMeterWait1:			
			cmp CIA_TODT
			beq krnFreqMeterWait1		// Wait for 10ths to change	
			lda CIA_TODT				// Store new 10ths value
		
krnFreqMeterWait2:			
			dec FREQ_COUNTER_LO			// Dec LO counter
			bne krnFreqMeterWait3		// If not 0, end
			stx FREQ_COUNTER_LO			// If 0, restore LO
			dec FREQ_COUNTER_HI			// and dec HI counter
			bne krnFreqMeterWait3		// If not 0, end
			sty FREQ_COUNTER_HI			// If 0, restore HI
			inc FREQ_METER				// and increase result
krnFreqMeterWait3:			
			cmp CIA_TODT				// Has 10ths changed?
			beq krnFreqMeterWait2		// If not, continue

			ply
			plx
			pla
			rts	 


#import "lcdFunctions.asm"
#import "scrFunctions.asm"

viaSetTimerInterrupt:
			pha

			lda FREQ_METER				// Load system frequency
			sta IRQ_COUNTER				// into interrupt counter

			lda #%01000000
			sta VIA_ACR					// TIMER1 continuoUs. PB7 off, shift register off, pb latches off

			lda #$20
			sta VIA_T1CL
			lda #$4E
			sta VIA_T1CH            	// 4e20 = 20000 ticks en los latches

			lda #%11000000
			sta VIA_IER 				// Enable Timer 1 interrupts

			pla
			rts

viaISR:
			bit VIA_T1CL				// Clear VIA interrupt flag
			dec IRQ_COUNTER				// Decrement interrupt counter
			bne viaISRend				// Si no es 0, salimos
			jsr scrRefresh				// Si es 0, draw screen
			jsr kbdScan					// Scan Keyboard
			pha
			lda FREQ_METER
			sta IRQ_COUNTER				// Restore interrupt counter
			lda (SCREEN_CURSOR_POINTER) // Blink Cursor
			eor #$DF
			sta (SCREEN_CURSOR_POINTER)
			pla
viaISRend:  rti

// Keyboard Jump table
kbdUp:
	jmp (keyUp)
kbdDown:
	jmp (keyDown)
kbdOk:
    jmp (keyOk)
kbdCancel:
	jmp (keyCancel)
krnDoNothing:
	rts


*=$FFF2 "JUMP TABLE" 
keyUp: 		.word scrScrollUp 		// keyUp
keyDown:	.word scrScrollDown     // keydown
keyOk:		.word krnDoNothing      // keyOk
keyCancel:	.word krnDoNothing      // keyCancel


     