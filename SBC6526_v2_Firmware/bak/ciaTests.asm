#importonce

				lda #$00
				sta testNo					// Reset test value to 0

start:
	     		ldx #<str_title				// Print title			
				ldy #>str_title
				jsr scrPrintStr

//  TEST 0001. DDRA Initialization Value
//		RESET
//		READ and CMP #$0
//		EQ OK NE KO
//		RESET LCD

test0001:		jsr printTest				// Test header
				jsr ciaReset				// Reset CIA
				lda CIA_DDRA
				cmp #$00					// Compare reset value
				beq test0001_ok
				jsr printKO 				// KO
				jmp test0001_end
test0001_ok:	jsr printOK 				// OK
test0001_end:	jsr lcdReset				// Reset LCD


jmp programEnd

//  TEST 0002. DDRB Initialization Value
//		RESET
//		READ and CMP #$0
//		EQ OK NE KO
//		RESET LCD

test0002:		jsr printTest				// Test header
				jsr ciaReset				// Reset CIA
				lda CIA_DDRB
				cmp #$00					// Compare reset value
				beq test0002_ok
				jsr printKO 				// KO
				jmp test0002_end
test0002_ok:	jsr printOK 				// OK
test0002_end:	jsr lcdReset				// Reset LCD



//	TEST 0003. DDRA WRITE / READ
//		RESET
//		WRITE 00..FF to DDRA
//		READ BACK
//		IF ALL EQ OK, NE KO
//		RESET LCD



test0003:		jsr printTest
         		jsr ciaReset
         		clc
         		lda #$00
test0003_01:	sta CIA_DDRA
         		cmp CIA_DDRA
         		bne test0003_ko
         		clc
         		adc #$01
         		bcs test0003_ok
         		jmp test0003_01
test0003_ko: 	jsr printKO
         		jmp test0003_end
test0003_ok:	jsr printOK
test0003_end:	jsr lcdReset
				 


//	TEST 0004. DDRb WRITE / READ
//		RESET
//		WRITE 00..FF to DDRb
//		READ BACK
//		IF ALL EQ OK, NE KO

test0004:		jsr printTest
         		jsr ciaReset
         		clc
         		lda #$00
test0004_01:	sta CIA_DDRB
         		cmp CIA_DDRB
         		bne test0004_ko
         		clc
         		adc #$01
         		bcs test0004_ok
         		jmp test0004_01
test0004_ko: 	jsr printKO
         		jmp test0004_end
test0004_ok:	jsr printOK
test0004_end:	jsr lcdReset
											


										 



//	TEST 0005.	PORTA Reset
				jsr printTest
				jsr ciaReset
				lda CIA_PRTA
				cmp #$FF
				beq test5_ok
				jsr printKO
				jmp test5_end
test5_ok:		jsr printOK
test5_end:			
				lda CIA_PRTB
			

 				jmp programEnd


printKO:		phx
				phy
				ldx #<str_txtKO
				ldy #>str_txtKO
				jsr scrPrintStr
				ply 
				plx
				rts

printOK:		phx
				phy
				ldx #<str_txtOK
				ldy #>str_txtOK
				jsr scrPrintStr
				ply 
				plx
				rts

testNo:
				.word $0000

printTest:
		// Print " TEST "
				phx
				phy
				pha
				ldx #<str_test
				ldy #>str_test
				jsr scrPrintStr
				
		// Print number
				lda testNo+1
				and #$F0
				clc
				ror
				ror
				ror
				ror
				clc
				adc #$30
				jsr scrPrintChar
				lda testNo+1
				and #$0F
				clc
				adc #$30
				jsr scrPrintChar

				lda testNo
				and #$F0
				ror
				ror
				ror
				ror
				clc
				adc #$30
				jsr scrPrintChar
				lda testNo
				and #$0F
				clc
				adc #$30
				jsr scrPrintChar		

		// Increment test number
				sed
				lda testNo
				clc
				adc #$01
				sta testNo
				cmp #$00
				beq incrementNext
				pla
				ply
				plx
				rts

	incrementNext:
				lda testNo+1
				clc
				adc #$01
				sta testNo+1
				cld
				pla
				ply
				plx
				rts


str_title:
	.text "-= 74HCT6526 TEST =-"
	.byte $00

str_test:
	.text " TEST "
	.byte $00

str_txtOK:
	.text "   ( OK ) "
	.byte $00

str_txtKO:
	.text "   ( KO ) "
	.byte $00
	


testAlarmIRQ:
	// SET IRQ VECTOR
				sei
				lda #<ciaIRQ
				sta vecIRQ
				lda #>ciaIRQ
				sta vecIRQ+1

	// SETUP IRQ. Solo TOD activo
				lda #%10000100
				sta CIA_ICR
				lda #%00011011			 
				sta CIA_ICR
				lda CIA_ICR			// clear irq
				
				jsr stopTODticker   // Control del TOD mediante la VIA
				jsr loadTOD  		// 01.00.00.0
	//			jsr loadALARM		// 01.00.10.0
	// Screen IRQ counter
				lda #$30
				sta $7008			// 0 en el contador de interrupciones

				lda CIA_ICR	

				cli 
todtest:
				jsr printTOD
				jsr tickTod
				jmp todtest

// Functions
//////////////////////////////////////
nib2hex:
				cmp #$0a
         		bcc nib2hex0_9           
		        ora #$30
		        clc
		        adc #$07
		        rts
nib2hex0_9:		ora #$30         
				rts

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
				lda CIA_CRGB
				and #$7F
				sta CIA_CRGB 					// ALARM=0
				lda #$04
				sta CIA_TODH
				lda #$24
				sta CIA_TODM
				lda #$02
				sta CIA_TODS
				lda #$00
				sta CIA_TODT
				rts

//////////////////////////////////////
loadALARM:
				lda CIA_CRGB
				ora #$80
				sta CIA_CRGB 					// ALARM=1
				lda #$04
				sta CIA_TODH
				lda #$24
				sta CIA_TODM
				lda #$10
				sta CIA_TODS
				lda #$02
				sta CIA_TODT
				lda CIA_CRGB
				and #$7F
				sta CIA_CRGB 					// ALARM=0
				rts

loadTenths:
				pha
				lda #$00
				sta CIA_TODT
				pla
				rts

//////////////////////////////////////
localReset:
				jsr ciaReset
				jsr lcdReset
				rts

//////////////////////////////////////
ciaIRQ:
				inc $7008
				lda CIA_ICR		// CREAR CIA IRQ
				jsr printTOD2
				rti

//////////////////////////////////////
printTOD:
				lda CIA_TODH
				and #$F0
				ror
				ror
				ror
				ror
				jsr nib2hex

				sta $7000+60

				lda CIA_TODH
				and #$0F
				jsr nib2hex
				sta $7001+60

				lda #':'			// :
				sta $7002+60
				sta $7005+60
				sta $7008+60
				
				lda CIA_TODM
				and #$F0
				ror
				ror
				ror
				ror
				jsr nib2hex
				sta $7003+60

				lda CIA_TODM
				and #$0F
				jsr nib2hex
				sta $7004+60

				lda CIA_TODS
				and #$F0
				ror
				ror
				ror
				ror
				jsr nib2hex
				sta $7006+60

				lda CIA_TODS
				and #$0F
				jsr nib2hex
				sta $7007+60

				lda CIA_TODT
				and #$0F
				jsr nib2hex
				sta $7009+60
				rts

//////////////////////////////////////
printTOD2:
				lda CIA_TODH
				and #$F0
				ror
				ror
				ror
				ror
				jsr nib2hex

				sta $7000+40

				lda CIA_TODH
				and #$0F
				jsr nib2hex
				sta $7001+40

				lda #':'			// :
				sta $7002+40
				sta $7005+40
				sta $7008+40
				
				lda CIA_TODM
				and #$F0
				ror
				ror
				ror
				ror
				jsr nib2hex
				sta $7003+40

				lda CIA_TODM
				and #$0F
				jsr nib2hex
				sta $7004+40

				lda CIA_TODS
				and #$F0
				ror
				ror
				ror
				ror
				jsr nib2hex
				sta $7006+40

				lda CIA_TODS
				and #$0F
				jsr nib2hex
				sta $7007+40

				lda CIA_TODT
				jsr nib2hex
				sta $7009+40
				rts

flipTODIN:
				pha
				lda CIA_CRGA
				eor #$80
				sta CIA_CRGA
				pla
				rts


