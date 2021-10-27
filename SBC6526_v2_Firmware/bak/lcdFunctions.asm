// LCD Functions for SBCv1
#importonce

/***************************
 SPEC

 lcdReset. Performs a reset of the LCD screen. 
 lcdInstr. Sends instructio in A HI nibble to lcd. Always 4 bit
 lcdChar.  Sends char in A to lcd. sends in two 4-bit instructions.

****************************/

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