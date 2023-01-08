//  TEST 0027. CRGB Initialization Value
//		RESET
//		READ and CMP #$0
//		EQ OK NE KO

test0027:			jsr printTest				// Test header
					jsr ciaReset				// Reset CIA
					lda CIA2_CRGB
					cmp #$00					// Compare reset value
					beq test0027_ok
					jsr printKO 				// KO
					jmp test0027_end
test0027_ok:		jsr printOK 				// OK
test0027_end:

//  TEST 0028. CRGb Write and read
//      WRITE FF to CRGB
//		READ Should be 11101111

test0028:			jsr printTest				// Test header
					lda #$FF
					sta CIA2_CRGB
					lda CIA2_CRGB
					cmp #%11101111				// Compare
					beq test0028_ok
					jsr printKO 				// KO
					jmp test0028_end
test0028_ok:		jsr printOK 				// OK
test0028_end:

//  TEST 0029. CRGB Timer output on PB7
//  	Set PORTB as OUTPUT
//		Enable PB7 output (CREGB1=1)
//		Enable TIMERB Toggle (CREGB=2)
//		Check PB7. Should be 0
//		START and STOP Timer. PB7 should be 1

test0029:			jsr printTest
					jsr ciaReset
					lda #$FF
					sta CIA2_DDRB				// PORTB as output
					lda #%00000110
					sta CIA2_CRGB				// PB7 on and TOGGLE 
					lda CIA2_PRTB
					and #%10000000
					bne test0029_ko				// PB7 should be 0
					lda #%00000111
					ldx #%00000110
					sta CIA2_CRGB
					stx CIA2_CRGB				// start and stop TIMERB
					lda CIA2_PRTB
					and #%10000000
					beq test0029_ko				// Should be 1
					jsr printOK
					jmp test0029_end
test0029_ko:		jsr printKO
test0029_end:		

//	TEST 0030. TIMERB reload on RESET
// 		Resets CIA
//		TBLO/TBHI should be FFFF

test0030:			jsr printTest
					jsr ciaReset
					lda CIA2_TBLO
					cmp #$FF
					bne test0030_ko				// If not FF, test fails
					lda CIA2_TBHI
					cmp #$FF
					bne test0030_ko				// If not FF, test fails
					jsr printOK
					jmp test0030_end
test0030_ko:		jsr printKO
test0030_end:

// 	TEST 0031. TIMERB read and write
//			Write 0000 and test back
//			If OK, inc until FF
//			

test0031:			jsr printTest
					jsr ciaReset
					ldx #$00
					ldy #$00
test0031_loop:		stx CIA2_TBLO
					sty CIA2_TBHI
					cpx CIA2_TBLO
					bne test0031_ko
					cpy CIA2_TBHI
					bne test0031_ko
					inx
					cpx #$00 
					bne test0031_loop
					lda #$01
					cmp MACHINE_TYPE
					beq test0031_ok 		 	// In Logisim complete only one loop
					iny
					cpy #$00
					bne test0031_loop

test0031_ok:		jsr printOK
					jmp test0031_end

test0031_ko:		jsr printKO
test0031_end:					

// 	TEST 0032. TIMERB reload on FORCELOAD
//			Start timer
//			Wait for delay
//			Issue FORCELOAD
// 			Wait for delay and stop
//			Test value.
//			Reload and test
//	Tests show that original MOS6526 stops at EEF7


test0032:			jsr ciaReset
					jsr printTest
					lda #$01
					sta CIA2_CRGB				// Start Timer
					jsr krnLongDelay	 		// Wait for delay
					lda #$11 					
					sta CIA2_CRGB 				// Force LOAD
					jsr krnLongDelay
					lda #$00 					
					sta CIA2_CRGB 				// Stop Timer
					nop
					nop
					lda CIA2_TBLO 
					cmp #$F7
					bne test0032_ko
                    lda CIA2_TBHI
					cmp #$EE 
					bne test0032_ko 			// Test EEF7
					lda #$10 					
					sta CIA2_CRGB 				// Reload again
					lda CIA2_TBLO 
					cmp #$FF
					bne test0032_ko
					lda CIA2_TBHI
					cmp #$FF 
					bne test0032_ko 			// Test FFFF
					jsr printOK
					jmp test0032_end
test0032_ko:		jsr printKO
test0032_end:

// 	TEST 0033. TIMERB reload on OVERFLOW
//			Set timer to low value
// 			Start timer
//			Delay
//			Stop Timer
//			Check timer
//	If reload on underflow is ok. should get same value

test0033:			jsr printTest
					jsr ciaReset
					lda #$10
					sta CIA2_TBLO
					lda #$00
					sta CIA2_TBHI				// Load 0010 on timer
					lda #$01
					sta CIA2_CRGB				// Start timer
					jsr krnLongDelay 			// Delay
					lda #$00
					sta CIA2_CRGB 				// Stop timer.Should be 0007
					lda CIA2_TBHI
					cmp #$00
					bne test0033_ko
					lda CIA2_TBLO 
					cmp #$07
					bne test0033_ko
					jsr printOK
					jmp test0033_end
test0033_ko:		jsr printKO
test0033_end:		

// TEST 0034. TIMERB reload on TBHI write when not running
//		Reset CIA
// 		Start Timer (At FFFF)
//		write to TBHI while running
// 		read TBHI
//		Shouldn't reload
//		Stop timer
//		Read TBHI. shoudn't yet reload
//		Write TBHI
//		Read TBHI
//		Should Reload

test0034: 			jsr printTest
					jsr ciaReset
					lda #$01
					sta CIA2_CRGB 				// Start timer							
					sta CIA2_TBHI 				// Write 01 to TAHI
					lda CIA2_TBHI 				// Read TAHI
					cmp #$FF 		
					bne test0034_ko 			// STill should be FF
					lda #$00
					sta CIA2_CRGB 				// Stop Timer
					lda CIA2_TBHI
					cmp #$FF 					// Still should be FF
					bne test0034_ko
					lda #$01
					sta CIA2_TBHI				// Write 01 to TAHI
					lda CIA2_TBHI
					cmp #$01 					// Should update
					bne test0034_ko
					jsr printOK
					jmp test0034_end
test0034_ko:		jsr printKO
test0034_end:

// TEST 0035. TOGGLE OUTPUT
//		Reset CIA
//		Set PB7 ON / PB7 as output
//		Check timer output. Should be 0
//		Set low value
//		Start
//		Check. (Before toggling) Should be 1
//		Wait until toggle
//		Check.  Should be 0
//		Wait until toggle
//		Check.  Should be 1
//		Wait until toggle
//		Check.  Should be 0
//		Wait until toggle
//		Check.  Should be 1
//		Wait until toggle
//		Check.  Should be 0

test0035:  			jsr printTest
					jsr ciaReset
					jsr krnLongDelay

					lda #$07
					sta CIA2_TBLO
					lda #$00
					sta CIA2_TBHI				// Count 7 cycles

					lda #$06
					sta CIA2_CRGB 				// PB7 = on and Toggle
					lda #$80
					sta CIA2_DDRB 				// PB7 as output
					and CIA2_PRTB
					bne test0035_ko 			// If PB7 != 0


 					lda #$07
 					sta CIA2_CRGB 				// Start time, PB7 as out,
 												// And toggle
 
 					lda #$80
 					and CIA2_PRTB
 					beq	test0035_ko				// Just started, if PB6 7=1
 												// This loop takes 7 cycles
 												// So each test, it should've
 												// toggled!
 
 					lda #$80
 					and CIA2_PRTB
 					bne	test0035_ko
 
 					lda #$80
 					and CIA2_PRTB
 					beq	test0035_ko
 
 					lda #$80
 					and CIA2_PRTB
 					bne	test0035_ko
 
 					lda #$80
 					and CIA2_PRTB
 					beq	test0035_ko															
 
 					lda #$80
 					and CIA2_PRTB
 					bne	test0035_ko
 
 					lda #$80
 					and CIA2_PRTB
 					beq	test0035_ko															
 
 					lda #$80
 					and CIA2_PRTB
 					bne	test0035_ko
 
 					lda #$80
 					and CIA2_PRTB
 					beq	test0035_ko															
 
 					lda #$80
 					and CIA2_PRTB
 					bne	test0035_ko
 
 					lda #$80
 					and CIA2_PRTB
 					beq	test0035_ko															
					jsr printOK	
					jmp test0035_end
test0035_ko:  		jsr printKO
test0035_end:

// TEST 0036. PULSE OUTPUT
//		Reset CIA
//		Set PB7 ON / PB7 as output
//		Check timer output. Should be 0
//		Set low value (0008)
//		Start
// 		Check timer on a 7 cycle long. Still 0

test0036:  			jsr printTest
					jsr ciaReset

					lda #$08
					sta CIA2_TBLO
					lda #$00
					sta CIA2_TBHI				// Count 8 cycles

					lda #$02
					sta CIA2_CRGB 				// PB7 = on
					lda #$80
					sta CIA2_DDRB 				// PB7 as output
					and CIA2_PRTB
					bne test0036_ko 			// If PB7 != 0

  					lda #$03
  					sta CIA2_CRGB 				// Start time, PB7 as out,
  												// And PULSE
  
  					lda #$80
  					and CIA2_PRTB
  					bne	test0036_ko				// Just started, if PB7 !=0
  												// This loop takes 7 cycles
  												// So each test, it drifts 1 cycle
  					lda #$80
  					and CIA2_PRTB
  					bne	test0036_ko				// Still 0
  					lda #$80
  					and CIA2_PRTB
  					bne	test0036_ko				// Still 0
  					lda #$80
  					and CIA2_PRTB
  					bne	test0036_ko				// Still 0
  					lda #$80
  					and CIA2_PRTB
  					bne	test0036_ko				// Still 0
  					lda #$80
  					and CIA2_PRTB
  					beq	test0036_ko				// Pulse!

					jsr printOK	
					jmp test0036_end
test0036_ko:  		jsr printKO
test0036_end:

// TEST 0037. Test ONESHOT
// 		Reset, and set timer for 0006
//		Start on oneshot
//		nop nop
// 		CHECK CREGB for 8
// 		CHECK TIMERB for 0006

test0037:  			jsr printTest
					jsr ciaReset
					lda #$06
					sta CIA2_TBLO
					lda #$00
					sta CIA2_TBHI
					lda #$09
					sta CIA2_CRGB 				// Start on oneshot
					nop
					nop
					nop
					lda CIA2_CRGB
					cmp #$08
					bne test0037_ko
					lda CIA2_TBHI
					cmp #$00
					bne test0037_ko
					lda CIA2_TBLO
					cmp #$06
					bne test0037_ko
					jsr printOK
					jmp test0037_end
test0037_ko:		jsr printKO
test0037_end: 				

// TEST 0038. Double Count on underflow under PHI2
//		Reset CIA
//		Load timers with 6
//		Start
// 		Check value
// 		ON MOS6526 first count is 4
//		OTHERWISE, check. 

test0038:  			jsr printTest
					jsr ciaReset

					lda #$06
					sta CIA2_TBLO
					lda #$00
					sta CIA2_TBHI				// Count 6 cycles

  					lda #$01
  					sta CIA2_CRGB 				// Start timer
  
  					lda CIA2_TBLO
  					cmp #$04
  					bne	test0038_ko				

  					lda CIA2_TBLO
  					cmp #$03
  					bne	test0038_ko				

  					lda CIA2_TBLO
  					cmp #$02
  					bne	test0038_ko				

  					lda CIA2_TBLO
  					cmp #$01
  					bne	test0038_ko				

  					lda CIA2_TBLO
  					cmp #$06
  					bne	test0038_ko				

  					lda CIA2_TBLO
  					cmp #$06
  					bne	test0038_ko				

  					lda CIA2_TBLO
  					cmp #$05
  					bne	test0038_ko				

					jsr printOK	
					jmp test0038_end
test0038_ko:  		jsr printKO
test0038_end:

// TEST 0039. COUNT on CNT, and count = 0 on underflow
// 		Usaremos SPSEND desde la CIA1, para generar 8 pulsos
//		Set CIA2 SPMODE to IN
test0039:  			jsr printTest
					jsr ciaReset


					lda #$08
					sta CIA2_TBLO
					lda #$00
					sta CIA2_TBHI				// TIMERA set to 0008

					lda #%00100001
					sta CIA2_CRGB 				// SPMODE = input BY DEFAULT
												// Count CNT
												// Start TIMERB

					lda #%01000000
					sta CIA1_CRGA				// CIA1 SPMODE = OUTPUT											

					lda #$FF
					sta CIA1_TALO 				// CIA1 TA = 00FF
					lda #$00
					sta CIA1_TAHI

					lda #%01000001				
					sta CIA1_CRGA 				// START timera and SPOUT

					ldx #$AA 
					stx CIA1_SDR 				// Write to PORT OUT
					jsr krnLongDelay 			// WAIT FOR SEND
					lda CIA2_TBLO
					cmp #$00					// Should be 0
					bne test0039_ko

					stx CIA1_SDR 				// Write to PORT OUT
					jsr krnLongDelay 			// WAIT FOR SEND
					lda CIA2_TBLO
					cmp #$01					// Should be 1
					bne test0039_ko

					stx CIA1_SDR 				// Write to PORT OUT
					jsr krnLongDelay 			// WAIT FOR SEND
					lda CIA2_TBLO
					cmp #$02					// Should be 2
					bne test0039_ko

					stx CIA1_SDR 				// Write to PORT OUT
					jsr krnLongDelay 			// WAIT FOR SEND
					lda CIA2_TBLO
					cmp #$03					// Should be 3
					bne test0039_ko

					stx CIA1_SDR 				// Write to PORT OUT
					jsr krnLongDelay 			// WAIT FOR SEND
					lda CIA2_TBLO
					cmp #$04					// Should be 4
					bne test0039_ko

					stx CIA1_SDR 				// Write to PORT OUT
					jsr krnLongDelay 			// WAIT FOR SEND
					lda CIA2_TBLO
					cmp #$05					// Should be 5
					bne test0039_ko

					stx CIA1_SDR 				// Write to PORT OUT
					jsr krnLongDelay 			// WAIT FOR SEND
					lda CIA2_TBLO
					cmp #$06					// Should be 6
					bne test0039_ko

					stx CIA1_SDR 				// Write to PORT OUT
					jsr krnLongDelay 			// WAIT FOR SEND
					lda CIA2_TBLO
					cmp #$07					// Should be 7
					bne test0039_ko

					stx CIA1_SDR 				// Write to PORT OUT
					jsr krnLongDelay 			// WAIT FOR SEND
					lda CIA2_TBLO
					cmp #$08					// Should be 8
					bne test0039_ko

					stx CIA1_SDR 				// Write to PORT OUT
					jsr krnLongDelay 			// WAIT FOR SEND
					lda CIA2_TBLO
					cmp #$00					// Should be 0
					bne test0039_ko

					jsr printOK
					jmp test0039_end
test0039_ko:		jsr printKO
test0039_end:					

// TEST 0040. 
// Stop timer on underflow. Even in continuos mode, it should stop a 0

test0040: 			jsr printTest
					jsr ciaReset
					lda #$06
					sta CIA2_TBLO
					lda #$00
					sta CIA2_TBHI
					lda #$01
					sta CIA2_CRGB
					lda #$00
					sta CIA2_CRGB
					lda CIA2_TBLO
					cmp #$00
					bne test0040_ko
					jsr printOK
					jmp test0040_end
test0040_ko:		jsr printKO
test0040_end:	

// TEST 0041. TB counts TA and terminal case
// Cuando TB cuenta TA UNDERFLOWS, TB avanza tras el 2 discount
// Pero cuanto TB llega a su underflow, se adelanta un ciclo
// EDIT. No tengo tan claro si esto es cierto.. pero testeo casos limite

test0041: 			jsr printTest
					jsr ciaReset

					lda #$0A
					sta CIA2_TALO
	
					lda #$03
					sta CIA2_TBLO
	
					lda #$00
					sta CIA2_TAHI			// TA = 0x000A
					sta CIA2_TBHI			// TB = 0x0003
	
					lda #$41
					sta CIA2_CRGB			// TB Start and count TA
					lda #$01
					sta CIA2_CRGA			// TA START
	
					ldx $00 				//
					ldx $00 				//
					nop 					//
					nop						// 10 cycle delay to read 0x0009 from TA

					ldx CIA2_TBLO			
					cpx #$02		
					bne test0041_ko			
					cpx $00           		// JUST FOR DELAY	

					ldx CIA2_TBLO			
					cpx #$01		
					bne test0041_ko			
					cpx $00           		
		
					ldx CIA2_TBLO			
					cpx #$00			
					bne test0041_ko			
					cpx $00           		
		
					ldx CIA2_TBLO			
					cpx #$03			
					bne test0041_ko			
					cpx $00           		
		
					ldx CIA2_TBLO			
					cpx #$02				
					bne test0041_ko			
					cpx $00   

// Rinse and repeat

					jsr ciaReset

					lda #$0A
					sta CIA2_TALO
	
					lda #$03
					sta CIA2_TBLO
	
					lda #$00
					sta CIA2_TAHI			// TA = 0x000A
					sta CIA2_TBHI			// TB = 0x0003
	
					lda #$41
					sta CIA2_CRGB			// TB Start and count TA
					lda #$01
					sta CIA2_CRGA			// TA START
	
					ldx $00 				//
					nop 					//
					nop 					//
					nop						// 9 cycle delay to read second 0x000A from TA

					ldx CIA2_TBLO			
					cpx #$03		
					bne test0041_ko			
					cpx $00           		// JUST FOR DELAY	

					ldx CIA2_TBLO			
					cpx #$02
					bne test0041_ko			
					cpx $00           		
		
					ldx CIA2_TBLO			
					cpx #$01			
					bne test0041_ko			
					cpx $00           		
		
					ldx CIA2_TBLO			
					cpx #$03		
					bne test0041_ko			
					cpx $00           		
		
					ldx CIA2_TBLO			
					cpx #$03				
					bne test0041_ko			
					cpx $00 					        		
 	
					jsr printOK
					jmp test0041_end
test0041_ko:		jsr printKO
test0041_end: