// Screen Functions for SBCv1
#importonce

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
            phy

            ldy #$00
			sta (SCREEN_CURSOR_POINTER),y
            
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
			ply 
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