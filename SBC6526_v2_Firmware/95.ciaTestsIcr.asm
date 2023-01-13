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

 					jsr enableTodFromVia    // Disable Tod from Arduino
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
 					and icr_mask
 					cmp #$01  				// TA SET
 					bne test0042_ko

 					lda CIA2_ICR			// LOAD ICR . Should be 0
 					and icr_mask
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
 					and icr_mask
 					cmp #$02  				// TA SET
 					bne test0043_ko

 					lda CIA2_ICR			// LOAD ICR . Should be 0
 					and icr_mask
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

// Check if TOD is Present
					lda reg_present
					and #TOD_PRESENT
					beq test0044_na

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
					jsr tickTodFromVia		// Tick FF times

 					lda CIA2_ICR			// LOAD ICR
 					and icr_mask
 					cmp #$04  				// TOD SET
 					bne test0044_ko

 					lda CIA2_ICR			// LOAD ICR . Should be 0
 					and icr_mask
 					beq test0044_ok			// If 0
 					
test0044_ko:		
					jsr printKO
 					jmp test0044_end
test0044_na:
					jsr printNA 					
 					jmp test0044_end
test0044_ok:		
					jsr printOK
test0044_end:

// Test0045
// Tests if SDR fires interrupt on send

test0045: 			jsr printTest
					jsr ciaReset

// Check if SDR is Present
					lda reg_present
					and #SDR_PRESENT
					beq test0045_na

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
 					and icr_mask
 					cmp #$09  					// SDR and TA SET
 					bne test0045_ko

 					lda CIA2_ICR				// LOAD ICR . Should be 0
 					and icr_mask
 					beq test0045_ok				// If 0
 					
test0045_ko:		
					jsr printKO
 					jmp test0045_end
test0045_na:
					jsr printNA 					
 					jmp test0045_end
test0045_ok:		
					jsr printOK
test0045_end:					

// Test0046
// Tests if SDR fires interrupt on receive

test0046: 			jsr printTest
					jsr ciaReset

// Check if SDR is Present
					lda reg_present
					and #SDR_PRESENT
					beq test0046_na

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
 					and icr_mask
 					cmp #$08  					// SDR SET
 					bne test0046_ko

 					lda CIA2_ICR				// LOAD ICR . Should be 0
 					and icr_mask
 					beq test0046_ok				// If 0
 					
test0046_ko:		
					jsr printKO
 					jmp test0046_end
test0046_na:
					jsr printNA 					
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
 					and icr_mask

 					cmp #$10  					// FLAG SET
 					bne test0047_ko

 					lda CIA2_ICR				// LOAD ICR . Should be 0
 					and icr_mask
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
                    sty $C0
                    stx $C1										
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


// Test 0050
// Test TOD Alarm IRQ

					lda #$00
					sta $C0 
					sta $C1

test0050:			jsr printTest
					jsr ciaReset			// Reset both cias

// Check if TOD is Present
					lda reg_present
					and #TOD_PRESENT
					beq test0050_na

					lda #$01
					sta CIA1_CRGB			// CIA1 TB is our timestamp
					lda #%10000100
 					sta CIA2_ICR			// Enable TOD IRQs
// Set Alarm
// 01.01.02.09
					lda #$80
					sta CIA2_CRGB 					// ALARM=1
					lda #$01
					sta CIA2_TODH
					lda #$01
					sta CIA2_TODM
					lda #$02
					sta CIA2_TODS
					lda #$09
					sta CIA2_TODT
					lda #$00
					sta CIA2_CRGB 					// ALARM=0
// Set TOD
// 01.01.00.01
					lda #$01
					sta CIA2_TODH
					lda #$01
					sta CIA2_TODM
					lda #$00
					sta CIA2_TODS
					lda #$01
					sta CIA2_TODT
 					jsr enableTodFromVia    // Disable Tod from Arduino

// TICK tod using VIA
					ldx #$FF
					jsr tickTodFromVia

					ldy $c0						// Reload TB vales
					ldx $c1

					cpy #$F1					// F1A1 or F19F
					bne test0050_ko		
					cpx #$A1
					beq test0050_ok
					cpx #$9F
					beq test0050_ok
test0050_ko:		jsr printKO
					jmp test0050_end
test0050_na:
					jsr printNA 					
 					jmp test0050_end
test0050_ok:		jsr printOK
test0050_end:	

// Test 0051
// Test SDR interrupt on send

test0051:			jsr printTest
					jsr ciaReset				// Reset both cias

// Check if SDR is Present
					lda reg_present
					and #SDR_PRESENT
					beq test0051_na

					lda #$01
					sta CIA1_CRGB				// CIA1 TB is our timestamp

					lda #%10001000
					sta CIA2_ICR				// Enable SDR IRQs

					lda #%01000000
					sta CIA2_CRGA				// CIA2 SPMODE = OUTPUT											

					lda #$FC
					sta CIA2_TALO 				// CIA2 TA = 02FC
					lda #$02
					sta CIA2_TAHI

					lda #%01000001				
					sta CIA2_CRGA 				// START timera and SPOUT

					ldx #$AA
					stx CIA2_SDR 				// Write to PORT OUT		

					wai 	

					cpy #$D2
					bne test0051_ko
					cpx #$EB
					bne test0051_ko
					jsr printOK
					jmp test0051_end
test0051_na:
					jsr printNA 					
 					jmp test0051_end
test0051_ko:		jsr printKO
test0051_end:

// Test 0052
// Test SDR interrupt on receive

test0052:			jsr printTest
					jsr ciaReset				// Reset both cias

// Check if SDR is Present
					lda reg_present
					and #SDR_PRESENT
					beq test0052_na

					lda #$01
					sta CIA1_CRGB				// CIA1 TB is our timestamp

					lda #%10001000
					sta CIA2_ICR				// Enable SDR IRQs

					lda #%01000000
					sta CIA1_CRGA				// CIA1 SPMODE = OUTPUT		

					lda #$F3
					sta CIA1_TALO 				// CIA1 TA = 00FF
					lda #$05
					sta CIA1_TAHI

					lda #%01000001				
					sta CIA1_CRGA 				// CIA1  START timera and SPOUT

					ldx #$AA
					stx CIA1_SDR 				// Write to CIA 1 PORT OUT	

					wai 

					cpy #$A0 
					bne test0052_ko
					cpx #$7B
					bne test0052_ko
					jsr printOK
					jmp test0052_end
test0052_na:
					jsr printNA 					
 					jmp test0052_end
test0052_ko:		jsr printKO
test0052_end:

// Test 0053
// Interrupt on Flag

test0053:			jsr printTest
					jsr ciaReset				// Reset both cias
					lda #$01
					sta CIA1_CRGB				// CIA1 TB is our timestamp

					lda #$00
					sta $C0 
					sta $C1

					lda #%10010000
					sta CIA2_ICR				// Enable SDR IRQs

					jsr krnLongDelay
					jsr krnLongDelay

					lda CIA1_PRTB

					jsr krnLongDelay

					ldy $c0						// Reload TB vales
					ldx $c1

					cpy #$DD 
					bne test0053_ko
					cpx #$C6
					bne test0053_ko
					jsr printOK
					jmp test0053_end
test0053_ko:		jsr printKO
test0053_end:					