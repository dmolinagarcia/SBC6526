// -----------------------------------------------------------------------------
// 
// SBC6526v2 Firmware v2.0.2
//
// -----------------------------------------------------------------------------
// 
// 0000 - 7FFF Free RAM
// 8000 - BFFF 8 Blocks IO
// 8800 - 8FFF CIA1 - Int
// 9000 - 97FF VIA
// 9800 - 9FFF CIA2 - Ext
// C000 - FFFF Free RAM
//
// Author : Daniel Molina 
// https://github.com/dmolinagarcia
//
// 2018 - 2022
//
// -----------------------------------------------------------------------------
// Ensure all subroutines return with A,X,Y unchanged!!
// -----------------------------------------------------------------------------

.cpu _65c02
.file [name="sbc6526_v2.bin", type="bin", segments="ROM"]
.segment ROM [min=$F000, max=$FFFF, fill]

#import "10.addresing.asm"

*=$F000 "ROM" 

// -----------------------------------------------------------------------------
// Reset
// -----------------------------------------------------------------------------

reset:
			lda #010					    // DEFAULT 1.0 MHz  
											// Freq Meter not implemented yet
			sta FREQ_METER	
			lda #$00
			sta MACHINE_TYPE				// SBC				
			jsr viaInit						
			jsr ciaReset					
			jsr ciaTodStart
			jsr krnFreqMeter
			jsr scrClear
			jsr scrInitialize
			jsr kbdSetup
			jsr lcdReset
			jsr viaSetTimerInterrupt
			sei 
			jmp program

// -----------------------------------------------------------------------------
// VIA
// -----------------------------------------------------------------------------

viaInit:
// Initializes VIA
			pha
			lda #%0001001
			sta VIA_PRTA			// CiaReset HIGH
									// LCD RW   Low (Write)
									// LCD E    High
			lda #$FF
			sta VIA_DDRA			// PA0     : ciaReset
									// PA1-PA7 : LCD
									// PA      : All Outputs
			pla
			rts

viaSetTimerInterrupt:
			pha

			lda FREQ_METER				// Load system frequency
			sta IRQ_COUNTER				// into interrupt counter

			lda #%01000000
			sta VIA_ACR					// TIMER1 continuous. PB7 off, 
										// shift register off, pb latches off

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

viaDisableInterrupt:
			pha

			lda #%01000000
			sta VIA_IER 				// Disable Timer 1 interrupts

			pla
			rts

// -----------------------------------------------------------------------------
// CIA
// -----------------------------------------------------------------------------

ciaReset:
// Resets both 6526s
			pha
			lda VIA_PRTA
			and #$FE 				
			sta VIA_PRTA			// /CIARES PULLED LOW
			jsr krnShortDelay
			ora #$01
			sta VIA_PRTA			// /CIARES PULLED HIGH
			pla
			rts

ciaTodStart:
// Sets TOD and starts it
			pha
	 		lda #$12			
	 		sta CIA1_TODH			// 12 AM
	 		lda #$00
 			sta CIA1_TODM
			sta CIA1_TODS
			sta CIA1_TODT			// AM 12:00:00.0
 			pla
			rts

// -----------------------------------------------------------------------------
// Kernal
// -----------------------------------------------------------------------------

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

krnDoNothing:
			rts

krnFreqMeter:
//Determines current clock frequency
// so far, not implemented
			rts   /// Return!!!
			pha
			phx
			phy


			ldx #$4A					// Counter LO prescaler
			stx FREQ_COUNTER_LO			// Counter LO stored
			ldy #$0A        			// Counter HI prescaler
			sty FREQ_COUNTER_HI			// Counter HI stored
			lda #$00		
			sta FREQ_METER				// Result location Initialized

			lda CIA1_TODT
krnFreqMeterWait1:			
			cmp CIA1_TODT
			beq krnFreqMeterWait1		// Wait for 10ths to change	
			lda CIA1_TODT				// Store new 10ths value
		
krnFreqMeterWait2:			
			dec FREQ_COUNTER_LO			// Dec LO counter
			bne krnFreqMeterWait3		// If not 0, end
			stx FREQ_COUNTER_LO			// If 0, restore LO
			dec FREQ_COUNTER_HI			// and dec HI counter
			bne krnFreqMeterWait3		// If not 0, end
			sty FREQ_COUNTER_HI			// If 0, restore HI
			inc FREQ_METER				// and increase result
krnFreqMeterWait3:			
			cmp CIA1_TODT				// Has 10ths changed?
			beq krnFreqMeterWait2		// If not, continue

			ply
			plx
			pla
			rts	 

// -----------------------------------------------------------------------------
// LCD
// -----------------------------------------------------------------------------

lcdInstr:  
// Send instruction in A HI nibble to lcd
			pha

			ora #$01 				// CIARES a 1 que es PA0
			ora #$08 				// Enable a 1
									// Envia instrucción al LCD. 
									// Bits 4-7 del acumulador
			and #$F9	            // Me quedo con los bits 4-7. 
									// RS, RW, E a 1 /ciares A 1
			sta VIA_PRTA			// Acumulador al PA
  			jsr krnShortDelay

			and #$F1				// Enable a 0
			sta VIA_PRTA
 			jsr krnShortDelay

			pla
			rts				

lcdReset:	
// Reset, clear, and set 4 bit mode
			pha

			lda FREQ_METER
			pha							// guardamos freqmeter en la pila

			lda #$30					    // Delay largo para el init
			sta FREQ_METER					

			lda #$30
			jsr lcdInstr		// Enable 8-bit mode

			lda #$30
			jsr lcdInstr		// Enable 8-bit mode
			
			lda #$30
			jsr lcdInstr		// Enable 4-bit mode
						
			lda #$20
			jsr lcdInstr		// Enable 4-bit mode

			lda #$20			// 4-bit 2 lineas 5x8 font
			jsr lcdInstr
			lda #$80
			jsr lcdInstr

			lda #$00			// Clear Display
			jsr lcdInstr
			lda #$10
			jsr lcdInstr

			lda #$00			// Mode Set. Increment and shift
			jsr lcdInstr
			lda #$60
			jsr lcdInstr

			lda #$00			// Display on and cursor OFF
			jsr lcdInstr
			lda #$C0
			jsr lcdInstr

			pla
			sta FREQ_METER					// Restauramos delay

			pla
			rts

lcdChar:	
// Sends char in A to LCD at current cursor
			pha
			pha					// Guardamos A en la pila
			and #$F0 			// Me quedo con el upper nibble
			ora #$03			// Register = DATA   CIARESET=1
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
			and #$F0
			ora #$03
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

// -----------------------------------------------------------------------------
// Screen
// -----------------------------------------------------------------------------

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
			
			pla
			rts

scrPrintStr:
			pha
			phx
			phy
			stx STRING_POINTER
			sty STRING_POINTER+1

scrPrintStr1:
			ldy #$00
			lda (STRING_POINTER),y 
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
			pla
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

scrPrint8:
// Prints in HEX 8bit value in AA
				pha
				pha 
				and #$F0
				ror
				ror
				ror
				ror
				jsr nib2hex
				jsr scrPrintChar
				
				pla
				and #$0F
				jsr nib2hex
				jsr scrPrintChar	

				pla 
				rts

scrPrint16:
// Prints in HEX 16bit value in YYXX
				pha 
				phy 
				phx
				
				tya
				and #$F0
				ror
				ror
				ror
				ror
				jsr nib2hex
				jsr scrPrintChar
				
				tya
				and #$0F
				jsr nib2hex
				jsr scrPrintChar

				txa
	            and #$F0
				ror
				ror
				ror
				ror
				jsr nib2hex
				jsr scrPrintChar
				
				txa
				and #$0F
				jsr nib2hex
				jsr scrPrintChar			

				plx 
				ply 
				pla
				rts



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



// -----------------------------------------------------------------------------
// Keyboard
// -----------------------------------------------------------------------------


// Keyboard Jump table
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
     


kbdSetup:
//Sets VIA to read keyboard
			pha
			lda VIA_DDRB
			and #%11100001
			sta VIA_DDRB			// VIA PB 1234 as inputs, others unchanged
			lda #$00
			sta KEY_PRESSED
			pla
			rts

kbdScan:
chkbtn:		pha		

			lda VIA_PRTB       		// Read Port B
			sta $94
			ora #%11100001
			cmp #$FF
			beq noKeyKbdScan		// no hay tecla pulsada, fic
									// Con un scaneo de 5 veces por segundo
									// no hace falta debounce

			bbs4 $94, b6
			jsr kbdUp			// UP pulsado
			lda KEY_PRESSED
			ora #UP
			sta KEY_PRESSED
			jmp endKbdScan

b6:			bbs3 $94, b5
			jsr kbdDown  		// DOWN pulsado
			lda KEY_PRESSED
			ora #DOWN
			sta KEY_PRESSED
			jmp endKbdScan

b5:			bbs2 $94, b4
			jsr kbdOk
			lda KEY_PRESSED
			ora #OK
			sta KEY_PRESSED
			jmp endKbdScan

b4: 		bbs1 $94, endKbdScan 
			jsr kbdCancel
			lda KEY_PRESSED
			ora #CANCEL
			sta KEY_PRESSED
			jmp endKbdScan

noKeyKbdScan:
			lda #$00
			sta KEY_PRESSED

endKbdScan:
			pla
			rts

kbdWaitOK:
	bbr2 KEY_PRESSED, kbdWaitOK	// Si no esta pulsado, esperamos
w1:						
	bbs2 KEY_PRESSED, w1		// Esta pulsado, esperamos a soltar
	rts

// ROM ///////////////////////////////////////////////////////////////////////

program:	  	
				#import "90.ciaTests.asm"
programEnd:		jmp programEnd

//////////////////////////////////////////////////////////////////////////////
//////   VECTORS                                                        //////
//////////////////////////////////////////////////////////////////////////////

*=$FFFA "VECTORS"
vecNMI:		.word viaISR 			// NMI
vecRES:		.word reset  			// Reset
vecIRQ:		.word reset  			// IRQ/BRK

// VECTORS ///////////////////////////////////////////////////////////////////