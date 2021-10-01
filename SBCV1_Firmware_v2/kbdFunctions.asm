// Keyboard Functions for SBCv1
#importonce

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

kbdWaitOK:
	bbr1 KEY_PRESSED, kbdWaitOK	// Si no esta pulsado, esperamos
w1:						
	bbs1 KEY_PRESSED, w1		// Esta pulsado, esperamos a soltar
	rts