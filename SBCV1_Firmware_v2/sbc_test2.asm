.cpu _65c02
.file [name="sbcv1.bin", type="bin", segments="ROM"]

.segment ROM [min=$E000, max=$FFFF, fill]

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

// Incluir direccionamiento de la CIA EXT para v2

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

// 30 Key pressed
.const KEY_PRESSED		= $30
.const UP 				= %00001000
.const DOWN 			= %00000100
.const OK 				= %00000010
.const CANCEL 			= %00000001

// FREQ METER
//////////////////////////////////////////////////////////////////////////////

	// A0 A1 A2
		// A0 A1  counter
		// A2 hundreds of KHz
		// A3 counter to time interrupts

.const FREQ_COUNTER_LO	= $A0
.const FREQ_COUNTER_HI	= $A1
.const FREQ_METER		= $A2
.const IRQ_COUNTER		= $A3


//////////////////////////////////////////////////////////////////////////////
//////   RAM                                                            //////
//////////////////////////////////////////////////////////////////////////////

*=$E000 "RAM"  
program:

#import "ciaTests.asm"

programEnd:		jmp programEnd


//////////////////////////////////////////////////////////////////////////////
//////   ROM                                                            //////
//////////////////////////////////////////////////////////////////////////////

*=$FC00 "ROM"

reset:
			lda #20						    // DEFAULT 20.0 MHz
			sta FREQ_METER					// Needed to reset CIA in worst case scenario
			jsr ciaReset					
			jsr ciaTodStart
			jsr krnFreqMeter
			jsr scrClear
			jsr scrInitialize
			jsr kbdSetup
			jsr lcdReset
			jsr viaSetTimerInterrupt
			jmp program

ciaReset:
// Resets the 6526
			pha
			lda #$20
			sta VIA_DDRA			// PA5 (/CIARES) set as output
			lda #$00	
			sta VIA_PRTA			// /CIARES PULLED LOW
			jsr krnShortDelay
			lda #$FF	
			sta VIA_PRTA			// /CIARES PULLED HIGH
			pla
			rts

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

*=$FFFA "VECTORS"
vecNMI:		.word viaISR 			// NMI
vecRES:		.word reset  			// Reset
vecIRQ:		.word $0000  			// IRQ/BRK
     