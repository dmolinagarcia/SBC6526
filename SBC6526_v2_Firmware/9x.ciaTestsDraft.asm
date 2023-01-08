// -----------------------------------------------------------------------------
// Draft Area
// -----------------------------------------------------------------------------

// Skip execution of all this sh**

			jmp endendendend



// tests. PORTS _ TEST PC PULSE!
//        PORTS _ irq ON pc PULSE VIA FLAG?

testAlarmIRQ:
	// SET IRQ VECTOR
				sei
				lda #<ciaIRQ
				sta vecIRQ
				lda #>ciaIRQ
				sta vecIRQ+1

	// SETUP IRQ. Solo TOD activo
				lda #%10000100
				sta CIA2_ICR
				lda #%00011011			 
				sta CIA2_ICR
				lda CIA2_ICR			// clear irq
				
				jsr stopTODticker   // Control del TOD mediante la VIA
				jsr loadTOD  		// 01.00.00.0
	//			jsr loadALARM		// 01.00.10.0
	// Screen IRQ counter
				lda #$30
				sta $7008			// 0 en el contador de interrupciones

				lda CIA2_ICR	

				cli 
todtest:
				jsr printTOD
				jsr tickTod
				jmp todtest


//////////////////////////////////////
tickTod:
				ldx #1
tick1:		
				ldy #1
tick2:		
				lda VIA_PRTB
				ora #%00000010
				sta VIA_PRTB			// PB1 high, others, unchanged

				and #%11111101
				sta VIA_PRTB			// PB1 low, others, unchanged


				jsr krnShortDelay
				jsr krnShortDelay
				jsr krnShortDelay
				jsr krnShortDelay
				jsr krnShortDelay
				jsr krnShortDelay
				
				inc $7002
				lda $7002
				cmp #'6'
				bne endBummer
				lda #'0'
				sta $7002
 endBummer:
				dey
				bne tick2
				dex
				bne tick1

				rts

//////////////////////////////////////
stopTODticker:
				// PB0 en la via se debe poner HIGH (es tod enable)
				lda VIA_DDRB
				ora #%00000001    
				sta VIA_DDRB			// PB0 as output, (TODENABLE) others unchanged

				lda VIA_PRTB
				ora #%00000001
				sta VIA_PRTB			// PB0 high, others, unchanged

				lda VIA_DDRB
				ora #%00000010    
				sta VIA_DDRB			// PB1 as output, (TOD) others unchanged

				lda #'0'
				sta $7002

				jsr krnShortDelay				// arduino ha soltado tod
				rts

//////////////////////////////////////
loadTOD:
				lda CIA2_CRGB
				and #$7F
				sta CIA2_CRGB 					// ALARM=0
				lda #$04
				sta CIA2_TODH
				lda #$24
				sta CIA2_TODM
				lda #$02
				sta CIA2_TODS
				lda #$00
				sta CIA2_TODT
				rts

//////////////////////////////////////
loadALARM:
				lda CIA2_CRGB
				ora #$80
				sta CIA2_CRGB 					// ALARM=1
				lda #$04
				sta CIA2_TODH
				lda #$24
				sta CIA2_TODM
				lda #$10
				sta CIA2_TODS
				lda #$02
				sta CIA2_TODT
				lda CIA2_CRGB
				and #$7F
				sta CIA2_CRGB 					// ALARM=0
				rts

loadTenths:
				pha
				lda #$00
				sta CIA2_TODT
				pla
				rts


//////////////////////////////////////
ciaIRQ:
				inc $7008
				lda CIA2_ICR		// CLEAR CIA IRQ
				jsr printTOD2
				rti

//////////////////////////////////////
printTOD:
				lda CIA2_TODH
				and #$F0
				ror
				ror
				ror
				ror
				jsr nib2hex

				sta $7000+60

				lda CIA2_TODH
				and #$0F
				jsr nib2hex
				sta $7001+60

				lda #':'			// :
				sta $7002+60
				sta $7005+60
				sta $7008+60
				
				lda CIA2_TODM
				and #$F0
				ror
				ror
				ror
				ror
				jsr nib2hex
				sta $7003+60

				lda CIA2_TODM
				and #$0F
				jsr nib2hex
				sta $7004+60

				lda CIA2_TODS
				and #$F0
				ror
				ror
				ror
				ror
				jsr nib2hex
				sta $7006+60

				lda CIA2_TODS
				and #$0F
				jsr nib2hex
				sta $7007+60

				lda CIA2_TODT
				and #$0F
				jsr nib2hex
				sta $7009+60
				rts

//////////////////////////////////////
printTOD2:
				lda CIA2_TODH
				and #$F0
				ror
				ror
				ror
				ror
				jsr nib2hex

				sta $7000+40

				lda CIA2_TODH
				and #$0F
				jsr nib2hex
				sta $7001+40

				lda #':'			// :
				sta $7002+40
				sta $7005+40
				sta $7008+40
				
				lda CIA2_TODM
				and #$F0
				ror
				ror
				ror
				ror
				jsr nib2hex
				sta $7003+40

				lda CIA2_TODM
				and #$0F
				jsr nib2hex
				sta $7004+40

				lda CIA2_TODS
				and #$F0
				ror
				ror
				ror
				ror
				jsr nib2hex
				sta $7006+40

				lda CIA2_TODS
				and #$0F
				jsr nib2hex
				sta $7007+40

				lda CIA2_TODT
				jsr nib2hex
				sta $7009+40
				rts

flipTODIN:
				pha
				lda CIA2_CRGA
				eor #$80
				sta CIA2_CRGA
				pla
				rts

endendendend: