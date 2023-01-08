// FEC8 FEC8 FE8D/93 F0B9 EFB4 EECC

// TOD
					jsr ciaReset			// Reset both cias
					lda #$01
					sta CIA1_CRGB			// CIA1 TB is our timestamp
					lda #$00
					lda #%10000100
					sta CIA2_ICR			// Enable TOD IRQs

// Load Alarm
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
// Load TOD
// 01.01.01.06
					lda #$01
					sta CIA2_TODH
					lda #$01
					sta CIA2_TODM
					lda #$01
					sta CIA2_TODS
					lda #$06
					sta CIA2_TODT					

// TICK tod using VIA

					ldx #$0C
tictoc:				lda VIA_PRTB
					ora #%01000000
					sta VIA_PRTB			// PB6 high, others, unchanged
					and #%10111111
					sta VIA_PRTB			// PB6 low, others, unchanged
					dex 
					bne tictoc
					jsr krnLongDelay 		// Wait for IRQ


// SDR Send
					jsr ciaReset				// Reset both cias
					lda #$01
					sta CIA1_CRGB				// CIA1 TB is our timestamp
					lda #%10001000
					sta CIA2_ICR				// Enable SDR IRQs		
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

					jsr krnLongDelay

// SDR Receive
					jsr ciaReset				// Reset both cias
					lda #$01
					sta CIA1_CRGB				// CIA1 TB is our timestamp
					lda #%10001000
					sta CIA2_ICR				// Enable SDR IRQs	

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

// FLAG
					jsr ciaReset				// Reset both cias
					lda #$01
					sta CIA1_CRGB				// CIA1 TB is our timestamp
					lda #%10010000
					sta CIA2_ICR				// Enable FLAG IRQs
					jsr krnLongDelay
					lda CIA1_PRTB				// READ PRTB CIA1, triggers nPC

					jsr krnLongDelay

// END
					lda #35
					jsr scrPrintChar 		// This is the END
											// Test if the irq arrives early enough
					cli
 					lda #%11000000
 					sta VIA_IER				// Enable VIA INTERRUPT				
 					jmp endendendend

waitForIRQ:
 					pha 

       				jsr krnLongDelay 		// Wait some time
 					lda CIA2_ICR			// LOAD ICR
 					jsr scrPrint8			// AND print
 					lda CIA2_ICR			// LOAD ICR
 					jsr scrPrint8			// AND print
 											// THIS TIME Should be 0
 					lda #$20
 					jsr scrPrintChar 	
					jsr ciaReset

 					pla 
 					rts

