// -----------------------------------------------------------------------------
// 
// 6526 Test Suite for SBC v2
// CIA2 is assumed to be 74HCT6526
// CIA1 can be MOS6526 or 74HCT6526
//
// Author : Daniel Molina 
// https://github.com/dmolinagarcia
//
// 2018 - 2021
//
// -----------------------------------------------------------------------------

// Initialization

					lda #$01 					// Reset test value to 1
					sta testNo					
            		dec
            		sta testNo+1

            		jsr ciaReset				// Safe Reset CIAs

			     	ldx #<str_title				// Print title			
					ldy #>str_title
					jsr scrPrintStr		


// -----------------------------------------------------------------------------
// Begin of Tests
// -----------------------------------------------------------------------------

//  TEST 0001. DDRA Initialization Value
//		RESET
//		READ and CMP #$0
//		EQ OK NE KO

test0001:			jsr printTest				// Test header
					jsr ciaReset				// Reset CIA
					lda CIA2_DDRA
					cmp #$00					// Compare reset value
					beq test0001_ok
					jsr printKO 				// KO
					jmp test0001_end
test0001_ok:		jsr printOK 				// OK
test0001_end:

//  TEST 0002. DDRB Initialization Value
//		RESET
//		READ and CMP #$0
//		EQ OK NE KO

test0002: 			jsr printTest				// Test header
					jsr ciaReset				// Reset CIA
					lda CIA2_DDRB
					cmp #$00					// Compare reset value
					beq test0002_ok
					jsr printKO 				// KO
					jmp test0002_end
test0002_ok:		jsr printOK 				// OK
test0002_end:	

//	TEST 0003. DDRA WRITE / READ
//		RESET
//		WRITE 00..FF to DDRA
//		READ BACK
//		IF ALL EQ OK, NE KO

test0003:			jsr printTest
         			jsr ciaReset
         			clc
         			lda #$00
test0003_01:		sta CIA2_DDRA
         			cmp CIA2_DDRA
         			bne test0003_ko
         			clc
         			adc #$01
         			bcs test0003_ok
         			jmp test0003_01
test0003_ko: 		jsr printKO
         			jmp test0003_end
test0003_ok:		jsr printOK
test0003_end:		lda #$00
					sta CIA2_DDRA

//	TEST 0004. DDRB WRITE / READ
//		RESET
//		WRITE 00..FF to DDRB
//		READ BACK
//		IF ALL EQ OK, NE KO

test0004:			jsr printTest
         			jsr ciaReset
         			clc
         			lda #$00
test0004_01:		sta CIA2_DDRB
         			cmp CIA2_DDRB
         			bne test0004_ko
         			clc
         			adc #$01
         			bcs test0004_ok
         			jmp test0004_01
test0004_ko: 		jsr printKO
         			jmp test0004_end
test0004_ok:		jsr printOK
test0004_end:		lda #$00
					sta CIA2_DDRB

//	TEST 0005. PORTA as INPUT
//		RESET
//		READ PORTA
//		EQ FF OK, NE KO
//		Tests DDR=0 (All inputs) and passive pull-ups

test0005:			jsr printTest				// Test header
					jsr ciaReset				// Reset CIA
					lda CIA2_PRTA
					cmp #$FF					// Compare reset value
					beq test0005_ok
					jsr printKO 				// KO
					jmp test0005_end
test0005_ok:		jsr printOK 				// OK
test0005_end:

//	TEST 0006. PORTB as INPUT
//		RESET
//		READ PORTB
//		EQ FF OK, NE KO
//		Tests DDR=0 (All inputs) and passive pull-ups

test0006:			jsr printTest				// Test header
					jsr ciaReset				// Reset CIA
					lda CIA2_PRTB
					cmp #$FF					// Compare reset value
					beq test0006_ok
					jsr printKO 				// KO
					jmp test0006_end
test0006_ok:		jsr printOK 				// OK
test0006_end:

//	TEST 0007. PORTA as OUTPUT RESET VALUE
//		RESET. DDRA=FF
//		READ PORTA
//		EQ 00 OK, NE KO
//		Tests DDR=1 (All outputs) reset value

test0007:			jsr printTest				// Test header
					jsr ciaReset				// Reset CIA
					lda #$FF
					sta CIA2_DDRA
					lda CIA2_PRTA
					cmp #$00 					// Compare reset value
					beq test0007_ok
					jsr printKO 				// KO
					jmp test0007_end
test0007_ok:		jsr printOK 				// OK
test0007_end:

//	TEST 0008. PORTB as OUTPUT RESET VALUE
//		RESET. DDRB=FF
//		READ PORTB
//		EQ 00 OK, NE KO
//		Tests DDR=1 (All outputs) reset value

test0008:			jsr printTest				// Test header
					jsr ciaReset				// Reset CIA
					lda #$FF
					sta CIA2_DDRB
					lda CIA2_PRTB
					cmp #$00 					// Compare reset value
					beq test0008_ok
					jsr printKO 				// KO
					jmp test0008_end
test0008_ok:		jsr printOK 				// OK
test0008_end:

//	TEST 0009. PORTA as input
//		RESET. DDRA1=FF
//		WRITE 00..FF to PORTA1
//		READ PORTA2
//		IF ALL EQ OK, NE KO
//		Tests PORTA2 as input, driven by PORTA1

test0009:			jsr printTest
         			jsr ciaReset
         			lda #$FF							
					sta CIA1_DDRA						
					clc									
					lda #$00 							
test0009_01:		sta CIA1_PRTA 						
         			cmp CIA2_PRTA 						
  					bne test0009_ko						
  					clc
         			adc #$01
         			bcs test0009_ok
         			jmp test0009_01
test0009_ko: 		jsr printKO
         			jmp test0009_end
test0009_ok:		jsr printOK
test0009_end:		lda #$00
					sta CIA1_DDRA

//	TEST 0010. PORTB as input
//		RESET. DDRB1=FF
//		WRITE 00..FF to PORTB1
//		READ PORTB2
//		IF ALL EQ OK, NE KO
//		Tests PORTB2 as input, driven by PORTB1

test0010:			jsr printTest
         			jsr ciaReset
         			lda #$FF							
					sta CIA1_DDRB						
					clc									
					lda #$00 							
test0010_01:		sta CIA1_PRTB 						
         			cmp CIA2_PRTB 						
  					bne test0010_ko						
  					clc
         			adc #$01
         			bcs test0010_ok
         			jmp test0010_01
test0010_ko: 		jsr printKO
         			jmp test0010_end
test0010_ok:		jsr printOK
test0010_end:		lda #$00
					sta CIA1_DDRB

//	TEST 0011. PORTA as output
//		RESET. DDRA2=FF
//		WRITE 00..FF to PORTA2
//		READ PORTA1
//		IF ALL EQ OK, NE KO
//		Tests PORTA2 as output, read by PORTA1

test0011:			jsr printTest
         			jsr ciaReset
         			lda #$FF							
					sta CIA2_DDRA						
					clc									
					lda #$00 							
test0011_01:		sta CIA2_PRTA 						
         			cmp CIA1_PRTA 						
  					bne test0011_ko						
  					clc
         			adc #$01
         			bcs test0011_ok
         			jmp test0011_01
test0011_ko: 		jsr printKO
         			jmp test0011_end
test0011_ok:		jsr printOK
test0011_end:		lda #$00
					sta CIA2_DDRA

//	TEST 0012. PORTB as output
//		RESET. DDRB2=FF
//		WRITE 00..FF to PORTB2
//		READ PORTB1
//		IF ALL EQ OK, NE KO
//		Tests PORTB2 as output, read by PORTB1

test0012:			jsr printTest
         			jsr ciaReset
         			lda #$FF							
					sta CIA2_DDRB						
					clc									
					lda #$00 							
test0012_01:		sta CIA2_PRTB 						
         			cmp CIA1_PRTB 						
  					bne test0012_ko						
  					clc
         			adc #$01
         			bcs test0012_ok
         			jmp test0012_01
test0012_ko: 		jsr printKO
         			jmp test0012_end
test0012_ok:		jsr printOK
test0012_end:		lda #$00
					sta CIA2_DDRB

// -----------------------------------------------------------------------------
// End of Tests
// -----------------------------------------------------------------------------

// Halt at end
programEnd:
			jmp programEnd

// -----------------------------------------------------------------------------
// Functions
// -----------------------------------------------------------------------------

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
			cld
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

printKO:
			phx
			phy
			ldx #<str_txtKO
			ldy #>str_txtKO
			jsr scrPrintStr
			ply 
			plx
			rts

printOK:
			phx
			phy
			ldx #<str_txtOK
			ldy #>str_txtOK
			jsr scrPrintStr
			ply 
			plx
			rts

// -----------------------------------------------------------------------------
// Variables
// -----------------------------------------------------------------------------

testNo:
			.word $0000

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



// -----------------------------------------------------------------------------
// Draft Area
// -----------------------------------------------------------------------------


// tests. PORTS _ TEST PC PULSE!
//        PORTS _ irq ON pc PULSE VIA FLAG?

//	TEST 0005.	PORTA Reset
				jsr printTest
				jsr ciaReset
				lda CIA2_PRTA
				cmp #$FF
				beq test5_ok
				jsr printKO
				jmp test5_end
test5_ok:		jsr printOK
test5_end:			
				lda CIA2_PRTB
			

 				jmp programEnd

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
localReset:
				jsr ciaReset
				jsr lcdReset
				rts

//////////////////////////////////////
ciaIRQ:
				inc $7008
				lda CIA2_ICR		// CREAR CIA IRQ
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


