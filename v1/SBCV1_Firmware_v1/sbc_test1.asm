.cpu _65c02
.file [name="sbcv1.bin", type="bin", segments="ROM"]
.segment ROM [min=$C000, max=$FFFF, fill]


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
.const CIA_TODT			= $8808
.const CIA_TODS			= $8809
.const CIA_TODM			= $880A
.const CIA_TODH			= $880B

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


// Jump Table
//////////////////////////////////////////////////////////////////////////////
// Lo almacenado aqui es lo que se llama en esos eventos

.const keyUp			= $FFF0
.const keyDown			= $FFF2
.const keyOk			= $FFF4
.const keyCancel		= $FFF6


//////////////////////////////////////////////////////////////////////////////
//////   RAM                                                            //////
//////////////////////////////////////////////////////////////////////////////

*=$E000 "RAM"  

program:

halt:		jmp halt

/////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
//////   ROM                                                            //////
//////////////////////////////////////////////////////////////////////////////

*=$FC00 "ROM"

reset:
			lda #09						// DEFAULT 20.0 MHz
			sta FREQ_METER					// Needed to reset CIA in worst case scenario
			jsr ciaReset					
			jsr ciaTodStart
			jsr krnFreqMeter
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

kbdSetup:
//Sets VIA to read keyboard
			pha
			lda VIA_DDRB
			and #%00001111
			sta VIA_DDRB			// VIA PB 4 5 6 7 as inputs, others unchanged
			lda #$00
			sta KEY_PRESSED
			pla
			rts

kbdScan:

chkbtn:		pha		
			phx
			phy

			lda VIA_PRTB       		// Read Port B
			sta $94
			ora #%00001111
			cmp #$FF
			beq noKeyKbdScan			// no hay tecla pulsada, fic
									// Con un scaneo de 5 veces por segundo.... no hace falta debounce

			bbs7 $94, b6
			jsr kbdUp			// UP pulsado
			lda KEY_PRESSED
			ora #UP
			sta KEY_PRESSED
			jmp endKbdScan

b6:			bbs6 $94, b5
			jsr kbdDown  		// DOWN pulsado
			lda KEY_PRESSED
			ora #DOWN
			sta KEY_PRESSED
			jmp endKbdScan

b5:			bbs5 $94, b4
			jsr kbdOk
			lda KEY_PRESSED
			ora #OK
			sta KEY_PRESSED
			jmp endKbdScan

b4: 		bbs4 $94, endKbdScan 
			jsr kbdCancel
			lda KEY_PRESSED
			ora #CANCEL
			sta KEY_PRESSED
			jmp endKbdScan

noKeyKbdScan:
			lda #$00
			sta KEY_PRESSED

endKbdScan:
		    ply
			plx
			pla
			rts

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

lcdReset:	
// Reset, clear, and set 4 bit mode
			pha

			lda #$00
			sta CIA_PRTA			// CIA all PA low
			lda #$FF
			sta CIA_DDRA			// CIA all PA as OUTPUT

			lda #$30
			jsr lcdInstr		// Enable 8-bit mode

			lda #$30
			jsr lcdInstr		// Enable 8-bit mode
			lda #$30
			jsr lcdInstr		// Enable 4-bit mode

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
			lda #$C0
			jsr lcdInstr

			pla

			rts

lcdInstr:  
// Send instruction in A HI nibble to lcd
			pha
								// Envia instrucción al LCD. Bits 4-7 del acumulador
			and #$F0            // Me quedo con los bits 4-7. RS, RW, E a 0
			sta CIA_PRTA			// Acumulador al PA
  			jsr krnShortDelay
			
			ora #$08			// Enable a 1
			sta CIA_PRTA
			jsr krnShortDelay

			and #$F0
			sta CIA_PRTA
 			jsr krnShortDelay

			pla
			rts

lcdChar:	
// Sends char in A to LCD at current cursor
			pha

			pha					// Guardamos A en la pila
			and #$F0 			// Me quedo con el upper nibble
			ora #$02			// Register = DATA
			sta CIA_PRTA
			jsr krnShortDelay

			ora #$08			// Enable a 1
			sta CIA_PRTA
			jsr krnShortDelay

			and #$F2			// Enable a 0
			sta CIA_PRTA
			jsr krnShortDelay

			pla 				// Recuperamos el caracter de la pila 
			asl
			asl
			asl
			asl					// desplazamos lower nibble a upper nibble
			and #$F0
			ora #$02
			sta CIA_PRTA
			jsr krnShortDelay

			ora #$08
			sta CIA_PRTA
			jsr krnShortDelay

			and #$F2
			sta CIA_PRTA
			jsr krnShortDelay

			pla
			rts

scrClear:
			// Fill Screen with blank spaces
			pha
			phx

			lda #$20   	// Blank
			ldx #$00    // index
sS_clear:	sta $7000,x
			sta $7100,x
			sta $7200,x
			sta $7300,x
			sta $7400,x
			sta $7500,x
			sta $7600,x
			sta $7700,x
			sta $7800,x
			sta $7900,x
			sta $7A00,x
			sta $7B00,x
			sta $7C00,x
			sta $7D00,x
			sta $7E00,x
			sta $7F00,x
			inx 
			bne sS_clear

			plx
			pla
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
			jsr scrClear

			pla
			rts

scrPrintStr:
			phx
			phy

			stx STRING_POINTER
			sty STRING_POINTER+1

scrPrintStr1:
			lda (STRING_POINTER)
			cmp #$00
			beq scrPrintStrEnd
			jsr scrPrintChar
			inc STRING_POINTER
			bne scrPrintStr1
			inc STRING_POINTER+1
			jmp scrPrintStr1

scrPrintStrEnd:
			jsr scrSetWindow
			ply
			plx
			rts

scrPrintChar:
// Prints char in accumulator in screen memory and advances cursor
            pha

			sta (SCREEN_CURSOR_POINTER)
			inc SCREEN_CURSOR_POINTER
			bne scrPrintCharEnd				// No overflow, fin
			inc SCREEN_CURSOR_POINTER+1		// Overflow, incr HI Pointer


scrPrintCharEnd:
			// Miramos si hemos dado la vuelta
			lda SCREEN_CURSOR_POINTER
			cmp #$3C
			bne scrPrintCharEnd2
			lda SCREEN_CURSOR_POINTER+1
			cmp #$7F
			bne scrPrintCharEnd2
				// Cursor pointar at 7F3C == fuera
			jsr scrClear
			lda #$00
			sta SCREEN_CURSOR_POINTER
			lda #$70
			sta SCREEN_CURSOR_POINTER+1

scrPrintCharEnd2:
			pla
			rts

scrRefresh:
			// Pone la memoria de pantalla en el lcd
			pha
			phy

			lda #$80
			jsr lcdInstr
			lda #$00
			jsr lcdInstr 		// Cursor a 0

			ldy #$00
dl1:		lda ($10),y
			jsr lcdChar
			iny
			cpy #$14
			bne dl1

			ldy #$28
dl3:		lda ($10),y
			jsr lcdChar
			iny
			cpy #$3C
			bne dl3

			ldy #$14
dl2:		lda ($10),y
			jsr lcdChar
			iny
			cpy #$28
			bne dl2

			ldy #$3C
dl4:		lda ($10),Y
			jsr lcdChar
			iny
			cpy #$50
			bne dl4

			ply
			pla
			rts

scrScrollUp:
			pha
	
			lda SCREEN_POINTER			
			sec
			sbc #$14 				// Restamos 20 al screen pointer
			sta SCREEN_POINTER
			bcs scrScrollUpEnd      // Carry Clear, no hay overflow
									// overflow
			dec SCREEN_POINTER+1	// DEC HI BYTE
			lda SCREEN_POINTER+1    
			cmp #$6f
			bne scrScrollUpEnd                  // No nos hemos pasado, fin
			lda #<SCREEN_BASE
			sta SCREEN_POINTER
			lda #>SCREEN_BASE
			sta SCREEN_POINTER+1 	// Set up base window
scrScrollUpEnd:
			pla
			rts

scrScrollDown:
			pha

			clc
			lda SCREEN_POINTER
			adc #$14				// Sumanos 20 al screen pointer
			sta SCREEN_POINTER

			bcc scrScrollDownEnd       // Carry Clear, no hay overflow
									// overflow
			inc SCREEN_POINTER+1	// INC HI BYTE
			lda SCREEN_POINTER+1    
			cmp #$7f
			bne scrScrollDownEnd                  // No nos hemos pasado, fin
			lda #$EC
			sta SCREEN_POINTER
			lda #$7E 
			sta SCREEN_POINTER+1
scrScrollDownEnd:
			pla
			rts

scrSetWindow:
			pha
			phx
			// Primero, restamos 0x7000 + 60 al SCREEN_CURSOR_POINTER
			// eso nos da la primera linea que hay que mostrar
			// un caracter de la primera linea a mostrar en pantalla
			// si la resta es menor a 0, dejamos 0
			// 0x7000 + 60 = 0X703C

		sec
		lda SCREEN_CURSOR_POINTER 
		sbc #$3C
		sta SCREEN_WINDOW_TEMP 
		lda SCREEN_CURSOR_POINTER+1 
		sbc #$70  
		sta SCREEN_WINDOW_TEMP+1
		bcs l0
		lda #$00
		sta SCREEN_WINDOW_TEMP
		sta SCREEN_WINDOW_TEMP+1

			// scren WINDOW TEMP TIENE UN CARACTER DE LA PRIMERA LINEA
			// aHORA, DIVIDIMOS screen_window_temp POR 20
			// Division 
//		jmp scrSetWindowEnd
l0:
		ldx #$FF
		inc SCREEN_WINDOW_TEMP+1
l1:		inx
		sec
		lda SCREEN_WINDOW_TEMP
		sbc #$14
		sta SCREEN_WINDOW_TEMP
		bcs l1
		dec SCREEN_WINDOW_TEMP+1
		bne l1

			// x es el numero de linea a mostrar
			// Multipicamos SCREEN_WINDOW_TEMP x 20
		lda #$00
		clc
		sta SCREEN_WINDOW_TEMP
		sta SCREEN_WINDOW_TEMP+1
m1:		cpx #$00
		beq m0
		dex
		clc
 		lda SCREEN_WINDOW_TEMP
		adc #$14
		sta SCREEN_WINDOW_TEMP
		bcc m1
		inc SCREEN_WINDOW_TEMP+1
		jmp m1

m0:
			// SCREEN WINDOW TEMP
			// Este es el offset del primer caracter a mostrar
			// Add 0x7000 para obtener SCRENN?WINDOW?PINTE
		lda SCREEN_WINDOW_TEMP+1
		clc
		adc #$70
		sta SCREEN_POINTER+1
		lda SCREEN_WINDOW_TEMP
		sta SCREEN_POINTER

			// end

scrSetWindowEnd:
			plx
			pla
			rts

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


*=$FFF0 "JUMP TABLE" 
.word scrScrollUp
.word scrScrollDown
.word krnDoNothing
.word krnDoNothing

*=$FFFA "Vectors"
 .word viaISR // NMI
 .word reset  // Reset
 .word $0000  // IRQ/BRK
     