// -----------------------------------------------------------------------------
// Begin of CIA2 Testing
// -----------------------------------------------------------------------------

					lda #$01 					// Reset test value to 1
					sta testNo					// TestNo holds running test
            		dec
	           		sta testNo+1 				// as a 2 byte decimal
	           		sta testOK+1
	           		sta testOK
            		jsr ciaReset				// Local Reset CIAs

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