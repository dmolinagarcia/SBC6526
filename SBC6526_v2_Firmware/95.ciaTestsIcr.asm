// Start OF ICR tests. First, just test if IRQ is detected
// Init. ACK and disable all interrupt sources

testIRQ:
					jsr ciaReset
					jsr krnLongDelay
 					sei 					// disable CPU IRQ
 											// VIA's on NMI
 					lda #%01000000
 					sta VIA_IER				// Disable VIA INTERRUPT

 					lda #%00011111
 					sta CIA2_ICR
 					lda CIA2_ICR			// DISABLE and CLEAR ICR

// STOP 60Hz tod ticker
					// PB0 en la via se debe poner HIGH (es tod enable)
					lda VIA_DDRB
					ora #%00000001    
					sta VIA_DDRB			// PB0 as output, (TODENABLE) others unchanged
	
					lda VIA_PRTB
					ora #%00000001
					sta VIA_PRTB			// PB0 high, others, unchanged
	
					lda VIA_DDRB
					ora #%01000000    
					sta VIA_DDRB			// PB6 as output, (TOD) others unchanged

					jsr krnLongDelay		// arduino ha soltado tod	

// Test 0042
// Tests if TA interrupt is detected and then cleared

test0042: 			jsr printTest
					jsr ciaReset

 					lda #$01
 					sta CIA2_TAHI
 					sta CIA2_CRGA			// START TA
 											// Overflow should set TA BIT

       				jsr krnLongDelay 		// Wait some time for IRQ
 					lda CIA2_ICR			// LOAD ICR
 					cmp #$01  				// TA SET
 					bne test0042_ko

 					lda CIA2_ICR			// LOAD ICR . Should be 0
 					beq test0042_ok			// If 0

test0042_ko:		jsr printKO
					jmp test0042_end
test0042_ok:		jsr printOK
test0042_end:	

// Test 0043
// Tests if TB interrupt is detected and then cleared

test0043: 			jsr printTest
					jsr ciaReset

 					lda #$01
 					sta CIA2_TBHI
 					sta CIA2_CRGB			// START TA
 											// Overflow should set TA BIT

       				jsr krnLongDelay 		// Wait some time for IRQ
 					lda CIA2_ICR			// LOAD ICR
 					cmp #$02  				// TA SET
 					bne test0043_ko

 					lda CIA2_ICR			// LOAD ICR . Should be 0
 					beq test0043_ok			// If 0
 					
test0043_ko:		
					jsr printKO
 					jmp test0043_end
test0043_ok:		
					jsr printOK
test0043_end:					


// Test0044
// Tests if TOD Alarm fires interrupt

test0044: 			jsr printTest
					jsr ciaReset
// Set Alarm
// 01.01.01.08
					lda #$80
					sta CIA2_CRGB 					// ALARM=1
					lda #$01
					sta CIA2_TODH
					lda #$01
					sta CIA2_TODM
					lda #$01
					sta CIA2_TODS
					lda #$08
					sta CIA2_TODT
					lda #$00
					sta CIA2_CRGB 					// ALARM=0
// Set TOD
// 01.01.01.01
					lda #$01
					sta CIA2_TODH
					lda #$01
					sta CIA2_TODM
					lda #$01
					sta CIA2_TODS
					lda #$01
					sta CIA2_TODT
// TICK tod using VIA
					ldx #$FF
tictoc1:			lda VIA_PRTB
					ora #%01000000
					sta VIA_PRTB			// PB6 high, others, unchanged
					and #%10111111
					sta VIA_PRTB			// PB6 low, others, unchanged
					dex 
					bne tictoc1

 					lda CIA2_ICR			// LOAD ICR
 					cmp #$04  				// TOD SET
 					bne test0044_ko

 					lda CIA2_ICR			// LOAD ICR . Should be 0
 					beq test0044_ok			// If 0
 					
test0044_ko:		
					jsr printKO
 					jmp test0044_end
test0044_ok:		
					jsr printOK
test0044_end:

// Test0045
// Tests if SDR fires interrupt on send

test0045: 			jsr printTest
					jsr ciaReset

// SDR Send
					lda #%01000000
					sta CIA2_CRGA				// CIA2 SPMODE = OUTPUT											

					lda #$FF
					sta CIA2_TALO 				// CIA2 TA = 00FF
					lda #$00
					sta CIA2_TAHI

					lda #%01000001				
					sta CIA2_CRGA 				// START timera and SPOUT

					ldx #$AA
					stx CIA2_SDR 				// Write to PORT OUT		

					jsr krnLongDelay 			// Wait for SEND			

 					lda CIA2_ICR				// LOAD ICR
 					cmp #$09  					// SDR and TA SET
 					bne test0045_ko

 					lda CIA2_ICR				// LOAD ICR . Should be 0
 					beq test0045_ok				// If 0
 					
test0045_ko:		
					jsr printKO
 					jmp test0045_end
test0045_ok:		
					jsr printOK
test0045_end:					

// Test0046
// Tests if SDR fires interrupt on receive

test0046: 			jsr printTest
					jsr ciaReset

					lda #%00000000
					sta CIA2_CRGA				// CIA2 SPMODE = INPUT											

					lda #%01000000
					sta CIA1_CRGA				// CIA1 SPMODE = OUTPUT		

					lda #$FF
					sta CIA1_TALO 				// CIA1 TA = 00FF
					lda #$00
					sta CIA1_TAHI

					lda #%01000001				
					sta CIA1_CRGA 				// CIA1  START timera and SPOUT

					ldx #$AA
					stx CIA1_SDR 				// Write to CIA 1 PORT OUT	

					jsr krnLongDelay

 					lda CIA2_ICR				// LOAD ICR
 					cmp #$08  					// SDR SET
 					bne test0046_ko

 					lda CIA2_ICR				// LOAD ICR . Should be 0
 					beq test0046_ok				// If 0
 					
test0046_ko:		
					jsr printKO
 					jmp test0046_end
test0046_ok:		
					jsr printOK
test0046_end:						

// Test0047
// Tests if FLAG fires interrupt

test0047: 			jsr printTest
					jsr ciaReset

					lda CIA1_PRTB				// READ PRTB CIA1, triggers nPC

 					lda CIA2_ICR				// LOAD ICR
 					cmp #$10  					// FLAG SET
 					bne test0047_ko

 					lda CIA2_ICR				// LOAD ICR . Should be 0
 					beq test0047_ok				// If 0
 					
test0047_ko:		
					jsr printKO
 					jmp test0047_end
test0047_ok:		
					jsr printOK
test0047_end:		

// Here we start with the IRQ tests
// Some initial setup is needed

testIRQfire:
					jsr ciaReset		// Reset CIA, just in case

					lda #<irqTestVector // Then, setup the IRQ routine
					sta vecIRQ
					lda #>irqTestVector
					sta vecIRQ+1
					cli 				// And enable interrupts back
					jmp test0048		// Skip the IRQ handler

irqTestVector:	
										// Stops Timers to prevent further IRQs
										// Clears CIA2 Interrupt
										// And returns CIA1 TB as Timestamp
					ldx #$00
					stx CIA2_CRGA
					stx CIA2_CRGB		// STOP CIA2 Both timers
										// To prevent further interrupts
					lda CIA2_ICR		// Clear CIA2 Interrupt
					ldy CIA1_TBHI
					ldx CIA1_TBLO		// Return TBHI TBLO in YYXX
										// Ready for the scrPrint16
					rti									

// test0048
// Test TA firing interrupt

test0048:			jsr printTest
					jsr ciaReset			// Reset both cias
					lda #$01
					sta CIA1_CRGB			// CIA1 TB is our timestamp
					lda #$00
					sta CIA2_TAHI			// CIA2 TA = 00FF
					lda #%10000001
					sta CIA2_ICR			// Enable TA IRQs
					lda #$01
					sta CIA2_CRGA			// START CIA2 TA
					wai 	
					cpy #$FE
					bne test0048_ko
					cpx #$CE 
					bne test0048_ko
					jsr printOK
					jmp test0048_end
test0048_ko:		jsr printKO
test0048_end:					

// test0049
// Test TB firing interrupt

test0049:			jsr printTest
					jsr ciaReset			// Reset both cias
					lda #$01
					sta CIA1_CRGB			// CIA1 TB is our timestamp
					lda #$00
					sta CIA2_TBHI			// CIA2 TB = 00FF
					lda #%10000010
					sta CIA2_ICR			// Enable TB IRQs
					lda #$01
					sta CIA2_CRGB			// START CIA2 TB
					wai 	
					cpy #$FE
					bne test0049_ko
					cpx #$CE 
					bne test0049_ko
					jsr printOK
					jmp test0049_end
test0049_ko:		jsr printKO
test0049_end: